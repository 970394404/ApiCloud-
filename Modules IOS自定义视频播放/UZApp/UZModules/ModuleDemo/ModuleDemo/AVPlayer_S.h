//
//  AVPlayer_S.h
//  AVPlayer_Test
//
//  Created by Sansan on 15/7/8.
//  Copyright (c) 2015年 Sansan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface AVPlayer_S : UIView

@property (nonatomic, retain) AVPlayer *player;
@property (nonatomic, retain) UIButton *playButton;
@property (nonatomic, retain) UIProgressView *playProgress;
@property (nonatomic, retain) NSString *video_url;
@property (nonatomic, assign) CMTime totalTime;
@property (nonatomic, retain) UISlider *playSlider;
@property (nonatomic, assign) BOOL hidenBar;
@property (nonatomic, retain) UIView *barView;
@property (nonatomic, retain) UIButton *fullScreenButton;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, retain) AVPlayerLayer *playerLayer;
@property (nonatomic, retain) UIImageView *backIamge;
@property (nonatomic, retain) UIView *superView;
@property (nonatomic, retain) UILabel *didTimeLabel;
@property (nonatomic, retain) UILabel *totalTimeLabel;
@property (nonatomic, assign) float loadTime;
@property (nonatomic, assign) BOOL didPlay;

- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSString *)url;
- (void)removeNotification;
- (void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem;

@end
