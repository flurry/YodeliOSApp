//
//  FlurryAdNativeAssets+Private.h
//  Flurry iOS Advertising
//
//  Copyright 2009-2014 Flurry, Inc. All rights reserved.
//	
//	Methods in this header file are for use by Flurry Publishers

#import <Foundation/Foundation.h>
#import "FlurryAdNativeAsset.h"

/*!
 *  @brief Provides all available methods for displaying native ad assets.
 *
 *  Set of methods that allow publishers to retrieve assets for native ads.
 *
 *  For information on how to use Flurry's Ads SDK to
 *  attract high-quality users and monetize your user base see <a href="http://support.flurry.com/index.php?title=Publishers">Support Center - Publishers</a>.
 *
 *  @author 2009 - 2014 Flurry, Inc. All Rights Reserved.
 *  @version 6.0.0
 *
 */
@interface FlurryAdNativeAsset (Private)


+ (kAssetType) nativeAssetTypeStringToEnum:(NSString*)strVal;


+ (NSString*) nativeAssetTypeEnumToString:(kAssetType)enumVal;

- (id)initWithDictionary:(NSDictionary*)infoDictionary;

@end