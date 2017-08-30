//
//  ATMBackTask.m
//  Weather
//
//  Created by admin  on 2017/7/4.
//  Copyright © 2017年 zhenhui huang. All rights reserved.
//

#import "KDBackTask.h"

static KDBackTask *kBackTask;

@interface KDBackTask ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;

@end

@implementation KDBackTask

+ (void)load
{
    if (self == [self class])
    {
        kBackTask = [[KDBackTask alloc] init];
    }
}

- (instancetype)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(destoryTask) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return  self;
}

- (void)appDidEnterBackgroundNotification
{
    UIApplication *app = [UIApplication sharedApplication];
    self.bgTask = [app beginBackgroundTaskWithName:@"keepTask" expirationHandler:^{
        [self destoryTask];
    }];
}

- (void)destoryTask
{
    UIApplication *app = [UIApplication sharedApplication];
    [app endBackgroundTask:self.bgTask];
    self.bgTask = UIBackgroundTaskInvalid;
}

@end
