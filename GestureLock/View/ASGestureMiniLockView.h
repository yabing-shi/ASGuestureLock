//
//  JYGestureMiniLockView.h
//  JYFinance
//
//  Created by shiyabing on 16/8/5.
//  Copyright © 2016年 xiangshang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JYGestureMiniLockView : UIView{
    NSInteger tag;

}

@property (nonatomic, strong) NSMutableArray * dots;


-(void)refreshWithInfo:(NSArray *)info;


@end
