//
//  JYGestureMiniLockView.m
//  JYFinance
//
//  Created by shiyabing on 16/8/5.
//  Copyright © 2016年 xiangshang. All rights reserved.
//

#import "JYGestureMiniLockView.h"

@implementation JYGestureMiniLockView

- (id)initWithFrame:(CGRect)frame
{
    CGFloat dotV_w = size(50, 30, 26);
    self = [super initWithFrame:frame];
    if (self) {
        
        self.dots = [NSMutableArray arrayWithCapacity:9];
        
        for (NSInteger i = 0; i < 3; i ++) {
            for (NSInteger j = 0; j <3; j ++) {
                
                NSInteger xTMP = i%3;
                NSInteger yTMP = i/3;
                UIImageView *dotView = [[UIImageView alloc]init];
                if (j == 0) {
                    dotView.tag = i + j;
                }else if(j == 1) {
                    dotView.tag = i + j + 2;
                }else if(j == 2) {
                    dotView.tag = i + j + 4;
                }
                dotView.backgroundColor     = kClearColor;
                dotView.layer.borderColor   = ColorWithHex(0xf8b7b7, 1).CGColor;
                dotView.layer.cornerRadius  = dotV_w / 2;
                dotView.layer.masksToBounds = YES;
                dotView.layer.borderWidth   = 1.5;
                dotView.frame               = CGRectMake(0, 0, dotV_w, dotV_w);
                dotView.center              = CGPointMake((xTMP + i * (dotV_w + 5) + 10), (yTMP + j * (dotV_w + 5) + 10));
                [self addSubview:dotView];
                [self.dots addObject:dotView];
            }
        }
    }
    return self;
}


-(void)refreshWithInfo:(NSArray *)info {
    if (info.count <= 0) {
        for (UIImageView *img in _dots) {
            img.backgroundColor = kClearColor;
        }
        return;
    }
    for (UIImageView *image in _dots) {
        for (UIButton *btn in info) {
            if (image.tag == btn.tag) {
                image.backgroundColor = ColorWithHex(0xFFFFFF, 1);
            }
        }
    }
}

@end
