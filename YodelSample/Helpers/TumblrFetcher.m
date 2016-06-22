//
//  TumblrFetcher.m
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
#import "Configuration.h"
#import "ContentItem.h"
#import "TumblrFetcher.h"
#import "TMAPIClient.h"
#import "AnalyticsWrapper.h"

@implementation TumblrFetcher

+ (id)sharedInstance
{
    static TumblrFetcher *fetcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fetcher = [[self alloc] init];
    });
    return fetcher;
}

- (id)init {
    if (self = [super init]) {
        [TMAPIClient sharedInstance].OAuthConsumerKey = [[Configuration sharedInstance] tumblrApiKey];
        
        // Callbacks  sent to TMAPIClient will be run in background.
        [TMAPIClient sharedInstance].defaultCallbackQueue = [NSOperationQueue new];
    }
    
    return self;
}

- (void)searchTags:(NSString *)tagString limit:(NSUInteger)limit callback:(TumblrFetcherCallback)callback
{
    NSDictionary* parameters = @{ @"filter":@"text" , @"type":@"photo" };
    
    [[TMAPIClient sharedInstance] tagged:tagString parameters:parameters callback:^(id result, NSError* error) {
        if(!error) {
            NSArray* arr = (NSArray*) result;
            [self parsePosts:arr withBlogTitle:nil limit:limit callback:callback];
        } else {
            callback(nil, nil, error);
        }
    }];

}

- (void)fetchPosts:(NSString*)blogName limit:(NSUInteger)limit callback:(TumblrFetcherCallback)callback
{
    NSDictionary* parameters = @{ @"filter":@"text" , @"reblog_info":@"true" };
    
    [[TMAPIClient sharedInstance] posts:blogName type:@"photo" parameters:parameters callback:^(id result, NSError* error) {
        if(!error) {
            @try {
                NSDictionary *json = (NSDictionary *)result;
                NSString* blogTitle = json[@"blog"][@"title"];
                [self parsePosts:json[@"posts"] withBlogTitle:blogTitle limit:limit callback:callback];
            } @catch(NSException *e) {
                NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:@"Unable to parse API response" forKey:NSLocalizedDescriptionKey];
                NSError *parseError = [NSError errorWithDomain:@"TumblrFetcher" code:0 userInfo:errorInfo];
                callback(nil,nil,parseError);
            }
        } else {
            [AnalyticsWrapper logError:@"TumlbrFetch" message:@"Fetch failed" error:error];
            callback(nil, nil, error);
        }
    }];
}

- (void)parsePosts:(NSArray *)xmlItems withBlogTitle:(NSString *)blogTitle limit:(NSUInteger)limit callback:(TumblrFetcherCallback)callback
{
    NSMutableArray *tumblrItems = [NSMutableArray arrayWithCapacity:limit];
    NSMutableArray *imageDownloadOperations = [NSMutableArray arrayWithCapacity:limit];
    
    for (NSDictionary *item in xmlItems) {
        // Currently only support photo items
        if(![item[@"type"] isEqualToString:@"photo"]) {
            continue;
        }
        
        if(tumblrItems.count == limit) {
            break;
        }
        
        ContentItem *tumblrItem = [[ContentItem alloc] init];
        
        if(item[@"reblogged_from_title"]) {
            tumblrItem.source = item[@"reblogged_from_title"];
        } else if(blogTitle) {
            tumblrItem.source = blogTitle;
        } else {
            tumblrItem.source = item[@"blog_name"];
        }
        
        tumblrItem.caption = item[@"caption"];
        tumblrItem.date = [NSDate dateWithTimeIntervalSince1970:[item[@"timestamp"] doubleValue]];
        tumblrItem.tags = item[@"tags"];
        tumblrItem.type = item[@"type"];
        
        // Get image urls to download
        NSMutableArray *photoUrls = [NSMutableArray new];
        for(NSDictionary *photoItem in [item objectForKey:@"photos"]) {
            [photoUrls addObject:[NSURL URLWithString:[[photoItem objectForKey:@"original_size"] objectForKey:@"url"]]];
        }
        
        // Create an array of operations which will download images associated with the content
        // This model for image downloads is used for simplicity
        NSOperation *imgDownloadOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSMutableArray *images = [NSMutableArray new];
            
            for(id photoUrl in photoUrls) {
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:(NSURL*)photoUrl]];
                if(image != nil) {
                    [images addObject:image];
                }
            }
            
            tumblrItem.images = images;
        }];
        
        [imageDownloadOperations addObject:imgDownloadOperation];
        [tumblrItems addObject:tumblrItem];
    }
    
    callback(tumblrItems, imageDownloadOperations, nil);
}

@end