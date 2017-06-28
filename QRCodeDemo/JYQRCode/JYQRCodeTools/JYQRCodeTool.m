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

+ (instancetype)toolsWithBindingController:(UIViewController *)controller
{
    return [[self alloc] initWithBindingController:controller];
}

- (instancetype)initWithBindingController:(UIViewController *)controller
{
    if (self = [super init]) {
        if (_bindVC != controller) {
            _bindVC = controller;
        }
    }
    
    return self;
}

#pragma mark - Public

- (void)jy_setUpCaptureWithRect:(CGRect)rect
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


- (void)jy_controlTheFlashLight:(BOOL)lock
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

- (void)jy_resetScaning;
{
    if (_jySession && !_jySession.isRunning) {
        [_jySession startRunning];
    }
}

+ (UIImage *)jy_createQRCodeWithString:(NSString *)string size:(CGFloat)size
{
    return [self createNonInterpolatedUIImageFormCIImage:[self createQRForString:string] withSize:size];
}

+ (UIImage *)jy_customQRCodeWithImage:(UIImage *)qrImage colorWithRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue
{
    return [self imageBlackToTransparent:qrImage withRed:red andGreen:green andBlue:blue];
}

+(UIImage *)jy_customQRCodeWithImage:(UIImage *)qrImage addAvatarImage:(UIImage *)avatarImage
{
    return [self imagewithQRImage:qrImage addAvatarImage:avatarImage ofTheSize:qrImage.size];
}

+(NSString *)jy_detectorQRCodeImageWithSourceImage:(UIImage *)sourceImage
{
    return [self detectorQRCodeImageWithSourceImage:sourceImage];
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
- (void)playScanSoundsWithName:(NSString *)soundName
{
    if (soundName) {
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
}

//生成二维码
+ (CIImage *)createQRForString:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // 返回CIImage
    return qrFilter.outputImage;
}

//缩放二维码尺寸
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

//颜色填充
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow *imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t *pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900)    // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return resultUIImage;
}

//添加logo
+ (UIImage *)imagewithQRImage:(UIImage *)qrImage addAvatarImage:(UIImage *)avatarImage ofTheSize:(CGSize)size
{
    if (!avatarImage) {
        return qrImage;
    }
    BOOL opaque = 0.0;
    // 获取当前设备的scale
    CGFloat scale = [UIScreen mainScreen].scale;
    // 创建画布Rect
    CGRect qrRect = CGRectMake(0, 0, size.width, size.height);
    // 头像大小 _不能大于_ 画布的1/4 （这个大小之内的不会遮挡二维码的有效信息）
    CGFloat avatarWidth = (size.width/5.0);
    CGFloat avatarHeight = avatarWidth;
    //调用一个新的切割绘图方法 crop image add cornerRadius  (裁切头像图片为圆角，并添加bored   返回一个newimage)
    avatarImage = [self clipCornerRadius:avatarImage withSize:CGSizeMake(avatarWidth, avatarHeight)];
    // 设置头像的位置信息
    CGPoint position = CGPointMake(size.width/2.0, size.height/2.0);
    CGRect avatarRect = CGRectMake(position.x-(avatarWidth/2.0), position.y-(avatarHeight/2.0), avatarWidth, avatarHeight);
    // 设置画布信息
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);{// 开启画布
        // 翻转context （画布）
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        // 根据 bgRect 用二维码填充视图
        CGContextDrawImage(context, qrRect, qrImage.CGImage);
        //  根据newAvatarImage 填充头像区域
        CGContextDrawImage(context, avatarRect, avatarImage.CGImage);
    }CGContextRestoreGState(context);// 提交画布
    // 从画布中提取图片
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    // 释放画布
    UIGraphicsEndImageContext();
    
    return resultImage;
}

//logo圆角设置
+ (UIImage *)clipCornerRadius:(UIImage *)image withSize:(CGSize)size
{
    // 白色border的宽度
    CGFloat outerWidth = size.width/15.0;
    // 黑色border的宽度
    CGFloat innerWidth = outerWidth/10.0;
    // 圆角这个就是我觉着的适合的一个值 ，可以自行改
    CGFloat corenerRadius = size.width/8.0;
    // 为context创建一个区域
    CGRect areaRect = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *areaPath = [UIBezierPath bezierPathWithRoundedRect:areaRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(corenerRadius, corenerRadius)];
    
    // 因为UIBezierpath划线是双向扩展的 初始位置就不会是（0，0）
    // path的位置就应该是你画的宽度的中间， 这个需要自己手动计算一下。
    // origin position
    CGFloat outerOrigin = outerWidth/2.0;
    CGFloat innerOrigin = innerWidth/2.0 + outerOrigin/1.2;
    CGRect outerRect = CGRectInset(areaRect, outerOrigin, outerOrigin);
    CGRect innerRect = CGRectInset(outerRect, innerOrigin, innerOrigin);
    // 要进行rect之间的计算，我想 "CGRectInset" 是一个不错的选择。
    //  外层path
    UIBezierPath *outerPath = [UIBezierPath bezierPathWithRoundedRect:outerRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(outerRect.size.width/8.0, outerRect.size.width/8.0)];
    //  内层path
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithRoundedRect:innerRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(innerRect.size.width/8.0, innerRect.size.width/8.0)];
    // 要保证"内外层"的吻合，那就要进行比例相等，就能达到形状的完全匹配
    // 创建上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);{
        // 翻转context
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        // context  添加 区域path -> 进行裁切画布
        CGContextAddPath(context, areaPath.CGPath);
        CGContextClip(context);
        // context 添加 背景颜色，避免透明背景会展示后面的二维码不美观的。（当然也可以对想遮住的区域进行clear操作，但是我当时写的时候还没有想到）
        CGContextAddPath(context, areaPath.CGPath);
        UIColor *fillColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        CGContextFillPath(context);
        // context 执行画头像
        CGContextDrawImage(context, innerRect, image.CGImage);
        // context 添加白色的边框 -> 执行填充白色画笔
        CGContextAddPath(context, outerPath.CGPath);
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(context, outerWidth);
        CGContextStrokePath(context);
        // context 添加黑色的边界 -> 执行填充黑色画笔
        CGContextAddPath(context, innerPath.CGPath);
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(context, innerWidth);
        CGContextStrokePath(context);
    }CGContextRestoreGState(context);
    UIImage *radiusImage  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return radiusImage;
}

+ (NSString *)detectorQRCodeImageWithSourceImage:(UIImage *)sourceImage
{
    // 0.创建上下文
    CIContext *context = [[CIContext alloc] init];
    // 1.创建一个探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    
    // 2.直接开始识别图片,获取图片特征
    CIImage *imageCI = [[CIImage alloc] initWithImage:sourceImage];
    NSArray<CIFeature *> *features = [detector featuresInImage:imageCI];
    
    // 3.读取特征
    CIFeature *feature = features.firstObject;
    NSString *msgString = nil;
    
    if ([feature isKindOfClass:[CIQRCodeFeature class]]) {
        CIQRCodeFeature *tempFeature = (CIQRCodeFeature *)feature;
        msgString = tempFeature.messageString;
    }
    
    // 4.传递数据给外界
    return msgString;
}

#pragma mark - Delegate

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [_jySession stopRunning];
            
            [self playScanSoundsWithName:_scanVoiceName];
            
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
