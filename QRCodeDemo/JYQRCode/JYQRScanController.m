//
//  JYQRScanController.m
//  QRCodeDemo
//
//  Created by 纪宇伟 on 2017/6/26.
//  Copyright © 2017年 jyw. All rights reserved.
//

#import "JYQRScanController.h"
#import <AVFoundation/AVFoundation.h>

@interface JYQRScanController () <AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)AVCaptureDevice            *jyDevice;
@property(nonatomic,strong)AVCaptureDeviceInput       *jyInput;
@property(nonatomic,strong)AVCaptureMetadataOutput    *jyOutput;
@property(nonatomic,strong)AVCaptureSession           *jySession;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *jyPreview;

@property(nonatomic,strong)UIView *jyScanRectView;

@end

@implementation JYQRScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"扫一扫";
    
    [self setUpCapture];
    [self setUpRectView];
}

- (void)setUpCapture
{
    _jyDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _jyInput = [AVCaptureDeviceInput deviceInputWithDevice:_jyDevice error:nil];
    
    _jyOutput = [[AVCaptureMetadataOutput alloc] init];
    [_jyOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _jySession = [[AVCaptureSession alloc] init];
    [_jySession setSessionPreset:([UIScreen mainScreen].bounds.size.height<500)?AVCaptureSessionPreset640x480:AVCaptureSessionPresetHigh];
    [_jySession addInput:_jyInput];
    [_jySession addOutput:_jyOutput];
    
    _jyOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    _jyOutput.rectOfInterest = CGRectMake(50, 50, 200, 200);
    
    _jyPreview = [AVCaptureVideoPreviewLayer layerWithSession:_jySession];
    _jyPreview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _jyPreview.frame = [[UIScreen mainScreen] bounds];
    [self.view.layer insertSublayer:_jyPreview atIndex:0];
    
    [_jySession startRunning];
}

-(void)setUpRectView
{
    CGSize cSize = [UIScreen mainScreen].bounds.size;
    
    CGSize scanSize = CGSizeMake(cSize.width * 3/4, cSize.width * 3/4);
    CGRect scanRect = CGRectMake((cSize.width - scanSize.width) / 2, (cSize.height - scanSize.height) / 2, scanSize.width, scanSize.height);
    
    //计算rectOfInterest 注意x,y交换位置
    CGRect rectOfInterest = CGRectMake(scanRect.origin.y/cSize.height, scanRect.origin.x/cSize.width, scanRect.size.height/cSize.height,scanRect.size.width/cSize.width);
    _jyOutput.rectOfInterest = rectOfInterest;
    
    _jyScanRectView = [[UIView alloc] initWithFrame:scanRect];
    _jyScanRectView.layer.borderColor = [UIColor grayColor].CGColor;
    _jyScanRectView.layer.borderWidth = 1.0;
    [self.view addSubview:_jyScanRectView];
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
