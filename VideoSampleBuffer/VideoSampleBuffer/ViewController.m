//
//  ViewController.m
//  VideoSampleBuffer
//
//  Created by  周家稳 on 2018/5/25.
//  Copyright © 2018年 zhoujiawen. All rights reserved.
//

#import "ViewController.h"
#import "SampleBufferVideo.h"
#import "RecoderEngine.h"
#import "Common.h"

#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<SampleBufferVideoDelegate>
{
    
}
@property (nonatomic, strong) RecoderEngine *recoderEngine;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    SampleBufferVideo *video = [[SampleBufferVideo alloc] init];
    video.delegate = self;
    [video startRuning];
    AVCaptureVideoPreviewLayer *videolayer = [video previewLayer];
    videolayer.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-50,[UIScreen mainScreen].bounds.size.height/2-50,100,100);
    videolayer.cornerRadius = 50;
    [self.view.layer insertSublayer:videolayer atIndex:0];
    
    //开始录制
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"开始录制" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(startRecoderButton:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(50, 100, 120, 50);
    [btn setBackgroundColor:UIColor.grayColor];
    [btn setTintColor:UIColor.redColor];
    
    //结束录制
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:@"结束录制" forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    [btn2 addTarget:self action:@selector(endRecoderButton:) forControlEvents:UIControlEventTouchUpInside];
    btn2.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-170, 100, 120, 50);
    [btn2 setBackgroundColor:UIColor.grayColor];
    [btn2 setTintColor:UIColor.redColor];
    
}

//开始录制
-(void)startRecoderButton:(UIButton *)button{
    [self.recoderEngine startRecoderVideo];
}
//结束录制
-(void)endRecoderButton:(UIButton *)button{
    [self.recoderEngine finishRecoderVideo:^(NSDictionary *Info) {
        //保存视频相册核心代码
        UISaveVideoAtPathToSavedPhotosAlbum([Info objectForKey:@"filePath"], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }];
}
#pragma mark 视频保存完毕的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInf{
    if (!error) {
    NSLog(@"视频保存成功.");
    }
}



//返回来的视频帧
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    @synchronized(self) {
        //初始化录制
        if ([captureOutput isKindOfClass:[AVCaptureAudioDataOutput class]] && self.recoderEngine == nil) {
            NSString * basePath=[Common getVideoCachePath];
            NSString *filePath = [basePath stringByAppendingPathComponent:[Common getUploadFile_type:@"video" fileType:@"mp4"]];
            self.recoderEngine = [RecoderEngine initRecoderEngineWithFilePath:filePath Width:ScreenW Height:ScreenH SampleBuffer:sampleBuffer];
        }
        if ([captureOutput isKindOfClass:[AVCaptureVideoDataOutput class]]) {
            [self.recoderEngine recoderVideoWithSampleBuffer:sampleBuffer];
        }
        if ([captureOutput isKindOfClass:[AVCaptureAudioDataOutput class]]) {
            [self.recoderEngine recoderAudioWithSampleBuffer:sampleBuffer];
        }
    }
}
//丢失的视频帧
- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    
}










- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
