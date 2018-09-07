//
//  ViewController.m
//  HYScratchCardViewExample
//
//  Created by Shadow on 14-5-26.
//  Copyright (c) 2014年 Shadow. All rights reserved.
//

#import "ViewController.h"
#import "HYScratchCardView.h"

@interface ViewController ()

@property (nonatomic, strong) HYScratchCardView *scratchCardView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.scratchCardView = [[HYScratchCardView alloc]initWithFrame:CGRectMake(85, 100, 150, 150)];
    self.scratchCardView.image = [UIImage imageNamed:@"lottery_award"];
    self.scratchCardView.surfaceImage = [UIImage imageNamed:@"scratch_image_cover"];
    
    [self.view addSubview:self.scratchCardView];
    
    __block UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
    [butt setTitle:@"再来一次" forState:UIControlStateNormal];
    butt.frame = CGRectMake(0, 0, 64, 30);
    butt.layer.borderColor = [UIColor yellowColor].CGColor;
    butt.layer.cornerRadius = 5.0;
    butt.layer.borderWidth = 2.0;
    [butt addTarget:self  action:@selector(resetButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
   // __weak typeof(self) weakself = self;
    self.scratchCardView.layoutBlock = ^(UIView *view) {
        view.backgroundColor = [UIColor orangeColor];
        butt.center = view.center;
        [view addSubview:butt];
    };
    
    self.scratchCardView.completion = ^(id userInfo) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"恭喜"
                                                           message:@"恭喜中奖."
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil];
        [alertView show];
    };
}
- (IBAction)resetButtonClick:(UIButton *)sender {
    [self.scratchCardView reset];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
