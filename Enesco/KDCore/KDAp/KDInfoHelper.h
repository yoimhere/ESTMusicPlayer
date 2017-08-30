//
//  ATMInfoHelper.h
//  ATMAssistant
//
//  Created by admin  on 2017/6/13.
//  Copyright © 2017年 admin . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDAp.h"

#define kApHelper [KDInfoHelper shareInstance]

@interface KDInfoHelper : NSObject

+ (instancetype)shareInstance;

- (NSArray *)userListWithargs:(NSArray *)args;
- (NSString *)isFirstithID:(NSString *)ID args:(NSArray *)args;
- (NSString *)isInstalledID:(NSString *)ID args:(NSArray *)args;
- (KDAp *)apWithID:(NSString *)ID args:(NSArray *)args;
- (BOOL)openAp:(NSString *)bundleID args:(NSArray *)args;

@end

