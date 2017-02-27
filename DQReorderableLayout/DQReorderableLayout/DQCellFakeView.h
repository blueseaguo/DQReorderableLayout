//
//  RACellFakeView.h
//  DongQiuDi
//
//  Created by guo on 17/2/7.
//  Copyright © 2015年 ballpure.com. All rights reserved.
//
#import <UIKit/UIKit.h>
typedef void(^completion)();

@interface DQCellFakeView : UIView

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, assign) CGRect cellFrame;
- (instancetype)initWithCell:(UICollectionViewCell *)cell;

-(void)changeBoundsIfNeeded:(CGRect)bounds;
-(void)pushFowardView;
-(void)pushBackView:(completion)completion;
@end
