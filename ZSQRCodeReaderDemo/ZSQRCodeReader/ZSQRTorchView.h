//
//  ZSQRTorchView.h
//  CheFu365
//
//  Created by safiri on 2017/10/17.
//  Copyright © 2017年 safiri. All rights reserved.
//

#import <UIKit/UIKit.h>
#define QRLightingViewWidth 75
#define QRLightingViewHeight 75

@protocol QRTorchViewDelegate <NSObject>
/**
 手电筒开关点击回调
 */
- (void)torchSwitchClick;
@end
@interface ZSQRTorchView : UIView

@property (nonatomic ,weak) id <QRTorchViewDelegate> _Nullable delegate;

- (void)showLightAnimated:(BOOL)animated;
- (void)showLightAnimated:(BOOL)animated completion:(void (^_Nullable)(BOOL finished))completion;
- (void)hideLightAnimated:(BOOL)animated;
- (void)showLightBlinkAnimation;
- (void)showLightBlinkAnimationWithCount:(NSInteger)count;

@end
