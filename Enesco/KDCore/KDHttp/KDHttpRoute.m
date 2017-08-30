//
//  KDHttpRoute.m
//  KDAssisentHttp
//
//  Created by admin  on 2017/8/11.
//  Copyright © 2017年 kd. All rights reserved.
//

#import "KDHttpRoute.h"
#import "KDHttpStore.h"
#import "KDInfo.h"
#import "NetworkType.h"
#import "KDHttpResponse.h"
#import "KDInfoHelper.h"
#import "KDAppNotification.h"
#import "YYModel.h"
#import <Photos/Photos.h>
#import <ShareSDK/ShareSDK.h>
#import "NSString+KDExtension.h"
#import "SIAlertView.h"
#import "KDAppNotification.h"

static NSInteger const kMaxSemaphoreTime = 30;
static dispatch_semaphore_t kImageST;
static dispatch_semaphore_t kWxShareST;

static NSString const* kHttpCode    = @"code";//返回码
static NSString const* kHttpMessage = @"msg"; //返回信息
static NSString const* kHttpData    = @"data";//返回数据

//GET  无需参数
static NSString const* kRoutePathForCheck      = @"/check.kd";  //微信登录
static NSString const* kRoutePathForWxLogin    = @"/wx_login.kd";  //微信登录
static NSString const* kRoutePathForInfo       = @"/info.kd";      //设备信息
static NSString const* kRoutePathForProcesses  = @"/processes.kd"; //进程列表

//POST 需要参数
static NSString const* kRoutePathForOpen       = @"/open_app.kd";  //设备信息
static NSString const* kRoutePathForUserList   = @"/user_list.kd"; //已安装设备
static NSString const* kRoutePathForAppInfo    = @"/app_info.kd";  //应用信息
static NSString const* kRoutePathForCopyText   = @"/copy_text.kd"; //拷贝文字
static NSString const* kRoutePathForSaveImage  = @"/save_image.kd";//保存图片
static NSString const* kRoutePathForWxShare    = @"/wx_share.kd";  //分享

@implementation KDHttpRoute

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kImageST   = dispatch_semaphore_create(0);
        kWxShareST = dispatch_semaphore_create(0);
    });
}

+ (NSDictionary *)body:(NSString *)body path:(NSString *)path
{
    if (body.length == 0)
    {
        return [self getDataWithPath:path];
    }
    else
    {
        return [self postBody:body path:path];
    }
}

+ (NSDictionary *)getDataWithPath:(NSString *)path
{
    NSInteger code = 0;
    id data = @"";
    NSString *msg  = @"";

    @try
    {
        //微信登录
        if ([kRoutePathForWxLogin isEqualToString:path])
        {
            if (kHttpStore.wxCode == 200)
            {
                code = kHttpStore.wxCode;
                data   = kHttpStore.wxRes;
            }
            else
            {
                code = kHttpStore.wxCode;
                msg   = kHttpStore.wxRes?:@"请微信授权登录!";
            }
        }
        
        //设备信息
        else if ([kRoutePathForInfo isEqualToString:path])
        {
           code = 200;
           data = [[NSDictionary alloc] initWithObjectsAndKeys:[KDInfo getUserId],@"udid",[KDInfo getIDFA],@"idfa",[KDInfo getMacAddress],@"mac",[KDInfo getOSVersion],@"osversion",[KDInfo getDeviceType],@"deviceType",[KDInfo getYueYuState],@"yueyu",[KDInfo getCardState],@"cardStatus",[KDInfo getLanguageType],@"locale",[KDInfo isVPNConnected],@"vpn",[KDInfo getCarrierName],@"carrierName",[KDInfo getNetworkStatus],@"netowkStatus",[KDInfo getRouterName],@"routerName",[KDInfo getRouterMac],@"routerMac",@"",@"token", nil];
        }
        
        //进程信息
        else if ([kRoutePathForProcesses isEqualToString:path])
        {
            code = 200;
            data =  [NetworkType carrierNameDetails];
        }
        
        //检查
        else if ([kRoutePathForCheck isEqualToString:path])
        {
            if([KDAppNotification shareInstance].server.isRunning)
            {
                code = 200;
            }
            else
            {
                code = 0;
            }
        }
    }
    @catch (NSException *exception)
    {
        code = 500;
        data = nil;
        msg = [exception description];
    }
    @finally
    {
        NSMutableDictionary *res = [NSMutableDictionary dictionary];
        [res setObject:@(code) forKey:kHttpCode];
        [res setObject:data?:@"" forKey:kHttpData];
        [res setObject:msg?:@"" forKey:kHttpMessage];
        
        return res;
    }
}

+ (NSDictionary *)postBody:(NSString *)body path:(NSString *)path
{
    __block NSInteger code = 0;
    __block id data = @"";
    __block NSString *msg  = @"";
    
    @try
    {
        NSDictionary *params = [NSObject _yy_dictionaryWithJSON:body];
        
        //打开应用
        if ([kRoutePathForOpen isEqualToString:path])
        {
             NSString *bundleID  = params[@"bundleID"];
             NSArray  *args      = params[@"args"];
             BOOL isCanOpen =  [kApHelper openAp:bundleID args:args];
            if (isCanOpen) {
                code = 200;
                msg = @"打开成功!";
            }
            else
            {
                code = 0;
                msg = @"打开失败!";
            }
        }
        
        //已安装信息
        else if ([kRoutePathForUserList isEqualToString:path])
        {
            code = 200;

            NSArray  *args      = params[@"args"];
            data  = [kApHelper userListWithargs:args];
        }
        
        //app信息
        else if ([kRoutePathForAppInfo isEqualToString:path])
        {
            code = 200;
            
            NSString *bundleID  = params[@"bundleID"];
            NSArray  *args      = params[@"args"];
            
            KDAp *ap = [kApHelper apWithID:bundleID args:args];
            data  = [ap yy_modelToJSONObject];
        }
        
        //拷贝文字
        else if ([kRoutePathForCopyText isEqualToString:path])
        {
            NSString *copyText  = params[@"text"];
            if (copyText.length > 0)
            {
                code = 200;
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = [NSString stringWithFormat:@"%@",copyText];
            }
            else
            {
                code = 406;
                msg  = @"未设置赋值文字!";
            }
        }
        
        //保存图片
        else if ([kRoutePathForSaveImage isEqualToString:path])
        {
            static NSUInteger imageIndex = -1;
            NSUInteger currentImageIndex =  imageIndex;
            
            code = 0;
            msg  = @"操作超时,请重新保存!";
            
            NSString *imageBase64  = params[@"image"];
      
            //把base64转化成image
            NSData *imagedate = [[NSData alloc]initWithBase64EncodedString:imageBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage * image = [UIImage imageWithData:imagedate];
            if (image)
            {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    //写图片入相册
                    [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                } completionHandler:^(BOOL success, NSError * _Nullable error)
                {
                    @synchronized (self)
                    {
                        if (currentImageIndex == imageIndex)
                        {
                            if (success == 1) {
                                code = 200;
                                msg  = @"保存成功";
                            }else{
                                code = 0;
                                msg  = @"请授权后重新保存!";
                            }
                        }
                        
                        dispatch_semaphore_signal(kImageST);
                    }
                 }];
            }else
            {
                code = 406;
                msg  = @"未找到图片!";
                dispatch_semaphore_signal(kImageST);
            }

            dispatch_semaphore_wait(kImageST, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kMaxSemaphoreTime * NSEC_PER_SEC)));
            @synchronized(self)
            {
                imageIndex++;
            }
        }
        
        //微信分享
        else if([kRoutePathForWxShare isEqualToString:path])
        {                                    
            static NSUInteger shareIndex = -1;
            NSUInteger currentShareIndex =  shareIndex;
            
            code = 1;
            msg  = @"操作超时,请重新分享!";
            
            NSArray  *args      = params[@"args"];
            if (args) {
                NSString *bID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
                [kApHelper openAp:bID args:args];
            }
            
            //获得参数
            NSString *type   = [NSString stringWithFormat:@"%@",params[@"type"]];
            NSString *text   = params[@"text"];
            NSString *image  = params[@"image"]?:@"";
            NSString *title  = params[@"title"];
            NSString *url    = params[@"url"];
            
            NSUInteger sharePlatformType = 0;
            if ([type isEqualToString:@"1"]) {
                sharePlatformType = SSDKPlatformSubTypeWechatTimeline;
            }else if ([type isEqualToString:@"2"]){
                sharePlatformType = SSDKPlatformSubTypeQZone;
            }else if ([type isEqualToString:@"3"]){
                sharePlatformType = SSDKPlatformSubTypeWechatSession;
            }else if ([type isEqualToString:@"4"]){
                sharePlatformType = SSDKPlatformSubTypeQQFriend;
            }
            
            NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
            [shareParams SSDKSetupShareParamsByText:text
                                             images:@[image]
                                                url:[NSURL URLWithString:url]
                                              title:title
                                               type:SSDKContentTypeWebPage];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ShareSDK share:sharePlatformType parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
                 {
                     @synchronized(self)
                     {
                         if (currentShareIndex == shareIndex)
                         {
                             if (state == SSDKResponseStateBegin) {
                                 return ;
                             }
                             
                             if (state == SSDKResponseStateSuccess)
                             {
                                 code = 200;
                                 msg  = @"分享成功!";
                             }else if (state == SSDKResponseStateCancel)
                             {
                                 code = 1;
                                 msg  = @"取消分享!";
                             }else {
                                 code = 0;
                                 msg  = @"分享失败!";
                             }
                             
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),  dispatch_get_global_queue(0, 0), ^{
                                 [self goSfWithArgs:args];
                             });
                             dispatch_semaphore_signal(kWxShareST);
                         }
                         else if(shareIndex - currentShareIndex == 1)
                         {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [SIAlertView appearance].backgroundStyle = SIAlertViewBackgroundStyleSolid;
                                 SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"温馨提示" andMessage:@"分享超时,是否前往Safari?"];
                                 [alertView addButtonWithTitle:@"确定"
                                                          type:SIAlertViewButtonTypeDefault
                                                       handler:^(SIAlertView *alert) {
                                                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                                                               [self goSfWithArgs:args];
                                                           });
                                                       }];
                                 [alertView addButtonWithTitle:@"取消"
                                                          type:SIAlertViewButtonTypeCancel
                                                       handler:nil];
                                 [alertView show];
                             });
                         }
                     }
                 }];
            });
            
           dispatch_semaphore_wait(kWxShareST, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kMaxSemaphoreTime * NSEC_PER_SEC)));
            @synchronized(self)
            {
                shareIndex++;
            }
        }
    } @catch (NSException *exception)
    {
        code = 500;
        data = nil;
        msg = [exception description];
    }@finally
    {
        NSMutableDictionary *res = [NSMutableDictionary dictionary];
        [res setObject:@(code) forKey:kHttpCode];
        [res setObject:data?:@"" forKey:kHttpData];
        [res setObject:msg?:@"" forKey:kHttpMessage];
        
        NSLog(@"code:%ld - msg:%@",(long)code,msg);
        
        
        return res;
    }
}

+ (void)goSfWithArgs:(NSArray *)args
{
    if (args)
    {
        [kApHelper openAp:[@"GjgjQL6/s7N7fwxTRNnSkB8ke0afqYHGCkpFHkUT2Ko=" aesDecrypt] args:args];
    }
}

@end
