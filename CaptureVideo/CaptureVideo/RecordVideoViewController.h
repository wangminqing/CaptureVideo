//
//  RecordVideoViewController.h
//  CaptureVideo
//
//  Created by 名品导购网MPLife.com on 16/6/23.
//  Copyright © 2016年 tele.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordVideo.h"

@interface RecordVideoViewController : UIViewController<RecordVideoDelegate>{

    float currentTime; //当前视频长度
    NSTimer *countTimer; //计时器
    
    float progressStep; //进度条每次变长的最小单位
    float preLayerWidth;//镜头宽
    float preLayerHeight;//镜头高
    float preLayerHWRate; //高，宽比
    
    UIButton* shootBt;//录制按钮
    UIButton* finishBt;//结束按钮
    
    UIView* progressPreView; //进度条

}
@property(assign,nonatomic) float totalTime; //视频总长度 默认10秒
@property (strong,nonatomic) UIView *viewContainer;//视频容器
@property(strong,nonatomic)RecordVideo *recordVideo;
@end
