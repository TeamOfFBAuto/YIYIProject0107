//
//  GMyWalletViewController.m
//  YiYiProject
//
//  Created by gaomeng on 15/6/29.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GMyWalletViewController.h"
#import "GMyJianquanViewController.h"
#import "CouponModel.h"

@interface GMyWalletViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_titleArray;
    UITableView *_tableView;
    CGRect _jiangquanCGRECT;
    CGFloat _cellHeight_c;//抽奖券cell高度
    CGFloat _cellHeight_y;//优惠券cell高度
    
    int _isOpen[20];
    
    int _count;//网络请求完成个数
    
    NSArray *_jiangquanArray;//奖券数组
    NSArray *_youhuiquanArray;//优惠券数组
    NSArray *_disable_use_Array;//不可用的优惠券
    
    
}
@end



@implementation GMyWalletViewController

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
    [self removeObserver:self forKeyPath:@"_count"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"我的钱包";
    
    for (int i=0; i<20; i++) {
        _isOpen[i]=0;
    }
    _isOpen[2]=1;
    
    _titleArray = @[@"积分",@"奖券",@"优惠券"];
    
    _cellHeight_c = 180.0/750*DEVICE_WIDTH + (15.0/750*DEVICE_WIDTH)*2;
    _jiangquanCGRECT = CGRectMake(120.0/750*DEVICE_WIDTH, 15.0/750*DEVICE_WIDTH, 510.0/750*DEVICE_WIDTH, 180.0/750*DEVICE_WIDTH);
    
    _cellHeight_y = 140.0/750*DEVICE_WIDTH;
    
    
    
//    _cellHeight = 137;
//    _jiangquanCGRECT = CGRectMake(15, 10, 325, 117);
    
//    NSLog(@"%f",_cellHeight);
//    NSLog(@"x = %f",30.0/750*DEVICE_WIDTH);
//    NSLog(@"y = %f",20.0/750*DEVICE_WIDTH);
//    NSLog(@"w = %f",650.0/750*DEVICE_WIDTH);
//    NSLog(@"h = %f",650.0/750*DEVICE_WIDTH*234/650);
    [self prepareNetData];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - MyMethod
-(void)prepareNetData{
   
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    [self addObserver:self forKeyPath:@"_count" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self getJiangquan];
    
    [self getYouhuiquan];
    
    
}


-(void)getJiangquan{
    NSString *url = [NSString stringWithFormat:@"%@&authcode=%@",MYJIANGQUAN_LIST,[GMAPI getAuthkey]];
    
    
    NSLog(@"奖券url %@",url);
    
    LTools *ll = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [ll requestCompletion:^(NSDictionary *result, NSError *erro) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            _jiangquanArray = [result arrayValueForKey:@"list"];
            if (_jiangquanArray.count == 0) {
                _isOpen[1] = 0;
            }
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
    } failBlock:^(NSDictionary *result, NSError *erro) {
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
    }];
}

-(void)getYouhuiquan{
    NSString *url = [NSString stringWithFormat:@"%@&authcode=%@",MYYOUHUIQUAN_LIST,[GMAPI getAuthkey]];
    
    NSLog(@"优惠券 url%@",url);
    
    LTools *ll = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    
    
    
    [ll requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSArray *tmp = [result arrayValueForKey:@"coupon_list"];
        NSMutableArray *m_tmp = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *m_tmp_dis = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in tmp) {
            CouponModel *model = [[CouponModel alloc]initWithDictionary:dic];
            if (model.enable_use == 1) {//可用
                [m_tmp addObject:model];
            }else if (model.enable_use == 0){//不可用
                [m_tmp_dis addObject:model];
            }
            
            
            
        }
        _youhuiquanArray = (NSArray*)m_tmp;
        _disable_use_Array = (NSArray *)m_tmp_dis;

        if (_youhuiquanArray.count == 0) {
            _isOpen[2] = 0;
        }
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
    } failBlock:^(NSDictionary *result, NSError *erro) {
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
    }];
    
    
}





/**
 *  监控 单品详情 和 相似单品都请求完再显示 监控tableview的contentSize
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    NSNumber *num = [change objectForKey:@"new"];
    if ([num intValue] == 2) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [self creatMyTab];
    }
}



-(void)creatMyTab{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-64) style:UITableViewStyleGrouped];
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

-(void)loadJiangquanCustomCellWithIndex:(NSIndexPath *)indexPath tableViewCell:(UITableViewCell*)cell{
    UIImageView *imv = [[UIImageView alloc]initWithFrame:_jiangquanCGRECT];
    [imv setImage:[UIImage imageNamed:@"mywallet_01.png"]];
    [cell.contentView addSubview:imv];
    
    //箭头
    UIImageView *jt = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15, _cellHeight_c*0.5-6, 7, 12)];
    [jt setImage:[UIImage imageNamed:@"my_jiantou.png"]];
    //    jt.backgroundColor = [UIColor orangeColor];
    [cell.contentView addSubview:jt];
    
    UILabel *tishiLabel = [[UILabel alloc]initWithFrame:CGRectMake(35.0*imv.frame.size.width/650, 30.0/234*imv.frame.size.height+168.0/234*imv.frame.size.height *0.1, 480.0/650*imv.frame.size.width, 168.0/234*imv.frame.size.height *0.3)];
    
    //提示
    NSDictionary *dataDic = _jiangquanArray[indexPath.row];
    NSString *prize_tips = [dataDic stringValueForKey:@"prize_tips"];
    //奖项
    NSDictionary *category_info = [dataDic dictionaryValueForKey:@"category_info"];
    NSString *category_name = [category_info stringValueForKey:@"category_name"];
    
    
    tishiLabel.text = prize_tips;
    tishiLabel.font = [UIFont systemFontOfSize:14.0];
    tishiLabel.textColor = RGBCOLOR(249, 148, 151);
    tishiLabel.textAlignment = NSTextAlignmentCenter;
    [imv addSubview:tishiLabel];
    //    tishiLabel.backgroundColor = [UIColor orangeColor];
    
    UILabel *jiangxiangLabel = [[UILabel alloc]initWithFrame:CGRectMake(tishiLabel.frame.origin.x, CGRectGetMaxY(tishiLabel.frame), tishiLabel.frame.size.width, 168.0/234*imv.frame.size.height *0.40)];
    jiangxiangLabel.font = [UIFont systemFontOfSize:20];
    jiangxiangLabel.textColor = [UIColor whiteColor];
    
    UILabel *youxiaoqiLabel = [[UILabel alloc]initWithFrame:CGRectMake(jiangxiangLabel.frame.origin.x, CGRectGetMaxY(jiangxiangLabel.frame), jiangxiangLabel.frame.size.width, imv.frame.size.height *0.2)];
    youxiaoqiLabel.textAlignment = NSTextAlignmentCenter;
    youxiaoqiLabel.font = [UIFont systemFontOfSize:10];
    youxiaoqiLabel.textColor = [UIColor whiteColor];
    [imv addSubview:youxiaoqiLabel];
    
    
    //兑奖日期
    NSString *startTimeStr = dataDic[@"prize_info"][@"start_time"];
    NSString *endTimeStr = dataDic[@"prize_info"][@"end_time"];
    youxiaoqiLabel.textColor = [UIColor whiteColor];
    youxiaoqiLabel.text = [NSString stringWithFormat:@"有效期:%@-%@",[GMAPI timechangeAll3:startTimeStr],[GMAPI timechangeAll3:endTimeStr]];
    
    
    BOOL isGuoqi = [GMAPI isGuoqi:endTimeStr];
    
    if (isGuoqi) {//已过期
        jiangxiangLabel.text = category_name;
        
        [imv setImage:[UIImage imageNamed:@"choujiangquan_g.png"]];
        
        jiangxiangLabel.textColor = [UIColor whiteColor];
        tishiLabel.textColor = [UIColor whiteColor];
        
        UIImageView *aa = [[UIImageView alloc]initWithFrame:CGRectMake(imv.frame.size.width*0.5-imv.frame.size.height*0.5, 0, imv.frame.size.height, imv.frame.size.height)];
        [aa setImage:[UIImage imageNamed:@"jiangquan_yiguoqi.png"]];
        [imv addSubview:aa];
    }else{//未过期
        if ([[dataDic stringValueForKey:@"is_accepted"]intValue] == 0) {//未兑奖
            jiangxiangLabel.text = category_name;
        }else if ([[dataDic stringValueForKey:@"is_accepted"]intValue] == 1){//已兑奖
            jiangxiangLabel.text = category_name;
            
            [imv setImage:[UIImage imageNamed:@"choujiangquan_g.png"]];
            
            jiangxiangLabel.textColor = [UIColor whiteColor];
            tishiLabel.textColor = [UIColor whiteColor];
            
            
            UIImageView *aa = [[UIImageView alloc]initWithFrame:CGRectMake(imv.frame.size.width*0.5-imv.frame.size.height*0.5, 0, imv.frame.size.height, imv.frame.size.height)];
            [aa setImage:[UIImage imageNamed:@"jiangquan_yiduijiang.png"]];
            [imv addSubview:aa];
            
        }
    }
    
    
    
    
    
    
    
    
    
    jiangxiangLabel.textAlignment = NSTextAlignmentCenter;
    [imv addSubview:jiangxiangLabel];
}

-(void)loadYouhuiquanCustomCell:(NSIndexPath*)indexPath tableViewCell:(UITableViewCell*)cell{
    
    //数据model
    CouponModel *aModel = _youhuiquanArray[indexPath.row];
    
    //logo图
    UIImageView *pinpaiLogoImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, [LTools fitWidth:50], [LTools fitWidth:50])];
    [pinpaiLogoImv l_setImageWithURL:[NSURL URLWithString:aModel.brand_logo] placeholderImage:DEFAULT_YIJIAYI];
    pinpaiLogoImv.layer.borderWidth = 0.5;
    pinpaiLogoImv.layer.borderColor = [RGBCOLOR(220, 221, 223)CGColor];
    [cell.contentView addSubview:pinpaiLogoImv];
    
    
    
    
    
    
    
    CGFloat aWidth = 0;
    CGFloat aHeight = 0;
    aWidth = [LTools fitWidth:100];
    
    UIImage *aImage = [LTools imageForCoupeColorId:aModel.color];
    UIButton *btn = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 10 - aWidth, [LTools fitHeight:17], aWidth, [LTools fitHeight:35]) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil nornalImage:aImage selectedImage:nil target:self action:@selector(clickToCoupe)];
    [cell.contentView addSubview:btn];
    
    int type = [aModel.type intValue];
    
    NSString *title_minus;
    NSString *title_full;
    //满减
    if (type == 1) {
        
        title_minus = [NSString stringWithFormat:@"￥%@",aModel.minus_money];
        title_full = [NSString stringWithFormat:@"满%@即可使用",aModel.full_money];
    }
    //折扣
    else if (type == 2){
        
        NSString *discount = [NSString stringWithFormat:@"%.1f",[aModel.discount_num floatValue] * 10];
        discount = [NSString stringWithFormat:@"%@",[discount stringByRemoveTrailZero]];
        title_minus = @"优惠券";
        title_full = [NSString stringWithFormat:@"本店享%@折优惠",discount];
        
    }else if (type == 3){
        title_minus = [NSString stringWithFormat:@"￥%@",aModel.newer_money];
        title_full = [NSString stringWithFormat:@"新人首单优惠"];
    }
    
    aHeight = btn.height / 2.f - 5;
    UILabel *minusLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, btn.width - 10, aHeight) title:title_minus font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [btn addSubview:minusLabel];
    minusLabel.font = [UIFont boldSystemFontOfSize:8];
    UILabel *fullLabel = [[UILabel alloc]initWithFrame:CGRectMake(minusLabel.left, minusLabel.bottom, minusLabel.width, aHeight) title:title_full font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [btn addSubview:fullLabel];
    
    
    //店铺名
    UILabel *shopNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(pinpaiLogoImv.frame)+5, pinpaiLogoImv.frame.origin.y, DEVICE_WIDTH - 10 - aWidth - 5 - CGRectGetMaxX(pinpaiLogoImv.frame)-5, pinpaiLogoImv.frame.size.height *0.5)];
    shopNameLabel.font = [UIFont systemFontOfSize:shopNameLabel.frame.size.height*0.5];
    
    
    
    if ([LTools isEmpty:aModel.brand_name] || [LTools isEmpty:aModel.malll_name]) {
        shopNameLabel.text = @" ";
    }else{
        shopNameLabel.text = [NSString stringWithFormat:@"%@-%@",aModel.brand_name,aModel.malll_name];
    }
    
    
    if (type == 3){
        shopNameLabel.text = [NSString stringWithFormat:@"新人首单优惠"];
    }
    
    [cell.contentView addSubview:shopNameLabel];
    
    //使用期限
    UILabel *useTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(shopNameLabel.frame.origin.x, CGRectGetMaxY(shopNameLabel.frame), shopNameLabel.frame.size.width, shopNameLabel.frame.size.height)];
    useTimeLabel.font = shopNameLabel.font;
    NSString *t1 = [GMAPI timechangeAll3:aModel.use_start_time];
    NSString *t2 = [GMAPI timechangeAll3:aModel.use_end_time];
    useTimeLabel.text = [NSString stringWithFormat:@"使用期限:%@-%@",t1,t2];
    [cell.contentView addSubview:useTimeLabel];
    
    
    
    
    
    
}

-(void)clickToCoupe{
    NSLog(@"%s",__FUNCTION__);
}


#pragma mark - UITableViewDelegate && UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger aa = 0;
    if (section == 0) {
        aa = 0;
    }else if(section == 1){
        aa = _jiangquanArray.count;
        if (!_isOpen[section]) {
            aa = 0;
        }
    }else if (section == 2){
        aa = _youhuiquanArray.count;
        if (!_isOpen[section]) {
            aa = 0;
        }
    }
    return aa;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat cellHeight = 0;
    
    if (indexPath.section == 1) {//抽奖券
        cellHeight = _cellHeight_c;
    }else if (indexPath.section == 2){//优惠券
        cellHeight = _cellHeight_y;
    }
    
    return cellHeight;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 1) {//奖券
        [self loadJiangquanCustomCellWithIndex:indexPath tableViewCell:cell];
    }else if (indexPath.section == 2){//优惠券
        [self loadYouhuiquanCustomCell:indexPath tableViewCell:cell];
    }
    
    
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {//奖券
        NSDictionary *dataDic = _jiangquanArray[indexPath.row];
        NSDictionary *category_info = [dataDic dictionaryValueForKey:@"category_info"];
        NSString *prize_id = [category_info stringValueForKey:@"prize_id"];
        
        GMyJianquanViewController *cc = [[GMyJianquanViewController alloc]init];
        cc.jiangQuanId = prize_id;
        [self.navigationController pushViewController:cc animated:YES];
        
    }else if (indexPath.section == 2){//优惠券
        
    }
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 0.01;
    if (section == 2 && _disable_use_Array.count>0) {
       height = _disable_use_Array.count *_cellHeight_y +35;
    }
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.1)];
    
    
    
    if (section == 2 && _disable_use_Array.count>0 && _isOpen[section]) {//有不可用的优惠券
        
        for (int i = 0; i<_disable_use_Array.count; i++) {
            
            UILabel *ttlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 35)];
            ttlabel.backgroundColor = RGBCOLOR(239, 239, 244);
            ttlabel.text = @"已失效的优惠券";
            ttlabel.textColor = RGBCOLOR(105, 106, 107);
            ttlabel.textAlignment = NSTextAlignmentCenter;
            ttlabel.font = [UIFont systemFontOfSize:14];
            [view addSubview:ttlabel];
            
            CouponModel *aModel = _disable_use_Array[i];
            
            
            UIView *view_one = [[UIView alloc]initWithFrame:CGRectMake(0, 35+i*_cellHeight_y, DEVICE_WIDTH, _cellHeight_y)];
            [view addSubview:view_one];
            
            
            //logo图
            UIImageView *pinpaiLogoImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, [LTools fitWidth:50], [LTools fitWidth:50])];
            [pinpaiLogoImv l_setImageWithURL:[NSURL URLWithString:aModel.brand_logo] placeholderImage:DEFAULT_YIJIAYI];
            pinpaiLogoImv.layer.borderWidth = 0.5;
            pinpaiLogoImv.layer.borderColor = [RGBCOLOR(220, 221, 223)CGColor];
            [view_one addSubview:pinpaiLogoImv];
            
            
            
            CGFloat aWidth = 0;
            CGFloat aHeight = 0;
            aWidth = [LTools fitWidth:100];
            
            UIButton *btn = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 10 - aWidth, [LTools fitHeight:17], aWidth, [LTools fitHeight:35]) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil nornalImage:[UIImage imageNamed:@"youhuiquan_g.png"] selectedImage:nil target:self action:@selector(clickToCoupe)];
            [view_one addSubview:btn];
            
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(btn.frame.size.width*0.5-btn.frame.size.height*0.5, 0, btn.frame.size.height, btn.frame.size.height)];
            if (aModel.disable_use_reason == 1) {//已经使用过
                [imv setImage:[UIImage imageNamed:@"youhuiquan_yishiyong.png"]];
            }else if (aModel.disable_use_reason == 2){//过期
                [imv setImage:[UIImage imageNamed:@"youhuiquan_yiguoqi.png"]];
            }
            [btn addSubview:imv];
            
            
            int type = [aModel.type intValue];
            
            NSString *title_minus;
            NSString *title_full;
            //满减
            if (type == 1) {
                
                title_minus = [NSString stringWithFormat:@"￥%@",aModel.minus_money];
                title_full = [NSString stringWithFormat:@"满%@即可使用",aModel.full_money];
            }
            //折扣
            else if (type == 2){
                
                NSString *discount = [NSString stringWithFormat:@"%.1f",[aModel.discount_num floatValue] * 10];
                discount = [NSString stringWithFormat:@"%@",[discount stringByRemoveTrailZero]];
                title_minus = @"优惠券";
                title_full = [NSString stringWithFormat:@"本店享%@折优惠",discount];
                
            }else if (type == 3){
                title_minus = [NSString stringWithFormat:@"￥%@",aModel.newer_money];
                title_full = [NSString stringWithFormat:@"新人首单优惠"];
            }
            
            aHeight = btn.height / 2.f - 5;
            UILabel *minusLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, btn.width - 10, aHeight) title:title_minus font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
            [btn addSubview:minusLabel];
            minusLabel.font = [UIFont boldSystemFontOfSize:8];
            UILabel *fullLabel = [[UILabel alloc]initWithFrame:CGRectMake(minusLabel.left, minusLabel.bottom, minusLabel.width, aHeight) title:title_full font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
            [btn addSubview:fullLabel];
            
            
            //店铺名
            UILabel *shopNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(pinpaiLogoImv.frame)+5, pinpaiLogoImv.frame.origin.y, DEVICE_WIDTH - 10 - aWidth - 5 - CGRectGetMaxX(pinpaiLogoImv.frame)-5, pinpaiLogoImv.frame.size.height *0.5)];
            shopNameLabel.font = [UIFont systemFontOfSize:shopNameLabel.frame.size.height*0.5];
            if ([LTools isEmpty:aModel.brand_name] || [LTools isEmpty:aModel.malll_name]) {
                shopNameLabel.text = @" ";
            }else{
                shopNameLabel.text = [NSString stringWithFormat:@"%@-%@",aModel.brand_name,aModel.malll_name];
            }
            
            if (type == 3){
                shopNameLabel.text = [NSString stringWithFormat:@"新人首单优惠"];
            }
            
            
            [view_one addSubview:shopNameLabel];
            
            //使用期限
            UILabel *useTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(shopNameLabel.frame.origin.x, CGRectGetMaxY(shopNameLabel.frame), shopNameLabel.frame.size.width, shopNameLabel.frame.size.height)];
            useTimeLabel.font = shopNameLabel.font;
            NSString *t1 = [GMAPI timechangeAll3:aModel.use_start_time];
            NSString *t2 = [GMAPI timechangeAll3:aModel.use_end_time];
            useTimeLabel.text = [NSString stringWithFormat:@"使用期限:%@-%@",t1,t2];
            [view_one addSubview:useTimeLabel];
            
            UIView *fline = [[UIView alloc]initWithFrame:CGRectMake(14, _cellHeight_y - 0.5, DEVICE_WIDTH-14, 0.5)];
            if (i == _disable_use_Array.count-1) {
                [fline setFrame:CGRectMake(0, _cellHeight_y-0.5, DEVICE_WIDTH, 0.5)];
            }
            fline.backgroundColor = RGBCOLOR(200, 199, 204);
            [view_one addSubview:fline];
        }
        
        [view setHeight:(_disable_use_Array.count *_cellHeight_y +35)];
        view.backgroundColor = [UIColor whiteColor];
        
    }
    
    return view;
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 45)];
    view.backgroundColor = [UIColor whiteColor];
    view.userInteractionEnabled = YES;
    view.tag = section +10;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ggShouFang:)];
    [view addGestureRecognizer:tap];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 70, 15)];
    titleLabel.text = _titleArray[section];
    [view addSubview:titleLabel];
    
    UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame), 15, DEVICE_WIDTH-10-70-30, 15)];
    if (section == 0) {
        [numLabel setFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame), 15, DEVICE_WIDTH-10-70-10, 15)];
    }
    numLabel.textAlignment = NSTextAlignmentRight;
    [view addSubview:numLabel];
    
    if (section == 0) {
        numLabel.text = [NSString stringWithFormat:@"%@分",self.jifen];
    }else if (section == 1){
        numLabel.text = [NSString stringWithFormat:@"%lu张",(unsigned long)_jiangquanArray.count];
    }else if (section == 2){
        numLabel.text = [NSString stringWithFormat:@"%lu张",(unsigned long)_youhuiquanArray.count];
    }
    
    
    if (numLabel.text.length>0) {
        NSMutableAttributedString *tt = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",numLabel.text]];
        [tt addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(253, 106, 157) range:NSMakeRange(0,numLabel.text.length-1)];
        [tt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0,numLabel.text.length-1)];
        [tt addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(numLabel.text.length-1, 1)];
        [tt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(numLabel.text.length-1, 1)];
        numLabel.attributedText = tt;
    }
    if (section == 1 || section == 2) {
        UIView *line =[[UIView alloc]initWithFrame:CGRectMake(0, 44.5, DEVICE_WIDTH, 0.5)];
        line.backgroundColor = RGBCOLOR(220, 221, 223);
        [view addSubview:line];
        
        //箭头
        UIButton *jiantou = [UIButton buttonWithType:UIButtonTypeCustom];
        [jiantou setFrame:CGRectMake(DEVICE_WIDTH - 30, 7, 30, 30)];
        jiantou.userInteractionEnabled = NO;
        [view addSubview:jiantou];
        
        if ( !_isOpen[view.tag-10]) {
            [jiantou setImage:[UIImage imageNamed:@"buy_jiantou_d.png"] forState:UIControlStateNormal];
        }else{
            [jiantou setImage:[UIImage imageNamed:@"buy_jiantou_u.png"] forState:UIControlStateNormal];
        }
        
        
    }else if (section == 0){
        UIView *fline = [[UIView alloc]initWithFrame:CGRectMake(0, view.frame.size.height-0.5,DEVICE_WIDTH , 0.5)];
        fline.backgroundColor = RGBCOLOR(200, 199, 204);
        [view addSubview:fline];
    }
    
    
    return view;
    
}




-(void)ggShouFang:(UIGestureRecognizer*)ges{
    
    
    
    _isOpen[ges.view.tag-10]=!_isOpen[ges.view.tag-10];
    
//    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:ges.view.tag-10];
//    [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationTop];
    [_tableView reloadData];
    
    
    
}










@end
