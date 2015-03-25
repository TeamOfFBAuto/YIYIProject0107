//
//  GScrollView.m
//  YiYiProject
//
//  Created by gaomeng on 14/12/27.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "GScrollView.h"

#import "NSDictionary+GJson.h"
#import "HomeClothController.h"
#import "UIView+Gstring.h"
#import "GBtn.h"

@implementation GScrollView



//block的set方法

-(void)setPinpaiViewBlock:(pinpaiViewBlock)pinpaiViewBlock{
    _pinpaiViewBlock = pinpaiViewBlock;
}


-(void)gReloadData{
    
    if (self.gtype == GNEARBYPINPAI) {//附近的品牌
        
        
        for (UIView *view in self.subviews) {
            [view removeFromSuperview];
        }
        
        
        NSInteger countNum = self.dataArray.count;
        
        self.contentSize = CGSizeMake(countNum *77, self.contentSize.height);
        
        for (int i = 0; i<countNum; i++) {
            NSDictionary *dic = self.dataArray[i];
            NSString *imvStr = [dic stringValueForKey:@"brand_logo"];
            NSString *nameStr = [dic stringValueForKey:@"brand_name"];
            
            UIView *pinpaiView = [[GView alloc]initWithFrame:CGRectMake(0+i*77, 0, 70, 120)];
            pinpaiView.tag = [[dic stringValueForKey:@"id"]intValue]+10;
            pinpaiView.gString = nameStr;
            pinpaiView.backgroundColor = RGBCOLOR(242, 242, 242);
            pinpaiView.userInteractionEnabled = YES;
            
            //手势
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ggdoTap:)];
            [pinpaiView addGestureRecognizer:tap];
            
            //距离
            NSString *distance_str = [dic stringValueForKey:@"distance"];
            CGFloat distance_float = [distance_str floatValue];
            if (distance_float>=1000) {
                distance_float = distance_float*0.001;
                distance_str = [NSString stringWithFormat:@"%.2fkm",distance_float];
            }else{
                distance_str = [NSString stringWithFormat:@"%@m",distance_str];
            }
            
            UILabel *distanceLabel = [[UILabel alloc]initWithFrame
                                      :CGRectMake(0, 10, 70, 13)];
            distanceLabel.font = [UIFont systemFontOfSize:13];
            distanceLabel.textColor = RGBCOLOR(114, 114, 114);
            distanceLabel.textAlignment = NSTextAlignmentCenter;
            distanceLabel.text = distance_str;
            [pinpaiView addSubview:distanceLabel];
            
            
            //logo
            UIImageView *yuanLogoImv = [[UIImageView alloc]initWithFrame:CGRectMake(2, CGRectGetMaxY(distanceLabel.frame)+10, 66, 66)];
            yuanLogoImv.layer.cornerRadius = 33;
            yuanLogoImv.layer.borderWidth = 1;
            yuanLogoImv.layer.masksToBounds = YES;
            yuanLogoImv.userInteractionEnabled = YES;
            yuanLogoImv.layer.borderColor = RGBCOLOR(212, 212, 212).CGColor;
            [yuanLogoImv sd_setImageWithURL:[NSURL URLWithString:imvStr] placeholderImage:nil];
            [pinpaiView addSubview:yuanLogoImv];
            
            //品牌名称
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(yuanLogoImv.frame)+10, 70, 13)];
            nameLabel.userInteractionEnabled = YES;
            nameLabel.font = [UIFont systemFontOfSize:13];
            nameLabel.text = nameStr;
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.textColor = RGBCOLOR(114, 114, 114);
            [pinpaiView addSubview:nameLabel];
            
            
            [self addSubview:pinpaiView];
            
        }
        
    }else if (self.gtype == GNEARBYSTORE){//附近的商店

        for (UIView *view in self.subviews) {
            [view removeFromSuperview];
        }
        
        
        
        NSInteger countNum = self.dataArray.count*0.5+1;
        NSInteger countNum_info = self.dataArray.count;
        
        if (DEVICE_WIDTH>320) {
            countNum = countNum<4?4:countNum;
        }else{
            countNum = countNum<3?3:countNum;
        }
        
        self.contentSize = CGSizeMake(countNum *118, self.contentSize.height);
        
        
        //红图和信息view
        for (int i = 0; i<countNum; i++) {
            //红图
            UIImageView *nearStoreView = [[UIImageView alloc]initWithFrame:CGRectMake(0+i*118, 60, 118, 113)];
            [nearStoreView setImage:[UIImage imageNamed:@"gnearstorered.png"]];
            
            [self addSubview:nearStoreView];
        }
        
        
        
        
        //数据源
        NSMutableArray *upDataArray = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *downDataArray = [NSMutableArray arrayWithCapacity:1];
        
        //单双信息分组
        for (int i = 0; i<countNum_info; i++) {
            
            NSDictionary *dic = self.dataArray[i];
            
            if (i%2==0) {//下
                [downDataArray addObject:dic];
            }else if (i%2==1){//上
                [upDataArray addObject:dic];
            }
        }
        
        NSInteger upArrayNum = upDataArray.count;
        NSInteger downArrayNum = downDataArray.count;
        
        //信息
        for (int i = 0; i<downArrayNum; i++) {//下
            NSDictionary *dic = downDataArray[i];
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(22+i*(38+80), 104, 80, 60)];
            view.userInteractionEnabled = YES;
            
            
            //小红点
            UIImageView *redPoint = [[UIImageView alloc]initWithFrame:CGRectMake(view.frame.size.width*0.5-8, -10, 12, 12)];
            [redPoint setImage:[UIImage imageNamed:@"dian_da.png"]];
            [view addSubview:redPoint];
            
            
            GBtn *storeNameBtn = [GBtn buttonWithType:UIButtonTypeCustom];
            [storeNameBtn setFrame:CGRectMake(-3, 2, view.frame.size.width, 35)];
            storeNameBtn.tag = [[dic stringValueForKey:@"mall_id"]integerValue]+10;
            [storeNameBtn addTarget:self action:@selector(goNearbyStoreVC:) forControlEvents:UIControlEventTouchUpInside];
            [storeNameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            storeNameBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            storeNameBtn.titleLabel.numberOfLines = 2;
            [storeNameBtn setBackgroundImage:[UIImage imageNamed:@"gdownname.png"] forState:UIControlStateNormal];
            [storeNameBtn setTitle:[dic stringValueForKey:@"mall_name"] forState:UIControlStateNormal];
            storeNameBtn.shopType = [dic stringValueForKey:@"mall_type"];
            
            
            //调整titleLabel间距
            [storeNameBtn setTitleEdgeInsets:UIEdgeInsetsMake(5, 1, 0, 1)];
            
            
            [view addSubview:storeNameBtn];
            //距离
            UILabel *distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(storeNameBtn.frame), view.frame.size.width, 25)];
            distanceLabel.font = [UIFont systemFontOfSize:13];
            distanceLabel.textAlignment = NSTextAlignmentCenter;
            distanceLabel.textColor = [UIColor whiteColor];
            distanceLabel.text = [NSString stringWithFormat:@"%@m",[dic stringValueForKey:@"distance"]];
            NSString *juli = [dic stringValueForKey:@"distance"];
            CGFloat juli_f = 0.0f;
            if ([juli intValue] >=1000) {
                juli_f = [juli floatValue]*0.001;
                distanceLabel.text = [NSString stringWithFormat:@"%.2fkm",juli_f];
            }
            
            [view addSubview:distanceLabel];
            
            [self addSubview:view];
        }
        
        for (int i =0; i<upArrayNum; i++) {//上
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(76+i*(38+80), 5, 80, 60)];

            NSDictionary *dic = upDataArray[i];
            //距离
            UILabel *distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 1, view.frame.size.width, 18)];

            distanceLabel.font = [UIFont systemFontOfSize:13];
            distanceLabel.textAlignment = NSTextAlignmentCenter;
            distanceLabel.textColor = [UIColor blackColor];
            distanceLabel.text = [NSString stringWithFormat:@"%@m",[dic stringValueForKey:@"distance"]];
            NSString *juli = [dic stringValueForKey:@"distance"];
            CGFloat juli_f = 0.0f;
            if ([juli intValue] >=1000) {
                juli_f = [juli floatValue]*0.001;
                distanceLabel.text = [NSString stringWithFormat:@"%.2fkm",juli_f];
            }
            [view addSubview:distanceLabel];
            
            //商城名字
            GBtn *storeNameBtn = [GBtn buttonWithType:UIButtonTypeCustom];

            [storeNameBtn setFrame:CGRectMake(3, CGRectGetMaxY(distanceLabel.frame), view.frame.size.width, 35)];
            storeNameBtn.tag = [[dic stringValueForKey:@"mall_id"]integerValue]+10;
            [storeNameBtn addTarget:self action:@selector(goNearbyStoreVC:) forControlEvents:UIControlEventTouchUpInside];
            [storeNameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            storeNameBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            storeNameBtn.titleLabel.numberOfLines = 2;
            [storeNameBtn setBackgroundImage:[UIImage imageNamed:@"gupname.png"] forState:UIControlStateNormal];
            [storeNameBtn setTitle:[dic stringValueForKey:@"mall_name"] forState:UIControlStateNormal];
            storeNameBtn.shopType = [dic stringValueForKey:@"mall_type"];
            //调整titleLabel间距
            [storeNameBtn setTitleEdgeInsets:UIEdgeInsetsMake(-4, 1, 0, 1)];
            [view addSubview:storeNameBtn];
            
            
            //小红点
            UIImageView *redPoint = [[UIImageView alloc]initWithFrame:CGRectMake(storeNameBtn.frame.size.width*0.5-4, CGRectGetMaxY(storeNameBtn.frame), 15, 15)];
            [redPoint setImage:[UIImage imageNamed:@"dian_da.png"]];
            [view addSubview:redPoint];
            
            
            
            [self addSubview:view];
        }
        
        
        
    }
    
    
    
    
    
    
}



//点击商城
-(void)goNearbyStoreVC:(GBtn*)sender{
    NSString *ssidStr = [NSString stringWithFormat:@"%d",sender.tag-10];
    
    NSLog(@"%@",sender.titleLabel.text);
    [self.delegate1 pushToNearbyStoreVCWithIdStr:ssidStr theStoreName:sender.titleLabel.text theType:sender.shopType];
}



//点击品牌
-(void)ggdoTap:(UITapGestureRecognizer *)sender{
//    if (self.pinpaiViewBlock) {
//        self.pinpaiViewBlock(sender.view.tag);
//    }
    
    NSString *ssidstr = [NSString stringWithFormat:@"%d",sender.view.tag-10];
    NSString *pinpaiName = sender.view.gString;
    [self.delegate1 pushToPinpaiDetailVCWithIdStr:ssidstr pinpaiName:pinpaiName];
    
    
}

@end
