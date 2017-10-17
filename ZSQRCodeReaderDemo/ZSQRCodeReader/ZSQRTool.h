//
//  ZSQRTool.h
//  CheFu365
//
//  Created by safiri on 2017/10/17.
//  Copyright © 2017年 safiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "NSBundle+ZSQRReader.h"

@interface ZSQRTool : NSObject
+ (CGRect)screenBounds;

//此项目一直是竖屏
+ (AVCaptureVideoOrientation)videoOrientationFromCurrentDeviceOrientation;
@end
