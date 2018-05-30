//
//  SampleBufferVideo.m
//  VideoSampleBuffer
//
//  Created by 周家稳 on 2018/5/25.
//  Copyright © 2018年 zhoujiawen. All rights reserved.
//

#import "SampleBufferVideo.h"
@interface SampleBufferVideo()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
{
    
}
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;//捕获到的视频呈现的layer
//第一步
@property (strong, nonatomic) AVCaptureSession           *recordSession;//捕获视频的会话
//第二步
@property (strong, nonatomic) AVCaptureDeviceInput       *backCameraInput;//后置摄像头输入
@property (strong, nonatomic) AVCaptureDeviceInput       *frontCameraInput;//前置摄像头输入
@property (strong, nonatomic) AVCaptureDeviceInput       *audioMicInput;//麦克风输入
@property (strong, nonatomic) AVCaptureVideoDataOutput   *videoOutput;//视频输出
@property (strong, nonatomic) AVCaptureAudioDataOutput   *audioOutput;//音频输出
//第三步
@property (copy  , nonatomic) dispatch_queue_t           captureQueue;//录制的队列
@property (strong, nonatomic) AVCaptureConnection        *audioConnection;//音频录制连接
@property (strong, nonatomic) AVCaptureConnection        *videoConnection;//视频录制连接
/**
 第四步  [recordSession startRunning];开启录制会话引擎
 AVCaptureVideoDataOutputSampleBufferDelegate  //视频片段回调
 AVCaptureAudioDataOutputSampleBufferDelegate  //音频片段回调
 CAAnimationDelegate //动画效果作用不明
 **/
@end

@implementation SampleBufferVideo

#pragma mark 公共调用
//开始
-(void)startRuning{
    [self.recordSession startRunning];
}
//停止
-(void)stopRuning{
   [self.recordSession stopRunning];
}
//销毁对象
+(void)destroyInstance{
    _instance = nil;
}
//关闭闪光灯
- (void)closeLight{
    AVCaptureDevice *backCamera = [self backCamera];
    if (backCamera.torchMode == AVCaptureTorchModeOn) {
        [backCamera lockForConfiguration:nil];
        backCamera.torchMode = AVCaptureTorchModeOff;
        backCamera.flashMode = AVCaptureTorchModeOff;
        [backCamera unlockForConfiguration];
    }
}
//开启闪光灯
- (void)openLight {
    AVCaptureDevice *backCamera = [self backCamera];
    if (backCamera.torchMode == AVCaptureTorchModeOff) {
        [backCamera lockForConfiguration:nil];
        backCamera.torchMode = AVCaptureTorchModeOn;
        backCamera.flashMode = AVCaptureFlashModeOn;
        [backCamera unlockForConfiguration];
    }
}
//切换前后置摄像头
- (void)swichCameraInputDeviceToFront:(BOOL)isFront{
    if (isFront) {
        [self.recordSession removeInput:self.backCameraInput];
        if ([self.recordSession canAddInput:self.frontCameraInput]) {
            [self.recordSession addInput:self.frontCameraInput];
        }
    }else {
        [self.recordSession removeInput:self.frontCameraInput];
        if ([self.recordSession canAddInput:self.backCameraInput]) {
            [self.recordSession addInput:self.backCameraInput];
        }
    }
}

/*
 捕获到的视频呈现的layer用于预览显示视频流
 是CoreAnimation里面layer的一个子类，用来做为AVCaptureSession预览视频输出，简单来说就是来做为拍摄的视频呈现的一个layer。
 */
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        //通过AVCaptureSession初始化
        AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.recordSession];
        //设置比例为铺满全屏
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer = preview;
    }
    return _previewLayer;
}






#pragma mark 第一步 初始化AVCaptureSession (以下为私有)
/*
 录制视频是一个总的会话一切操作都在会话中进行,所以要把所有的设备,还有输入输出加入会话中
 AVCaptureSession
 AVCaptureSession是AVFoundation捕捉类的中心枢纽，我们先从这个类入手，在视频捕获时,客户端可以实例化AVCaptureSession并添加适当的AVCaptureInputs、AVCaptureDeviceInput和输出，比如AVCaptureMovieFileOutput。通过[AVCaptureSession startRunning]开始数据流从输入到输出,和[AVCaptureSession stopRunning]停止输出输入的流动。客户端可以通过设置sessionPreset属性定制录制质量水平或输出的比特率。
 */
- (AVCaptureSession *)recordSession {
    if (_recordSession == nil) {
        _recordSession = [[AVCaptureSession alloc] init];
        [_recordSession setSessionPreset:AVCaptureSessionPresetHigh];//接下来三种为相对预设(low, medium, high)，这些预设的编码配置会因设备不同而不同，如果选择high，那么你选定的相机会提供给你该设备所能支持的最高画质；
        //添加后置摄像头的输出
        if ([_recordSession canAddInput:self.backCameraInput]) {
            [_recordSession addInput:self.backCameraInput];
        }
        //添加后置麦克风的输出
        if ([_recordSession canAddInput:self.audioMicInput]) {
            [_recordSession addInput:self.audioMicInput];
        }
        //添加视频输出
        if ([_recordSession canAddOutput:self.videoOutput]) {
            [_recordSession addOutput:self.videoOutput];
        }
        //添加音频输出
        if ([_recordSession canAddOutput:self.audioOutput]) {
            [_recordSession addOutput:self.audioOutput];
        }
        //AVCaptureVideoOrientationPortrait           = 1,home健在下
        //AVCaptureVideoOrientationPortraitUpsideDown = 2,home健在上
        //AVCaptureVideoOrientationLandscapeRight     = 3,home健在右
        //AVCaptureVideoOrientationLandscapeLeft      = 4,home健在左
        //设置视频录制的方向
        //self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;//home键在下方
    }
    return _recordSession;
}
#pragma mark 第二步 初始化设备输入输出源
/*
 ***************************************************设备输入流
 AVCaptureDevice
 AVCaptureDevice的每个实例对应一个设备,如摄像头或麦克风。AVCaptureDevice的实例不能直接创建。所有现有设备可以使用类方法devicesWithMediaType:defaultDeviceWithMediaType:获取，设备可以提供一个或多个给定流媒体类型。AVCaptureDevice实例可用于提供给AVCaptureSession创建一个为AVCaptureDeviceInput类型的输入源。
 AVCaptureDeviceInput 是AVCaptureSession输入源,提供媒体数据从设备连接到系统，通过AVCaptureDevice的实例化得到，就是我们将要用到的设备输出源设备，也就是前后摄像头，通过[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]方法获得
 */
//后置摄像头输入
- (AVCaptureDeviceInput *)backCameraInput {
    if (_backCameraInput == nil) {
        NSError *error;
        _backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        if (error) {
            NSLog(@"获取后置摄像头失败~");
        }
    }
    return _backCameraInput;
}
//返回后置摄像头
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}
//前置摄像头输入
- (AVCaptureDeviceInput *)frontCameraInput {
    if (_frontCameraInput == nil) {
        NSError *error;
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        if (error) {
            NSLog(@"获取前置摄像头失败~");
        }
    }
    return _frontCameraInput;
}
//返回前置摄像头
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}
//用来返回是前置摄像头还是后置摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    //返回和视频录制相关的所有默认设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //遍历这些设备返回跟position相关的设备
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}
//麦克风输入
- (AVCaptureDeviceInput *)audioMicInput {
    if (_audioMicInput == nil) {
        AVCaptureDevice *mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSError *error;
        _audioMicInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&error];
        if (error) {
            NSLog(@"获取麦克风失败~");
        }
    }
    return _audioMicInput;
}

/*
 **************************************************设备输出流
 
 AVCaptureMovieFileOutput
 AVCaptureMovieFileOutput是AVCaptureFileOutput的子类，用来写入QuickTime视频类型的媒体文件。因为这个类在iphone上并不能实现暂停录制，和不能定义视频文件的类型，所以在这里并不使用，而是用灵活性更强的AVCaptureVideoDataOutput和AVCaptureAudioDataOutput来实现视频的录制。
 AVCaptureVideoDataOutput
 AVCaptureVideoDataOutput是AVCaptureOutput一个子类，可以用于用来输出未压缩或压缩的视频捕获的帧，AVCaptureVideoDataOutput产生的实例可以使用其他媒体视频帧适合的api处理，应用程序可以用captureOutput:didOutputSampleBuffer:fromConnection:代理方法来获取帧数据。
 */
//视频输出
- (AVCaptureVideoDataOutput *)videoOutput {
    if (_videoOutput == nil) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoOutput setSampleBufferDelegate:self queue:self.captureQueue];
        NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],kCVPixelBufferPixelFormatTypeKey,nil];
        _videoOutput.videoSettings = setcapSettings;
    }
    return _videoOutput;
}
//音频输出
- (AVCaptureAudioDataOutput *)audioOutput {
    if (_audioOutput == nil) {
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [_audioOutput setSampleBufferDelegate:self queue:self.captureQueue];
    }
    return _audioOutput;
}

#pragma mark 第三步 输入输出流之间的链接
/*
 **************************************************  流之间的链接
 AVCaptureConnection
 AVCaptureConnection代表AVCaptureInputPort或端口之间的连接，和一个AVCaptureOutput或AVCaptureVideoPreviewLayer在AVCaptureSession中的呈现。
 */
//录制的队列
- (dispatch_queue_t)captureQueue {
    if (_captureQueue == nil) {
        _captureQueue = dispatch_queue_create("Recordengine.capture", DISPATCH_QUEUE_SERIAL);
    }
    return _captureQueue;
}
//视频连接
- (AVCaptureConnection *)videoConnection {
    _videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    return _videoConnection;
}
//音频连接
- (AVCaptureConnection *)audioConnection {
    if (_audioConnection == nil) {
        _audioConnection = [self.audioOutput connectionWithMediaType:AVMediaTypeAudio];
    }
    return _audioConnection;
}
#pragma mark 第四步 视频音频片段回调
/*
 AVCaptureVideoDataOutputSampleBufferDelegate
 didOutputSampleBuffer
 didDropSampleBuffer
 这两个方法都要处理Sample Buffer.它以CMSampleBuffer对象的形式存在
 CMSampleBuffer
 CMSampleBuffer是一个由Core Media框架提供的Core Foundation风格对象. 用于在媒体管道中传输数字样本. CMSampleBuffer的角色是将基础的样本数据进行封装并提供格式和时间信息,以及所有在转换和处理数据时要用到的元数据.
 样本数据 : 使用AVCaptureVideoDataOutput时,sample buffer 会包含一个CVPixeBuffer,它是一个带有单个视频帧原始数据的Core Video中的对象.它在内存中保存像素数据,给我们提供了操作内容的机会.例如给捕捉到的图片应用灰度效果.
 格式信息: 除了原始媒体样本外,CMSampleBuffer还提供了以CMFormatDescription对象的形式存在的样本格式信息. 它定义了大量函数用于访问媒体样本的更多细节. 例如: 识别音频和视频数据.
 时间信息: CMSampleBuffer还定义了关于媒体样本的时间信息,可以获取到原始的表示时间戳和解码时间戳.
 附加的元数据 : Core Media在CMAttachment.h中定义了元数据协议,可以读取和写入底层元数据.比如可交换图片文件格式的标签.
 
 captureOutput:didOutputSampleBuffer:fromConnection:
 当输出捕获并输出一个新的视频帧、解码或重新编码它的视频设置属性指定的时候，委托将接收此消息。委托可以与其他api一起使用提供的视频框架进行进一步的处理。
 此方法在输出的sampleBufferCallbackQueue属性指定的分派队列上调用。它是周期性的，因此必须有效地防止捕获性能问题，包括已删除的帧。
 如果您需要在这个方法的范围之外引用CMSampleBuffer对象，那么您必须将它保存起来，然后在您完成它时将它CFRelease。
 为了保持最佳性能，一些示例缓冲区直接引用可能需要被设备系统和其他捕获输入重用的内存池。这常常是未压缩设备本地捕获的情况，在这里，内存块的复制尽可能少。如果多个样本缓冲区对这样的内存池进行了太长时间的引用，输入将不再能够将新的样本复制到内存中，并且这些样本将被删除。
 如果您的应用程序从而丢弃样品提供CMSampleBufferRef对象保留太久,但它需要对样本数据的访问很长一段时间,考虑将数据复制到新的缓冲区,然后释放样品缓冲(如果是以前留存),这样可以重用它引用的内存。
 
 
 
 */
//捕获到视频的回调函数 每当获取一个新的视频帧就会调用,数据在其中进行解码或重新编码
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
     CFRetain(sampleBuffer);
    [self.delegate captureOutput:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];
    CFRelease(sampleBuffer);
}

/*
 
 */
//每当一个迟到的帧被丢弃时调用
- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    [self.delegate captureOutput:output didDropSampleBuffer:sampleBuffer fromConnection:connection];
    
}

#pragma mark 初始化  创建单利

static SampleBufferVideo *_instance;
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    // 也可以使用一次性代码
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}
// 类方法命名规范 share类名|default类名|类名 // 最好用self 用Tools他的子类调用时会出现错误
+(instancetype)shareVideoEnegine{
    return [[self alloc] init];
}
// 为了严谨，也要重写copyWithZone 和 mutableCopyWithZone
-(id)copyWithZone:(NSZone *)zone{
    return _instance;
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return _instance;
}
- (void)dealloc {
    [_recordSession stopRunning];
    _captureQueue     = nil;
    _recordSession    = nil;
    _previewLayer     = nil;
    _backCameraInput  = nil;
    _frontCameraInput = nil;
    _audioOutput      = nil;
    _videoOutput      = nil;
    _audioConnection  = nil;
    _videoConnection  = nil;
}

@end























