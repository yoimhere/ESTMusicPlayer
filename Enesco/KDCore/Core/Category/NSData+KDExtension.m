//
//  NSData+ATMExtension.m
//  ATMCore
//
//  Created by admin  on 2017/6/21.
//  Copyright © 2017年 admin . All rights reserved.
//

#import "NSData+KDExtension.h"
#import "NSString+KDSecurity.h"
#import "KDSecurity.h"

@implementation NSData (KDExtension)

- (id)jsonObject
{
    NSError *error;
    id obj =  [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingAllowFragments error:&error];
    return obj;
}

- (id)aesJsonObject
{
    NSString *dataResult =  [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    NSString *jsonResult = [dataResult aesDecrypt];
    jsonResult = [jsonResult stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    
    NSData *jsonData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
    return jsonData.jsonObject;
}

@end
