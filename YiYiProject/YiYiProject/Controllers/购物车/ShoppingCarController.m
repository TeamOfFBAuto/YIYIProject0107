//
//  ShoppingCarController.m
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ShoppingCarController.h"
#import "ShoppingCartCell.h"
#import "ProductModel.h"

#import "ConfirmOrderController.h"//确认订单
#import "PayActionViewController.h"//支付页面
#import "RefreshTableView.h"

#import "OrderModel.h"

#define kPadding_add 1000 //数量增加
#define kPadding_reduce 2000 //数量减少
#define kPadding_delete 3000 //删除
#define kPadding_alert  4000 //UIAlertView tag
#define kPadding_select  5000 //UIAlertView tag

@interface ShoppingCarController ()<RefreshDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    RefreshTableView *_table;
    
    BOOL _isSelectAll;//是否选择全部
    
    UIButton *_selectAllBtn;//选择全部按钮
    
    UILabel *_sumLabel;//总价label
    
    UIView *_bottom;//底部工具
    
    BOOL _isEditing;//是否处在编辑状态
    
    BOOL _isUpdateCart;//是否更新购物车
    
    NSMutableDictionary *_selectDic;//记录是否选择了
    
    OrderModel *_buyAgainOrder;//再次购买order
}

@end

@implementation ShoppingCarController

- (void)dealloc
{
    [_table removeObserver];
    _table.dataSource = nil;
    _table.refreshDelegate = nil;
    _table = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"购物车";
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    
//    [self.my_right_button setTitle:@"编辑" forState:UIControlStateNormal];
//    [self.my_right_button setTitle:@"完成" forState:UIControlStateSelected];
    [self.my_right_button setImage:[UIImage imageNamed:@"myaddress_shanchu"] forState:UIControlStateNormal];
    self.my_right_button.hidden = YES;

    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH,DEVICE_HEIGHT - 64) showLoadMore:NO];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    
    __weak typeof(self)weakSelf = self;
    _table.dataArrayObeserverBlock = ^(NSString *keyPath,NSDictionary *change)
    {
        if ([keyPath isEqualToString:@"selected"]) {
            [weakSelf updateSumPrice];
            
        }else if ([keyPath isEqualToString:@"_dataArrayCount"]){
            
            [weakSelf checkCartIsEmpty];
        }
    };
    
    [_table showRefreshHeader:YES];
    
    _isUpdateCart = YES;
    
    //初始化 记录是否选择 默认全选择
    _selectDic = [NSMutableDictionary dictionary];
    
    //监测购物车是否更新
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateCartNotification:) name:NOTIFICATION_UPDATE_TO_CART object:nil];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForBuyAgain:) name:NOTIFICATION_BUY_AGAIN object:nil];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
        
    if (_isUpdateCart) {
        
        [_table showRefreshHeader:YES];
        _isUpdateCart = NO;
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 创建视图

/**
 *  创建购物车为空view
 */
- (UIView *)footerViewForNoProduct
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, _table.height)];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 235)];
//    bgView.backgroundColor = [UIColor orangeColor];
    [footerView addSubview:bgView];
    bgView.centerY = footerView.height/2.f;
    //图片
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 110, 105)];
    imageView.image = [UIImage imageNamed:@"shopping_cart_icon"];
    [bgView addSubview:imageView];
    imageView.centerX = bgView.width/2.f - 10;
    
    //购物车还是空的
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.bottom + 22, DEVICE_WIDTH, 15) title:@"购物车还是空的" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"646464"]];
    [bgView addSubview:label];
    
    //快去挑几件喜欢的宝贝吧
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, label.bottom + 5, DEVICE_WIDTH, 15) title:@"快去挑几件喜欢的宝贝吧" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"e4e4e4"]];
    [bgView addSubview:label2];
    
    UIButton *btn = [[UIButton alloc]initWithframe:CGRectMake((DEVICE_WIDTH - 150) / 2.f, label2.bottom + 20, 150, 30) buttonType:UIButtonTypeRoundedRect normalTitle:@"去逛逛" selectedTitle:nil target:self action:@selector(clickToGoShopping:)];
    [bgView addSubview:btn];
    btn.backgroundColor = DEFAULT_TEXTCOLOR;
    [btn addCornerRadius:3.f];
    btn.centerX = bgView.width/2.f;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return footerView;
}

/**
 *  创建底部工具条
 */
- (void)creatBottomTools
{
    _bottom = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 64 - 50, DEVICE_WIDTH, 50)];
    [self.view addSubview:_bottom];
    _bottom.backgroundColor = [UIColor whiteColor];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _bottom.width, 0.5)];
    line.backgroundColor = [UIColor colorWithHexString:@"e4e4e4"];
    [_bottom addSubview:line];
    
    _selectAllBtn = [[UIButton alloc]initWithframe:CGRectMake(0, 0, 40, _bottom.height) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"shoppingcart_bottom_normal"] selectedImage:[UIImage imageNamed:@"shoppingcart_bottom_selected"] target:self action:@selector(clickToSelectAll:)];
    [_bottom addSubview:_selectAllBtn];
    
    _selectAllBtn.selected = YES;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(_selectAllBtn.right, 0, 30, _bottom.height) title:@"全选" font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"494949"]];
    [_bottom addSubview:label];
    
    UILabel *label_heJi = [[UILabel alloc]initWithFrame:CGRectMake(label.right + 10, 12, 30, 14) title:@"合计" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"494949"]];
    [_bottom addSubview:label_heJi];
    
    UILabel *label_fei = [[UILabel alloc]initWithFrame:CGRectMake(label.right + 10, label_heJi.bottom + 5, 30, 8) title:@"免运费" font:8 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"494949"]];
    [_bottom addSubview:label_fei];
    
    _sumLabel = [[UILabel alloc]initWithFrame:CGRectMake(label_heJi.right + 10, 0, 100, _bottom.height) title:@"￥0.00" font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR];
    [_bottom addSubview:_sumLabel];
    
    [self updateSumPrice];//更新数据
    
    UIButton *payButton = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 110, 0, 110, _bottom.height) buttonType:UIButtonTypeCustom normalTitle:@"去结算" selectedTitle:nil target:self action:@selector(clickToPay:)];
    [payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    payButton.backgroundColor = DEFAULT_TEXTCOLOR;
    [_bottom addSubview:payButton];
    
}

#pragma mark - 监控通知

/**
 *  购物车更新通知
 *
 *  @param notification
 */
- (void)updateCartNotification:(NSNotification *)notification
{
    _isUpdateCart = YES;
}

/**
 *  再次购买通知
 *
 *  @param notification
 */
- (void)notificationForBuyAgain:(NSNotification *)notification
{
    OrderModel *order = [notification.userInfo objectForKey:@"result"];
    _buyAgainOrder = order;
}

#pragma mark - 选中单品相关处理

/**
 *  是否全部选中
 *
 *  @return
 */
- (BOOL)isAllSelected
{
    for (int i = 0; i < _table.dataArray.count; i ++) {
        
        ProductModel *aModel = [_table.dataArray objectAtIndex:i];
        if ([_selectDic[aModel.cart_pro_id] isEqualToString:@"no"]) {
            
            return NO;
        }
    }
    return YES;
}

/**
 *  选中个数
 *
 *  @return
 */
- (int)sumSelected
{
    int sum = 0;
    for (int i = 0; i < _table.dataArray.count; i ++) {
        
        ProductModel *aModel = [_table.dataArray objectAtIndex:i];
        if ([_selectDic[aModel.cart_pro_id] isEqualToString:@"yes"]) {
            
            sum ++;
        }
    }
    return sum;
}

/**
 *  所有选中id ,拼接字符串
 *
 *  @return
 */
- (NSString *)stringForSelected
{
    NSMutableArray *arr_id = [NSMutableArray array];
    for (int i = 0; i < _table.dataArray.count; i ++) {
        
        ProductModel *aModel = [_table.dataArray objectAtIndex:i];
        if ([_selectDic[aModel.cart_pro_id] isEqualToString:@"yes"]) {
            [arr_id addObject:aModel.cart_pro_id];
        }
    }
    return [arr_id componentsJoinedByString:@","];
}

/**
 *  计算总价
 *
 *  @return
 */
- (float)sumPrice
{
    float sum = 0.f;
    for (int i = 0; i < _table.dataArray.count; i ++) {
        
        ProductModel *aModel = [_table.dataArray objectAtIndex:i];
        
        if ([_selectDic[aModel.cart_pro_id] isEqualToString:@"yes"]) {
            
            sum += ([aModel.product_num floatValue] * [aModel.product_price floatValue]);
        }
    }
    
    return sum;
}

#pragma mark - 事件处理

/**
 *  跳转至支付页面
 */
- (void)pushToPayPageWithOrderId:(NSString *)orderId
                        orderNum:(NSString *)orderNum
                        sumPrice:(CGFloat)sumPrice
{
    [self.navigationController popViewControllerAnimated:NO];
    
    PayActionViewController *pay = [[PayActionViewController alloc]init];
    pay.orderId = orderId;
    pay.orderNum = orderNum;
    pay.sumPrice = sumPrice;
    pay.hidesBottomBarWhenPushed = YES;
    pay.lastVc = self;
    [self.navigationController pushViewController:pay animated:YES];
}


/**
 *  检测
 */
- (void)checkCartIsEmpty
{
    //购物车是空的
    if (_table.dataArray.count == 0) {
        
        _table.tableFooterView = [self footerViewForNoProduct];
        
        if (_bottom) {
            
            [_bottom removeFromSuperview];
            _bottom = nil;
        }
        
        self.my_right_button.hidden = YES;
        
        _table.height = DEVICE_HEIGHT - 64 - 49;
        
        _isEditing = NO;
        
        self.my_right_button.selected = NO;
        
    }else
    {
        _table.tableFooterView = nil;
        
        if (!_bottom) {
            
            _isSelectAll = YES;
            [self creatBottomTools];
        }
        
        self.my_right_button.hidden = NO;

        _table.height = DEVICE_HEIGHT - 64 - 49;

    }
    
    [self updateSumPrice];
}

/**
 *  更新总价格
 */
- (void)updateSumPrice
{
    _sumLabel.text = [NSString stringWithFormat:@"￥%.2f",[self sumPrice]];
    
    _selectAllBtn.selected = [self isAllSelected];

}

/**
 *  去选择商品
 *
 *  @param sender
 */
- (void)clickToGoShopping:(UIButton *)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    UITabBarController *root = (UITabBarController *)((LNavigationController *)ROOTVIEWCONTROLLER).topViewController;
    
    root.selectedIndex = 1;
}

/**
 *  去结算
 *
 *  @param sender
 */
- (void)clickToPay:(UIButton *)sender
{
    if (![LTools isLogin:self]) {
        
        return;
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < _table.dataArray.count; i ++) {
        
        ProductModel *aModel = [_table.dataArray objectAtIndex:i];
        
        if ([_selectDic[aModel.cart_pro_id] isEqualToString:@"yes"]) {
            
            NSLog(@"购买:%@ 单价:%@ 数量:%@",aModel.product_name,aModel.product_price,aModel.product_num);
            
            [arr addObject:aModel];

        }

    }
    NSLog(@"总价: %f",[self sumPrice]);
    
    if (arr.count == 0) {
        
        [LTools showMBProgressWithText:@"您还没有选择商品哦!" addToView:self.view];
        return;
    }
    
    ConfirmOrderController *confirm = [[ConfirmOrderController alloc]init];
    confirm.productArray = arr;
    confirm.hidesBottomBarWhenPushed = YES;
    confirm.lastViewController = self;
    [self.navigationController pushViewController:confirm animated:YES];
    
}

- (void)clickToSelect:(UIButton *)sender
{
    _isSelectAll = NO;
    
    ProductModel *aModel = [_table.dataArray objectAtIndex:sender.tag - kPadding_select];
    
    //默认 yes
    
    if (!sender.selected) {
        
        [_selectDic setObject:@"yes" forKey:aModel.cart_pro_id];

    }else
    {
        [_selectDic setObject:@"no" forKey:aModel.cart_pro_id];
    }
    
    //注意顺序,一定要先设置 yes or no再做如下操作
    sender.selected = !sender.selected;
    
    [self updateSumPrice];

}

/**
 *  全部设置为选择状态
 *
 */
- (void)setAllSelected
{
    for (int i = 0; i < _table.dataArray.count; i ++) {
        
        ProductModel *aModel = [_table.dataArray objectAtIndex:i];
        [_selectDic setObject:@"yes" forKey:aModel.cart_pro_id];
        
    }
}

- (void)clickToSelectAll:(UIButton *)sender
{
    sender.selected = !sender.selected;

    _isSelectAll = YES;
    
    for (int i = 0; i < _table.dataArray.count; i ++) {
        
        ProductModel *aModel = [_table.dataArray objectAtIndex:i];
        BOOL isOK = sender.selected;
        [_selectDic setObject:isOK ? @"yes" : @"no" forKey:aModel.cart_pro_id];

    }
    
    
    [_table reloadData];
    
    [self updateSumPrice];
}

/**
 *  添加数量
 *
 *  @param sender
 */
- (void)clickToAdd:(UIButton *)sender
{
    NSInteger index = sender.tag - kPadding_add;
    ProductModel *aModel = _table.dataArray[index];
    
    [self updateProductByNum:1 cell:nil productModel:aModel];
}

/**
 *  减少数量
 *
 *  @param sender
 */
- (void)clickToReduce:(UIButton *)sender
{
    NSInteger index = sender.tag - kPadding_reduce;
    ProductModel *aModel = _table.dataArray[index];
    
    [self updateProductByNum:-1 cell:nil productModel:aModel];

}

//右边按钮点击

-(void)rightButtonTap:(UIButton *)sender
{
    int sum = [self sumSelected];
    if (sum == 0) {
        
        [LTools alertText:@"您还没有选择宝贝!"];
        return;
    }
    
    NSString *title = [NSString stringWithFormat:@"确认要删除选中%d种宝贝吗?",sum];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:title delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.tag = sender.tag + kPadding_alert;
    [alert show];
}

#pragma mark - 网络请求

/**
 *  删除购物车某条记录
 *
 *  @param aModel
 */
- (void)deleteProducts:(NSString *)products
{
//    authcode
//    cart_pro_id 购物车商品ids
    
    NSString *authkey = [GMAPI getAuthkey];
    
    NSDictionary *params = @{@"authcode":authkey,
                             @"cart_pro_id":products};
    
    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *post = [LTools url:nil withParams:params];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    LTools *tool = [[LTools alloc]initWithUrl:ORDER_DEL_CART_PRODUCT isPost:YES postData:postData];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATON_UPDATESHOPCAR_NUM object:nil];
        weakTable.pageNum = 1;
        weakTable.isReloadData = YES;
        [weakSelf getCartList];
        
    } failBlock:^(NSDictionary *result, NSError *erro) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [weakTable loadFail];
    }];
}

/**
 *  更新单品数量
 *
 *  @param num    +1 或者 -1
 *  @param cell
 *  @param aModel
 */
- (void)updateProductByNum:(int)num
                      cell:(ShoppingCartCell *)cell
              productModel:(ProductModel *)aModel
{
    NSString *authkey = [GMAPI getAuthkey];
    
    NSDictionary *params = @{@"authcode":authkey,
                             @"cart_pro_id":aModel.cart_pro_id,
                             @"product_num":[NSNumber numberWithInt:num]};
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self)weakSelf = self;
    __weak typeof(_table)weakTable = _table;

    NSString *post = [LTools url:nil withParams:params];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    LTools *tool = [[LTools alloc]initWithUrl:ORDER_EDIT_CART_PRODUCT isPost:YES postData:postData];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        //更新购物车显示数字
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATON_UPDATESHOPCAR_NUM object:nil];
        aModel.product_num = [NSString stringWithFormat:@"%d",[aModel.product_num intValue] + num];
        [weakTable reloadData];
        [weakSelf updateSumPrice];
        
    } failBlock:^(NSDictionary *result, NSError *erro) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [weakTable loadFail];
    }];

}
/**
 *  获取购物车数据
 */
- (void)getCartList
{
    NSString *authkey = [GMAPI getAuthkey];
    
    NSDictionary *params = @{@"authcode":authkey,
                             @"page":[NSNumber numberWithInt:_table.pageNum],
                             @"perpage":[NSNumber numberWithInt:L_PAGE_SIZE]};
    
    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;

    NSString *url = [LTools url:nil withParams:params];

    url = [NSString stringWithFormat:@"%@&%@",ORDER_GET_CART_PRODCUTS,url];
    
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];

        NSArray *list = [result arrayValueForKey:@"list"];
        if (list) {
            
            NSMutableArray *temp = [NSMutableArray array];
            for (NSDictionary *aDic in list) {
                ProductModel *aModel = [[ProductModel alloc]initWithDictionary:aDic];
                [temp addObject:aModel];
                
                [_selectDic setObject:@"yes" forKey:aModel.cart_pro_id];
            }
            [weakTable reloadData:temp pageSize:L_PAGE_SIZE noDataView:[weakSelf footerViewForNoProduct]];
        }
        
        
    } failBlock:^(NSDictionary *result, NSError *erro) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];

        [weakTable reloadData:nil pageSize:L_PAGE_SIZE noDataView:[weakSelf footerViewForNoProduct]];
    }];
    
}

#pragma mark - 代理

#pragma mark - UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self deleteProducts:[self stringForSelected]];
        
    }
}

#pragma mark - RefreshDelegate

- (void)loadNewData
{
    [self getCartList];
}
- (void)loadMoreData
{
    [self getCartList];
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductModel *aModel = [_table.dataArray objectAtIndex:indexPath.row];
    [MiddleTools pushToProductDetailWithId:aModel.product_id fromViewController:self lastNavigationHidden:NO hiddenBottom:NO];
}

- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath
{
    return 85.f;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _table.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"ShoppingCartCell";
    ShoppingCartCell *cell = (ShoppingCartCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    ProductModel *aModel = [_table.dataArray objectAtIndex:indexPath.row];
    [cell setCellWithModel:aModel];
    
    [cell.selectedButton addTarget:self action:@selector(clickToSelect:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.addButton.tag = kPadding_add + indexPath.row;
    cell.reduceButton.tag = kPadding_reduce + indexPath.row;
    cell.deleteBtn.tag = kPadding_delete + indexPath.row;
    cell.selectedButton.tag = kPadding_select + indexPath.row;

    //默认 yes
    NSString *state = _selectDic[aModel.cart_pro_id];
    cell.selectedButton.selected = [state isEqualToString:@"yes"] ? YES : NO;
    
    [cell.addButton addTarget:self action:@selector(clickToAdd:) forControlEvents:UIControlEventTouchUpInside];

    [cell.reduceButton addTarget:self action:@selector(clickToReduce:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.deleteBtn addTarget:self action:@selector(clickToDelete:) forControlEvents:UIControlEventTouchUpInside];
    
    //监控选中按钮状态以及数量
//    [cell.selectedButton addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
//    [cell.numLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    cell.bgView.left = _isEditing ? -40 : 0;
    
    return cell;
}


#pragma - mark 通知处理

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    
//    if ([keyPath isEqualToString:@"selected"]) {
//        [self updateSumPrice];
//
//    }else if ([keyPath isEqualToString:@"_dataArrayCount"]){
//        
//        [self checkCartIsEmpty];
//    }
//    
//}

@end
