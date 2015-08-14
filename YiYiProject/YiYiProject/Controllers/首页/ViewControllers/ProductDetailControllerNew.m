//
//  ProductDetailControllerNew.m
//  YiYiProject
//
//  Created by lichaowei on 15/8/11.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ProductDetailControllerNew.h"

#import "ProductModel.h"
#import "LShareSheetView.h"
#import "YIYIChatViewController.h"
#import "GLeadBuyMapViewController.h"
#import "LoginViewController.h"

#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

#import "GAddTtaiImageLinkViewController.h"
#import "TMPhotoQuiltViewCell.h"
#import "LContactView.h"//联系view
#import "BottomToolsView.h"//底部工具
#import "LWaterflowView.h"//瀑布流
#import "CycleScrollView1.h"//上下滚动
#import "MessageDetailController.h"//活动详情
#import "ProductListForTagController.h"//标签对应单品列表
#import "TopicCommentsModel.h"//评论
#import "TTaiCommentViewController.h"//评论列表

@interface ProductDetailControllerNew ()<TMQuiltViewDataSource,WaterFlowDelegate,UIScrollViewDelegate>
{
    ProductModel *_aModel;
    
    UIButton *heartButton;//赞 与 取消赞
    
    UIButton *collectButton;//收藏 与 取消收藏
    
    MBProgressHUD *loading;
    
    LTools *tool_detail;
    
    NSArray *image_urls;//图片链接数组
    
    UIScrollView *_headerView;
    LWaterflowView *_waterFlow;
    
    UILabel *_backLabel;//释放返回
    UILabel *_zanNumLabel;//赞数量label
    UILabel *_commentNumLabel;//评论数量label
    UILabel *_addressLabel_current;//当前位置
    
    int _count;//网络请求完成个数
    NSArray *_sameStyleArray;//同款单品
    CGFloat _latitude;//维度
    CGFloat _longtitude;//经度
    NSString *_addressDetail;//地址详细信息
    NSArray *_commentArray;//评论
    int _commentCount;//评论总数
}

@property (strong, nonatomic) UILabel *brandName;

@property (strong, nonatomic) UILabel *shopNameLabel;
@property (strong, nonatomic) UIImageView *bigImageView;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UILabel *discountLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *xingHaoLabel;
@property (strong, nonatomic) UILabel *biaoQianLabel;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UIButton *bugButton;
@property (strong, nonatomic) UIButton *shopButton;
@property (weak, nonatomic) UIButton *lianxiDianzhuBtn;

@property(nonatomic,strong)ProductModel *theModel;//单品model 给聊天界面传递


@end

@implementation ProductDetailControllerNew

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if (self.isTPlatPush) {
        
        self.navigationController.navigationBarHidden = YES;
        
        [[UIApplication sharedApplication]setStatusBarHidden:NO];
    }
    
    self.navigationController.navigationBarHidden = NO;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:self.lastPageNavigationHidden animated:animated];
    
}

- (void)dealloc
{
    NSLog(@"dealloc %@",self);
    [tool_detail cancelRequest];
    heartButton = nil;
    collectButton = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    [self createNavigationbarTools];//导航条
    
    [self.bugButton addCornerRadius:3.f];
    
    [self addProductVisit];//添加单品浏览数
    
    [self addObserver:self forKeyPath:@"_count" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    //瀑布流相关
    _waterFlow = [[LWaterflowView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) waterDelegate:self waterDataSource:self noHeadeRefresh:YES noFooterRefresh:YES];
    _waterFlow.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_waterFlow];

    _waterFlow.hidden = YES;
    
    //下拉 返回上面内容
    _backLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40) title:@"下拉,返回单品详情" font:10 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"8b8b8b"]];
    [_waterFlow addSubview:_backLabel];
    [_waterFlow bringSubviewToFront:_waterFlow.quitView];
    _waterFlow.hidden = YES;
    
    CGFloat aHeight = [LTools heightForImageHeight:42 imageWidth:375 showWidth:DEVICE_WIDTH];
    UIImageView *lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, aHeight)];
    lineImage.image = [UIImage imageNamed:@"danpinxq_tuijian"];
    lineImage.contentMode = UIViewContentModeCenter;
    _waterFlow.headerView = lineImage;
    
    [self getCurrentLocation];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求

/**
 *  获取单品详情
 */
- (void)networkForDetail
{
    if (tool_detail) {
        [tool_detail cancelRequest];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self)weakSelf = self;
    
    self.product_id = @"146";
    NSString *url = [NSString stringWithFormat:HOME_PRODUCT_DETAIL,self.product_id,[GMAPI getAuthkey]];
    tool_detail = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    
    [tool_detail requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@",result);
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([result isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic = result[@"pinfo"];
            
            ProductModel *aModel1 = [[ProductModel alloc]initWithDictionary:dic];
            weakSelf.theModel = aModel1;
            _aModel = aModel1;
            [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        }
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failBlock == %@",failDic[RESULT_INFO]);
        
    }];
}

/**
 *  获取单品同款
 */
- (void)networkForDetailSameStyle
{
    __weak typeof(self)weakSelf = self;
    
    self.product_id = @"146";
    NSString *url = [NSString stringWithFormat:HOME_PRODUCT_DETAIL_SAME_STYLE,_longtitude,_latitude,self.product_id];
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@",result);
        NSArray *list = result[@"list"];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:list.count];
        for (NSDictionary *aDic in list) {
            ProductModel *aModel = [[ProductModel alloc]initWithDictionary:aDic];
            [temp addObject:aModel];
        }
        _sameStyleArray = [NSArray arrayWithArray:temp];
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];

        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failBlock == %@",failDic[RESULT_INFO]);
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
    }];
}

/**
 *  获取单品评论列表
 */
- (void)networkForCommentList
{
    __weak typeof(self)weakSelf = self;
    
    self.product_id = @"11";
    NSString *url = [NSString stringWithFormat:PRODUCT_COMMENT_LIST,self.product_id];
    url = [NSString stringWithFormat:@"%@&page=%d&per_page=%d",url,1,10];
    
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@",result);
        _commentCount  = [[result objectForKey:@"total"] intValue];
        NSArray * commentsArray = [result objectForKey:@"list"];
        
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:commentsArray.count];
        
        for (NSDictionary * dic in commentsArray)
        {
            TopicCommentsModel * model = [[TopicCommentsModel alloc] initWithDictionary:dic];
            model.reply_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"post_id"]];
            model.repost_uid = [NSString stringWithFormat:@"%@",[dic objectForKey:@"uid"]];
            [arr addObject:model];
        }
        _commentArray = [NSArray arrayWithArray:arr];
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];

        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failBlock == %@",failDic[RESULT_INFO]);
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
    }];
}


/**
 *  赞 取消赞 收藏 取消收藏
 *
 *  @param action_type
 */
- (void)networkForActionType:(ACTION_TYPE)action_type
{
    
    __weak typeof(self)weakSelf = self;
    
    NSString *api;
    if (action_type == Action_like_yes) {
        api = HOME_PRODUCT_ZAN_ADD;
    }else if (action_type == Action_Collect_yes){
        api = HOME_PRODUCT_COLLECT_ADD;
    }else if (action_type == Action_like_no){
        api = HOME_PRODUCT_ZAN_Cancel;
    }else if (action_type == Action_Collect_no){
        
        api = HOME_PRODUCT_COLLECT_Cancel;
    }
    
    NSString *post = [NSString stringWithFormat:@"product_id=%@&authcode=%@",self.product_id,[GMAPI getAuthkey]];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *url = api;
    
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:YES postData:postData];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@",result);
        
        if (action_type == Action_like_yes) {
            
            [weakSelf updateZanState:YES];
            
            //更改上一个界面的状态  从我的店铺界面跳转
            if (self.theLastViewClickedCell) {
                
                //赞的红心状态
                weakSelf.theLastViewClickedCell.like_btn.selected = YES;
                int zanNum = [weakSelf.theLastViewClickedCell.like_label.text intValue];
                zanNum++;
                weakSelf.theLastViewClickedCell.like_label.text = [NSString stringWithFormat:@"%d",zanNum];
                
                //赞后面的数字
                weakSelf.theLastViewProductModel.is_like = 1;
                int like_num = [weakSelf.theLastViewProductModel.product_like_num intValue];
                like_num++;
                weakSelf.theLastViewProductModel.product_like_num = [NSString stringWithFormat:@"%d",like_num];
            }
            
            //更改上一个界面的状态  从首页单品跳转
            if (self.theHomeBuyVcProductCell) {
                
                if (self.theHomeBuyVcModel) {
                    
                    //赞的红心状态
                    self.theHomeBuyVcProductCell.like_btn.selected = YES;
                    int zanNum = [self.theHomeBuyVcProductCell.like_label.text intValue];
                    zanNum++;
                    self.theHomeBuyVcProductCell.like_label.text = [NSString stringWithFormat:@"%d",zanNum];
                    
                    //赞后面的数字
                    self.theHomeBuyVcModel.is_like = 1;
                    int like_num = [self.theHomeBuyVcModel.product_like_num intValue];
                    like_num++;
                    self.theHomeBuyVcModel.product_like_num = [NSString stringWithFormat:@"%d",like_num];
                }
                
            }
            
            //更改上一个界面的状态  从收藏界面跳转
            if (self.theMyshoucangProductCell) {
                
                //赞的红心状态
                self.theMyshoucangProductCell.like_btn.selected = YES;
                int zanNum = [self.theMyshoucangProductCell.like_label.text intValue];
                zanNum++;
                self.theMyshoucangProductCell.like_label.text = [NSString stringWithFormat:@"%d",zanNum];
                
                //赞后面的数字
                self.theMyshoucangProductModel.is_like = 1;
                int like_num = [self.theMyshoucangProductModel.product_like_num intValue];
                like_num++;
                self.theMyshoucangProductModel.product_like_num = [NSString stringWithFormat:@"%d",like_num];
            }
            
            
            //更改上一个界面的状态  从店铺详情页跳转
            if (self.theStorePinpaiProductCell) {
                
                //赞的红心状态
                self.theStorePinpaiProductCell.like_btn.selected = YES;
                int zanNum = [self.theStorePinpaiProductCell.like_label.text intValue];
                zanNum++;
                self.theStorePinpaiProductCell.like_label.text = [NSString stringWithFormat:@"%d",zanNum];
                
                //赞后面的数字
                self.theStorePinpaiProductModel.is_like = 1;
                int like_num = [self.theStorePinpaiProductModel.product_like_num intValue];
                like_num++;
                self.theStorePinpaiProductModel.product_like_num = [NSString stringWithFormat:@"%d",like_num];
            }
            
        }else if (action_type == Action_Collect_yes){
            
            collectButton.selected = YES;
            //关注单品通知
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_GUANZHU_PRODUCT object:nil userInfo:@{@"state":[NSNumber numberWithBool:YES]}];
            
        }else if (action_type == Action_like_no){
            

            [weakSelf updateZanState:NO];
            
            //更改上一个界面的状态 从我的店铺界面跳转
            if (self.theLastViewClickedCell) {
                //赞的红心状态
                self.theLastViewClickedCell.like_btn.selected = NO;
                int zanNum = [self.theLastViewClickedCell.like_label.text intValue];
                zanNum--;
                self.theLastViewClickedCell.like_label.text = [NSString stringWithFormat:@"%d",zanNum];
                //赞后面的数字
                self.theLastViewProductModel.is_like = 0;
                int like_num = [self.theLastViewProductModel.product_like_num intValue];
                like_num--;
                self.theLastViewProductModel.product_like_num = [NSString stringWithFormat:@"%d",like_num];
                
            }
            
            //更改上一个界面的状态 从首页单品标签跳转
            if (self.theHomeBuyVcProductCell) {
                
                if (self.theHomeBuyVcModel) {
                    //赞的红心状态
                    self.theHomeBuyVcProductCell.like_btn.selected = NO;
                    int zanNum = [self.theHomeBuyVcProductCell.like_label.text intValue];
                    zanNum--;
                    self.theHomeBuyVcProductCell.like_label.text = [NSString stringWithFormat:@"%d",zanNum];
                    //赞后面的数字
                    self.theHomeBuyVcModel.is_like = 0;
                    int like_num = [self.theHomeBuyVcModel.product_like_num intValue];
                    like_num--;
                    self.theHomeBuyVcModel.product_like_num = [NSString stringWithFormat:@"%d",like_num];
                }
                
            }
            
            //更改上一个界面的状态  从收藏界面跳转
            if (self.theMyshoucangProductCell) {
                //赞的红心状态
                self.theMyshoucangProductCell.like_btn.selected = NO;
                int zanNum = [self.theMyshoucangProductCell.like_label.text intValue];
                zanNum--;
                self.theMyshoucangProductCell.like_label.text = [NSString stringWithFormat:@"%d",zanNum];
                //赞后面的数字
                self.theMyshoucangProductModel.is_like = 0;
                int like_num = [self.theMyshoucangProductModel.product_like_num intValue];
                like_num--;
                self.theMyshoucangProductModel.product_like_num = [NSString stringWithFormat:@"%d",like_num];
            }
            
            
            //更改上一个界面的状态  从店铺详情页跳转
            
            if (self.theStorePinpaiProductCell) {
                //赞的红心状态
                self.theStorePinpaiProductCell.like_btn.selected = NO;
                int zanNum = [self.theStorePinpaiProductCell.like_label.text intValue];
                zanNum--;
                self.theStorePinpaiProductCell.like_label.text = [NSString stringWithFormat:@"%d",zanNum];
                //赞后面的数字
                self.theStorePinpaiProductModel.is_like = 0;
                int like_num = [self.theStorePinpaiProductModel.product_like_num intValue];
                like_num--;
                self.theStorePinpaiProductModel.product_like_num = [NSString stringWithFormat:@"%d",like_num];
            }
            
            
            
        }else if (action_type == Action_Collect_no){
            
            collectButton.selected = NO;
            //关注单品通知
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_GUANZHU_PRODUCT object:nil userInfo:@{@"state":[NSNumber numberWithBool:NO]}];
        }
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failBlock == %@",failDic[RESULT_INFO]);
        
    }];
}

/**
 *  添加单品浏览量
 */
- (void)addProductVisit
{
    //判断是否登录
    NSString *url = @" ";
    if ([LTools cacheBoolForKey:LOGIN_SERVER_STATE]) {
        url = [NSString stringWithFormat:@"%@&product_id=%@&authcode=%@",LIULAN_NUM_PRODUCT,self.product_id,[GMAPI getAuthkey]];
        
    }else{
        url = [NSString stringWithFormat:@"%@&product_id=%@",LIULAN_NUM_PRODUCT,self.product_id];
    }
    LTools *ccc = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [ccc requestCompletion:^(NSDictionary *result, NSError *erro) {
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
    }];
}

/**
 *  获取品牌推荐
 */
- (void)getRecommentProductList
{
    //test
    self.product_id = @"146";

    NSString *url = [NSString stringWithFormat:PRODUCT_LIST_SAME_BRAND_RECOMMENT,self.product_id,_waterFlow.pageNum,L_PAGE_SIZE,[GMAPI getAuthkey]];

    __weak typeof(self)weakSelf = self;
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        [weakSelf parseDataWithResult:result];
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failBlock == %@",failDic[RESULT_INFO]);
        [_waterFlow loadFail];
        
    }];
}

#pragma - mark 解析数据

- (void)parseDataWithResult:(NSDictionary *)result
{
    NSMutableArray *arr;
    if ([result isKindOfClass:[NSDictionary class]]) {
        
        NSArray *list = result[@"list"];
        arr = [NSMutableArray arrayWithCapacity:list.count];
        if ([list isKindOfClass:[NSArray class]]) {
            
            for (NSDictionary *aDic in list) {
                
                ProductModel *model = [[ProductModel alloc]initWithDictionary:aDic];
                
                [arr addObject:model];
            }
            
            
            [_waterFlow reloadData:arr pageSize:L_PAGE_SIZE];
        }
        
    }
    
}


#pragma mark - 事件处理

/**
 *  监控 单品详情 和 相似单品都请求完再显示
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"keyPath %@",change);
    
    NSNumber *num = [change objectForKey:@"new"];
    if ([num intValue] == 3) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (_aModel) {
            _aModel.sameStyleArray = _sameStyleArray;
            
            [self prepareViewWithModel:_aModel];
        }
    }
}

/**
 *  跳转活动详情页
 */
- (void)clickToActivity:(UIButton *)sender
{
    NSString *activityId = _aModel.official_activity[@"id"];
    MessageDetailController *detail = [[MessageDetailController alloc]init];
    detail.isActivity = YES;
    detail.msg_id = activityId;
    [self.navigationController pushViewController:detail animated:YES];
}

/**
 *  点击标签调转至对应单品列表
 *
 *  @param sender
 */
- (void)clickToTagList:(UIButton *)sender
{
    NSArray *tagList = _aModel.tag;
    int index = (int)sender.tag - 100;
    ProductListForTagController *list = [[ProductListForTagController alloc]init];
    list.tag_id = [tagList[index] objectForKey:@"tag_id"];
    list.tag_name = [tagList[index] objectForKey:@"tag_name"];
    [self.navigationController pushViewController:list animated:YES];
}

- (void)getCurrentLocation
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self)weakSelf = self;
    [[GMAPI appDeledate]startDingweiWithBlock:^(NSDictionary *dic) {
        
        [weakSelf theLocationDictionary:dic];
    }];

}


#pragma - mark 地图坐标

- (void)theLocationDictionary:(NSDictionary *)dic{
    
    NSLog(@"当前坐标-->%@",dic);
    
    CGFloat lat = [dic[@"lat"]doubleValue];;
    CGFloat lon = [dic[@"long"]doubleValue];
    
    _latitude = lat;
    _longtitude = lon;
    
    BOOL result = [dic[@"result"] boolValue];
    if (result) {
        
        NSString *address = dic[@"addressDetail"];
        _addressDetail = address;
    }else
    {
        _addressDetail = @"未获取到当前位置";
    }
    
    //请求单品详情
    [self networkForDetail];
    
    //请求单品同款
    [self networkForDetailSameStyle];
    
    //请求评论
    
    [self networkForCommentList];
    
    //品牌推荐
    [self getRecommentProductList];

}

/**
 *  赞数量大于1000显示 k
 *
 *  @param zanNum
 *
 *  @return
 */
- (NSString *)zanNumStringForNum:(NSString *)zanNum
{
    int num = [zanNum intValue];
    if (num >= 1000) {
        
        return [NSString stringWithFormat:@"%.1fk",num * 0.001];
    }
    return zanNum;
}

/**
 *  更新赞的状态
 *
 *  @param isZan 是否赞
 */
- (void)updateZanState:(BOOL)isZan
{
    if (isZan) {
        heartButton.selected = YES;
        _aModel.product_like_num = NSStringFromInt([_aModel.product_like_num intValue] + 1);
    }else
    {
        heartButton.selected = NO;
        _aModel.product_like_num = NSStringFromInt([_aModel.product_like_num intValue] - 1);
    }
    _zanNumLabel.text = [self zanNumStringForNum:_aModel.product_like_num];
    
}


/**
 *  上拉下拉移动视图
 *
 *  @param up 是否上拉
 */
- (void)moveToUp:(BOOL)up
{
    if (up) {
        _waterFlow.top = _headerView.height;
    }
    [UIView animateWithDuration:1 animations:^{
       
        _headerView.top = up ? - _headerView.height : 0;
        _waterFlow.top = up ? 0 : _headerView.height;
    }];
}

/**
 *  评论页面
 *
 *  @param sender
 */
- (void)clickToComment:(UIButton *)sender
{
    TTaiCommentViewController *commentList = [[TTaiCommentViewController alloc]init];
    commentList.tt_id = @"11";
    commentList.commentType = COMMENTTYPE_Product;
    commentList.aProduct = _aModel;
    [self.navigationController pushViewController:commentList animated:YES];
}

/**
 *  附近更多商场
 *
 *  @param btn
 */
- (void)clickToMoreMall:(UIButton *)btn
{
    
}

-(void)leftButtonTap:(UIButton *)sender
{
    if (self.isPresent) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)tapImage:(UITapGestureRecognizer *)tap
{
    int count = (int)image_urls.count;
    
    UIImageView *aImageView = (UIImageView *)tap.view;
    
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        // 替换为中等尺寸图片
        NSString *url = image_urls[i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url]; // 图片路径
        photo.srcImageView = aImageView; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

/*
 是否喜欢
 */
- (void)clickToLike:(UIButton *)sender
{
    
    if ([LTools isLogin:self]) {
        
        [LTools animationToBigger:heartButton duration:0.2 scacle:1.5];
        
        if (heartButton.selected) {
            
            [self networkForActionType:Action_like_no];
        }else
        {
            [self networkForActionType:Action_like_yes];
        }
    }
}

/*
 是否收藏
 */

- (void)clickToCollect:(UIButton *)sender
{
    if (sender.selected) {
        
        [self networkForActionType:Action_Collect_no];
    }else
    {
        [self networkForActionType:Action_Collect_yes];
    }
}


/*
 分享
 */

- (void)clickToShare:(UIButton *)sender
{
    NSString *productString = [NSString stringWithFormat:SHARE_PRODUCT_DETAIL,self.product_id];
    
    NSString *safeString = [LTools safeString:self.theModel.product_name];
    NSString *title = safeString.length > 0 ? safeString : @"衣加衣";
    
    [[LShareSheetView shareInstance] showShareContent:_aModel.product_name title:title shareUrl:productString shareImage:self.bigImageView.image targetViewController:self];
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
}

#pragma mark--联系搭配师

/**
 *  联系商家
 *
 *  @param sender
 */
- (IBAction)clickToContact:(id)sender {
    
    __weak typeof(self)weakSelf = self;
    
    [[LContactView shareInstance] show];
    
    [[LContactView shareInstance] setContactBlock:^ (CONTACTTYPE contactType,int extra){
        
        if (contactType == CONTACTTYPE_PHONE) {
            
            [weakSelf clickToPhone:nil];
            
        }else if (contactType == CONTACTTYPE_PRIVATECHAT){
            
            [weakSelf clickToPrivateChat:nil];
        }
        
    }];
}

/**
 *  私聊
 *
 *  @param sender
 */
- (void)clickToPhone:(UIButton *)sender
{
    NSString *phoneNum = _aModel.mall_info[@"mobile"];
    
    if (phoneNum.length > 0) {
        
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"拨号" message:phoneNum delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }else
    {
        //        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        //        [al show];
        
        [LTools showMBProgressWithText:@"抱歉!该商家暂未填写有效联系方式" addToView:self.view];
    }
}

//打电话
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *phoneNum = _aModel.mall_info[@"mobile"];
    
    //0取消    1确定
    if (buttonIndex == 1) {
        NSString *strPhone = [NSString stringWithFormat:@"tel://%@",phoneNum];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strPhone]];
    }
}

/**
 *  私聊
 *
 *  @param sender
 */
- (void)clickToPrivateChat:(UIButton *)sender
{
    BOOL rong_login = [LTools cacheBoolForKey:LOGIN_RONGCLOUD_STATE];
    
    //服务器登陆成功
    if ([LTools isLogin:self]) {
        
        //融云登陆成功
        if (rong_login) {
            
            NSString *useriId;
            NSString *userName;
            NSString *mall_type;
            NSString *brand_name;
            NSString *mall_name;
            YIYIChatViewController *contact = [[YIYIChatViewController alloc]init];
            
            
            if ([_aModel.mall_info isKindOfClass:[NSDictionary class]]) {
                
                useriId = _aModel.mall_info[@"uid"];
                userName = _aModel.mall_info[@"mall_name"];
                mall_type = _aModel.mall_info[@"mall_type"];
                if ([mall_type intValue] == 1) {//商场店
                    brand_name = _aModel.brand_info[@"brand_name"];//品牌名
                    mall_name = _aModel.mall_info[@"mall_name"];//商城名
                    NSString *aaa = [NSString stringWithFormat:@"%@.%@",brand_name,mall_name];
                    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:aaa];
                    NSInteger pinpaiNameLength = brand_name.length;
                    NSInteger storeNameLength = mall_name.length;
                    [title addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,pinpaiNameLength+1)];
                    [title addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17*GscreenRatio_320] range:NSMakeRange(0,pinpaiNameLength)];
                    [title addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(240, 173, 184) range:NSMakeRange(pinpaiNameLength+1, storeNameLength)];
                    [title addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13*GscreenRatio_320] range:NSMakeRange(pinpaiNameLength+1, storeNameLength)];
                    contact.GTitleLabel.textAlignment = NSTextAlignmentCenter;
                    contact.GTitleLabel.attributedText = title;
                }else{
                    userName = userName;
                    contact.GTitleLabel.text = userName;
                    contact.GTitleLabel.textColor = RGBCOLOR(251, 108, 157);
                }
                
            }
            
            contact.currentTarget = useriId;
            contact.portraitStyle = RCUserAvatarCycle;
            contact.enableSettings = NO;
            contact.conversationType = ConversationType_PRIVATE;
            
            contact.theModel = self.theModel;
            contact.isProductDetailVcPush = YES;
            
            
            [self.navigationController pushViewController:contact animated:YES];
        }else
        {
            NSLog(@"服务器登陆成功了,融云未登陆");
            
            
            AppDelegate * appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appdelegate loginToRongCloud];
            
        }
        
    }
}

#pragma mark--带你去买

/**
 *  跳转至地图
 *
 *  @param sender
 */
- (IBAction)clickToMap:(id)sender {
    
    GLeadBuyMapViewController *ll = [[GLeadBuyMapViewController alloc]init];
    ll.aModel = _aModel;
    
    ll.theType = LEADYOUTYPE_STORE;
    
    if ([LTools isDictinary:_aModel.mall_info]) {
        
        ll.storeName = _aModel.mall_info[@"mall_name"];
        ll.coordinate_store = CLLocationCoordinate2DMake([_aModel.mall_info[@"latitude"]floatValue], [_aModel.mall_info[@"longitude"]floatValue]);
    }
    
    [self presentViewController:ll animated:YES completion:nil];
}

/**
 *  跳转至地图
 *
 *  @param sender
 */
- (IBAction)clickToMapForCurrentLoacation:(id)sender {
    
    GLeadBuyMapViewController *ll = [[GLeadBuyMapViewController alloc]init];
    ll.aModel = _aModel;
    ll.theType = LEADYOUTYPE_STORE;
    
    ll.storeName = @"当前位置";
    ll.coordinate_store = CLLocationCoordinate2DMake(_latitude, _longtitude);
    
    [self presentViewController:ll animated:YES completion:nil];
}

- (IBAction)clickToStore:(id)sender {
    
    
    if (self.isChooseProductLink) {
        GAddTtaiImageLinkViewController *cc = self.navigationController.viewControllers[0];
        
        NSString *shopId = _aModel.product_shop_id;
        NSString *productName = _aModel.product_name;
        NSString *shopName = _aModel.mall_info[@"mall_name"];
        NSString *price = [NSString stringWithFormat:@"%@",_aModel.product_price];
        
        [cc setGmoveImvProductId:self.product_id shopid:shopId productName:productName shopName:shopName price:price type:@"单品"];
        [self.navigationController popToViewController:cc animated:YES];
        return;
    }
    
    //    int mall_type = [aModel.mall_info[@"mall_type"] intValue];
    int shop_type = [_aModel.shop_type intValue];
    NSString *storeId;
    NSString *storeName;
    
    if (shop_type == ShopType_pinpaiDian) {
        
        storeId = _aModel.product_shop_id;
        storeName = _aModel.product_brand_name;
        NSString *brandName = _aModel.product_brand_name;//品牌店需要brandName
        
        [MiddleTools pushToStoreDetailVcWithId:storeId shopType:shop_type storeName:storeName brandName:brandName fromViewController:self lastNavigationHidden:NO hiddenBottom:NO isTPlatPush:NO];
        
    }else if (shop_type == ShopType_jingpinDian || shop_type == ShopType_mall){
        
        storeId = _aModel.mall_info[@"mall_id"];
        storeName = _aModel.mall_info[@"mall_name"];
        
        [MiddleTools pushToStoreDetailVcWithId:storeId shopType:shop_type storeName:storeName brandName:@" " fromViewController:self lastNavigationHidden:NO hiddenBottom:NO isTPlatPush:NO];
    }
}

/*
 原图
 */
- (NSString *)originalImageForArr:(NSArray *)imagesArr
{
    if (imagesArr.count >= 1) {
        
        NSDictionary *imageDic = imagesArr[0];
        NSDictionary *originalImage = imageDic[@"original"];
        
        
        return originalImage[@"src"];
    }
    
    return @"";
}

- (NSString *)thumbImageForArr:(NSArray *)imagesArr
{
    if (imagesArr.count >= 1) {
        
        NSDictionary *imageDic = imagesArr[0];
        NSDictionary *originalImage = imageDic[@"540Middle"];
        
        
        return originalImage[@"src"];
    }
    
    return @"";
}

- (CGFloat)thumbImageHeightForArr:(NSArray *)imagesArr
{
    CGFloat aHeight = 0.f;
    CGFloat aWidth = 0.f;
    if (imagesArr.count >= 1) {
        
        NSDictionary *imageDic = imagesArr[0];
        NSDictionary *originalImage = imageDic[@"540Middle"];
        
        aHeight = [originalImage[@"height"] floatValue];
        aWidth = [originalImage[@"width"] floatValue];
    }
    
    return aHeight * (DEVICE_WIDTH / aWidth);
}

/**
 *  给view 赋值
 *
 *  @param aProductModel
 */
- (void)prepareViewWithModel:(ProductModel *)aProductModel
{
    
    //解析 原图
    NSArray *arr = aProductModel.images;
    NSMutableArray *temp_arr = [NSMutableArray arrayWithCapacity:arr.count];
    for (NSDictionary *aDic in arr) {
        
        NSDictionary *original = aDic[@"original"];
        NSString *src = original[@"src"];
        [temp_arr addObject:src];
    }
    image_urls = [NSArray arrayWithArray:temp_arr];
    
    _aModel = aProductModel;
    
    //赞 与 收藏 状态
    heartButton.selected = aProductModel.is_like == 1 ? YES : NO;
    collectButton.selected = aProductModel.is_favor ==  1 ? YES : NO;
    
    //创建详情相关view 并赋值
    
    [self createDetailViewsWithModel:aProductModel];
    
}

#pragma mark - 创建视图
/**
 *  创建详情显示view 除了底部品牌推荐 其他的作为header
 *
 *  @param aProductModel 单品详情model
 */

- (void)createDetailViewsWithModel:(ProductModel *)aProductModel
{
    //头部view
    _headerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    _headerView.backgroundColor = [UIColor whiteColor];
    _headerView.delegate = self;
    [self.view addSubview:_headerView];
    
    _waterFlow.hidden = NO;
    
    [self createBottomView];//底部
    
    //单品图片
    //图片高度
    CGFloat aHeight = [self thumbImageHeightForArr:aProductModel.images];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, aHeight)];
    [imageView l_setImageWithURL:[NSURL URLWithString:[self originalImageForArr:aProductModel.images]] placeholderImage:DEFAULT_YIJIAYI];
    [_headerView addSubview:imageView];
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, imageView.bottom, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [_headerView addSubview:line];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, imageView.bottom + 10, DEVICE_WIDTH - 20, 18) title:aProductModel.product_name font:15 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
    [_headerView addSubview:titleLabel];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    titleLabel.numberOfLines = 0;
    aHeight = [LTools heightForText:aProductModel.product_name width:titleLabel.width Boldfont:15];
    titleLabel.height = aHeight;
    
    //折后价格
    NSString *price_now = [NSString stringWithFormat:@"￥%.2f",[aProductModel.product_price floatValue]];
    CGFloat aWidth = [LTools widthForText:price_now font:13];
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLabel.left, titleLabel.bottom + 10, aWidth, 13) title:price_now font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR];
    [_headerView addSubview:priceLabel];
    
    //有折扣
    if (aProductModel.discount_num < 1) {

        //原价
        NSString *price_discount = [NSString stringWithFormat:@"￥%.2f",[aProductModel.original_price floatValue]];

        NSAttributedString *temp = [[NSAttributedString alloc]initWithString:price_discount];

        NSMutableAttributedString *priceAttString = [[NSMutableAttributedString alloc]initWithAttributedString:temp];

        //中间加横线
        NSRange range = NSMakeRange(0, price_discount.length);

        [priceAttString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:range];
        [priceAttString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"767676"] range:range];
        
        CGFloat aWidth = [LTools widthForText:price_discount font:10];
        UILabel *priceLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(priceLabel.right + 8, titleLabel.bottom + 10, aWidth, 13) title:price_discount font:10 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646464"]];
        [_headerView addSubview:priceLabel2];
        
        [priceLabel2 setAttributedText:priceAttString];
        
        //折扣
        
        NSString *discount = [NSString stringWithFormat:@"%.1f",_aModel.discount_num * 10];
        discount = [NSString stringWithFormat:@"%@折",[discount stringByRemoveTrailZero]];
        aWidth = [LTools widthForText:discount font:13];
        UILabel *dicountLabel = [[UILabel alloc]initWithFrame:CGRectMake(priceLabel2.right + 5, priceLabel2.top, aWidth + 8, 13) title:discount font:13 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
        [_headerView addSubview:dicountLabel];
        dicountLabel.backgroundColor = DEFAULT_TEXTCOLOR;
        [dicountLabel addCornerRadius:6.5];

    }
    
#pragma - mark 地址相关
    //地址信息
    UIImageView *addressIcon = [[UIImageView alloc]initWithFrame:CGRectMake(titleLabel.left, priceLabel.bottom + 10, 13, 13)];
    addressIcon.image = [UIImage imageNamed:@"danpinxq_dianpu"];
    [_headerView addSubview:addressIcon];
    
    NSString *address = [NSString stringWithFormat:@"%@ - %@",[LTools NSStringNotNull:aProductModel.product_brand_name],aProductModel.mall_info[@"mall_name"]];
    UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressIcon.right + 10, addressIcon.top, DEVICE_WIDTH - addressIcon.right - 5 - 20, addressIcon.height) title:address font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"67bcfd"]];
    [_headerView addSubview:addressLabel];
    
    [addressLabel addTaget:self action:@selector(clickToMap:) tag:0];
    
    //当前位置信息
    UIImageView *addressIcon_current = [[UIImageView alloc]initWithFrame:CGRectMake(titleLabel.left, addressIcon.bottom + 10, 13, 13)];
    addressIcon_current.image = [UIImage imageNamed:@"danpinxq_dizhi"];
    [_headerView addSubview:addressIcon_current];
    
    NSString *address_current = [NSString stringWithFormat:@"定位中..."];
    _addressLabel_current = [[UILabel alloc]initWithFrame:CGRectMake(addressIcon_current.right + 10, addressIcon_current.top, DEVICE_WIDTH - addressIcon.right - 5 - 20, addressIcon.height) title:address_current font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"67bcfd"]];
    [_headerView addSubview:_addressLabel_current];
    
    [_addressLabel_current addTaget:self action:@selector(clickToMapForCurrentLoacation:) tag:0];
    
    _addressLabel_current.text = _addressDetail;
    
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, _addressLabel_current.bottom + 5, DEVICE_WIDTH, 0.5)];
    line2.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [_headerView addSubview:line2];
    UIView *line3 = [[UIView alloc]initWithFrame:CGRectMake(0, line2.bottom + 55, DEVICE_WIDTH, 0.5)];
    line3.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [_headerView addSubview:line3];

#pragma - mark 评论相关
    //评论
    
    int commentCount = (int)_commentArray.count;
    NSMutableArray *viewsArray1 = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < commentCount; i++) {
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH - 105, 55)];
        view.backgroundColor = [UIColor whiteColor];
        [viewsArray1 addObject:view];
        
        TopicCommentsModel *amodel = _commentArray[i];
        NSString *content = [NSString stringWithFormat:@"%@:%@",amodel.user_name,amodel.repost_content];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 12.5, view.width - 20, 30) title:content font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"6d6d6d"]];
        [view addSubview:label];
        label.numberOfLines = 2;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    if (commentCount) {
        
        CycleScrollView1 * topScrollView1 = [[CycleScrollView1 alloc] initWithFrame:CGRectMake(0, line2.bottom, DEVICE_WIDTH - 105, 55) animationDuration:2];
        topScrollView1.isPageControlHidden = YES;
        topScrollView1.scrollView.showsHorizontalScrollIndicator = FALSE;
        [_headerView addSubview:topScrollView1];
        
        topScrollView1.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
            return viewsArray1[pageIndex];
        };
        
        NSInteger count1 = viewsArray1.count;
        topScrollView1.totalPagesCount = ^NSInteger(void){
            return count1;
        };
        
        //    __weak typeof (self)bself = self;
        topScrollView1.TapActionBlock = ^(NSInteger pageIndex){
            //        [bself cycleScrollDidClickedWithIndex:pageIndex];
        };

    }
    
    //点赞、评论
    
    UIButton *zanBtn = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 10 - 40,line2.bottom + 8, 40, 40) buttonType:UIButtonTypeCustom nornalImage:nil selectedImage:nil target:self action:@selector(clickToLike:)];
    [_headerView addSubview:zanBtn];
    [zanBtn addCornerRadius:20];
    [zanBtn setBorderWidth:.5 borderColor:DEFAULT_TEXTCOLOR];
    
    heartButton = [[UIButton alloc]initWithframe:CGRectMake(0, 5, 40, 20) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"Ttai_zan_normal"] selectedImage:[UIImage imageNamed:@"Ttai_zan_selected"] target:self action:nil];
    [zanBtn addSubview:heartButton];
    heartButton.userInteractionEnabled = NO;
    heartButton.selected = aProductModel.is_like == 1 ? YES : NO;
    
    NSString *zanString = [self zanNumStringForNum:aProductModel.product_like_num];
    _zanNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, heartButton.bottom, 40, 10) title:zanString font:10 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR];
    [zanBtn addSubview:_zanNumLabel];

    
    UIButton *commentBtn = [[UIButton alloc]initWithframe:CGRectMake(zanBtn.left - 14 - 40, zanBtn.top, 40, 40) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"Ttaixq_pinglun2"] selectedImage:[UIImage imageNamed:@"Ttaixq_pinglun2"] target:self action:@selector(clickToComment:)];
    [_headerView addSubview:commentBtn];
    NSString *commentString = [self zanNumStringForNum:NSStringFromInt(_commentCount)];
    _commentNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, 40, 10) title:commentString font:10 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR];
    [commentBtn addSubview:_commentNumLabel];
    
#pragma - mark 标签相关
    //标签
    NSArray *tags = aProductModel.tag;
    int count = (int)tags.count;
    CGFloat left = 10;
    for (int i = 0; i < count; i ++) {
        NSString *name = tags[i][@"tag_name"];
        CGFloat width = [LTools widthForText:name font:10];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(left, 7 + line3.bottom, width + 10, 15) title:name font:10 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR];
        [_headerView addSubview:label];
        [label addCornerRadius:7.5];
        [label setBorderWidth:0.5 borderColor:DEFAULT_TEXTCOLOR];
        left = label.right + 10;
        [label addTaget:self action:@selector(clickToTagList:) tag:100 + i];
    }
    
    UIView *line4 = [[UIView alloc]initWithFrame:CGRectMake(0, line3.bottom + 30, DEVICE_WIDTH, 0.5)];
    line4.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [_headerView addSubview:line4];

#pragma - mark 固定介绍图
    
    CGFloat top = line4.bottom;
    
    //有固定介绍图
    NSDictionary *official_pic = aProductModel.official_pic;
    if (official_pic && [official_pic isKindOfClass:[NSDictionary class]]) {
        
        //固定的图片
        CGFloat imageHeight = [official_pic[@"height"] floatValue];
        CGFloat imageWidth = [official_pic[@"width"] floatValue];
        NSString *imageUrl = official_pic[@"url"];
        aHeight = [LTools heightForImageHeight:imageHeight imageWidth:imageWidth showWidth:DEVICE_WIDTH];
        UIImageView *constImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, line4.bottom + 5, DEVICE_WIDTH, aHeight)];
        [_headerView addSubview:constImageView];
        [constImageView l_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:DEFAULT_YIJIAYI];
        UIView *line5 = [[UIView alloc]initWithFrame:CGRectMake(0, constImageView.bottom + 5, DEVICE_WIDTH, 0.5)];
        line5.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
        [_headerView addSubview:line5];
        
        top = line5.bottom;
    }
#pragma - mark 相似单品及所在商场
    //所在商场
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, top, DEVICE_WIDTH, 40) title:@"所在商场" font:14 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
    [_headerView addSubview:label];
    
    UIView *line6 = [[UIView alloc]initWithFrame:CGRectMake(0, label.bottom, DEVICE_WIDTH, 0.5)];
    line6.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [_headerView addSubview:line6];
    
    //只显示3个 大于3个显示更多 否则不显示
    
    NSArray *shopArray = aProductModel.sameStyleArray;
    count = (int)shopArray.count;
    
    int needCount = count > 3 ? 3 : count;
    
    top = line6.bottom;
    for (int i = 0; i < needCount; i ++) {
        
        ProductModel *model = aProductModel.sameStyleArray[i];
        NSString *name = [NSString stringWithFormat:@"%@-%@",model.brand_name,model.mall_name];
        aWidth = [LTools widthForText:name font:12];
        
        //店铺名
        UILabel *shopLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, top, aWidth, 30) title:name font:12 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
        [_headerView addSubview:shopLabel];
        
        //距离
        NSString *distanceStr;
        
        double dis = [model.distance doubleValue];
        
        if (dis > 1000) {
            
            distanceStr = [NSString stringWithFormat:@"%.1fkm",dis/1000];
        }else
        {
            distanceStr = [NSString stringWithFormat:@"%@m",model.distance];
        }
        aWidth = [LTools widthForText:distanceStr font:8];
        UILabel *disLabel = [[UILabel alloc]initWithFrame:CGRectMake(shopLabel.right + 5, shopLabel.top, aWidth, shopLabel.height) title:distanceStr font:8 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"8b8b8b"]];
        [_headerView addSubview:disLabel];
        
        //价格
        NSString *price = [NSString stringWithFormat:@"￥%.1f",[model.product_price floatValue]];
        aWidth = [LTools widthForText:price font:8];
        UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 10 - aWidth, shopLabel.top, aWidth, shopLabel.height) title:price font:8 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR];
        [_headerView addSubview:priceLabel];
        
        if (i < needCount - 1) {
            
            UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, shopLabel.bottom, DEVICE_WIDTH, 0.5f)];
            line.image = [UIImage imageNamed:@"danpinxq_line"];
            [_headerView addSubview:line];
        }
        
        top = priceLabel.bottom + 0.5;
    }
    
    //大于3个显示更多
    if (count > 3) {
        
        UIButton *more_btn = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 35 - 10,top + 6, 35, 16.5) buttonType:UIButtonTypeRoundedRect normalTitle:@"更多" selectedTitle:nil target:self action:@selector(clickToMoreMall:)];
        [_headerView addSubview:more_btn];
        [more_btn addCornerRadius:8];
        [more_btn setBorderWidth:.5 borderColor:DEFAULT_TEXTCOLOR];
        [more_btn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        [more_btn.titleLabel setFont:[UIFont systemFontOfSize:10]];
        
        top = more_btn.bottom + 6;
    }
    
#pragma - mark 官方活动
    
    UIView *line5 = [[UIView alloc]initWithFrame:CGRectMake(0, top, DEVICE_WIDTH, 0.5)];
    line5.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [_headerView addSubview:line5];
    
    NSDictionary *official_activity = aProductModel.official_activity;
    if (official_activity && [official_activity isKindOfClass:[NSDictionary class]]) {
        
        //固定的图片
        CGFloat imageHeight = [official_activity[@"height"] floatValue];
        CGFloat imageWidth = [official_activity[@"width"] floatValue];
        NSString *imageUrl = official_activity[@"url"];
        
        aHeight = [LTools heightForImageHeight:imageHeight imageWidth:imageWidth showWidth:DEVICE_WIDTH];
        UIImageView *constImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, line5.bottom, DEVICE_WIDTH, aHeight)];
        [_headerView addSubview:constImageView];
        [constImageView l_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:DEFAULT_YIJIAYI];
        [constImageView addTaget:self action:@selector(clickToActivity:) tag:0];
        
        top = constImageView.bottom;
    }
    
#pragma - mark 单品详情
    //商品详情
    //单品的其他图片
    NSArray *images = aProductModel.images;
    count = (int)images.count;
    if (count > 1) {
        
        aHeight = [LTools heightForImageHeight:42 imageWidth:375 showWidth:DEVICE_WIDTH];
        UIImageView *detailImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, top, DEVICE_WIDTH, aHeight)];
        detailImage.image = [UIImage imageNamed:@"danpinxq_xq"];
        [_headerView addSubview:detailImage];
        
        top = detailImage.bottom;
        
        //从第二张开始
        for (int i = 1; i < count; i ++) {
            
            NSDictionary *imageDic = images[i];
            NSDictionary *originalImage = imageDic[@"540Middle"];
            
            aHeight = [originalImage[@"height"] floatValue];
            aWidth = [originalImage[@"width"] floatValue];
            
            NSString *imageUrl = originalImage[@"src"];
            //图片高度
            aHeight = [LTools heightForImageHeight:aHeight imageWidth:aWidth showWidth:DEVICE_WIDTH];
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, top, DEVICE_WIDTH, aHeight)];
            [imageView l_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:DEFAULT_YIJIAYI];
            [_headerView addSubview:imageView];
            
            top = imageView.bottom + 5;
        }
    }
    
    //继续拖动查看 品牌推荐
    
    UILabel *moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, top + 10, DEVICE_WIDTH, 46) title:@"继续拖动,查看品牌推荐" font:10 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"8b8b8b"]];
    [_headerView addSubview:moreLabel];
    
    _headerView.contentSize = CGSizeMake(DEVICE_WIDTH, moreLabel.bottom);

}

/**
 *  判断内容是否为空,内容为空时label移除
 *
 *  @param text  内容
 *  @param label 对应label
 *
 *  @return
 */
- (BOOL)isValidateForText:(NSString *)text
                withLabel:(UILabel *)label
{
    if ([LTools isEmpty:text]) {
        
        [label removeFromSuperview];
        label = nil;
        return NO;
    }
    return YES;
}

/**
 *  底部工具栏
 */
- (void)createBottomView
{
    //导航按钮
    
    UIView *bottom = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 64 - 46, DEVICE_WIDTH, 46)];
    bottom.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [self.view addSubview:bottom];
    
    //电话
    UIButton *phoneBtn = [[UIButton alloc]initWithframe:CGRectMake(22, 5, 36, 36) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"danpinxq_dianhua2"] selectedImage:nil target:self action:@selector(clickToPhone:)];
    [bottom addSubview:phoneBtn];
    
    //聊天
    UIButton *chatBtn = [[UIButton alloc]initWithframe:CGRectMake(phoneBtn.right + 25, 5, 39, 36) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"danpinxq_lianximaijia2"] selectedImage:nil target:self action:@selector(clickToPrivateChat:)];
    [bottom addSubview:chatBtn];
    
    //聊天
    UIButton *shopBtn = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 70 - 20, 8, 70, 30) buttonType:UIButtonTypeCustom normalTitle:@"进入店铺" selectedTitle:nil target:self action:@selector(clickToStore:)];
    [shopBtn addCornerRadius:15];
    [shopBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [shopBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    shopBtn.backgroundColor = DEFAULT_TEXTCOLOR;
    [bottom addSubview:shopBtn];

}

- (void)createNavigationbarTools
{
    
    UIButton *rightView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 190, 44)];
    rightView.backgroundColor=[UIColor clearColor];
    
//    //是否赞
//    heartButton = [[UIButton alloc]initWithframe:CGRectMake(0, 0, 44, 44) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"productDetail_zan_normal"] selectedImage:[UIImage imageNamed:@"productDetail_zan_selected"] target:self action:@selector(clickToLike:)];
//    [heartButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    
    
    //收藏的
    
    collectButton = [[UIButton alloc]initWithframe:CGRectMake(74, 0, 44, 44) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"productDetail_collect_normal"] selectedImage:[UIImage imageNamed:@"productDetail_collect_selected"] target:self action:@selector(clickToCollect:)];
    collectButton.center = CGPointMake(rightView.width / 2.f, collectButton.center.y);
    [collectButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    
    
    //分享
    
    UIButton *shareButton = [[UIButton alloc] initWithframe:CGRectMake(rightView.width - 44, 0, 44, 44) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"product_share"] selectedImage:nil target:self action:@selector(clickToShare:)];
    [shareButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    
    [rightView addSubview:shareButton];
//    [rightView addSubview:heartButton];
    [rightView addSubview:collectButton];
    
    UIBarButtonItem *comment_item=[[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    self.navigationItem.rightBarButtonItem = comment_item;
}


#pragma mark - @protocol UIScrollViewDelegate<NSObject>

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 下拉到最底部时显示更多数据
    
    if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height + 60 + 30)))
    {
        [self moveToUp:YES];
    }
}

#pragma mark - WaterFlowDelegate

- (void)waterScrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y < -40)
    {
        _backLabel.text = @"释放,返回单品详情";
    }else
    {
        _backLabel.text = @"下拉,返回单品详情";
    }
    
}

- (void)waterScrollViewDidEndDragging:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y < -40)
    {
        [self moveToUp:NO];
    }
}

- (void)waterLoadNewData
{
    
}
- (void)waterLoadMoreData
{
    [self getRecommentProductList];
}

- (void)waterDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductModel *aMode = _waterFlow.dataArray[indexPath.row];
    //    ProductDetailController *detail = [[ProductDetailController alloc]init];
    //    detail.product_id = aMode.product_id;
    //    detail.hidesBottomBarWhenPushed = YES;
    //    TMPhotoQuiltViewCell *cell = (TMPhotoQuiltViewCell*)[waterFlow.quitView cellAtIndexPath:indexPath];
    //    detail.theHomeBuyVcModel = aMode;
    //    detail.theHomeBuyVcProductCell = cell;
    //
    //    [self.rootViewController.navigationController pushViewController:detail animated:YES];
    
    [MiddleTools pushToProductDetailWithId:aMode.product_id fromViewController:self lastNavigationHidden:NO hiddenBottom:YES];
    
}

- (CGFloat)waterHeightForCellIndexPath:(NSIndexPath *)indexPath
{
    CGFloat imageH = 0.f;
    ProductModel *aMode = _waterFlow.dataArray[indexPath.row];
    
    NSDictionary *images = (NSDictionary *)aMode.images;
    if (images && [images isKindOfClass:[NSDictionary class]]) {
        
        
        NSDictionary *middleImage = [images objectForKey:@"540Middle"];
        float image_width = [middleImage[@"width"]floatValue];
        float image_height = [middleImage[@"height"]floatValue];
        
        if (image_width == 0.0) {
            image_width = image_height;
        }
        float rate = image_height/image_width;
        
        imageH = (DEVICE_WIDTH - 6)/2.0*rate + 25;
        
    }

    
    return imageH;
}
- (CGFloat)waterViewNumberOfColumns
{
    
    return 2;
}

#pragma mark - TMQuiltViewDataSource

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return [_waterFlow.dataArray count];
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    TMPhotoQuiltViewCell *cell = (TMPhotoQuiltViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"];
    if (!cell) {
        cell = [[TMPhotoQuiltViewCell alloc] initWithReuseIdentifier:@"PhotoCell"];
    }
    
    cell.layer.cornerRadius = 3.f;
    
    cell.cellStyle = CELLSTYLE_BrandRecommendList;
    
    ProductModel *aMode = _waterFlow.dataArray[indexPath.row];
    [cell setCellWithModel222:aMode];
    
    cell.likeBackBtn.tag = 100 + indexPath.row;
//    [cell.likeBackBtn addTarget:self action:@selector(clickToZan:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


@end
