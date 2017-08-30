//
//  NewController.m
//  Weather
//
//  Created by admin  on 2017/8/15.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "NewController.h"
#import "KDAppNotification.h"
#import "KDHttpStore.h"
#import "MBProgressHUD+HR.h"
#import "NSString+KDExtension.h"

@interface NewController ()

@property (nonatomic, weak) IBOutlet UIButton *wxLoginButton;
@property (nonatomic, strong) id subView;

@end

@implementation NewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)wxLogin
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD showMessage:@"微信登陆中..."];
    });
    [KDAppNotification wxLoginWithBlock:^(NSDictionary *userDict)
     {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [MBProgressHUD hideHUD];
         });
         if (userDict)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.wxLoginButton setTitle:userDict[@"nickName"] forState:UIControlStateNormal];
                 [MBProgressHUD showSuccess:@"登陆成功"];
             });
         }
         else
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.wxLoginButton setTitle:@"微信登陆" forState:UIControlStateNormal];
                 [MBProgressHUD showError:@"登陆失败"];
             });
         }
     }];
}

- (IBAction)onClickStartButton:(id)sender
{
    if (kHttpStore.wxRes && kHttpStore.wxCode == 200)
    {
        NSString *myUrl = [[NSUserDefaults standardUserDefaults] objectForKey:kMurl];
//        if(![myUrl hasPrefix:@"http://"] && ![myUrl hasPrefix:@"https://"])
//        {
            myUrl = [NSString stringWithFormat:@"http://www.xhebao.com/webapp"];
//        }
//        
        myUrl = [NSString stringWithFormat:@"%@?%@",myUrl,[NSBundle mainBundle].bundleIdentifier];
        
        NSURL *url = [NSURL URLWithString:[myUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请先登录微信" delegate:nil
                          cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil] show];
    }
}


@end
