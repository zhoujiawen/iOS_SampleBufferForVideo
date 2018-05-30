//
//  Common.m
//  VideoSampleBuffer
//
//  Created by  周家稳 on 2018/5/28.
//  Copyright © 2018年 zhoujiawen. All rights reserved.
//

#import "Common.h"

@implementation Common
//设置/获取 文件路径
+(NSString *)setCachePathForfileFolder:(NSString *)fileFolder FileName:(NSString *)fileName{
    //    创建一个文件夹Document
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES);
    NSString *documentPath = [paths firstObject];
    NSString *fileFolderPath = [documentPath stringByAppendingPathComponent:fileFolder];
    //NSFileManager 文件管理器，用来创建本地文件夹，是个单例 ，系统的单利
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //创建文件夹
    BOOL isDirectory = YES;
    BOOL fileExist = [fileManager fileExistsAtPath:fileFolderPath isDirectory:&isDirectory];
    if (!(isDirectory == YES && fileExist == YES)) {
        BOOL success = [fileManager createDirectoryAtPath:fileFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (!success) {
            return @"获取路径失败";
        }
    }
    //创建文件路径
    NSString *filePath = [fileFolderPath stringByAppendingPathComponent:fileName];
    //    给路径加后缀
    //NSString *path2 = [documentPath stringByAppendingPathExtension:@"jpg"];
    return filePath;
}
/*
  NSFileManager将文件:(NSString *name = @"测试" 路径:../test.txt)写入某个路径
  把一个代表这个内容的property列表写入到指定的路径。
  property列表里的对象（包括 NSData, NSDate, NSNumber, NSString, NSArray, or NSDictionary）
  只能存储这些类型数据否则会报错
  NSArray:.xml NSDictionary:.plist
  如果是类那么应该使用归档
 */
+(BOOL)writeToFilePath:(NSString *)filePath Object:(id)Object Archiver:(BOOL)Archiver{
    if (Archiver) {
        BOOL success = [NSKeyedArchiver archiveRootObject:Object toFile:filePath];
         return success;
    } else {
        BOOL success = [Object writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
         return success;
    }
}
//获取文件(默认字典)其他的重设
+(id)getFileWithFilePath:(NSString *)filePath unArchiver:(BOOL)unArchiver{
    if (unArchiver) {
        id data = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        return data;
    } else {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:filePath]) {
            return @"失败";
        } else {
            NSMutableDictionary *data= [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
            return data;
        }
    }
}
//获取视频第一帧的图片
+(void)getToImageWithPath:(NSString *)videoPath Handler:(void (^)(NSDictionary *Data))handler {
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    CMTime   time = [asset duration];
    int seconds = ceil(time.value/time.timescale) + 1;
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = TRUE;
    //    generator.requestedTimeToleranceAfter = kCMTimeZero;//任意帧
    //    generator.requestedTimeToleranceBefore = kCMTimeZero;
    //    CMTime thumbTime = CMTimeMakeWithSeconds(0, 60);
    //    CMTime CMTimeMake (
    //                       int64_t value,    //表示 当前视频播放到的第几桢数
    //                       int32_t timescale //每秒的帧数
    //                       );
    //    CMTime CMTimeMakeWithSeconds(
    //                                 Float64 seconds,   //第几秒的截图,是当前视频播放到的帧数的具体时间
    //                                 int32_t preferredTimeScale //首选的时间尺度 "每秒的帧数"
    //                                 ); 
    //参数一:即当前时间 参数二:每秒几帧
    CMTime thumbTime = CMTimeMakeWithSeconds(0, 60);
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    AVAssetImageGeneratorCompletionHandler generatorHandler =
    ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *thumbImg = [UIImage imageWithCGImage:im];
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:videoPath,@"videoPath",thumbImg,@"Image",[NSNumber numberWithInt:seconds],@"Time",nil];
                    handler(dict);
                });
            }
        }
    };
    [generator generateCGImagesAsynchronouslyForTimes:
    [NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:generatorHandler];
//    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
}

//获得视频存放地址
+ (NSString *)getVideoCachePath {
    NSString *videoCache = [NSTemporaryDirectory() stringByAppendingPathComponent:@"videos"] ;
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:videoCache isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:videoCache withIntermediateDirectories:YES attributes:nil error:nil];
    };
    return videoCache;
}
//文件名设置
+ (NSString *)getUploadFile_type:(NSString *)type fileType:(NSString *)fileType {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    NSDate * NowDate = [NSDate dateWithTimeIntervalSince1970:now];
    ;
    NSString * timeStr = [formatter stringFromDate:NowDate];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.%@",type,timeStr,fileType];
    return fileName;
}
+(void)removFiles:(NSString *)fileFolder{
     NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fileFolder error:nil];
}



@end
