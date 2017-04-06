//
//  ASGestureMiniLockView.h
//  ASGuestureLock
//
//  Created by shiyabing on 17/4/6.
//  Copyright © 2017年 shiyabing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASGestureMiniLockView : UIView{
    NSInteger tag;

}

@property (nonatomic, strong) NSMutableArray * dots;


-(void)refreshWithInfo:(NSArray *)info;


@end
