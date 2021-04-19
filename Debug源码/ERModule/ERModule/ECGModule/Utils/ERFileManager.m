//
//  ERFileManager.m
//  iwown
//
//  Created by viatom on 2020/5/7.
//  Copyright © 2020 LP. All rights reserved.
//

#import "ERFileManager.h"

@implementation ERFileManager

+ (void)deleteAllFileInDocuments
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSArray *dirNames = [fileManager contentsOfDirectoryAtPath:documentsURL.path error:nil];
    for (NSString *dirName in dirNames) {
        NSURL *dirURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
        [fileManager removeItemAtPath:dirURL.path error:nil];
    }
    
    NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    [fileManager removeItemAtPath:cachesDir error:nil];
}

+ (void)deleteDirectory:(NSString *)dirName fromDirectory:(NSSearchPathDirectory)directory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:directory inDomains:NSUserDomainMask] lastObject];
    NSArray *dirNames = [fileManager contentsOfDirectoryAtPath:documentsURL.path error:nil];
    if ([dirNames containsObject:dirName]) {
        NSURL *mubiao = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
        BOOL success = [fileManager removeItemAtPath:mubiao.path error:nil];
        NSLog(@"deleteDirectory: %d", success);
    }
}

//删除指定文件
+(void)deleteFile:(NSString*) fileName inDirectory:(NSString *)dirName
{
    if (!fileName || !dirName) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *directoryURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:directoryURL.path]) {
        NSError *err;
        [fileManager removeItemAtPath:fileURL.path error:&err];
    }
}


//保存文件     //把获取到的数据文件保存到沙盒中
+(void)saveFile:(NSString*)fileName FileData:(NSData*)data withDirectoryName:(NSString *)dirName
{
    if (!fileName || !data) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *directoryURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
    if (![fileManager fileExistsAtPath:directoryURL.absoluteString]) {
        [fileManager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:fileName];
    if (![fileManager fileExistsAtPath:fileURL.path]) {
        [fileManager createFileAtPath:fileURL.path contents:nil attributes:nil];
        NSError *error;
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingToURL:fileURL error:&error];
        [data writeToURL:fileURL atomically:YES];
        [fileHandle closeFile];
    }else{
        NSError *error;
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingURL:fileURL error:&error];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];
        if (error) {
            NSLog(@"更新文件失败");
        }else{
//            NSLog(@"更新文件，写入%d长度",data.length);
        }
    }
}

//读文件
+(NSData*)readFile:(NSString*)fileName inDirectory:(NSString *)dirName     //获得document下的NSData类型的数据
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *directoryURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:fileURL.path isDirectory:NO]) { //如果文件存在
        NSData *data = [[NSData alloc] initWithContentsOfFile:fileURL.path];
        return data;
    }else{
        return nil;
    }
}

//判断文件是否存在
+(BOOL)isFileExist:(NSString*)fileName inDirectory:(NSString *)dirName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *directoryURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:fileName];
    
    if ([fileManager fileExistsAtPath:fileURL.path]) {
        return YES;
    }
    return  NO;
}

+ (BOOL) isDirectoryExistInDocumentsWithName:(NSString *)dirName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *dirURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
    BOOL isDir = YES;
    if ([fileManager fileExistsAtPath:dirURL.path isDirectory:&isDir]) {
        return YES;
    }
    return NO;
}




//  获取指定name开头的文件名称
+ (NSArray *)readAllFileNamesInDocumentsWithPrefix:(NSString *)prefixName inDirectory:(NSString *)dirName
{
    NSMutableArray *NameArr = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSArray *allFileNames = [NSArray array];
    if (dirName) {
        NSURL *directoryURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
        //获取文件夹下的所有文件的名字
        allFileNames = [fileManager contentsOfDirectoryAtPath:directoryURL.path error:nil];
    }else {
        allFileNames = [fileManager contentsOfDirectoryAtPath:documentsURL.path error:nil];
    }
    for (NSString *fileName in allFileNames) {
        if ([fileName hasPrefix:prefixName]) {
            [NameArr addObject:fileName];
        }
    }
    return NameArr;
}

//  获取含有name的文件名称
+ (NSArray *)readAllFileNamesInDocumentsWithName:(NSString *)name inDirectory:(NSString *)dirName
{
    NSMutableArray *NameArr = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSArray *allFileNames = [NSArray array];
    if (dirName) {
        NSURL *directoryURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
        //获取文件夹下的所有文件的名字
        allFileNames = [fileManager contentsOfDirectoryAtPath:directoryURL.path error:nil];
    }else {
        allFileNames = [fileManager contentsOfDirectoryAtPath:documentsURL.path error:nil];
    }
    for (NSString *fileName in allFileNames) {
        if ([fileName rangeOfString:name].location != NSNotFound) {
            
            [NameArr addObject:fileName];
        }
    }
    return NameArr;
}


// 在documents文件夹内创建一个文件夹
+ (void)createDirectoryInDocumentsWithName:(NSString *)name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取应用的Document文件夹路径的URL     .path 可获取路径
    NSURL *fileURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSString *dirPath = [fileURL.path stringByAppendingPathComponent:name];
    BOOL isDIR = NO;
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDIR];//是否存在文件夹
    if (!(isDIR == YES && existed == YES)) {
        //创建文件夹的路径
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}


@end
