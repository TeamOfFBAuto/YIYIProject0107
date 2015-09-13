//
//  ConfirmOrderController.m
//  WJXC
//
//  Created by lichaowei on 15/7/18.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ConfirmOrderController.h"
#import "ConfirmInfoCell.h"
#import "ShoppingAddressController.h"//收货地址
#import "AddressModel.h"
#import "ProductModel.h"
#import "FBActionSheet.h"
#import "PayActionViewController.h"//支付页面
#import "ShopModel.h"
#import "CouponModel.h"//优惠劵
#import "ProductBuyCell.h"//单品
#import "OrderOtherInfoCell.h"
#import "CustomInputView.h"//自定义输入框

#define ALIPAY @"支付宝支付"
#define WXPAY  @"微信支付"

@interface ConfirmOrderController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    UITableView *_table;
    NSString *_selectAddressId;//选中的地址
    
    UIImageView *_nameIcon;//名字icon

    UILabel *_nameLabel;//收货人name
    UILabel *_phoneLabel;//收货人电话
    UILabel *_addressLabel;//收货地址
    UIImageView *_phoneIcon;//电话icon
    
    NSString *_payStyle;//支付类型
    
    float _expressFee;//邮费
    UILabel *_priceLabel;//邮费加产品价格
    
    MBProgressHUD *_loading;//加载
    
    UILabel *_addressHintLabel;//收货地址提示
    NSMutableDictionary *_productsDic;//按照shopId分组的字典
    
    NSMutableArray *_shop_arr;//shopModel数组
    
    //原价
    UILabel *_price_original;//原价
    
    //首单减免优惠劵
    CouponModel *_couponModel_first;
    
    CGFloat _priceSum;//记录初始总价
    
    UITextField *_firstTf;//记录当前响应textField
}

@property(nonatomic,strong)CustomInputView * input_view;


@end

@implementation ConfirmOrderController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBarHidden = NO;
    
//    [_input_view addKeyBordNotification];
    
    self.myTitle = @"确认订单";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [_input_view deleteKeyBordNotification];
    
    [self.navigationController setNavigationBarHidden:self.lastPageNavigationHidden animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"确认订单";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 50) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _table.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToHidderkeyboard)];
    tap.delegate = self;
    [_table addGestureRecognizer:tap];
    
    _loading = [LTools MBProgressWithText:@"生成订单中..." addToView:self.view];
    
    [self tableHeaderViewWithAddressModel:nil];
    
    [self getAddressAndFee];//获取收货地址和邮费
    
    [self getUserCouponList];
    
//    [self createInputView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  获取所有shopId数组 价格
 *
 *  @return shopId数组
 */
- (NSArray *)shopIdsArray
{
    NSMutableDictionary *temp = [NSMutableDictionary dictionary];

    for (ProductModel *aModel in self.productArray) {
        [temp setObject:@"shopId" forKey:aModel.product_shop_id];
    }
    return [temp allKeys];
}

- (void)getUserCouponList
{
//    NSMutableDictionary *temp_shopId = [NSMutableDictionary dictionary];//shopid
    NSMutableDictionary *temp_price = [NSMutableDictionary dictionary];//存储shopId对应单品总价格
    NSMutableDictionary *temp_products = [NSMutableDictionary dictionary];//存储shopId对应单品数组

    for (ProductModel *aModel in self.productArray) {
        //id
//        [temp_shopId setObject:@"shopId" forKey:aModel.product_shop_id];
        //价格
        CGFloat price = [aModel.product_price floatValue] * [aModel.product_num intValue];
        CGFloat lastPrice = [[temp_price objectForKey:aModel.product_shop_id] floatValue];
        CGFloat sum = lastPrice + price;
        [temp_price setObject:NSStringFromFloat(sum) forKey:aModel.product_shop_id];
        //单品
        NSArray *products = [temp_products arrayValueForKey:aModel.product_shop_id];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:products];//是否崩溃
        [arr addObject:aModel];
        [temp_products setObject:arr forKey:aModel.product_shop_id];
    }
    
    [self networkForCouponListWithShopIdArray:[temp_products allKeys] totalPricesDic:temp_price productDic:temp_products];
}

#pragma mark - 网络请求

/**
 *  获取可用优惠券
 *
 *  @param shopIds     shopId字符串
 *  @param priceString 总价格字符串
 */
- (void)networkForCouponListWithShopIdArray:(NSArray *)shopIdArray
                             totalPricesDic:(NSDictionary *)priceDic
                                 productDic:(NSDictionary *)productDic{
    
    //店铺对应总价格
    NSMutableArray *priceArray = [NSMutableArray array];
    for (NSString *key in shopIdArray) {
        NSString *temp = [priceDic objectForKey:key];
        [priceArray addObject:temp];
    }
    
    NSString *shopIds = [shopIdArray componentsJoinedByString:@","];
    NSString *priceString = [priceArray componentsJoinedByString:@","];
    NSLog(@"shopIds %@ priceString %@",shopIds,priceString);
    NSDictionary *params = @{@"authcode":[GMAPI getAuthkey],
                             @"total_price":priceString,
                             @"shop_id":shopIds};
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self)weakSelf = self;
    NSString *post = [LTools url:nil withParams:params];
    NSString *api = [NSString stringWithFormat:@"%@&%@",USER_GETCOUPON_LIST,post];
    
    LTools *tool = [[LTools alloc]initWithUrl:api isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        _shop_arr = [NSMutableArray array];
        
        //首单减免优惠劵
        NSDictionary *couponDic_first = [result dictionaryValueForKey:@"newer_coupon"];
        if (couponDic_first && [couponDic_first isKindOfClass:[NSDictionary class]]) {
            
            _couponModel_first = [[CouponModel alloc]initWithDictionary:couponDic_first];
        }
        
        //多个店铺信息和对应优惠劵对应的字典
        NSDictionary *shop_list_Dic = [result dictionaryValueForKey:@"shop_list"];
        
        //通过店铺id 获取对应的店铺信息和优惠劵信息
        for (int i = 0; i < shopIdArray.count; i ++) {
            NSString *shopId = shopIdArray[i];
            
            NSDictionary *shopDic = [shop_list_Dic dictionaryValueForKey:shopId];
            
            NSArray *coupon_list = [shopDic arrayValueForKey:@"coupon_list"];
            NSDictionary *shopinfo = [shopDic dictionaryValueForKey:@"shopinfo"];
            
            NSMutableArray *coupArr = [NSMutableArray arrayWithCapacity:coupon_list.count];
            //获取店铺对应的多个优惠券
            for (NSDictionary *aDic in coupon_list) {
                
                CouponModel *couModel = [[CouponModel alloc]initWithDictionary:aDic];
                [coupArr addObject:couModel];
            }
            
            //店铺id 对应的单品数组
            NSArray *products = [productDic arrayValueForKey:shopId];
            
            ShopModel *shopModel = [[ShopModel alloc]initWithShopId:shopId productsArray:products couponsArray:coupArr mallName:[shopinfo stringValueForKey:@"mall_name"] brandName:[shopinfo stringValueForKey:@"brand_name"] brandLogo:[shopinfo stringValueForKey:@"brand_logo"] totalPrice:[priceDic stringValueForKey:shopId] productNum:NSStringFromInt((int)products.count)];
            //加个单价
            if (products.count) {
                ProductModel *aModel = [products lastObject];
                shopModel.productPrice = aModel.product_price;
            }else
            {
                shopModel.productPrice = @"0";
            }
            
            [_shop_arr addObject:shopModel];
        }
        
        [_table reloadData];
        
        [weakSelf tableViewFooter];
        [weakSelf createBottomView];
        
    } failBlock:^(NSDictionary *result, NSError *erro) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];
}

/**
 *  切换购物地址时 更新邮费
 */
- (void)updateExpressFeeWithAddressId:(NSString *)addressId
{
    NSString *authkey = [GMAPI getAuthkey];
    
    float weight = 0;//总重
    
    NSDictionary *params = @{@"authcode":authkey,
                             @"weight":[NSNumber numberWithFloat:weight],
                             @"address_id":addressId};
    
    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    
//    LTools *tool = [LTools alloc]initWithUrl:<#(NSString *)#> isPost:<#(BOOL)#> postData:<#(NSData *)#>
    
//    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_GET_EXPRESS_FEE parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
//        
//        NSLog(@"更新邮费%@ %@",result[RESULT_INFO],result);
//        float fee = [result[@"fee"]floatValue];
//        _expressFee = fee;
//        [weakSelf updateExpressFeeAndSumPrice:fee];
//        [weakTable reloadData];
//        
//    } failBlock:^(NSDictionary *result) {
//        
//        NSLog(@"更新邮费 失败 %@",result[RESULT_INFO]);
//        
//    }];

}

/**
 *  获取收货地址
 */
- (void)getAddressAndFee
{
    NSString *authkey = [GMAPI getAuthkey];
    
    NSDictionary *params = @{@"authcode":authkey};
//    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    
    NSString *url = [LTools url:ORDER_GET_DEFAULT_ADDRESS withParams:params];
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"获取收货地址 %@",result[RESULT_INFO]);
        NSDictionary *address = result[@"address"];
        AddressModel *aModel = [[AddressModel alloc]initWithDictionary:address];
        [weakSelf setViewsWithModel:aModel];
        
    } failBlock:^(NSDictionary *result, NSError *erro) {
        NSLog(@"获取收货地址和邮费 失败 %@",result[RESULT_INFO]);

    }];

}

/**
 *  生成订单
 */
- (void)postOrderInfo
{
    //    authcode \商品id 多个中间用英文逗号隔开\商品个数 多个中间用英文逗号隔开
    
    NSString *addressId = _selectAddressId;
    if (addressId.length == 0) {
        
        [LTools alertText:@"请选择有效收货地址" viewController:self];
        
        return;
    }
    
    int num = (int)self.productArray.count;
    NSMutableArray *product_ids = [NSMutableArray arrayWithCapacity:num];
    NSMutableArray *product_nums = [NSMutableArray arrayWithCapacity:num];
    NSMutableArray *product_color_ids = [NSMutableArray arrayWithCapacity:num];//colorids
    NSMutableArray *product_size_ids = [NSMutableArray arrayWithCapacity:num];//sizeIds
    NSMutableArray *cart_pro_ids = [NSMutableArray arrayWithCapacity:num];
    for (ProductModel *aModel in self.productArray) {
        
        [product_ids addObject:aModel.product_id];
        [product_nums addObject:aModel.product_num];
        [product_size_ids addObject:aModel.size_id];
        [product_color_ids addObject:aModel.color_id];
        [cart_pro_ids addObject:aModel.cart_pro_id];
    }
    
    NSString *ids = [product_ids componentsJoinedByString:@","];
    NSString *nums = [product_nums componentsJoinedByString:@","];
    NSString *colorIds = [product_color_ids componentsJoinedByString:@","];
    NSString *sizeIds = [product_size_ids componentsJoinedByString:@","];
    NSString *car_ids = [cart_pro_ids componentsJoinedByString:@","];
    
    NSString *authkey = [GMAPI getAuthkey];
    NSString *note = @"";//备注
    NSString *expressFee = @"0";
    
    NSMutableDictionary *coupDic = [NSMutableDictionary dictionary];
    //优惠劵数据
    for (ShopModel *shopModel in _shop_arr) {
        
        if (shopModel.couponModel) {
            CouponModel *c_model = (CouponModel *)shopModel.couponModel;
            [coupDic setObject:c_model.coupon_id forKey:shopModel.product_shop_id];
        }
    }
    
    [_loading show:YES];
    
    
//    product_color_ids 每个商品颜色id 多个用英文逗号隔开（和product_ids有对应关系）
//    product_size_ids 每个商品尺寸id 多个用英文逗号隔开（和product_ids有对应关系）
//    order_note 订单备注
//    product_coupons 优惠券信息 json字符串 字典(key为shopId,value 为优惠劵id)
//    cart_pro_ids 如果从购物车跳转过来的那么就需要传此参数，购物车id，多个用英文逗号隔开 如：100,200,300
    
    NSDictionary *params = @{@"authcode":authkey,
                             @"product_ids":ids,
                             @"product_nums":nums,
                             @"address_id":addressId,
                             @"express_fee":expressFee,//免运费
                             @"product_color_ids":colorIds,
                             @"product_size_ids":sizeIds,
                             @"order_note":note,
                             @"coupons":coupDic ? : @"",
                             @"cart_pro_ids":car_ids};
    
    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    
    NSString *post = [LTools url:nil withParams:params];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    LTools *tools = [[LTools alloc]initWithUrl:ORDER_SUBMIT isPost:YES postData:postData];
    
    [tools requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"提交订单成功 %@",result[RESULT_INFO]);

        [_loading hide:YES];

        NSString *orderId = result[@"order_id"];
        NSString *orderNum = result[@"order_no"];

        //生成订单成功,更新一下购物车
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];

        [weakSelf pushToPayPageWithOrderId:orderId orderNum:orderNum];
        
    } failBlock:^(NSDictionary *result, NSError *erro) {
        NSLog(@"提交订单失败 %@",result[RESULT_INFO]);
        [_loading hide:YES];
    }];
    
//    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:ORDER_SUBMIT parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
//        
//        NSLog(@"提交订单成功 %@",result[RESULT_INFO]);
//        
//        [_loading hide:YES];
//        
//        NSString *orderId = result[@"order_id"];
//        NSString *orderNum = result[@"order_no"];
//        
//        //生成订单成功,更新一下购物车
//        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
//
//        [weakSelf pushToPayPageWithOrderId:orderId orderNum:orderNum];
//        
//    } failBlock:^(NSDictionary *result) {
//        
//        NSLog(@"提交订单失败 %@",result[RESULT_INFO]);
//        
//        [_loading hide:YES];
//
//    }];
}


#pragma mark - 事件处理
/**
 *  判断section是否是显示单品
 *
 *  @param section
 *
 *  @return
 */
- (BOOL)productsSection:(NSInteger)section
{
    if (section > 0 && section <= _shop_arr.count) {
        return YES;
    }
    return NO;
}

/**
 *  判断是否是否是单品IndexPath
 *
 *  @param indexPath
 *
 *  @return
 */
- (BOOL)productIndexPath:(NSIndexPath *)indexPath
{
    ShopModel *shopModel = _shop_arr[indexPath.section - 1];
    if (indexPath.row < shopModel.productsArray.count) {
        
        return YES;
    }
    return NO;
}
//
///**
// *  判断是否是"其他" 部分section
// *
// *  @param section
// *
// *  @return
// */
//- (BOOL)otherSection:(NSInteger)section
//{
//    
//}

- (void)updateExpressFeeAndSumPrice:(CGFloat)express
{
    //产品加邮费
//    NSString *price = [NSString stringWithFormat:@"￥%.2f",self.sumPrice + _expressFee];
//    _priceLabel.text = price;
}

/**
 *  跳转至支付页面
 */
- (void)pushToPayPageWithOrderId:(NSString *)orderId
                        orderNum:(NSString *)orderNum
{
    PayActionViewController *pay = [[PayActionViewController alloc]init];
    pay.orderId = orderId;
    pay.orderNum = orderNum;
//    pay.sumPrice = self.sumPrice + _expressFee;
    pay.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:pay animated:YES];
    
//    self.navigationController.viewControllers
}

- (void)clickToHidderkeyboard
{
    [_firstTf resignFirstResponder];
}

/**
 *  确定订单
 *
 *  @param sender
 */
- (void)clickToConfirmOrder:(UIButton *)sender
{
    //去生成订单
    [self postOrderInfo];
    
    //test

//    [self pushToPayPageWithOrderId:@"1" orderNum:@"11"];
}

/**
 *  选择购物地址
 *
 *  @param sender
 */
- (void)clickToSelectAddress:(UIButton *)sender
{
    __weak typeof(self)wealSelf = self;
    ShoppingAddressController *address = [[ShoppingAddressController alloc]init];
    address.isSelectAddress = YES;
    address.selectAddressId = _selectAddressId;
    address.selectAddressBlock = ^(AddressModel *aModel){
        _selectAddressId = aModel.address_id;
        [wealSelf updateAddressInfoWithModel:aModel];//更新收货地址显示
        [wealSelf updateExpressFeeWithAddressId:aModel.address_id];//更新邮费
    };
    
    [self.navigationController pushViewController:address animated:YES];
}

/**
 *  更新收货地址信息
 *
 *  @param aModel 
 
 */
- (void)updateAddressInfoWithModel:(AddressModel *)aModel
{
    NSLog(@"---address %@",aModel.address);
    
//    UILabel *_nameLabel;//收货人name
//    UILabel *_phoneLabel;//收货人电话
//    UILabel *_addressLabel;//收货地址
    
    _nameLabel.text = aModel.receiver_username;
    
    CGFloat width = [LTools widthForText:_nameLabel.text font:15];
    _nameLabel.width = width;
    
    _phoneIcon.left = _nameLabel.right + 10;
    _phoneLabel.left = _phoneIcon.right + 10;
    _phoneLabel.text = aModel.mobile;
    _addressLabel.text = aModel.address;

    _phoneIcon.hidden = NO;
    _nameIcon.hidden = NO;
    
    if (_addressHintLabel) {
        [_addressHintLabel removeFromSuperview];
        _addressHintLabel = nil;
    }
}

#pragma mark - 创建视图

- (void)createInputView
{
    __weak typeof(self)weakSelf = self;
    
    _input_view = [[CustomInputView alloc] initWithFrame:CGRectMake(0,DEVICE_HEIGHT,DEVICE_WIDTH,44)];
    
    _input_view.userInteractionEnabled = NO;
    
    [_input_view loadAllViewWithPinglunCount:@"0" WithType:0 WithPushBlock:^(int type){
        
        if (type == 0)
        {
            NSLog(@"跳到评论");
            
        }else
        {
            NSLog(@"分类按钮");
        }
        
    } WithSendBlock:^(NSString *content, BOOL isForward) {
        
        NSLog(@"发表评论");
        
        _firstTf.text = content;
        
    }];
    
    [_input_view.send_button setTitle:@"确定" forState:UIControlStateNormal];

    [self.view addSubview:_input_view];
}

/**
 *  底部工具条
 */
- (void)createBottomView
{
    UIView *bottom = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 64 - 50, DEVICE_WIDTH, 50)];
    bottom.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottom];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.5f)];
    line.backgroundColor = [UIColor colorWithHexString:@"e4e4e4"];
    [bottom addSubview:line];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 36, 50) title:@"合计:" font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"303030"]];
    [bottom addSubview:label];
    
    //总价
    _priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right + 10, 5, 150, 20) title:@"" font:12 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR];
    [bottom addSubview:_priceLabel];
    
    //原价
    _price_original = [[UILabel alloc]initWithFrame:CGRectMake(_priceLabel.left, _priceLabel.bottom, _priceLabel.width, _priceLabel.height) title:@"原价" font:11 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"7e7e7e"]];
    [bottom addSubview:_price_original];
    
    UIButton *sureButton = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 15 - 100, 10, 100, 30) buttonType:UIButtonTypeRoundedRect normalTitle:@"提交订单" selectedTitle:nil target:self action:@selector(clickToConfirmOrder:)];
    [sureButton addCornerRadius:3.f];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    sureButton.backgroundColor = DEFAULT_TEXTCOLOR;
    [bottom addSubview:sureButton];
    
    //处理总价
    
    //处理折后价
    
    CGFloat sumPrice = 0.f;
    CGFloat sumPrice_ori = 0.f;
    for (ProductModel *aMode in self.productArray) {
        sumPrice += [aMode.product_price floatValue] * [aMode.product_num intValue];
        sumPrice_ori += [aMode.original_price floatValue] * [aMode.product_num intValue];
    }
    
    NSString *price_ori = [NSString stringWithFormat:@"￥%.2f",sumPrice_ori];
    [_price_original setAttributedText:[LTools attributedUnderlineString:price_ori]];

    //判断是否有收单减优惠劵
    NSString *other = @"";
    if (_couponModel_first) {
        
        other = [NSString stringWithFormat:@"(首单立减￥%@)",_couponModel_first.newer_money];
    }
    
    _priceLabel.text = [NSString stringWithFormat:@"￥%.2f%@",sumPrice,other];

    //记录初始价格
    _priceSum = sumPrice;
}

/**
 *  更新价格 (更改优惠劵,价格跟着变)
 */
- (void)updateSumPrice
{
    CGFloat sum_minus = 0.f;
    for (ShopModel *aModel in _shop_arr) {
        CouponModel *c_model = aModel.couponModel;
        if (c_model) {
            //1满减 2打折 3：新人优惠
            int type = [c_model.type intValue];
            if (type == 1) {
                
                //判断是否满足满减条件
                if ([aModel.total_price floatValue] >= [c_model.full_money floatValue]) {
                    
                    sum_minus += [c_model.minus_money floatValue];//减掉
                }
            }else if (type == 2){
                
                sum_minus += ([aModel.total_price floatValue] * [c_model.discount_num floatValue]);
            }
        }
    }
    
    //判断是否有收单减优惠劵
    NSString *other = @"";
    if (_couponModel_first) {
        
        other = [NSString stringWithFormat:@"(首单立减￥%@)",_couponModel_first.newer_money];
    }
    
    _priceLabel.text = [NSString stringWithFormat:@"￥%.2f%@",_priceSum - sum_minus,other];}


- (void)tableViewFooter
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
    footerView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    _table.tableFooterView = footerView;
}

/**
 *  所有视图赋值
 *
 *  @param aModel
 */
- (void)setViewsWithModel:(AddressModel *)aModel
{
    _selectAddressId = aModel.address_id;
    [self tableHeaderViewWithAddressModel:aModel];
}


- (void)tableHeaderViewWithAddressModel:(AddressModel *)aModel
{
    NSString *name = aModel.receiver_username;
    NSString *phone = aModel.mobile;
    NSString *address = aModel.address;
    
    //是否有收货地址
    BOOL haveAddress = address ? YES : NO;
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 122)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    
    UIImageView *topImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, DEVICE_WIDTH, 3)];
    [headerView addSubview:topImage];
    topImage.image = [UIImage imageNamed:@"shopping cart_dd_top_line"];
    
    UIView *addressView = [[UIView alloc]initWithFrame:CGRectMake(0, topImage.bottom, DEVICE_WIDTH, 100)];
    addressView.backgroundColor = [UIColor colorWithHexString:@"fffaf4"];
    [headerView addSubview:addressView];
    
    //名字icon
    _nameIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 13, 12, 17.5)];
    [addressView addSubview:_nameIcon];
    _nameIcon.image = [UIImage imageNamed:@"shopping cart_dd_top_name"];
    _nameIcon.hidden = !haveAddress;
    
    //名字
    CGFloat aWidth = [LTools widthForText:name font:15];
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(_nameIcon.right + 10, 13, aWidth, _nameIcon.height) title:name font:15.f align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [addressView addSubview:_nameLabel];
    
    //电话icon
    _phoneIcon = [[UIImageView alloc]initWithFrame:CGRectMake(_nameLabel.right + 10, 13, 12, 17.5)];
    [addressView addSubview:_phoneIcon];
    _phoneIcon.image = [UIImage imageNamed:@"shopping cart_dd_top_phone"];
    _phoneIcon.hidden = !haveAddress;
    
    //电话
    _phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(_phoneIcon.right + 10, 13, 120, _nameIcon.height) title:phone font:15.f align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [addressView addSubview:_phoneLabel];
    
    //地址
    _addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, _phoneIcon.bottom + 15, DEVICE_WIDTH - 10 * 4, 40) title:address font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646462"]];
    [addressView addSubview:_addressLabel];
    _addressLabel.numberOfLines = 2;
    _addressLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    //箭头
    UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 40, 0, 40, addressView.height)];
    [addressView addSubview:arrowImage];
    arrowImage.image = [UIImage imageNamed:@"my_jiantou"];
    arrowImage.contentMode = UIViewContentModeCenter;
    
    UIImageView *bottomImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, addressView.bottom, DEVICE_WIDTH, 3)];
    [headerView addSubview:bottomImage];
    bottomImage.image = [UIImage imageNamed:@"shopping cart_dd_top_line"];
    
    if (!haveAddress) {
        
        _addressHintLabel = [[UILabel alloc]initWithFrame:headerView.bounds title:@"请填写收货地址以确保商品顺利到达" font:13 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"646462"]];
        [headerView addSubview:_addressHintLabel];
    }
    
    
    _table.tableHeaderView = headerView;
    
    //点击事件
    [headerView addTaget:self action:@selector(clickToSelectAddress:) tag:0];
    
}

#pragma mark - UITapGestureDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSString *touchViewString = NSStringFromClass([touch.view class]);
    if ([touchViewString isEqualToString:@"UITableViewCellContentView"]) {
        
        return NO;
    }
    
    return YES;
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    [self clickToHidderkeyboard];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"点击商品name = ");

    if (indexPath.section == 1) {
        
        ProductModel *aModel = [self.productArray objectAtIndex:indexPath.row];
        
        NSLog(@"点击商品name = %@",aModel.product_name);
        
//        ProductDetailViewController *cc = [[ProductDetailViewController alloc]init];
//        cc.product_id = aModel.product_id;
//        [self.navigationController pushViewController:cc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 0;
    }
    if ([self productsSection:indexPath.section]) {
        
        if ([self productIndexPath:indexPath]) {
            
            return 85;
        }
        
        //优惠劵 备注部分
        return 276 / 2.f + 4;
    }
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self productsSection:section]) {
        return 50;
    }
    
    return 37.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if ([self productsSection:section]) {
            
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
        view.backgroundColor = [UIColor whiteColor];
        ShopModel *aModel = _shop_arr[section - 1];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
        [view addSubview:imageView];
        [imageView sd_setImageWithURL:[NSURL URLWithString:aModel.brand_logo] placeholderImage:DEFAULT_YIJIAYI];
        
        NSString *title = [NSString stringWithFormat:@"%@-%@",aModel.brand_name,aModel.mall_name];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(imageView.right + 10, 0, DEVICE_WIDTH - 10 - imageView.right - 10, view.height) title:title font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"313131"]];
        [view addSubview:titleLabel];
        
        return view;
    }else
    {
        NSString *title;
        //商品清单
        if (section == 0) {
            title = @"商品清单";
        }else
        {
            title = @"其他";
        }
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 35)];
        
        UIView *redPoint = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 4, 4)];
        redPoint.backgroundColor = DEFAULT_TEXTCOLOR;
        [redPoint addRoundCorner];
        [view addSubview:redPoint];
        redPoint.centerY = view.height/2.f;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(redPoint.right + 8, 0, 100, view.height) title:title font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"9d9d9d"]];
        [view addSubview:label];
        view.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
        
        return view;

    }
    
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self productsSection:section]) {
        ShopModel *aModel = _shop_arr[section - 1];
        return aModel.productsArray.count + 1;
    }
    
    if (section == 0) {
        return 0;
    }else
    {
        return 1;
    }
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self productsSection:indexPath.section]) {
        
        if ([self productIndexPath:indexPath]) {
            
            static NSString *identify = @"ProductBuyCell";
            ProductBuyCell *cell = (ProductBuyCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            ShopModel *shopModel = _shop_arr[indexPath.section - 1];
            
            ProductModel *aModel = [shopModel.productsArray objectAtIndex:indexPath.row];
            
            [cell setCellWithModel:aModel];
            
            return cell;
        }
        
        static NSString *identify = @"OrderOtherInfoCell";
        OrderOtherInfoCell *cell = (OrderOtherInfoCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[OrderOtherInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        ShopModel *shopModel = _shop_arr[indexPath.section - 1];
        [cell setCellWithModel:shopModel];
        
        cell.tf.indexPath = indexPath;
        
        __weak typeof(self)weakSelf = self;
        __weak typeof(tableView)weakTable = tableView;
        //更新优惠劵了
        cell.updateCouponBlock = ^(id model){
          
            if ([model isKindOfClass:[UITextField class]]) {
                
                _firstTf = model;
                
                CustomTextField *textField = model;

                //避免键盘遮挡
                CGPoint origin = textField.frame.origin;
                CGPoint point = [textField.superview convertPoint:origin toView:weakTable];
                float navBarHeight = self.navigationController.navigationBar.frame.size.height;
                CGPoint offset = weakTable.contentOffset;
                // Adjust the below value as you need
                offset.y = (point.y - navBarHeight - 100);
                [weakTable setContentOffset:offset animated:YES];
                
            }else{
                [weakSelf updateSumPrice];
            }
        };
        
        NSLog(@"cellFrame %@",NSStringFromCGRect(cell.frame));
        
        
        return cell;
        
    }
    
//    if (indexPath.section == 0) {
//        
//        static NSString *identify = @"tableCell";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
//        if (!cell) {
//            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
//            _inputTf = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH - 20, 30)];
//            _inputTf.placeholder = @"填写备注";
//            _inputTf.font = [UIFont systemFontOfSize:12];
//            [cell.contentView addSubview:_inputTf];
//            _inputTf.clearButtonMode = UITextFieldViewModeWhileEditing;
//        }
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        
//        return cell;
//    }
    
    
    static NSString *identify = @"ConfirmInfoCell";
    ConfirmInfoCell *cell = (ConfirmInfoCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    if (indexPath.row == 0) {
        
    cell.nameLabel.text = @"运费";
    cell.priceLabel.text = @"免运费";
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _shop_arr.count + 1 + 1;//单品部分、商品清单、其他
}

@end
