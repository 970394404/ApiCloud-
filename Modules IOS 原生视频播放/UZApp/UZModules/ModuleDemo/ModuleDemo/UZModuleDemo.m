//
//  UZModuleDemo.m
//  UZModule
//
//  Created by kenny on 14-3-5.
//  Copyright (c) 2014年 APICloud. All rights reserved.
//

#import "UZModuleDemo.h"
#import "UZAppDelegate.h"
#import "NSDictionaryUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
@interface UZModuleDemo ()
<UIAlertViewDelegate>
{
    NSInteger _cbId;
}

@end

@implementation UZModuleDemo

- (id)initWithUZWebView:(UZWebView *)webView_ {
    if (self = [super initWithUZWebView:webView_]) {
        
    }
    return self;
}

- (void)dispose {
    //do clean
}


-(void)vidplay:(NSDictionary * )paramDict
{
    _cbId = [paramDict integerValueForKey:@"cbId" defaultValue:0];
    NSString *vidurl = [paramDict stringValueForKey:@"vurl" defaultValue:nil];
    NSLog(@"vidurl==%@",vidurl);
 
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:vidurl]];

    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc]init];

    playerVC.player = player;

    [self.viewController presentViewController:playerVC animated:YES completion:nil];
    [playerVC.player play];
    
}

//- (void)showAlert:(NSDictionary *)paramDict {
//    _cbId = [paramDict integerValueForKey:@"cbId" defaultValue:0];
//    NSString *message = [paramDict stringValueForKey:@"msg" defaultValue:nil];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    [alert show];
//}
//
//#pragma mark - UIAlertViewDelegate
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (_cbId > 0) {
//        NSDictionary *ret = @{@"index":@(buttonIndex+1)};
//        [self sendResultEventWithCallbackId:_cbId dataDict:ret errDict:nil doDelete:YES];
//    }
//}
//
@end
