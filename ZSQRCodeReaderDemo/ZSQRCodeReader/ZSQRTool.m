//
//  ZSQRTool.m
//  CheFu365
//
//  Created by safiri on 2017/10/17.
//  Copyright © 2017年 safiri. All rights reserved.
//

#import "ZSQRTool.h"

@implementation ZSQRTool

+ (CGRect)screenBounds{
    UIScreen *screen = [UIScreen mainScreen];
    CGRect screenRect;
    if (![screen respondsToSelector:@selector(fixedCoordinateSpace)] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        screenRect = CGRectMake(0, 0, screen.bounds.size.height, screen.bounds.size.width);
    }else{
        screenRect = screen.bounds;
    }
    return screenRect;
}

+ (AVCaptureVideoOrientation)videoOrientationFromCurrentDeviceOrientation{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait) {
        return AVCaptureVideoOrientationPortrait;
    }else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        
        return AVCaptureVideoOrientationLandscapeLeft;
        
    }else if (orientation == UIInterfaceOrientationLandscapeRight){
        
        return AVCaptureVideoOrientationLandscapeRight;
    }else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        
        return AVCaptureVideoOrientationPortraitUpsideDown;
    }
    return AVCaptureVideoOrientationPortrait;
}
@end
