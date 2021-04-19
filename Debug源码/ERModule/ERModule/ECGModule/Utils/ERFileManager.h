//
//  ERFileManager.h
//  iwown
//
//  Created by viatom on 2020/5/7.
//  Copyright © 2020 LP. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ERFileManager : NSObject

+ (void)deleteAllFileInDocuments;
+ (void)deleteDirectory:(NSString *)dirName fromDirectory:(NSSearchPathDirectory)directory;

+ (void)deleteFile:(NSString*)fileName inDirectory:(NSString *)dirName;

+ (void)saveFile:(NSString*)fileName FileData:(NSData*)data withDirectoryName:(NSString *)dirName;
+ (BOOL)isDirectoryExistInDocumentsWithName:(NSString *)dirName;
+ (BOOL)isFileExist:(NSString*)fileName inDirectory:(NSString *)dirName;
+ (NSMutableData*)readFile:(NSString*)fileName inDirectory:(NSString *)dirName;
// 通过前缀名读取文件夹下的文件
+ (NSArray *)readAllFileNamesInDocumentsWithPrefix:(NSString *)prefixName inDirectory:(NSString *)dirName;

+ (NSArray *)readAllFileNamesInDocumentsWithName:(NSString *)name inDirectory:(NSString *)dirName;
// 在documents文件夹内创建一个文件夹
+ (void)createDirectoryInDocumentsWithName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
