//
//  ImageCarouselViewController.m
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
#import "ImageCarouselViewController.h"
#import "ImageCarouselCell.h"

@interface ImageCarouselViewController () <ImageCarouselCellDelegate>
@property(nonatomic, strong) NSArray* images;
@end

@implementation ImageCarouselViewController

-(instancetype) initWithImages:(NSArray *)images
{
    self = [super initWithCollectionViewLayout:[UIUtil defaultCollectionViewLayout]];
    if(self) {
        self.images = images;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ImageCarouselCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCarouselCell"];
    
    self.collectionView.pagingEnabled = YES;
    self.collectionView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellType = @"ImageCarouselCell";
    ImageCarouselCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellType forIndexPath:indexPath];

    UIImage* image = [self.images objectAtIndex:indexPath.row];
    
    
    [cell setupWithImage:image number:(indexPath.row+1) outOf:self.images.count];
    cell.delegate = self;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.bounds.size;
}

#pragma mark - ImageCarouselViewControllerDelegate

- (void) closeButtonPressed
{
    if(self.delegate) {
        [self.delegate controllerShouldDismiss:self];
    }
}


@end