//
//  CarouselCollectionViewController.h
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

@protocol CarouselCollectionViewDelegate <NSObject>

- (void) controllerShouldDismiss:(UIViewController *) viewController;

@end


@interface CarouselCollectionViewController : UICollectionViewController

@property(weak, nonatomic) id<CarouselCollectionViewDelegate> delegate;
@property(nonatomic, strong) NSArray *tumblrItems;
@property(nonatomic, strong) id currentItem;
@property(nonatomic, assign) BOOL showLeanMore;

@property(nonatomic, assign) BOOL needsReloadContent; // Set this to true when content should be updated
@end

