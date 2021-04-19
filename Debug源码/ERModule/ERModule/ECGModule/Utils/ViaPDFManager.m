//
//  ViaPDFManager.m
//  ViHealth
//
//  Created by Viatom on 2019/6/3.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import "ViaPDFManager.h"



@implementation ViaPDFManager


+ (NSString *)pdfDestPath:(NSString *)filename
{
    return [[ViaPDFManager alloc] createPDFPathWithName:filename];
}

+ (void)via_createPdfFileWithSrc:(NSData *)imgData
                      toDestFile:(NSString *)destFileName
{
    NSString *fileFullPath = [self pdfDestPath:destFileName];
    UIImage *img = [UIImage imageWithData:imgData];
    // CGRectZero 表示默认尺寸，参数可修改，设置自己需要的尺寸 pdfContextBounds
    UIGraphicsBeginPDFContextToFile(fileFullPath, CGRectMake(0, 0, whole_width, whole_height), NULL);
    CGRect pdfBounds = UIGraphicsGetPDFContextBounds();
    CGFloat pdfWidth  = pdfBounds.size.width;
    CGFloat pdfHeight = pdfBounds.size.height;
    UIGraphicsBeginPDFPage();
    CGFloat imageW = img.size.width;
    CGFloat imageH = img.size.height;
    if (imageW <= pdfWidth && imageH <= pdfHeight)
    {
        CGFloat originX = (pdfWidth - imageW) / 2;
        CGFloat originY = (pdfHeight - imageH) / 2;
        [img drawInRect:CGRectMake(originX, originY, imageW, imageH)];
    }
    else
    {
        CGFloat width,height;
        
        if ((imageW / imageH) > (pdfWidth / pdfHeight))
        {
            width  = pdfWidth;
            height = width * imageH / imageW;
        }
        else
        {
            height = pdfHeight;
            width = height * imageW / imageH;
        }
        [img drawInRect:CGRectMake((pdfWidth - width)/2, (pdfHeight - height)/2, width , height)];
    }
    UIGraphicsEndPDFContext();
}

+ (BOOL)deletePdfWithPath:(NSString *)pdfPath{
    return [[ViaPDFManager alloc] deletePDFCache:pdfPath];
}


- (NSString *)createPDFPathWithName:(NSString *)pdfName {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * finderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) lastObject]
                             stringByAppendingPathComponent:ERDIR_AIReport_File];
    if (![fileManager fileExistsAtPath:finderPath]) {
        [fileManager createDirectoryAtPath:finderPath withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
    }
    return [finderPath stringByAppendingPathComponent:pdfName];
}

- (BOOL)deletePDFCache:(NSString *)path{
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:path error:nil];
}


void drawContentForPage(CGContextRef myContext,
                        CFDataRef data,
                        CGRect rect)
{
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(data);
    CGImageRef image = CGImageCreateWithJPEGDataProvider(dataProvider,
                                                         NULL,
                                                         NO,
                                                         kCGRenderingIntentDefault);
    
    CGContextDrawImage(myContext, rect, image);
    
    CGDataProviderRelease(dataProvider);
    CGImageRelease(image);
}


+ (void)createPDFFileWithImage:(NSArray*)imagePathArr toDestFile:(NSString *)destFileName
{
    const char *fileName = [[self pdfDestPath:destFileName] UTF8String];
    CFStringRef path = CFStringCreateWithCString (NULL, fileName, kCFStringEncodingUTF8);
    CFURLRef url = CFURLCreateWithFileSystemPath (NULL, path, kCFURLPOSIXPathStyle, 0);
    CFRelease (path);
    
    CFMutableDictionaryRef myDictionary = CFDictionaryCreateMutable(NULL,
                                                                    0,
                                                                    &kCFTypeDictionaryKeyCallBacks,
                                                                    &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(myDictionary,
                         kCGPDFContextTitle,
                         CFSTR("ECG Report"));
    CFDictionarySetValue(myDictionary,
                         kCGPDFContextCreator,
                         CFSTR("Viatom"));
    
    //开始生成pdf文件
    CGContextRef pdfContext = NULL;
    CFDataRef boxData = NULL;
    CFMutableDictionaryRef pageDictionary = NULL;
    
    //正常情况下每一页的尺寸都是一样的
    CGRect pageRect = CGRectMake(0, 0, whole_width, whole_height);
    pdfContext = CGPDFContextCreateWithURL (url, &pageRect, myDictionary);
    for (int pageIndex = 0; pageIndex < imagePathArr.count; pageIndex++) {
        UIImage * image = imagePathArr[pageIndex];
//        image = [self compressOriginalImage:image toSize:CGSizeMake(PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT)];
        NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
        CFDataRef data = (__bridge CFDataRef)imgData;
        pageDictionary = CFDictionaryCreateMutable(NULL,
                                                   0,
                                                   &kCFTypeDictionaryKeyCallBacks,
                                                   &kCFTypeDictionaryValueCallBacks);
        
        boxData = CFDataCreate(NULL,(const UInt8 *)&pageRect, sizeof (CGRect));
        CFDictionarySetValue(pageDictionary, kCGPDFContextMediaBox, boxData);
        
        //生成一个新的页面
        CGPDFContextBeginPage (pdfContext, pageDictionary);
        drawContentForPage(pdfContext,data,pageRect);
        CGPDFContextEndPage (pdfContext);
    }
    
    CFRelease(myDictionary);
    CFRelease(url);
    CGContextRelease (pdfContext);
    CFRelease(pageDictionary);
    CFRelease(boxData);
    
}



+(UIImage *)compressOriginalImage:(UIImage *)image toSize:(CGSize)size{
    UIImage * resultImage = image;
    UIGraphicsBeginImageContext(size);
    [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}


@end
