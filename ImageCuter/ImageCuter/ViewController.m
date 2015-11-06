//
//  ViewController.m
//  ImageCuter
//
//  Created by Lanseer on 15/11/3.
//  Copyright © 2015年 Lacar. All rights reserved.
//

#import "ViewController.h"
#import "CroperViewController.h"

@interface ViewController ()
{

     UIButton *userHeadImageBtn;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    self.title=@"头像";
    //头像
    userHeadImageBtn=[UIButton buttonWithType:(UIButtonTypeCustom)];
    userHeadImageBtn.frame=CGRectMake(self.view.frame.size.width/2-50, self.view.frame.size.height/2-50, 100, 100);
    
    [userHeadImageBtn addTarget:self action:@selector(changeMyHeadImage) forControlEvents:(UIControlEventTouchUpInside)];
    userHeadImageBtn.layer.cornerRadius=50.0f;
    userHeadImageBtn.layer.masksToBounds=YES;
    [self.view addSubview:userHeadImageBtn];
    
    
    UILabel *lable=[[UILabel alloc] initWithFrame:(CGRectMake(0, userHeadImageBtn.frame.origin.y+100+20, self.view.frame.size.width, 17))];
    lable.text=@"点击头像更换图片";
    lable.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:lable];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    [userHeadImageBtn setBackgroundImage:[UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"localData"]] forState:(UIControlStateNormal)];
}
- (void)changeMyHeadImage{
    
    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController pushViewController:[[CroperViewController alloc] init] animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
