//
//  CarouselCell.m
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
#import "CarouselCell.h"
#import "UIUtil.h"
#import "Util.h"

@interface CarouselCell ()


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIView *titleSeparatorLine;
@property (weak, nonatomic) IBOutlet UILabel *headline;
@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UILabel *hashTags;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoText;
@property (weak, nonatomic) IBOutlet UIImageView *starburstImage;
@property (weak, nonatomic) IBOutlet UILabel *callToAction;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeAgoTextConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hashTagsConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *learnMoreConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headlineConstraint;

@property (strong, nonatomic) NSString *learnMoreText;

@property (weak, nonatomic) IBOutlet UIButton *learnMoreButton;
@property (weak, nonatomic) IBOutlet UIButton *galleryButton;
@property (weak, nonatomic) IBOutlet UIImageView *galleryButtonImage;

@property (nonatomic, retain) ContentItem *contentItem;


@end

static NSString* const LEARN_MORE_STRING = @"Learn More:";

@implementation CarouselCell

-(void) awakeFromNib
{
    // Scale the button image correctly using Insets
    self.learnMoreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.learnMoreButton.imageEdgeInsets = UIEdgeInsetsMake(0, -11, 0, 0);
    self.learnMoreButton.titleEdgeInsets = UIEdgeInsetsMake(0, -22 + 7.5, 0, 0);
    
    self.callToAction.layer.borderColor = self.callToAction.textColor.CGColor;
    self.callToAction.layer.borderWidth = 1.5;
    self.callToAction.layer.cornerRadius = 4;
}

- (void)prepareForReuse
{
    if(self.contentItem.ad) {
        [self.contentItem.ad removeTrackingView];
    }
}

- (void)updateConstraints {
    // Constrain the image to a specific aspect ratio.
    if(self.imageView.image != nil) {
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        self.imageHeightConstraint.constant = screenWidth / IMAGE_ASPECT_RATIO;
    }
    
    // Disable constraints on images / labels if they are not present
    if(self.hashTags.text == nil) {
        self.hashTagsConstraint.constant = 0;
    } else {
        self.hashTagsConstraint.constant = 20;
    }
    
    if(self.learnMoreButton.hidden == YES) {
        self.learnMoreConstraint.constant = 0;
    } else {
        self.learnMoreConstraint.constant = 28;
    }
    
    if(self.headline.text == nil) {
        self.headlineConstraint.constant = 0;
    } else {
        self.headlineConstraint.constant = 28;
    }
    
    if(self.starburstImage.hidden == YES) {
        self.timeAgoTextConstraint.priority = UILayoutPriorityDefaultLow;
    } else {
        self.timeAgoTextConstraint.priority = UILayoutPriorityDefaultHigh;
    }
    
    [super updateConstraints];
}

- (void) setupWithContentItem:(ContentItem*)item;
{
    // When preparing for reuse, we should move the scrollview back to top. But we shouldn't bump the scroll view if the cell is being used for the same item
    if(item != self.contentItem) {
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
    
    self.contentItem = item;
    
    // Ads have slightly different content in the View than a Tumblr Post. We could also have a compeltely different cell for the Ad Items.
    if([item isAd]) {
        item.ad.trackingView = self;
        
        self.starburstImage.hidden = NO;
        self.callToAction.hidden = NO;
        self.galleryButton.hidden = YES;
        self.galleryButtonImage.hidden = YES;
        self.timeAgoText.text = @"Sponsored";
        self.title.textColor = [UIUtil colorForSponsoredContent];
        self.titleSeparatorLine.backgroundColor = [UIUtil colorForSponsoredContent];
    } else {
        self.starburstImage.hidden = YES;
        self.callToAction.hidden = YES;
        self.galleryButton.hidden = NO;
        self.galleryButtonImage.hidden = NO;
        self.timeAgoText.text = [Util timeAgoStringFromDate:item.date];
        self.title.textColor = [UIUtil colorForTumblrContent];
        self.titleSeparatorLine.backgroundColor = [UIUtil colorForTumblrContent];
    }
    
    self.imageView.image = [item displayImage];
    self.title.text = item.source;
    
    if(item.caption) {
        self.caption.attributedText = [[NSAttributedString alloc] initWithString:item.caption attributes:[UIUtil attributesForCaptionText]];
    }
    if(item.headline) {
        self.headline.attributedText = [[NSAttributedString alloc] initWithString:item.headline attributes:[UIUtil attributesForHeadlineText]];
    } else {
        self.headline.text = nil;
    }
    
    self.hashTags.attributedText = nil;
    self.learnMoreText = nil;
    self.learnMoreButton.hidden = YES;
    
    // Process tags into readable format using # symbol
    if([item.tags count] > 0) {
        NSMutableString *tagsString = [[NSMutableString alloc] init];
        for(NSString* tag in item.tags) {
            [tagsString appendString:@"#"];
            [tagsString appendString:tag];
            [tagsString appendString:@" "];
        }
        
        self.learnMoreText = [item.tags objectAtIndex:0];
        self.hashTags.attributedText = [[NSAttributedString alloc] initWithString:tagsString attributes:[UIUtil attributesForCaptionText]];
    }
    
    // Set up the "Learn More" button.
    if(self.learnMoreText && self.showLearnMoreButton) {
        NSString *buttonString = [NSString stringWithFormat:@"%@ %@", LEARN_MORE_STRING, self.learnMoreText];
        NSRange boldedRange = NSMakeRange(0, LEARN_MORE_STRING.length);
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:buttonString];
        UIFont* boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0];
        
        [attributedString beginEditing];
        [attributedString addAttribute:NSFontAttributeName value:boldFont range:boldedRange];
        [attributedString endEditing];
        
        [self.learnMoreButton setAttributedTitle:attributedString forState:UIControlStateNormal];
        self.learnMoreButton.hidden = NO;
    }
    
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (IBAction)backButtonPressed:(id)sender
{
    if(self.delegate) {
        [self.delegate backButtonPressed];
    }
}

- (IBAction)learnMoreButtonPressed:(id)sender
{
    if(self.delegate) {
        [self.delegate learnMoreButtonPressed:self.learnMoreText];
    }
}

- (IBAction)imageButtonPressed:(id)sender
{
    if(self.delegate) {
        [self.delegate imageButtonPressed];
    }
}

@end