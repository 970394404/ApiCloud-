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
#import "AVPlayer_S.h"
@interface UZModuleDemo ()
<UIAlertViewDelegate>
{
    NSInteger _cbId;
}
@property (nonatomic, retain) AVPlayer_S *myVideoPlayer;
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



-(void)divvideoplay:(NSDictionary *)paramDict
{   _cbId = [paramDict integerValueForKey:@"cbId" defaultValue:0];
    NSString *vieurl = [paramDict stringValueForKey:@"videurl" defaultValue:nil];
    NSLog(@"前段传来的视频地址====%@",vieurl);
    self.myVideoPlayer=[[AVPlayer_S alloc]initWithFrame:CGRectMake(0, 0, 300, 300) videoURL:vieurl];
    [self addSubview:self.myVideoPlayer fixedOn:nil fixed:NO];
}




//- (void)showAlert:(NSDictionary *)paramDict {
//    c
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
