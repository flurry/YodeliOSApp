//
//  TumblrManager.h
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

#import <UIKit/UIKit.h>

@class TumblrManager;

@protocol TumblrManagerDelegate <NSObject>
-(void)tumblrContentUpdated:(TumblrManager*)manager;
-(void)tumblrContaintDidFailToFetch:(NSError*)error;
@end

@interface TumblrManager : NSObject
@property(nonatomic, weak) id<TumblrManagerDelegate> delegate;

+(TumblrManager*)sharedInstance;
-(NSArray*)tumblrItems;
-(void)refreshContent;
@end