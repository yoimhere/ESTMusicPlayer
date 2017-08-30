//
//  ATMInfoHelper.m
//  ATMAssistant
//
//  Created by admin  on 2017/6/13.
//  Copyright © 2017年 admin . All rights reserved.
//

#import "KDInfoHelper.h"
#import "YYModel.h"

@interface KDInfoHelper ()

@end

//0.@"LSApplicationWorkspace"
//1.@"defaultWorkspace"
//2.@"allInstalledApplications"
//3.@"bundleType"
//4.@"bundleIdentifier"
//5.@"localizedName"
//6.@"applicationProxyForIdentifier:"
//7.@"isInstalled"
//8.@"registeredDate"
//9.@"containerURL"
//10.@"openApplicationWithBundleID:"
//11.@"LSApplicationProxy"
//12.@"storeCohortMetadata"

#define kAppWorkSpaceClz     NSClassFromString(args[0])
#define kAppWorkDef          NSSelectorFromString(args[1])
#define kAppInstalled        NSSelectorFromString(args[2])
#define kBDType              NSSelectorFromString(args[3])
#define kBDID                NSSelectorFromString(args[4])
#define kAppLocalizedName    NSSelectorFromString(args[5])
#define kAppProxyByID        NSSelectorFromString(args[6])
#define kAppIsInstalled      NSSelectorFromString(args[7])
#define kAppRegisteredDate   NSSelectorFromString(args[8])
#define kAppContainerURL     NSSelectorFromString(args[9])
#define kAppOpenWithID       NSSelectorFromString(args[10])
#define kAppProxyClz         NSClassFromString(args[11])
#define kStoreMetadata       NSSelectorFromString(args[12])

@implementation KDInfoHelper

+ (instancetype)shareInstance
{
    static KDInfoHelper *infoHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        infoHelper = [KDInfoHelper new];
    });
    
    return infoHelper;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

- (NSArray *)userListWithargs:(NSArray *)args
{
    NSMutableArray *userList = [NSMutableArray array];

    NSArray *items = [[kAppWorkSpaceClz performSelector:kAppWorkDef] performSelector:kAppInstalled];
    
    for (id item in items)
    {
        NSString *bundleType = [item performSelector:kBDType];
        if ([[bundleType lowercaseString] containsString:@"user"])
        {
            NSString *bundleID = [item performSelector:kBDID];
            NSString *appName = [item performSelector:kAppLocalizedName];
            
            KDAp *ap = [KDAp new];
            ap.bundleid = bundleID;
            ap.appname = appName;
            [userList addObject:ap];
        }
    }
    return userList;
}

- (NSString *)isFirstithID:(NSString *)ID args:(NSArray *)args
{
    KDAp *ap = [self apWithID:ID args:args];
    NSTimeInterval installedTime =  [ap.itime floatValue];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval duration = nowTime - installedTime;
    if (duration > 0 && duration < 60 * 60 * 24) {
        return @"1";
    }
    
    return @"0";
}

- (NSString *)isInstalledID:(NSString *)ID args:(NSArray *)args
{
    KDAp *ap = [self apWithID:ID args:args];
    return  [ap.isInstalled isEqualToString:@"1"] ? @"1":@"0";
}

- (KDAp *)apWithID:(NSString *)ID args:(NSArray *)args
{
    KDAp *atm = [KDAp new];


    atm.bundleid = ID;
    if (![ID isKindOfClass:[NSString class]] || ID.length == 0)
    {
        atm.isInstalled = @"0";
        return atm;
    }
    
    id appProxy = [kAppProxyClz performSelector:kAppProxyByID withObject:ID];
    if (![appProxy performSelector:kAppIsInstalled])
    {
        atm.isInstalled = @"0";
        return atm;
    }
    
    if (atm.itime.length == 0)
    {
        //7|date=1499245200000&sf=143465&pgtp=Search&prpg=Search&ctxt=Search&issrch=1
        NSString *timerStr = [appProxy performSelector:kStoreMetadata];
        if (timerStr.length > 0)
        {
            NSString *regexString = @"date=(\\w+)&";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray * matches = [regex matchesInString:timerStr options:0 range:NSMakeRange(0, [timerStr length])];
            for (NSTextCheckingResult *match in matches)
            {
                NSInteger count = [match numberOfRanges];
                for (NSInteger i = count - 1 ; i < count;)
                {
                    NSString *component = [timerStr substringWithRange:[match rangeAtIndex:i]];
                    if ([component floatValue] > 10000)
                    {
                        atm.appname = [appProxy performSelector:kAppLocalizedName];
                        atm.itime = component;
                        atm.isInstalled = @"1";
                    }
                    break;
                }
            }
        }
    }
    
    if (atm.itime.length == 0)
    {
        NSString *bundleIDSanboxHomeDirectory = [[appProxy performSelector:kAppContainerURL] path];
        bundleIDSanboxHomeDirectory = [bundleIDSanboxHomeDirectory substringFromIndex:8];
        if ([[NSFileManager defaultManager] fileExistsAtPath:bundleIDSanboxHomeDirectory])
        {
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:bundleIDSanboxHomeDirectory error:nil];
            if ([fileAttributes objectForKey:NSFileCreationDate])
            {
                NSTimeInterval itime = [[fileAttributes objectForKey:NSFileCreationDate] timeIntervalSince1970];
                atm.appname = [appProxy performSelector:kAppLocalizedName];;
                atm.itime = [NSString stringWithFormat:@"%f",itime];
                atm.isInstalled = @"1";
            }
        }
    }

    if (atm.itime.length == 0)
    {
        //iOS 10
        SEL registeredDateSEL = kAppRegisteredDate;
        if ([appProxy respondsToSelector:registeredDateSEL])
        {
            NSDate *registeredDate = [appProxy performSelector:registeredDateSEL];
            atm.appname = [appProxy performSelector:kAppLocalizedName];;
            atm.itime = [NSString stringWithFormat:@"%f",[registeredDate timeIntervalSince1970]];
            atm.isInstalled = @"1";
        }
    }

    return atm;
}

- (BOOL)openAp:(NSString *)bundleID args:(NSArray *)args
{
   return  [[kAppWorkSpaceClz performSelector:kAppWorkDef] performSelector:kAppOpenWithID withObject:[bundleID copy]];
}

#pragma clang diagnostic pop
#pragma clang diagnostic pop

@end
