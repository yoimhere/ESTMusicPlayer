//
//  KDHttpStore.h
//  KDAssisentHttp
//
//  Created by admin  on 2017/8/11.
//  Copyright © 2017年 kd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHttpStore [KDHttpStore shareStore]

@interface KDHttpStore : NSObject

+ (instancetype)shareStore;

#pragma - mark 微信登录

@property (nonatomic, assign) NSInteger wxCode;
@property (nonatomic, strong) id wxRes;

@end
