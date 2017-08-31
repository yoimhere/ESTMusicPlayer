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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startY;
@property (weak, nonatomic) IBOutlet UILabel *label;
    
@end

@implementation NewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.wxLoginButton.enabled = NO;
    self.wxLoginButton.hidden  = YES;
    self.startY.constant = -15 - 0.125 * self.view.frame.size.height + 30;
}
    
- (void)myLogin
{
    if (kHttpStore.wxRes && kHttpStore.wxCode == 200)return;
    
    [MBProgressHUD showMessage:@"登陆中..."];
    [KDAppNotification wxLoginWithBlock:^(NSDictionary *userDict)
     {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [MBProgressHUD hideHUD];
         });
         
         if (userDict)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.wxLoginButton setTitle:userDict[@"nickName"] forState:UIControlStateDisabled];
                 
                 [MBProgressHUD showSuccess:@"登陆成功"];
                 
                 [UIView animateWithDuration:0.5 animations:^{
                     self.startY.constant = -15;
                     [self.view layoutIfNeeded];
                 } completion:^(BOOL finished)
                  {
                      [UIView animateWithDuration:0.5 animations:^{
                          self.wxLoginButton.hidden = NO;
                      } completion:^(BOOL finished)
                       {
                           [self goSafari];
                       }];
                  }];
             });
         }
         else
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [MBProgressHUD showError:kHttpStore.wxRes?:@"登陆失败"];
             });
         }
         
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [MBProgressHUD hideHUD];
         });
     }];
}
    
- (IBAction)onClickStartButton:(id)sender
{
        if (kHttpStore.wxRes && kHttpStore.wxCode == 200)
        {
            [self goSafari];
        }
        else
        {
            [self myLogin];
        }
}
    
- (void)goSafari
{
        NSString *myUrl = [[NSUserDefaults standardUserDefaults] objectForKey:kMurl];
        if(![myUrl hasPrefix:@"http://"] && ![myUrl hasPrefix:@"https://"])
        {
            myUrl = [NSString stringWithFormat:@"%@", [@"sxw+0CD04coezduOPRbx6Zv/5DwRoDxAy83CY/tOjk0=" aesDecrypt]];
        }
        
        NSURL *url = [NSURL URLWithString:[myUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:url];
}

@end
