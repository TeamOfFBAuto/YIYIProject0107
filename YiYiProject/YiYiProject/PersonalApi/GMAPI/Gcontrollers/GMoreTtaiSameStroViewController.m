//
//  GMoreTtaiSameStroViewController.m
//  YiYiProject
//
//  Created by gaomeng on 15/8/26.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GMoreTtaiSameStroViewController.h"
#import "RefreshTableView.h"
#import "GTtaiRelationStoreModel.h"
#import "GBtn.h"
#import "GTtaiDetailViewController.h"
#import "GwebViewController.h"
#import "MessageDetailController.h"

@interface GMoreTtaiSameStroViewController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_tab;
    
    int _isOpen[1000];//缩放tablview
    
    LTools *tool_detail;
}
@end

@implementation GMoreTtaiSameStroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    
    self.myTitle = @"更多商场";
    
    
    for (int i=0; i<1000; i++) {
        _isOpen[i]=0;
    }
    _isOpen[0] = 1;
    
    
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
    GTtaiRelationStoreModel *model = _tab.dataArray[indexPath.section];
    NSArray *img_detail = [model.image arrayValueForKey:@"img_detail"];
    NSDictionary *dic = img_detail[indexPath.row];
    NSString *product_id = [dic stringValueForKey:@"product_id"];
    
    [MiddleTools pushToProductDetailWithId:product_id fromViewController:self lastNavigationHidden:NO hiddenBottom:YES];
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return _tab.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = 0;
    GTtaiRelationStoreModel *amodel = _tab.dataArray[section];
    NSDictionary *image = amodel.image;
    if ([[image stringValueForKey:@"have_detail"]intValue] == 1) {
        count = [image arrayValueForKey:@"img_detail"].count;
    }else{
        count = 0;
    }
    
    
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
    
    NSString *url = [NSString stringWithFormat:@"%@&authcode=%@&longitude=%@&latitude=%@&tt_id=%@page=%d&count=%d",TTAI_STORE,[GMAPI getAuthkey],longitude,latitude,self.tPlat_id,_tab.pageNum,L_PAGE_SIZE];
    
    NSLog(@"爱你也需要很大的勇气%@",url);
    
    tool_detail = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    
    [tool_detail requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        
        
        NSLog(@"result %@",result);
        NSArray *list = result[@"list"];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:list.count];
        
        for (NSDictionary *dic in list) {
            GTtaiRelationStoreModel *amodel = [[GTtaiRelationStoreModel alloc]initWithDictionary:dic];
            amodel.isChoose = [NSMutableArray arrayWithCapacity:1];
            NSDictionary *image = amodel.image;
            if ([[image stringValueForKey:@"have_detail"]intValue] == 1) {
                for (int i = 0; i<[image arrayValueForKey:@"img_detail"].count; i++) {
                    [amodel.isChoose addObject:@"1"];
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
    NSDictionary *image = amodel.image;
    if ([[image stringValueForKey:@"have_detail"]intValue] == 1) {
        NSArray *img_detail = [image arrayValueForKey:@"img_detail"];
        NSDictionary *dic = img_detail[indexPath.row];
        
        
        
        //选择button
        GBtn *chooseBtn = [GBtn buttonWithType:UIButtonTypeCustom];
        [chooseBtn setFrame:CGRectMake(0, 8, 35, 44)];
        [chooseBtn setImage:[UIImage imageNamed:@"Ttaixq_xuanze_xuanzhong.png"] forState:UIControlStateSelected];
        [chooseBtn setImage:[UIImage imageNamed:@"Ttaixq_xuanze1.png"] forState:UIControlStateNormal];
        chooseBtn.theIndex = indexPath;
        [chooseBtn addTarget:self action:@selector(GchooseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        //        chooseBtn.backgroundColor = [UIColor orangeColor];
        if ([amodel.isChoose[indexPath.row] intValue] == 1) {
            chooseBtn.selected = YES;
        }else{
            chooseBtn.selected = NO;
        }
        
        [cell.contentView addSubview:chooseBtn];
        
        
        NSDictionary *product_cover_pic = [dic dictionaryValueForKey:@"product_cover_pic"];
        NSString *imvUrl = [product_cover_pic stringValueForKey:@"src"];
        
        UIImageView *picImv = [[UIImageView alloc]initWithFrame:CGRectMake(35, 8, 44, 44)];
        [picImv l_setImageWithURL:[NSURL URLWithString:imvUrl] placeholderImage:DEFAULT_YIJIAYI];
        [cell.contentView addSubview:picImv];
        
        UILabel *productNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(picImv.frame)+10, picImv.frame.origin.y, DEVICE_WIDTH - CGRectGetMaxX(picImv.frame)-10, picImv.frame.size.height*0.5)];
        productNameLabel.font = [UIFont systemFontOfSize:12];
        productNameLabel.text = [NSString stringWithFormat:@"%@:%@",[dic stringValueForKey:@"product_type_name"],[dic stringValueForKey:@"product_name"]];
        [cell.contentView addSubview:productNameLabel];
        
        UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(productNameLabel.frame.origin.x, CGRectGetMaxY(productNameLabel.frame), productNameLabel.frame.size.width, productNameLabel.frame.size.height)];
        priceLabel.font = [UIFont systemFontOfSize:12];
        priceLabel.textColor = RGBCOLOR(249, 165, 196);
        priceLabel.text = [NSString stringWithFormat:@"￥%@",[dic stringValueForKey:@"product_price"]];
        [cell.contentView addSubview:priceLabel];
        
        
    }else{
        
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    return cell;
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
    [_tab reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    return 50;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView;{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
    view.backgroundColor = [UIColor whiteColor];
    view.tag = section+10;
    [view addTaget:self action:@selector(viewForHeaderInSectionClicked:) tag:view.tag];
    UILabel *ttLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH*0.6, 50)];
    
    
    GTtaiRelationStoreModel *amodel = _tab.dataArray[section];
    ttLabel.text = [NSString stringWithFormat:@"%@-%@ %@m",amodel.brand_name,amodel.mall_name,amodel.distance];
    ttLabel.font = [UIFont systemFontOfSize:12];
    [view addSubview:ttLabel];
    //    ttLabel.backgroundColor = [UIColor orangeColor];
    
    
    CGFloat totlePrice = 0;
    NSArray *img_detail = [amodel.image arrayValueForKey:@"img_detail"];
    for (int i = 0; i<img_detail.count; i++) {
        if ([amodel.isChoose[i] integerValue] == 1) {
            NSDictionary *dic = img_detail[i];
            totlePrice += [[dic stringValueForKey:@"product_price"] floatValue];
        }
    }
    
    UILabel *totlePriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(ttLabel.frame)+5, ttLabel.frame.origin.y, DEVICE_WIDTH *0.3, 50)];
    totlePriceLabel.font = [UIFont systemFontOfSize:12];
    totlePriceLabel.textAlignment = NSTextAlignmentCenter;
    totlePriceLabel.text = [NSString stringWithFormat:@"搭配价￥%.1f",totlePrice];
    [view addSubview:totlePriceLabel];
    
    
    UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, 49.5, DEVICE_WIDTH, 0.5)];
    downLine.backgroundColor = RGBCOLOR(220, 221, 223);
    [view addSubview:downLine];
    
    
    
    UIButton *jiantouBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jiantouBtn setFrame:CGRectMake(DEVICE_WIDTH-40, 5, 40, 40)];
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
    
    
//    [UIView animateWithDuration:0.2 animations:^{
        [_tab reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
//    }];
    
    
    
    
}


-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    NSString *url;
    
    
    GTtaiRelationStoreModel *model = _tab.dataArray[section];
    if (model.activity) {//有活动
        url = [model.activity stringValueForKey:@"cover_pic"];
        CGFloat p_width = [[model.activity stringValueForKey:@"width"]floatValue];
        CGFloat p_height = [[model.activity stringValueForKey:@"height"]floatValue];
        height = DEVICE_WIDTH/p_width * p_height;
        
    }
    
    
    if (_isOpen[section] == 0) {
        height = 0.01;
    }
    
    
    
    return height;
    
}
-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0;
    NSString *url;
    
    
    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectZero];
    
    GTtaiRelationStoreModel *model = _tab.dataArray[section];
    if (model.activity) {//有活动
        url = [model.activity stringValueForKey:@"cover_pic"];
        CGFloat p_width = [[model.activity stringValueForKey:@"width"]floatValue];
        CGFloat p_height = [[model.activity stringValueForKey:@"height"]floatValue];
        height = DEVICE_WIDTH/p_width * p_height;
        
        
        [imv setHeight:height];
        
        [imv l_setImageWithURL:[NSURL URLWithString:url] placeholderImage:DEFAULT_YIJIAYI];
        
        [imv addTapGestureTarget:self action:@selector(viewForFooterInSectionClicked:) tag:(int)(section + 1000)];
        
        
        
    }
    
    return imv;
}


//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    
//    
//}


-(void)viewForFooterInSectionClicked:(UITapGestureRecognizer*)sender{
    
    NSInteger tt = sender.view.tag-1000;
    GTtaiRelationStoreModel *model = _tab.dataArray[tt];
    if ([[model.activity stringValueForKey:@"redirect_type"]intValue] == 1) {//外链活动
        GwebViewController *ccc = [[GwebViewController alloc]init];
        ccc.urlstring = [model.activity stringValueForKey:@"url"];
        ccc.isSaoyisao = YES;
        ccc.hidesBottomBarWhenPushed = YES;
        UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:ccc];
        [self presentViewController:navc animated:YES completion:^{
            
        }];
    }else if ([[model.activity stringValueForKey:@"redirect_type"]intValue] == 0){//跳转应用内活动
        NSString *activityId = [model.activity stringValueForKey:@"id"];
        MessageDetailController *detail = [[MessageDetailController alloc]init];
        detail.isActivity = YES;
        detail.msg_id = activityId;
        detail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detail animated:YES];
    }
    
}



@end
