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

@end

@implementation JYScanRectView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.layer.borderWidth = 1.0;
        
        [self customScanCorners];
        [self customScanLine];
    }
    
    return self;
}

-(void)customScanCorners
{
    CGFloat cWidth = self.bounds.size.width;
    CGFloat cHeight = self.bounds.size.height;
    
    NSArray *pointArray = @[@{@"top":[NSValue valueWithCGPoint:CGPointMake(-1, 20)],
                              @"mid":[NSValue valueWithCGPoint:CGPointMake(-1, -1)],
                              @"end":[NSValue valueWithCGPoint:CGPointMake(20, -1)]},
                            
                            @{@"top":[NSValue valueWithCGPoint:CGPointMake(cWidth - 20, -1)],
                              @"mid":[NSValue valueWithCGPoint:CGPointMake(cWidth + 1, -1)],
                              @"end":[NSValue valueWithCGPoint:CGPointMake(cWidth + 1, 20)]},
                            
                            @{@"top":[NSValue valueWithCGPoint:CGPointMake(cWidth + 1, cHeight - 20)],
                              @"mid":[NSValue valueWithCGPoint:CGPointMake(cWidth + 1, cHeight + 1)],
                              @"end":[NSValue valueWithCGPoint:CGPointMake(cWidth - 20, cHeight + 1)]},
                            
                            @{@"top":[NSValue valueWithCGPoint:CGPointMake(20, cHeight + 1)],
                              @"mid":[NSValue valueWithCGPoint:CGPointMake(-1, cHeight + 1)],
                              @"end":[NSValue valueWithCGPoint:CGPointMake(-1, cHeight - 20)]},];
    
    
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

-(void)customScanLine
{
    CGFloat cWidth = self.bounds.size.width;
    CGFloat cHeight = self.bounds.size.height;
    
    _scanView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cWidth, 2)];
    _scanView.backgroundColor = [UIColor greenColor];
    [self addSubview:_scanView];
    
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    moveAnimation.fromValue = @0;
    moveAnimation.toValue = [NSNumber numberWithFloat:cHeight - 2];
    moveAnimation.duration = 2.5;
    moveAnimation.repeatCount = HUGE_VALF;
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeForwards;
    [_scanView.layer addAnimation:moveAnimation forKey:nil];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    [[UIColor whiteColor] setStroke];
    [[UIColor clearColor] setFill];
    
    CGContextBeginPath(context);
    
    //左上角
    CGContextMoveToPoint(context, 0, 20);
    
    CGContextAddLineToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 20, 0);
    
    //右上角
    CGContextMoveToPoint(context, rect.size.width - 20, 0);
    
    CGContextAddLineToPoint(context, rect.size.width, 0);
    CGContextAddLineToPoint(context, rect.size.width, 20);
    
    //左下角
    CGContextMoveToPoint(context, 0, rect.size.height - 20);
    
    CGContextAddLineToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, 20, rect.size.height);
    
    //右下角
    CGContextMoveToPoint(context, rect.size.width - 20, rect.size.height);
    
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height - 20);
    
    CGContextStrokePath(context);
    
    CGContextClosePath(context);
}
*/

@end
