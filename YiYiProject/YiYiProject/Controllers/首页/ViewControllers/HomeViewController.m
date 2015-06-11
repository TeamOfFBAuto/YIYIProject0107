//
//  HomeViewController.m
//  YiYiProject
//
//  Created by lichaowei on 14/12/10.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeBuyController.h"
#import "HomeClothController.h"
#import "HomeMatchController.h"
#import "GsearchViewController.h"

#import "BigProductViewController.h"//单品的大图模式

@interface HomeViewController ()
{
    UIView *menu_view;
    
    HomeBuyController   *buy_viewcontroller;
    HomeClothController *cloth_viewcontroller;
    HomeMatchController *match_viewcontroller;
    
    BigProductViewController *product_viewController;//单品大图
}

@end

@implementation HomeViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (IOS7_OR_LATER) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createMemuView];
    
    [self creatSearchRightBarButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 创建视图

-(void)creatSearchRightBarButton{
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    
//    searchBtn.backgroundColor = [UIColor orangeColor];
    
    [searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [searchBtn setFrame:CGRectMake(0, 0, 60, 30)];
//    searchBtn.backgroundColor = [UIColor orangeColor];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [searchBtn setImage:[UIImage imageNamed:@"gsearch_up.png"] forState:UIControlStateNormal];
    [searchBtn setImage:[UIImage imageNamed:@"gsearch_down.png"] forState:UIControlStateHighlighted];
    [searchBtn addTarget:self action:@selector(pushToSearchVc) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *btn_right = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -18;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,btn_right];
    
}

-(void)pushToSearchVc{
    GsearchViewController *gsearchVc = [[GsearchViewController alloc]init];
    gsearchVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gsearchVc animated:YES];
}


/**
 *  暂时去掉搭配师 创建选择首页选择view
 */
- (void)createMemuView
{
    
    CGFloat aWidth = (ALL_FRAME_WIDTH - 166)/ 3.f;
    menu_view = [[UIView alloc]initWithFrame:CGRectMake(0, 20, aWidth * 2, 30)];
    menu_view.clipsToBounds = YES;
//    menu_view.layer.cornerRadius = 15.f;
//    menu_view.layer.borderWidth = 1;
//    menu_view.layer.borderColor = [RGBCOLOR(253, 103, 154)CGColor];
    
    self.navigationItem.titleView = menu_view;
    
    NSArray *titles = @[@"精选",@"单品"];
    
    for (int i = 0; i < titles.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.backgroundColor = [UIColor orangeColor];
        btn.frame = CGRectMake(aWidth * i + 0.5 * i, 0, aWidth, 30);
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setHighlighted:NO];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        btn.tag = 100 + i;
        
        [menu_view addSubview:btn];
        [btn addTarget:self action:@selector(clickToSwap:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIButton *btn = (UIButton *)[menu_view viewWithTag:100];
    [self clickToSwap:btn];
    
    
    UIView *fengeLine = [[UIView alloc]initWithFrame:CGRectMake(aWidth, 8, 0.5, 16)];
    fengeLine.backgroundColor = RGBCOLOR(192, 193, 194);
//    fengeLine.backgroundColor = [UIColor blackColor];
    
    
//    fengeLine.center = menu_view.center;
//    menu_view.backgroundColor = [UIColor blackColor];
    [menu_view addSubview:fengeLine];
    
    
}


//- (void)createMemuView
//{
//    
//    CGFloat aWidth = (ALL_FRAME_WIDTH - 166)/ 3.f;
//    menu_view = [[UIView alloc]initWithFrame:CGRectMake(0, 20, aWidth * 3, 30)];
//    menu_view.clipsToBounds = YES;
//    menu_view.layer.cornerRadius = 15.f;
//    
//    self.navigationItem.titleView = menu_view;
//
//    NSArray *titles = @[@"值得买",@"衣+衣",@"搭配师"];
//    
//    for (int i = 0; i < titles.count; i ++) {
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.frame = CGRectMake(aWidth * i + 0.5 * i, 0, aWidth, 30);
//        
//        [btn setTitle:titles[i] forState:UIControlStateNormal];
//        btn.backgroundColor = [UIColor clearColor];
//        [btn setHighlighted:NO];
//        [btn.titleLabel setFont:[UIFont systemFontOfSize:13]];
//        btn.tag = 100 + i;
////        [btn setBackgroundImage:[UIImage imageNamed:normalImages[i]] forState:UIControlStateNormal];
////        [btn setBackgroundImage:[UIImage imageNamed:selectedImages[i]] forState:UIControlStateSelected];
//        
////        [btn setBackgroundImage:[UIImage imageNamed:normalImages[i]] forState:UIControlStateNormal];
////        [btn setBackgroundImage:[UIImage imageNamed:selectedImages[i]] forState:UIControlStateSelected];
//
//        
//        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor colorWithHexString:@"d7425c"] forState:UIControlStateSelected];
//        
//        [menu_view addSubview:btn];
//        [btn addTarget:self action:@selector(clickToSwap:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    UIButton *btn = (UIButton *)[menu_view viewWithTag:100];
//    [self clickToSwap:btn];
//
//}

#pragma mark - 事件处理

- (void)clickToSwap:(UIButton *)sender
{
    int tag = (int)sender.tag;
    
    NSLog(@"sender %@",sender);
    
    CGFloat aFrameY = 0;
    switch (tag) {
        case 101:
        {
            //单品的瀑布流模式
            
            if (buy_viewcontroller)
            {
                buy_viewcontroller.view.hidden = NO;
            }
            else
            {
                buy_viewcontroller = [[HomeBuyController alloc]init];
                buy_viewcontroller.view.frame = CGRectMake(0, aFrameY, self.view.frame.size.width, self.view.frame.size.height);
                buy_viewcontroller.rootViewController = self;
                [self.view addSubview:buy_viewcontroller.view];
            }
            
//            buy_viewcontroller.view.backgroundColor = [UIColor redColor];
            
            [self controlViewController:buy_viewcontroller];
            
            
            //单品的大图模式
            
//            if (product_viewController)
//            {
//                product_viewController.view.hidden = NO;
//            }
//            else
//            {
//                product_viewController = [[BigProductViewController alloc]init];
//                product_viewController.view.frame = CGRectMake(0, aFrameY, self.view.frame.size.width, self.view.frame.size.height);
//                product_viewController.rootViewController = self;
//                [self.view addSubview:product_viewController.view];
//            }
//            
//            
//            [self controlViewController:product_viewController];
            
        }
            break;
        case 100:
        {
            if (cloth_viewcontroller)
            {
                cloth_viewcontroller.view.hidden = NO;
            }
            else
            {
                cloth_viewcontroller = [[HomeClothController alloc]init];
                cloth_viewcontroller.view.frame = CGRectMake(0, aFrameY, self.view.frame.size.width, self.view.frame.size.height);
                cloth_viewcontroller.rootViewController = self;
                [self.view addSubview:cloth_viewcontroller.view];
            }
            
            [self controlViewController:cloth_viewcontroller];
            
            
        }
            break;
        case 102:
        {
            if (match_viewcontroller)
            {
                match_viewcontroller.view.hidden = NO;
            }
            else
            {
                match_viewcontroller = [[HomeMatchController alloc]init];
                match_viewcontroller.view.frame = CGRectMake(0, aFrameY, self.view.frame.size.width, self.view.frame.size.height  -35);
                match_viewcontroller.rootViewController = self;
                [self.view addSubview:match_viewcontroller.view];
            }
            
            match_viewcontroller.view.backgroundColor = [UIColor purpleColor];
            
            [self controlViewController:match_viewcontroller];
            
        }
            break;
        default:
            NSLog(@"Controller-Error");
            break;
    }
}


//改变字体和背景色
- (void)controlViewController:(UIViewController *)vc
{
    product_viewController.view.hidden = [vc isKindOfClass:[BigProductViewController class]] ? NO : YES;//大图单品模式
    buy_viewcontroller.view.hidden = [vc isKindOfClass:[HomeBuyController class]] ? NO : YES;//服务介绍
    cloth_viewcontroller.view.hidden = [vc isKindOfClass:[HomeClothController class]] ? NO : YES;//商家介绍
    match_viewcontroller.view.hidden = [vc isKindOfClass:[HomeMatchController class]] ? NO : YES;//商家服务
    

    
//    UIColor *normalColor_bgc = RGBCOLOR(253, 105, 155);
//    UIColor *selectColor_bgc = [UIColor whiteColor];
//    UIColor *normalColor_tt = RGBCOLOR(252, 104, 152);
//    UIColor *selectColor_tt = [UIColor whiteColor];
    
    //改变背景色
//    ((UIButton *)[menu_view viewWithTag:101]).backgroundColor = [vc isKindOfClass:[HomeBuyController class]] ? normalColor_bgc : selectColor_bgc;//服务介绍;
//    ((UIButton *)[menu_view viewWithTag:100]).backgroundColor = [vc isKindOfClass:[HomeClothController class]] ? normalColor_bgc : selectColor_bgc;//服务介绍;
//    ((UIButton *)[menu_view viewWithTag:102]).backgroundColor = [vc isKindOfClass:[HomeMatchController class]] ? normalColor_bgc : selectColor_bgc;//服务介绍;
    
    
    
//    UIColor *normalColor_bgc = RGBCOLOR(253, 105, 155);
//    UIColor *selectColor_bgc = [UIColor whiteColor];
    UIColor *normalColor_tt = [UIColor blackColor];
    UIColor *selectColor_tt = RGBCOLOR(245, 75, 135);
    
    //改变文字颜色
    UIButton *btn = (UIButton*)[menu_view viewWithTag:101];
    if ([vc isKindOfClass:[HomeBuyController class]] || [vc isKindOfClass:[BigProductViewController class]]) {
        [btn setTitleColor:selectColor_tt forState:UIControlStateNormal];
    }else{
        [btn setTitleColor:normalColor_tt forState:UIControlStateNormal];
    }
    
    UIButton *btn1 = (UIButton*)[menu_view viewWithTag:100];
    if ([vc isKindOfClass:[HomeClothController class]]) {
        [btn1 setTitleColor:selectColor_tt forState:UIControlStateNormal];
    }else{
        [btn1 setTitleColor:normalColor_tt forState:UIControlStateNormal];
    }
    
    
}

@end
