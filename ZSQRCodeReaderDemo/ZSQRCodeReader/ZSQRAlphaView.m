//
//  ZSQRAlphaView.m
//  CheFu365
//
//  Created by safiri on 2017/10/17.
//  Copyright © 2017年 safiri. All rights reserved.
//

#import "ZSQRAlphaView.h"
#import "ZSQRTool.h"


static NSTimeInterval kQrLineanimateDuration = 0.02f;
static CGFloat BorderLineWidth = 0.8f;//白色正方形框的宽度
static CGFloat CornerLineWidth = 2.0f;//四个角的宽度

@interface ZSQRAlphaView ()
@property (nonatomic ,strong) NSTimer *timer;
@property (nonatomic ,assign ,readwrite)BOOL isLineMoving;

@end
@implementation ZSQRAlphaView

{
    UIImageView *qrLine;
    CGFloat qrLineOriginY;
    CGFloat qrLineY;
}


#pragma mark - UI
- (void)initQRLine{
    qrLineOriginY = self.transparentRect.origin.y;
    qrLine = [[UIImageView alloc]initWithFrame:CGRectMake(self.transparentRect.origin.x, qrLineOriginY, self.transparentRect.size.width, 1.4)];
    [qrLine setImage:[NSBundle bundleImageNamed:@"qrline"]];
    qrLine.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:qrLine];
    qrLineY = qrLineOriginY;
}

- (CGFloat)transparentSide {
    if (_transparentSide == 0) {
        CGSize screenSize = [ZSQRTool screenBounds].size;
        _transparentSide = screenSize.width * 0.718;
    }
    return _transparentSide;
}
- (CGRect)transparentRect {
    if (CGRectEqualToRect(_transparentRect, CGRectZero)) {
        CGSize screenSize = [ZSQRTool screenBounds].size;
        _transparentRect = CGRectMake((screenSize.width - self.transparentSide)/2, (screenSize.height - self.transparentSide)/ 2+self.ajustTransparentAreaY, self.transparentSide, self.transparentSide);
    }
    return _transparentRect;
}

- (void)dealloc {
    [self stopMovingLine];
    //NSLog(@"memory leak******QRAlphaView");
}
#pragma mark - draw Rect
- (void)layoutSubviews{
    [super layoutSubviews];
    if (!qrLine) {
        [self initQRLine];
        [self startMovingLine];
    }
    
}
- (void)drawRect:(CGRect)rect {
    
    //整个二维码扫描界面的颜色
    CGSize screenSize = [ZSQRTool screenBounds].size;
    CGRect screenDrawRect = CGRectMake(0, 0, screenSize.width, screenSize.height);
    
    //中间透明的矩形框 居中
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self addScreenFillRect:context rect:screenDrawRect];
    [self addCenterClearRect:context rect:self.transparentRect];
    [self addWhiteRect:context rect:self.transparentRect];
    [self addCornerLineWithContext:context rect:self.transparentRect];
    
}
- (void)addScreenFillRect:(CGContextRef)context rect:(CGRect)rect{
    
    CGContextSetRGBFillColor(context, 40 / 255.0,40 / 255.0,40 / 255.0,0.5);//颜色
    CGContextFillRect(context, rect);   //绘制透明图层
}
- (void)addCenterClearRect :(CGContextRef)context rect:(CGRect)rect{
    
    CGContextClearRect(context, rect);  //透明图层的rect位置
}
- (void)addWhiteRect:(CGContextRef)context rect:(CGRect)rect{
    
    CGContextStrokeRect(context, rect);
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
    CGContextSetLineWidth(context, BorderLineWidth);
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);
    
}
- (void)addCornerLineWithContext:(CGContextRef)context rect:(CGRect)rect{
    //画四个边角
    CGContextSetLineWidth(context, CornerLineWidth);
    CGContextSetRGBStrokeColor(context, 83/255.0f, 239/255.0f, 111/255.0f, 1);//绿色
    
    CGFloat offset = 0.7;
    //左上角
    CGPoint pointsTopLeftA[] = {//左上y
        CGPointMake(rect.origin.x + offset, rect.origin.y),
        CGPointMake(rect.origin.x + offset, rect.origin.y + 15)
    };
    CGPoint pointsTopLeftB[] = {//左上x
        CGPointMake(rect.origin.x, rect.origin.y + offset),
        CGPointMake(rect.origin.x + 15, rect.origin.y + offset)
    };
    [self addLineWithPointA:pointsTopLeftA pointB:pointsTopLeftB context:context];
    //左下角
    CGPoint pointsBottomLeftA[] = {
        CGPointMake(rect.origin.x + offset, rect.origin.y + rect.size.height - 15),
        CGPointMake(rect.origin.x + offset, rect.origin.y + rect.size.height)
    };
    CGPoint pointsBottomLeftB[] = {
        CGPointMake(rect.origin.x , rect.origin.y + rect.size.height - offset) ,
        CGPointMake(rect.origin.x + offset + 15, rect.origin.y + rect.size.height - offset)
    };
    [self addLineWithPointA:pointsBottomLeftA pointB:pointsBottomLeftB context:context];
    //右上角
    CGPoint pointsTopRightA[] = {
        CGPointMake(rect.origin.x + rect.size.width - 15, rect.origin.y + offset),
        CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + offset)
    };
    CGPoint pointsTopRightB[] = {
        CGPointMake(rect.origin.x + rect.size.width - offset, rect.origin.y),
        CGPointMake(rect.origin.x + rect.size.width - offset,rect.origin.y + 15 + offset)
    };
    [self addLineWithPointA:pointsTopRightA pointB:pointsTopRightB context:context];
    //右下角
    CGPoint pointsBottomRightA[] = {
        CGPointMake(rect.origin.x + rect.size.width - offset, rect.origin.y + rect.size.height - 15),
        CGPointMake(rect.origin.x - offset + rect.size.width, rect.origin.y + rect.size.height)
    };
    CGPoint pointsBottomRightB[] = {
        CGPointMake(rect.origin.x + rect.size.width - 15, rect.origin.y + rect.size.height - offset),
        CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - offset)
    };
    [self addLineWithPointA:pointsBottomRightA pointB:pointsBottomRightB context:context];
    CGContextStrokePath(context);
}
- (void)addLineWithPointA:(CGPoint[])pointA pointB:(CGPoint[])pointB context:(CGContextRef)context{
    CGContextAddLines(context, pointA, CornerLineWidth);
    CGContextAddLines(context, pointB, CornerLineWidth);
}
#pragma mark -
- (void)startMovingLine {
    qrLine.hidden = NO;
    self.isLineMoving = YES;
    if (!self.timer) {
        self.timer = [NSTimer timerWithTimeInterval:kQrLineanimateDuration target:self selector:@selector(moveScanLine) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}
- (void)stopMovingLine {
    qrLine.hidden = YES;
    self.isLineMoving = NO;
    qrLineY = qrLineOriginY;
    [self moveQRLineView];
    [self.timer invalidate];
    self.timer = nil;
}
- (void)moveScanLine{
    //扫描动画 控制Y坐标
    [UIView animateWithDuration:0 animations:^{ //耗费CPU
        [self moveQRLineView];
    } completion:^(BOOL finished) {
        if (self.isLineMoving == NO) {
            return;
        }
        CGFloat maxBorder = qrLineOriginY+self.transparentSide-2;
        if (qrLineY > maxBorder) {
            qrLineY = qrLineOriginY;
        }
        qrLineY += 1;
    }];
}
- (void)moveQRLineView {
    CGRect rect = qrLine.frame;
    rect.origin.y = qrLineY;
    qrLine.frame = rect;
}

@end
