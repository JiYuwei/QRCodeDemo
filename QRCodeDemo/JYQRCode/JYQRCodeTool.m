//
//  JYQRCodeTool.m
//  QRCodeDemo
//
//  Created by 纪宇伟 on 2017/6/27.
//  Copyright © 2017年 jyw. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import "JYQRCodeTool.h"

@interface JYQRCodeTool () <AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)AVCaptureDevice            *jyDevice;
@property(nonatomic,strong)AVCaptureDeviceInput       *jyInput;
@property(nonatomic,strong)AVCaptureMetadataOutput    *jyOutput;
@property(nonatomic,strong)AVCaptureSession           *jySession;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *jyPreview;

@property(nonatomic,weak)UIViewController *bindVC;

@end


@implementation JYQRCodeTool

+(instancetype)toolsWithBindingController:(UIViewController *)controller
{
    return [[self alloc] initWithBindingController:controller];
}

-(instancetype)initWithBindingController:(UIViewController *)controller
{
    if (self = [super init]) {
        if (_bindVC != controller) {
            _bindVC = controller;
        }
    }
    
    return self;
}

#pragma mark - Public

-(void)jy_setUpCaptureWithRect:(CGRect)rect
{
    [self setCropRect:rect];
    
    CGSize cSize = [UIScreen mainScreen].bounds.size;
    //计算rectOfInterest 注意x,y交换位置
    CGRect rectOfInterest = CGRectMake(rect.origin.y/cSize.height, rect.origin.x/cSize.width, rect.size.height/cSize.height,rect.size.width/cSize.width);
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self setUpCaptureWithRect:rectOfInterest];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"设备不支持该功能" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


-(void)jy_controlTheFlashLight:(BOOL)lock
{
    if (lock) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSError *error =nil;
        
        if([device hasTorch]) {
            BOOL locked = [device lockForConfiguration:&error];
            
            if(locked) {
                device.torchMode= AVCaptureTorchModeOn;
                [device unlockForConfiguration];
            }
        }
    }
    else{
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
    }
}

-(void)jy_resetScaning;
{
    if (_jySession && !_jySession.isRunning) {
        [_jySession startRunning];
    }
}


#pragma mark - Private

//添加遮罩
- (void)setCropRect:(CGRect)cropRect{
    
    CAShapeLayer *cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, _bindVC.view.bounds);
    
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:[UIColor blackColor].CGColor];
    [cropLayer setOpacity:0.6];
    
    [_bindVC.view.layer addSublayer:cropLayer];
}

- (void)setUpCaptureWithRect:(CGRect)rectOfInterest
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"相机权限已关闭" message:@"请在设置->隐私->相机中，允许app访问相机。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else{
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
            [_bindVC.view.layer insertSublayer:_jyPreview atIndex:0];
            
            [_jySession startRunning];
        });
    }
}

//播放扫描音效
-(void)playScanSoundsWithName:(NSString *)soundName
{
    // 获取音频文件路径
    NSURL *url = [[NSBundle mainBundle] URLForResource:soundName withExtension:nil];
    
    // 加载音效文件并创建 SoundID
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    
    // 设置播放完成回调
    //    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    
    // 播放音效
    // 带有震动
    //    AudioServicesPlayAlertSound(_soundID);
    // 无振动
    AudioServicesPlaySystemSoundWithCompletion(soundID, ^{
        AudioServicesDisposeSystemSoundID(soundID);
    });
    
    // 销毁 SoundID
    //    AudioServicesDisposeSystemSoundID(soundID);
}

#pragma mark - Delegate

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [_jySession stopRunning];
            
            if (_scanVoiceName) {
                [self playScanSoundsWithName:_scanVoiceName];
            }
            
            AVMetadataMachineReadableCodeObject *readableObj = metadataObjects.firstObject;
            NSString *outPutString = readableObj.stringValue;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(jy_succeedOutputMataDataObjectToString:)]) {
                    [_delegate jy_succeedOutputMataDataObjectToString:outPutString];
                }
            });
        });
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_bindVC.navigationController popViewControllerAnimated:YES];
}

@end
