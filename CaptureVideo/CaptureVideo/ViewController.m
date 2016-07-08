//
//  ViewController.m
//  CaptureVideo
//
//  Created by 名品导购网MPLife.com on 16/6/22.
//  Copyright © 2016年 tele.com. All rights reserved.
//

#import "ViewController.h"
#import "CaptureViewController.h"
#import "RecordVideoViewController.h"
#import "WRecordVideoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor=[UIColor whiteColor];
    UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordBtn setBackgroundColor:[UIColor blueColor]];
    recordBtn.frame = CGRectMake((kScreenWidth-200)/2, 200, 200, 40);
    [recordBtn setTitle:@"录 制" forState:UIControlStateNormal];
    [recordBtn addTarget:self action: @selector(recordBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordBtn];
}
-(void)recordBtn:(UIButton*)sender{

    /*CaptureViewController *captureVC=[[CaptureViewController alloc]init];
    captureVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:captureVC animated:YES];*/
    /*RecordVideoViewController *recordVideoVC=[[RecordVideoViewController alloc]init];
    recordVideoVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:recordVideoVC animated:YES];*/
    WRecordVideoViewController *wRecordVideoVC=[[WRecordVideoViewController alloc]init];
    wRecordVideoVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:wRecordVideoVC animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
