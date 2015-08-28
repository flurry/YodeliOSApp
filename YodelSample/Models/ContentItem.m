//
//  ContentItem.m
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

#import "ContentItem.h"
#import <Foundation/Foundation.h>

@implementation ContentItem

-(instancetype)initWithAd:(FlurryAdNative*)ad
{
    self = [super init];
    if(self) {
        
        self.ad = ad;
        
        self.tags = nil;
        self.date = nil;
        self.type = @"ad";
        
        if ([self.ad isVideoAd]){
            
            self.isVideoAd = YES;
            
            
        } else {
            self.isVideoAd = NO;
        }
        
        for (int ix = 0; ix < ad.assetList.count; ++ix) {
            FlurryAdNativeAsset* asset = [ad.assetList objectAtIndex:ix];
            
            self.callToAction = @"More"; //default value for CTA
            
            if ([asset.name isEqualToString:@"source"]) {
                self.source = asset.value;
            }
            
            if ([asset.name isEqualToString:@"headline"]) {
                self.headline = asset.value;
            }
            
            if([asset.name isEqualToString:@"summary"]) {
                self.caption = asset.value;
            }
            if([asset.name isEqualToString:@"callToAction"]) {
                self.callToAction = asset.value;
            }
           if (!self.isVideoAd) //video ads do not get "secHqImage" asset
            if([asset.name isEqualToString:@"secHqImage"]) {
                
                /*
                  The AdSpace is configured server-side by default to download assets to disk, thus
                  asset.value points to a location on disk. So this request should complete very 
                  quickly. A more complete implementation should take into account the case where
                  the asset.value is a remote URL, and should trigger a "ready" flag before the item
                  is used in the stream.
                */
                void (^downloadCompletionBlock)(NSURLResponse *response, NSData *data, NSError *error) = ^void(NSURLResponse *response, NSData *data, NSError *error) {
                    if(data && !error) {
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        if(image) {
                            self.images = [NSArray arrayWithObject:image];
                        }
                    }
                };
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: asset.value]];
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:downloadCompletionBlock];
            }
        }
    }
    return self;
}

- (UIImage*) displayImage
{
    if(self.images.count > 0) {
        return [self.images objectAtIndex:0];
    } else {
        return nil;
    }
}

- (BOOL) isAd
{
    return self.ad != nil;
}


@end