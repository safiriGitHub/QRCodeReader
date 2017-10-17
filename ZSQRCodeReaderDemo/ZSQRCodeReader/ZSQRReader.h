//
//  ZSQRReader.h
//  CheFu365
//
//  Created by safiri on 2017/10/17.
//  Copyright © 2017年 safiri. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "ZSQRTool.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^ReaderErrorBlock)(NSString * _Nullable errorMsg);
typedef void(^CompletionBlock)(NSString * _Nullable resultAsString);
typedef void(^ScanBrightnessBlock)(CGFloat brightnessValue);

@interface ZSQRReader : NSObject

#pragma mark - init QRReader
///根据扫码类型初始化 初始化之前要先用
- (instancetype)initWithMetadataObjectTypes:(NSArray<AVMetadataObjectType> * _Nullable)metadataObjectTypes;
+ (instancetype)readerWithMetadataObjectTypes:(NSArray<AVMetadataObjectType> * _Nullable)metadataObjectTypes;
+ (instancetype)readerWithDefaultMetadataObjectTypes;

#pragma mark -
@property (strong, nonatomic, readonly) NSArray<AVMetadataObjectType> *metadataObjectTypes;
@property (strong, nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;
@property (readonly) AVCaptureDeviceInput *defaultDeviceInput;
@property (readonly) AVCaptureMetadataOutput *metadataOutput;

#pragma mark - Block
///初始化设备错误block
@property (nonatomic ,copy ,nullable) ReaderErrorBlock readerErrorBlock;
///扫描结果block
@property (nonatomic ,copy ,nullable) CompletionBlock completionBlock;
///光亮感应block
@property (nonatomic ,copy ,nullable) ScanBrightnessBlock scanBrightnessBlock;
#pragma mark - controll

- (void)startScanning;
- (void)stopScanning;
- (BOOL)isRunning;
- (BOOL)isTorchAvailable;
- (void)toggleTorch:(void(^)(BOOL torchOnOff))torchOnOffBlock;
- (void)setRectOfInterest:(CGRect)cropRect width:(CGFloat)width height:(CGFloat)height;
///开启DataOutput（光感）
- (void)configureVideoDataOutputComponents;

#pragma mark - 检查Reader是否可用
+ (BOOL)isAvailable;
+ (BOOL)supportsMetadataObjectTypes:(NSArray * _Nullable )metadataObjectTypes;

@end

NS_ASSUME_NONNULL_END
