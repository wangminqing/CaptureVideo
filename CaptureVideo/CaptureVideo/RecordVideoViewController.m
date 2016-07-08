//
//  RecordVideoViewController.m
//  CaptureVideo
//
//  Created by 名品导购网MPLife.com on 16/6/23.
//  Copyright © 2016年 tele.com. All rights reserved.
//

#import "RecordVideoViewController.h"

@interface RecordVideoViewController ()

@end

@implementation RecordVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0x1d1e20);
    self.navigationItem.title = @"视频录制";
    if (bIOS7) {
        //iOS7默认开启了全视图布局，视图会填充满整个屏幕，默认是开启的即UIRectEdgeAll。
        //该参数的类型是UIRectEdge的枚举类型，定义了视图的扩展方向。
        self.edgesForExtendedLayout= UIRectEdgeNone;
        //如果你使用了不透明的操作栏，设置edgesForExtendedLayout的时候也请将
        //extendedLayoutIncludesOpaqueBars的值设置为No（默认值是YES）。
        self.extendedLayoutIncludesOpaqueBars = NO;
        //指定一个视图控制器是否出现非全屏，接管的状态栏从外观上呈现的视图控制器控制。默认值YES）
        self.modalPresentationCapturesStatusBarAppearance = NO;
        //如果你不想让scroll view的内容自动调整，将这个属性设为NO（默认值YES）。
        //self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //视频最大时长 默认10秒
    if (self.totalTime==0) {
        self.totalTime =10;
    }
    
    preLayerWidth =kScreenWidth;
    preLayerHeight = kScreenWidth;
    preLayerHWRate =preLayerHeight/preLayerWidth;
    progressStep = kScreenWidth*TIMER_INTERVAL/self.totalTime;
    [self initSubView];
}

-(void)initSubView{
    
    self.viewContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, preLayerWidth, preLayerHeight)];
    [self.view addSubview:self.viewContainer];
    
    [self initRecordVideo];
    
    
    //进度条
    progressPreView = [[UIView alloc]initWithFrame:CGRectMake(0, preLayerHeight, 0, 4)];
    progressPreView.backgroundColor = UIColorFromRGB(0xffc738);
    [progressPreView makeCornerRadius:2 borderColor:nil borderWidth:0];
    [self.view addSubview:progressPreView];
    
    UIView *btView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 86, 86)];
    btView.center = CGPointMake(kScreenWidth/2, (kScreenHeight-64-preLayerHeight)/2+preLayerHeight);
    [btView makeCornerRadius:43 borderColor:nil borderWidth:0];
    btView.backgroundColor = UIColorFromRGB(0xeeeeee);
    [self.view addSubview:btView];
    
    
    shootBt = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 76, 76)];
    shootBt.center = CGPointMake(43, 43);
    shootBt.backgroundColor = UIColorFromRGB(0xfa5f66);
    [shootBt addTarget:self action:@selector(shootButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [shootBt makeCornerRadius:38 borderColor:UIColorFromRGB(0x28292b) borderWidth:3];
    [btView addSubview:shootBt];
    
    finishBt = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    finishBt.center = CGPointMake(kScreenWidth-35, (kScreenHeight-64-preLayerHeight)/2+preLayerHeight);
    finishBt.adjustsImageWhenHighlighted = NO;
    [finishBt setBackgroundImage:[UIImage imageNamed:@"shootFinish"] forState:UIControlStateNormal];
    [finishBt addTarget:self action:@selector(finishBtTap:) forControlEvents:UIControlEventTouchUpInside];
    finishBt.hidden = NO;
    [self.view addSubview:finishBt];
}

-(void)initRecordVideo{
    
    _recordVideo = [[RecordVideo alloc]init];
    _recordVideo.delegate=self;
    [_recordVideo embedLayerWithView:self.viewContainer];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_recordVideo.captureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_recordVideo.captureSession stopRunning];
    
    currentTime = 0;
    [progressPreView setFrame:CGRectMake(0, preLayerHeight, 0, 4)];
    shootBt.backgroundColor = UIColorFromRGB(0xfa5f66);
    finishBt.hidden = YES;
}

-(void)shootButtonClick:(UIButton*)sender{

    [_recordVideo recordButtonClick:sender];
    [self startTimer];
    
}

-(void)startTimer{
    shootBt.backgroundColor = UIColorFromRGB(0xf8ad6a);
    
    countTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    [countTimer fire];
}

-(void)stopTimer{
    shootBt.backgroundColor = UIColorFromRGB(0xfa5f66);
    
    [countTimer invalidate];
    countTimer = nil;
    
}
- (void)onTimer:(NSTimer *)timer
{
    currentTime += TIMER_INTERVAL;
    float progressWidth = progressPreView.frame.size.width+progressStep;
    [progressPreView setFrame:CGRectMake(0, preLayerHeight, progressWidth, 4)];
    if (currentTime>2) {
        finishBt.hidden = NO;
    }
    
    //时间到了停止录制视频
    if (currentTime>=self.totalTime) {
        [countTimer invalidate];
        countTimer = nil;
        [_recordVideo stopRecording];
    }
    
}

#pragma mark - 视频输出代理
-(void)captureVideoStopRecording{
   [self stopTimer];
}
-(void)finishBtTap:(UIButton*)sender{

    currentTime=self.totalTime+10;
    [countTimer invalidate];
    countTimer = nil;
    [_recordVideo stopRecording];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
