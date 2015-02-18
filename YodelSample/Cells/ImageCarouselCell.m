//
//  ImageCarouselCell.m
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
#import "ImageCarouselCell.h"

@interface ImageCarouselCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *captionText;
@property (weak, nonatomic) IBOutlet UILabel *imageNumberText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;

@end

@implementation ImageCarouselCell

-(void) setupWithImage:(UIImage*)image number:(NSUInteger)num outOf:(NSUInteger)total
{
    self.imageView.image = image;
    
    [self needsUpdateConstraints];
    
    self.captionText.hidden = YES;
    self.imageNumberText.text = [NSString stringWithFormat:@"%lu of %lu", (unsigned long) num, (unsigned long) total];
    

}
- (IBAction)closeButtonPressed:(id)sender {
    [self.delegate closeButtonPressed];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    
    // Maintain aspect ratio of image using a configurable height constraint
    if(self.imageView.image != nil) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        self.imageHeightConstraint.constant = self.imageView.image.size.height * (screenWidth / self.imageView.image.size.width);
    }
}

@end
