//
//  QRCodeReaderVC.h
//  CheFu365
//
//  Created by safiri on 2017/10/15.
//  Copyright © 2017年 safiri. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^readCompleteBlock)(NSString * _Nullable QRString);
typedef void(^readErrorBlock)(NSString * _Nullable errorMsg);

@interface ZSQRCodeReaderVC : UIViewController

#pragma mark - init
@property (nonatomic ,copy, nullable) NSString * navTitle;
@property (nonatomic ,copy, nullable) NSString * scanLabelHintString;
///扫描后一定要跳转页面，这里不处理以后迭代功能
@property (nonatomic ,copy ,nonnull)readCompleteBlock completeBlock;
@property (nonatomic ,copy ,nullable)readErrorBlock errorBlock;
@property (nonatomic ,assign) CGFloat ajustTransparentAreaY;
///init之前检测是否可用
+ (BOOL)isReadyForCodeReader;
#pragma mark - action
- (void)startReading;
- (void)stopReading;
#pragma mark - other
///扫描读取区域CGRect
@property (nonatomic ,assign ,readonly) CGRect scanReaderRect;


@end
