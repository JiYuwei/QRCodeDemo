//
//  ViewController.m
//  QRCodeDemo
//
//  Created by 纪宇伟 on 2017/6/26.
//  Copyright © 2017年 jyw. All rights reserved.
//

#import "ViewController.h"
#import "JYQRScanController.h"

@interface ViewController ()

//@property(nonatomic,strong)UIView *scanView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"首页";
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"扫一扫" style:UIBarButtonItemStylePlain target:self action:@selector(openQRScanVC)];
    
//    _scanView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    _scanView.backgroundColor = [UIColor grayColor];
////    _scanView.alpha = 0.6;
//    _scanView.layer.shadowColor = [UIColor redColor].CGColor;
//    _scanView.layer.shadowOffset = CGSizeMake(0, -5);
//    _scanView.layer.shadowRadius = 5.0;
//    _scanView.layer.shadowOpacity = 1;
//    [self.view addSubview:_scanView];
}

- (void)openQRScanVC
{
    JYQRScanController *jyQRScanVC = [[JYQRScanController alloc] init];
    [self.navigationController pushViewController:jyQRScanVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
