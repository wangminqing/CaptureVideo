//
//  WRecordVideoViewController.m
//  CaptureVideo
//
//  Created by 名品导购网MPLife.com on 16/6/23.
//  Copyright © 2016年 tele.com. All rights reserved.
//

#import "WRecordVideoViewController.h"

@interface WRecordVideoViewController ()

@end

@implementation WRecordVideoViewController

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
    
     isStart = NO;
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
    [self initStartButton];
    
}

-(void)initStartButton{
    startButton = [[StartButton alloc]initWithFrame:CGRectMake(kScreenWidth/4, ((kScreenHeight-64)-preLayerHeight-kScreenWidth/2)/2+preLayerHeight, kScreenWidth/2, kScreenWidth/2)];
    [self.view addSubview:startButton];
    
    //拍摄手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    panGesture.delegate = self;
    [startButton addGestureRecognizer:panGesture];
    UILongPressGestureRecognizer *longPressGeture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(startAction:)];
    longPressGeture.delegate = self;
    longPressGeture.minimumPressDuration = 0.1;
    [startButton addGestureRecognizer:longPressGeture];
}
-(void)initProgress{
    progressLayer = [CALayer layer];
    progressLayer.backgroundColor = [UIColor greenColor].CGColor;
    progressLayer.frame = CGRectMake(0, preLayerHeight, kScreenWidth, 5);
    [self.view.layer addSublayer:progressLayer];
    CABasicAnimation *countTime = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    countTime.toValue = @0;
    countTime.duration = self.totalTime;
    countTime.removedOnCompletion = NO;
    countTime.fillMode = kCAFillModeForwards;
    [progressLayer addAnimation:countTime forKey:@"progressAni"];
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
  
}


-(void)panAction:(UIPanGestureRecognizer*)gestureRecognizer{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if (point.y < preLayerHeight) {
        isCancel = YES;
        progressLayer.backgroundColor = [UIColor redColor].CGColor;
        tipsLabel.text = @"松手取消";
        tipsLabel.textColor = [UIColor whiteColor];
        tipsLabel.backgroundColor = [UIColor redColor];
    }
    else{
        isCancel = NO;
        progressLayer.backgroundColor = [UIColor greenColor].CGColor;
        tipsLabel.text = @"⬆️上移取消";
        tipsLabel.textColor = [UIColor greenColor];
        tipsLabel.backgroundColor = [UIColor clearColor];
    }
}

-(void)startAction:(UILongPressGestureRecognizer*)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        isStart = YES;
        isCancel = NO;
        [startButton disappearAnimation];
        [self initProgress];
        tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2-42, kScreenWidth-30, 84, 20)];
        tipsLabel.font = [UIFont systemFontOfSize:14];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.text = @"⬆️上移取消";
        tipsLabel.textColor = [UIColor greenColor];
        [self.view addSubview:tipsLabel];
        countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
        currentTime = 0;
        NSLog(@"start");
        [_recordVideo startRecord];
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        if (isCancel) {
            NSLog(@"cancel");
            isStart = NO;
            [countTimer invalidate];
            [progressLayer removeFromSuperlayer];
            [tipsLabel removeFromSuperview];
            [startButton appearAnimation];
            [self finishCamera];
            return;
        }
        else{
            if (currentTime < 1) {
                isStart = NO;
                [countTimer invalidate];
                //[imagesArray removeAllObjects];
                [progressLayer removeFromSuperlayer];
                [startButton appearAnimation];
                tipsLabel.text = @"手指不要放开";
                tipsLabel.textColor = [UIColor whiteColor];
                tipsLabel.backgroundColor = [UIColor redColor];
                [UIView animateWithDuration:2.0 animations:^{
                    tipsLabel.alpha = 0;
                } completion:^(BOOL finished) {
                    [tipsLabel removeFromSuperview];
                }];
                return;
            }
            else if(currentTime >=1 && currentTime < self.totalTime){
                [self finishCamera];
            }
        }
    }
}
-(void)countDown:(NSTimer*)timerer{
    currentTime++;
    if (currentTime >= self.totalTime) {
        [self finishCamera];
    }
    NSLog(@"%ld",(long)time);
}



-(void)stopTimer{
   
    [countTimer invalidate];
    countTimer = nil;
    
}

#pragma mark  UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
#pragma mark - 视频输出代理
-(void)captureVideoStopRecording{
    [self stopTimer];
}
-(void)finishCamera{
    
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
