//
//  ERPdfReportViewController.h
//  iwown
//
//  Created by viatom on 2020/6/2.
//  Copyright © 2020 LP. All rights reserved.
//

#import <QuickLook/QuickLook.h>

NS_ASSUME_NONNULL_BEGIN

@interface ERPdfReportViewController : QLPreviewController

@property (nonatomic, copy) NSString *pdfPath;

@end

NS_ASSUME_NONNULL_END
