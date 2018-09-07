//
//  HYScratchCardView.h
//  Test
//
//  Created by Shadow on 14-5-23.
//  Copyright (c) 2014年 Shadow. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^scratchCompletion)(id userInfo);

typedef void(^LayoutScratchViewBlock)(UIView *view);

@interface HYScratchCardView : UIView

/**
 要刮的底图.
 */
@property (nonatomic, strong) UIImage *image;

/**
 对要刮的底图view自定义布局。 优先于 image 属性。
 */
@property (nonatomic, strong) LayoutScratchViewBlock layoutBlock;

/**
 涂层图片.
 */
@property (nonatomic, strong) UIImage *surfaceImage;


/**
 线条宽度 默认 15.0
 */
@property (nonatomic,assign) CGFloat lineWidth;


/**
 刮掉多少比例就算是完成，默认 0.75
 */
@property (nonatomic,assign) CGFloat completionRate;

/**
 涂层是否已被刮开
 */
@property (nonatomic, assign, readonly, getter = isOpen) BOOL open;

/**
 刮出后的回调.
 */
@property (nonatomic, strong) scratchCompletion completion;

/**
 可携带一些自定义信息, 将会在回调的block内回传.
 */
@property (nonatomic, strong) id userInfo;

/**
 重置刮刮卡涂层.
 */
- (void)reset;

/**
 用这个方法初始化.
 */
- (id)initWithFrame:(CGRect)frame;

@end
