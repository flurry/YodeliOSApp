//
//  CardCell.m
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

#import <QuartzCore/QuartzCore.h>
#import "CardCell.h"
#import "UIUtil.h"
#import "Util.h"

@interface CardCell ()

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *headline;
@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoText;

@property (weak, nonatomic) IBOutlet UILabel *callToAction;
@property (weak, nonatomic) IBOutlet UIImageView *starburstImage;
@property (weak, nonatomic) IBOutlet UIImageView *blogImage;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headlineConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *reblogImage;
@property (weak, nonatomic) IBOutlet UIImageView *likeImage;

@property (strong, nonatomic) ContentItem *contentItem;

@end

const float CARD_CELL_MARGIN = 12;

@implementation CardCell


-(void) awakeFromNib
{
    // Define things which cannot be neatly defined in interface builder.
    self.callToAction.layer.borderColor = self.callToAction.textColor.CGColor;
    self.callToAction.layer.borderWidth = 1.5;
    self.callToAction.layer.cornerRadius = 4;
    
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 0.1;
    self.layer.shadowOffset = CGSizeMake(2.5, 2.5);
    self.layer.shadowRadius = 3;
    
    // Rasterize for a performance boost, especially on simulator
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

-(void)prepareForReuse
{
    if(self.contentItem.ad) {
        [self.contentItem.ad removeTrackingView];
    }
}

-(void)setFrame:(CGRect)frame {
    // Add margins around the table cell.
    frame.origin.x += CARD_CELL_MARGIN;
    frame.size.width -= 2 * CARD_CELL_MARGIN;
    frame.size.height -= CARD_CELL_MARGIN;
    
    [super setFrame:frame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
     
    // We must set preferredMaxLayoutWidth so that systemLayoutSizeFittingSize takes into account text wrap.
    // This way, we can use autolayout to calculate the cell height, rather than doing it manually.
    self.title.preferredMaxLayoutWidth = self.title.frame.size.width;
    self.headline.preferredMaxLayoutWidth = self.headline.frame.size.width;
    self.caption.preferredMaxLayoutWidth = self.caption.frame.size.width;
    self.timeAgoText.preferredMaxLayoutWidth = self.timeAgoText.frame.size.width;
}


- (void)updateConstraints {
    // If the headline is not present, remove its spacing constraint
    if(self.headline.text == nil) {
        self.headlineConstraint.constant = 0;
    } else {
        self.headlineConstraint.constant = 12;
    }
    
    // Adjust the image height in Auto Layout
    if(self.blogImage.image != nil) {
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat cardFrameWidth = screenWidth - 2 * CARD_CELL_MARGIN;
        
        // Ads should preserve their original aspect ratio, while other images will be scaled and cropped to a fixed aspect ratio
        if([self.contentItem isAd]) {
            self.imageHeightConstraint.constant = (self.blogImage.image.size.height * (cardFrameWidth / self.blogImage.image.size.width));
        } else {
            self.imageHeightConstraint.constant = cardFrameWidth / IMAGE_ASPECT_RATIO;
        }
    }
    
    [super updateConstraints];
}

- (void) setupWithContentItem:(ContentItem*)item;
{
    self.contentItem = item;
    
    // Ads have slightly different content in the View than a Tumblr Post. We could also have a compeltely different cell for the Ad Items.
    if([item isAd]) {
        self.timeAgoText.text = @"Sponsored";
        self.reblogImage.hidden = YES;
        self.likeImage.hidden = YES;
        self.starburstImage.hidden = NO;
        self.callToAction.hidden = NO;
        self.title.textColor = [UIUtil colorForSponsoredContent];
    } else {
        self.timeAgoText.text = [Util timeAgoStringFromDate:item.date];
        self.reblogImage.hidden = NO;
        self.likeImage.hidden = NO;
        self.starburstImage.hidden = YES;
        self.callToAction.hidden = YES;
        self.title.textColor = [UIUtil colorForTumblrContent];
    }
    
    self.title.text = item.source;
    self.blogImage.image = [item displayImage];
    
    if(item.headline) {
        self.headline.attributedText = [[NSAttributedString alloc] initWithString:item.headline attributes:[UIUtil attributesForHeadlineText]];
    } else {
        self.headline.attributedText = nil;
    }

    if(item.caption) {
        self.caption.attributedText = [[NSAttributedString alloc] initWithString:item.caption attributes:[UIUtil attributesForCaptionText]];
    } else {
        self.caption.attributedText = nil;
    }
    
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

@end
