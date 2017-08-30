

#import "NetworkType.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
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


static id _st_observer = nil;

@implementation NetworkType{
    CTTelephonyNetworkInfo *_networkInfo;
    TelStatus _status;
}


- (void)dealloc{
    [_st_observer removeObserver:self];
}

+ (instancetype)shareNetworkType{
    static dispatch_once_t onceToken;
    static NetworkType *_st_shared_netlisten = nil;
    dispatch_once(&onceToken, ^{
        _st_shared_netlisten = [self new];
    });
    return _st_shared_netlisten;
}

- (instancetype)init{
    if (self = [super init]){
        _networkInfo = [CTTelephonyNetworkInfo new];
        [self updateStatus];
        [self registerNotification];
    }
    return self;
}

- (void)registerNotification{
    NSNotificationCenter *nitifC = [NSNotificationCenter defaultCenter];
    _st_observer = [nitifC addObserverForName:CTRadioAccessTechnologyDidChangeNotification
                                       object:nil queue:[NSOperationQueue mainQueue]
                                   usingBlock:^(NSNotification *note) {
                                       [self updateStatus];
                                   }];
}

- (void)updateStatus{
    NSString *info = _networkInfo.currentRadioAccessTechnology;
    if ([info isEqualToString:CTRadioAccessTechnologyGPRS]){
        _status = TelStatusGPRS;
    }else if ([info isEqualToString:CTRadioAccessTechnologyEdge]){
        _status = TelStatusEdge;
    }else if ([info isEqualToString:CTRadioAccessTechnologyCDMA1x]){
        _status = TelStatus2G;
    }else if ([info isEqualToString:CTRadioAccessTechnologyWCDMA] ||
              [info isEqualToString:CTRadioAccessTechnologyHSDPA] ||
              [info isEqualToString:CTRadioAccessTechnologyHSUPA] ||
              [info isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
              [info isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
              [info isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
              [info isEqualToString:CTRadioAccessTechnologyeHRPD]){
        _status = TelStatus3G;
    }else if ([info isEqualToString:CTRadioAccessTechnologyLTE]){
        _status = TelStatus4G;
    }else{
        _status = TelStatusNone;
    }
}

- (TelStatus)status{
    return _status;
}

- (NSString *)statusDescripetion{
    switch (_status) {
        case TelStatusGPRS:{
            return @"GPRS";
            break;
        }
        case TelStatusEdge:{
            return @"E";
            break;
        }
        case TelStatus2G:{
            return @"2G";
            break;
        }
        case TelStatus3G:{
            return @"3G";
            break;
        }
        case TelStatus4G:{
            return @"4G";
            break;
        }
        default:
            break;
    }
    return nil;
}

#pragma mark -
+(NSArray*) carrierNameDetails
{
    // ***
    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 8) {
        int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
        size_t miblen = 4;
        
        size_t size;
        int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
        
        struct kinfo_proc * process = NULL;
        struct kinfo_proc * newprocess = NULL;
        do {
            
            size += size / 10;
            newprocess = realloc(process, size);
            
            if (!newprocess){
                
                if (process){
                    free(process);
                }
                
                return nil;
            }
            
            process = newprocess;
            st = sysctl(mib, miblen, process, &size, NULL, 0);
            
        } while (st == -1 && errno == ENOMEM);
        
        if (st == 0){
            
            if (size % sizeof(struct kinfo_proc) == 0){
                int nprocess = size / sizeof(struct kinfo_proc);
                
                if (nprocess){
                    
                    NSMutableArray * array = [[NSMutableArray alloc] init];
                    
                    for (int i = nprocess - 1; i >= 0; i--){
                        
                        NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                        NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                        
                        NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, nil]forKeys:[NSArray arrayWithObjects:@"ProcessID", @"ProcessName", nil]];
                        [array addObject:dict];
                    }
                    
                    free(process);
                    return array;
                }
            }
        }
    }else{
        
    }
    
    return nil;
}


- (NSString *)carrierName{
    return _networkInfo.subscriberCellularProvider.carrierName;
}

- (NSString *)description{
    CTCarrier *c = _networkInfo.subscriberCellularProvider;
    return [NSString stringWithFormat:@"(%@)(%@-%@-%@-%@)",[self statusDescripetion],c.carrierName,c.mobileCountryCode,c.mobileNetworkCode,c.isoCountryCode];
}

@end
