//
//  AnalyticsWrapper.m
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
#import "AnalyticsWrapper.h"
#import "Flurry.h"

@implementation AnalyticsWrapper

+(void)logEvent:(NSString*)event
{
    [Flurry logEvent:event];
}

+(void)logEvent:(NSString*)event withContentItem:(ContentItem*)item
{
    [AnalyticsWrapper logEvent:event withParameters:nil andContentItem:item];
}

+(void)logEvent:(NSString*)event withParameters:(NSDictionary*)parameters
{
    [Flurry logEvent:event withParameters:parameters];
}

+(void)logEvent:(NSString*)event withParameters:(NSMutableDictionary*)parameters andContentItem:(ContentItem*)item
{
    if(item) {
        if(!parameters) {
            parameters = [NSMutableDictionary new];
        }
        
        [parameters addEntriesFromDictionary:@{ @"article_type":item.type , @"article_origin":item.source }];
    }
    
    [Flurry logEvent:event withParameters:parameters];
}

+(void)logError:(NSString *)name message:(NSString *)message error:(NSError *)error
{
    [Flurry logError:name message:message error:error];
}

@end