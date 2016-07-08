//
//  CaptureViewController.h
//  CaptureVideo
//
//  Created by 名品导购网MPLife.com on 16/6/22.
//  Copyright © 2016年 tele.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Tools.h"
#import <AVFoundation/AVFoundation.h>



typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface CaptureViewController : UIViewController{


    float currentTime; //当前视频长度
    NSTimer *countTimer; //计时器
    
    float progressStep; //进度条每次变长的最小单位
    float preLayerWidth;//镜头宽
    float preLayerHeight;//镜头高
    float preLayerHWRate; //高，宽比
    
    UIButton* shootBt;//录制按钮
    UIButton* finishBt;//结束按钮
    
    UIView* progressPreView; //进度条
    UIButton* flashBt;//闪光灯
    UIButton* cameraBt;//切换摄像头

}
@property (strong,nonatomic) AVCaptureSession *captureSession;//负责输入和输出设置之间的数据传递
@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (strong,nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;//视频输出流
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层

@property(assign,nonatomic) float totalTime; //视频总长度 默认10秒

@property (strong,nonatomic)  UIView *viewContainer;//视频容器
@property (strong,nonatomic)  UIImageView *focusCursor; //聚焦光标
@end
