//
//  LPhotoBrowser.m
//  YiYiProject
//
//  Created by lichaowei on 15/4/20.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "LPhotoBrowser.h"
#import "LShareSheetView.h"
#import "TDetailModel.h"
#import "MJPhotoView.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "TTaiCommentViewController.h"

#import "GStorePinpaiViewController.h"
#import "ProductDetailController.h"

@implementation LPhotoBrowser
{
    TDetailModel *detail_model;
    MBProgressHUD *loading;
    //红心
    UIButton *zan_btn;
    
    //评论button
    UIButton *commentButton;
    //喜欢button (显示数字)
    UIButton *likeNumButton;
    
    
    UIView *topView;//顶部view
    UIView *bottomView;//底部view
    UIView *bottom;
    BOOL isShowTool;//是否显示tools
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    isShowTool = YES;
    
    loading = [LTools MBProgressWithText:@"加载中..." addToView:self.view];
    
    [self getTTaiDetail];//获取t台详情
}

#pragma - mark 创建视图

/**
 *  工具栏
 */
- (void)createToolbar
{
    topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 49)];
    topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topView];
    
    //顶部
    UIButton *closeButton = [LTools createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 49, 49) normalTitle:nil image:BACK_DEFAULT_IMAGE backgroudImage:nil superView:self.view target:self action:@selector(clickToClose:)];
    [topView addSubview:closeButton];
    
    //转发
    UIButton *zhuan_btn = [LTools createButtonWithType:UIButtonTypeCustom frame:CGRectMake(DEVICE_WIDTH - 10 - 26, 0, 26, 50) normalTitle:nil image:[UIImage imageNamed:@"fenxiangb"] backgroudImage:nil superView:nil target:self action:@selector(clickToZhuanFa:)];
    [topView addSubview:zhuan_btn];
}

- (void)createBottomTools
{
    //底部
    
    bottom = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 49, DEVICE_WIDTH, 49)];
    [self.view addSubview:bottom];
    bottom.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.9];
    
    bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 49, DEVICE_WIDTH, 49)];
    [self.view addSubview:bottomView];
    bottomView.backgroundColor = [UIColor clearColor];
    
    NSString *iconUrl = @"";
    NSString *userName = @"";
    if ([detail_model.uinfo isKindOfClass:[NSDictionary class]]) {
        
        iconUrl = detail_model.uinfo[@"photo"];
        userName = detail_model.uinfo[@"user_name"];
    }

    
    //头像
    UIImageView *iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 7, 35, 35)];
    iconImageView.layer.cornerRadius = 35/2.f;
    iconImageView.clipsToBounds = YES;
//    iconImageView.backgroundColor = [UIColor redColor];
    [bottomView addSubview:iconImageView];
    [iconImageView sd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:DEFAULT_HEADIMAGE];
    
    //红心
    zan_btn = [LTools createButtonWithType:UIButtonTypeCustom frame:CGRectMake(DEVICE_WIDTH - 10 - 50, 0, 50, 50) normalTitle:nil image:[UIImage imageNamed:@"xq_love_up"] backgroudImage:nil superView:nil target:self action:@selector(clickToZan:)];
    [bottomView addSubview:zan_btn];
    [zan_btn setImage:[UIImage imageNamed:@"xq_love_down"] forState:UIControlStateSelected];
    
    zan_btn.selected = detail_model.is_like == 1 ? YES : NO;

    //喜欢的数字
    
    NSString *likeNum = [NSString stringWithFormat:@"%@人喜欢",detail_model.tt_like_num];
    CGFloat likeWidth = [LTools widthForText:likeNum font:14];
    
    likeNumButton = [LTools createButtonWithType:UIButtonTypeCustom frame:CGRectMake(zan_btn.left - likeWidth - 20, 0, likeWidth, bottomView.height) normalTitle:likeNum image:nil backgroudImage:nil superView:nil target:self action:@selector(clickToCommentPage:)];
    [likeNumButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [bottomView addSubview:likeNumButton];
    
    //评论数字
    
    NSString *commentNum = [NSString stringWithFormat:@"%@条评论",detail_model.tt_like_num];
    likeWidth = [LTools widthForText:commentNum font:14];
    
    commentButton = [LTools createButtonWithType:UIButtonTypeCustom frame:CGRectMake(likeNumButton.left - likeWidth - 20, 0, likeWidth, bottomView.height) normalTitle:commentNum image:nil backgroudImage:nil superView:nil target:self action:@selector(clickToCommentPage:)];
    [commentButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [bottomView addSubview:commentButton];
}

#pragma - mark 事件处理

#pragma mark---锚点的点击方法
//到商场的
-(void)turntoshangchang:(UITapGestureRecognizer *)sender{
    
    NSLog(@"xxxshanchang==%ld",sender.view.tag);
    
    UILabel *testlabel=(UILabel *)sender.view;
    
    GStorePinpaiViewController *detail = [[GStorePinpaiViewController alloc]init];
    detail.storeIdStr =[NSString stringWithFormat:@"%ld",sender.view.tag] ;
    detail.storeNameStr=testlabel.text;
//    [self.navigationController pushViewController:detail animated:YES];
    
    LNavigationController *unvc = [[LNavigationController alloc]initWithRootViewController:detail];
    
    [self presentViewController:unvc animated:YES completion:nil];
    
}
//到单品的
-(void)turntodanpin:(UITapGestureRecognizer *)sender{
    
    NSLog(@"xxxsdanpin==%ld",sender.view.tag);
    
    ProductDetailController *detail = [[ProductDetailController alloc]init];
    detail.product_id =[NSString stringWithFormat:@"%ld",sender.view.tag] ;
    
    detail.isPresent = YES;
    
    LNavigationController *unvc = [[LNavigationController alloc]initWithRootViewController:detail];
    
//    [self.navigationController pushViewController:unvc animated:YES];
    
    [self presentViewController:unvc animated:YES completion:nil];
    
}

/**
 *  添加锚点
 */
- (void)addMaoDian:(TDetailModel *)aModel
{
    //史忠坤修改
    
    int image_have_detail=0;
    
    NSArray *img_detail=[NSArray array];
    
    if ([aModel.image isKindOfClass:[NSDictionary class]]) {
        
        image_have_detail=[aModel.image[@"have_detail"]intValue ];
        
        img_detail=aModel.image[@"img_detail"];
        
    }
       if (image_have_detail>0) {
        //代表有锚点，0代表没有锚点
        
        for (int i=0; i<img_detail.count; i++) {
            
            /*{
             dateline = 1427958416;
             "img_x" = "0.2000";
             "img_y" = "0.4000";
             "product_id" = 100;
             "shop_id" = 2654;
             "tt_id" = 26;
             "tt_img_id" = 0;
             "tt_img_info_id" = 1;
             },*/
            NSDictionary *maodian_detail=(NSDictionary *)[img_detail objectAtIndex:i];
            
            
            [self createbuttonWithModel:maodian_detail];
            
        }}

}

#pragma mark--等到加载完图片之后再加载图片上的三个button

-(void)createbuttonWithModel:(NSDictionary*)maodian_detail{
    
    
    UIView *bigImageView = [self currentPhotoView];
    
    bigImageView.userInteractionEnabled= YES;
    
    
    NSInteger product_id=[maodian_detail[@"product_id"] integerValue];
    
    NSInteger shop_id=[maodian_detail[@"shop_id"] integerValue];
    
    float dx=[maodian_detail[@"img_x"] floatValue];
    float dy=[maodian_detail[@"img_y"] floatValue];
    
    if (product_id>0) {
        //说明是单品
        
        UILabel *_centerLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH/3, 100)];
        _centerLabel.backgroundColor=RGBCOLOR(70,81,76);
        _centerLabel.alpha = 0.8f;
        _centerLabel.textColor=[UIColor whiteColor];
        _centerLabel.font=[UIFont systemFontOfSize:13];
        _centerLabel.layer.cornerRadius=5;
        _centerLabel.layer.masksToBounds=YES;
        _centerLabel.layer.borderWidth = 1.f;
        _centerLabel.layer.borderColor = [RGBCOLOR(252, 76, 139)CGColor];
        _centerLabel.numberOfLines=3;
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.text=maodian_detail[@"product_name"];
        _centerLabel.tag=product_id;
        
        
        //        _centerLabel.center = CGPointMake(dx*bigImageView.frame.size.width, dy*bigImageView.frame.size.height);
        
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 13, 13)];
        [imv setImage:[UIImage imageNamed:@"gbutton.png"]];
        imv.center = CGPointMake(dx*bigImageView.frame.size.width, dy*bigImageView.frame.size.height);
        [bigImageView addSubview:imv];
        
        _centerLabel.frame=CGRectMake(CGRectGetMaxX(imv.frame), imv.frame.origin.y, _centerLabel.frame.size.width+4, _centerLabel.frame.size.height+4);
        [_centerLabel sizeToFit];
        
        [bigImageView addSubview:_centerLabel];
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(turntodanpin:)];
        _centerLabel.userInteractionEnabled=YES;
        
        [_centerLabel addGestureRecognizer:tap];
        
    }else{
        
        //说明是品牌店面
        UILabel *_centerLabel=[[UILabel alloc]initWithFrame:CGRectZero];
        _centerLabel.backgroundColor=RGBCOLOR(255, 0, 0);
        _centerLabel.textColor=[UIColor colorWithRed:220/255.f green:220/255.f blue:230/255.f alpha:1];
        _centerLabel.font=[UIFont systemFontOfSize:12];
        _centerLabel.layer.cornerRadius=3;
        _centerLabel.layer.masksToBounds=YES;
        _centerLabel.numberOfLines=3;
        _centerLabel.textAlignment=NSTextAlignmentCenter;
        _centerLabel.text=maodian_detail[@"shop_name"];
        [_centerLabel sizeToFit];
        _centerLabel.tag=shop_id;
        _centerLabel.frame=CGRectMake(dx*bigImageView.frame.size.width, dy*bigImageView.frame.size.height, _centerLabel.frame.size.width+4, _centerLabel.frame.size.height+4);
        [bigImageView addSubview:_centerLabel];
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(turntoshangchang:)];
        _centerLabel.userInteractionEnabled=YES;
        
        [_centerLabel addGestureRecognizer:tap];
        
    }
    
}




/**
 *  显示或隐藏tools
 */
- (void)showOrHiddenTool
{
    BOOL show = isShowTool = !isShowTool;
    __block UIView *top = topView;
    __block UIView *bBottomV = bottomView;
    __block UIView *bBottom = bottom;
    [UIView animateWithDuration:0.2 animations:^{
       
        top.top = show ? 0 : -49;
        bBottom.top = show ? DEVICE_HEIGHT - 49 : DEVICE_HEIGHT;
        bBottomV.top = show ? DEVICE_HEIGHT - 49 : DEVICE_HEIGHT;
    }];
}

#pragma mark - MJPhotoView代理

/**
 *  重写父类代理方法
 *
 */
- (void)photoViewSingleTap:(MJPhotoView *)photoView
{
    [self showOrHiddenTool];
}

/**
 *  更新喜欢数
 */
- (void)updateLikeNum
{
    NSString *likeNum = [NSString stringWithFormat:@"%@人喜欢",detail_model.tt_like_num];
    [likeNumButton setTitle:likeNum forState:UIControlStateNormal];
}
/**
 *  更新评论数
 */
- (void)updateCommentNum
{
    NSString *commentNum = [NSString stringWithFormat:@"%@条评论",detail_model.tt_like_num];
    [commentButton setTitle:commentNum forState:UIControlStateNormal];
}

- (void)clickToCommentPage:(UIButton *)sender
{
    //评论页面
    
    TTaiCommentViewController *comment = [[TTaiCommentViewController alloc]init];
    
    comment.tt_id = self.tt_id;
    
    LNavigationController *unVc = [[LNavigationController alloc]initWithRootViewController:comment];
    
    [self presentViewController:unVc animated:YES completion:nil];
    
//    [self.navigationController pushViewController:comment animated:YES];
    
}


- (void)clickToZan:(UIButton *)sender
{
//    if ([LTools cacheBoolForKey:LOGIN_SERVER_STATE] == NO) {
//        
//        LoginViewController *login = [[LoginViewController alloc]init];
//        
//        login.isSpecial = YES;
//        
//        LNavigationController *unVc = [[LNavigationController alloc]initWithRootViewController:login];
//                
//        UIWindow *window = [UIApplication sharedApplication].keyWindow;
//        [window addSubview:unVc.view];
//        [window.rootViewController addChildViewController:unVc];
//
//    }else
//    {
//        sender.selected = !sender.selected;
//        [self zanTTaiDetail:sender.selected];
//    }
    
    if ([LTools isLogin:self]) {
        
        sender.selected = !sender.selected;
        [self zanTTaiDetail:sender.selected];
    }
    
}

- (void)clickToZhuanFa:(UIButton *)sender
{
    [[LShareSheetView shareInstance] showShareContent:detail_model.tt_content title:@"衣加衣" shareUrl:@"http://www.alayy.com" shareImage:self.showImageView.image targetViewController:self];
    [[LShareSheetView shareInstance]actionBlock:^(NSInteger buttonIndex, Share_Type shareType) {
        
        if (shareType == Share_QQ) {
            
            NSLog(@"Share_QQ");
            
        }else if (shareType == Share_QQZone){
            
            NSLog(@"Share_QQZone");
            
        }else if (shareType == Share_WeiBo){
            
            NSLog(@"Share_WeiBo");
            
        }else if (shareType == Share_WX_HaoYou){
            
            NSLog(@"Share_WX_HaoYou");
            
        }else if (shareType == Share_WX_PengYouQuan){
            
            NSLog(@"Share_WX_PengYouQuan");
            
        }
        
    }];
    
    [[LShareSheetView shareInstance]shareResult:^(Share_Result result, Share_Type type) {
        
        if (result == Share_Success) {
            
            //分享 + 1
            NSLog(@"分享成功");
            
            [self zhuanFaTTaiDetail];
            
        }else
        {
            //分享失败
            
            NSLog(@"分享失败");
        }
        
    }];
}


- (void)clickToClose:(UIButton *)sender
{
    [self hide];
}

#pragma - mark 网络请求

//T台赞 或 取消

- (void)zanTTaiDetail:(BOOL)zan
{
    NSString *authkey = [GMAPI getAuthkey];
    NSString *post = [NSString stringWithFormat:@"tt_id=%@&authcode=%@",self.tt_id,authkey];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *url;
    
    if (zan) {
        url = TTAI_ZAN;
    }else
    {
        url = TTAI_ZAN_CANCEL;
    }
    
    __weak typeof(self)weakSelf = self;
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:YES postData:postData];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"-->%@",result);
        
        zan_btn.selected = zan;
        
        int like_num = [detail_model.tt_like_num intValue];
        detail_model.tt_like_num = [NSString stringWithFormat:@"%d",zan ? like_num + 1 : like_num - 1];

        [weakSelf updateLikeNum];
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        [LTools showMBProgressWithText:failDic[@"msg"] addToView:self.view];
    }];
}


//T台详情

- (void)getTTaiDetail
{
    
    [loading show:YES];
    
    __weak typeof(self)weakSelf = self;
    
    NSString *url = [NSString stringWithFormat:TTAI_DETAIL,self.tt_id,[GMAPI getAuthkey]];
    
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        
        [loading hide:YES];
        
        detail_model = [[TDetailModel alloc]initWithDictionary:result];
        
//        [weakSelf createViewsWithModel:detail_model];
//        
//        [weakSelf setViewWithModel:detail_model];
        
        [weakSelf addMaoDian:detail_model];
        
        [weakSelf createBottomTools];
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failBlock == %@",failDic[RESULT_INFO]);
        
        [loading hide:YES];
        
    }];
}


// 转发 + 1

- (void)zhuanFaTTaiDetail
{
    NSString *authkey = [GMAPI getAuthkey];
    
    if (authkey.length == 0) {
        return;
    }
    
    NSString *post = [NSString stringWithFormat:@"tt_id=%@&authcode=%@",self.tt_id,authkey];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *url = TTAI_ZHUANFA_ADD;
    
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:YES postData:postData];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"-->%@",result);
        
//        int like_num = [detail_model.tt_share_num intValue];
//        detail_model.tt_like_num = [NSString stringWithFormat:@"%d",like_num + 1];
//        zhuan_num_label.text = detail_model.tt_like_num;
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        [LTools showMBProgressWithText:failDic[@"msg"] addToView:self.view];
    }];
}


@end
