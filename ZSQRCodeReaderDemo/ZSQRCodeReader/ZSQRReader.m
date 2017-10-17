//
//  ZSQRReader.m
//  CheFu365
//
//  Created by safiri on 2017/10/17.
//  Copyright © 2017年 safiri. All rights reserved.
//

#import "ZSQRReader.h"
@interface ZSQRReader ()<AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic ,assign) NSInteger didOutputSampleBufferCount;

@property (strong, nonatomic) AVCaptureDevice            *defaultDevice;
@property (strong, nonatomic) AVCaptureDeviceInput       *defaultDeviceInput;
@property (strong, nonatomic) AVCaptureMetadataOutput    *metadataOutput;
@property (strong, nonatomic) AVCaptureSession           *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation ZSQRReader
#pragma mark - init QRReader
- (instancetype)initWithMetadataObjectTypes:(NSArray<AVMetadataObjectType> * _Nullable)metadataObjectTypes {
    if (self = [super init]) {
        if (metadataObjectTypes == nil) {
            _metadataObjectTypes = [ZSQRReader defaultMetadataObjectTypes];
        }else {
            _metadataObjectTypes = metadataObjectTypes;
        }
        [self setupScanComponents];
    }
    return self;
}
+ (instancetype)readerWithMetadataObjectTypes:(NSArray<AVMetadataObjectType> * _Nullable)metadataObjectTypes {
    return [[self alloc] initWithMetadataObjectTypes:metadataObjectTypes];
}

+(instancetype)readerWithDefaultMetadataObjectTypes {
    return [[self alloc] initWithMetadataObjectTypes:nil];
}
#pragma mark - 设置扫描部件
- (void)setupScanComponents {
    //关系http://blog.163.com/chester_lp/blog/static/139794082012119112834437/
    //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo 可以理解为打开摄像头这样的动作
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.defaultDevice = captureDevice;
    BOOL canSetup = NO;
    if (_defaultDevice) {
        //2.用captureDevice创建输入流,//获取一个AVCaptureDeviceInput对象，将上面的'摄像头'作为输入设备
        NSError *error = nil;
        self.defaultDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (!error) {
            canSetup = YES;
        }
    }
    if (!canSetup) {
        
        return;
    }
    
    //3.创建媒体数据输出流 拍完照片以后，需要一个AVCaptureMetadataOutput对象将获取的'图像'输出，以便进行对其解析
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    //4.实例化捕捉会话
    self.session = [[AVCaptureSession alloc] init];
    //5.实例化预览图层 设置相机的取景器
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    
    [self configureDefaultComponents];
}
- (void)configureDefaultComponents {
    
    //4.1.将输入流添加到会话
    if ([self.session canAddInput:self.defaultDeviceInput]) {
        [self.session addInput:self.defaultDeviceInput];
    }
    //4.2.将媒体输出流添加到会话中
    if ([self.session canAddOutput:self.metadataOutput]) {
        [self.session addOutput:self.metadataOutput];
    }
    
    //3.1 设置代理 并将媒体输出流添加到串行队列当中 //获取输出需要设置代理，在代理方法中获取
    dispatch_queue_t dispatchQueue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);
    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    //先设置session的output再设置output.metadataObjectTypes，否则崩溃
    //3.2设置输出类型，如AVMetadataObjectTypeQRCode是二维码类型，
    [self.metadataOutput setMetadataObjectTypes:self.metadataObjectTypes];
    
    //5.1设置预览图层填充方式
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //    //5.2.设置图层的frame
    //    _previewLayer.frame = self.view.bounds;
    //    //5.3 将图层添加到预览view的图层上
    //    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    //    _previewLayer.connection.videoOrientation = [QRTool videoOrientationFromCurrentDeviceOrientation];
}
- (void)setRectOfInterest:(CGRect)cropRect width:(CGFloat)width height:(CGFloat)height{
    //3.3.设置扫描范围
    //设计的坐标已反 rectOfInterest都是按照横屏来计算的，所以当竖屏的情况下x轴和y轴要交换一下
    _metadataOutput.rectOfInterest = CGRectMake(cropRect.origin.y / height,cropRect.origin.x / width,cropRect.size.height / height,cropRect.size.width / width);
}
- (void)configureVideoDataOutputComponents {
    //获取实时拍照的视频流
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    dispatch_queue_t queue = dispatch_queue_create("myQueue1", DISPATCH_QUEUE_CONCURRENT);
    [videoDataOutput setSampleBufferDelegate:self queue:queue];
    videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    videoDataOutput.alwaysDiscardsLateVideoFrames=YES;
    
    if ([self.session canAddOutput:videoDataOutput]) {
        [self.session addOutput:videoDataOutput];
    }
}

//CMTimeMake(1,15)
- (void)configureCaptureDeviceVideoMinFrameDuration:(CMTime)min VideoMaxFrameDuration:(CMTime)max{
    //1.2设置帧速率
    for (AVCaptureDeviceFormat *vFormat in [self.defaultDevice formats]) {
        /**获取相关数据
         CMFormatDescriptionRef description = vFormat.formatDescription;
         AVFrameRateRange *range = (AVFrameRateRange *)[vFormat.videoSupportedFrameRateRanges objectAtIndex:0];
         float minrate = range.minFrameRate;//默认的最小fps ..2
         float maxrate = range.maxFrameRate;//默认的最小fps ..60
         CMTime minframeDuration = range.minFrameDuration;// ..minframeDuration = 1 60th of a second {value = 1 timescale = 60 flags = kCMTimeFlags_Valid epoch = 0}
         CMTime maxframeDuration = range.maxFrameDuration;//..maxframeDuration = 1 half seconds {value = 1 timescale = 2 flags = kCMTimeFlags_Valid epoch = 0}
         if (maxrate > 59) {
         
         }
         **/
        if ([self.defaultDevice lockForConfiguration:NULL]) {
            self.defaultDevice.activeFormat = vFormat;
            //降低帧速率，降低CPU使用，但是会降低识别二维码的速度 默认为60
            //使用15FPS,降低了CPU4%
            [self.defaultDevice setActiveVideoMinFrameDuration:min];//15fps
            [self.defaultDevice setActiveVideoMaxFrameDuration:max];
            
            [self.defaultDevice unlockForConfiguration];
            //NSLog(@"formats  %@ %@ %@",vFormat.mediaType,vFormat.formatDescription,vFormat.videoSupportedFrameRateRanges);
        }
        
    }
}

#pragma mark - getter setter
+ (NSArray<AVMetadataObjectType> *)defaultMetadataObjectTypes {
    
    return @[AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeQRCode];;
}

#pragma mark - Control Reader
- (void)startScanning{
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}
- (void)stopScanning{
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
}
- (BOOL)isRunning {
    return self.session.isRunning;
}

- (BOOL)isTorchAvailable{
    return _defaultDevice.hasTorch&&_defaultDevice.isTorchAvailable;
}

- (void)toggleTorch:(void(^)(BOOL torchOnOff))torchOnOffBlock{
    NSError *error = nil;
    
    [_defaultDevice lockForConfiguration:&error];
    
    if (error == nil) {
        AVCaptureTorchMode mode = _defaultDevice.torchMode;
        BOOL onoff = mode == AVCaptureTorchModeOn;
        if (torchOnOffBlock) {
            torchOnOffBlock(!onoff);
        }
        _defaultDevice.torchMode = onoff ? AVCaptureTorchModeOff : AVCaptureTorchModeOn;
    }
    [_defaultDevice unlockForConfiguration];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    [self.session stopRunning];//停止会话
    
    for (AVMetadataObject *current in metadataObjects) {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]
            && [_metadataObjectTypes containsObject:current.type]) {
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
            dispatch_sync(dispatch_get_main_queue(), ^{
                //主线程
                AudioServicesPlaySystemSound(1007);
                if (scannedResult) {
                    if (self.completionBlock) {
                        self.completionBlock(scannedResult);
                    }
                }else {
                    if (self.readerErrorBlock) {
                        self.readerErrorBlock(@"扫码失败,请确定码是否正确或重试");
                    }
                }
            });
            
            break;
        }
    }
}
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate 读取环境光亮度

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    self.didOutputSampleBufferCount += 1;
    if (self.didOutputSampleBufferCount%20 == 0) { //降低灵敏度
        self.didOutputSampleBufferCount = 0;
        //将系统有关摄像头采集到的信息返回，通过CMCopyDictionary...方法转换成一个CFDictionaryRef类型的字典。里面包含了环境亮度值还有摄像头光圈等等信息。
        CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
        //将CFDictionaryRef字典转换成为NSDctionary，便于操作和取值。
        NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary *)metadataDict];
        //释放Ref，防止内存泄露
        CFRelease(metadataDict);
        //通过Key，取Value。Key值可以直接输出MetaData进行查看，也可以用SDK定义好的进行取值（例如kCGImagePropertyExifDictionary对应的其实是{Exif}）。
        NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
        float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
        //NSLog(@"%f",brightnessValue);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.scanBrightnessBlock) {
                self.scanBrightnessBlock(brightnessValue);
            }
        });
    }
}

#pragma mark - 检查Reader是否可用

+ (BOOL)isAvailable
{
    @autoreleasepool {
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if (!captureDevice) {
            return NO;
        }
        
        NSError *error;
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        
        if (!deviceInput || error) {
            return NO;
        }
        
        return YES;
    }
}

+ (BOOL)supportsMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
    if (![self isAvailable]) {
        return NO;
    }
    
    @autoreleasepool {
        // Setup components
        AVCaptureDevice *captureDevice    = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
        AVCaptureMetadataOutput *output   = [[AVCaptureMetadataOutput alloc] init];
        AVCaptureSession *session         = [[AVCaptureSession alloc] init];
        
        [session addInput:deviceInput];
        [session addOutput:output];
        
        if (metadataObjectTypes == nil || metadataObjectTypes.count == 0) {
            // Check the QRCode metadata object type by default
            metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        }
        
        for (NSString *metadataObjectType in metadataObjectTypes) {
            if (![output.availableMetadataObjectTypes containsObject:metadataObjectType]) {
                return NO;
            }
        }
        
        return YES;
    }
}
@end
