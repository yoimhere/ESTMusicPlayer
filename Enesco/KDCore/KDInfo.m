//
//  SSDKUserData.m
//  ScoreGame
//
//  Created by 黄裕杰 on 16/9/7.
//  Copyright © 2016年 黄裕杰. All rights reserved.
//

#import "KDInfo.h"
#define DDD "/usr/lib/libMobileGestalt.dylib"
#define kCopyname [[[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:@"TUdDb3B5QW5zd2Vy" options:0]  encoding:NSUTF8StringEncoding] UTF8String]
#define gettype "DieId"

#import "sys/utsname.h"

#include <sys/socket.h> // Per msqr
#include <net/if.h>
#include <net/if_dl.h>

#import <CommonCrypto/CommonDigest.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/machine.h>
#include <sys/resource.h>
#include <sys/vm.h>
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#import "sys/utsname.h"
#import <device/device_types.h>
#include <sys/param.h>
#include <sys/mount.h>
#import  <AdSupport/AdSupport.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Reachability.h"
#import "NetworkType.h"
#import <ifaddrs.h>


#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <Reachability/Reachability.h>

@implementation KDInfo

#pragma mark -
+(NSString*) getUserId
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path1 = @"/System";
    NSString *path2 = @"/Library";
    NSString *path3 = @"/var/mobile/Media/Photos";
    
    NSDictionary *fileAttributes1 = [fileManager attributesOfItemAtPath:path1 error:nil];
    NSDictionary *fileAttributes2 = [fileManager attributesOfItemAtPath:path2 error:nil];
    NSDictionary *fileAttributes3 = [fileManager attributesOfItemAtPath:path3 error:nil];
    
    NSString *creationDate1;
    NSString *creationDate2;
    NSString *creationDate3;
    
    if ([fileAttributes1 objectForKey:NSFileCreationDate]) {
        creationDate1 = [fileAttributes1 objectForKey:NSFileCreationDate];
    }
    
    if ([fileAttributes2 objectForKey:NSFileCreationDate]) {
        creationDate2 = [fileAttributes2 objectForKey:NSFileCreationDate];
    }
    
    if ([fileAttributes3 objectForKey:NSFileCreationDate]) {
        creationDate3 = [fileAttributes3 objectForKey:NSFileCreationDate];
    }
    
    NSString *uuid = [self MD5EncryptionWithStr:[NSString stringWithFormat:@"%@",did()]];
    NSString *_openUDID;
    if (YES) {
        unsigned char result[16];
        const char *cStr = [[[NSProcessInfo processInfo] globallyUniqueString] UTF8String];
        CC_MD5( cStr, strlen(cStr), result );
        _openUDID = [NSString stringWithFormat:
                     @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08lx",
                     result[0], result[1], result[2], result[3],
                     result[4], result[5], result[6], result[7],
                     result[8], result[9], result[10], result[11],
                     result[12], result[13], result[14], result[15],
                     arc4random() % 4294967295];
    }
    return uuid;
}

static NSString* did(void)
{
    NSString *did=nil;
    
    void *gestalt = dlopen(DDD, RTLD_GLOBAL | RTLD_LAZY);
    if (gestalt) {
        CFStringRef (*atmCopyAnswer)(CFStringRef) = (CFStringRef (*)(CFStringRef))(dlsym(gestalt, kCopyname));
        did=CFBridgingRelease(atmCopyAnswer(CFSTR(gettype)));
        dlclose(gestalt);
    }
    return did;
}

+(NSString*) MD5EncryptionWithStr:(NSString*)str{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

#pragma mark -

+(NSString*) getIDFA
{
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

#pragma mark -
+(NSString*) getMacAddress{
    int                    mib[6];
    size_t                len;
    char                *buf;
    unsigned char        *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl    *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return @"";
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return @"";
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return @"";
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return @"";
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    // NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return [outstring uppercaseString];
}

#pragma mark -
+(NSString*) getOSVersion{
    return [NSString stringWithFormat:@"%@",[UIDevice currentDevice].systemVersion];
}

#pragma mark -
+(NSString*) getDeviceType
{
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if (platform == nil) {
        return @"";
    }
    
    return platform;
}


#pragma mark -
#define USER_APP_PATH                 @"/User/Applications/"
#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])
const char* RWXinXiObjectjailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt"
};

+(NSString*) getYueYuState
{
    for (int i=0; i<ARRAY_SIZE(RWXinXiObjectjailbreak_tool_pathes); i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:RWXinXiObjectjailbreak_tool_pathes[i]]]) {
            return @"1";
        }
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH]) {
        return @"1";
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        return @"1";
    }
    NSString*resourcePath22 =@"var/mobile/Library/Preferences/com.saurik.Cydia.plist";
    NSMutableDictionary *rootArray = [NSMutableDictionary dictionaryWithContentsOfFile:resourcePath22 ];
    if (rootArray!=NULL) {
        return @"1";
    }
    return @"0";
}


#pragma mark -
+(NSString*) getCardState{
    //初始化
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    
    if (carrier.carrierName == nil || [carrier.carrierName isEqualToString:@""]) {
        return @"0";
    }else if([carrier.carrierName isEqualToString:@"Carrier"]){
        NetworkType *networkType = [NetworkType shareNetworkType];
        if ([networkType statusDescripetion] == nil ) {
            return @"0";
        }
    }
    
    return @"1";
}
#pragma mark -
+(NSString*) getLanguageType{
    NSString *preferredLang = [NSString stringWithFormat:@"%@_%@",[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode],[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
    return preferredLang;
}

#pragma mark -
+(NSString*) isVPNConnected{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            NSString *string = [NSString stringWithFormat:@"%s" , temp_addr->ifa_name];
            if ([string rangeOfString:@"tap"].location != NSNotFound ||
                [string rangeOfString:@"tun"].location != NSNotFound ||
                [string rangeOfString:@"ppp"].location != NSNotFound){
                return @"1";
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return @"0";
}
#pragma mark -
+(NSString*) getCarrierName{
    //初始化
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    
    if (carrier.carrierName == nil) {
        return @"";
    }
    return carrier.carrierName;
}

+(NSString*) getNetworkStatus
{
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            return @"notNetwork";
            break;
        case ReachableViaWWAN:{
            NetworkType *networkType = [NetworkType shareNetworkType];
            return [networkType statusDescripetion];
            break;
        }
        case ReachableViaWiFi:
            return @"wifi";
            break;
        default:
            break;
    }
    return @"";
}
#pragma mark -
+(NSString*) getRouterName{
    // ***
    NSString *ssid = @"";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            
            ssid = [dict valueForKey:@"SSID"];
            
            if ([ssid rangeOfString:@"&"].location != NSNotFound) {
                ssid = [ssid stringByReplacingOccurrencesOfString:@"&" withString:@""];
            }
            
            return ssid;
        }
    }
    return @"";
}
+(NSString*) getRouterMac{
    // ***
    NSString *mac = @"";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            
            mac = [dict valueForKey:@"BSSID"];
            
            return mac;
        }
    }
    return @"";
}

#pragma mark -
+(NSString*) getAPPBundleId{
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    if (identifier == nil) {
        return @"";
    }
    return [NSString stringWithFormat:@"com%@ngy%@fen14",@".te",@"un.ji"];
}
+(NSString*) getAPPVersion{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    if (appVersion == nil) {
        return @"";
    }
    return appVersion;
}


#pragma mark -
+(NSString*) getBatteryNum{
    UIDevice *device = [UIDevice currentDevice];
    
    device.batteryMonitoringEnabled = YES;
    
    return [NSString stringWithFormat:@"%.0f",device.batteryLevel * 100];
}
+(NSString*) getBatteryStatus{
    UIDevice *device = [UIDevice currentDevice];
    
    device.batteryMonitoringEnabled = YES;
    
    if (device.batteryState == UIDeviceBatteryStateCharging) {
        return @"1";//充电中
    }else if(device.batteryState == UIDeviceBatteryStateFull){
        return @"2";//已充满
    }else if(device.batteryState == UIDeviceBatteryStateUnplugged){
        return @"0";//未充电
    }else{
        return @"3";//未知
    }
}


@end
