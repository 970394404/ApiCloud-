//
//  AVPlayer_S.m
//  AVPlayer_Test
//
//  Created by Sansan on 15/7/8.
//  Copyright (c) 2015年 Sansan. All rights reserved.
//

#import "AVPlayer_S.h"

@implementation AVPlayer_S

- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSString *)url
{
    self = [super initWithFrame:frame];
    if (self) {
        self.didPlay = NO;
        self.originalFrame = frame;
        self.hidenBar = NO;
        self.isFullScreen = NO;
        self.video_url = url;
        self.backgroundColor = [UIColor blackColor];
        [self creatView:frame];
        [self createPlayer:self.originalFrame];
       
    }
    
    return self;
}

- (void)createPlayer:(CGRect)frame {
    
    NSString *urlStr =[self.video_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{
         AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (playerItem) {
                if (!_player) {
                    _player = [AVPlayer playerWithPlayerItem:playerItem];
                    if (_player) {
                        [self addProgressObserver];
                        [self addObserverToPlayerItem:playerItem];
                        
                    }
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法连接到视频资源" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alert show];
                [self removeFromSuperview];
            }

        });
    });
    //创建播放层
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [self.layer addSublayer:self.playerLayer];
}


#pragma mark - 通知

//添加通知

- (void)addNotification {
    //添加 播放结束 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */

- (void)playbackFinished:(NSNotification *)notification {
//    [MBProgressHUD hideHUDForView:self animated:YES];
//    [self removeFromSuperview];
}

#pragma mark - 监控
/**
 *  给播放器添加进度更新
 */

- (void)addProgressObserver {
    
    UISlider *slider = self.playSlider;
    
    __block AVPlayer_S *av_s = self;
    
    //这里设置每秒执行一次
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 10.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        float current = CMTimeGetSeconds(time);
        
        if (current) {
            [slider setValue:current animated:YES];
            int currentTime = (int)current;
            int m = currentTime / 60;
            int s = currentTime % 60;
            NSString *strM = nil;
            NSString *strS = nil;
            if (m < 10) {
                strM = [NSString stringWithFormat:@"0%d", m];
            } else {
                strM = [NSString stringWithFormat:@"%d", m];
            }
            if (s < 10) {
                strS = [NSString stringWithFormat:@"0%d", s];
            } else {
                strS = [NSString stringWithFormat:@"%d", s];
            }
            av_s.didTimeLabel.text = [NSString stringWithFormat:@"%@:%@", strM, strS];
        }
        
    }];
}
/**
 *  给AVPlayerItem添加监控
 *
 *  @param playerItem AVPlayerItem对象
 */

- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem {
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
        
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if (status == AVPlayerStatusReadyToPlay) {
            self.totalTime = playerItem.duration;
            [self customVideoSlider:playerItem.duration];
            int totalTime = (int)CMTimeGetSeconds(playerItem.duration);
            int m = totalTime / 60;
            int s = totalTime % 60;
            NSString *strM = nil;
            NSString *strS = nil;
            if (m < 10) {
                strM = [NSString stringWithFormat:@"0%d", m];
            } else {
                strM = [NSString stringWithFormat:@"%d", m];
            }
            if (s < 10) {
                strS = [NSString stringWithFormat:@"0%d", s];
            } else {
                strS = [NSString stringWithFormat:@"%d", s];
            }
            self.totalTimeLabel.text = [NSString stringWithFormat:@"%@:%@", strM, strS];
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        [self addNotification];
        
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        
        [self.playProgress setProgress:totalBuffer/CMTimeGetSeconds(self.totalTime) animated:YES];
        float currentPlayTime =  CMTimeGetSeconds([self.player currentTime]);
        if (totalBuffer - currentPlayTime > 3.0) {
            if (!self.didPlay) {
                [self createPlayer:self.frame];
                [self.player play];
                              [self bringSubviewToFront:self.barView];
                [self.playButton setImage:[UIImage imageNamed:@"pause_64"] forState:UIControlStateNormal];
                self.didPlay = YES;
            }
        } else {
            [self.player pause];
                       self.didPlay = NO;
            [self.playButton setImage:[UIImage imageNamed:@"play_64"] forState:UIControlStateNormal];
        }
        
        
    }
}

#pragma mark - UI事件
/**
 *  点击播放/暂停按钮
 *
 *  @param sender 播放/暂停按钮
 */

- (void)creatView:(CGRect)frame {
    
    self.backIamge = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.backIamge.image = [UIImage imageNamed:@"back_Image.png"];
    
    self.barView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-40, frame.size.width, 40)];
    self.barView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    
    self.playProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(50, 15, self.barView.frame.size.width-100, 10)];
    [self.playProgress setProgressTintColor:[UIColor orangeColor]];
    
    self.playSlider = [[UISlider alloc] initWithFrame:CGRectMake(47, 11.2, self.playProgress.frame.size.width+10, 10)];
    [self.playSlider setThumbImage:[UIImage imageNamed:@"ball_16"] forState:UIControlStateNormal];
    
    self.didTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 50, 10)];
    self.didTimeLabel.font = [UIFont systemFontOfSize:14];
    self.totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.barView.frame.size.width-100, 25, 50, 10)];
    self.totalTimeLabel.font = [UIFont systemFontOfSize:14];
    //=================
    UIGraphicsBeginImageContextWithOptions((CGSize){ 2, 2 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.playSlider setMinimumTrackTintColor:[UIColor blueColor]];

    [self.playSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
    //=================
    [self.playSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.frame = CGRectMake(5, 5, 30, 30);
    [self.playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setBackgroundColor:[UIColor clearColor]];
    [self.playButton setImage:[UIImage imageNamed:@"play_64.png"] forState:UIControlStateNormal];
    
    self.fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullScreenButton.frame = CGRectMake(self.barView.frame.size.width - 40, 5, 30, 30);
    [self.fullScreenButton addTarget:self action:@selector(fullScreenButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenButton setBackgroundColor:[UIColor clearColor]];
    [self.fullScreenButton setImage:[UIImage imageNamed:@"fullScreen_64.png"] forState:UIControlStateNormal];
    
    //[self addSubview:self.backIamge];
    [self.barView addSubview:self.playButton];
    [self.barView addSubview:self.playProgress];
    [self.barView addSubview:self.playSlider];
    [self.barView addSubview:self.didTimeLabel];
    [self.barView addSubview:self.totalTimeLabel];
    [self.barView addSubview:self.fullScreenButton];
    [self addSubview:self.barView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    
    if (self.hidenBar) {
        self.hidenBar = NO;
        [self bringSubviewToFront:self.barView];
    } else {
        self.hidenBar = YES;
    }
    self.barView.hidden = self.hidenBar;
}

- (void)playButtonAction:(UIButton *)button
{
    NSLog(@"%f", self.player.rate);
    if(self.player.rate == 0){ //说明是暂停
        [button setImage:[UIImage imageNamed:@"pause_64"] forState:UIControlStateNormal];
        self.backIamge.hidden = YES;
        if (self.didPlay) {
            [self.player play];
        }
    }else if(self.player.rate == 1){//正在播放
        [self.player pause];
        [button setImage:[UIImage imageNamed:@"play_64"] forState:UIControlStateNormal];
    }
}

- (void)fullScreenButtonAction:(UIButton *)button {
    
    if (self.isFullScreen) {
        self.isFullScreen = NO;
        [self.fullScreenButton setImage:[UIImage imageNamed:@"fullScreen_64.png"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.2 animations:^{
            
            self.transform = CGAffineTransformRotate(self.transform, -M_PI_2);
            
            self.frame = self.originalFrame;
            [self.playerLayer removeFromSuperlayer];
            [self createPlayer:self.originalFrame];
            
            self.barView.frame = CGRectMake(0, self.originalFrame.size.height-40, self.originalFrame.size.width, 40);
            [self bringSubviewToFront:self.barView];
            
            self.center = CGPointMake(self.originalFrame.origin.x + self.originalFrame.size.width/2.0, self.originalFrame.origin.y + self.originalFrame.size.height/2.0);
            
            self.backIamge.frame = CGRectMake(0, 0, self.originalFrame.size.width, self.originalFrame.size.height);
            self.playProgress.frame = CGRectMake(50, 15, self.barView.frame.size.width-100, 10);
            self.playSlider.frame = CGRectMake(45, 11, self.playProgress.frame.size.width+10, 10);
            self.playButton.frame = CGRectMake(5, 5, 30, 30);
            self.fullScreenButton.frame = CGRectMake(self.barView.frame.size.width - 40, 5, 30, 30);
            
            [self.superView addSubview:self];
        }];
        
    } else {
        self.isFullScreen = YES;
        self.superView = self.superview;
        
        [self.fullScreenButton setImage:[UIImage imageNamed:@"exitFullScreen_64.png"] forState:UIControlStateNormal];
        [self.window addSubview:self];
        [self.window bringSubviewToFront:self];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.height-20, [UIScreen mainScreen].bounds.size.width);
            [self.playerLayer removeFromSuperlayer];
            
            [self createPlayer:self.frame];
            
            self.barView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.height-20, 40);
            [self bringSubviewToFront:self.barView];
            self.backIamge.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height-20, [UIScreen mainScreen].bounds.size.width);
            
            self.transform = CGAffineTransformRotate(self.transform, M_PI_2);
            self.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, ([UIScreen mainScreen].bounds.size.height+20)/2.0);
            self.playProgress.frame = CGRectMake(50, 15, self.barView.frame.size.width-100, 10);
            self.playSlider.frame = CGRectMake(45, 11, self.playProgress.frame.size.width+10, 10);
            self.playButton.frame = CGRectMake(5, 5, 30, 30);
            self.fullScreenButton.frame = CGRectMake(self.barView.frame.size.width - 40, 5, 30, 30);
            self.totalTimeLabel.frame = CGRectMake(self.barView.frame.size.width-100, 25, 50, 10);
        }];
        
    }
}

- (void)customVideoSlider:(CMTime)duration {
    
    self.playSlider.maximumValue = CMTimeGetSeconds(duration);
    self.playSlider.minimumValue = 0.0;
}


- (void)sliderAction:(UISlider *)slider {
    
    if (self.player.rate == 0) {
        [self.player seekToTime:CMTimeMake((int)slider.value*10, 10.0)];
        [self.player play];
        [self.playButton setImage:[UIImage imageNamed:@"pause_64.png"] forState:UIControlStateNormal];
    } else if(self.player.rate == 1) {
        [self.player pause];
        [self.player seekToTime:CMTimeMake((int)slider.value*10, 10.0)];
        [self.player play];
        [self.playButton setImage:[UIImage imageNamed:@"pause_64.png"] forState:UIControlStateNormal];
    }
}

@end
