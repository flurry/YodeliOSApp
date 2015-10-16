//
//  Utils.m
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

#import "Util.h"
#import "FlurryAdNative.h"
#import <sys/utsname.h>

static const int AD_FREQUENCY = 4;
static const int FIRST_AD_POS = 2;

@implementation Util

+ (NSString*) timeAgoStringFromDate:(NSDate *) date
{
    NSTimeInterval secondsSinceDate = [[NSDate date] timeIntervalSinceDate:date];
    
    int64_t minutesSinceDate = secondsSinceDate / 60.0;
    int64_t hoursSinceDate = minutesSinceDate / 60.0;
    int64_t daysSinceDate = hoursSinceDate / 24.0;
    int64_t yearsSinceDate = daysSinceDate / 365.25;
    
    if(yearsSinceDate > 1) {
        return [NSString stringWithFormat:@"%lld years ago", yearsSinceDate];
    }
    
    if(daysSinceDate > 1) {
        return [NSString stringWithFormat:@"%lld days ago", daysSinceDate];
    }
    
    if(hoursSinceDate > 1) {
        return [NSString stringWithFormat:@"%lld hours ago", hoursSinceDate];
    }
    
    if(minutesSinceDate > 1) {
        return [NSString stringWithFormat:@"%lld minutes ago", minutesSinceDate];
    }
    
    // Only go down to minutes
    return @"1 minute ago";
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSString *)getDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    // Painful if/else here...  maybe move this to swift ala http://stackoverflow.com/questions/26028918/ios-how-to-determine-iphone-model-in-swift but bleh that requires a bridging header...
    if([deviceModel isEqualToString:@"iPod5,1"]){return @"iPod Touch 5";}
    else if([deviceModel isEqualToString:@"iPod7,1"]){return @"iPod Touch 6";}
    else if([deviceModel isEqualToString:@"iPhone3,1"] ||
            [deviceModel isEqualToString:@"iPhone3,2"] ||
            [deviceModel isEqualToString:@"iPhone3,3"]){return @"iPhone 4";}
    else if([deviceModel isEqualToString:@"iPhone4,1"]){return @"iPhone 4s";}
    else if([deviceModel isEqualToString:@"iPhone5,1"] ||
            [deviceModel isEqualToString:@"iPhone5,2"]){return @"iPhone 5";}
    else if([deviceModel isEqualToString:@"iPhone5,3"] ||
            [deviceModel isEqualToString:@"iPhone5,4"]){return @"iPhone 5c";}
    else if([deviceModel isEqualToString:@"iPhone6,1"] ||
            [deviceModel isEqualToString:@"iPhone6,2"]){return @"iPhone 5s";}
    else if([deviceModel isEqualToString:@"iPhone7,2"]){return @"iPhone 6";}
    else if([deviceModel isEqualToString:@"iPhone7,1"]){return @"iPhone 6 Plus";}
    else if([deviceModel isEqualToString:@"iPhone8,1"]){return @"iPhone 6s";}
    else if([deviceModel isEqualToString:@"iPhone8,2"]){return @"iPhone 6s Plus";}
    else if([deviceModel isEqualToString:@"iPad2,1"] ||
            [deviceModel isEqualToString:@"iPad2,2"] ||
            [deviceModel isEqualToString:@"iPad2,3"] ||
            [deviceModel isEqualToString:@"iPad2,4"]){return @"iPad 2";}
    else if([deviceModel isEqualToString:@"iPad3,1"] ||
            [deviceModel isEqualToString:@"iPad3,2"] ||
            [deviceModel isEqualToString:@"iPad3,3"]){return @"iPad 3";}
    else if([deviceModel isEqualToString:@"iPad3,4"] ||
            [deviceModel isEqualToString:@"iPad3,5"] ||
            [deviceModel isEqualToString:@"iPad3,6"]){return @"iPad 4";}
    else if([deviceModel isEqualToString:@"iPad4,1"] ||
            [deviceModel isEqualToString:@"iPad4,2"] ||
            [deviceModel isEqualToString:@"iPad4,3"]){return @"iPad Air";}
    else if([deviceModel isEqualToString:@"iPad5,1"] ||
            [deviceModel isEqualToString:@"iPad5,3"] ||
            [deviceModel isEqualToString:@"iPad5,4"]){return @"iPad Air 2";}
    else if([deviceModel isEqualToString:@"iPad2,5"] ||
            [deviceModel isEqualToString:@"iPad2,6"] ||
            [deviceModel isEqualToString:@"iPad2,7"]){return @"iPad Mini";}
    else if([deviceModel isEqualToString:@"iPad4,4"] ||
            [deviceModel isEqualToString:@"iPad4,5"] ||
            [deviceModel isEqualToString:@"iPad4,6"]){return @"iPad Mini 2";}
    else if([deviceModel isEqualToString:@"iPad4,7"] ||
            [deviceModel isEqualToString:@"iPad4,8"] ||
            [deviceModel isEqualToString:@"iPad4,9"]){return @"iPad Mini 3";}
    else if([deviceModel isEqualToString:@"iPad5,2"]){return @"iPad Mini 4";}
    else if([deviceModel isEqualToString:@"i386"] ||
            [deviceModel isEqualToString:@"x86_64"]){return @"Simulator";}
    else return deviceModel;
}



#pragma mark - ad helper routines

+(BOOL)isAdIndex:(NSUInteger)row
{
    return row % AD_FREQUENCY == FIRST_AD_POS;
}

+(NSUInteger)numAdsRequiredForContentAmount:(NSUInteger)numContent
{
    if(numContent == 0) {
        return 0;
    }
    
    // We won't show an ad as the last item in the stream
    numContent--;
    
    if(numContent < FIRST_AD_POS) {
        return 0;
    }
    
    return 1 + (numContent - FIRST_AD_POS) / (AD_FREQUENCY - 1);
}

@end
