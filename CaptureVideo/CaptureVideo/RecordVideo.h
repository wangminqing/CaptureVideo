//
//  RecordVideo.h
//  CaptureVideo
//
//  Created by 名品导购网MPLife.com on 16/6/23.
//  Copyright © 2016年 tele.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@protocol RecordVideoDelegate;
@interface RecordVideo : NSObject<AVCaptureFileOutputRecordingDelegate>{

    UIView *viewContainer;//视频容器
    UIButton* flashBt;//闪光灯
    UIButton* cameraBt;//切换摄像头
}
@property (strong,nonatomic) AVCaptureSession *captureSession;//负责输入和输出设置之间的数据传递
@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (strong,nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;//视频输出流
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层
@property (strong,nonatomic)  UIImageView *focusCursor; //聚焦光标

@property (nonatomic,assign) NSInteger frameNum;//设置帧数

@property(nonatomic,weak) id <RecordVideoDelegate>delegate;

-(void)embedLayerWithView:(UIView*)view;

-(void)recordButtonClick:(UIButton*)sender;

-(void)startRecord;
-(void)stopRecording;


@end

@protocol RecordVideoDelegate <NSObject>

@optional
//连接取得设备输出的数据停止录制了
-(void)captureVideoStopRecording;

@end
