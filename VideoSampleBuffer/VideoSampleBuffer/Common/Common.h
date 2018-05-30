//
//  Common.h
//  VideoSampleBuffer
//
//  Created by  周家稳 on 2018/5/28.
//  Copyright © 2018年 zhoujiawen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface Common : NSObject
//设置/获取 文件路径
+(NSString *)setCachePathForfileFolder:(NSString *)fileFolder FileName:(NSString *)fileName;
//文件写入存储路径
+(BOOL)writeToFilePath:(NSString *)filePath Object:(id)Object Archiver:(BOOL)Archiver;
//获取文件(默认字典)其他的重设
+(id)getFileWithFilePath:(NSString *)filePath unArchiver:(BOOL)unArchiver;
//文件名设置
+ (NSString *)getUploadFile_type:(NSString *)type fileType:(NSString *)fileType ;
//获得视频存放地址
+ (NSString *)getVideoCachePath;
@end
