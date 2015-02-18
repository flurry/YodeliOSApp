//
//  Configuration.m
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

#import "Configuration.h"

static Configuration* gInstance;

@interface Configuration ()
@property (nonatomic, retain) NSMutableDictionary* info;
@end


@implementation Configuration

+ (id) sharedInstance
{
    @synchronized(self) {
        if (gInstance == nil) {
            gInstance = [[self.class alloc] init];
            NSString *theFile = [[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"];
            gInstance.info = [NSMutableDictionary dictionaryWithContentsOfFile:theFile];
        }
    }
    return gInstance;
}

- (NSString*) flurryApiKey
{
    return [[[self.class sharedInstance] info] objectForKey:@"flurryApiKey"];
}

- (NSString*) flurryAdSpace
{
    return [[[self.class sharedInstance] info] objectForKey:@"flurryAdSpace"];
}

- (NSString*) yahooSearchAppId
{
    return [[[self.class sharedInstance] info] objectForKey:@"yahooSearchAppId"];
}

- (NSString*) tumblrApiKey
{
    return [[[self.class sharedInstance] info] objectForKey:@"tumblrApiKey"];
}

- (NSString*) tumblrBlogName
{
    return [[[self.class sharedInstance] info] objectForKey:@"tumblrBlogName"];
}


@end