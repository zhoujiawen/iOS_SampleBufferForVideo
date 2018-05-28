//
//  Common.m
//  VideoSampleBuffer
//
//  Created by  周家稳 on 2018/5/28.
//  Copyright © 2018年 zhoujiawen. All rights reserved.
//

#import "Common.h"

@implementation Common
//设置文件存储路径
+(NSString *)setCachePathForfileFolder:(NSString *)fileFolder FileName:(NSString *)fileName{
    //    创建一个文件夹Document
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES);
    NSString *documentPath = [paths firstObject];
    NSString *fileFolderPath = [documentPath stringByAppendingPathComponent:fileFolder];
    //NSFileManager 文件管理器，用来创建本地文件夹，是个单例 ，系统的单利
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //创建文件夹
    BOOL isDirectory = NO;
    BOOL fileExist = [fileManager fileExistsAtPath:fileFolderPath isDirectory:&isDirectory];
    if (!(isDirectory == YES && fileExist == YES)) {
        [fileManager createDirectoryAtPath:fileFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //创建文件路径
    NSString *filePath = [fileFolderPath stringByAppendingPathComponent:fileName];
    return filePath;
}
//








@end
