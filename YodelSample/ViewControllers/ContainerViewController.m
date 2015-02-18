//
//  SearchBarController.m
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
#import "ContainerViewController.h"
#import "CardTableViewController.h"
#import "SearchBarViewController.h"
#import <QuartzCore/QuartzCore.h>


static const CGFloat TRANSITION_DURATION = 0.3;           // Duration in seconds of animation, when transitioning view controllers
static const CGFloat TRANSITION_OFFSCREEN_PERCENT = 0.35; // When transitioning view controllers off screen, what percent of its size to move off screen

// This Container View Controller is similar to a Navigation Controller, but gives us finer controller over the animation
// and UI elements. SearchBarViewController gives a custom search bar rather than a navigation bar.
@interface ContainerViewController ()

// Can push a single view controller on top of the base controller
@property(strong, nonatomic) CardTableViewController *baseController; // Hard-coded to only accept CardTableViewController for now.
@property(strong, nonatomic) UIViewController *pushedController;

@property(strong, nonatomic) SearchBarViewController *searchBarController;

@end

@implementation ContainerViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup SearchBarController
    SearchBarViewController *searchBarController = [[SearchBarViewController alloc] initWithNibName:@"SearchBarViewController" bundle:nil];
    CGRect searchBarFrame = self.view.frame;
    searchBarFrame.size.height = SEARCH_BAR_HEIGHT;
    searchBarController.view.frame = searchBarFrame;
    [self addChildViewController:searchBarController];
    [searchBarController didMoveToParentViewController:self];
    [self.view addSubview:searchBarController.view];
    self.searchBarController = searchBarController;
    self.searchBarController.containerController = self;
    
    // Setup CardViewController
    CardTableViewController *cardViewController = [[CardTableViewController alloc] init];
    cardViewController.view.frame = self.view.frame;
    UIEdgeInsets inset = cardViewController.tableView.contentInset;
    inset.top += SEARCH_BAR_HEIGHT;
    [cardViewController.tableView setContentInset:inset];
    UIEdgeInsets scrollIndicatorInset = cardViewController.tableView.scrollIndicatorInsets;
    scrollIndicatorInset.top += SEARCH_BAR_HEIGHT;
    [cardViewController.tableView setScrollIndicatorInsets:scrollIndicatorInset];
    
    [self addChildViewController:cardViewController];
    [cardViewController didMoveToParentViewController:self];
    [self.view addSubview:cardViewController.view];
    [self.view sendSubviewToBack:cardViewController.view];
    
    self.baseController = cardViewController;
    self.baseController.containerController = self;
}


-(BOOL)prefersStatusBarHidden
{
    return YES;
}


-(void) pushViewController:(UIViewController *) pushedController
{
    // Currently only support a single pushed controller
    if(self.pushedController) {
        return;
    }

    // Animate pushedController sliding in from right. Supports portrait only.
    CGRect initialPushedControllerFrame = self.view.frame;
    initialPushedControllerFrame.origin.x += self.view.frame.size.width;
    pushedController.view.frame = initialPushedControllerFrame;
    
    CGRect finalPushedControllerFrame = self.view.frame;
    
    CGRect finalBaseControllerFrame = self.baseController.view.frame;
    finalBaseControllerFrame.origin.x -= self.view.frame.size.width * TRANSITION_OFFSCREEN_PERCENT;
    
    CGRect finalSearchBarFrame = self.searchBarController.view.frame;
    finalSearchBarFrame.origin.x -= self.view.frame.size.width;
    
    
    [self addChildViewController:pushedController];
    [self.baseController willMoveToParentViewController:nil];
    
    [pushedController beginAppearanceTransition:YES animated:YES];
    
    void (^animationBlock)(void) = ^void() {
        pushedController.view.frame = finalPushedControllerFrame;
        self.baseController.view.frame = finalBaseControllerFrame;
        self.searchBarController.view.frame = finalSearchBarFrame;
    };
    
    [self transitionFromViewController:self.baseController toViewController:pushedController duration:TRANSITION_DURATION options:UIViewAnimationOptionCurveEaseInOut animations:animationBlock completion:^(BOOL finished) {
        [self.baseController removeFromParentViewController];
        self.searchBarController.view.hidden = YES;
        [pushedController didMoveToParentViewController:self];
        [pushedController endAppearanceTransition];
    }];
    
    self.pushedController = pushedController;
}

-(void) popViewController
{
    // Animate pushedController sliding out to right. Supports portrait only.
    CGRect finalPoppedControllerFrame = self.view.frame;
    finalPoppedControllerFrame.origin.x += self.view.frame.size.width;
    
    CGRect finalBaseControllerFrame = self.view.frame;
    CGRect finalSearchBarFrame = self.searchBarController.view.frame;
    finalSearchBarFrame.origin.x += self.view.frame.size.width;
    
    self.searchBarController.view.hidden = NO;
    
    [self addChildViewController:self.baseController];
    [self.pushedController willMoveToParentViewController:nil];
    
    void (^animationBlock)(void) = ^void() {
        self.pushedController.view.frame = finalPoppedControllerFrame;
        self.baseController.view.frame = finalBaseControllerFrame;
        self.searchBarController.view.frame = finalSearchBarFrame;
    };
    
    
    [self transitionFromViewController:self.pushedController toViewController:self.baseController duration:TRANSITION_DURATION options:UIViewAnimationOptionCurveEaseInOut animations:animationBlock
        completion:^(BOOL finished) {
        [self.pushedController removeFromParentViewController];
        [self.baseController didMoveToParentViewController:self];
        self.pushedController = nil;
    }];
}


- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    [super transitionFromViewController:fromViewController toViewController:toViewController duration:duration options:options animations:animations completion:completion];
    
    // The transitionFromViewController method moves toViewController's view to the front. But we need to keep the base view controller in the back.
    if(toViewController == self.baseController) {
        [self.view sendSubviewToBack:toViewController.view];
    }
}

@end
