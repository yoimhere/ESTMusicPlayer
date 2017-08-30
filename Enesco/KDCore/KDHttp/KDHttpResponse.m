//
//  KDHttpResponse.m
//  KDAssisentHttp
//
//  Created by admin  on 2017/8/11.
//  Copyright © 2017年 kd. All rights reserved.
//

#import "KDHttpResponse.h"

@implementation KDHttpResponse

- (NSDictionary *)httpHeaders
{
    return  @{@"Access-Control-Allow-Origin":@"*"};
}


@end
