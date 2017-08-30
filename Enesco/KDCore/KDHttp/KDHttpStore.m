//
//  KDHttpStore.m
//  KDAssisentHttp
//
//  Created by admin  on 2017/8/11.
//  Copyright © 2017年 kd. All rights reserved.
//

#import "KDHttpStore.h"

@implementation KDHttpStore

+ (instancetype)shareStore
{
    static KDHttpStore *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [KDHttpStore new];
    });
    
    return store;
}


@end
