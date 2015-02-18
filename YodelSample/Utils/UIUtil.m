//
//  UIUtil.m
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
#import "UIUtil.h"
#import "Util.h"

const CGFloat IMAGE_ASPECT_RATIO = 1.5;
NSString *const TEXT_CELL_IDENTIFIER = @"textCellID";
const CGFloat TEXT_CELL_HEIGHT = 50;

@implementation UIUtil


+(UICollectionViewFlowLayout*)defaultCollectionViewLayout
{
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    return flowLayout;
}

+(UIColor*)colorForSponsoredContent
{
    return [Util colorFromHexString:@"#93004F"];
}

+(UIColor*)colorForTumblrContent
{
    return [Util colorFromHexString:@"#0D9AF8"];
}

+(UIColor*)colorForTableBackground
{
    return [Util colorFromHexString:@"#EDEDF1"];
}

+(NSDictionary*)attributesForCaptionText
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;
    paragraphStyle.lineBreakMode = 4;
    paragraphStyle.alignment = 0;
    
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys: paragraphStyle, NSParagraphStyleAttributeName, nil];
    
    return attributes;
}

+(NSDictionary*)attributesForHeadlineText
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;
    paragraphStyle.lineBreakMode = 4;
    paragraphStyle.alignment = 0;
    
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys: paragraphStyle, NSParagraphStyleAttributeName, nil];
    
    return attributes;
}

+(UITableViewCell*)textTableCell; {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TEXT_CELL_IDENTIFIER];

    UIColor *color = [UIColor colorWithWhite:(155/255.0) alpha:1.0];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:22.0];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = color;
    cell.textLabel.font = font;
    
    return cell;
}

@end