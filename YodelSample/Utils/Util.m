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
