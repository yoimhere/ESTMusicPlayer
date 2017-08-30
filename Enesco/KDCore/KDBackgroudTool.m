//
//  ATMBackgroudTool.m
//  ZJSocketServer
//
//  Created by admin  on 2017/6/12.
//  Copyright © 2017年 admin . All rights reserved.
//

#import "KDBackgroudTool.h"
#import <AVFoundation/AVFoundation.h>

@interface KDBackgroudTool ()

@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation KDBackgroudTool

+ (void)setupOpened:(BOOL)opened
{
    [[self shareInstance] setupOpened:opened];
}

- (void)setupOpened:(BOOL)opened
{
    _opened = opened;
    if (_opened == NO)
    {
        [_player stop];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    return nil;
}

- (instancetype)_init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotice) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterreption) name:AVAudioSessionInterruptionNotification object:nil];
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        [session setActive:YES error:nil];
    }
    return self;
}

- (void)handleInterreption
{
    if(self.player)
    {
        [self.player pause];
    }
    else
    {
        [self.player play];
    }
}

- (void)willResignActiveNotice
{
    if (self.opened)
    {
        [self.player play];
    }
}

- (void)didBecomeActive
{
    if (self.opened)
    {
        [self.player pause];
    }
}

-(void)handleInterreption:(NSNotification *)sender
{
    if(self.opened)
    {
        if (self.player.playing)
        {
            [self.player pause];
        }else{
            [self.player play];
        }
    }
}

- (AVAudioPlayer *)player
{
    if (!_player) {
        NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"silence" ofType:@"wav"];
        NSURL *URLPath = [[NSURL alloc] initFileURLWithPath:musicPath];
        
        NSError *error;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:URLPath error:&error];
                
        self.player.numberOfLoops = -1;
        [self.player prepareToPlay];
    }
    return _player;
}

+ (instancetype)shareInstance
{
    static KDBackgroudTool *tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[self alloc] _init];
    });

    return tool;
}

@end
