//
//  ZSQRTorchView.m
//  CheFu365
//
//  Created by safiri on 2017/10/17.
//  Copyright © 2017年 safiri. All rights reserved.
//

#import "ZSQRTorchView.h"
#import "ZSQRTool.h"

@interface ZSQRTorchView ()
@property (nonatomic ,strong) UIButton *toggleTorchBtn;
@property (nonatomic ,assign) NSInteger blinkCount;
@end

@implementation ZSQRTorchView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}
- (void)dealloc {
    //NSLog(@"memory leak******QRLightingView");
}
- (void)configUI {
    self.toggleTorchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toggleTorchBtn.frame = CGRectMake(25, 25, 25, 25);
    [self.toggleTorchBtn setImage:[NSBundle bundleImageNamed:@"qrlighting"] forState:UIControlStateNormal];
    [self.toggleTorchBtn setImage:[NSBundle bundleImageNamed:@"qrlightingH"] forState:UIControlStateHighlighted];
    [self.toggleTorchBtn setImage:[NSBundle bundleImageNamed:@"qrlightingON"] forState:UIControlStateSelected];
    [self.toggleTorchBtn addTarget:self action:@selector(toggleTorchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.toggleTorchBtn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, 75, 20)];
    label.text = @"轻触照亮";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14.0f];
    [self addSubview:label];
}

# pragma mark - show or hide animate
- (void)showLightAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (!self.isHidden) {//已经显示
        return;
    }
    self.hidden = NO;
    self.alpha = 0;
    if (animated) {
        
        __weak typeof(self) weakSelf = self;
        //@weakify(self);
        [UIView animateWithDuration:0.5f animations:^{
            //@strongify(self);
            weakSelf.alpha = 1;
        } completion:^(BOOL finished) {
            //@strongify(self);
            if (completion) {
                completion(finished);
            }
        }];
    }else {
        self.alpha = 1;
    }
}
- (void)showLightAnimated:(BOOL)animated {
    [self showLightAnimated:animated completion:nil];
}
- (void)hideLightAnimated:(BOOL)animated {
    if (self.isHidden) {//已经隐藏
        return;
    }
    if (animated) {
        //@weakify(self);
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.5f animations:^{
            //@strongify(self);
            weakSelf.alpha = 0;
        } completion:^(BOOL finished) {
            //@strongify(self);
            weakSelf.hidden = YES;
        }];
    }else {
        self.hidden = YES;
    }
}
- (void)showLightBlinkAnimation {
    [self showLightBlinkAnimationWithCount:0];
}
- (void)showLightBlinkAnimationWithCount:(NSInteger)count {
    if (self.isHidden) {
        return;
    }
    if (count > 0) {
        self.blinkCount++;
        if (self.blinkCount >= count) {
            return;
        }
    }
    //@weakify(self);
    __weak typeof(self) weakSelf = self;
    [self animate:^{
        //@strongify(self);
        [weakSelf showLightBlinkAnimationWithCount:count];
    }];
}
- (void)animate:(void(^)(void))completion {
    //@weakify(self);
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.7f animations:^{
        //@strongify(self);
        weakSelf.toggleTorchBtn.alpha = 0;
    } completion:^(BOOL finished) {
        //@strongify(self);
        weakSelf.toggleTorchBtn.alpha = 1;
        completion();
    }];
}
#pragma mark - event
- (void)toggleTorchBtnClick {
    
    if ([self.delegate respondsToSelector:@selector(torchSwitchClick)]) {
        self.toggleTorchBtn.selected = !self.toggleTorchBtn.isSelected;
        [self.delegate torchSwitchClick];
    }
}

@end
