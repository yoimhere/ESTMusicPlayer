//
//  SSDKUserData.h
//  ScoreGame
//
//  Created by 黄裕杰 on 16/9/7.
//  Copyright © 2016年 黄裕杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface KDInfo : NSObject

+(NSString*) getUserId;
+(NSString*) getIDFA;
+(NSString*) getMacAddress;
+(NSString*) getOSVersion;
+(NSString*) getDeviceType;
+(NSString*) getYueYuState;
+(NSString*) getCardState;
+(NSString*) getLanguageType;
+(NSString*) isVPNConnected;
+(NSString*) getCarrierName;
+(NSString*) getNetworkStatus;
+(NSString*) getRouterName;
+(NSString*) getRouterMac;
+(NSString*) getAPPBundleId;
+(NSString*) getAPPVersion;
+(NSString*) getBatteryNum;
+(NSString*) getBatteryStatus;


@end
