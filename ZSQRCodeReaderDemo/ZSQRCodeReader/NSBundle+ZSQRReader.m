//
//  NSBundle+ZSQRReader.m
//  ZSQRCodeReaderDemo
//
//  Created by safiri on 2017/10/17.
//  Copyright © 2017年 safiri. All rights reserved.
//

#import "NSBundle+ZSQRReader.h"
#import "ZSQRReader.h"
@implementation NSBundle (ZSQRReader)
+ (instancetype)QRReaderBundle {
    static NSBundle *refreshBundle = nil;
    if (refreshBundle == nil) {
        refreshBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[ZSQRReader class]] pathForResource:@"ZSQRCodeReader" ofType:@"bundle"]];
    }
    return refreshBundle;
}
+ (UIImage *)bundleImageNamed:(NSString *)name{
    name = [name stringByAppendingString:@"@2x"];
    NSString *imagePath = [[NSBundle QRReaderBundle] pathForResource:name ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (!image) {
        // 兼容业务方自己设置图片的方式
        name = [name stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
        image = [UIImage imageNamed:name];
    }
    return image;
}
@end
