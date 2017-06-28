//
//  JYQRCodeTool.h
//  QRCodeDemo
//
//  Created by 纪宇伟 on 2017/6/27.
//  Copyright © 2017年 jyw. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JYQRCodeDelegate <NSObject>

- (void)jy_succeedOutputMataDataObjectToString:(NSString *)outPutString;

@end


@interface JYQRCodeTool : NSObject

+ (instancetype)toolsWithBindingController:(UIViewController *)controller;

@property(nonatomic,copy)NSString *scanVoiceName;
@property(nonatomic,weak) id <JYQRCodeDelegate> delegate;

- (void)jy_setUpCaptureWithRect:(CGRect)rect;
- (void)jy_controlTheFlashLight:(BOOL)lock;

- (void)jy_resetScaning;


+ (UIImage *)jy_createQRCodeWithString:(NSString *)string size:(CGFloat)size;
+ (UIImage *)jy_customQRCodeWithImage:(UIImage *)qrImage colorWithRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue;
+ (UIImage *)jy_customQRCodeWithImage:(UIImage *)qrImage addAvatarImage:(UIImage *)avatarImage;

@end
