//
//  QLPdfPreviewItem.h
//  iwown
//
//  Created by viatom on 2020/6/5.
//  Copyright © 2020 LP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

NS_ASSUME_NONNULL_BEGIN

@interface QLPdfPreviewItem : NSObject<QLPreviewItem>

@property (nullable, nonatomic) NSURL *previewItemURL;
@property (nullable, nonatomic) NSString *previewItemTitle;

@end

NS_ASSUME_NONNULL_END
