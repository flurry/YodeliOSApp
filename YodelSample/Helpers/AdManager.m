//
//  AdManager.m
//  YodelSample
//
//  Copyright 2015 Yahoo! Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import "AdManager.h"
#import "Configuration.h"
#import "Flurry.h"
#import "Util.h"

@interface AdManager () <FlurryAdNativeDelegate>

@property(nonatomic, strong) NSString *adSpaceName;

// Ads will move from adsFetching to adsReady when the ad has been fetched
@property(nonatomic, strong) NSMutableArray *adsFetching;
@property(nonatomic, strong) NSMutableArray *adsReady;

@end

static const NSUInteger NUM_ADS_TO_PREPARE = 5;   // Number of ads to keep prepared in advance.
static const NSUInteger AD_ERROR_RETRY_DELAY = 4; // Seconds to retry fetchAd after a failure

@implementation AdManager

+ (id)sharedInstance
{
    static AdManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}


- (id)init
{
    if (self = [super init]) {
        self.adSpaceName = [[Configuration sharedInstance] flurryAdSpace];
        self.adsFetching = [[NSMutableArray alloc] init];
        self.adsReady = [[NSMutableArray alloc] init];
        
        [self ensureCapacity];
    }
    
    return self;
}

-(void) ensureCapacity
{
    @synchronized(self) {
        
        // Remove any ads that may have expired.
        NSMutableArray *expiredAds = [NSMutableArray array];
        for(FlurryAdNative *ad in self.adsReady) {
            if((!ad.ready) || (ad.expired)) {
                [expiredAds addObject:ad];
            }
        }
        [self.adsReady removeObjectsInArray:expiredAds];
        
        
        NSUInteger totalAds = self.adsReady.count + self.adsFetching.count;
        
        if(totalAds < NUM_ADS_TO_PREPARE) {
            for (int ix = 0; ix < (NUM_ADS_TO_PREPARE-totalAds); ix++)
            {
                FlurryAdNative* nativeAd = [[FlurryAdNative alloc] initWithSpace:self.adSpaceName];
                nativeAd.adDelegate = self;
                nativeAd.targeting = [FlurryAdTargeting targeting];
                //test mode enabled - do not use this for production apps
                nativeAd.targeting.testAdsEnabled = TRUE;
                
                [Flurry logEvent:@"ad_requested" withParameters:@{@"ad_space":nativeAd.space,
                                                                  @"model":[Util getDeviceModel],
                                                                  @"type":@"unknown"}];
                
                [nativeAd fetchAd];
                [self.adsFetching addObject:nativeAd];
            }
        }
    }
}

-(FlurryAdNative*) getAdIfAvailableForViewController:(UIViewController*) viewController
{
    @synchronized(self) {
        // EnsureCapacity will also remove any expired ads from the adsReady array
        [self ensureCapacity];
        
        if(self.adsReady.count > 0) {
            FlurryAdNative *ad = [self.adsReady objectAtIndex:0];
            [self.adsReady removeObject:ad];
            ad.adDelegate = nil;
            ad.viewControllerForPresentation = viewController;
            return ad;
        } else {
            return nil;
        }
    }
}

#pragma mark - FlurryAdNativeDelegate

- (void) adNativeDidFetchAd:(FlurryAdNative *)flurryAd
{
    NSString* adType = @"native";
    if([flurryAd isVideoAd])
    {
        adType = @"nativeVideo";
    }
    [Flurry logEvent:@"ad_fetched" withParameters:@{@"ad_space":flurryAd.space,
                                                    @"model":[Util getDeviceModel],
                                                    @"network":@"Flurry",
                                                    @"type":adType}];

    @synchronized(self) {
        [self.adsReady addObject:flurryAd];
        [self.adsFetching removeObject:flurryAd];
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(adIsAvailable:)]) {
        [self.delegate adIsAvailable:self];
    }
}

- (void) adNative:(FlurryAdNative *)flurryAd adError:(FlurryAdError)adError errorDescription:(NSError *)errorDescription
{
    NSString* adType = @"native";
    if([flurryAd isVideoAd])
    {
        adType = @"nativeVideo";
    }
    [Flurry logEvent:@"ad_request_error" withParameters:@{@"ad_space":flurryAd.space,
                                                          @"model":[Util getDeviceModel],
                                                          @"error_code":[errorDescription localizedDescription],
                                                          @"network":@"Flurry",
                                                          @"type":adType}];
    
    // Deallocate ad that failed to fetch, and try to fetch new ones after a delay
    @synchronized(self) {
        [self.adsFetching removeObject:flurryAd];
    }
    
    [self performSelector:@selector(ensureCapacity) withObject:nil afterDelay:AD_ERROR_RETRY_DELAY];
}

- (void) adNativeDidLogImpression:(FlurryAdNative *)nativeAd
{
    NSString* adType = @"native";
    if([nativeAd isVideoAd])
    {
        adType = @"nativeVideo";
    }
    [Flurry logEvent:@"ad_displayed" withParameters:@{@"ad_space":nativeAd.space,
                                                      @"type":adType,
                                                      @"model":[Util getDeviceModel],
                                                      @"network":@"Flurry"}];
    
}

- (void) adNativeDidReceiveClick:(FlurryAdNative *)nativeAd
{
    NSString* adType = @"native";
    if([nativeAd isVideoAd])
    {
        adType = @"nativeVideo";
    }
    [Flurry logEvent:@"ad_clicked" withParameters:@{@"ad_space":nativeAd.space,
                                                    @"model":[Util getDeviceModel],
                                                    @"network":@"Flurry",
                                                    @"type":adType}];
}

- (void) adNativeWillPresent:(FlurryAdNative *)nativeAd
{
    NSString *adIsReady = @"FALSE";
    if(nativeAd.ready)
    {
        adIsReady = @"TRUE";
    }
    NSString* adType = @"native";
    if([nativeAd isVideoAd])
    {
        adType = @"nativeVideo";
    }
    [Flurry logEvent:@"ad_display_attempt" withParameters:@{@"ad_ready":adIsReady,
                                                            @"ad_space":nativeAd.space,
                                                            @"model":[Util getDeviceModel],
                                                            @"network":@"Flurry",
                                                            @"type":adType}];
}

@end