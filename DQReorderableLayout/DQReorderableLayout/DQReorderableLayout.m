//
//  RAReorderableLayout.m
//  DongQiuDi
//
//  Created by guo on 17/2/8.
//  Copyright © 2015年 ballpure.com. All rights reserved.
//


#import "DQReorderableLayout.h"
#import "DQCellFakeView.h"
typedef NS_ENUM(NSInteger, DQDirection) {
    toTop = 0,
    toEnd,
    stay,
};

@interface DQReorderableLayout ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) DQDirection continuousScrollDirection;
@property (nonatomic, strong) DQCellFakeView *cellFakeView;
@property (nonatomic, assign) CGPoint panTranslation;
@property (nonatomic, assign) CGPoint fakeCellCenter;

@property (nonatomic) UIEdgeInsets trigerInsets;
@property (nonatomic) UIEdgeInsets trigerPadding;
@property (nonatomic) CGFloat scrollSpeedValue;
@property (nonatomic, weak) id<DQReorderableLayoutDelegate> delegate;
@property (nonatomic, weak) id<DQReorderableLayoutDataSource> dataSource;
@end

@implementation DQReorderableLayout

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"collectionView"];
}
- (instancetype)init
{
    if (self = [super init]) {
        _continuousScrollDirection = stay;
        _trigerInsets = UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0);
        _trigerPadding = UIEdgeInsetsZero;
        _scrollSpeedValue = 10.0;

        [self configureObserver];
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    self.delegate = (id<DQReorderableLayoutDelegate>) self.collectionView.delegate;
    self.dataSource = (id<DQReorderableLayoutDataSource>) self.collectionView.dataSource;
    if ([self.dataSource respondsToSelector:@selector(scrollTrigerEdgeInsetsInCollectionView:)]) {
        _trigerInsets = [self.dataSource scrollTrigerEdgeInsetsInCollectionView:self.collectionView];
    }
    if ([self.dataSource respondsToSelector:@selector(scrollTrigerPaddingInCollectionView:)]) {
        _trigerPadding = [self.dataSource scrollTrigerPaddingInCollectionView:self.collectionView];
    }
    if ([self.dataSource respondsToSelector:@selector(scrollSpeedValueInCollectionView:)]) {
        _scrollSpeedValue = [self.dataSource scrollSpeedValueInCollectionView:self.collectionView];
    }
}
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributesArray = [super layoutAttributesForElementsInRect:rect];
    [attributesArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attributes, NSUInteger idx, BOOL * _Nonnull stop) {
        if (attributes.representedElementCategory == UICollectionElementCategoryCell&&[attributes.indexPath isEqual:_cellFakeView.indexPath]) {
            //???比较有可能不对
            if ([self.dataSource respondsToSelector:@selector(collectionView:reorderingItemAlphaInSection:)]) {
                attributes.alpha = [self.dataSource collectionView:self.collectionView reorderingItemAlphaInSection:attributes.indexPath.section];
            }else{
                attributes.alpha = 0;
            }
            
            
        }
    }];
    
    return attributesArray;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"collectionView"]) {
        [self setUpGestureRecognizers];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];;
    }
}
- (void)configureObserver
{
    [self addObserver:self forKeyPath:@"collectionView" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}
- (void)setUpDisplayLink
{
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(continuousScroll)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)invalidateDisplayLink
{
    _continuousScrollDirection = stay;
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}
- (void)beginScrollIfNeeded
{
    if (_cellFakeView) {
        if ([self fakeCellTopEdge] <=([self offsetFromTop]+[self triggerPaddingTop]+[self triggerInsetTop])) {
            _continuousScrollDirection = toTop;
            [self setUpDisplayLink];
        }else if ([self fakeCellEndEdge] >=([self offsetFromTop]+[self collectionViewLength]-[self triggerPaddingEnd]-[self triggerInsetEnd])){
            _continuousScrollDirection = toEnd;
            [self setUpDisplayLink];

        }else{
            [self invalidateDisplayLink];
        }
    }
}
- (void)moveItemIfNeeded
{
    if (_cellFakeView) {
        NSIndexPath *atIndexPath = _cellFakeView.indexPath;
        NSIndexPath *toIndexPath = [self.collectionView indexPathForItemAtPoint:_cellFakeView.center];
        if (!atIndexPath||!toIndexPath) {
            return;
        }
        if (atIndexPath.item!=toIndexPath.item) {
            if ([self.delegate respondsToSelector:@selector(collectionView:atIndexPath:canMoveToIndexPath:)]) {
                BOOL canMove = [self.delegate collectionView:self.collectionView atIndexPath:atIndexPath canMoveToIndexPath:toIndexPath];
                if (canMove) {
                    if ([self.delegate respondsToSelector:@selector(collectionView:atIndexPath:willMoveToIndexPath:)]) {
                        // will move item
                        [self.delegate collectionView:self.collectionView atIndexPath:atIndexPath willMoveToIndexPath:toIndexPath];
                    }
                    UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForItemAtIndexPath:toIndexPath];
                    [self.collectionView performBatchUpdates:^{
                        _cellFakeView.indexPath = toIndexPath;
                        _cellFakeView.cellFrame = attribute.frame;
                        [_cellFakeView changeBoundsIfNeeded:attribute.bounds];
                        [self.collectionView deleteItemsAtIndexPaths:@[atIndexPath]];
                        [self.collectionView insertItemsAtIndexPaths:@[toIndexPath]];
                        if ([self.delegate respondsToSelector:@selector(collectionView:atIndexPath:didMoveToIndexPath:)]) {
                            // did move item
                            [self.delegate collectionView:self.collectionView atIndexPath:atIndexPath didMoveToIndexPath:toIndexPath];
                        }
                    } completion:nil];

                }
            }
        }
    }
}

- (void)continuousScroll
{
    if (_cellFakeView) {
        CGFloat  percentage = [self calcTriggerPercentage];
        CGFloat scrollRate = [self scrollValue:self.scrollSpeedValue percentage:percentage];
        
        CGFloat offset = [self offsetFromTop];
        CGFloat length = [self collectionViewLength];
        if (([self contentLength]+[self insetsTop]+[self insetsEnd])<=length) {
            return;
        }
        if (offset+scrollRate<=(-[self insetsTop])) {
            scrollRate =-[self insetsTop]-offset;
        }else if (offset+scrollRate>=([self contentLength]+[self insetsEnd]-length)){
            scrollRate = [self contentLength]+[self insetsEnd]-length-offset;
        }
        [self.collectionView performBatchUpdates:^{
            if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                self.fakeCellCenter = CGPointMake(self.fakeCellCenter.x, self.fakeCellCenter.y+scrollRate);
                _cellFakeView.center = CGPointMake(self.cellFakeView.center.x, self.fakeCellCenter.y+self.panTranslation.y);
                self.collectionView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y+scrollRate);
                
            }else{
                self.fakeCellCenter = CGPointMake(self.fakeCellCenter.x+scrollRate, self.fakeCellCenter.y);
                _cellFakeView.center = CGPointMake(self.fakeCellCenter.x+self.panTranslation.x,self.cellFakeView.center.y);
                self.collectionView.contentOffset = CGPointMake(self.collectionView.contentOffset.x+scrollRate,self.collectionView.contentOffset.y);
            }
        } completion:nil];
        [self moveItemIfNeeded];
    }
}
- (CGFloat)calcTriggerPercentage
{
    if (_cellFakeView) {
        CGFloat offset = [self offsetFromTop];
        CGFloat offsetEnd = [self offsetFromTop] + [self collectionViewLength];
        CGFloat paddingEnd = [self triggerPaddingEnd];
        CGFloat percentage = 0;
        switch (self.continuousScrollDirection) {
            case toTop:
                if ([self fakeCellTopEdge]) {
                    percentage = 1.0-(([self fakeCellTopEdge]-(offset+[self triggerPaddingTop]))/[self triggerInsetTop]);
                }
                break;
            case toEnd:
                if ([self fakeCellEndEdge]) {
                    percentage = 1.0 -((([self insetsTop]+offsetEnd-paddingEnd)-([self fakeCellEndEdge]+[self insetsTop]))/[self triggerInsetEnd]);
                }
                break;
            default:
                break;
                
        }
        percentage = MIN(1.0, percentage);
        percentage = MAX(0, percentage);
        return percentage;

    }
    return 0;
}
- (void)setUpGestureRecognizers
{
    if (self.longPress&&self.panGesture) {
        return;
    }
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    _longPress.delegate = self;
    _panGesture.delegate = self;
    _panGesture.maximumNumberOfTouches = 1;
    NSArray *gestures = self.collectionView.gestureRecognizers;
    [gestures enumerateObjectsUsingBlock:^(id gestureRecognizer, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [gestureRecognizer requireGestureRecognizerToFail:self.longPress];
        }
    }];
    [self.collectionView addGestureRecognizer:self.longPress];
    [self.collectionView addGestureRecognizer:self.panGesture];
}

- (void)cancelDrag:(NSIndexPath *)toIndexPath
{
    if (_cellFakeView) {
        if ([self.delegate respondsToSelector:@selector(collectionView:collectionViewLayout:willEndDraggingItemToIndexPath:)]) {
            [self.delegate collectionView:self.collectionView collectionViewLayout:self willEndDraggingItemToIndexPath:toIndexPath];
        }
        self.collectionView.scrollsToTop = YES;
        self.fakeCellCenter = CGPointZero;
        [self invalidateDisplayLink];
        [self.cellFakeView pushBackView:^{
            [self.cellFakeView removeFromSuperview];
            self.cellFakeView = nil;
            [self invalidateLayout];
            if ([self.delegate respondsToSelector:@selector(collectionView:collectionViewLayout:didEndDraggingItemToIndexPath:)]) {
                [self.delegate collectionView:self.collectionView collectionViewLayout:self didEndDraggingItemToIndexPath:toIndexPath];
            }
        }];
    }
}
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    CGPoint location = [longPress locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    if (_cellFakeView) {
        indexPath = _cellFakeView.indexPath;
    }
    if (!indexPath) {
        return;
    }
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
             // will begin drag item
            if ([self.delegate respondsToSelector:@selector(collectionView:collectionViewLayout:willBeginDraggingItemAtIndexPath:)]) {
                [self.delegate collectionView:self.collectionView collectionViewLayout:self willBeginDraggingItemAtIndexPath:indexPath];
            }
            self.collectionView.scrollsToTop = NO;
            UICollectionViewCell *currentCell = [self.collectionView cellForItemAtIndexPath:indexPath];
            _cellFakeView = [[DQCellFakeView alloc] initWithCell:currentCell];
            _cellFakeView.indexPath = indexPath;
            _cellFakeView.originalCenter = currentCell.center;
            _cellFakeView.cellFrame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
            [self.collectionView addSubview:_cellFakeView];
            _fakeCellCenter = _cellFakeView.center;
            [self invalidateLayout];
            [_cellFakeView pushFowardView];
            
            // did begin drag item
            if ([self.delegate respondsToSelector:@selector(collectionView:collectionViewLayout:didBeginDraggingItemAtIndexPath:)]) {
                [self.delegate collectionView:self.collectionView collectionViewLayout:self didBeginDraggingItemAtIndexPath:indexPath];
            }
            
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            [self cancelDrag:indexPath];
        }
        default:
            break;
    }
}
- (void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    _panTranslation = [pan translationInView:self.collectionView];
    if (_cellFakeView) {
        switch (pan.state) {
            case UIGestureRecognizerStateChanged:
            {
                _cellFakeView.center = CGPointMake(_fakeCellCenter.x+_panTranslation.x, _fakeCellCenter.y+_panTranslation.y);
                [self beginScrollIfNeeded];
                [self moveItemIfNeeded];
            }
                break;
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
            {
                [self invalidateDisplayLink];
            }
                
            default:
                break;
        }
    }
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    if (indexPath) {
        if ([self.delegate respondsToSelector:@selector(collectionView:allowMoveAtIndexPath:)]) {
            return [self.delegate collectionView:self.collectionView allowMoveAtIndexPath:indexPath];
        }
    }
    //这里会不会漏掉一种情况
    if (gestureRecognizer == self.longPress) {
        return !(self.collectionView.panGestureRecognizer.state != UIGestureRecognizerStatePossible && self.collectionView.panGestureRecognizer.state != UIGestureRecognizerStateFailed);
    }
    if (gestureRecognizer == self.panGesture) {
        return !(self.longPress.state == UIGestureRecognizerStatePossible || self.longPress.state == UIGestureRecognizerStateFailed);

    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.panGesture) {
        return otherGestureRecognizer == self.longPress;
    }
    if (gestureRecognizer == self.collectionView.panGestureRecognizer) {
        return (self.longPress.state != UIGestureRecognizerStatePossible || self.longPress.state != UIGestureRecognizerStateFailed);
    }
    return YES;
}
- (CGFloat)scrollValue:(CGFloat)speedValue percentage:(CGFloat )percentage
{
    CGFloat vaule = 0;
    switch (self.continuousScrollDirection) {
        case toTop:
            vaule = -speedValue;
            break;
        case toEnd:
            vaule = speedValue;
        
        default:
            return 0;
            break;
    }
    CGFloat proofedPercentage = MAX(MIN(1.0, percentage), 0);
    return vaule * proofedPercentage;
}

- (CGFloat)offsetFromTop
{
    CGPoint contentOffset = self.collectionView.contentOffset;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return contentOffset.y;
    }
    return contentOffset.x;
}

- (CGFloat)insetsTop
{
    UIEdgeInsets contentInsets = self.collectionView.contentInset;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return contentInsets.top;
    }
    return contentInsets.left;
}
- (CGFloat)insetsEnd
{
    UIEdgeInsets contentInsets = self.collectionView.contentInset;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return contentInsets.bottom;
    }
    return contentInsets.right;
}
- (CGFloat)contentLength
{
    CGSize contentSize = self.collectionView.contentSize;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return contentSize.height;
    }
    return contentSize.width;
}
- (CGFloat)collectionViewLength
{
    CGSize collectionViewSize = self.collectionView.bounds.size;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return collectionViewSize.height;
    }
    return collectionViewSize.width;
}
- (CGFloat)fakeCellTopEdge
{
    if (!self.cellFakeView) {
        return 0;
    }
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return CGRectGetMinY(self.cellFakeView.frame);
    }
    return CGRectGetMinX(self.cellFakeView.frame);
}
- (CGFloat)fakeCellEndEdge
{
    if (!self.cellFakeView) {
        return 0;
    }
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return CGRectGetMaxY(self.cellFakeView.frame);
    }
    return CGRectGetMaxX(self.cellFakeView.frame);
}
- (CGFloat)triggerInsetTop
{
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return  self.trigerInsets.top;
    }
    return self.trigerInsets.left;
}
- (CGFloat)triggerInsetEnd
{
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return  self.trigerInsets.top;
    }
    return self.trigerInsets.left;
}
- (CGFloat)triggerPaddingTop
{
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return  self.trigerPadding.top;
    }
    return self.trigerPadding.left;
}
- (CGFloat)triggerPaddingEnd
{
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return  self.trigerPadding.bottom;
    }
    return self.trigerPadding.right;
}


@end
