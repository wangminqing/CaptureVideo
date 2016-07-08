//
//  WRecordVideoViewController.h
//  CaptureVideo
//
//  Created by 名品导购网MPLife.com on 16/6/23.
//  Copyright © 2016年 tele.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordVideo.h"
#import "StartButton.h"
@interface WRecordVideoViewController : UIViewController<RecordVideoDelegate,UIGestureRecognizerDelegate>{
    
    float currentTime; //当前视频长度
    NSTimer *countTimer; //计时器
    
    float progressStep; //进度条每次变长的最小单位
    float preLayerWidth;//镜头宽
    float preLayerHeight;//镜头高
    float preLayerHWRate; //高，宽比
    
    BOOL isStart;
    BOOL isCancel;
    
    CALayer *progressLayer;
    StartButton *startButton;
   
    UILabel *tipsLabel;
    
}
@property(assign,nonatomic) float totalTime; //视频总长度 默认10秒
@property (strong,nonatomic) UIView *viewContainer;//视频容器
@property(strong,nonatomic)RecordVideo *recordVideo;
@end
