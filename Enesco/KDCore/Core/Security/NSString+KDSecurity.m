//
//  NSString+ATMSecurity.m
//  Weather
//
//  Created by admin  on 2017/7/11.
//  Copyright © 2017年 zhenhui huang. All rights reserved.
//

#import "NSString+KDSecurity.h"
#import "KDSecurity.h"
#import "GTMBase64.h"



@implementation NSString (KDSecurity)

- (NSString *)aesEncrypt
{
    NSData *data = [KDSecurity aes256EncryptWithString:self];
    if (data)
    {
        return  [GTMBase64 stringByEncodingData:data];
    }
    return nil;
}

- (NSString *)aesDecrypt
{
    NSData *data = [GTMBase64 decodeString:self];
    return  [KDSecurity aes256DecryptStringWithData:data];
}

@end
