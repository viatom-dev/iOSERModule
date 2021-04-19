//
//  ERPdfReportViewController.m
//  iwown
//
//  Created by viatom on 2020/6/2.
//  Copyright © 2020 LP. All rights reserved.
//

#import "ERPdfReportViewController.h"
#import "QLPdfPreviewItem.h"

@interface ERPdfReportViewController ()<QLPreviewControllerDataSource,QLPreviewControllerDelegate>


@end

@implementation ERPdfReportViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
    UINavigationBar *bar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]];
    [bar setTintColor:[UIColor blackColor]];
    [bar setTitleTextAttributes:
     @{NSForegroundColorAttributeName: [UIColor darkTextColor]}];
    [self reloadData];
}

- (void)setPdfPath:(NSString *)pdfPath{
    _pdfPath = pdfPath;
}

#pragma mark QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    QLPdfPreviewItem  *item = [[QLPdfPreviewItem alloc] init];
    item.previewItemURL = [NSURL fileURLWithPath:_pdfPath];
    item.previewItemTitle = _pdfPath.lastPathComponent;
    return item;
}



/*!
 * @abstract Invoked before the preview controller is closed.
 */
- (void)previewControllerWillDismiss:(QLPreviewController *)controller{}

/*!
 * @abstract Invoked after the preview controller is closed.
 */
- (void)previewControllerDidDismiss:(QLPreviewController *)controller{}

/*!
 * @abstract Invoked by the preview controller before trying to open an URL tapped in the preview.
 * @result Returns NO to prevent the preview controller from calling -[UIApplication openURL:] on url.
 * @discussion If not implemented, defaults is YES.
 */
- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item{
    return NO;
}

/*!
 * @abstract Invoked when the preview controller is about to be presented full screen or dismissed from full screen, to provide a zoom effect.
 * @discussion Return the origin of the zoom. It should be relative to view, or screen based if view is not set. The controller will fade in/out if the rect is CGRectZero.
 */
//- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id <QLPreviewItem>)item inSourceView:(UIView * _Nullable * __nonnull)view;

/*!
 * @abstract Invoked when the preview controller is about to be presented full screen or dismissed from full screen, to provide a smooth transition when zooming.
 * @param contentRect The rect within the image that actually represents the content of the document. For example, for icons the actual rect is generally smaller than the icon itself.
 * @discussion Return an image the controller will crossfade with when zooming. You can specify the actual "document" content rect in the image in contentRect.
 */
//- (UIImage * _Nullable)previewController:(QLPreviewController *)controller transitionImageForPreviewItem:(id <QLPreviewItem>)item contentRect:(CGRect *)contentRect;

/*!
 * @abstract Invoked when the preview controller is about to be presented full screen or dismissed from full screen, to provide a smooth transition when zooming.
 * @discussion  Return the view that will crossfade with the preview.
 */
//- (UIView* _Nullable)previewController:(QLPreviewController *)controller transitionViewForPreviewItem:(id <QLPreviewItem>)item NS_AVAILABLE_IOS(10_0);

/*!
 * @abstract Invoked when the preview controller is loading its data. It is called for each preview item passed to the data source of the preview controller.
 * @discussion The preview controller does not offer the users to edit previews by default, but it is possible to activate this functionality if its delegate either allows it to overwrite the contents of the preview item, or if it takes care of the updated version of the preview item by implementing previewController:didSaveEditedCopyOfPreviewItem:atURL:.
   If the returned value is QLPreviewItemEditingModeUpdateContents and the previewController:didSaveEditedCopyOfPreviewItem:atURL: delegate method is implemented, the preview controller will overwrite the contents of the preview item if this is possible. If not (because the new version of the preview item is of a different type for instance), it will instead call previewController:didSaveEditedCopyOfPreviewItem:atURL:.
 * @param previewItem The preview item for which the controller needs to know how its delegate wants edited versions of the preview item to be handled.
 * @result A value indicating how the preview controller should handle edited versions of the preview item.
 */
- (QLPreviewItemEditingMode)previewController:(QLPreviewController *)controller editingModeForPreviewItem:(id <QLPreviewItem>)previewItem API_AVAILABLE(ios(13.0)){
    return QLPreviewItemEditingModeDisabled;
}

/*!
 * @abstract Called after the preview controller has successfully overwritten the contents of the file at previewItemURL for the preview item with the edited version of the users.
 * @discussion May be called multiple times in a row when overwriting the preview item with the successive edited versions of the preview item (whenever the users save the changes).
 */
//- (void)previewController:(QLPreviewController *)controller didUpdateContentsOfPreviewItem:(id<QLPreviewItem>)previewItem API_AVAILABLE(ios(13.0));

/*!
 * @abstract This method will be called with an edited copy of the contents of the preview item at previewItemURL.
 * @discussion This can be called after the users save changes in the following cases:
 
               - If the returned editing mode of the preview item is QLPreviewItemEditingModeCreateCopy.
 
               - If the returned editing mode of the preview item is QLPreviewItemEditingModeUpdateContents and its previewItemURL could not be successfully overwritten. In this case, modifiedContentsURL will point to a temporary file on disk containing the edited copy.
 
               - If the returned editing mode of the preview item is QLPreviewItemEditingModeUpdateContents and its content type and the content type of the edited version don't match.
                 This means that the file type of modifiedContentsURL may be different from the one of the preview item.
 
               Note that this may be called multiple times in a row with the successive edited versions of the preview item (whenever the users save the changes).
 * @param modifiedContentsURL NSURL of a temporary file on disk containing the edited copy of the preview item.
 */
//- (void)previewController:(QLPreviewController *)controller didSaveEditedCopyOfPreviewItem:(id <QLPreviewItem>)previewItem atURL:(NSURL *)modifiedContentsURL API_AVAILABLE(ios(13.0));

@end
