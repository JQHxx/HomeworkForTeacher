//
//  PlayVideoViewController.m
//  Teasing
//
//  Created by vision on 2019/6/19.
//  Copyright © 2019 vision. All rights reserved.
//

#import "PlayVideoViewController.h"
#import "MainVideoPlayer.h"


@interface PlayVideoViewController ()<MainVideoPlayerDelegate>

@property (nonatomic, strong) MainVideoPlayer  *videoPlayer;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIView   *bottomBar;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, assign) BOOL isBarShowing;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation PlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initPlayVideoView];
    [self startPlayVideo];
    
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.view addGestureRecognizer:tapGesture];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"播放视频"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"播放视频"];
}

#pragma mark -- MainVideoPlayerDelegate
#pragma mark 当前播放状态
-(void)player:(MainVideoPlayer *)player statusChanged:(VideoPlayerStatus)status{
    if (status == VideoPlayerStatusPlaying) {
        [self.indicatorView stopAnimating];
        self.playButton.hidden = YES;
        self.pauseButton.hidden = NO;
        self.isBarShowing = YES;
        [self autoFadeOutControlBar];
    }
}

#pragma mark 当前播放进度
-(void)player:(MainVideoPlayer *)player currentTime:(double)currentTime totalTime:(double)totalTime progress:(double)progress{
    MyLog(@"currentTime:%.f,totalTime:%.f,progress:%.f",currentTime,totalTime,progress);
    self.progressSlider.maximumValue = floor(totalTime);
    self.progressSlider.value = ceil(currentTime);
    
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
    
    double minutesRemaining = floor(totalTime / 60.0);;
    double secondsRemaining = floor(fmod(totalTime, 60.0));;
    NSString *timeRmainingString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesRemaining, secondsRemaining];
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeElapsedString,timeRmainingString];
}

#pragma mark -- Event Response
#pragma mark 返回
-(void)leftNavigationItemAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 点击界面
- (void)onTap:(UITapGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.isBarShowing) {
            [self animateHide];
        } else {
            [self animateShow];
        }
    }
}

#pragma mark  播放
-(void)playButtonClickAction{
    if (!self.videoPlayer.isVideoPlaying) {
        [self.videoPlayer resumePlay];
        self.playButton.hidden = YES;
        self.pauseButton.hidden = NO;
    }
}

#pragma mark 暂停播放
-(void)pauseButtonClickAction{
    if (self.videoPlayer.isVideoPlaying) {
        [self.videoPlayer pausePlay];
        self.playButton.hidden = NO;
        self.pauseButton.hidden = YES;
    }
}

#pragma mark -- Private Methods
#pragma mark 初始化
-(void)initPlayVideoView{
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.bottomBar];
    
    [self.bottomBar addSubview:self.playButton];
    [self.bottomBar addSubview:self.pauseButton];
    self.pauseButton.hidden = YES;
    [self.bottomBar addSubview:self.progressSlider];
    [self.bottomBar addSubview:self.timeLabel];
    
    [self.view addSubview:self.indicatorView];
    self.indicatorView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

#pragma mark 播放视频
-(void)startPlayVideo{
    // 移除原来的播放
    if (self.videoPlayer) {
        [self.videoPlayer removeVideo];
    }
    [self.videoPlayer playVideoWithView:self.view url:self.videoUrl];
    
    [self.indicatorView startAnimating];
}

#pragma mark 隐藏播放操作
- (void)animateHide{
    if (!self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.backButton.alpha = 0.0;
        self.bottomBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = NO;
    }];
}

#pragma mark 显示播放操作
- (void)animateShow{
    if (self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.backButton.alpha = 1.0;
        self.bottomBar.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = YES;
        [self autoFadeOutControlBar];
    }];
}

#pragma mark 5秒后自动隐藏
- (void)autoFadeOutControlBar{
    if (!self.isBarShowing) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
    [self performSelector:@selector(animateHide) withObject:nil afterDelay:5.0];
}

#pragma mark -- Getters
#pragma mark 播放器
-(MainVideoPlayer *)videoPlayer{
    if (!_videoPlayer) {
        _videoPlayer = [[MainVideoPlayer alloc] init];
        _videoPlayer.delegate = self;
    }
    return _videoPlayer;
}

#pragma mark 返回
-(UIButton *)backButton{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"return_white"] forState:UIControlStateNormal];
        _backButton.frame = CGRectMake(10,KStatusHeight, 40 , 40);
        [_backButton addTarget:self action:@selector(leftNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

#pragma mark 底部视图
- (UIView *)bottomBar{
    if (!_bottomBar) {
        _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-40, kScreenWidth, 40)];
        _bottomBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _bottomBar;
}

#pragma mark 播放按钮
- (UIButton *)playButton{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"kr-video-player-play"] forState:UIControlStateNormal];
        _playButton.frame = CGRectMake(10, 0, 40 , 40);
        [_playButton addTarget:self action:@selector(playButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

#pragma mark 暂停按钮
- (UIButton *)pauseButton{
    if (!_pauseButton) {
        _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseButton setImage:[UIImage imageNamed:@"kr-video-player-pause"] forState:UIControlStateNormal];
        _pauseButton.frame = CGRectMake(10, 0, 40, 40);
        [_pauseButton addTarget:self action:@selector(pauseButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseButton;
}

#pragma mark 进度条
- (UISlider *)progressSlider{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(self.playButton.right+5, 15, kScreenWidth-self.playButton.right-60, 10)];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"kr-video-player-point"] forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
        [_progressSlider setMaximumTrackTintColor:[UIColor lightGrayColor]];
        _progressSlider.value = 0.f;
        _progressSlider.continuous = YES;
    }
    return _progressSlider;
}

#pragma mark 播放时长
- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont regularFontWithSize:10.0f];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.frame = CGRectMake(self.progressSlider.right+10, 10, 45, 20);
        _timeLabel.text = @"00:00";
    }
    return _timeLabel;
}

- (UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_indicatorView stopAnimating];
    }
    return _indicatorView;
}

@end
