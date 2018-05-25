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
    [video previewLayer].frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
    [self.view.layer insertSublayer:[video previewLayer] atIndex:0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
