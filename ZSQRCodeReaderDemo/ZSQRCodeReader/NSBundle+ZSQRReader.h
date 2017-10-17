//
//  NSBundle+ZSQRReader.h
//  ZSQRCodeReaderDemo
//
//  Created by safiri on 2017/10/17.
//  Copyright © 2017年 safiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSBundle (ZSQRReader)
+ (instancetype)QRReaderBundle;
+ (UIImage *)bundleImageNamed:(NSString *)name;
@end
