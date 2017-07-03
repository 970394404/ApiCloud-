//
//  QRCodeVC.h
//  shikeApp
//
//  Created by 淘发现4 on 16/1/7.
//  Copyright © 2016年 淘发现1. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  类型自定义
 */
// 一会要传的值为NSString类型
typedef void (^newBlock)(NSArray *);

@interface QRCodeVC : UIViewController
// 声明block属性
@property (nonatomic, copy) newBlock block;
// 声明block方法
- (void)text:(newBlock)block;
@end
