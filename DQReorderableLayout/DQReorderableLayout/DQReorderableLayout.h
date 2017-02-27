//
//  RAReorderableLayout.h
//  DongQiuDi
//
//  Created by guo on 17/2/8.
//  Copyright © 2015年 ballpure.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DQReorderableLayout;
@protocol DQReorderableLayoutDataSource <UICollectionViewDataSource>
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
@optional
- (CGFloat)collectionView:(UICollectionView * )collectionView reorderingItemAlphaInSection:(NSInteger)section;
- (UIEdgeInsets)scrollTrigerEdgeInsetsInCollectionView:(UICollectionView * )collectionView;
- (UIEdgeInsets)scrollTrigerPaddingInCollectionView:(UICollectionView * )collectionView;
- (CGFloat)scrollSpeedValueInCollectionView:(UICollectionView * )collectionView;
@end


@protocol DQReorderableLayoutDelegate <UICollectionViewDelegateFlowLayout>
@optional
- (void)collectionView:(UICollectionView * )collectionView atIndexPath:(NSIndexPath * )atIndexPath willMoveToIndexPath:(NSIndexPath * )toIndexPath;
- (void)collectionView:(UICollectionView * )collectionView atIndexPath:(NSIndexPath * )atIndexPath didMoveToIndexPath:(NSIndexPath * )toIndexPath;
- (BOOL)collectionView:(UICollectionView * )collectionView allowMoveAtIndexPath:(NSIndexPath * )indexPath;
- (BOOL)collectionView:(UICollectionView * )collectionView atIndexPath:(NSIndexPath * )atIndexPath canMoveToIndexPath:(NSIndexPath * )canMoveToIndexPath;
- (void)collectionView:(UICollectionView * )collectionView collectionViewLayout:(DQReorderableLayout * )layout willBeginDraggingItemAtIndexPath:(NSIndexPath * )indexPath;
- (void)collectionView:(UICollectionView * )collectionView collectionViewLayout:(DQReorderableLayout * )layout didBeginDraggingItemAtIndexPath:(NSIndexPath * )indexPath;
- (void)collectionView:(UICollectionView * )collectionView collectionViewLayout:(DQReorderableLayout * )layout willEndDraggingItemToIndexPath:(NSIndexPath * )indexPath;
- (void)collectionView:(UICollectionView * )collectionView collectionViewLayout:(DQReorderableLayout * )layout didEndDraggingItemToIndexPath:(NSIndexPath *)indexPath;
@end

@interface DQReorderableLayout : UICollectionViewFlowLayout

@end
