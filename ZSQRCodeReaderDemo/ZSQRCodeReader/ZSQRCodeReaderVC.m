//
//  QRCodeReaderVC.m
//  CheFu365
//
//  Created by safiri on 2017/10/15.
//  Copyright © 2017年 safiri. All rights reserved.
//

#import "ZSQRCodeReaderVC.h"
#import "ZSQRTool.h"
#import "ZSQRAlphaView.h"
#import "ZSQRTorchView.h"
#import "ZSQRReader.h"
#import "ZSQRCodeReaderVC+ReadPicCode.h"

typedef NS_ENUM(NSUInteger, QRScanBrightnessModel) {
    BrightnessModelOrigin,
    BrightnessModelLight, //有光UI显示自动扫描，torch隐藏
    BrightnessModelDark,  //无光UI隐藏，torch显示
    BrightnessModelDark_toggleON, //无光-打开手电筒 UI隐藏 torch显示
};

@interface ZSQRCodeReaderVC ()<QRTorchViewDelegate>

@property (strong, nonatomic) ZSQRReader *codeReader;
//@property (nonatomic ,assign) QRScanUIModel scanUIModel;
///含透明区域的View
@property (nonatomic ,strong) ZSQRAlphaView *qrAlphaView;
///扫描读取区域CGRect
@property (nonatomic ,assign, readwrite) CGRect scanReaderRect;
///手电筒View
@property (nonatomic ,strong) ZSQRTorchView *torchLightView;
///是否可以闪烁手电筒View
@property (nonatomic ,assign) BOOL canBlinkTorchLightView;


@property (nonatomic ,assign) QRScanBrightnessModel scanBrightnessModel;
@end

@implementation ZSQRCodeReaderVC
+ (BOOL)isReadyForCodeReader {
    return [ZSQRReader supportsMetadataObjectTypes:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title= self.navTitle?self.navTitle:@"扫一扫";
    
    [self startReading]; //初始化二维码配置 并开始扫描
    [self cofingUI];
    
    //设备旋转，未完成
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)dealloc {
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"memory leak******QRCodeReaderVC");
}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.codeReader.previewLayer.frame = self.view.bounds;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self startReading];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopReading];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UI
- (void)cofingUI {
    //覆盖含透明区域的View
    [self.view addSubview:self.qrAlphaView];
    [self.view addSubview:self.torchLightView];
    [self setRightPicTitle];
}

#pragma mark -
- (void)startReading {
    [self.codeReader startScanning];
    [self.qrAlphaView startMovingLine];
}
- (void)stopReading {
    [self.codeReader stopScanning];
    [self.qrAlphaView stopMovingLine];
}
#pragma mark - getter setter
- (ZSQRReader *)codeReader {
    if (!_codeReader) {
        _codeReader = [[ZSQRReader alloc] initWithMetadataObjectTypes:nil];
        [_codeReader configureVideoDataOutputComponents];
        //@weakify(self);
        __weak typeof(self) weakSelf = self;
        [_codeReader setReaderErrorBlock:^(NSString * _Nullable errorMsg) {
            //@strongify(self);
            //NSLog(@"errorMsg - %@",errorMsg);
            if (weakSelf.errorBlock) {
                weakSelf.errorBlock(@"扫码失败,请确定码是否正确或重试");
            }
        }];
        [_codeReader setCompletionBlock:^(NSString * _Nullable resultAsString) {
            //@strongify(self);
            if (weakSelf.completeBlock) {
                weakSelf.completeBlock(resultAsString);
            }
            //NSLog(@"resultAsString - %@",resultAsString);
        }];
        [_codeReader setScanBrightnessBlock:^(CGFloat brightnessValue) {
            //@strongify(self);
//            if (self.isResultViewShow) {
//                return;
//            }
            if (brightnessValue < 0) {
                if (weakSelf.scanBrightnessModel != BrightnessModelDark_toggleON) {
                    if (weakSelf.scanBrightnessModel != BrightnessModelDark) {
                        weakSelf.scanBrightnessModel = BrightnessModelDark;
                        //停止扫描线
                        [weakSelf.qrAlphaView stopMovingLine];
                        //显示照明开关
                        [weakSelf.torchLightView showLightAnimated:YES completion:^(BOOL finished) {
                            if (weakSelf.canBlinkTorchLightView) {
                                weakSelf.canBlinkTorchLightView = NO;
                                [weakSelf.torchLightView showLightBlinkAnimationWithCount:3];
                            }
                        }];
                    }
                }
                
            }else {
                if (weakSelf.scanBrightnessModel != BrightnessModelLight) {
                    if (weakSelf.scanBrightnessModel != BrightnessModelDark_toggleON) {
                        weakSelf.scanBrightnessModel = BrightnessModelLight;
                        //手电筒关闭才能自动隐藏torchView
                        [weakSelf.qrAlphaView startMovingLine];
                        [weakSelf.torchLightView hideLightAnimated:YES];
                    }
                }
            }
            //NSLog(@"brightnessValue - %f",brightnessValue);
        }];
        [self configReaderPreviewLayer];
    }
    return _codeReader;
}

- (ZSQRAlphaView *)qrAlphaView{
    if (!_qrAlphaView) {
        CGRect screenRect = [ZSQRTool screenBounds];
        _qrAlphaView = [[ZSQRAlphaView alloc]initWithFrame:CGRectMake(screenRect.origin.x, screenRect.origin.y, screenRect.size.width, screenRect.size.height)];
        self.scanReaderRect = _qrAlphaView.transparentRect;
        _qrAlphaView.backgroundColor = [UIColor clearColor];
        [self addLabelView];
        [self adjustMetadataOutputRectOfInterest];
    }
    
    return _qrAlphaView;
}

- (void)addLabelView{
    if (self.scanLabelHintString) {
        UILabel *label = [[UILabel alloc]init];
        [label setFrame:CGRectMake(self.scanReaderRect.origin.x, self.scanReaderRect.origin.y + self.scanReaderRect.size.height + 10, self.scanReaderRect.size.width, 30)];
        label.text = self.scanLabelHintString;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14.0f];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
    }
}

- (ZSQRTorchView *)torchLightView {
    if (!_torchLightView) {
        _torchLightView = [[ZSQRTorchView alloc] initWithFrame:CGRectMake(self.scanReaderRect.origin.x + (self.scanReaderRect.size.width-QRLightingViewWidth)/2, self.scanReaderRect.origin.y+(self.scanReaderRect.size.height-QRLightingViewHeight-10), QRLightingViewWidth, QRLightingViewHeight)];
        _torchLightView.delegate = self;
        _torchLightView.hidden = YES;
        _canBlinkTorchLightView = YES;
    }
    return _torchLightView;
}

#pragma mark - other
///配置ReaderPreviewLayer
- (void)configReaderPreviewLayer {
    //5.2.设置图层的frame
    self.codeReader.previewLayer.frame = self.view.bounds;
    [self manageVideoOrientation];
    //5.4 将图层添加到预览view的图层上
    [self.view.layer insertSublayer:self.codeReader.previewLayer atIndex:0];
}
///调整修正扫描区域
- (void)adjustMetadataOutputRectOfInterest {
    //修正扫描区域 使其和透明区域一样大
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    
    self.qrAlphaView.center = CGPointMake(screenWidth / 2, screenHeight / 2);
    CGRect cropRect = CGRectMake((screenWidth - self.scanReaderRect.size.width) / 2, (screenHeight - self.scanReaderRect.size.height) / 2 + self.ajustTransparentAreaY, self.scanReaderRect.size.width, self.scanReaderRect.size.height);
    [self.codeReader setRectOfInterest:cropRect width:screenWidth height:screenHeight];
}
///手电筒开关点击
- (void)torchSwitchClick {
    if (self.codeReader.isTorchAvailable) {
        //@weakify(self);
        __weak typeof(self) weakSelf = self;
        [self.codeReader toggleTorch:^(BOOL torchOnOff) {
            //@strongify(self);
            if (torchOnOff) {
                weakSelf.scanBrightnessModel = BrightnessModelDark_toggleON;
            }else {
                weakSelf.scanBrightnessModel = BrightnessModelOrigin;
            }
        }];
    }
}

#pragma mark - VideoOrientation 设备方向

- (void)orientationChanged:(NSNotification *)notification {
    [self manageVideoOrientation];
}
- (void)manageVideoOrientation {
    //5.3
    if ([self.codeReader.previewLayer.connection isVideoOrientationSupported]) {
        self.codeReader.previewLayer.connection.videoOrientation = [ZSQRTool videoOrientationFromCurrentDeviceOrientation];
    }
}
@end
