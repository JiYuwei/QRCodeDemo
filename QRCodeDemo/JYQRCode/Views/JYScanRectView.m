//
//  JYScanRectView.m
//  QRCodeDemo
//
//  Created by 纪宇伟 on 2017/6/26.
//  Copyright © 2017年 jyw. All rights reserved.
//

#import "JYScanRectView.h"

@interface JYScanRectView ()

@property(nonatomic,strong)UIView *scanView;
@property(nonatomic,strong)UIView *loadingView;
@property(nonatomic,strong)UIActivityIndicatorView *actView;
@property(nonatomic,strong)UILabel *loadingLabel;

@end

@implementation JYScanRectView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.layer.borderWidth = 1.0;
        
        [self customScanCorners];
        [self customScanLine];
        [self customLoadingView];
    }
    
    return self;
}

#pragma mark - CustomUI

//添加四角标识
-(void)customScanCorners
{
    CGFloat cWidth = self.bounds.size.width;
    CGFloat cHeight = self.bounds.size.height;
    
    NSArray *pointArray = @[@{@"top":[NSValue valueWithCGPoint:CGPointMake(2, 20)],
                              @"mid":[NSValue valueWithCGPoint:CGPointMake(2, 2)],
                              @"end":[NSValue valueWithCGPoint:CGPointMake(20, 2)]},
                            
                            @{@"top":[NSValue valueWithCGPoint:CGPointMake(cWidth - 20, 2)],
                              @"mid":[NSValue valueWithCGPoint:CGPointMake(cWidth - 2, 2)],
                              @"end":[NSValue valueWithCGPoint:CGPointMake(cWidth - 2, 20)]},
                            
                            @{@"top":[NSValue valueWithCGPoint:CGPointMake(cWidth - 2, cHeight - 20)],
                              @"mid":[NSValue valueWithCGPoint:CGPointMake(cWidth - 2, cHeight - 2)],
                              @"end":[NSValue valueWithCGPoint:CGPointMake(cWidth - 20, cHeight - 2)]},
                            
                            @{@"top":[NSValue valueWithCGPoint:CGPointMake(20, cHeight - 2)],
                              @"mid":[NSValue valueWithCGPoint:CGPointMake(2, cHeight - 2)],
                              @"end":[NSValue valueWithCGPoint:CGPointMake(2, cHeight - 20)]},];
    
    
    for (NSInteger i = 0; i < pointArray.count; i++) {
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.lineWidth = 3.0;
        shapeLayer.strokeColor = [UIColor greenColor].CGColor;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:[pointArray[i][@"top"] CGPointValue]];
        [path addLineToPoint:[pointArray[i][@"mid"] CGPointValue]];
        [path addLineToPoint:[pointArray[i][@"end"] CGPointValue]];
        
        shapeLayer.path = path.CGPath;
        
        [self.layer addSublayer:shapeLayer];
    }
    
}

//添加扫描线
-(void)customScanLine
{
    CGFloat cWidth = self.bounds.size.width;
    
    _scanView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cWidth, 2)];
    _scanView.backgroundColor = [UIColor greenColor];
    _scanView.alpha = 0.0;
    
    [self addSubview:_scanView];
}

//添加loading视图
-(void)customLoadingView
{
    _loadingView = [[UIView alloc] initWithFrame:self.bounds];
    _loadingView.backgroundColor = [UIColor blackColor];
    _loadingView.alpha = 0.0;
    [self addSubview:_loadingView];
    
    _actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _actView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    [_actView startAnimating];
    [self addSubview:_actView];
    
    _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.bounds.size.height / 2 + 25, self.bounds.size.width - 40, 30)];
    _loadingLabel.textColor = [UIColor whiteColor];
    _loadingLabel.font = [UIFont systemFontOfSize:15];
    _loadingLabel.textAlignment = NSTextAlignmentCenter;
    _loadingLabel.text = @"处理中，请稍候";
    [self addSubview:_loadingLabel];
}

#pragma mark - Override Setter & Getters

-(void)setLoading:(BOOL)loading
{
    if (_loading != loading) {
        _loading = loading;
        
        _loadingView.alpha = _loading?0.6:0.0;
        _actView.alpha = _loading;
        _loadingLabel.alpha = _loading;
        
        if (!loading) {
            [self startScanAnim];
        }
        else{
            [self stopScanAnim];
        }
    }
}

-(void)startScanAnim
{
    if (![_scanView.layer animationForKey:@"ScanAnim"]) {
        
        _scanView.alpha = 1.0;
        CGFloat cHeight = self.bounds.size.height;
        
        CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        moveAnimation.fromValue = @0;
        moveAnimation.toValue = [NSNumber numberWithFloat:cHeight - 2];
        moveAnimation.duration = 2.4;
        moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimation.fromValue = @0;
        fadeInAnimation.toValue = @1;
        fadeInAnimation.duration = 0.6;
        
        CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeOutAnimation.fromValue = @1;
        fadeOutAnimation.toValue = @0;
        fadeOutAnimation.duration = 0.6;
        fadeOutAnimation.beginTime = 1.8;
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[moveAnimation,fadeInAnimation,fadeOutAnimation];
        group.duration = 2.4;
        group.repeatCount = HUGE_VALF;
        group.removedOnCompletion = NO;
        group.fillMode = kCAFillModeForwards;
        
        [_scanView.layer addAnimation:group forKey:@"ScanAnim"];
    }
}


-(void)stopScanAnim
{
    if ([_scanView.layer animationForKey:@"ScanAnim"]) {
        [_scanView.layer removeAllAnimations];
        _scanView.alpha = 0.0;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
 
}
*/

@end
