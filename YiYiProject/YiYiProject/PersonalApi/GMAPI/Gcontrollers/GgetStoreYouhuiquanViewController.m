//
//  GgetStoreYouhuiquanViewController.m
//  YiYiProject
//
//  Created by gaomeng on 15/9/13.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GgetStoreYouhuiquanViewController.h"
#import "RefreshTableView.h"
#import "GTtaiRelationStoreModel.h"
#import "GBtn.h"
#import "GTtaiDetailViewController.h"
#import "GwebViewController.h"
#import "MessageDetailController.h"
#import "ButtonProperty.h"

@interface GgetStoreYouhuiquanViewController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_tab;
    
    int _isOpen[200];//缩放tablview
    
    LTools *tool_detail;
}
@end

@implementation GgetStoreYouhuiquanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.myTitle = @"店铺优惠券";
    
    
    for (int i=0; i<200; i++) {
        _isOpen[i]=1;
    }
    
    
    [self creatTableView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)creatTableView{
    //header上的可缩放tableview
    _tab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-64)];
    _tab.refreshDelegate = self;
    _tab.dataSource = self;
    [_tab showRefreshHeader:YES];
    [self.view addSubview:_tab];
}


- (void)loadNewDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}


- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%s",__FUNCTION__);
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath{
    return [LTools fitHeight:50];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return _tab.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = 0;
    GTtaiRelationStoreModel *amodel = _tab.dataArray[section];
    count = amodel.coupon_model_array.count;
    
    if (_isOpen[section] == 0) {
        count = 0;
    }else{
        
    }
    
    
    return count;
}



//请求T台关联的商场
-(void)prepareNetData{
    
    NSString *longitude = [self.locationDic stringValueForKey:@"long"];
    NSString *latitude = [self.locationDic stringValueForKey:@"lat"];
    
    NSString *url = [NSString stringWithFormat:@"%@&authcode=%@&longitude=%@&latitude=%@&tt_id=%@&page=%d&per_page=%d",GETYOUHUIQUAN_RELATIONSHOP,[GMAPI getAuthkey],longitude,latitude,self.tPlat_id,_tab.pageNum,L_PAGE_SIZE];
    

    
    tool_detail = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    
    [tool_detail requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        
        
        NSLog(@"result %@",result);
        NSArray *list = result[@"list"];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:list.count];
        
        for (NSDictionary *dic in list) {
            GTtaiRelationStoreModel *amodel = [[GTtaiRelationStoreModel alloc]initWithDictionary:dic];
            amodel.isChoose = [NSMutableArray arrayWithCapacity:1];
            NSArray *coupon_list = amodel.coupon_list;
            amodel.coupon_model_array = [NSMutableArray arrayWithCapacity:1];
            if (coupon_list.count>0) {
                for (int i = 0; i<coupon_list.count; i++) {
                    NSDictionary *dic = coupon_list[i];
                    
                    CouponModel *mm = [[CouponModel alloc]initWithDictionary:dic];
                    
                    [amodel.coupon_model_array addObject:mm];
                    
                    NSLog(@"%@",amodel.coupon_model_array);
                    
                }
            }
            [temp addObject:amodel];
        }
        
        [_tab reloadData:temp pageSize:L_PAGE_SIZE];
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failBlock == %@",failDic[RESULT_INFO]);
        
        [_tab loadFail];
        
    }];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    GTtaiRelationStoreModel *amodel = _tab.dataArray[indexPath.section];
    
    if (amodel.coupon_model_array.count>0) {
        CouponModel *md = amodel.coupon_model_array[indexPath.row];//优惠券dic
        
        if (md) {
            
            UIView *aaa = [self coupeViewWithCoupeModel:md frame:CGRectMake(0, 0, DEVICE_WIDTH, [LTools fitHeight:50])];
            [cell.contentView addSubview:aaa];
            
            
            
        }
        
    }
    
    

    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    return cell;
}


- (UIView *)coupeViewWithCoupeModel:(CouponModel *)aModel
                              frame:(CGRect)frame
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    
    UIImage *aImage = [LTools imageForCoupeColorId:aModel.color];
    
    //券
    UIButton *btn = [[UIButton alloc]initWithframe:CGRectMake([LTools fitWidth:10], [LTools fitHeight:8] , [LTools fitWidth:88], [LTools fitHeight:35]) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil nornalImage:aImage selectedImage:nil target:self action:nil];
    [view addSubview:btn];
    
    
    int type = [aModel.type intValue];
    
    NSString *title_minus;
    NSString *title_full;
    NSString *title;
    //满减
    if (type == 1) {
        
        title_minus = [NSString stringWithFormat:@"￥%@",aModel.minus_money];
        title_full = [NSString stringWithFormat:@"满%@即可使用",aModel.full_money];
        title = [NSString stringWithFormat:@"满%@减%@",aModel.full_money,aModel.minus_money];
    }
    //折扣
    else if (type == 2){
        
        NSString *discount = [NSString stringWithFormat:@"%.1f",[aModel.discount_num floatValue] * 10];
        discount = [NSString stringWithFormat:@"%@",[discount stringByRemoveTrailZero]];
        title_minus = @"优惠券";
        title_full = [NSString stringWithFormat:@"本店享%@折优惠",discount];
        title = [NSString stringWithFormat:@"%@折",discount];
    }
    
    CGFloat aHeight = btn.height / 2.f - 5;
    UILabel *minusLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, btn.width - 10, aHeight) title:title_minus font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [btn addSubview:minusLabel];
    UILabel *fullLabel = [[UILabel alloc]initWithFrame:CGRectMake(minusLabel.left, minusLabel.bottom, minusLabel.width, aHeight) title:title_full font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [btn addSubview:fullLabel];
    
    //优惠标题
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(btn.right + 5, btn.top, [LTools fitWidth:140], btn.height / 2.f) title:title font:8 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"5c5c5c"]];
    [view addSubview:label];
    label.font = [UIFont boldSystemFontOfSize:8];
    
    NSString *title2 = [NSString stringWithFormat:@"有效期:%@-%@",[LTools timeString:aModel.use_start_time withFormat:@"yyyy.MM.dd"],[LTools timeString:aModel.use_end_time withFormat:@"yyyy.MM.dd"]];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(btn.right + 5, label.bottom, [LTools fitWidth:140], btn.height / 2.f) title:title2 font:8 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"ababab"]];
    [view addSubview:label2];
    
    //点击获取优惠劵
    CGFloat aWidth = [LTools fitWidth:55];
    
    ButtonProperty *btn_get = [ButtonProperty buttonWithType:UIButtonTypeCustom];
    btn_get.frame = CGRectMake(view.width - [LTools fitWidth:10] - aWidth, [LTools fitHeight:16], aWidth, [LTools fitHeight:20]);
    [btn_get setImage:[UIImage imageNamed:@"youhui_lingqu"] forState:UIControlStateNormal];
    [btn_get setImage:[UIImage imageNamed:@"youhui_yilingqu"] forState:UIControlStateSelected];
    [btn_get addTarget:self action:@selector(clickToGetCoupe:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn_get];
    btn_get.object = aModel;
    
    int isGet = [aModel.enable_receive intValue];
    btn_get.selected = !isGet;
    
    
    return view;
}



/**
 *  获取优惠券
 *
 *  @param sender
 */
- (void)clickToGetCoupe:(ButtonProperty *)sender
{
    CouponModel *model = sender.object;
    [self netWorkForCouponModel:model button:sender];
}


/**
 *  领取优惠劵
 *
 *  @param aModel 优惠劵model
 *  @param sender
 */
- (void)netWorkForCouponModel:(CouponModel *)aModel
                       button:(UIButton *)sender
{
    //    __weak typeof(self)weakSelf = self;
    
    if (![LTools isLogin:self]) {
        
        return;
    }
    
    NSString *authkey = [GMAPI getAuthkey];
    
    NSString *post = [NSString stringWithFormat:@"&coupon_id=%@&authcode=%@",aModel.coupon_id,authkey];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    LTools *tool = [[LTools alloc]initWithUrl:USER_GETCOUPON isPost:YES postData:postData];
    
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@",result);
        aModel.enable_receive = @"0";
        sender.selected = YES;
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failBlock == %@",failDic[RESULT_INFO]);
        
        
    }];
}




-(void)GchooseBtnClicked:(GBtn *)sender{
    
    
    sender.selected = !sender.selected;
    
    GTtaiRelationStoreModel *model = _tab.dataArray[sender.theIndex.section];
    if ([model.isChoose[sender.theIndex.row]intValue] == 1) {
        model.isChoose[sender.theIndex.row] = @"0";
    }else{
        model.isChoose[sender.theIndex.row] = @"1";
    }
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:sender.theIndex.section];
    [_tab reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
    
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    return 30;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView;{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 30)];
    view.backgroundColor = RGBCOLOR(239, 239, 239);
    view.tag = section+10;
    [view addTaget:self action:@selector(viewForHeaderInSectionClicked:) tag:view.tag];
    UILabel *ttLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH*0.6, 30)];
    
    
    GTtaiRelationStoreModel *amodel = _tab.dataArray[section];
    ttLabel.text = [NSString stringWithFormat:@"%@-%@ %@m",amodel.brand_name,amodel.mall_name,amodel.distance];
    ttLabel.font = [UIFont systemFontOfSize:12];
    [view addSubview:ttLabel];
    
   
    
    UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, 29.5, DEVICE_WIDTH, 0.5)];
    downLine.backgroundColor = RGBCOLOR(220, 221, 223);
    [view addSubview:downLine];
    
    
    
    UIButton *jiantouBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jiantouBtn setFrame:CGRectMake(DEVICE_WIDTH-30, 0, 30, 30)];
    jiantouBtn.userInteractionEnabled = NO;
    [view addSubview:jiantouBtn];
    
    
    if ( !_isOpen[view.tag-10]) {
        //        downLine.hidden = NO;
        [jiantouBtn setImage:[UIImage imageNamed:@"buy_jiantou_d.png"] forState:UIControlStateNormal];
    }else{
        //        downLine.hidden = YES;
        [jiantouBtn setImage:[UIImage imageNamed:@"buy_jiantou_u.png"] forState:UIControlStateNormal];
    }
    
    
    return view;
}

-(void)viewForHeaderInSectionClicked:(UIView*)sender{
    
    NSLog(@"%s",__FUNCTION__);
    _isOpen[sender.tag - 10] = !_isOpen[sender.tag - 10];
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:sender.tag-10];
    
    [_tab reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}



- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}












@end
