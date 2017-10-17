//
//  ViewController.m
//  ZSQRCodeReaderDemo
//
//  Created by safiri on 2017/10/17.
//  Copyright © 2017年 safiri. All rights reserved.
//

#import "ViewController.h"
#import "ZSQRCodeReaderVC.h"

@interface ViewController ()

@end

@implementation ViewController
- (IBAction)scanButtonClick:(id)sender {
    
    if ([ZSQRCodeReaderVC isReadyForCodeReader]) {
        ZSQRCodeReaderVC *codeReaderVC = [[ZSQRCodeReaderVC alloc] init];
        //@weakify(self)
        //@weakify(codeReaderVC)
        __weak typeof (self) weakSelf = self;
        __weak typeof (codeReaderVC) weakCodeReaderVC = codeReaderVC;
        codeReaderVC.completeBlock = ^(NSString *QRString) {
            //@strongify(self)
            //@strongify(codeReaderVC)
            NSLog(@"扫码result: %@", QRString);
            
            [weakCodeReaderVC.navigationController popViewControllerAnimated:YES];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫码result" message:QRString preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:0 handler:nil]];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        };
        codeReaderVC.errorBlock = ^(NSString * _Nullable errorMsg) {
            //@strongify(self);
            //@strongify(codeReaderVC);
            [weakCodeReaderVC.navigationController popViewControllerAnimated:YES];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫码错误" message:errorMsg preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:0 handler:nil]];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        };
        codeReaderVC.scanLabelHintString = @"将条形码放入框内,即可自动扫描";
        [self.navigationController pushViewController:codeReaderVC animated:YES];
    }else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法扫码" message:@"初始化失败,请重试" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:0 handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
