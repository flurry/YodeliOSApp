//
//  TumblrFetcher.h
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

/*
 The callback arguments are an array of ContentItems set up with tumblr posts, and an Array of NSOperations to
 download the associated images. This is a quick way to allow callers define how to download the images, but 
 could definitely be improved.
*/
typedef void (^TumblrFetcherCallback)(NSArray *tumblrItems, NSArray* imageDownloadOperations, NSError* error);

@interface TumblrFetcher : NSObject

+(TumblrFetcher*)sharedInstance;
-(void)searchTags:(NSString *)tagString limit:(NSUInteger)limit callback:(TumblrFetcherCallback)callback;
-(void)fetchPosts:(NSString*)blogName limit:(NSUInteger)limit callback:(TumblrFetcherCallback)callback;

@end