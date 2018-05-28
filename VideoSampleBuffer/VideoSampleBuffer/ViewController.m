//
//  ViewController.m
//  VideoSampleBuffer
//
//  Created by Apple on 2018/5/25.
//  Copyright © 2018年 zhoujiawen. All rights reserved.
//

#import "ViewController.h"
#import "SampleBufferVideo.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    SampleBufferVideo *video = [[SampleBufferVideo alloc] init];
    [video startRuning];
    AVCaptureVideoPreviewLayer *videolayer = [video previewLayer];
    videolayer.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-50,[UIScreen mainScreen].bounds.size.height/2-50,100,100);
    videolayer.cornerRadius = 50;
    [self.view.layer insertSublayer:videolayer atIndex:0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
