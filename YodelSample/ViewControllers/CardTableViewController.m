//
//  CardTableViewController.m
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

#import "AnalyticsWrapper.h"
#import "CardCell.h"
#import "CardTableViewController.h"
#import "Util.h"
#import "CarouselCollectionViewController.h"
#import "AdManager.h"
#import "TumblrManager.h"
#import "UIUtil.h"

@interface CardTableViewController () <FlurryAdNativeDelegate, CarouselCollectionViewDelegate, AdManagerDelegate, TumblrManagerDelegate, FlurryAdNativeDelegate>

@property(nonatomic, strong) NSMutableArray *adItems;
@property(nonatomic, strong) NSMutableArray *rowObjects;

@property(nonatomic, strong) CarouselCollectionViewController *carouselController;

@end

@implementation CardTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self)
    {
        self.rowObjects = [NSMutableArray array];
        self.adItems = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CardCell" bundle:nil] forCellReuseIdentifier:@"CardCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Add a margin before the first cell
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top += CARD_CELL_MARGIN;
    [self.tableView setContentInset:inset];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.refreshControl beginRefreshing];
    
    self.tableView.backgroundColor = [UIUtil colorForTableBackground];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadContent];
    [AdManager sharedInstance].delegate = self;
    [TumblrManager sharedInstance].delegate = self;
}

- (void) refresh
{
    [AnalyticsWrapper logEvent:@"stream_pullto_refresh"];
    
    self.adItems = [NSMutableArray array];
    self.rowObjects = [NSMutableArray array];
    [[TumblrManager sharedInstance] refreshContent];
    [self reloadContent];
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
    
    NSArray* tumblrItems = [[TumblrManager sharedInstance] tumblrItems];
    [self getAdsIfNeeded];
    
    if(tumblrItems.count > 0 && [self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
    
    [self.rowObjects removeAllObjects];
    
    NSUInteger postCount = tumblrItems.count;
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
            [self.rowObjects addObject:[tumblrItems objectAtIndex:tumblrIndex]];
        }
    }
    
    [self.tableView reloadData];
}

-(void) getAdsIfNeeded
{
    NSArray* tumblrItems = [[TumblrManager sharedInstance] tumblrItems];
    NSUInteger numAdditionalAdsNeeded = MAX([Util numAdsRequiredForContentAmount:tumblrItems.count] - self.adItems.count , 0);
    for (int i=0; i < numAdditionalAdsNeeded; i++) {
        FlurryAdNative* ad = [[AdManager sharedInstance] getAdIfAvailableForViewController:self];
        
        if(ad) {
            // Setting this class as the delegate will make this class handle all impression, clicked, etc.
            // delegate events for this ad.  The request, fetch and error still belong to the AdManager.
            ad.adDelegate = self;
        
            // We want to set up the ContentItem with the ad immediately, so we can make sure assets are always in memory
            ContentItem *adItem = [[ContentItem new] initWithAd:ad];
            [self.adItems addObject:adItem];
        }
    }
}

#pragma mark - AdManagerDelegate

- (void)adIsAvailable:(AdManager *)manager
{
    [self reloadContent];
}

#pragma mark - TumblrManagerDelegate

- (void)tumblrContentUpdated:(TumblrManager *)manager
{
    [self reloadContent];
    
    // If the carousel Controller is being presented, lets update its content.
    if(self.carouselController) {
        self.carouselController.needsReloadContent = YES;
    }
}

- (void)tumblrContaintDidFailToFetch:(NSError *)error
{
    // This method changes the tableview data, so can only be run on main thread
    if(![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self tumblrContaintDidFailToFetch:error];
        });
        
        return;
    }
    
    [self.refreshControl endRefreshing];
    [self.rowObjects removeAllObjects];
    [self.rowObjects addObject:@"network error"];
    
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rowObjects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Use a static cell which will use autolayout to determine the height
    static CardCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSString *cellType = @"CardCell";
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:cellType];
    });
    
    id rowObject = [self.rowObjects objectAtIndex:indexPath.row];
    
    if([rowObject isKindOfClass:[ContentItem class]]) {
        //[sizingCell setupWithContentItem:(ContentItem*) rowObject];
        [sizingCell setupWithContentItem:(ContentItem*) rowObject forSizing:YES];
        //return 423 + CARD_CELL_MARGIN;
    } else if([rowObject isKindOfClass:[NSString class]]){
        return TEXT_CELL_HEIGHT;
    } else {
        return 0;
    }
    
    [sizingCell setNeedsUpdateConstraints];
    [sizingCell updateConstraintsIfNeeded];
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return roundf(size.height + CARD_CELL_MARGIN);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellType = @"CardCell";
    CardCell *cardCell = [tableView dequeueReusableCellWithIdentifier:cellType];
    
    id rowObject = [self.rowObjects objectAtIndex:indexPath.row];
    
    if([rowObject isKindOfClass:[ContentItem class]]) {
        ContentItem *item = (ContentItem*) rowObject;
        
        [cardCell setupWithContentItem:(ContentItem*) item];
        
        // If this is an ad, set the trackingView to the card cell. TrackingView is removed in cells prepareForReuse method.
        // We could also set trackingView in setupWithContentItem, but we would need to make sure not to set it when used with sizingCell in heightForRowAtIndexPath
        if([item isAd]) {
            item.ad.trackingView = cardCell;
            
        }
        
    } else if([rowObject isKindOfClass:[NSString class]]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TEXT_CELL_IDENTIFIER];
        if(cell == nil) {
            cell = [UIUtil textTableCell];
        }
        cell.textLabel.text = ((NSString*)rowObject);
        
        return cell;
    } else {
        cardCell.hidden = YES;
    }
    
    return cardCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id rowObject = [self.rowObjects objectAtIndex:indexPath.row];
    if(![rowObject isKindOfClass:[ContentItem class]] || [rowObject isAd]) {
        return;
    }
    
    ContentItem *item = (ContentItem*) rowObject;
    [AnalyticsWrapper logEvent:@"stream_article_click"  withContentItem:item];
    
    // Open the carousel view controller at the same position of selected row.
    CarouselCollectionViewController *carouselController = [[CarouselCollectionViewController alloc] init];
    carouselController.delegate = self;
    carouselController.showLeanMore = YES;
    carouselController.tumblrItems = [[TumblrManager sharedInstance] tumblrItems]; // Use shared tumblr items that can be updated
    carouselController.currentItem = item;
    self.carouselController = carouselController;
    [self.containerController pushViewController:carouselController];
}

#pragma mark - CarouselCollectionViewDelegate

- (void) controllerShouldDismiss:(UIViewController *) viewController
{
    [self.containerController popViewController];
    self.carouselController = nil;
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
        }
    }
    
    [AnalyticsWrapper logEvent:@"stream_ad_click" withParameters:@{@"ad_placement":adPosition}];
}

- (void) adNativeDidLogImpression:(FlurryAdNative *)nativeAd
{
    NSString* adType = @"native";
    if([nativeAd isVideoAd])
    {
        adType = @"nativeVideo";
    }
    [AnalyticsWrapper logEvent:@"stream_ad_displayed" withParameters:@{@"ad_space":nativeAd.space,
                                                                @"type":adType,
                                                                @"model":[Util getDeviceModel],
                                                                @"network":@"Flurry"}];
    
}

- (void) adNativeDidReceiveClick:(FlurryAdNative *)nativeAd
{
    NSString* adType = @"native";
    if([nativeAd isVideoAd])
    {
        adType = @"nativeVideo";
    }
    
    // Find the position of this ad, so we can track which ad positions are favorable
    NSString *adPosition = @"Unknown";
    for(int i=0; i<self.rowObjects.count; i++) {
        ContentItem *item = [self.rowObjects objectAtIndex:i];
        if(item.ad == nativeAd) {
            adPosition = [@(i) stringValue];
        }
    }
    
    [AnalyticsWrapper logEvent:@"ad_clicked" withParameters:@{@"ad_space":nativeAd.space,
                                                              @"model":[Util getDeviceModel],
                                                              @"network":@"Flurry",
                                                              @"type":adType,
                                                              @"ad_placement":adPosition}];
}


@end
