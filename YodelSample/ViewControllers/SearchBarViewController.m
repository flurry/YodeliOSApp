//
//  SearchBarViewController.m
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
#import <QuartzCore/QuartzCore.h>
#import <YahooSearchKit/YahooSearchKit.h>

#import "CarouselCollectionViewController.h"
#import "ContentItem.h"
#import "SearchBarViewController.h"
#import "SearchResultCell.h"
#import "TumblrFetcher.h"
#import "UIUtil.h"
#import "AnalyticsWrapper.h"

@interface SearchBarViewController () <UITableViewDataSource, UITableViewDelegate, YSLSearchViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headerBg;
@property (weak, nonatomic) IBOutlet UIImageView *resultBg;

@property (weak, nonatomic) IBOutlet UIView *searchBarView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *tableViewSeparator;
@property (weak, nonatomic) IBOutlet UIButton *moreOnWebButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeButtonTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleConstraint;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (nonatomic, assign) BOOL isSearchExpanded;
@property (nonatomic, assign) BOOL isSearchFieldOpen;

@property(nonatomic, strong) NSArray* tumblrItems;
@property(nonatomic, strong) NSMutableArray* tableData;
@property(nonatomic, strong) NSOperationQueue* downloadOperationQueue;

@end

@implementation SearchBarViewController


static const CGFloat ANIMATION_DURATION = 0.5;
static const CGFloat BACKGROUND_IMAGE_ALPHA = 1;
const CGFloat SEARCH_BAR_HEIGHT = 60;

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.searchLeadingConstraint.priority = UILayoutPriorityDefaultLow;
    self.titleConstraint.constant = (-[[UIScreen mainScreen] bounds].size.width) / 2;
    self.closeButtonTrailingConstraint.constant = -[[UIScreen mainScreen] bounds].size.width;
    
    self.tableViewSeparator.hidden = YES;
    
    self.downloadOperationQueue = [NSOperationQueue new];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchResultCell" bundle:nil] forCellReuseIdentifier:@"SearchResultCell"];
    
    self.headerBg.alpha = BACKGROUND_IMAGE_ALPHA;
    self.resultBg.alpha = 0;
    
    UIColor *color = [UIColor colorWithWhite:1 alpha:0.5];
    self.searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search for content" attributes:@{NSForegroundColorAttributeName: color}];
}

-(void)closeSearchBar
{
    self.searchLeadingConstraint.priority = UILayoutPriorityDefaultLow;
    self.titleConstraint.priority = UILayoutPriorityDefaultLow;
    self.closeButtonTrailingConstraint.constant = -[[UIScreen mainScreen] bounds].size.width;
    self.searchButton.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    self.searchButtonWidthConstraint.constant = 60;
    self.searchTextField.text = nil;
    [self.searchTextField resignFirstResponder];
    [self.view setNeedsLayout];
    
    void (^animationBlock)(void) = ^void() {
        if(self.isSearchExpanded) {
            self.tableViewHeightConstraint.priority = UILayoutPriorityDefaultHigh;
            CGRect searchBarFrame = [[UIScreen mainScreen] bounds];
            searchBarFrame.size.height = SEARCH_BAR_HEIGHT;
            self.view.frame = searchBarFrame;
            self.searchViewHeightConstraint.constant = SEARCH_BAR_HEIGHT;
            self.tableViewSeparator.hidden = YES;
            self.headerBg.alpha = BACKGROUND_IMAGE_ALPHA;
            self.resultBg.alpha = 0;
            self.tableView.alpha = 0;
            self.moreOnWebButton.alpha = 0;
            
            [self.activityIndicator stopAnimating];
            
            UIColor *color = [UIColor colorWithWhite:1.0 alpha:1.0];
            [self.searchTextField setTextColor:color];
            [self.searchButton setTintColor:color];
            [self.closeButton setTintColor:color];
        }
        
        [self.view layoutIfNeeded];
    };
    
    void (^completionBlock)(BOOL) = ^void(BOOL b) {
        // Clear out table data when finished closing
        self.tableData = [NSMutableArray new];
        self.tumblrItems = [NSArray new];
        [self.downloadOperationQueue cancelAllOperations];
        
        self.isSearchFieldOpen = NO;
        self.tableView.hidden = YES;
        self.moreOnWebButton.hidden = YES;
    };
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:animationBlock completion:completionBlock];
}

-(void) openSearchResults
{
    self.tableView.hidden = NO;
    self.tableViewSeparator.hidden = NO;
    [self.tableView reloadData];
    
    void (^animationBlock)(void) = ^void() {
        self.tableViewHeightConstraint.priority = UILayoutPriorityDefaultLow;
        self.view.frame =[[UIScreen mainScreen] bounds];
        self.searchViewHeightConstraint.constant = [[UIScreen mainScreen] bounds].size.height;
        self.headerBg.alpha = 0;
        self.resultBg.alpha = BACKGROUND_IMAGE_ALPHA;
        self.tableView.alpha = 1;
        
        UIColor *color = [UIColor colorWithWhite:(155/255.0) alpha:1.0];
        [self.searchTextField setTextColor:color];
        [self.searchButton setTintColor:color];
        [self.closeButton setTintColor:color];
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    };
    
    void (^completionBlock)(BOOL) = ^void(BOOL b) {
        self.isSearchExpanded = YES;
    };
    
    UIViewAnimationOptions options = (UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction);
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:options animations:animationBlock completion:completionBlock];
}

#pragma mark - IBAction

- (IBAction)searchButtonPressed:(id)sender
{
    if(!self.isSearchFieldOpen) {
        [AnalyticsWrapper logEvent:@"stream_search_click"];
        
        self.searchTextField.enabled = YES;
        [self.searchTextField becomeFirstResponder];
        self.searchLeadingConstraint.priority = UILayoutPriorityDefaultHigh;
        self.titleConstraint.priority = UILayoutPriorityDefaultHigh;
        self.closeButtonTrailingConstraint.constant = 0;
        self.searchButton.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 10);
        self.searchButtonWidthConstraint.constant = 50;
        [self.view setNeedsLayout];
        
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{[self.view layoutIfNeeded];} completion:^(BOOL b) {self.isSearchFieldOpen = YES;}];
    } else {
        [self closeSearchBar];
    }
}

- (IBAction)closeButtonPressed:(id)sender
{
    [self closeSearchBar];
}

- (IBAction)moreOnWebButtonPressed:(id)sender {
    [AnalyticsWrapper logEvent:@"search_moreonweb_click" withParameters:@{ @"search_term":self.searchTextField.text }];
    
    YSLSearchViewController *searchViewController = [YSLSearchViewController new];
    searchViewController.queryString = self.searchTextField.text;
    searchViewController.delegate = self;
    [self presentViewController:searchViewController animated:YES completion:nil];
    return;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // Do nothing if there is no text
    if(textField.text.length == 0) {
        return NO;
    }
    
    [AnalyticsWrapper logEvent:@"search_term_started" withParameters:@{ @"search_term":textField.text }];
    
    // Open the search results
    [self openSearchResults];
    [self.activityIndicator startAnimating];
    self.tumblrItems = [NSArray new];
    self.tableData = [NSMutableArray new];
    [self.tableView reloadData];
    self.searchTextField.enabled = NO;
    [textField resignFirstResponder];
    
    [[TumblrFetcher sharedInstance] searchTags:textField.text limit:5 callback:^(NSArray *tumblrItems, NSArray *imageDownloadOperations, NSError *error) {
        
        // Display no results until all images are downloaded.
        NSOperation *finishedOperation = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                self.searchTextField.enabled = YES;
                
                if(!error) {
                    if(tumblrItems == nil || tumblrItems.count == 0) {
                        [self.tableData addObject:@"no results"];
                    } else {
                        self.tumblrItems = tumblrItems;
                        self.tableData = [NSMutableArray arrayWithArray:tumblrItems];
                    }
                    
                    
                    self.moreOnWebButton.hidden = NO;
                    self.moreOnWebButton.alpha = 1;
                    [self.activityIndicator stopAnimating];
                } else {
                    [self.activityIndicator stopAnimating];
                    [self.tableData addObject:@"network error"];
                    self.moreOnWebButton.hidden = YES;
                }
                
                
                [self.tableView reloadData];
            });
        }];
        
        for(id op in imageDownloadOperations) {
            [finishedOperation addDependency:op];
        }
        
        [self.downloadOperationQueue addOperations:imageDownloadOperations waitUntilFinished:NO];
        [self.downloadOperationQueue addOperation:finishedOperation];
    }];
    
    return NO;
}


#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id rowObject = [self.tableData objectAtIndex:indexPath.row];
    
    if([rowObject isKindOfClass:[ContentItem class]]) {
        return SEARCH_RESULT_CELL_HEIGHT;
    } else if([rowObject isKindOfClass:[NSString class]]){
        return TEXT_CELL_HEIGHT;
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id rowObject = [self.tableData objectAtIndex:indexPath.row];
    
    if([rowObject isKindOfClass:[ContentItem class]]) {
        
        NSString *cellType = @"SearchResultCell";
        SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];
        [cell setupWithContentItem:[self.tableData objectAtIndex:indexPath.row]];
        return cell;
        
    } else if([rowObject isKindOfClass:[NSString class]]){
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TEXT_CELL_IDENTIFIER];
        if(cell == nil) {
            cell = [UIUtil textTableCell];
            
            [cell setTranslatesAutoresizingMaskIntoConstraints:NO];
            [cell.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        }
        
        cell.textLabel.text = rowObject;
        return cell;
        
    } else {
        // Not supported
        return nil;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id rowObject = [self.tableData objectAtIndex:indexPath.row];
    
    if(![rowObject isKindOfClass:[ContentItem class]]) {
        return;
    }
    
    ContentItem *item = (ContentItem*)rowObject;
    [AnalyticsWrapper logEvent:@"search_result_click"  withContentItem:item];
    
    // Open the carousel view controller at the same position of selected row.
    CarouselCollectionViewController *carouselController = [[CarouselCollectionViewController alloc] init];
    carouselController.tumblrItems = self.tumblrItems;
    carouselController.currentItem = item;
    carouselController.delegate = self;
    
    [self.containerController pushViewController:carouselController];
}

#pragma  mark - CarouselCollectionViewDelegate

- (void) controllerShouldDismiss:(UIViewController *) viewController
{
    [self.containerController popViewController];
}

#pragma mark - YSLSearchViewControllerDelegate

- (void)searchViewControllerDidTapLeftButton:(YSLSearchViewController*)searchViewController
{
    [searchViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
