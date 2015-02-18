//
//  CarouselCollectionViewController.m
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

#import <YahooSearchKit/YahooSearchKit.h>
#import "AdManager.h"
#import "AnalyticsWrapper.h"
#import "CarouselCollectionViewController.h"
#import "CarouselCell.h"
#import "ImageCarouselViewController.h"
#import "UIUtil.h"
#import "Util.h"

@interface CarouselCollectionViewController () <CarouselCellDelegate,YSLSearchViewControllerDelegate,ImageCarouselViewControllerDelegate, AdManagerDelegate, FlurryAdNativeDelegate>

@property(nonatomic, strong) NSMutableArray *adItems;
@property(nonatomic, strong) NSMutableArray *rowObjects;

@end

@implementation CarouselCollectionViewController

-(id) init
{
    self = [super initWithCollectionViewLayout:[UIUtil defaultCollectionViewLayout]];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.adItems = [[NSMutableArray alloc] init];
    self.rowObjects = [[NSMutableArray alloc] init];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CarouselCell" bundle:nil] forCellWithReuseIdentifier:@"CarouselCell"];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    
    [self reloadContent];
    [AdManager sharedInstance].delegate = self;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Keep track of the indexPath for the current visible cell
    CGRect visibleRect = (CGRect){.origin = self.collectionView.contentOffset, .size = self.collectionView.bounds.size};
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    NSIndexPath *visibleIndexPath = [self.collectionView indexPathForItemAtPoint:visiblePoint];
    self.currentItem = [self.rowObjects objectAtIndex:visibleIndexPath.row];
    
    // Reload content if needed. We do it here because we don't want to reload content in the middle of scrolling
    if(self.needsReloadContent) {
        [self performSelector:@selector(reloadContent) withObject:nil afterDelay:0.0]; // Do reloadContent on next runloop cycle, not current one
    }
}

- (void)adIsAvailable:(AdManager*)manager
{
    self.needsReloadContent = YES;
}

-(void) getAdsIfNeeded
{
    NSUInteger numAdditionalAdsNeeded = MAX([Util numAdsRequiredForContentAmount:self.tumblrItems.count] - self.adItems.count , 0);
    for (int i=0; i < numAdditionalAdsNeeded; i++) {
        // We want to set up the ContentItem with the ad immediately, so we can make sure assets are always in memory
        FlurryAdNative* ad = [[AdManager sharedInstance] getAdIfAvailableForViewController:self];
        
        if(ad) {
            ad.adDelegate = self;
            
            // We want to set up the ContentItem with the ad immediately, so we can make sure assets are always in memory
            ContentItem *adItem = [[ContentItem new] initWithAd:ad];
            [self.adItems addObject:adItem];
        }
    }
}

- (void) reloadContent
{
    // This method changes the tableview data, so can only be run on main thread
    if(![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadContent];
        });
        
        return;
    }
    
    /*
      self.rowObjects contains the objects used to populate the table. This method
      recreates rowObjects by mixing tumblrItems with adItems. Objects are
      copied from both arrays into rowObjects.
    */
    
    [self getAdsIfNeeded];
    [self.rowObjects removeAllObjects];

    NSUInteger postCount = self.tumblrItems.count;
    NSUInteger adsRequired = [Util numAdsRequiredForContentAmount:postCount];
    NSUInteger adsToShowCount = MIN(adsRequired, self.adItems.count);
    
    NSUInteger totalRows =  postCount + adsToShowCount;
    NSUInteger numAdsInserted = 0;
    
    for(NSUInteger i=0; i<totalRows; i++) {
        if([Util isAdIndex:i] && numAdsInserted < self.adItems.count) {
            [self.rowObjects addObject:[self.adItems objectAtIndex:numAdsInserted]];
            numAdsInserted++;
        } else {
            NSUInteger tumblrIndex = i - numAdsInserted;
            [self.rowObjects addObject:[self.tumblrItems objectAtIndex:tumblrIndex]];
        }
    }
    
    // Avoid moving the screen that the user is on by calculating the new index of the item the user was originally on.
    NSIndexPath* newIndex = [self indexPathFromItem:self.currentItem];
    [UIView setAnimationsEnabled:NO];
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:newIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [UIView setAnimationsEnabled:YES];
    
    self.needsReloadContent = NO;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.rowObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellType = @"CarouselCell";
    CarouselCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellType forIndexPath:indexPath];
    cell.delegate = self;
    
    id rowObject = [self.rowObjects objectAtIndex:indexPath.row];
    
    if([rowObject isKindOfClass:[ContentItem class]]) {
        cell.showLearnMoreButton = self.showLeanMore;
        [cell setupWithContentItem:(ContentItem*) rowObject];
    } else {
        cell.hidden = YES;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.bounds.size;
}

#pragma mark - CarouselCellDelegate

- (void) backButtonPressed
{
    ContentItem *item = self.currentItem;
    [AnalyticsWrapper logEvent:@"carousel_back_click" withContentItem:item];
    
    if(self.delegate) {
        [self.delegate controllerShouldDismiss:self];
    }
}


- (void) learnMoreButtonPressed:(NSString *)learnMoreText
{
    ContentItem *item = self.currentItem;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{@"search_term":learnMoreText}];
    [AnalyticsWrapper logEvent:@"carousel_learnmore_click" withParameters:params andContentItem:item];
    
    YSLSearchViewController *searchViewController = [YSLSearchViewController new];
    searchViewController.queryString = learnMoreText;
    searchViewController.delegate = self;
    [self presentViewController:searchViewController animated:YES completion:nil];
}

-(void)imageButtonPressed
{
    id rowObject = self.currentItem;
    if(![rowObject isKindOfClass:[ContentItem class]]) {
        return;
    }
    
    ContentItem *item = self.currentItem;
    [AnalyticsWrapper logEvent:@"carousel_moreimages_click" withContentItem:item];
    
    ImageCarouselViewController *imageCarousel = [[ImageCarouselViewController alloc] initWithImages:item.images];
    imageCarousel.delegate = self;
    
    [self presentViewController:imageCarousel animated:NO completion:nil];
}


#pragma mark - ImageCarouselViewControllerDelegate

- (void) controllerShouldDismiss:(UIViewController *) viewController
{
    [viewController dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - YSLSearchViewControllerDelegate

- (void)searchViewControllerDidTapLeftButton:(YSLSearchViewController*)searchViewController
{
    [searchViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FlurryAdNativeDelegate

- (void) adNativeWillPresent:(FlurryAdNative*) nativeAd;
{
    // Find the position of this ad, so we can track which ad positions are favorable
    NSString *adPosition = @"Unknown";
    for(int i=0; i<self.rowObjects.count; i++) {
        ContentItem *item = [self.rowObjects objectAtIndex:i];
        if(item.ad == nativeAd) {
            adPosition = [@(i) stringValue];
            break;
        }
    }
    
    [AnalyticsWrapper logEvent:@"carousel_ad_click" withParameters:@{@"ad_placement":adPosition}];
}

#pragma mark - Helper Routines

-(NSIndexPath*) indexPathFromItem:(id)item
{
    NSUInteger objectIndex = [self.rowObjects indexOfObject:self.currentItem];
    
    // Default to first item, if item does not exist in collection
    if(objectIndex == NSNotFound) {
        objectIndex = 0;
    }
    
    return [NSIndexPath indexPathForItem:objectIndex inSection:0];
}

@end
