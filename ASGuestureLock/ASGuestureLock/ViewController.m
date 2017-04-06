//
//  ViewController.m
//  ASGuestureLock
//
//  Created by shiyabing on 17/4/6.
//  Copyright © 2017年 shiyabing. All rights reserved.
//

#import "ViewController.h"
#import "ASGestureLockController.h"

#define kDeviceWidth           [UIScreen mainScreen].bounds.size.width
#define KDeviceHeight          [UIScreen mainScreen].bounds.size.height
#define GESTUREPASSWORDKEY @"GESTUREPASSWORD"

@interface ViewController (){
    NSString *gesPwd;
}

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    gesPwd = [[NSUserDefaults standardUserDefaults] objectForKey:GESTUREPASSWORDKEY];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10, 100, kDeviceWidth - 20, 30)];
    [button setTitle:@"设置手势密码" forState:UIControlStateNormal];
    [button setTag:10];
    [button setBackgroundColor:[UIColor greenColor]];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button1 = [[UIButton alloc]initWithFrame:CGRectMake(10, 150, kDeviceWidth - 20, 30)];
    [button1 setTitle:@"验证手势密码" forState:UIControlStateNormal];
    [button1 setTag:10];
    [button1 setBackgroundColor:[UIColor greenColor]];
    [button1 addTarget:self action:@selector(click1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2 = [[UIButton alloc]initWithFrame:CGRectMake(10, 200, kDeviceWidth - 20, 30)];
    [button2 setTitle:@"修改手势密码" forState:UIControlStateNormal];
    [button2 setTag:10];
    [button2 setBackgroundColor:[UIColor greenColor]];
    [button2 addTarget:self action:@selector(click2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}

- (void)click{
    if (gesPwd.length != 0) {
        NSLog(@"已设置手势密码");
        return;
    }
    ASGestureLockController *lockView = [[ASGestureLockController alloc] init];
    [self presentViewController:lockView animated:YES completion:nil];
}

- (void)click1{
    if (gesPwd.length == 0) {
        NSLog(@"请先设置手势密码");
        return;
    }
    ASGestureLockController *lockView = [[ASGestureLockController alloc] init];
    lockView.isLoginEntrance = YES;
    [self presentViewController:lockView animated:YES completion:nil];
}

- (void)click2{
    if (gesPwd.length == 0) {
        NSLog(@"请先设置手势密码");
        return;
    }
    ASGestureLockController *lockView = [[ASGestureLockController alloc] init];
    lockView.isLoginEntrance = NO;
    [self presentViewController:lockView animated:YES completion:nil];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
