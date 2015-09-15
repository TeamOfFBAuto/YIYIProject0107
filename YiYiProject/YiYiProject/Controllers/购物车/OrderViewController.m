//
//  OrderViewController.m
//  WJXC
//
//  Created by lichaowei on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "OrderViewController.h"
#import "OrderCell.h"
#import "OrderModel.h"
#import "PayActionViewController.h"//支付页面
#import "OrderInfoViewController.h"//订单详情
#import "ConfirmOrderController.h"//确认订单
#import "RefreshTableView.h"
#import "TuiKuanViewController.h"//退款页面

#define kPadding_Pay 1000 //去支付
#define kPadding_Refund 2000 //退款
#define kPadding_Confirm 3000 //确认收货
#define kPadding_BuyAgain  4000 //再次购买

//获取对应tableView
#define TABLEVIEW_TAG_DaiFu 0 //待付款
#define TABLEVIEW_TAG_DaiFaHuo 1 //待发货
#define TABLEVIEW_TAG_PeiSong 2 //配送中
#define TABLEVIEW_TAG_WanCheng 3 //完成
#define TABLEVIEW_TAG_TuiHuan 4 //退换

@interface CustomeAlertView : UIAlertView

@property(nonatomic,retain)id object;//参数

@end

@implementation CustomeAlertView


@end

@interface OrderViewController ()<RefreshDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    int _buttonNum;//button个数
    UIView *_indicator;//指示器
    UIScrollView *_scroll;
}

@end

@implementation OrderViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if (self.lastPageNavigationHidden) {
//        self.navigationController.navigationBarHidden = NO;
//        return;
//    }
//    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"我的订单";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    NSArray *titles = @[@"待付款",@"待发货",@"配送中",@"已完成",@"退换"];
    int count = (int)titles.count;
    CGFloat width = DEVICE_WIDTH / count;
    _buttonNum = count;
    
    _scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 40, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 40)];
    _scroll.delegate = self;
    _scroll.contentSize = CGSizeMake(DEVICE_WIDTH * count, _scroll.height);
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.pagingEnabled = YES;
    [self.view addSubview:_scroll];
    
    //scrollView 和 系统手势冲突问题
    [_scroll.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    
    for (int i = 0; i < count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        btn.tag = 100 + i;
        btn.frame = CGRectMake(width * i, 0, width, 40);
        [btn setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
        [btn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateSelected];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn addTarget:self action:@selector(clickToSelect:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor whiteColor];
        btn.selected = YES;
        
        RefreshTableView *_table = [[RefreshTableView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH * i, 0, DEVICE_WIDTH,_scroll.height)];
        _table.refreshDelegate = self;
        _table.dataSource = self;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_scroll addSubview:_table];
        _table.tag = 200 + i;
        
        [_table showRefreshHeader:YES];
        

        [_table reloadData:nil pageSize:10 noDataView:[self noDataView]];

    }
    
    _indicator = [[UIView alloc]initWithFrame:CGRectMake(0, 38, width, 2)];
    _indicator.backgroundColor = DEFAULT_TEXTCOLOR;
    [self.view addSubview:_indicator];
    
    //默认选中第一个
    [self controlSelectedButtonTag:100];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForPaySuccess:) name:NOTIFICATION_PAY_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForRecieveConfirm:) name:NOTIFICATION_RECIEVE_CONFIRM object:nil];//确认收货
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForCancelOrder:) name:NOTIFICATION_ORDER_CANCEL object:nil];//取消订单
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForDelOrder:) name:NOTIFICATION_ORDER_DEL object:nil];//删除订单

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 通知处理

/**
 *  支付成功通知
 *
 *  @param notify
 */
- (void)notificationForPaySuccess:(NSNotification *)notify
{
    //支付成功 更新
    
    [[self refreshTableForIndex:TABLEVIEW_TAG_DaiFu]showRefreshHeader:YES];//待付款
    [[self refreshTableForIndex:TABLEVIEW_TAG_DaiFaHuo]showRefreshHeader:YES];//待发货
}

/**
 *  确认收货通知
 */
- (void)notificationForRecieveConfirm:(NSNotification *)notify
{
    [[self refreshTableForIndex:TABLEVIEW_TAG_PeiSong]showRefreshHeader:YES];//配送
    [[self refreshTableForIndex:TABLEVIEW_TAG_WanCheng]showRefreshHeader:YES];//完成
}

/**
 *  取消订单通知 只有待付款可以取消订单
 */
- (void)notificationForCancelOrder:(NSNotification *)notify
{
    [[self refreshTableForIndex:TABLEVIEW_TAG_DaiFu]showRefreshHeader:YES];//待付款
}

/**
 *  删除订单通知 完成的可以删除
 */
- (void)notificationForDelOrder:(NSNotification *)notify
{
    [[self refreshTableForIndex:TABLEVIEW_TAG_WanCheng]showRefreshHeader:YES];//待评价
}

#pragma - mark 网络请求

/**
 *  获取订单列表
 *
 *  @param orderType 不同的订单状态
 */
- (void)getOrderListWithStatus:(ORDERTYPE)orderType
{
//    authcode
//    status 我的订单状态（no_pay待付款，deliver配送中，no_comment待评价，complete已完成）
    NSString *authey = [GMAPI getAuthkey];
    if (authey.length == 0) {
        return;
    }
    NSString *status = nil;
    switch (orderType) {
        case ORDERTYPE_DaiFu:
            status = @"no_pay";
            break;
        case ORDERTYPE_PeiSong:
            status = @"deliver";
            break;
        case ORDERTYPE_DaiFaHuo:
            status = @"no_deliver";
            break;
        case ORDERTYPE_WanCheng:
            status = @"complete";
            break;
        case ORDERTYPE_TuiHuan:
            status = @"refund";
            break;
        default:
            break;
    }
    __weak typeof(RefreshTableView)*weakTable = [self refreshTableForIndex:orderType - 1];

    NSDictionary *params = @{@"authcode":authey,
                             @"status":status,
                             @"per_page":[NSNumber numberWithInt:10],
                             @"page":[NSNumber numberWithInt:weakTable.pageNum]};
    
    NSString *url = [LTools url:nil withParams:params];
    url = [NSString stringWithFormat:@"%@&%@",ORDER_GET_MY_ORDERS,url];
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSArray *list = result[@"list"];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:list.count];
        for (NSDictionary *aDic in list) {

            OrderModel *aModel = [[OrderModel alloc]initWithDictionary:aDic];
            [temp addObject:aModel];
        }

        [weakTable reloadData:temp pageSize:10 noDataView:[self noDataView]];
        
    } failBlock:^(NSDictionary *result, NSError *erro) {
        
        [weakTable reloadData:nil pageSize:10 noDataView:[self noDataView]];
    }];
}

/**
 *  没有数据自定义view
 *
 *  @return
 */
- (UIView *)noDataView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 135)];
    view.backgroundColor = [UIColor clearColor];
    //图标
    
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 73, 80)];
    imageV.image = [UIImage imageNamed:@"my_indent_no"];
    [view addSubview:imageV];
    imageV.centerX = view.width/2.f;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, imageV.bottom + 20, DEVICE_WIDTH, 30) title:@"您还没有相关订单哦" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"646464"]];
    [view addSubview:label];
    
    return view;
}

/**
 *  没有数据自定义view
 *
 *  @return
 */
- (UIView *)erroView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 135)];
    view.backgroundColor = [UIColor clearColor];
    //图标
    
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 73, 80)];
    imageV.image = [UIImage imageNamed:@"my_indent_no"];
    [view addSubview:imageV];
    imageV.centerX = view.width/2.f;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, imageV.bottom + 20, DEVICE_WIDTH, 30) title:@"您还没有相关订单哦" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"646464"]];
    [view addSubview:label];
    
    return view;
}

#pragma - mark 事件处理

/**
 *  再次购买
 *
 *  @param sender
 */
- (void)buyAgain:(OrderModel *)order
{
    //先返回购物车,然后
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:order.products.count];
    for (NSDictionary *aDic in order.products) {
        
        ProductModel *aModel = [[ProductModel alloc]initWithDictionary:aDic];
        [temp addObject:aModel];
    }
    NSArray *productArr = temp;
    ConfirmOrderController *confirm = [[ConfirmOrderController alloc]init];
    confirm.productArray = productArr;
//    confirm.sumPrice = [order.total_fee floatValue];
    [self.navigationController pushViewController:confirm animated:YES];
    
}


/**
 *  去支付 确认收货 评价 再次购买
 *
 *  @param sender
 */
- (void)clickToAction:(UIButton *)sender
{
    int index = (int)sender.tag;
    
    int kadding = 0;
    
    if (index >= kPadding_BuyAgain) {
        //再次购买
        kadding = kPadding_BuyAgain;
        OrderModel *aModel = [[self refreshTableForIndex:3].dataArray objectAtIndex:index - kadding];
        [self buyAgain:aModel];
        
    }else if (index >= kPadding_Confirm){
        
        //确认收货
        kadding = kPadding_Confirm;
        NSString *msg = [NSString stringWithFormat:@"收货成功之后再确定,避免不必要损失!"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"确认收货" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = index - kPadding_Refund;
        [alert show];
        
    }else if (index >= kPadding_Refund){

        kadding = kPadding_Refund;
        OrderModel *aModel = [[self refreshTableForIndex:1].dataArray objectAtIndex:index - kadding];
        TuiKuanViewController *tuiKuan = [[TuiKuanViewController alloc]init];
        tuiKuan.tuiKuanPrice = [aModel.real_product_total_price floatValue];
        tuiKuan.orderId = aModel.order_id;
        [self.navigationController pushViewController:tuiKuan animated:YES];
        
    }else if (index >= kPadding_Pay){
        //支付
        kadding = kPadding_Pay;
        OrderModel *aModel = [[self refreshTableForIndex:0].dataArray objectAtIndex:index - kPadding_Pay];
        [self pushToPayPageWithOrderId:aModel.order_id orderNum:aModel.order_no sumPrice:[aModel.total_fee floatValue] payStyle:[aModel.pay_type intValue]];
        
    }
    
}

/**
 *  跳转至支付页面
 */
- (void)pushToPayPageWithOrderId:(NSString *)orderId
                        orderNum:(NSString *)orderNum
                        sumPrice:(CGFloat)sumPrice
                        payStyle:(int)payStyle
{
    PayActionViewController *pay = [[PayActionViewController alloc]init];
    pay.orderId = orderId;
    pay.orderNum = orderNum;
    pay.sumPrice = sumPrice;
    pay.payStyle = payStyle;
    [self.navigationController pushViewController:pay animated:YES];
}

/**
 *  获取button 根据tag
 */
- (UIButton *)buttonForTag:(int)tag
{
    return (UIButton *)[self.view viewWithTag:tag];
}

/**
 *  根据下标来获取tableView
 *
 *  @param index 下标 1，2，3，4
 */
- (RefreshTableView *)refreshTableForIndex:(int)index
{
    return (RefreshTableView *)[self.view viewWithTag:index + 200];
}

/**
 *  控制button选中状态
 */
- (void)controlSelectedButtonTag:(int)tag
{
    for (int i = 0; i < _buttonNum; i ++) {

        [self buttonForTag:100 + i].selected = (i + 100 == tag) ? YES : NO;
    }
    
    __weak typeof(_indicator)weakIndicator = _indicator;
    [UIView animateWithDuration:0.1 animations:^{
       
        weakIndicator.left = DEVICE_WIDTH / _buttonNum * (tag - 100);
    }];
}

/**
 *  点击button
 *
 *  @param sender
 */
- (void)clickToSelect:(UIButton *)sender
{
    [self controlSelectedButtonTag:(int)sender.tag];
    
    __weak typeof(_scroll)weakScroll = _scroll;
    [UIView animateWithDuration:0.1 animations:^{
       
        [weakScroll setContentOffset:CGPointMake(DEVICE_WIDTH * (sender.tag - 100), 0)];
    }];
}

#pragma - mark 视图创建

#pragma - 代理

#pragma - mark UIAlertViewDelegate <NSObject>
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        NSString *authey = [GMAPI getAuthkey];

        OrderModel *aModel = [[self refreshTableForIndex:1].dataArray objectAtIndex:alertView.tag];
        
        __weak typeof(RefreshTableView)*weakTable = [self refreshTableForIndex:TABLEVIEW_TAG_PeiSong];
        __weak typeof(RefreshTableView)*weakTable2 = [self refreshTableForIndex:TABLEVIEW_TAG_WanCheng];
        
        NSDictionary *params = @{@"authcode":authey,
                                 @"order_id":aModel.order_id};
        NSString *url = [LTools url:ORDER_RECEIVING_CONFIRM withParams:params];
        LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
        [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
            NSLog(@"result确认收货 %@",result);
            //刷新配送中列表
            [weakTable showRefreshHeader:YES];
            //刷新完成列表
            [weakTable2 showRefreshHeader:YES];
            
        } failBlock:^(NSDictionary *result, NSError *erro) {
            
        }];
    }
}


#pragma mark - RefreshDelegate

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    int tableTag = (int)tableView.tag - 200 + 1;
    
    [self getOrderListWithStatus:tableTag];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    int tableTag = (int)tableView.tag - 200 + 1;
    
    [self getOrderListWithStatus:tableTag];
}

//新加
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    OrderModel *aModel = [((RefreshTableView *)tableView).dataArray objectAtIndex:indexPath.row];

    OrderInfoViewController *orderInfo = [[OrderInfoViewController alloc]init];
    orderInfo.order_id = aModel.order_id;
    [self.navigationController pushViewController:orderInfo animated:YES];
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
//    return 372/2.f;
    OrderModel *aModel = [((RefreshTableView *)tableView).dataArray objectAtIndex:indexPath.row];
    return [OrderCell heightForAddress:aModel.address];
}

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma - mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RefreshTableView *refreshTable = (RefreshTableView *)tableView;
    return refreshTable.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"OrderCell";
    OrderCell *cell = (OrderCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    RefreshTableView *table = (RefreshTableView *)tableView;
    
    NSString *text = @"";
    
    int refund_status = 0;
    
    if (indexPath.row < table.dataArray.count) {
        
        OrderModel *aModel = [table.dataArray objectAtIndex:indexPath.row];
        [cell setCellWithModel:aModel];
        
        
        refund_status = [aModel.refund_status intValue];
        
        //代表有退款状态
        if (refund_status > 0) {
            
            if (refund_status == 1 || refund_status == 2) {
                text = @"退款中";
            }else if (refund_status == 3){
                text = @"退款成功";
            }else if (refund_status == 4 || refund_status == 5){
                text = @"退款失败";
            }
            
        }
    }
    
    int tableViewTag = (int)tableView.tag;
    switch (tableViewTag) {
        case 200:
        {
            [cell.commentButton setTitle:@"去支付" forState:UIControlStateNormal];
            cell.commentButton.tag = kPadding_Pay + indexPath.row;
        }
            break;
        case 201:
        {
            [cell.commentButton setTitle:@"申请退款" forState:UIControlStateNormal];
            cell.commentButton.tag = kPadding_Refund + indexPath.row;

        }
            break;
        case 202:
        {
            [cell.commentButton setTitle:@"确认收货" forState:UIControlStateNormal];
            cell.commentButton.tag = kPadding_Confirm + indexPath.row;
        }
            break;
        case 203:
        {
            [cell.commentButton setTitle:@"再次购买" forState:UIControlStateNormal];
            cell.commentButton.tag = kPadding_BuyAgain + indexPath.row;
        }
            break;
        case 204:
        {
            [cell.commentButton setTitle:text forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    
    [cell.commentButton addTarget:self action:@selector(clickToAction:) forControlEvents:UIControlEventTouchUpInside];
        
    return cell;
}

#pragma - mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
        
    int page = floor((scrollView.contentOffset.x - DEVICE_WIDTH / 2) / DEVICE_WIDTH) + 1;//只要大于半页就算下一页
    NSLog(@"page %d",page);
    //选中状态
    [self controlSelectedButtonTag:page + 100];
    
}


@end
