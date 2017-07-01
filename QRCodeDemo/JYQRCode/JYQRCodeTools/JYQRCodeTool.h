//
//  JYQRCodeTool.h
//  QRCodeDemo
//
//  Created by 纪宇伟 on 2017/6/27.
//  Copyright © 2017年 jyw. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JYQRCodeDelegate <NSObject>

/**
 * 扫描成功回调
 **/
- (void)jy_willGetOutputMataDataObject;

/**
 * 数据处理完毕回调
 *
 * @param outPutString 返回的数据
 **/
- (void)jy_didGetOutputMataDataObjectToString:(NSString *)outPutString;

@end


@interface JYQRCodeTool : NSObject

@property(nonatomic,weak) id <JYQRCodeDelegate> delegate;

/**
 * 初始化二维码扫描工具
 *
 * @param controller 扫描界面对应的控制器
 **/
+ (instancetype)toolsWithBindingController:(UIViewController *)controller;


#pragma mark - ScanQRCode

//扫描音效文件名，其值为nil时不播放扫描音，默认为nil
@property(nonatomic,copy)NSString *scanVoiceName;


/**
 * 初始化扫描二维码功能，自动确定扫描范围，范围外的部分加遮罩
 *
 * @param rect 扫描范围
 **/
- (void)jy_setUpCaptureWithRect:(CGRect)rect;


/**
 * 初始化扫描二维码功能，添加完成后回调
 *
 * @param rect       扫描范围
 * @param successCB  完成后回调
 **/
- (void)jy_setUpCaptureWithRect:(CGRect)rect success:(void(^)())successCB;


/**
 * 控制闪光灯开关
 *
 * @param lock 闪光灯开关，YES时开启，NO时关闭，默认为NO
 **/
- (void)jy_controlTheFlashLight:(BOOL)lock;


/**
 * 启用扫描功能
 **/
- (void)jy_startScaning;


/**
 * 禁用扫描功能
 **/
- (void)jy_stopScaning;


#pragma mark - GenerateQRCode

/**
 * 将字符串转成二维码
 *
 * @param string  字符串
 * @param size    二维码图片尺寸
 *
 * @return 二维码图片
 **/
+ (UIImage *)jy_createQRCodeWithString:(NSString *)string size:(CGFloat)size;


/**
 * 自定义二维码颜色
 *
 * @param qrImage  二维码图片
 * @param red      RGB通道-R
 * @param green    RGB通道-G
 * @param blue     RGB通道-B
 *
 * @return 二维码图片
 **/
+ (UIImage *)jy_customQRCodeWithImage:(UIImage *)qrImage colorWithRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue;


/**
 * 给二维码添加Logo
 *
 * @param qrImage      二维码图片
 * @param avatarImage  Logo图片
 *
 * @return 二维码图片
 **/
+ (UIImage *)jy_customQRCodeWithImage:(UIImage *)qrImage addAvatarImage:(UIImage *)avatarImage;


/**
 * 给二维码添加Logo
 *
 * @param qrImage      二维码图片
 * @param avatarImage  Logo图片
 * @param ratio        Logo圆角比例（0～1）0为无圆角，1为圆形
 *
 * @return 二维码图片
 **/
+ (UIImage *)jy_customQRCodeWithImage:(UIImage *)qrImage addAvatarImage:(UIImage *)avatarImage cornerRatio:(CGFloat)ratio;

#pragma mark - ReadQRCode

/**
 * 识别图片中的二维码
 *
 * @param sourceImage  需要识别的图片
 *
 * @return 识别获得的数据
 **/
+ (NSString *)jy_detectorQRCodeWithSourceImage:(UIImage *)sourceImage;


/**
 * 改变图片尺寸
 *
 * @param image  原图片
 * @param size   需要改变的尺寸
 *
 * @return 修改后的图片
 **/
+(UIImage*)jy_getImage:(UIImage *)image scaleToSize:(CGSize)size;


@end
