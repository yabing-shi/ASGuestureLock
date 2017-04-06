//
//  ASGestureMiniLockView.m
//  ASGuestureLock
//
//  Created by shiyabing on 17/4/6.
//  Copyright © 2017年 shiyabing. All rights reserved.
//

#import "ASGestureMiniLockView.h"

#define ColorWithHex(hex,alph)  [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:(alph)]

@implementation ASGestureMiniLockView

- (id)initWithFrame:(CGRect)frame
{
    CGFloat dotV_w = 20;
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
                dotView.backgroundColor     = [UIColor clearColor];
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
            img.backgroundColor = [UIColor clearColor];
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
