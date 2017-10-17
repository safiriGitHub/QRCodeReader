//
//  QRCodeReaderVC+ReadPicCode.m
//  CheFu365
//
//  Created by safiri on 2017/10/16.
//  Copyright © 2017年 safiri. All rights reserved.
//

#import "ZSQRCodeReaderVC+ReadPicCode.h"
#import "TZImagePickerController.h"
#import <objc/runtime.h>

static const void *readPicCodeResultViewKey = &readPicCodeResultViewKey;
static const void *isResultViewShowKey = &isResultViewShowKey;
static const void *imagePickerNavbarTintColorKey = &imagePickerNavbarTintColorKey;
@interface ZSQRCodeReaderVC ()<TZImagePickerControllerDelegate>
@property (nonatomic ,assign ,readwrite) BOOL isResultViewShow;
@end

@implementation ZSQRCodeReaderVC (ReadPicCode)
#pragma mark - AssociatedObject
- (UIView *)readPicCodeResultView {
    UIView *readPicCodeResultView = objc_getAssociatedObject(self, readPicCodeResultViewKey);
    if (!readPicCodeResultView) {
        
        readPicCodeResultView = [[UIView alloc] initWithFrame:self.view.bounds];
        readPicCodeResultView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        
        UIView *contentView = [[UIView alloc] initWithFrame:self.scanReaderRect];
        [readPicCodeResultView addSubview:contentView];
        
        CGFloat h = 20;
        CGFloat y = (self.scanReaderRect.size.height-h*2-5)/2;
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.scanReaderRect.size.width, h)];
        label1.text = @"未发现二维码/条码";
        label1.font = [UIFont systemFontOfSize:17];
        label1.textColor = [UIColor whiteColor];
        label1.textAlignment = NSTextAlignmentCenter;
        [contentView addSubview:label1];
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, y+h+5, self.scanReaderRect.size.width, h)];
        label2.text = @"轻触屏幕继续扫描";
        label2.font = [UIFont systemFontOfSize:14];
        label2.textColor = [UIColor grayColor];
        label2.textAlignment = NSTextAlignmentCenter;
        [contentView addSubview:label2];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResultViewForStart)];
        readPicCodeResultView.userInteractionEnabled = YES;
        [readPicCodeResultView addGestureRecognizer:tap];
        objc_setAssociatedObject(self, readPicCodeResultViewKey, readPicCodeResultView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return readPicCodeResultView;
}
- (void)setIsResultViewShow:(BOOL)isResultViewShow {
    objc_setAssociatedObject(self, isResultViewShowKey, @(isResultViewShow), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)isResultViewShow {
    return [objc_getAssociatedObject(self, isResultViewShowKey) boolValue];
}
- (void)setImagePickerNavbarTintColor:(UIColor *)imagePickerNavbarTintColor {
    objc_setAssociatedObject(self, imagePickerNavbarTintColorKey, imagePickerNavbarTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIColor *)imagePickerNavbarTintColor {
    return objc_getAssociatedObject(self, imagePickerNavbarTintColorKey);
}
#pragma mark -
- (void)showReadPicCodeResultView {
    self.isResultViewShow = YES;
    self.readPicCodeResultView.hidden = NO;
    [self stopReading];
    [self.view addSubview:self.readPicCodeResultView];
}
- (void)hideReadPicCodeResultView {
    self.isResultViewShow = NO;
    self.readPicCodeResultView.hidden = YES;
    [self startReading];
    [self.readPicCodeResultView removeFromSuperview];
}
- (void)tapResultViewForStart {
    [self hideReadPicCodeResultView];
}
- (void)setRightPicTitle {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(takeQRCodeFromPic)];
}
#pragma mark - 从相册选择识别
- (void)takeQRCodeFromPic {
    TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    imagePickerVC.isSelectOriginalPhoto = YES;
    // 2. 设置imagePickerVC的外观
    if (self.imagePickerNavbarTintColor) {
        imagePickerVC.navigationBar.barTintColor = self.imagePickerNavbarTintColor;
    }
    
    imagePickerVC.navigationBar.translucent = NO;
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVC.allowTakePicture = NO;
    imagePickerVC.allowPickingVideo = NO;
    imagePickerVC.allowPickingImage = YES;
    imagePickerVC.allowPickingOriginalPhoto = YES;
    imagePickerVC.allowPickingGif = NO;
    imagePickerVC.allowPickingMultipleVideo = NO; // 是否可以多选视频
    // 4. 照片排列按修改时间升序
    imagePickerVC.sortAscendingByModificationDate = YES;
    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVC.showSelectBtn = NO;
    imagePickerVC.allowCrop = NO;
    imagePickerVC.needCircleCrop = NO;
    // 你可以通过block或者代理，来得到用户选择的照片.
//    [imagePickerVC setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
//
//    }];
    imagePickerVC.autoDismiss = NO;
    [self presentViewController:imagePickerVC animated:YES completion:nil];

}


#pragma mark - TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// The picker should dismiss itself; when it dismissed these handle will be called.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    //只有一张图片
    [picker showProgressHUD];
    if (photos.count > 0) {
        UIImage *image = [photos objectAtIndex:0];
        //1.获取选择的图片
        
        //2.初始化一个监测器
        CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
        //监测到的结果数组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count >=1) {
            /**结果对象 */
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            //NSLog(@"scannedResult - %@",scannedResult);
            if (self.completeBlock) {
                self.completeBlock(scannedResult);
            }
        }
        else{
            [self showReadPicCodeResultView];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [picker hideProgressHUD];
        [picker dismissViewControllerAnimated:YES completion:nil];
    });
    
}



// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    
}

// If user picking a gif image, this callback will be called.
// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {
    
}

// Decide album show or not't
// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result {
    /*
     if ([albumName isEqualToString:@"个人收藏"]) {
     return NO;
     }
     if ([albumName isEqualToString:@"视频"]) {
     return NO;
     }*/
    return YES;
}

// Decide asset show or not't
// 决定asset显示与否
- (BOOL)isAssetCanSelect:(id)asset {
    /*
     if (iOS8Later) {
     PHAsset *phAsset = asset;
     switch (phAsset.mediaType) {
     case PHAssetMediaTypeVideo: {
     // 视频时长
     // NSTimeInterval duration = phAsset.duration;
     return NO;
     } break;
     case PHAssetMediaTypeImage: {
     // 图片尺寸
     if (phAsset.pixelWidth > 3000 || phAsset.pixelHeight > 3000) {
     // return NO;
     }
     return YES;
     } break;
     case PHAssetMediaTypeAudio:
     return NO;
     break;
     case PHAssetMediaTypeUnknown:
     return NO;
     break;
     default: break;
     }
     } else {
     ALAsset *alAsset = asset;
     NSString *alAssetType = [[alAsset valueForProperty:ALAssetPropertyType] stringValue];
     if ([alAssetType isEqualToString:ALAssetTypeVideo]) {
     // 视频时长
     // NSTimeInterval duration = [[alAsset valueForProperty:ALAssetPropertyDuration] doubleValue];
     return NO;
     } else if ([alAssetType isEqualToString:ALAssetTypePhoto]) {
     // 图片尺寸
     CGSize imageSize = alAsset.defaultRepresentation.dimensions;
     if (imageSize.width > 3000) {
     // return NO;
     }
     return YES;
     } else if ([alAssetType isEqualToString:ALAssetTypeUnknown]) {
     return NO;
     }
     }*/
    return YES;
}
@end
