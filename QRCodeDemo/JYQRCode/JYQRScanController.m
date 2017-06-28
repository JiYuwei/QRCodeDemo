//
//  JYQRScanController.m
//  QRCodeDemo
//
//  Created by 纪宇伟 on 2017/6/26.
//  Copyright © 2017年 jyw. All rights reserved.
//

#import "JYQRScanController.h"
#import "JYScanRectView.h"
#import "JYQRCodeTool.h"
#import "WebViewController.h"

@interface JYQRScanController () <JYQRCodeDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)JYQRCodeTool *jyQRTool;

@property(nonatomic,strong)JYScanRectView *jyScanRectView;
@property(nonatomic,strong)UILabel *scanLabel;
@property(nonatomic,strong)UIButton *lightBtn;

@end


@implementation JYQRScanController

//LazyLoad
-(JYQRCodeTool *)jyQRTool
{
    if (!_jyQRTool) {
        _jyQRTool = [JYQRCodeTool toolsWithBindingController:self];
        _jyQRTool.scanVoiceName = @"sound.wav";
        _jyQRTool.delegate = self;
    }
    
    return _jyQRTool;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.jyQRTool jy_startScaning];
    [_jyScanRectView startScanAnim];
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
    
    [self.jyQRTool jy_setUpCaptureWithRect:scanRect];
    
    [self setUpRectViewWithRect:scanRect];
    [self setUpLightButton];
}


#pragma mark - CustomUI

//创建扫描框
-(void)setUpRectViewWithRect:(CGRect)scanRect
{
    _jyScanRectView = [[JYScanRectView alloc] initWithFrame:scanRect];
    [self.view addSubview:_jyScanRectView];
    
    _scanLabel = [[UILabel alloc] initWithFrame:CGRectMake(_jyScanRectView.frame.origin.x, _jyScanRectView.frame.origin.y + _jyScanRectView.frame.size.height + 5, _jyScanRectView.frame.size.width, 30)];
    _scanLabel.textColor = [UIColor grayColor];
    _scanLabel.font = [UIFont systemFontOfSize:13];
    _scanLabel.textAlignment = NSTextAlignmentCenter;
    _scanLabel.text = @"将二维码/条码放入框内，即可自动扫描";
    [self.view addSubview:_scanLabel];
}

//创建闪光灯开关
-(void)setUpLightButton
{
    CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
    
    _lightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _lightBtn.frame = CGRectMake(cWidth / 2 - 50, _scanLabel.frame.origin.y + _scanLabel.frame.size.height + 20, 100, 30);

    [_lightBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [_lightBtn setTintColor:[UIColor greenColor]];
    [_lightBtn setTitle:@"开启闪光灯" forState:UIControlStateNormal];
    [_lightBtn setTitle:@"关闭闪光灯" forState:UIControlStateSelected];
    
    [_lightBtn addTarget:self action:@selector(lightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_lightBtn];
}

#pragma mark - Actions

-(void)openPhotoLibrary
{
    UIImagePickerController *pickerCtr = [[UIImagePickerController alloc] init];
    pickerCtr.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerCtr.delegate = self;
    [self presentViewController:pickerCtr animated:YES completion:nil];
}

-(void)lightBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.jyQRTool jy_controlTheFlashLight:sender.selected];
}

-(void)visitWebViewWithUrl:(NSString *)url
{
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.urlStr = url;
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - Delegate

-(void)jy_succeedOutputMataDataObjectToString:(NSString *)outPutString
{
    _lightBtn.selected = NO;
    [_jyScanRectView stopScanAnim];
    [self.jyQRTool jy_stopScaning];
    //对扫描获得的数据进行处理
    [self visitWebViewWithUrl:outPutString];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        _lightBtn.selected = NO;
        [_jyScanRectView stopScanAnim];
        [self.jyQRTool jy_stopScaning];
        UIImage *pickImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        //对获得的数据进行处理
        NSString *urlStr = [JYQRCodeTool jy_detectorQRCodeImageWithSourceImage:pickImage];
        
        if (urlStr) {
            [self visitWebViewWithUrl:urlStr];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结果" message:@"未识别到有效信息" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.jyQRTool jy_startScaning];
    [_jyScanRectView startScanAnim];
}


#pragma mark - Dealloc

-(void)dealloc
{
    NSLog(@"dealloc %@",NSStringFromClass([self class]));
}

#pragma mark - MemoryWarning

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
