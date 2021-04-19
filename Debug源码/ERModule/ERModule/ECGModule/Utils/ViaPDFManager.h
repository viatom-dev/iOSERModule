//
//  ViaPDFManager.h
//  ViHealth
//
//  Created by Viatom on 2019/6/3.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VTMarco.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViaPDFManager : NSObject

+ (void)via_createPdfFileWithSrc:(NSData *)imgData
                      toDestFile:(NSString *)destFileName;

+ (NSString *)pdfDestPath:(NSString *)filename;

+ (BOOL)deletePdfWithPath:(NSString *)pdfPath;

+ (void)createPDFFileWithImage:(NSArray*)imagePathArr toDestFile:(NSString *)destFileName;

@end

NS_ASSUME_NONNULL_END
