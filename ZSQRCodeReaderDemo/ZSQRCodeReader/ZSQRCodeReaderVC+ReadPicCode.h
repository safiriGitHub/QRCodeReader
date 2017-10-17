//
//  QRCodeReaderVC+ReadPicCode.h
//  CheFu365
//
//  Created by safiri on 2017/10/16.
//  Copyright © 2017年 safiri. All rights reserved.
//

#import "ZSQRCodeReaderVC.h"

///只能读取二维码
@interface ZSQRCodeReaderVC (ReadPicCode)<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (void)setRightPicTitle;
@property (nonatomic ,strong) UIColor *imagePickerNavbarTintColor;
///透明扫描区域提示View
@property (nonatomic ,strong ,readonly) UIView *readPicCodeResultView ;
@property (nonatomic ,assign ,readonly) BOOL isResultViewShow;
@end
