//
//  JYGestureViewController.m
//  JYFinance
//
//  Created by shiyabing on 16/8/5.
//  Copyright © 2016年 xiangshang. All rights reserved.
//

#import "JYGesturePwdController.h"
#import "JYGestureMiniLockView.h"
#import "JYGestureNineButtonView.h"
#import "JYTabBarController.h"
#import "AppDelegate.h"
#import "JYUserModel.h"
#import "JYLoginViewController.h"

#define MINIGESTUREVIEW_W 64

#define WORINGGESPWD       @"密码错误"//
#define DIFFERENTGESPWD    @"与上次绘制不一致，请重新绘制"//两次密码不一致
#define DRAWGESPWDAGAIN    @"请再次绘制手势密码"//再次设置
#define SETGESPWDSUCCESS   @"设置成功"//
#define CHANGEGESSUCCESS   @"修改成功"
#define ATLEASTFOURGESOWD  @"至少连接四个点，请重新绘制"
#define GESVALIDATESUCCESS @"验证成功"

@interface JYGesturePwdController ()<JYGestureLockDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) UILabel  *titleLabel;
@property (nonatomic,strong) UILabel  *tipLabel;
@property (nonatomic,strong) UILabel  *mobileLB;
@property (nonatomic,strong) UIButton *jumpBtn;
@property (nonatomic,strong) UIButton *backBtn;
@property (nonatomic,strong) UIButton *resetButton;
@property (nonatomic,strong) UIButton *forgetButton;
@property (nonatomic,strong) UIButton *otherUserLoginBtn;
@property (nonatomic,strong) JYGestureMiniLockView    *miniView;
@property (nonatomic,strong) JYGestureNineButtonView *gestureView;
@property (nonatomic,strong) id<JYGestureLockDelegate> delegate;

@end

@implementation JYGesturePwdController
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if ([JYHelper currentArchiveUserInfo].isSetTouchId && _isLoginEntrance) {
        [JYHelper verifyTouchIdWithLocalizedFallbackTitle:@"" callBack:^(BOOL result, NSError *error) {
            //验证成功，进入应用
            if (result){
                [self dismissSelf];
            }else{
                [JYMSGManager showTextInWindow:@"指纹验证失败，请使用手势密码登录!"];
            }
            
        }]; 
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.isLoginEntrance) {
        [self performSelector:@selector(enablePopGestere:) withObject:@(NO) afterDelay:1.0];
    }
}

- (void)enablePopGestere:(BOOL)enable{
    self.navigationController.interactivePopGestureRecognizer.enabled = enable;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavBarStyle:JYNavigationBarStyle_Red];

    [self _creatSubViews];
}

- (void)_creatSubViews{
    _gestureView.isSetGesturePwd = [JYHelper currentArchiveUserInfo].isSetGesPwd;
    //    背景
    UIImage *bgImg = [UIImage imageNamed:@"gesture_back"];
    bgImg = [bgImg stretchableImageWithLeftCapWidth:2 topCapHeight:300];
    UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, KDeviceHeight)];
    bgView.image = bgImg;
    [self.view addSubview:bgView];
    //    九宫格按钮view
    _gestureView = [[JYGestureNineButtonView alloc]initWithFrame:CGRectMake((kDeviceWidth - KDeviceHeight / 2.224) * 0.5, KDeviceHeight - KDeviceHeight/2.224 - KDeviceHeight/6.86, KDeviceHeight / 2.224, KDeviceHeight / 2.224)];
    _gestureView.isLoginEntrance = self.isLoginEntrance;
    _gestureView.delegate = self;
    [self.view addSubview:_gestureView];
    //   提示label
    _tipLabel = [JYTools buildLabelWithFrame:CGRectMake(0, _gestureView.y - KDeviceHeight/66.7 - 40, kDeviceWidth, 30) backColor:kClearColor content:nil textColor:ColorWithHex(0xffffff, 1) font:JYFont(16) textAlignment:NSTextAlignmentCenter];
    _tipLabel.text = @"请绘制手势密码";
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:_tipLabel];
    //  手机号label
    _mobileLB = [JYTools buildLabelWithFrame:CGRectMake(0, _tipLabel.y - 50, kDeviceWidth, 30) backColor:kClearColor content:[[JYHelper currentArchiveUserInfo].mobile stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"] textColor:kWhiteColor font:kFont18];
    _mobileLB.hidden = YES;
    _mobileLB.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_mobileLB];
    //    九宫格小图
    _miniView = [[JYGestureMiniLockView alloc]initWithFrame:CGRectMake((kDeviceWidth - MINIGESTUREVIEW_W+2)/2, _tipLabel.y - 70, MINIGESTUREVIEW_W, 60)];
    _miniView.centerX = _gestureView .centerX;
    [self.view addSubview:_miniView];
    //    重新设置按钮
    _resetButton = [JYTools buildButtonWithFrame:CGRectMake((kDeviceWidth - 100) - (kDeviceWidth - KDeviceHeight / 2.224)/2, KDeviceHeight - KDeviceHeight / 7.4, 100, 30) backColor:kClearColor title:@"重新设置" textColor:kWhiteColor font:kFont16];
    _resetButton.hidden = YES;
    [_resetButton sizeToFit];
    _resetButton.centerX = _gestureView.centerX;
    [_resetButton addTarget:self action:@selector(resetPasswordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_resetButton];
    //    其他账号登录按钮
    _otherUserLoginBtn = [JYTools buildButtonWithFrame:CGRectMake(0, KDeviceHeight - KDeviceHeight / 7.4, kDeviceWidth / 2, 30) backColor:kClearColor title:@"其他账号登录" textColor:kWhiteColor font:kFont16];
    [_otherUserLoginBtn addTarget:self action:@selector(otherUserLoginButtonAction) forControlEvents:UIControlEventTouchUpInside];
    _otherUserLoginBtn.hidden = YES;
    [self.view addSubview:_otherUserLoginBtn];
    //    忘记密码按钮
    _forgetButton = [JYTools buildButtonWithFrame:CGRectMake(_otherUserLoginBtn.maxX + 10, KDeviceHeight - KDeviceHeight / 7.4, kDeviceWidth / 2, 30) backColor:kClearColor title:@"忘记手势密码?" textColor:kWhiteColor font:kFont16];
    [_forgetButton addTarget:self action:@selector(forgetPasswordAction) forControlEvents:UIControlEventTouchUpInside];
    _forgetButton.hidden = YES;
    [self.view addSubview:_forgetButton];
    //    顶部标题
    _titleLabel = [JYTools buildLabelWithFrame:CGRectMake((kDeviceWidth - (kDeviceWidth - 200))/2, 25, kDeviceWidth - 200, 35) backColor:kClearColor content:@"设置手势密码" textColor:kWhiteColor font:kFont16 textAlignment:NSTextAlignmentCenter];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titleLabel];
    //    跳过按钮
    _jumpBtn = [JYTools buildButtonWithFrame:CGRectMake(kDeviceWidth - 70, 25, 60, 35) backColor:kClearColor title:@"跳过此步" textColor:kWhiteColor font:kFont14];
    _jumpBtn.hidden = YES;
    [_jumpBtn addTarget:self action:@selector(jumpAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_jumpBtn];
    //    返回按钮
    _backBtn = [JYTools buildButtonWithFrame:CGRectMake(5, 20, 20, 44) backColor:kClearColor title:nil textColor:nil font:nil];
    [_backBtn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(setCancel) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_backBtn];
    
    if ([JYHelper currentArchiveUserInfo].isSetGesPwd && [JYHelper currentArchiveUserInfo].isOpenGesPwd) {
        if (self.isLoginEntrance) {
            _tipLabel.text            = @"请绘制手势密码";
            _miniView.hidden          = YES;
            _titleLabel.hidden        = YES;
            _backBtn.hidden           = YES;
            _mobileLB.hidden          = NO;
            _otherUserLoginBtn.hidden = NO;
            _forgetButton.hidden      = NO;
        }else{
            _titleLabel.text          = @"修改手势密码";
            _tipLabel.text            = @"设置新手势密码";
        }
    }else{
        if (self.isLoginEntrance) {
            _jumpBtn.hidden           = NO;
            _backBtn.hidden           = YES;
        }
    }
}

#pragma mark ---buttonClickAction
//返回按钮
- (void)setCancel{
    [self dismissSelf];
}
//重新设置按钮
- (void)resetPasswordAction{
    NSLog(@"reset");
    [_miniView refreshWithInfo:@[]];
    _gestureView.isSetGesturePwd = NO;
    
    JYUserModel *model = [JYHelper currentArchiveUserInfo];
    model.isSetGesPwd = NO;
    model.isSetTouchId = NO;
    [JYHelper archiveUserInfo:model];
    
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
    DLog(@"show loginView");
//    [JYHelper clearUserInfo];
//    JYLoginViewController *login = [[UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"JYLoginViewController"];
//    login.isRoot = self.isRoot;
//    [self.navigationController pushViewController:login animated:YES];
}
//跳过按钮
- (void)jumpAction{
    [self dismissSelf];
    
}

#pragma mark ---XSGestureLockDelegate
- (void)GestureLockSetResult:(NSString *)result gestureView:(JYGestureNineButtonView *)gestureView{
    _tipLabel.text = result;
    _tipLabel.textColor = ColorWithHex(0xffffff, 1);
    if ([result isEqualToString:SETGESPWDSUCCESS]) {
        JYUserModel *model = [JYHelper currentArchiveUserInfo];
        model.gesPwd = _gestureView.inputPassword;
        model.isSetGesPwd = YES;
        model.isOpenGesPwd = YES;
        [JYHelper archiveUserInfo:model];
        if (self.isLoginEntrance) {
            if ([JYHelper checkTouchIDUsable]) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"使用提示" message:@"是否需要开启Touch ID?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开启", nil];
                alertView.tag = 1001;
                [alertView show];
            }else{
                [self dismissSelf];
            }
        }else{
            [self dismissSelf];
            [JYMSGManager showTextInWindow:@"手势密码设置成功"];
        }
    }else if([result isEqualToString:CHANGEGESSUCCESS]){
        JYUserModel *model = [JYHelper currentArchiveUserInfo];
        model.gesPwd = _gestureView.inputPassword;
        model.isSetGesPwd = YES;
        [self dismissSelf];
        [JYMSGManager showTextInWindow:@"修改成功"];
        [JYHelper archiveUserInfo:model];
    }else if([result isEqualToString:GESVALIDATESUCCESS]){
        [self dismissSelf];
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
#pragma mark ---UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1001) {
        
        if (buttonIndex ==  0) {
            [self dismissSelf];
            
        }else{
            DLog(@"开启Touch ID");
            //开启Touch ID
            [JYHelper verifyTouchIdWithLocalizedFallbackTitle:@"请验证已有指纹" callBack:^(BOOL result, NSError *error) {
                if (result) {
                    JYUserModel *model = [JYHelper currentArchiveUserInfo];
                    model.isSetTouchId = YES;
                    [JYHelper archiveUserInfo:model];
                    [self dismissSelf];
                }else{
                    [self dismissSelf];
                    [JYMSGManager showTextInWindow:@"指纹解锁开启失败"];
                }
            }];
        }
    }
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
//dismiss当前视图控制器
- (void)dismissSelf{
    if (_isRoot) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate setHomeRootViewController];
    }else{
        if (_isLoginEntrance) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self.navigationController popToViewController:self.popToViewController animated:YES];
        }
    }
}

@end
