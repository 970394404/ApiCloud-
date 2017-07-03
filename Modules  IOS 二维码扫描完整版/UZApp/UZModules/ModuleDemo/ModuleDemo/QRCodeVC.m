//
//  QRCodeVC.m
//  shikeApp
//
//  Created by 淘发现4 on 16/1/7.
//  Copyright © 2016年 淘发现1. All rights reserved.
//

#import "QRCodeVC.h"
#import <AVFoundation/AVFoundation.h>
#import "QRCodeAreaView.h"
#import "QRCodeBacgrouView.h"
#import "UIViewExt.h"


#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height

@interface QRCodeVC()<AVCaptureMetadataOutputObjectsDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate>{
    AVCaptureSession * session;//输入输出的中间桥梁
    QRCodeAreaView *_areaView;//扫描区域视
    
    BOOL LightOn;
    AVCaptureDevice *device;
    
    NSInteger _cbId;
    UIView * diview;
    NSString * tfstr;//手动输入的数据
    
}

@property (nonatomic,strong)UITableView * tableView;

@property (nonatomic,strong)NSMutableArray *listAry ;
@property (nonatomic,assign)BOOL on;

@end

@implementation QRCodeVC

-(void)viewDidLoad{
    [super viewDidLoad];
    
    _listAry=[[NSMutableArray alloc]init];
    
    
    
    //扫描区域
    //CGRect areaRect = CGRectMake((screen_width - 218)/2, (screen_height - 218)/2, 218, 218);
    CGRect areaRect = CGRectMake(30,100,screen_width-60, 120);
    //半透明背景
    QRCodeBacgrouView *bacgrouView = [[QRCodeBacgrouView alloc]initWithFrame:self.view.bounds];
    bacgrouView.scanFrame = areaRect;
    [self.view addSubview:bacgrouView];
    
    //设置扫描区域
    _areaView = [[QRCodeAreaView alloc]initWithFrame:areaRect];
    [self.view addSubview:_areaView];
    
    //提示文字
    UILabel *label = [UILabel new];
    label.text = @"将二维码放入框内，即开始扫描";
    label.textColor = [UIColor whiteColor];
    label.y = CGRectGetMaxY(_areaView.frame) + 20;
    [label sizeToFit];
    label.center = CGPointMake(_areaView.center.x, label.center.y);
    [self.view addSubview:label];
    
    //返回键
    UIButton *backbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    backbutton.frame = CGRectMake(12, 26, 42, 42);
    [backbutton setBackgroundImage:[UIImage imageNamed:@"prev"] forState:UIControlStateNormal];
    [backbutton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backbutton];
    
    //确认键
    UIButton * yesbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    yesbutton.frame=CGRectMake(self.view.frame.size.width-70, 26, 60, 38);
    [yesbutton setTitle:@"确认" forState:UIControlStateNormal];
    yesbutton.backgroundColor=[[UIColor grayColor]colorWithAlphaComponent:0.65];
    [yesbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [yesbutton addTarget:self action:@selector(gojsweb) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:yesbutton];
    
    
    //表格展示输出数据
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, label.y+80, screen_width,self.view.frame.size.height-(label.frame.size.height+_areaView.frame.size.height)-250) style:UITableViewStyleGrouped];
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];
    
    
    //底部按钮
    UIButton * witbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    witbtn.frame=CGRectMake(0, self.view.frame.size.height-60, self.view.frame.size.width/2, 60);
    witbtn.backgroundColor=[[UIColor grayColor]colorWithAlphaComponent:0.65];
    [witbtn setTitle:@"手动输入" forState:UIControlStateNormal];
    [witbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [witbtn addTarget:self action:@selector(witdtnt) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:witbtn];
    
    UILabel * lab=[[UILabel alloc]init];
    lab.frame=CGRectMake(self.view.frame.size.width/2-0.5, witbtn.frame.origin.y, 1, 60);
    lab.backgroundColor=[[UIColor whiteColor]colorWithAlphaComponent:0.65];
    [self.view addSubview:lab];
    
    
    UIButton * dowbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    dowbtn.frame=CGRectMake(self.view.frame.size.width/2, witbtn.frame.origin.y, witbtn.frame.size.width, 60);
    dowbtn.backgroundColor=[[UIColor grayColor]colorWithAlphaComponent:0.65];
    [dowbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [dowbtn setTitle:@"打开照明设备" forState:UIControlStateNormal];
    [dowbtn addTarget:self action:@selector(zhaomingbtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dowbtn];
    
    
    //text
    UITextField *test = [[UITextField alloc]init] ;
    test.delegate = self;
    
    /**
     *  初始化二维码扫描
     */
    
    //获取摄像设备
    AVCaptureDevice * devices = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:devices error:nil];
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置识别区域
    //深坑，这个值是按比例0~1设置，而且X、Y要调换位置，width、height调换位置
    output.rectOfInterest = CGRectMake(_areaView.y/screen_height, _areaView.x/screen_width, _areaView.height/screen_height, _areaView.width/screen_width);
    
    //初始化链接对象
    session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [session addInput:input];
    [session addOutput:output];
    
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;

    [self.view.layer insertSublayer:layer atIndex:0];

    //开始捕获
    [session startRunning];
    [self initUIIIUI];
    
    //手动输入View
    diview=[[UIView alloc]init];
    diview.frame=CGRectMake(30, 200, screen_width-60, 250);
    diview.backgroundColor=[UIColor whiteColor];
    diview.userInteractionEnabled=YES;
    [self.view addSubview:diview];
    
    
    UILabel * labs=[[UILabel alloc]init];
    labs.backgroundColor=[UIColor clearColor];
    labs.frame=CGRectMake(0, 0, diview.frame.size.width, 50);
    labs.text=@"添加运单号";
    labs.textAlignment=NSTextAlignmentCenter;
    labs.font = [UIFont systemFontOfSize:20];
    labs.textColor=[UIColor grayColor];
    [diview addSubview:labs];
    
    UILabel * labn=[[UILabel alloc]init];
    labn.backgroundColor=[[UIColor lightGrayColor]colorWithAlphaComponent:0.65];
    labn.frame=CGRectMake(0, 50, diview.frame.size.width, 1);
    
    [diview addSubview:labn];
    
    UITextField * texfid=[[UITextField alloc]init];
    texfid.backgroundColor=[UIColor redColor];
    texfid.frame=CGRectMake(20, 90, diview.frame.size.width-40, 90);
    texfid.borderStyle = UITextBorderStyleRoundedRect;
    texfid.autocorrectionType = UITextAutocorrectionTypeYes;
    texfid.placeholder = @"请输入运单号";
    //texfid.secureTextEntry = YES;
    texfid.returnKeyType = UIReturnKeyDone;
    texfid.clearButtonMode = UITextFieldViewModeWhileEditing;
    [texfid setBackgroundColor:[UIColor whiteColor]];
    [texfid addTarget:self action:@selector(huqushuju:) forControlEvents:UIControlEventEditingDidEnd];
    [diview addSubview:texfid];
    
    UIButton * btn1=[UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame=CGRectMake(0, diview.frame.size.height-50, diview.frame.size.width/2, 50);
    [btn1 setTitle:@"取消" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    //btn1.backgroundColor=[UIColor yellowColor];
    [btn1.layer setMasksToBounds:YES];
    [btn1.layer setCornerRadius:0.0]; //设置矩圆角半径
    [btn1.layer setBorderWidth:1.0];   //边框宽度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 217/255.0, 217/255.0, 217/255.0, 1 });
    [btn1 addTarget:self action:@selector(viewbtn1) forControlEvents:UIControlEventTouchUpInside];
    [btn1.layer setBorderColor:colorref];//边框颜色
    
    [diview addSubview:btn1];
    UIButton * btn2=[UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame=CGRectMake(diview.frame.size.width/2, diview.frame.size.height-50, btn1.frame.size.width, 50);
    [btn2.layer setMasksToBounds:YES];
    [btn2.layer setCornerRadius:0.0]; //设置矩圆角半径
    [btn2.layer setBorderWidth:1.0];   //边框宽度
    [btn2.layer setBorderColor:colorref];//边框颜色
    [btn2 setTitle:@"确认" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(viewqueren) forControlEvents:UIControlEventTouchUpInside];
    [diview addSubview:btn2];
    //添加手势点击空白处回收键盘
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap1.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap1];
    
    diview.hidden=YES;
    
}
#pragma mark - 手势
-(void)viewTapped:(UITapGestureRecognizer*)tap1
{
    
    [self.view endEditing:YES];
}

#pragma mark -view 上的方法
-(void)viewqueren
{
    NSLog(@"点击了view的确认按钮");
    
    [_listAry addObject:tfstr];
    [_tableView reloadData];
    diview.hidden=YES;
}
-(void)viewbtn1
{
    NSLog(@"点击了view的取消按钮");
    diview.hidden=YES;
}

-(void)huqushuju:(UITextField *)field
{
    UITextField * tf=field;
    tfstr=[NSString stringWithFormat:@"%@",tf.text];
    NSLog(@"view上的输入===%@",tfstr);
}


-(void)initUIIIUI{
    
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (![device hasTorch]) {
        
        //无手电筒
        NSLog(@"没有手电筒");
        
    }
    
    LightOn = NO;
    
}
#pragma 二维码扫描的回调
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [session stopRunning];//停止扫描
        [_areaView stopAnimaion];//暂停动画
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        
        //输出扫描字符串
        //NSLog(@"%@",metadataObject.stringValue);
        NSString * tabstr=[NSString stringWithFormat:@"%@",metadataObject.stringValue];
        //NSLog(@"扫描到的数据结果====%@",tabstr);
        
        NSMutableArray * datasout=[[NSMutableArray alloc]init];
        [datasout addObject:tabstr];
        
        for (NSString *str in datasout) {
            if (![_listAry containsObject:str]) {
                [_listAry addObject:str];
            }
        }
    
        //NSLog(@"数据源数据===%@",_datasout);
        [_tableView reloadData];
        [session startRunning];
        [_areaView startAnimaion];
    }
}


#pragma mark TableViewDeleate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
/** 设置分区行数 */
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listAry.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * str = @"haha";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    
    

    //为单元格添加内容
    
    cell.textLabel.text =[NSString stringWithFormat:@"%lu. %@",(long)indexPath.row +1,_listAry[indexPath.row]];
    //    NSLog(@"表哥数据源==%@",_datasout);
//    NSLog(@"表格内容===%@",cell.textLabel.text);
    
    cell.textLabel.textColor=[UIColor whiteColor];
    //设置单元格的背景颜色为透明色
    cell.backgroundColor = [UIColor clearColor];
    //设置单元格选中颜色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}
// CELL 将要显示时调用
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //以下代码对cell分割线不对齐做了限制。
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
//cell 可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_listAry removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [tableView reloadData];
}
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}






#pragma mark -设置block,设置要传的值
- (void)text:(newBlock)block
{
    self.block = block;
}

#pragma mark -按钮
//点击返回按钮回调
-(void)clickBackButton{
   //NSString * str=[NSString stringWithFormat:@"%@",_listAry];
    if (self.block != nil) {
        self.block(_listAry);
    }

    [self.navigationController popViewControllerAnimated:YES];
    
}
#pragma mark -确认按钮
-(void)gojsweb
{
 
    //NSString * str=[NSString stringWithFormat:@"%@",_listAry];
    if (self.block != nil) {
        self.block(_listAry);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"点击了确认按钮");
    
}
#pragma mark -手动输入按钮
-(void)witdtnt
{
    NSLog(@"点击了手动输入按钮");
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入单号" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
//    UITextField *txtName = [alert textFieldAtIndex:0];
//    txtName.placeholder = @"请输入单号";
//    [alert show];
    diview.hidden=NO;

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        UITextField *txt = [alertView textFieldAtIndex:0];
        //获取txt内容即可
        NSLog(@"txt 内容==%@",txt.text);
        [_listAry addObject:[NSString stringWithFormat:@"%@",txt.text]];
    }
    
    [_tableView reloadData];
}





-(void)zhaomingbtn
{
    NSLog(@"点击了照明按钮");
    LightOn = !LightOn;
    
    if (LightOn) {
        
        [self turnOn];
        
    }else{
        
        [self turnOff];
        
    }
    
}



-(void) turnOn

{
    
    [device lockForConfiguration:nil];
    
    [device setTorchMode:AVCaptureTorchModeOn];
    
    [device unlockForConfiguration];
    
}

-(void) turnOff

{
    
    [device lockForConfiguration:nil];
    
    [device setTorchMode: AVCaptureTorchModeOff];
    
    [device unlockForConfiguration];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

@end
