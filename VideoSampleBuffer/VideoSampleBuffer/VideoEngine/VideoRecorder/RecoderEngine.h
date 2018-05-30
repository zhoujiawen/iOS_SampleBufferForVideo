//
//  RecoderEngine.h
//  VideoSampleBuffer
//
//  Created by  周家稳 on 2018/5/28.
//  Copyright © 2018年 zhoujiawen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface RecoderEngine : NSObject
//初始化录制引擎
+ (RecoderEngine *)initRecoderEngineWithFilePath:(NSString *)filePath Width:(NSUInteger)width Height:(NSInteger)height SampleBuffer:(CMSampleBufferRef)sampleBuffer;
//写入录制视频帧
-(void)recoderVideoWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;
//写入录制语音片段
-(void)recoderAudioWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

//开始录制
-(void)startRecoderVideo;
//结束录制录制结束记得销毁实例对象
-(void)finishRecoderVideo:(void (^)(NSDictionary *Info))handler;





@end
