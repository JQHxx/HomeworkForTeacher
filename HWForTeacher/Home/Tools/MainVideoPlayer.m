//
//  MainVideoPlayer.m
//  Teasing
//
//  Created by vision on 2019/5/28.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MainVideoPlayer.h"
#import <TXLiteAVSDK_Player/TXLiveBase.h>
#import <TXLiteAVSDK_Player/TXVodPlayer.h>
#import <TXLiteAVSDK_Player/TXVodPlayListener.h>
#import <AVFoundation/AVFoundation.h>

@interface MainVideoPlayer ()<TXVodPlayListener>

@property (nonatomic, strong) TXVodPlayer  *player;

@property (nonatomic, assign) double       duration;

@property (nonatomic, assign) BOOL         isNeedResume;

@end

@implementation MainVideoPlayer

-(instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

#pragma -- NSNotification
#pragma mark appDidEnterBackground
-(void)appDidEnterBackground:(NSNotification *)notify{
    if (self.status == VideoPlayerStatusLoading || self.status == VideoPlayerStatusPlaying) {
        [self pausePlay];
        self.isNeedResume = YES;
    }
}

#pragma mark appWillEnterForeground
-(void)appWillEnterForeground:(NSNotification *)notify{
    if (self.isNeedResume && self.status == VideoPlayerStatusPaused) {
        self.isNeedResume = NO;
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resumePlay];
        });
    }
}

#pragma mark -- TXVodPlayListener
#pragma mark onPlayEvent
-(void)onPlayEvent:(TXVodPlayer *)player event:(int)EvtID withParam:(NSDictionary *)param{
    switch (EvtID) {
        case PLAY_EVT_CHANGE_RESOLUTION:{
            double width = [param[@"EVT_PARAM1"] doubleValue];
            double height = [param[@"EVT_PARAM2"] doubleValue];
            if (width>height) {
                [player setRenderMode:RENDER_MODE_FILL_EDGE];
            }else{
                [player setRenderMode:RENDER_MODE_FILL_SCREEN];
            }
        }
            break;
        case PLAY_EVT_PLAY_LOADING: {
            if (self.status == VideoPlayerStatusPaused) {
                [self playerStatusChanged:VideoPlayerStatusPaused];
            }else{
                [self playerStatusChanged:VideoPlayerStatusLoading];
            }
        }
            break;
        case PLAY_EVT_PLAY_BEGIN:{
            [self playerStatusChanged:VideoPlayerStatusPlaying];
        }
            break;
        case PLAY_EVT_PLAY_END: {
            if ([self.delegate respondsToSelector:@selector(player:currentTime:totalTime:progress:)]) {
                [self.delegate player:self currentTime:self.duration totalTime:self.duration progress:1.0f];
            }
            [self playerStatusChanged:VideoPlayerStatusEnded];
        }
            break;
        case PLAY_EVT_PLAY_PROGRESS:{
            if (self.status == VideoPlayerStatusPlaying) {
                self.duration = [param[EVT_PLAY_DURATION] doubleValue];
                double currTime = [param[EVT_PLAY_PROGRESS] doubleValue];
                double progress = self.duration == 0?0:currTime/self.duration;
                if ([self.delegate respondsToSelector:@selector(player:currentTime:totalTime:progress:)]) {
                    [self.delegate player:self currentTime:currTime totalTime:self.duration progress:progress];
                }
            }
        }
            break;
        case PLAY_ERR_NET_DISCONNECT:{
            [self playerStatusChanged:VideoPlayerStatusError];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark onNetStatus
-(void)onNetStatus:(TXVodPlayer *)player withParam:(NSDictionary *)param{
    
}

#pragma mark -- Private Methods
#pragma mark playerStatusChanged
-(void)playerStatusChanged:(VideoPlayerStatus)status{
    MyLog(@"playerStatusChanged,status:%ld",status);
    self.status = status;
    if ([self.delegate respondsToSelector:@selector(player:statusChanged:)]) {
        [self.delegate player:self statusChanged:status];
    }
}


#pragma mark -- Public methods
#pragma mark  playVideo
-(void)playVideoWithView:(UIView *)playView url:(NSString *)url{
    MyLog(@"playVideo---url:%@",url);
    [self.player setupVideoWidget:playView insertIndex:0];
    [self playerStatusChanged:VideoPlayerStatusPrepared];
    
    if ([self.player startPlay:url] == 0) {
      
    }else{
        [self playerStatusChanged:VideoPlayerStatusError];
    }
}

#pragma mark stopPlay
-(void)removeVideo{
    [self.player stopPlay];
    [self.player removeVideoWidget];
    [self playerStatusChanged:VideoPlayerStatusUnload];
}

#pragma mark pausePlay
-(void)pausePlay{
    [self playerStatusChanged:VideoPlayerStatusPaused];
    [self.player pause];
}

#pragma mark resumePlay
-(void)resumePlay{
    if (self.status == VideoPlayerStatusPaused) {
        [self.player resume];
        [self playerStatusChanged:VideoPlayerStatusPlaying];
    }
}

#pragma mark resetPlay
-(void)resetPlay{
    [self.player resume];
    [self playerStatusChanged:VideoPlayerStatusPlaying];
}

#pragma mark -- Getters
#pragma mark player
-(TXVodPlayer *)player{
    if (!_player) {
        [TXLiveBase setLogLevel:LOGLEVEL_NULL];
        [TXLiveBase setConsoleEnabled:NO];
        
        _player = [[TXVodPlayer alloc] init];
        _player.vodDelegate = self;
        [_player setRenderMode:RENDER_MODE_FILL_EDGE];
        
    }
    return _player;
}

#pragma mark isVideoPlaying
-(BOOL)isVideoPlaying{
    return self.player.isPlaying;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

@end
