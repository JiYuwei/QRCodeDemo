//
//  ViewController.m
//  QRCodeDemo
//
//  Created by 纪宇伟 on 2017/6/26.
//  Copyright © 2017年 jyw. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
#import "JYQRScanController.h"
#import "JYQRCodeTool.h"

#define BTN_BORDER_COLOR  [UIColor colorWithRed:0.2 green:0.49 blue:0.99 alpha:1]

@interface ViewController () <UIActionSheetDelegate>

@property(nonatomic,strong)UIView *qrBGView;
@property(nonatomic,strong)UIImageView *qrCodeView;
@property(nonatomic,strong)UITextField *textField;
@property(nonatomic,strong)UITextField *redField;
@property(nonatomic,strong)UITextField *greenField;
@property(nonatomic,strong)UITextField *blueField;
@property(nonatomic,strong)UIButton *transBtn;
@property(nonatomic,strong)UISwitch *shadowSwitch;
@property(nonatomic,strong)UISwitch *logoSwitch;
@property(nonatomic,strong)UILabel  *logoCornerLB;
@property(nonatomic,strong)UISlider *logoSlider;

@end

@implementation ViewController

- (void)loadView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageView.image = [UIImage imageNamed:@"bgcolor"];
    imageView.userInteractionEnabled = YES;
    self.view = imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"生成二维码";
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"scan"] style:UIBarButtonItemStylePlain target:self action:@selector(openQRScanVC)];
    
    [self createUI];
    [self createCustomUI];
    [self generateQRCode];
}

#pragma mark - CustomUI

-(void)createUI
{
    CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat cHeight = [UIScreen mainScreen].bounds.size.height;
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 84, cWidth-110, 35)];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.text = @"http://www.baidu.com";
    [_textField addTarget:self action:@selector(textFieldDidChangeCharacters:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_textField];
    
    _transBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _transBtn.frame = CGRectMake(_textField.frame.origin.x + _textField.frame.size.width + 10, _textField.frame.origin.y, 60, 35);
    _transBtn.backgroundColor = [UIColor whiteColor];
    _transBtn.layer.borderColor = [UIColor grayColor].CGColor;
    _transBtn.layer.borderWidth = 0.5;
    _transBtn.layer.cornerRadius = 5;
    [_transBtn setTitle:@"已生成" forState:UIControlStateNormal];
    _transBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [_transBtn addTarget:self action:@selector(generateQRCode) forControlEvents:UIControlEventTouchUpInside];
    _transBtn.enabled = NO;
    [self.view addSubview:_transBtn];
    
    CGFloat vWidth = 250;
    
    _qrBGView = [[UIView alloc] initWithFrame:CGRectMake((cWidth - vWidth) / 2, (cHeight - vWidth) / 2 * 1.6, vWidth, vWidth)];
    _qrBGView.backgroundColor = [UIColor whiteColor];
    _qrBGView.layer.borderColor = [UIColor grayColor].CGColor;
    _qrBGView.layer.borderWidth = 1.0;
    _qrBGView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _qrBGView.layer.shadowOpacity = 1.0;
    _qrBGView.layer.shadowOffset = CGSizeMake(0, 0);
    [self.view addSubview:_qrBGView];
    
    _qrCodeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, vWidth, vWidth)];
    _qrCodeView.backgroundColor = [UIColor clearColor];
    _qrCodeView.layer.shadowColor = [UIColor grayColor].CGColor;
    _qrCodeView.layer.shadowRadius = 1.5;
    _qrCodeView.layer.shadowOffset = CGSizeMake(0, 0);
    _qrCodeView.userInteractionEnabled = YES;
    [_qrCodeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(qrCodeAction)]];
    [_qrBGView addSubview:_qrCodeView];
}

-(void)createCustomUI
{
    CGFloat originX = _textField.frame.origin.x;
    CGFloat originY = _textField.frame.origin.y + _textField.frame.size.height + 20;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat cFHeight = 28;
    CGFloat cFWidth = 45;
    
    UILabel *colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, cFWidth, cFHeight)];
    colorLabel.font = [UIFont systemFontOfSize:16];
    colorLabel.textColor = [UIColor whiteColor];
    colorLabel.text = @"颜色:";
    colorLabel.shadowColor = [UIColor darkGrayColor];
    colorLabel.shadowOffset = CGSizeMake(0, 1);
    [self.view addSubview:colorLabel];
    
    _redField = [[UITextField alloc] init];
    _greenField = [[UITextField alloc] init];
    _blueField = [[UITextField alloc] init];
    
    [self createColorTextField:_redField rect:CGRectMake(originX + colorLabel.frame.size.width, originY, cFWidth, cFHeight) placeHolder:@"R"];
    [self createColorTextField:_greenField rect:CGRectMake(originX + colorLabel.frame.size.width + cFWidth, originY, cFWidth, cFHeight) placeHolder:@"G"];
    [self createColorTextField:_blueField rect:CGRectMake(originX + colorLabel.frame.size.width + cFWidth * 2, originY, cFWidth, cFHeight) placeHolder:@"B"];
    
    UILabel *shadowLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - cFWidth - 70, originY, cFWidth, cFHeight)];
    shadowLabel.font = [UIFont systemFontOfSize:16];
    shadowLabel.textColor = [UIColor whiteColor];
    shadowLabel.text = @"阴影:";
    shadowLabel.shadowColor = [UIColor darkGrayColor];
    shadowLabel.shadowOffset = CGSizeMake(0, 1);
    [self.view addSubview:shadowLabel];
    
    _shadowSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screenWidth - 70, originY - 1, 0, 0)];
    _shadowSwitch.tintColor = [UIColor whiteColor];
    [_shadowSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_shadowSwitch];
    
    UILabel *logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - cFWidth - 70, originY + 50, cFWidth, cFHeight)];
    logoLabel.font = [UIFont systemFontOfSize:16];
    logoLabel.textColor = [UIColor whiteColor];
    logoLabel.text = @"Logo:";
    logoLabel.shadowColor = [UIColor darkGrayColor];
    logoLabel.shadowOffset = CGSizeMake(0, 1);
    [self.view addSubview:logoLabel];
    
    _logoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screenWidth - 70, originY + 49, 0, 0)];
    _logoSwitch.tintColor = [UIColor whiteColor];
    [_logoSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_logoSwitch];
    
    _logoSlider = [[UISlider alloc] initWithFrame:CGRectMake(originX, originY + 60, screenWidth - cFWidth - 110, 10)];
    _logoSlider.minimumValue = 0.0;
    _logoSlider.maximumValue = 1.0;
    _logoSlider.value = 0.25;
    _logoSlider.thumbTintColor = [UIColor colorWithRed:0.37 green:0.84 blue:0.47 alpha:1];
    _logoSlider.minimumTrackTintColor = [UIColor colorWithRed:0.37 green:0.84 blue:0.47 alpha:1];
    [_logoSlider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
    _logoSlider.alpha = 0.0;
    [self.view addSubview:_logoSlider];
    
    _logoCornerLB = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY + 80, screenWidth - cFWidth - 110, 30)];
    _logoCornerLB.font = [UIFont systemFontOfSize:16];
    _logoCornerLB.textColor = [UIColor whiteColor];
    _logoCornerLB.text = @"圆角半径比例: 0.25";
    _logoCornerLB.textAlignment = NSTextAlignmentCenter;
    _logoCornerLB.shadowColor = [UIColor darkGrayColor];
    _logoCornerLB.shadowOffset = CGSizeMake(0, 1);
    _logoCornerLB.alpha = 0.0;
    [self.view addSubview:_logoCornerLB];
}

-(void)createColorTextField:(UITextField *)colorField rect:(CGRect)rect placeHolder:(NSString *)placeHolder
{
    colorField.frame = rect;
    colorField.borderStyle = UITextBorderStyleRoundedRect;
    colorField.placeholder = placeHolder;
    colorField.keyboardType = UIKeyboardTypeNumberPad;
    [colorField addTarget:self action:@selector(textFieldDidChangeCharacters:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:colorField];
}

#pragma mark - ReadQRCode

-(void)readQRCode
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *qrImage = [self clipImageFromView:_qrBGView];
        
        NSString *urlStr = [JYQRCodeTool jy_detectorQRCodeWithSourceImage:qrImage];
        NSLog(@"%@",urlStr);
        
        if (!urlStr) {
            UIImage *scaleImage = [JYQRCodeTool jy_getImage:qrImage scaleToSize:CGSizeMake(200, 200)];
            urlStr = [JYQRCodeTool jy_detectorQRCodeWithSourceImage:scaleImage];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //对识别出的数据进行处理
            if (urlStr) {
                WebViewController *webVC = [[WebViewController alloc] init];
                webVC.urlStr = urlStr;
                [self.navigationController pushViewController:webVC animated:YES];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结果" message:@"未识别到有效信息" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        });
    });
}

#pragma mark - SavePhoto

-(UIImage *)clipImageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)savePhoto
{
    UIImage *image = [self clipImageFromView:_qrBGView];
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = nil ;
    
    if(error){
        msg = @"保存失败" ;
    }else{
        msg = @"保存成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:nil  cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


#pragma mark - ButtonEnableControl

-(void)controlBtnsEnabled:(BOOL)enable
{
    return [self controlBtnsEnabled:enable labelChanged:YES];
}

-(void)controlBtnsEnabled:(BOOL)enable labelChanged:(BOOL)change
{
    if (enable) {
        if (!_transBtn.isEnabled) {
            if (change) {
                [_transBtn setTitle:@"生成" forState:UIControlStateNormal];
            }
            _transBtn.enabled = YES;
            _transBtn.layer.borderColor = BTN_BORDER_COLOR.CGColor;
        }
    }
    else{
        if (_transBtn.isEnabled) {
            if (change) {
                [_transBtn setTitle:@"已生成" forState:UIControlStateNormal];
            }
            _transBtn.enabled = NO;
            _transBtn.layer.borderColor = [UIColor grayColor].CGColor;
        }
    }
}


#pragma mark - Actions

- (void)openQRScanVC
{
    JYQRScanController *jyQRScanVC = [[JYQRScanController alloc] init];
    [self.navigationController pushViewController:jyQRScanVC animated:YES];
}

-(void)textFieldDidChangeCharacters:(UITextField *)textField
{
    if (textField == _textField) {
        if(_textField.text.length == 0){
            [self controlBtnsEnabled:NO labelChanged:NO];
        }
        else{
            [self controlBtnsEnabled:YES];
        }
    }
    else{
        if ([textField.text integerValue] > 255) {
            textField.text = @"255";
        }
        
        if (_textField.text.length > 0) {
            [self controlBtnsEnabled:YES];
        }
    }
}

//生成二维码
-(void)generateQRCode
{
    [self controlBtnsEnabled:NO];
    [self resignTextFields];
    
    UIImage *qrImage = [JYQRCodeTool jy_createQRCodeWithString:_textField.text size:_qrCodeView.bounds.size.width];
    
    NSArray <NSNumber *> *colorArr = @[[NSNumber numberWithFloat:_redField.text.floatValue],
                                       [NSNumber numberWithFloat:_greenField.text.floatValue],
                                       [NSNumber numberWithFloat:_blueField.text.floatValue]];
    
    BOOL isDarkBG = (colorArr[0].floatValue > 220 && colorArr[1].floatValue > 220 && colorArr[2].floatValue > 220);
    _qrBGView.backgroundColor = isDarkBG?[UIColor blackColor]:[UIColor whiteColor];
    _qrCodeView.layer.shadowColor = isDarkBG?[UIColor whiteColor].CGColor:[UIColor grayColor].CGColor;
    
    qrImage = [JYQRCodeTool jy_customQRCodeWithImage:qrImage colorWithRed:colorArr[0].floatValue andGreen:colorArr[1].floatValue andBlue:colorArr[2].floatValue];
    
    
    if (_logoSwitch.isOn) {
        qrImage = [JYQRCodeTool jy_customQRCodeWithImage:qrImage addAvatarImage:[UIImage imageNamed:@"logo"] cornerRatio:_logoSlider.value];
    }
    
    _qrCodeView.image = qrImage;
    
}

-(void)qrCodeAction
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"识别图中二维码" otherButtonTitles:@"保存到相册", nil];
    [sheet showInView:self.view];
}

-(void)switchChanged:(UISwitch *)sender
{
    if (sender == _shadowSwitch) {
        _qrCodeView.layer.shadowOpacity = sender.isOn;
    }
    else if (sender == _logoSwitch){
        _logoSlider.alpha = sender.isOn;
        _logoCornerLB.alpha = sender.isOn;
        
        if (_textField.text.length > 0) {
            [self controlBtnsEnabled:YES];
        }
    }
    else{
        return;
    }
}

-(void)sliderChanged
{
    if (_textField.text.length > 0) {
        [self controlBtnsEnabled:YES];
    }
    
    _logoCornerLB.text = [NSString stringWithFormat:@"圆角半径比例: %.2f",_logoSlider.value];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self readQRCode];
            break;
        case 1:
            [self savePhoto];
            break;
            
        default:
            break;
    }
}


#pragma mark - TouchEvent

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self resignTextFields];
}

-(void)resignTextFields
{
    for (UITextField *field in self.view.subviews) {
        if (field.isFirstResponder) {
            [field resignFirstResponder];
            return;
        }
    }
}

#pragma mark - MemoryWarning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
