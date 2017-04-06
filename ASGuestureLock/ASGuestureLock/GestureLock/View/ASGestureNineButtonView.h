//
//  ASGestureNineButtonView.h
//  ASGuestureLock
//
//  Created by shiyabing on 17/4/6.
//  Copyright © 2017年 shiyabing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ASGestureNineButtonView;
@protocol ASGestureLockDelegate <NSObject>

@optional

- (void)GestureLockSetResult:(NSString *)result gestureView:(ASGestureNineButtonView *)gestureView;

@end

@interface ASGestureNineButtonView : UIView

@property (nonatomic,strong ) NSMutableString       *inputPassword;
@property (nonatomic,strong ) NSMutableArray        *selectBtnArr;
@property (nonatomic,assign ) NSInteger             indexTag;
@property (nonatomic,assign ) BOOL                  isSetGesturePwd;
@property (nonatomic,assign ) BOOL                  isConfirm;
@property (nonatomic,assign ) BOOL                  isLoginEntrance;
@property (nonatomic,assign ) id<ASGestureLockDelegate> delegate;

@end
