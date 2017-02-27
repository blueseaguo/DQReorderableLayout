//
//  ViewController.m
//  DQReorderableLayout
//
//  Created by guo on 17/2/14.
//  Copyright © 2017年 guo. All rights reserved.
//

#import "ViewController.h"
#import "DQReorderableLayout.h"
@interface ViewController ()<DQReorderableLayoutDelegate,DQReorderableLayoutDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self startUp];
}

- (void)startUp {
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:[[DQReorderableLayout alloc] init]];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    
    [self.view addSubview:self.collectionView];
    
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (BOOL)collectionView:(UICollectionView *)collectionView allowMoveAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (BOOL)collectionView:(UICollectionView * )collectionView atIndexPath:(NSIndexPath * )atIndexPath canMoveToIndexPath:(NSIndexPath * )canMoveToIndexPath
{
    return YES;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 12.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat padding = (self.view.bounds.size.width - 76.0 * 4) / 5.0;
    if (padding < 5.0) {
        padding = (self.view.bounds.size.width - 76.0 * 3) / 4.0;
    }
    return UIEdgeInsetsMake(5.0, padding, 5.0, padding);
}

- (void)collectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)atIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath {
  
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"%ld::::%ld",indexPath.section,indexPath.row];
    [label sizeToFit];
    [cell.contentView addSubview:label];
    cell.backgroundColor = [UIColor whiteColor];
    
    
    return cell;
}

- (UIEdgeInsets)scrollTrigerPaddingInCollectionView:(UICollectionView *)collectionView {
    return UIEdgeInsetsMake(collectionView.contentInset.top, 0.0, collectionView.contentInset.bottom, 0.0);
}

- (UIEdgeInsets)scrollTrigerEdgeInsetsInCollectionView:(UICollectionView *)collectionView {
    return UIEdgeInsetsMake(12, 12, 12, 12);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView reorderingItemAlphaInSection:(NSInteger)section {
    return 0.2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(76.0, 30.0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
