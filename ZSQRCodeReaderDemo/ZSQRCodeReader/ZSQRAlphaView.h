//
//  ZSQRAlphaView.h
//  CheFu365
//
//  Created by safiri on 2017/10/17.
//  Copyright © 2017年 safiri. All rights reserved.
//

#import <UIKit/UIKit.h>

///带有中间透明区域的View 覆盖在扫描previewLayer上
@interface ZSQRAlphaView : UIView

///透明的区域Side 默认screenSize.width * 0.718;
@property (nonatomic ,assign) CGFloat transparentSide;
///透明的区域大小Rect
@property (nonatomic, assign)CGRect transparentRect;

@property (nonatomic ,assign ,readonly) BOOL isLineMoving;

///开始UI扫描动作
- (void)startMovingLine;
///停止UI扫描动作
- (void)stopMovingLine;
@end
