//
//  JYQRScanController.m
//  QRCodeDemo
//
//  Created by 纪宇伟 on 2017/6/26.
//  Copyright © 2017年 jyw. All rights reserved.
//

#import "JYQRScanController.h"
#import <AVFoundation/AVFoundation.h>
#import "JYScanRectView.h"

@interface JYQRScanController () <AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)AVCaptureDevice            *jyDevice;
@property(nonatomic,strong)AVCaptureDeviceInput       *jyInput;
@property(nonatomic,strong)AVCaptureMetadataOutput    *jyOutput;
@property(nonatomic,strong)AVCaptureSession           *jySession;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *jyPreview;

@property(nonatomic,strong)JYScanRectView *jyScanRectView;

@end


@implementation JYQRScanController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(openPhotoLibrary)];
    self.navigationItem.title = @"扫一扫";
    
    
    CGSize cSize = [UIScreen mainScreen].bounds.size;
    
    CGSize scanSize = CGSizeMake(cSize.width * 3/4, cSize.width * 3/4);
    CGRect scanRect = CGRectMake((cSize.width - scanSize.width) / 2, (cSize.height - scanSize.height) / 2, scanSize.width, scanSize.height);
    
    [self setCropRect:scanRect];
    
    //计算rectOfInterest 注意x,y交换位置
    CGRect rectOfInterest = CGRectMake(scanRect.origin.y/cSize.height, scanRect.origin.x/cSize.width, scanRect.size.height/cSize.height,scanRect.size.width/cSize.width);
    
    [self setUpCaptureWithRect:rectOfInterest];
    [self setUpRectViewWithRect:scanRect];
}

- (void)setUpCaptureWithRect:(CGRect)rectOfInterest
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _jyDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _jyInput = [AVCaptureDeviceInput deviceInputWithDevice:_jyDevice error:nil];
        
        _jyOutput = [[AVCaptureMetadataOutput alloc] init];
        [_jyOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        _jySession = [[AVCaptureSession alloc] init];
        [_jySession setSessionPreset:([UIScreen mainScreen].bounds.size.height<500)?AVCaptureSessionPreset640x480:AVCaptureSessionPresetHigh];
        [_jySession addInput:_jyInput];
        [_jySession addOutput:_jyOutput];
        
        _jyOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        _jyOutput.rectOfInterest = rectOfInterest;
        
        _jyPreview = [AVCaptureVideoPreviewLayer layerWithSession:_jySession];
        _jyPreview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _jyPreview.frame = [[UIScreen mainScreen] bounds];
        [self.view.layer insertSublayer:_jyPreview atIndex:0];
        
        [_jySession startRunning];
    });
}

-(void)setUpRectViewWithRect:(CGRect)scanRect
{
    _jyScanRectView = [[JYScanRectView alloc] initWithFrame:scanRect];
    [self.view addSubview:_jyScanRectView];
}

- (void)setCropRect:(CGRect)cropRect{
    
    CAShapeLayer *cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, self.view.bounds);
    
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:[UIColor blackColor].CGColor];
    [cropLayer setOpacity:0.6];
    
    [self.view.layer addSublayer:cropLayer];
}


-(void)openPhotoLibrary
{
    
}


#pragma mark - Delegate

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        [_jySession stopRunning];
        
        AVMetadataMachineReadableCodeObject *readableObj = metadataObjects.firstObject;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:readableObj.stringValue message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [_jySession startRunning];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
