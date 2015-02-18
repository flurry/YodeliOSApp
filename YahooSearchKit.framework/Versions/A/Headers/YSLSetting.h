//
//  YSLSetting.h
//  YahooSearchKit
//
//  Copyright (c) 2014 Yahoo! Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Safe search modes supported by YahooSearchKit.
 */
typedef NS_ENUM(NSUInteger, YSLSafeSearchMode)
{
    /**
     This is the safest mode. When set, the search backend aggressively filters any offensive content from the search results.
     */
    YSLSafeSearchModeStrict = 0,
    
    /**
     Less aggressive filtering
     */
    YSLSafeSearchModeModerate,
    
    /**
     No filtering
     */
    YSLSafeSearchModeOFF
};

@interface YSLSetting : NSObject

/**
 *  Initializes YahooSearchKit with the application ID; You must initialize YahooSearchKit with a valid application ID.
 *
 *  @param appId    Application ID
 */
+ (void)setupWithAppId:(NSString *)appId;

/**
 *  Returns the singleton setting instance
 *
 *  @return singleton setting instance
 */
+ (YSLSetting *)sharedSetting;

/**
 *  Set this property to specify the level of filtering that the search backend must perform to remove offensive content from the search results.
 *  You can turn off safe search mode by setting it to YSLSafeSearchModeOFF. Default is YSLSafeSearchModeModerate.
 */
@property (nonatomic, assign) YSLSafeSearchMode safeSearchMode;

/**
 *  Set this property to indicate if developer mode is turned on or off. Default is YES.
 *
 *  In order to avoid tracking search and ad attribution information for any searches performed using your application while
 *  you are still developing it, YahooSearchKit provides a developer mode flag. It is set to YES by default. It is important that you set
 *  it to NO for your production build that you will submit to Apple. Otherwise any searches performed or ads clicked on using your 
 *  application will not receive attribution.
 */
@property (nonatomic, assign) BOOL developerMode;

@end
