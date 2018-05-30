//
//  RecoderEngine.m
//  VideoSampleBuffer
//
//  Created by  周家稳 on 2018/5/28.
//  Copyright © 2018年 zhoujiawen. All rights reserved.
//

#import "RecoderEngine.h"
@interface RecoderEngine()
@property (nonatomic, strong) AVAssetWriter *writer;//媒体写入对象
@property (nonatomic, strong) AVAssetWriterInput *videoInput;//视频写入
@property (nonatomic, strong) AVAssetWriterInput *audioInput;//音频写入

//其他配置
@property (nonatomic, assign) BOOL canWrite;
@property (nonatomic, copy) NSString *Path;
@property (nonatomic, strong) UIImage *preImage;

@end
@implementation RecoderEngine
//当录制对象被销毁销毁
- (void)dealloc{
    _writer = nil;
    _videoInput = nil;
    _audioInput = nil;
    _Path = nil;
    _preImage = nil;
    _canWrite = NO;
}
//初始化
+(RecoderEngine *)initRecoderEngineWithFilePath:(NSString *)filePath Width:(NSUInteger)width Height:(NSInteger)height SampleBuffer:(CMSampleBufferRef)sampleBuffer{
    RecoderEngine *Engine = [[RecoderEngine alloc] initAVAssetWriterWithFilePath:filePath Width:width Height:height SampleBuffer:sampleBuffer];
    return Engine;
}
//开始录制
-(void)startRecoderVideo{
    self.canWrite = YES;
}
//结束录制
-(void)finishRecoderVideo:(void (^)(NSDictionary *Info))handler{
    if (_writer.status != AVAssetWriterStatusWriting) {
        return;
    }
    self.canWrite = NO;
    [_writer finishWritingWithCompletionHandler:^{
        handler(@{@"filePath":self.Path});
    }];
}






#pragma mark 配置录制参数
/*
 1.初始化写入配置
 AVAssetWriter
 AVAssetWriter为写入媒体数据到一个新的文件提供服务，AVAssetWriter的实例可以规定写入媒体文件的格式对视频进行相关的处理，如QuickTime电影文件格式或MPEG-4文件格式等
 AVAssetWriter有多个并行的轨道媒体数据，基本的有视频轨道和音频轨道。AVAssetWriter的单个实例可用于一次写入一个单一的文件。那些希望写入多次文件的客户端必须每一次用一个新的AVAssetWriter实例。
 */
-(instancetype)initAVAssetWriterWithFilePath:(NSString *)filePath Width:(NSUInteger)width Height:(NSInteger)height SampleBuffer:(CMSampleBufferRef)sampleBuffer{
    self = [super init];
    if (self) {
        //初始化写入媒体类型为MP4类型 使其更适合在网络上播放
        _writer = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:filePath] fileType:AVFileTypeMPEG4 error:nil];
        _writer.shouldOptimizeForNetworkUse = YES;
        //这个是用来设置录制的视频的高宽的
        NSDictionary *settingV = [NSDictionary dictionaryWithObjectsAndKeys:
                                  AVVideoCodecH264, AVVideoCodecKey,
                                  [NSNumber numberWithInteger:width], AVVideoWidthKey,
                                  [NSNumber numberWithInteger:height], AVVideoHeightKey,
                                  AVVideoScalingModeResizeAspectFill,AVVideoScalingModeKey,
                                  nil];
        //初始化视频写入类
        _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settingV];
        //表明输入是否应该调整其处理为实时数据源的数据
        _videoInput.expectsMediaDataInRealTime = YES;
        //将视频输入源加入
        [_writer addInput:_videoInput];
        
        CMFormatDescriptionRef fmt = CMSampleBufferGetFormatDescription(sampleBuffer);
        const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
        Float64 SamplesRate = asbd->mSampleRate;
        int channel = asbd->mChannelsPerFrame;
        //音频的一些配置包括音频各种这里为AAC,音频声道、采样率和音频的比特率
        NSDictionary *settingA = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                  [ NSNumber numberWithInt: channel], AVNumberOfChannelsKey,
                                  [ NSNumber numberWithFloat: SamplesRate], AVSampleRateKey,
                                  [ NSNumber numberWithInt: 128000], AVEncoderBitRateKey,
                                  nil];
        //初始化音频写入类
        _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:settingA];
        //表明输入是否应该调整其处理为实时数据源的数据
        _audioInput.expectsMediaDataInRealTime = YES;
        //将音频输入源加入
        [_writer addInput:_audioInput];
        self.Path = filePath;
    }
    return self;
}

//写入录制视频帧
-(void)recoderVideoWithSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    if (!_canWrite) {
        return;
    }
    if (CMSampleBufferDataIsReady(sampleBuffer)) {
        NSLog(@"返回来的视频帧%ld",(long)_writer.status);
        if (_writer.status == AVAssetWriterStatusUnknown) {
            //获取视频帧的描述时间戳  然后开始写入
            CMTime timeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [_writer startWriting];
            [_writer startSessionAtSourceTime:timeStamp];
        }
        if (_writer.status == AVAssetWriterStatusFailed) {
            return;
        }
        //视频输入是否准备接受更多的媒体数据
        if (_videoInput.readyForMoreMediaData == YES) {
            //拼接数据
            [_videoInput appendSampleBuffer:sampleBuffer];
        }
    }
    
}
//写入录制语音片段
-(void)recoderAudioWithSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    if (!_canWrite) {
        return;
    }
    if (CMSampleBufferDataIsReady(sampleBuffer)) {
        if (_writer.status == AVAssetWriterStatusUnknown) {
            //获取语音帧的描述时间戳  然后开始写入
            CMTime timeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [_writer startWriting];
            [_writer startSessionAtSourceTime:timeStamp];
        }
        if (_writer.status == AVAssetWriterStatusFailed) {
            return;
        }
        //音频输入是否准备接受更多的媒体数据
        if (_audioInput.readyForMoreMediaData == YES) {
            //拼接数据
            [_audioInput appendSampleBuffer:sampleBuffer];
        }
    }
}





















@end
