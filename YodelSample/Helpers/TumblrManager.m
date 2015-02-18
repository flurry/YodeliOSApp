//
//  TumblrManager.m
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
#import "TumblrManager.h"
#import "TumblrFetcher.h"
#import "Configuration.h"
#import "ContentItem.h"

@interface TumblrManager ()

@property(nonatomic, strong) NSMutableArray *itemsFetching;
@property(nonatomic, strong) NSMutableArray *itemsReady;

@property(nonatomic, strong) NSOperationQueue *downloadOperationQueue;

@end

static const NSUInteger CONCURRENT_DOWNLOAD_COUNT = 2;      // Number of operations to perform simulataneously

// TumblrManager manages the main stream of Tumblr Content
@implementation TumblrManager

+ (id)sharedInstance
{
    static TumblrManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}


- (id)init
{
    if (self = [super init]) {
        self.itemsFetching = [[NSMutableArray alloc] init];
        self.itemsReady = [[NSMutableArray alloc] init];
        
        self.downloadOperationQueue = [NSOperationQueue new];
        self.downloadOperationQueue.maxConcurrentOperationCount = CONCURRENT_DOWNLOAD_COUNT;

        [self performSelector:@selector(loadContent) withObject:nil afterDelay:1];
    }
    
    return self;
}

-(NSArray*)tumblrItems
{
    @synchronized(self) {
        return self.itemsReady;
    }
}

-(void)refreshContent
{
    @synchronized(self) {
        [self.downloadOperationQueue cancelAllOperations];
        self.itemsFetching = [[NSMutableArray alloc] init];
        self.itemsReady = [[NSMutableArray alloc] init];
        [self performSelectorInBackground:@selector(loadContent) withObject:nil];
    }
}

-(void) loadContent
{
    [[TumblrFetcher sharedInstance] fetchPosts:[Configuration sharedInstance].tumblrBlogName limit:20 callback:^(NSArray *tumblrItems, NSArray *imageDownloadOperations, NSError *error) {
        if (tumblrItems && !error) {
            self.itemsFetching = [NSMutableArray arrayWithArray:tumblrItems];
            
            for(int i=0; i<imageDownloadOperations.count; i++) {
                NSOperation *imageDownloadOperation = [imageDownloadOperations objectAtIndex:i];
                [imageDownloadOperation setCompletionBlock:^(){[self imageDidDownload];}];
            }
            

            [self.downloadOperationQueue addOperations:imageDownloadOperations waitUntilFinished:YES];
            
        } else {
            if(self.delegate && [self.delegate respondsToSelector:@selector(tumblrContaintDidFailToFetch:)]) {
                [self.delegate tumblrContaintDidFailToFetch:error];
            }
        }
    }];
}

-(void)imageDidDownload
{
    @synchronized(self) {
        while(self.itemsFetching.firstObject != nil  && ((ContentItem*)self.itemsFetching.firstObject).images != nil) {
            ContentItem *item = self.itemsFetching.firstObject;
            
            [self.itemsReady addObject:item];
            [self.itemsFetching removeObject:item];
        }
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(tumblrContentUpdated:)]) {
        [self.delegate tumblrContentUpdated:self];
    }
}


@end