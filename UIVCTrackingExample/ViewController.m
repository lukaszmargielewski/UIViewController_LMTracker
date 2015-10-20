//
//  ViewController.m
//  UIVCTrackingExample
//
//  Created by Lukasz Margielewski on 16/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+TrackingLifeCycle.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)loadView{

    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    NSUInteger count = self.navigationController.viewControllers.count;
    
    UIColor *color = [UIColor whiteColor];
    
    switch (count % 5) {
        case 0:
            color = [UIColor whiteColor];
            break;
        case 1:
            color = [UIColor redColor];
            break;
        case 2:
            color = [UIColor blueColor];
            break;
        case 3:
            color = [UIColor greenColor];
            break;
        case 4:
            color = [UIColor yellowColor];
            break;
        default:
            break;
    }
    self.view.backgroundColor = color;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Add extra stats" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addStats:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(20, 100, 280, 50);
    [self.view addSubview:button];
    
}
- (void)addStats:(UIButton *)button{

    NSUInteger count = self.navigationController.viewControllers.count;
    NSDictionary *userInfo = @{@"manual" : self.title};
    
    [self.trackerDelegate addStatsWithUserInfo:userInfo];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Push" style:UIBarButtonItemStyleDone target:self action:@selector(push:)];
    
    self.title = [NSString stringWithFormat:@"Controller nr %@", self.trackedInfo[@"stack"]];
    
}
- (void)push:(id)sender{

    ViewController *vc = [[ViewController alloc] init];
    
    NSUInteger count = self.navigationController.viewControllers.count;
    vc.trackedInfo = @{@"stack" : @(count)};
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
