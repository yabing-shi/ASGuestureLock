//
//  JYGuestureNineButtonView.h
//  JYFinance
//
//  Created by shiyabing on 16/8/5.
//  Copyright © 2016年 xiangshang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JYGestureNineButtonView;

@protocol JYGestureLockDelegate <NSObject>

@optional

- (void)GestureLockSetResult:(NSString *)result gestureView:(JYGestureNineButtonView *)gestureView;

@end

@interface JYGestureNineButtonView : UIView

@property (nonatomic,strong ) NSMutableString       *inputPassword;
@property (nonatomic,strong ) NSMutableArray        *selectBtnArr;
@property (nonatomic,assign ) NSInteger             indexTag;
@property (nonatomic,assign ) BOOL                  isSetGesturePwd;
@property (nonatomic,assign ) BOOL                  isConfirm;
@property (nonatomic,assign ) BOOL                  isLoginEntrance;
@property (nonatomic,assign ) id<JYGestureLockDelegate> delegate;

@end
