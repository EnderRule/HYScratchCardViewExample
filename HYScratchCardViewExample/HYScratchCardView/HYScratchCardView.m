//
//  HYScratchCardView.m
//  Test
//
//  Created by Shadow on 14-5-23.
//  Copyright (c) 2014年 Shadow. All rights reserved.
//

#import "HYScratchCardView.h"

@interface HYScratchCardView ()

@property (nonatomic, strong) UIImageView *surfaceImageView;
@property (nonatomic, strong) UIView *downView;
@property (nonatomic, strong) CALayer *imageLayer;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, assign) CGMutablePathRef path;

@property (nonatomic, assign, getter = isOpen) BOOL open;

@property (nonatomic, strong) NSMutableArray<NSString *> *checkPoints;
@property (nonatomic, strong) NSMutableArray<NSString *> *scratchRects;
@property (nonatomic) CGPoint prePoint;

@end

@implementation HYScratchCardView

- (void)dealloc
{
    if (self.path) {
        CGPathRelease(self.path);
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.completionRate = 0.75;
        self.lineWidth = 15.0;
        self.scratchRects = [NSMutableArray array];
        
        self.surfaceImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        self.surfaceImageView.image = [self imageByColor:[UIColor darkGrayColor]];
        [self addSubview:self.surfaceImageView];
        
        self.imageLayer = [CALayer layer];
        self.imageLayer.frame = self.bounds;
        [self.layer addSublayer:self.imageLayer];
        
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.frame = self.bounds;
        self.shapeLayer.lineCap = kCALineCapRound;
        self.shapeLayer.lineJoin = kCALineJoinRound;
        self.shapeLayer.lineWidth = self.lineWidth;
        self.shapeLayer.strokeColor = [UIColor blueColor].CGColor;
        self.shapeLayer.fillColor = nil;
        
        [self.layer addSublayer:self.shapeLayer];
        self.imageLayer.mask = self.shapeLayer;
        
        self.path = CGPathCreateMutable();
        
        [self calculateCheckPoints];
    }
    return self;
}

-(void)setLayoutBlock:(LayoutScratchViewBlock)layoutBlock {
    _layoutBlock = layoutBlock;
    
    [self checkLayoutDownView];
}

-(void)setCompletionRate:(CGFloat)completionRate {
    _completionRate = completionRate;
    
    if (self.checkPoints.count > 0) {
        [self calculateCheckPoints];
    }
}
-(void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    
    if (self.checkPoints.count > 0) {
        [self calculateCheckPoints];
    }}

-(void)calculateCheckPoints {
    self.checkPoints = [NSMutableArray arrayWithCapacity:0];
    CGFloat x = self.lineWidth;
    while (x < self.frame.size.width) {
        CGFloat y = self.lineWidth;
        while (y < self.frame.size.height) {
            [self.checkPoints addObject:NSStringFromCGPoint(CGPointMake(x, y))];
            y += self.lineWidth;
        }
        x += self.lineWidth;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (!self.isOpen) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGPathMoveToPoint(self.path, NULL, point.x, point.y);
        CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
        self.shapeLayer.path = path;
        CGPathRelease(path);
        
        self.prePoint = point;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (!self.isOpen) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGPathAddLineToPoint(self.path, NULL, point.x, point.y);
        CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
        self.shapeLayer.path = path;
        CGPathRelease(path);
        
        //计算滑动过的区域
        CGFloat x_x = _prePoint.x - point.x;
        CGFloat y_y = _prePoint.y - point.y;
        if (sqrt(x_x * x_x + y_y * y_y) >= self.lineWidth/2.0) {
            CGMutablePathRef rectPath = CGPathCreateMutable();
            CGPathMoveToPoint(rectPath, NULL , _prePoint.x, _prePoint.y);
            CGPathAddLineToPoint(rectPath, NULL, point.x, point.y);
            CGRect rect = CGPathGetPathBoundingBox(rectPath);
            rect.origin.x -= self.lineWidth/2.0;
            rect.origin.y -= self.lineWidth/2.0;
            rect.size.width += self.lineWidth;
            rect.size.height += self.lineWidth;
            [self.scratchRects addObject:NSStringFromCGRect(rect)];
            _prePoint = point;
            CGPathRelease(rectPath);
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (!self.isOpen) {
        [self checkForOpen2];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if (!self.isOpen) {
        [self checkForOpen2];
    }
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageLayer.contents = (id)image.CGImage;
}

- (void)setSurfaceImage:(UIImage *)surfaceImage
{
    _surfaceImage = surfaceImage;
    self.surfaceImageView.image = surfaceImage;
}

- (void)reset
{
    if (self.path) {
        CGPathRelease(self.path);
    }
    self.open = NO;
    self.path = CGPathCreateMutable();
    self.shapeLayer.path = NULL;
    self.imageLayer.mask = self.shapeLayer;
    
    self.scratchRects = [NSMutableArray array];
    self.prePoint = CGPointZero;
    
    [self checkLayoutDownView];
}

-(void)checkLayoutDownView {
    if (self.layoutBlock != nil) {
        [_downView removeFromSuperview];
        _downView = nil;
        
        _downView = [[UIView alloc] init];
        _downView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _downView.backgroundColor = [UIColor clearColor];
        self.layoutBlock(_downView);
        
        [self addSubview:_downView];
        _downView.layer.mask = self.shapeLayer;
        self.imageLayer.contents = NULL;
        
        _downView.userInteractionEnabled = false;
    }
}

- (void)checkForOpen
{
    CGRect rect = CGPathGetPathBoundingBox(self.path);
    
    NSArray *pointsArray = [self getPointsArray];
    for (NSValue *value in pointsArray) {
        CGPoint point = [value CGPointValue];
        if (!CGRectContainsPoint(rect, point)) {
            return;
        }
    }
    
    NSLog(@"完成");
    self.open = YES;
    self.imageLayer.mask = NULL;
    self.downView.layer.mask = NULL;
    
    if (self.completion) {
        self.completion(self.userInfo);
    }
}

-(void)checkForOpen2 {
    NSInteger containCount = 0;
    for (NSString *pointStr in self.checkPoints) {
        CGPoint p = CGPointFromString(pointStr);
        for (NSString *rectStr in self.scratchRects) {
            CGRect rect = CGRectFromString(rectStr);
            if ( CGRectContainsPoint(rect, p) ){
                containCount += 1;
                break;
            }
        }
    }
    CGFloat rate = (CGFloat)containCount/self.checkPoints.count;
    if ( rate >= self.completionRate ) {
        NSLog(@"完成");
        self.open = YES;
        self.imageLayer.mask = NULL;
        self.downView.layer.mask = NULL;
        if (self.completion) {
            self.completion(self.userInfo);
        }
        self.downView.userInteractionEnabled = true ;
    } else {
//        NSLog(@"Scratch Rect count:%i %i %i", self.scratchRects.count, containCount, self.checkPoints.count);
    }
}

- (NSArray *)getPointsArray
{
    NSMutableArray *array = [NSMutableArray array];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGPoint topPoint = CGPointMake(width/2, height/6);
    CGPoint leftPoint = CGPointMake(width/6, height/2);
    CGPoint bottomPoint = CGPointMake(width/2, height-height/6);
    CGPoint rightPoint = CGPointMake(width-width/6, height/2);
    
    [array addObject:[NSValue valueWithCGPoint:topPoint]];
    [array addObject:[NSValue valueWithCGPoint:leftPoint]];
    [array addObject:[NSValue valueWithCGPoint:bottomPoint]];
    [array addObject:[NSValue valueWithCGPoint:rightPoint]];
    
    return array;
}

- (UIImage *)imageByColor:(UIColor *)color
{
    CGSize imageSize = CGSizeMake(1, 1);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
