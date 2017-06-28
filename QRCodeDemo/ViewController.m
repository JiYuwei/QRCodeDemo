//
//  ViewController.m
//  QRCodeDemo
//
//  Created by 纪宇伟 on 2017/6/26.
//  Copyright © 2017年 jyw. All rights reserved.
//

#import "ViewController.h"
#import "JYQRScanController.h"
#import "JYQRCodeTool.h"

#define BTN_BORDER_COLOR  [UIColor colorWithRed:0.2 green:0.49 blue:0.99 alpha:1]

@interface ViewController () <UIActionSheetDelegate>

@property(nonatomic,strong)UIImageView *qrCodeView;
@property(nonatomic,strong)UITextField *textField;
@property(nonatomic,strong)UITextField *redField;
@property(nonatomic,strong)UITextField *greenField;
@property(nonatomic,strong)UITextField *blueField;
@property(nonatomic,strong)UIButton *transBtn;
@property(nonatomic,strong)UISwitch *logoSwitch;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    self.navigationItem.title = @"生成二维码";
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"扫一扫" style:UIBarButtonItemStylePlain target:self action:@selector(openQRScanVC)];
    
    [self createUI];
    [self createCustomUI];
    [self generateQRCode];
}

- (void)openQRScanVC
{
    JYQRScanController *jyQRScanVC = [[JYQRScanController alloc] init];
    [self.navigationController pushViewController:jyQRScanVC animated:YES];
}


-(void)createUI
{
    CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat cHeight = [UIScreen mainScreen].bounds.size.height;
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 84, cWidth-110, 35)];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.text = @"http://www.baidu.com";
    [_textField addTarget:self action:@selector(textFieldDidChangeCharacters:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_textField];
    
    _transBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _transBtn.frame = CGRectMake(_textField.frame.origin.x + _textField.frame.size.width + 10, _textField.frame.origin.y, 60, 35);
    _transBtn.layer.borderColor = [UIColor grayColor].CGColor;
    _transBtn.layer.borderWidth = 0.5;
    _transBtn.layer.cornerRadius = 5;
    [_transBtn setTitle:@"已生成" forState:UIControlStateNormal];
    _transBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [_transBtn addTarget:self action:@selector(generateQRCode) forControlEvents:UIControlEventTouchUpInside];
    _transBtn.enabled = NO;
    [self.view addSubview:_transBtn];
    
    CGFloat vWidth = 250;
    
    _qrCodeView = [[UIImageView alloc] initWithFrame:CGRectMake((cWidth - vWidth) / 2, (cHeight - vWidth) / 2 + 50, vWidth, vWidth)];
    _qrCodeView.backgroundColor = [UIColor whiteColor];
    _qrCodeView.layer.borderColor = [UIColor grayColor].CGColor;
    _qrCodeView.layer.borderWidth = 1.0;
    _qrCodeView.userInteractionEnabled = YES;
    [_qrCodeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(qrCodeAction)]];
    [self.view addSubview:_qrCodeView];
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
    colorLabel.textColor = [UIColor grayColor];
    colorLabel.text = @"颜色:";
    [self.view addSubview:colorLabel];
    
    _redField = [[UITextField alloc] init];
    _greenField = [[UITextField alloc] init];
    _blueField = [[UITextField alloc] init];
    
    [self createColorTextField:_redField rect:CGRectMake(originX + colorLabel.frame.size.width, originY, cFWidth, cFHeight) placeHolder:@"R"];
    [self createColorTextField:_greenField rect:CGRectMake(originX + colorLabel.frame.size.width + cFWidth, originY, cFWidth, cFHeight) placeHolder:@"G"];
    [self createColorTextField:_blueField rect:CGRectMake(originX + colorLabel.frame.size.width + cFWidth * 2, originY, cFWidth, cFHeight) placeHolder:@"B"];
    
    UILabel *logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - cFWidth - 70, originY, cFWidth, cFHeight)];
    logoLabel.font = [UIFont systemFontOfSize:16];
    logoLabel.textColor = [UIColor grayColor];
    logoLabel.text = @"Logo:";
    [self.view addSubview:logoLabel];
    
    _logoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screenWidth - 70, originY - 1, 0, 0)];
    _logoSwitch.tintColor = [UIColor lightGrayColor];
    [_logoSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_logoSwitch];
}

-(void)switchChanged
{
    [self controlBtnsEnabled:YES];
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

//生成二维码
-(void)generateQRCode
{
    
    [self controlBtnsEnabled:NO];
    
    UIImage *qrImage = [JYQRCodeTool jy_createQRCodeWithString:_textField.text size:_qrCodeView.bounds.size.width];
    
    NSArray <NSNumber *> *colorArr = @[[NSNumber numberWithFloat:_redField.text.floatValue],
                                       [NSNumber numberWithFloat:_greenField.text.floatValue],
                                       [NSNumber numberWithFloat:_blueField.text.floatValue]];
    
    for (NSNumber *num in colorArr) {
        if (num.floatValue > 0) {
            
            BOOL isDarkBG = (colorArr[0].floatValue > 128 && colorArr[1].floatValue > 128 && colorArr[2].floatValue > 128);
            _qrCodeView.backgroundColor = isDarkBG?[UIColor blackColor]:[UIColor whiteColor];
            
            qrImage = [JYQRCodeTool jy_customQRCodeWithImage:qrImage colorWithRed:colorArr[0].floatValue andGreen:colorArr[1].floatValue andBlue:colorArr[2].floatValue];
            break;
        }
    }
    
    if (_logoSwitch.isOn) {
        qrImage = [JYQRCodeTool jy_customQRCodeWithImage:qrImage addAvatarImage:[UIImage imageNamed:@"logo"]];
    }
    
    _qrCodeView.image = qrImage;
    
}

-(void)qrCodeAction
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"识别图中二维码" otherButtonTitles:@"保存到相册", nil];
    [sheet showInView:self.view];
}

-(void)readQRCode
{
    
}

-(void)savePhoto
{
    UIImageWriteToSavedPhotosAlbum(_qrCodeView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
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
        
        [self controlBtnsEnabled:YES];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITextField *field in self.view.subviews) {
        if (field.isFirstResponder) {
            [field resignFirstResponder];
            return;
        }
    }
}


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

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
