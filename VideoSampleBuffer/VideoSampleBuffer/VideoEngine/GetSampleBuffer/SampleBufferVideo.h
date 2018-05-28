//
//  SampleBufferVideo.h
//  VideoSampleBuffer
//
//  Created by 周家稳 on 2018/5/25.
//  Copyright © 2018年 zhoujiawen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol SampleBufferVideoDelegate <NSObject>
//返回来的视频帧
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;
//丢失的视频帧
- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;
@end
@interface SampleBufferVideo : NSObject
@property (weak, nonatomic) id<SampleBufferVideoDelegate> delegate;



//开始
-(void)startRuning;
//停止
-(void)stopRuning;
//销毁对象
+(void)destroyInstance;
//开启闪光灯
- (void)openLight;
//关闭闪光灯
- (void)closeLight;
//切换前后置摄像头
- (void)swichCameraInputDeviceToFront:(BOOL)isFront;
//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer;




@end
