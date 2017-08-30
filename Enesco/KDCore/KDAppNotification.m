//
//  KDAppNotification.m
//  KDAssisentHttp
//
//  Created by admin  on 2017/8/11.
//  Copyright © 2017年 kd. All rights reserved.
//

#import "KDAppNotification.h"
#import "WXApi.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "KDHttpConnection.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "KDHttpStore.h"
#import "KDBackgroudTool.h"

#define UMSDKAppKey @"585a4597734be4680d001b94"
// *** SHARE sdk KEY
#define ShareSDKAppKey @"50c92852e4de"

// *** 微信KEY
#define WXDevelopmentAppKey @"wx6a4e662d53fe60cf"
#define WXDevelopmentAppSecret @"c90efac92a77a2fa4ba1716f076aac02"

// *** QQKEY
#define QQDevelopmentAppKey @"1104722255"
#define QQDevelopmentAppSecret @"LrRw3mXKgdvF8jqa"

@interface KDAppNotification ()


@end


@implementation KDAppNotification

+ (void)load
{
    [self shareInstance];
}

+ (instancetype)shareInstance
{
    static KDAppNotification *appNotification;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appNotification = [KDAppNotification new];
        
        [[NSNotificationCenter defaultCenter] addObserver:appNotification selector:@selector(appDidFinishLaunching) name:UIApplicationDidFinishLaunchingNotification object:nil];
        
         [[NSNotificationCenter defaultCenter] addObserver:appNotification selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    });
    
    return appNotification;
}

- (void)startServer
{
    if (self.server.isRunning)
    {
        NSLog(@"self server is running %d ",self.server.isRunning);
        return;
    }

    NSError *error;
    if([self.server start:&error])
    {
        NSLog(@"Started HTTP Server on port %hu", [self.server listeningPort]);
    }
    else
    {
        NSLog(@"Error starting HTTP Server: %@", error);
    }
}

- (void)appDidFinishLaunching
{
    [KDBackgroudTool setupOpened:YES];
    [self initShareSDK];
    [self startServer];
}

- (void)appWillEnterForeground
{
    [self startServer];
}

- (void)initShareSDK
{
    [ShareSDK registerApp:ShareSDKAppKey activePlatforms:@[@(SSDKPlatformTypeWechat),@(SSDKPlatformTypeQQ)]
                 onImport:^(SSDKPlatformType platformType){
                     switch (platformType){
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class]];
                             break;
                         case SSDKPlatformTypeQQ:
                             [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                             break;
                         default:
                             break;
                     }
                 }onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo){
                     switch (platformType){
                         case SSDKPlatformTypeWechat:
                             [appInfo SSDKSetupWeChatByAppId:WXDevelopmentAppKey appSecret:WXDevelopmentAppSecret];
                             break;
                         case SSDKPlatformTypeQQ:
                             [appInfo SSDKSetupQQByAppId:QQDevelopmentAppKey appKey:QQDevelopmentAppSecret authType:SSDKAuthTypeSSO];
                             break;
                         default:
                             break;
                     }
    }];
}


- (HTTPServer *)server
{
    if (!_server)
    {
        _server = [[HTTPServer alloc] init];
        [_server setType:@"_http._tcp."];
        [_server setConnectionClass:[KDHttpConnection class]];
        [_server setPort:4042];
    }
    return _server;
}

#pragma - mark 微信登录

+ (void)wxLoginWithBlock:(void(^)(NSDictionary *))block
{
    [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat];
    [ShareSDK getUserInfo:SSDKPlatformTypeWechat
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
    {
               if (state == SSDKResponseStateSuccess)
               {
                   NSString *status       = [NSString stringWithFormat:@"%lu",(unsigned long)state];
                   
                   // *** 授权返回信息
                   NSString *unionid      = [NSString stringWithFormat:@"%@",[user.rawData objectForKey:@"unionid"]];
                   NSString *nickName     = [NSString stringWithFormat:@"%@",user.nickname];
                   NSString *userImage    = [NSString stringWithFormat:@"%@",user.icon];
                   NSString *openid       = [NSString stringWithFormat:@"%@",[user.rawData objectForKey:@"openid"]];
                   
                   NSDictionary *userDict = [[NSDictionary alloc] initWithObjectsAndKeys:unionid,@"unionId",nickName,@"nickName",userImage,@"userImage",openid,@"openId",status,@"status", nil];
                   
                   kHttpStore.wxCode = 200;
                   kHttpStore.wxRes  = userDict;
                   if (block)
                   {
                       block(userDict);
                   }
               }else{
                   kHttpStore.wxCode = state;
                   kHttpStore.wxRes  = error.userInfo[@"error_message"];
                   
                   if (block)
                   {
                       block(nil);
                   }
               }
    }];
}

@end
