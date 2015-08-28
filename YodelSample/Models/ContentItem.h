//
//  ContentItem.h
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
#import <UIKit/UIKit.h>
#import "FlurryAdNative.h"

@class ContentItem;

// A ContentItemCell is a View that can display a ContentItem
@protocol ContentItemCell <NSObject>
- (void) setupWithContentItem:(ContentItem*)item;
@end


/*
  A Content Item is an item that can appear in a view of the app. It can either
  be a Tumblr post, or an Ad. A more complete implementation could separate the
  Tumblr Post and Ad cases into separate objects with a common interface, for a 
  cleaner object model.
*/
@interface ContentItem : NSObject

@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *headline;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) UIView *videoContainer;
@property (nonatomic,strong) NSString *callToAction;
@property (nonatomic) Boolean isVideoAd;

@property (nonatomic, strong) FlurryAdNative *ad;

-(instancetype)initWithAd:(FlurryAdNative*)ad;
-(BOOL) isAd;
//-(BOOL) isVideoAd;
-(UIImage*) displayImage;

@end
