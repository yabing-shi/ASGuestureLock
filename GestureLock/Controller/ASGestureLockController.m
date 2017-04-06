//
//  ASGestureLockController.m
//  ASGuestureLock
//
//  Created by shiyabing on 17/4/6.
//  Copyright © 2017年 shiyabing. All rights reserved.
//

#import "ASGestureLockController.h"
#import "ASGestureMiniLockView.h"
#import "ASGestureNineButtonView.h"

#define MINIGESTUREVIEW_W 64

#define WORINGGESPWD       @"密码错误"//
#define DIFFERENTGESPWD    @"与上次绘制不一致，请重新绘制"//两次密码不一致
#define DRAWGESPWDAGAIN    @"请再次绘制手势密码"//再次设置
#define SETGESPWDSUCCESS   @"设置成功"//
#define CHANGEGESSUCCESS   @"修改成功"
#define ATLEASTFOURGESOWD  @"至少连接四个点，请重新绘制"
#define GESVALIDATESUCCESS @"验证成功"
#define GESTUREPASSWORDKEY @"GESTUREPASSWORD"
#define kDeviceWidth           [UIScreen mainScreen].bounds.size.width
#define KDeviceHeight          [UIScreen mainScreen].bounds.size.height
#define ColorWithHex(hex,alph)  [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:(alph)]

@interface ASGestureLockController ()<ASGestureLockDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) UIButton *backBtn;

@property (nonatomic,strong) UILabel  *titleLabel;
@property (nonatomic,strong) UILabel  *tipLabel;
@property (nonatomic,strong) UIButton *resetButton;
@property (nonatomic,strong) UIButton *forgetButton;
@property (nonatomic,strong) UIButton *otherUserLoginBtn;
@property (nonatomic,strong) ASGestureMiniLockView    *miniView;
@property (nonatomic,strong) ASGestureNineButtonView *gestureView;
@property (nonatomic,strong) id<ASGestureLockDelegate> delegate;

@end

@implementation ASGestureLockController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _creatSubViews];
}

- (void)_creatSubViews{
    //    背景
    UIImage *bgImg = [UIImage imageNamed:@"gesture_back"];
    bgImg = [bgImg stretchableImageWithLeftCapWidth:2 topCapHeight:300];
    UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, KDeviceHeight)];
    bgView.image = bgImg;
    [self.view addSubview:bgView];
    //    九宫格按钮view
    _gestureView = [[ASGestureNineButtonView alloc]initWithFrame:CGRectMake((kDeviceWidth - KDeviceHeight / 2.224) * 0.5, KDeviceHeight - KDeviceHeight/2.224 - KDeviceHeight/6.86, KDeviceHeight / 2.224, KDeviceHeight / 2.224)];
    _gestureView.isLoginEntrance = self.isLoginEntrance;
    _gestureView.delegate = self;
    [self.view addSubview:_gestureView];
    //   提示label
    _tipLabel = [self buildLabelWithFrame:CGRectMake(0, _gestureView.frame.origin.y - KDeviceHeight/66.7 - 40, kDeviceWidth, 30) backColor:[UIColor clearColor] content:nil textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:16] textAlignment:NSTextAlignmentCenter];
    _tipLabel.text = @"请绘制手势密码";
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:_tipLabel];

    //    九宫格小图
    _miniView = [[ASGestureMiniLockView alloc]initWithFrame:CGRectMake((kDeviceWidth - MINIGESTUREVIEW_W+2)/2, _tipLabel.frame.origin.y - 70, MINIGESTUREVIEW_W, 60)];
    [self.view addSubview:_miniView];
    //    重新设置按钮
    _resetButton = [self buildButtonWithFrame:CGRectMake((kDeviceWidth - 100)/2 + 25, KDeviceHeight - KDeviceHeight / 7.4, 100, 30) backColor:[UIColor clearColor] title:@"重新设置" textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:16]];
    _resetButton.hidden = YES;
    [_resetButton sizeToFit];
    [_resetButton addTarget:self action:@selector(resetPasswordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_resetButton];
    //    其他账号登录按钮
    _otherUserLoginBtn = [self buildButtonWithFrame:CGRectMake(0, KDeviceHeight - KDeviceHeight / 7.4, kDeviceWidth / 2, 30) backColor:[UIColor clearColor] title:@"其他账号登录" textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:16]];
    [_otherUserLoginBtn addTarget:self action:@selector(otherUserLoginButtonAction) forControlEvents:UIControlEventTouchUpInside];
    _otherUserLoginBtn.hidden = YES;
    [self.view addSubview:_otherUserLoginBtn];
    //    忘记密码按钮
    _forgetButton = [self buildButtonWithFrame:CGRectMake(_otherUserLoginBtn.frame.origin.x +_otherUserLoginBtn.frame.size.width + 10, KDeviceHeight - KDeviceHeight / 7.4, kDeviceWidth / 2, 30) backColor:[UIColor clearColor] title:@"忘记手势密码?" textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:16]];
    [_forgetButton addTarget:self action:@selector(forgetPasswordAction) forControlEvents:UIControlEventTouchUpInside];
    _forgetButton.hidden = YES;
    [self.view addSubview:_forgetButton];
    //    顶部标题
    _titleLabel = [self buildLabelWithFrame:CGRectMake((kDeviceWidth - (kDeviceWidth - 200))/2, 25, kDeviceWidth - 200, 35) backColor:[UIColor clearColor] content:@"设置手势密码" textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:16] textAlignment:NSTextAlignmentCenter];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titleLabel];
    //    返回按钮
    _backBtn = [self buildButtonWithFrame:CGRectMake(5, 20, 20, 44) backColor:[UIColor clearColor] title:nil textColor:nil font:nil];
    [_backBtn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(setCancel) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_backBtn];
  
    if (_gestureView.isSetGesturePwd) {
        if (self.isLoginEntrance) {
            _tipLabel.text            = @"请绘制手势密码";
            _miniView.hidden          = YES;
            _titleLabel.text          = @"验证手势密码";
            _otherUserLoginBtn.hidden = NO;
            _forgetButton.hidden      = NO;
        }else{
            _titleLabel.hidden = NO;
            _titleLabel.text          = @"修改手势密码";
            _tipLabel.text            = @"设置新手势密码";
        }
    }
    
}

#pragma mark ---buttonClickAction
//返回按钮
- (void)setCancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//重新设置按钮
- (void)resetPasswordAction{
    NSLog(@"reset");
    [_miniView refreshWithInfo:@[]];
    _gestureView.isSetGesturePwd = NO;
    _gestureView.isConfirm = NO;
    for (UIButton *btn in _gestureView.selectBtnArr) {
        btn.selected = NO;
    }
    [_gestureView.selectBtnArr removeAllObjects];
    _tipLabel.text = @"请设置手势密码";
    [_gestureView setNeedsDisplay];
}
//忘记密码
- (void)forgetPasswordAction{
    [self otherUserLoginButtonAction];
}
//其他用户登录
- (void)otherUserLoginButtonAction{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:GESTUREPASSWORDKEY];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ---XSGestureLockDelegate
- (void)GestureLockSetResult:(NSString *)result gestureView:(ASGestureNineButtonView *)gestureView{
    _tipLabel.text = result;
    _tipLabel.textColor = ColorWithHex(0xffffff, 1);
    if ([result isEqualToString:SETGESPWDSUCCESS]) {
        [[NSUserDefaults standardUserDefaults] setObject:_gestureView.inputPassword forKey:GESTUREPASSWORDKEY];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }else if([result isEqualToString:CHANGEGESSUCCESS]){
        [[NSUserDefaults standardUserDefaults] setObject:_gestureView.inputPassword forKey:GESTUREPASSWORDKEY];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }else if ([result isEqualToString:GESVALIDATESUCCESS]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }else if([result isEqualToString:DRAWGESPWDAGAIN]){
        _resetButton.hidden = NO;
        [_miniView refreshWithInfo:_gestureView.selectBtnArr];
    }else if ([result isEqualToString:WORINGGESPWD]){
        if (_gestureView.indexTag < 5) {
            _tipLabel.text = [NSString stringWithFormat:@"密码错误，还有%ld次机会",5 - _gestureView.indexTag];
            _tipLabel.textColor = ColorWithHex(0xba0a0a, 1);
            [self shakeView:_tipLabel];
        }else{
            [self otherUserLoginButtonAction];
        }
    }else if ([result isEqualToString:DIFFERENTGESPWD] || [result isEqualToString:ATLEASTFOURGESOWD]){
        [self shakeView:_tipLabel];
    }
}

- (UILabel *)buildLabelWithFrame:(CGRect)frame backColor:(UIColor *)color content:(NSString *)text textColor:(UIColor *)tColor {
    UILabel *newLabel        = [[UILabel alloc] initWithFrame:frame];
    newLabel.backgroundColor = color==nil?[UIColor clearColor]:color;
    newLabel.text            = text;
    newLabel.textColor       = tColor;
    
    return newLabel;
}

- (UILabel *)buildLabelWithFrame:(CGRect)frame backColor:(UIColor *)color content:(NSString *)text textColor:(UIColor *)tColor font:(UIFont *)font {
    UILabel *newLabel = [self buildLabelWithFrame:frame backColor:color content:text textColor:tColor];
    newLabel.font     = font==nil?[UIFont systemFontOfSize:15]:font;
    
    return newLabel;
}

- (UILabel *)buildLabelWithFrame:(CGRect)frame backColor:(UIColor *)color content:(NSString *)text textColor:(UIColor *)tColor font:(UIFont *)font textAlignment:(NSTextAlignment)alignment {
    UILabel *newLabel      = [self buildLabelWithFrame:frame backColor:color content:text textColor:tColor font:font];
    newLabel.textAlignment = alignment;
    
    return newLabel;
}

- (UILabel *)buildLabelWithFrame:(CGRect)frame backColor:(UIColor *)color content:(NSString *)text textColor:(UIColor *)tColor font:(UIFont *)font textAlignment:(NSTextAlignment)alignment lines:(NSInteger)line {
    UILabel *newLabel      = [self buildLabelWithFrame:frame backColor:color content:text textColor:tColor font:font textAlignment:alignment];
    newLabel.numberOfLines = line;
    
    return newLabel;
}

- (UIButton *)buildButtonWithFrame:(CGRect)frame backColor:(UIColor *)color title:(NSString *)title textColor:(UIColor *)tColor font:(UIFont *)font {
    UIButton *newButton       = [UIButton buttonWithType:UIButtonTypeCustom];
    newButton.frame           = frame;
    newButton.backgroundColor = color==nil?[UIColor clearColor]:color;
    newButton.titleLabel.font = font==nil?[UIFont systemFontOfSize:15]:font;
    [newButton setTitle:title forState:UIControlStateNormal];
    [newButton setTitleColor:tColor==nil?ColorWithHex(0x222222, 1):tColor forState:UIControlStateNormal];
    
    return newButton;
}

//摇晃view
-(void)shakeView:(UIView *)view {
    CALayer *layer = [view layer];
    CGPoint point  = [layer position];
    CGPoint y      = CGPointMake(point.x - 5, point.y);
    CGPoint x      = CGPointMake(point.x + 5, point.y);
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    [animation setAutoreverses:YES];
    [animation setDuration:0.08];
    [animation setRepeatCount:3];
    [layer addAnimation:animation forKey:nil];
}

@end
