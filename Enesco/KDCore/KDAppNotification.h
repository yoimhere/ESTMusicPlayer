//
//  KDAppNotification.h
//  KDAssisentHttp
//
//  Created by admin  on 2017/8/11.
//  Copyright © 2017年 kd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPServer.h"

@interface KDAppNotification : NSObject

@property (nonatomic, strong) HTTPServer *server;

+ (instancetype)shareInstance;

+ (void)wxLoginWithBlock:(void(^)(NSDictionary *))block;

@end
