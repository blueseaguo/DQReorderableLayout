//
//  RACellFakeView.m
//  DongQiuDi
//
//  Created by guo on 17/2/7.
//  Copyright © 2015年 ballpure.com. All rights reserved.
//

#import "DQCellFakeView.h"
@interface DQCellFakeView ()


@property (nonatomic, weak) UICollectionViewCell *cell;
@property (nonatomic, strong) UIImageView *cellFakeImageView;
@property (nonatomic, strong) UIImageView *cellFakeHightedView;

@end
@implementation DQCellFakeView


- (instancetype)initWithCell:(UICollectionViewCell *)cell
{
    self = [super initWithFrame:cell.frame];
    if (self) {
      
        self.cell = cell;
        
        self.layer.shadowColor = [UIColor colorWithRed:22.0/255.0 green:172.0/255.0 blue:58.0/255.0 alpha:1].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 0;
        self.layer.shadowRadius = 1.0;
        self.layer.shouldRasterize = NO;
        self.layer.borderColor = [UIColor colorWithRed:22.0/255.0 green:172.0/255.0 blue:58.0/255.0 alpha:1].CGColor;
        self.layer.borderWidth = 1.0;
        [self addSubview:self.cellFakeImageView];
        [self addSubview:self.cellFakeHightedView];
    }
    
    return self;
}

- (UIImageView *)cellFakeImageView
{
    if (!_cellFakeImageView) {
        _cellFakeImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _cellFakeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _cellFakeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
        _cellFakeImageView.image = [self getCellImage];
        
    }
    return _cellFakeImageView;
}
- (UIImageView *)cellFakeHightedView
{
    if (!_cellFakeHightedView) {
        _cellFakeHightedView = [[UIImageView alloc] initWithFrame:self.bounds];
        _cellFakeHightedView.contentMode = UIViewContentModeScaleAspectFill;
        _cellFakeHightedView.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
        _cellFakeHightedView.image = [self getCellImage];
        
    }
    return _cellFakeHightedView;
}
-(void)changeBoundsIfNeeded:(CGRect)bounds {
    if (CGRectEqualToRect(self.bounds, bounds)) {
        return;
    }
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.3 delay:0 options:options animations:^{
        self.bounds = bounds;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)pushFowardView {
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.3 delay:0 options:options animations:^{
        self.center = self.originalCenter;
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.cellFakeHightedView.alpha = 0;
        CABasicAnimation  *shadowAnimation =[CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        
        shadowAnimation.fromValue = @0;
        shadowAnimation.toValue = @0.7;
        shadowAnimation.removedOnCompletion = false;
        shadowAnimation.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:shadowAnimation forKey:@"applyShadow"];
    } completion:^(BOOL finished) {
        [self.cellFakeHightedView removeFromSuperview];
    }];
}

-(void)pushBackView:(completion)completion {
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.3 delay:0 options:options animations:^{
        self.frame = self.cellFrame;
        self.transform = CGAffineTransformIdentity;
        self.cellFakeHightedView.alpha = 0;
        CABasicAnimation  *shadowAnimation =[CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        
        shadowAnimation.fromValue = @0.7;
        shadowAnimation.toValue = @0;
        shadowAnimation.removedOnCompletion = false;
        shadowAnimation.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:shadowAnimation forKey:@"removeShadow"];
    } completion:^(BOOL finished) {
        completion();
    }];
}

-(UIImage *)getCellImage {
    UIGraphicsBeginImageContextWithOptions(self.cell.bounds.size, false, [UIScreen mainScreen].scale * 2);
    [self.cell drawViewHierarchyInRect:self.cell.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    return image;
}

@end
