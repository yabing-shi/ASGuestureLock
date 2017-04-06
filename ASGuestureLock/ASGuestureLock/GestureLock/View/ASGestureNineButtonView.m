//
//  ASGestureNineButtonView.m
//  ASGuestureLock
//
//  Created by shiyabing on 17/4/6.
//  Copyright © 2017年 shiyabing. All rights reserved.
//

#import "ASGestureNineButtonView.h"

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

#define LOCKVIEWWIDTH KDeviceHeight / 2.224

@interface ASGestureNineButtonView ()

@property (assign, nonatomic) CGPoint currentPoint;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, copy) NSString *confirmPassword;

@end

@implementation ASGestureNineButtonView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSString *gespwd = [[NSUserDefaults standardUserDefaults] objectForKey:GESTUREPASSWORDKEY];
        if (gespwd.length != 0) {
            _isSetGesturePwd = YES;
        }else{
            _isSetGesturePwd = NO;
        }
        self.backgroundColor = [UIColor clearColor];
        _selectBtnArr        = [[NSMutableArray alloc]initWithCapacity:0];
        _isConfirm           = NO;
        _indexTag            = 0;
    }
    return self;
}

- (NSArray*)buttons{
    if (_buttons == nil) {
        // 创建9个按钮
        NSMutableArray* arrayM = [NSMutableArray array];
        
        for (int i = 0; i < 9; i++) {
            UIButton *button=[[UIButton alloc]init];
            button.tag = i;
            button.userInteractionEnabled = NO;
            [button setBackgroundImage:[UIImage imageNamed:@"button_normal"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"button_highlighted"] forState:UIControlStateSelected];
            
            [self addSubview:button];
            [arrayM addObject:button];
        }
        _buttons = arrayM;
    }
    return _buttons;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    // 设置每个按钮的frame
    CGFloat w = 70;
    CGFloat h = 70;
    // 列（和行）的个数
    int columns = 3;
    // 计算水平方向和垂直方向的间距
    CGFloat marginX = (LOCKVIEWWIDTH - columns * w) / (columns + 1);
    CGFloat marginY = (LOCKVIEWWIDTH - columns * h) / (columns + 1);
    
    // 计算每个按钮的x 和 y
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton* button = self.buttons[i];
        // 计算当前按钮所在的行号
        int row = i / columns;
        // 计算当前按钮所在的列索引
        int col = i % columns;
        
        CGFloat x = marginX + col * (w + marginX);
        CGFloat y = marginY + row * (h + marginY);
        
        button.frame = CGRectMake(x, y, w, h);
    }
}

//视图恢复原样
- (void)resetView{
    for (UIButton *oneSelectBtn in _selectBtnArr) {
        oneSelectBtn.selected = NO;
    }
    [_selectBtnArr removeAllObjects];
    [self setNeedsDisplay];
}

//错误时绘成红色
- (void)drawWoringPicture{
    for (UIButton *btn in _selectBtnArr) {
        [btn setBackgroundImage:[UIImage imageNamed:@"button_error"] forState:UIControlStateSelected];
    }
    [self performSelector:@selector(wrongRevert:) withObject:[NSArray arrayWithArray:_selectBtnArr] afterDelay:.5];
    self.userInteractionEnabled = NO;
    [self setNeedsDisplay];
    
}

//输入错误回到原状态
- (void)wrongRevert:(NSArray *)arr{
    self.userInteractionEnabled = YES;
    for (UIButton *btn in arr) {
        [btn setBackgroundImage:[UIImage imageNamed:@"button_highlighted"] forState:UIControlStateSelected];
    }
    [self resetView];
}

#pragma mark ---Touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *oneTouch = [touches anyObject];
    CGPoint point     = [oneTouch locationInView:self];
    for (UIButton *oneBtn in self.subviews) {
        if (CGRectContainsPoint(oneBtn.frame, point)) {
            oneBtn.selected = YES;
            if (![_selectBtnArr containsObject:oneBtn]) {
                [_selectBtnArr addObject:oneBtn];
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *oneTouch = [touches anyObject];
    CGPoint point     = [oneTouch locationInView:self];
    _currentPoint     = point;
    for (UIButton *oneBtn in self.subviews) {
        if (CGRectContainsPoint(oneBtn.frame, point)) {
            oneBtn.selected = YES;
            if (![_selectBtnArr containsObject:oneBtn]) {
                [_selectBtnArr addObject:oneBtn];
            }
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_selectBtnArr.count == 0) {
        return;
    }
    UIButton *lastBtn =[_selectBtnArr lastObject];
    _currentPoint = lastBtn.center;
    if (_selectBtnArr.count < 4 ) {
        [self.delegate GestureLockSetResult:ATLEASTFOURGESOWD gestureView:self];
        [self drawWoringPicture];
        return;
    }
    //获取结果
    _inputPassword = [[NSMutableString alloc]initWithCapacity:0];
    for (int i = 0; i < _selectBtnArr.count; i ++) {
        UIButton *btn = (UIButton *)_selectBtnArr[i];
        [_inputPassword appendFormat:@"%d",(int)btn.tag];
    }
    if(/* DISABLES CODE */ (!_isSetGesturePwd)){//设置逻辑
        if (!_isConfirm) {
            [self.delegate GestureLockSetResult:DRAWGESPWDAGAIN gestureView:self];
            _isConfirm = YES;
            _confirmPassword =_inputPassword;
            [self resetView];
            
        }else{
            if ([_confirmPassword isEqualToString:_inputPassword]) {
                
                [self.delegate GestureLockSetResult:SETGESPWDSUCCESS gestureView:self];
                [self resetView];
                
            }else{
                
                [self.delegate GestureLockSetResult:DIFFERENTGESPWD gestureView:self];
                [self drawWoringPicture];
            }
        }
    }else{
        if (!_isLoginEntrance) {//修改逻辑
            if (!_isConfirm) {
                [self.delegate GestureLockSetResult:DRAWGESPWDAGAIN gestureView:self];
                _isConfirm = YES;
                _confirmPassword =_inputPassword;
                [self resetView];
            }else{
                if ([_confirmPassword isEqualToString:_inputPassword]) {
                    
                    [self.delegate GestureLockSetResult:CHANGEGESSUCCESS gestureView:self];
                    [self resetView];
                    
                }else{
                    
                    [self.delegate GestureLockSetResult:DIFFERENTGESPWD gestureView:self];
                    [self drawWoringPicture];
                }
            }
        }else{//验证逻辑
            //获取本地的密码
            NSString *localPassword = [[NSUserDefaults standardUserDefaults] objectForKey:GESTUREPASSWORDKEY];
            NSLog(@"%@",localPassword);
            if ([localPassword isEqualToString:_inputPassword]) {
                [self.delegate GestureLockSetResult:GESVALIDATESUCCESS gestureView:self];
            }else{
                _indexTag ++;
                [self.delegate GestureLockSetResult:WORINGGESPWD gestureView:self];
                [self drawWoringPicture];
            }
        }
    }
}

- (void)drawRect:(CGRect)rect{
    UIBezierPath *path;
    if (_selectBtnArr.count == 0) {
        return;
    }
    path = [UIBezierPath bezierPath];
    path.lineWidth     = 2;
    path.lineJoinStyle = kCGLineCapRound;
    path.lineCapStyle  = kCGLineCapRound;
    if (self.userInteractionEnabled) {
        [[UIColor whiteColor] set];
    }else{
        
        [[UIColor redColor] set];
    }
    for (int i = 0; i < _selectBtnArr.count; i ++) {
        UIButton *btn = _selectBtnArr[i];
        if (i == 0) {
            [path moveToPoint:btn.center];
        }else{
            [path addLineToPoint:btn.center];
        }
    }
    [path addLineToPoint:_currentPoint];
    [path stroke];
}

@end
