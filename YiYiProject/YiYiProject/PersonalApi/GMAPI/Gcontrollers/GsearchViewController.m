//
//  GsearchViewController.m
//  YiYiProject
//
//  Created by gaomeng on 15/3/23.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GsearchViewController.h"
#import "NSDictionary+GJson.h"
#import "GcustomSearchTableViewCell.h"
#import "GStorePinpaiViewController.h"//店铺主页
#import "GnearbyStoreViewController.h"//商场主页
#import "ProductDetailController.h"//单品详情页
#import "RefreshTableView.h"
#import "GpinpaiDetailViewController.h"//品牌主页

@interface GsearchViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,RefreshDelegate,UIScrollViewDelegate>
{
    UIView *_searchHeaderView;
    UITextField * _searchTextField;
    UIView *_menu_view;
    NSMutableArray *_btnArray;
    int _selectIndex;
    
    RefreshTableView *_tableView_brand;//搜索品牌
    RefreshTableView *_tableView_Shop;//搜索商铺
    RefreshTableView *_tableView_product;//搜索单品
    
    
    //定位相关
    NSDictionary *_locationDic;
    
    
    GcustomSearchTableViewCell *_tmpCell;//用于获取高度的临时cell
    
    
    
    LTools *_tool_brand;
    LTools *_tool_shop;
    LTools *_tool_product;
    
    
}
@end

@implementation GsearchViewController


- (void)dealloc
{
    _tableView_brand.refreshDelegate = nil;
    _tableView_brand.dataSource = nil;
    _tableView_brand.delegate = nil;
    _tableView_brand = nil;
    
    _tableView_Shop.refreshDelegate = nil;
    _tableView_Shop.dataSource = nil;
    _tableView_Shop.delegate = nil;
    _tableView_Shop = nil;
    
    _tableView_product.refreshDelegate = nil;
    _tableView_product.dataSource = nil;
    _tableView_product.delegate = nil;
    _tableView_product = nil;
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    
    self.myTitleLabel.textColor = RGBCOLOR(253, 105, 155);
    self.myTitle = @"搜索";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //创建搜索标题
    [self creatSearchHeaderView];
    
    _selectIndex = 100;
    
    
    [self creatThreeTab];
    
}


-(void)creatThreeTab{
    
    __weak typeof(self)weakSelf = self;
    
    //创建tableview
    _tableView_brand = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchHeaderView.frame), DEVICE_WIDTH, DEVICE_HEIGHT - _searchHeaderView.frame.size.height-64)];
    _tableView_brand.refreshDelegate = self;
    _tableView_brand.dataSource =self;
    _tableView_brand.hidden = YES;
    [self.view addSubview:_tableView_brand];
    
    
    
    
    _tableView_Shop = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchHeaderView.frame), DEVICE_WIDTH, DEVICE_HEIGHT - _searchHeaderView.frame.size.height-64)];
    _tableView_Shop.refreshDelegate = self;
    _tableView_Shop.dataSource =self;
    _tableView_Shop.hidden = YES;
    [self.view addSubview:_tableView_Shop];
    
    
    
    _tableView_product = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchHeaderView.frame), DEVICE_WIDTH, DEVICE_HEIGHT - _searchHeaderView.frame.size.height-64)];
    _tableView_product.refreshDelegate = self;
    _tableView_product.dataSource =self;
    _tableView_product.hidden = YES;
    [self.view addSubview:_tableView_product];
    
    
    
    [[GMAPI appDeledate]startDingweiWithBlock:^(NSDictionary *dic) {
        
        [weakSelf theLocationDictionary:dic];
    }];
    
    
    
}




- (void)theLocationDictionary:(NSDictionary *)dic{
    NSLog(@"%@",dic);
    _locationDic = dic;
    
    UIButton *btn = (UIButton *)[_menu_view viewWithTag:101];
    [self GbtnClicked:btn];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//创建搜索框
-(void)creatSearchHeaderView{
    _searchHeaderView=[[UIView alloc]initWithFrame:CGRectMake(0,0, DEVICE_WIDTH,82)];
    _searchHeaderView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_searchHeaderView];
    
    //搜索条图片
    UIView *kuang=[[UIView alloc]initWithFrame:CGRectMake(6, 6, self.view.bounds.size.width-60, 56/2)];
    kuang.layer.borderWidth = 0.5f;
    kuang.layer.cornerRadius = 4;
    kuang.layer.borderColor = [RGBCOLOR(182, 182, 182)CGColor];
    [_searchHeaderView addSubview:kuang];
    
    //放大镜
    UIImageView *fdj = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 13, 13)];
    [fdj setImage:[UIImage imageNamed:@"search_fangdajing.png"]];
//    fdj.backgroundColor = [UIColor orangeColor];
    [kuang addSubview:fdj];
    
    _searchTextField=[[UITextField alloc]initWithFrame:CGRectMake(30+6,MY_MACRO_NAME? 6:12,self.view.bounds.size.width-90,58/2)];
    _searchTextField.delegate=self;
    _searchTextField.font=[UIFont systemFontOfSize:12.f];
    _searchTextField.placeholder=@"输入关键词，不写关键字为搜索附近";
    _searchTextField.returnKeyType=UIReturnKeySearch;
    _searchTextField.userInteractionEnabled = TRUE;
    [_searchHeaderView addSubview:_searchTextField];
    
    //确定搜索按钮
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setFrame:CGRectMake(_searchHeaderView.frame.size.width-60, 0, 60, 40)];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_searchHeaderView addSubview:searchBtn];
    
    
    
    //分割线
    UIView *selectview=[[UIView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(kuang.frame)+5, DEVICE_WIDTH, 1)];
    selectview.backgroundColor=RGBCOLOR(235, 235, 235);
    [_searchHeaderView addSubview:selectview];
    
    //选择搜索类型view
    CGFloat aWidth = (ALL_FRAME_WIDTH - 24)/ 3.f;
    _menu_view = [[UIView alloc]initWithFrame:CGRectMake(12, CGRectGetMaxY(selectview.frame)+5, aWidth * 3, 30)];
    _menu_view.clipsToBounds = YES;
    _menu_view.layer.cornerRadius = 5;
    _menu_view.backgroundColor = [UIColor whiteColor];
    _menu_view.layer.borderWidth = 0.5;
    _menu_view.layer.borderColor = [RGBCOLOR(253, 105, 155)CGColor];
    
    [_searchHeaderView addSubview:_menu_view];
    NSLog(@"%@",NSStringFromCGRect(_menu_view.frame));
    
    NSArray *titles = @[@"品牌",@"商铺",@"单品"];
    _btnArray = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < titles.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(aWidth * i + 0.5 * i, 0, aWidth, 30);
        
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setHighlighted:NO];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        btn.tag = 100 + i;
        [btn setTitleColor:RGBCOLOR(253, 105, 155) forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor whiteColor];
        
        [_menu_view addSubview:btn];
        [_btnArray addObject:btn];
        [btn addTarget:self action:@selector(GbtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    _selectIndex = 101;
    
    UIButton *btn = (UIButton*)[_menu_view viewWithTag:101];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = RGBCOLOR(253, 105, 155);
    
    
}

- (void)GbtnClicked:(UIButton *)sender
{

    
    int tag = (int)sender.tag;
    //改变点击颜色
    for (UIButton *btn in _btnArray) {
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitleColor:RGBCOLOR(253, 105, 155) forState:UIControlStateNormal];
    }
    sender.backgroundColor = RGBCOLOR(253, 105, 155);
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _selectIndex = tag;
    NSLog(@"selectIndex = %d",_selectIndex);
    [self gshou];
    
    if (_selectIndex == 100) {//品牌
        _tableView_brand.hidden = NO;
        _tableView_Shop.hidden = YES;
        _tableView_product.hidden = YES;
        if (_tableView_brand.dataArray.count>0) {
            if ([LTools isEmpty:_searchTextField.text]) {
                return;
            }else{
                [_tableView_brand showRefreshHeader:YES];
            }
        }else{
            [_tableView_brand showRefreshHeader:YES];
        }
        
    }else if (_selectIndex == 101){//店铺
        _tableView_brand.hidden = YES;
        _tableView_Shop.hidden = NO;
        _tableView_product.hidden = YES;
        if (_tableView_Shop.dataArray.count>0) {
            if ([LTools isEmpty:_searchTextField.text]) {
                return;
            }else{
                [_tableView_Shop showRefreshHeader:YES];
            }
            
        }else{
            [_tableView_Shop showRefreshHeader:YES];
        }
        
    }else if (_selectIndex == 102){//单品
        _tableView_brand.hidden = YES;
        _tableView_Shop.hidden = YES;
        _tableView_product.hidden = NO;
        if (_tableView_product.dataArray.count>0) {
            if ([LTools isEmpty:_searchTextField.text]) {
                return;
            }else{
                [_tableView_product showRefreshHeader:YES];
            }
        }else{
            [_tableView_product showRefreshHeader:YES];
        }
        
    }
}

//点击搜索按钮
-(void)searchBtnClicked{

    [self gshou];
    
    if (_selectIndex == 100) {//品牌
        _tableView_brand.hidden = NO;
        _tableView_Shop.hidden = YES;
        _tableView_product.hidden = YES;
        [_tableView_brand showRefreshHeader:YES];
    }else if (_selectIndex == 101){//店铺
        _tableView_brand.hidden = YES;
        _tableView_Shop.hidden = NO;
        _tableView_product.hidden = YES;
        [_tableView_Shop showRefreshHeader:YES];
    }else if (_selectIndex == 102){//单品
        _tableView_brand.hidden = YES;
        _tableView_Shop.hidden = YES;
        _tableView_product.hidden = NO;
        [_tableView_product showRefreshHeader:YES];
    }
}

//收键盘
-(void)gshou{
    [_searchTextField resignFirstResponder];
}


-(void)isLocationDic{
    if ([LTools isEmpty:[_locationDic stringValueForKey:@"long"]] || [LTools isEmpty:[_locationDic stringValueForKey:@"lat"]]) {
        //金领时代 40.041951,116.33934
        _locationDic = @{
                         @"long":@"116.33934",
                         @"lat":@"40.041951",
                         @"isget":@"no"
                         };
    }
}

//请求网络数据
-(void)prepareNetData_brand{
    
    if (_tool_brand) {
        [_tool_brand cancelRequest];
    }
    NSString *theWord = _searchTextField.text;
    
    [self isLocationDic];
    
    NSString *url = [NSString stringWithFormat:@"%@&keywords=%@&page=%d&per_page=%d&long=%@&lat=%@&type=brand",GSEARCH,theWord,_tableView_brand.pageNum,L_PAGE_SIZE,[_locationDic stringValueForKey:@"long"],[_locationDic stringValueForKey:@"lat"]];
    
    //接口url:
    NSLog(@"请求用户通知接口:%@",url);
    
    
    _tool_brand= [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    
    [_tool_brand requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSArray *arr = [result arrayValueForKey:@"list"];
        
        [_tableView_brand reloadData:arr pageSize:L_PAGE_SIZE];
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        [_tableView_brand loadFail];
        
    }];
    
}


-(void)prepareNetData_shop{
    
    if (_tool_shop) {
        [_tool_shop cancelRequest];
    }
    
    
    [self isLocationDic];
    
    
    NSString *theWord = _searchTextField.text;
    NSString *url = [NSString stringWithFormat:@"%@&keywords=%@&page=%d&per_page=%d&long=%@&lat=%@&type=mall",GSEARCH,theWord,_tableView_Shop.pageNum,L_PAGE_SIZE,[_locationDic stringValueForKey:@"long"],[_locationDic stringValueForKey:@"lat"]];
    //接口url:
    NSLog(@"请求用户通知接口:%@",url);
    
    _tool_shop= [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    
    [_tool_shop requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSArray *arr = [result arrayValueForKey:@"list"];
        
        [_tableView_Shop reloadData:arr pageSize:L_PAGE_SIZE];
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        [_tableView_Shop loadFail];
        
        
    }];
}

-(void)prepareNetData_product{
    
    
    if (_tool_product) {
        [_tool_product cancelRequest];
    }
    
    [self isLocationDic];
    
    NSString *theWord = _searchTextField.text;
    NSString *url = [NSString stringWithFormat:@"%@&keywords=%@&page=%d&per_page=%d&long=%@&lat=%@&type=product",GSEARCH,theWord,_tableView_product.pageNum,L_PAGE_SIZE,[_locationDic stringValueForKey:@"long"],[_locationDic stringValueForKey:@"lat"]];
    
    
    //接口url:
    NSLog(@"请求用户通知接口:%@",url);
    
    
    _tool_product= [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    
    [_tool_product requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSArray *arr = [result arrayValueForKey:@"list"];
        [_tableView_product reloadData:arr pageSize:L_PAGE_SIZE];
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        [_tableView_product loadFail];
        
    }];
}



















#pragma - mark RefreshDelegate 

- (void)loadNewData
{
    if (_selectIndex == 100) {//品牌
        [self prepareNetData_brand];
    }else if (_selectIndex == 101){//店铺
        [self prepareNetData_shop];
    }else if (_selectIndex == 102){//单品
        [self prepareNetData_product];
    }
}

- (void)loadMoreData
{
    
    if (_selectIndex == 100) {//品牌
        [self prepareNetData_brand];
    }else if (_selectIndex == 101){//店铺
        [self prepareNetData_shop];
    }else if (_selectIndex == 102){//单品
        [self prepareNetData_product];
    }
}


//新加
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    NSLog(@"%s",__FUNCTION__);
    
    [self gshou];
    
    if (_selectIndex == 100) {//搜索的是品牌
        
        NSDictionary *dic = _tableView_brand.dataArray[indexPath.row];
        GpinpaiDetailViewController *ccc = [[GpinpaiDetailViewController alloc]init];
        if (self.isChooseProductLink) {
            ccc.isChooseProductLink = YES;
        }
        ccc.pinpaiIdStr = [dic stringValueForKey:@"brand_id"];
        ccc.pinpaiName = [dic stringValueForKey:@"brand_name"];
        ccc.locationDic = _locationDic;
        [self.navigationController pushViewController:ccc animated:YES];
        
        
    }else if (_selectIndex == 101){//搜索的是商铺
        NSDictionary *dic = _tableView_Shop.dataArray[indexPath.row];
        if ([[dic stringValueForKey:@"mall_type"]intValue] == 1) {//大商场
            GnearbyStoreViewController *ccc = [[GnearbyStoreViewController alloc]init];
            ccc.storeIdStr = [dic stringValueForKey:@"mall_id"];
            ccc.storeNameStr = [dic stringValueForKey:@"mall_name"];
            if (self.isChooseProductLink) {
                ccc.isChooseProductLink = YES;
            }
            [self.navigationController pushViewController:ccc animated:YES];
        }else if ([[dic stringValueForKey:@"mall_type"]intValue]==2){//精品店
            GStorePinpaiViewController *ccc = [[GStorePinpaiViewController alloc]init];
            ccc.storeIdStr = [dic stringValueForKey:@"mall_id"];
            ccc.storeNameStr = [dic stringValueForKey:@"mall_name"];
            ccc.guanzhuleixing = @"精品店";
            if (self.isChooseProductLink) {
                ccc.isChooseProductLink = YES;
            }
            [self.navigationController pushViewController:ccc animated:YES];
            
        }
    }else if (_selectIndex == 102){//搜索的是单品
        
        NSDictionary *dic = _tableView_product.dataArray[indexPath.row];
        NSString *productId = [dic stringValueForKey:@"product_id"];
        
        //添加品牌链接
        if (self.isChooseProductLink) {
            
            ProductDetailController *ccc = [[ProductDetailController alloc]init];
            ccc.product_id = productId;
            ccc.isChooseProductLink = YES;
            [self.navigationController pushViewController:ccc animated:YES];
            
        }else
        {
            [MiddleTools pushToProductDetailWithId:productId fromViewController:self lastNavigationHidden:NO hiddenBottom:NO];
        }
    }
    
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    CGFloat height = 0.0f;
    if (tableView == _tableView_brand) {//品牌
        height = 50;
    }else if (tableView == _tableView_Shop){//商铺
        NSDictionary *dic = _tableView_Shop.dataArray[indexPath.row];
        NSString *activityStr = [dic stringValueForKey:@"activity_title"];
        if (activityStr.length>0) {
            height = 69;
        }else{
            height = 52;
        }
    }else if (tableView == _tableView_product){//单品
        height = 90;
    }
    
    return height;
}







#pragma mark -  UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    

    
    //重用相关
    
    GcustomSearchTableViewCell *cell;
    
    if (tableView == _tableView_brand) {//品牌
        static NSString *identi_brand = @"refresh_brand";
        GcustomSearchTableViewCell *cell_brand = [tableView dequeueReusableCellWithIdentifier:identi_brand];
        if (!cell_brand) {
            cell_brand = [[GcustomSearchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi_brand];
        }
        cell = cell_brand;
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        cell.theType = GSEARCHTYPE_PINPAI;
        if (_searchTextField.text.length>0) {
            cell.isHaveKeyWord = YES;
        }else{
            cell.isHaveKeyWord = NO;
        }
        NSDictionary *data_dic = _tableView_brand.dataArray[indexPath.row];
        BOOL isshow = YES;
        if ([[_locationDic stringValueForKey:@"isget"] isEqualToString:@"no"]) {
            isshow = NO;
        }
        
        [cell loadCustomViewWithData:data_dic indexPath:indexPath showDidtance:isshow];
        
    }else if (tableView == _tableView_Shop){//商铺
        static NSString *identi_shop = @"refresh_shop";
        GcustomSearchTableViewCell *cell_shop = [tableView dequeueReusableCellWithIdentifier:identi_shop];
        if (!cell_shop) {
            cell_shop = [[GcustomSearchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi_shop];
        }
        cell = cell_shop;
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        cell.theType = GSEARCHTYPE_SHANGPU;
        NSDictionary *data_dic = _tableView_Shop.dataArray[indexPath.row];
        
        BOOL isshow = YES;
        if ([[_locationDic stringValueForKey:@"isget"] isEqualToString:@"no"]) {
            isshow = NO;
        }
        
        [cell loadCustomViewWithData:data_dic indexPath:indexPath showDidtance:isshow];
        
    }else if (tableView == _tableView_product){//单品
        static NSString *identi_product = @"refresh_product";
        GcustomSearchTableViewCell *cell_product = [tableView dequeueReusableCellWithIdentifier:identi_product];
        if (!cell_product) {
            cell_product = [[GcustomSearchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi_product];
        }
        cell = cell_product;
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        cell.theType = GSEARCHTYPE_DANPIN;
        NSDictionary *data_dic = _tableView_product.dataArray[indexPath.row];
        BOOL isshow = YES;
        if ([[_locationDic stringValueForKey:@"isget"] isEqualToString:@"no"]) {
            isshow = NO;
        }
        [cell loadCustomViewWithData:data_dic indexPath:indexPath showDidtance:isshow];
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
//    return _tableView.dataArray.count;
    NSInteger num = 0;
    if (tableView == _tableView_brand) {
        num = _tableView_brand.dataArray.count;
    }else if (tableView == _tableView_Shop){
        _tmpCell.theType = GSEARCHTYPE_SHANGPU;
        num = _tableView_Shop.dataArray.count;
    }else if (tableView == _tableView_product){
        _tmpCell.theType = GSEARCHTYPE_DANPIN;
        num = _tableView_product.dataArray.count;
    }
    
    return num;
}





-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"dddddddddddd %f",scrollView.contentOffset.y);
//    if (scrollView == _tableView_brand ) {
//        [self gshou];
//    }
    [self gshou];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchBtnClicked];
    return YES;
}



-(void)leftButtonTap:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
