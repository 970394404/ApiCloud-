//
//  ScanningModel.m
//  ModuleDemo
//
//  Created by quakoo on 2017/7/3.
//  Copyright © 2017年 APICloud. All rights reserved.
//

#import "ScanningModel.h"
#import "UZAppDelegate.h"
#import "NSDictionaryUtils.h"

#import "QRCodeVC.h"
#import "UIViewExt.h"

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height

@interface ScanningModel ()
{
    NSInteger _cbId;
}

@end
@implementation ScanningModel
- (id)initWithUZWebView:(UZWebView *)webView_ {
    if (self = [super initWithUZWebView:webView_]) {
        
        
    }
    return self;
}

- (void)dispose {
    //do clean
}

- (void)scanning:(NSDictionary *)paramDict {
    _cbId = [paramDict integerValueForKey:@"cbId" defaultValue:0];
    QRCodeVC *qvc=[[QRCodeVC alloc]init];
    //NSString * strr=[[NSString alloc]init];
    qvc.block = ^(NSArray *str){
        NSArray * jsstr=[[NSArray alloc]init];
        jsstr = str;
        
        NSData * jsondata=[NSJSONSerialization dataWithJSONObject:jsstr options:NSJSONWritingPrettyPrinted error:nil];
        NSString * tabjsstr=  [[NSString alloc]initWithData:jsondata encoding:NSUTF8StringEncoding];

        NSLog(@"block 传输的数据====%@", tabjsstr);
        if (_cbId > 0)
        {
            NSLog(@"bbbbbb bbbbb");
            
            NSDictionary *ret = @{@"tabstr":tabjsstr};
            [self sendResultEventWithCallbackId:_cbId dataDict:ret errDict:nil doDelete:YES];
        }
        
    };
    
    [self.viewController.navigationController pushViewController:qvc animated:YES];
    NSLog(@"aaaaaaa  aaaaa ");
    
}


@end
