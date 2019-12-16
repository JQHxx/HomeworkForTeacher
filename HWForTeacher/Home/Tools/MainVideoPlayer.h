//
//  MainVideoPlayer.h
//  Teasing
//
//  Created by vision on 2019/5/28.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, VideoPlayerStatus) {
    VideoPlayerStatusUnload,
    VideoPlayerStatusPrepared,
    VideoPlayerStatusLoading,
    VideoPlayerStatusPlaying,
    VideoPlayerStatusPaused,
    VideoPlayerStatusEnded,
    VideoPlayerStatusError
};

@class MainVideoPlayer;
@protocol MainVideoPlayerDelegate <NSObject>

- (void)player:(MainVideoPlayer *)player statusChanged:(VideoPlayerStatus)status;

- (void)player:(MainVideoPlayer *)player currentTime:(double)currentTime totalTime:(double)totalTime progress:(double)progress;

@end


@interface MainVideoPlayer : NSObject

@property (nonatomic, assign) VideoPlayerStatus      status;

@property (nonatomic,  weak ) id<MainVideoPlayerDelegate>delegate;

@property (nonatomic, assign) BOOL                   isVideoPlaying;

/**
 play video for url
 
 @param playView play view
 @param url play url
 */
- (void)playVideoWithView:(UIView *)playView url:(NSString *)url;

- (void)removeVideo;

/**
 pausePlay
 */
- (void)pausePlay;

/**
 resumePlay
 */
- (void)resumePlay;

/**
 resetPlay
 */
- (void)resetPlay;

@end

