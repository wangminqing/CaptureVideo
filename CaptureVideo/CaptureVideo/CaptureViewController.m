//
//  CaptureViewController.m
//  CaptureVideo
//
//  Created by 名品导购网MPLife.com on 16/6/22.
//  Copyright © 2016年 tele.com. All rights reserved.
//

#import "CaptureViewController.h"

@interface CaptureViewController ()<AVCaptureFileOutputRecordingDelegate>
//视频文件输出代理

@end

@implementation CaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    [self createVideoFolderIfNotExist];
    [self initSubView];
    [self initCapture];
    [self initCapturePreview];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.captureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.captureSession stopRunning];
    
    //还原数据-----------
    //[self deleteAllVideos];
    currentTime = 0;
    [progressPreView setFrame:CGRectMake(0, preLayerHeight, 0, 4)];
    shootBt.backgroundColor = UIColorFromRGB(0xfa5f66);
    finishBt.hidden = YES;
}

-(void)initCapture{

    //初始化会话
    _captureSession=[[AVCaptureSession alloc]init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {//设置分辨率
        _captureSession.sessionPreset=AVCaptureSessionPreset640x480;
    }
    //获得输入设备
    AVCaptureDevice *captureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    //添加一个音频输入设备
    AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];

    NSError *error=nil;
    //根据输入设备初始化设备输入对象，用于获得输入数据
    _captureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
    AVCaptureDeviceInput *audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
    
    //初始化设备输出对象，用于获得输出数据
    _captureMovieFileOutput=[[AVCaptureMovieFileOutput alloc]init];
    
    //将设备输入添加到会话中
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
        [_captureSession addInput:audioCaptureDeviceInput];
        AVCaptureConnection *captureConnection=[_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoStabilizationSupported ]) {
            captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
        }
    }
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
        [_captureSession addOutput:_captureMovieFileOutput];
    }

}
-(void)initSubView{

    self.viewContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, preLayerWidth, preLayerHeight+10)];
    [self.view addSubview:self.viewContainer];
    
    self.focusCursor = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 50, 50)];
    [self.focusCursor setImage:[UIImage imageNamed:@"focusImg"]];
    self.focusCursor.alpha = 0;
    [self.viewContainer addSubview:self.focusCursor];


    UIView *btView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 86, 86)];
    btView.center = CGPointMake(kScreenWidth/2, (kScreenHeight-64-preLayerHeight-10)/2+preLayerHeight);
    [btView makeCornerRadius:43 borderColor:nil borderWidth:0];
    btView.backgroundColor = UIColorFromRGB(0xeeeeee);
    [self.view addSubview:btView];
    
    shootBt = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 76, 76)];
    shootBt.center = CGPointMake(43, 43);
    shootBt.backgroundColor = UIColorFromRGB(0xfa5f66);
    [shootBt addTarget:self action:@selector(shootButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [shootBt makeCornerRadius:38 borderColor:UIColorFromRGB(0x28292b) borderWidth:3];
    [btView addSubview:shootBt];
    
    finishBt = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    finishBt.center = CGPointMake(kScreenWidth-35, (kScreenHeight-64-preLayerHeight-10)/2+preLayerHeight);
    finishBt.adjustsImageWhenHighlighted = NO;
    [finishBt setBackgroundImage:[UIImage imageNamed:@"shootFinish"] forState:UIControlStateNormal];
    [finishBt addTarget:self action:@selector(finishBtTap) forControlEvents:UIControlEventTouchUpInside];
    finishBt.hidden = NO;
    [self.view addSubview:finishBt];
}

-(void)initCapturePreview{

    //创建视频预览层，用于实时展示摄像头状态
    _captureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    
    CALayer *layer= self.viewContainer.layer;
    layer.masksToBounds=YES;
    
    _captureVideoPreviewLayer.frame=  CGRectMake(0, 0, preLayerWidth, preLayerHeight);
    _captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
    [layer insertSublayer:_captureVideoPreviewLayer below:self.focusCursor.layer];
    
    //进度条
    progressPreView = [[UIView alloc]initWithFrame:CGRectMake(0, preLayerHeight, 0, 4)];
    progressPreView.backgroundColor = UIColorFromRGB(0xffc738);
    [progressPreView makeCornerRadius:2 borderColor:nil borderWidth:0];
    [self.viewContainer addSubview:progressPreView];
    
    flashBt = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth-90, 5, 34, 34)];
    [flashBt setBackgroundImage:[UIImage imageNamed:@"flashOn"] forState:UIControlStateNormal];
    [flashBt makeCornerRadius:17 borderColor:nil borderWidth:0];
    [flashBt addTarget:self action:@selector(flashBtTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewContainer addSubview:flashBt];
    
    cameraBt = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth-40, 5, 34, 34)];
    [cameraBt setBackgroundImage:[UIImage imageNamed:@"changeCamer"] forState:UIControlStateNormal];
    [cameraBt makeCornerRadius:17 borderColor:nil borderWidth:0];
    [cameraBt addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewContainer addSubview:cameraBt];
}

#pragma mark 视频录制
- (void)shootButtonClick{
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection=[self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //根据连接取得设备输出的数据
    if (![self.captureMovieFileOutput isRecording]) {
        shootBt.backgroundColor = UIColorFromRGB(0xfa5f66);
        //预览图层和视频方向保持一致
        captureConnection.videoOrientation=[self.captureVideoPreviewLayer connection].videoOrientation;
        [self.captureMovieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:[self getVideoSaveFilePathString]] recordingDelegate:self];
    }
    else{
        [self stopTimer];
        [self.captureMovieFileOutput stopRecording];//停止录制
    }
}


-(void)flashBtTap:(UIButton*)bt{
    if (bt.selected == YES) {
        bt.selected = NO;
        //关闭闪光灯
        [flashBt setBackgroundImage:[UIImage imageNamed:@"flashOn"] forState:UIControlStateNormal];
        [self setTorchMode:AVCaptureTorchModeOff];
    }else{
        bt.selected = YES;
        //开启闪光灯
        [flashBt setBackgroundImage:[UIImage imageNamed:@"flashOff"] forState:UIControlStateNormal];
        [self setTorchMode:AVCaptureTorchModeOn];
    }
}

-(void)finishBtTap{
    
    currentTime=self.totalTime+10;
    [countTimer invalidate];
    countTimer = nil;
    
    //正在拍摄
    if (_captureMovieFileOutput.isRecording) {
        [_captureMovieFileOutput stopRecording];
    }else{//已经暂停了
        //[self mergeAndExportVideosAtFileURLs:urlArray];
    }
   // [self uploadVideoInformation];
}


#pragma mark 切换前后摄像头
- (void)changeCamera:(UIButton*)bt {
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition=AVCaptureDevicePositionFront;
    if (currentPosition==AVCaptureDevicePositionUnspecified||currentPosition==AVCaptureDevicePositionFront) {
        toChangePosition=AVCaptureDevicePositionBack;
        flashBt.hidden = NO;
    }else{
        flashBt.hidden = YES;
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.captureSession beginConfiguration];
    //移除原有输入对象
    [self.captureSession removeInput:self.captureDeviceInput];
    //添加新的输入对象
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.captureDeviceInput=toChangeDeviceInput;
    }
    //提交会话配置
    [self.captureSession commitConfiguration];
    
    //关闭闪光灯
    flashBt.selected = NO;
    [flashBt setBackgroundImage:[UIImage imageNamed:@"flashOn"] forState:UIControlStateNormal];
    [self setTorchMode:AVCaptureTorchModeOff];
    
}


//设置闪光灯
-(void)setTorchMode:(AVCaptureTorchMode )torchMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isTorchModeSupported:torchMode]) {
            [captureDevice setTorchMode:torchMode];
        }
    }];
}
//设置焦点
-(void)setFocusMode:(AVCaptureFocusMode )focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}
//设置前后摄像头
-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

#pragma mark - 私有方法
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}

//录制保存的时候要保存为 mov
//录制保存的时候要保存为 mov
- (NSString *)getVideoSaveFilePathString
{
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *path = [paths objectAtIndex:0];
    
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mov"];
    
    return fileName;
}

- (void)createVideoFolderIfNotExist
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *folderPath = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建保存视频文件夹失败");
        }
    }
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
        [_captureMovieFileOutput stopRecording];
    }
    
}


#pragma mark - 视频输出代理
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"开始录制...");
    [self startTimer];
}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    
    if (currentTime>=self.totalTime) {
       // [self mergeAndExportVideosAtFileURLs:urlArray];
    }
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
