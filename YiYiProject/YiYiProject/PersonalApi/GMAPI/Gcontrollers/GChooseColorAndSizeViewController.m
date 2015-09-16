//
//  GChooseColorAndSizeViewController.m
//  YiYiProject
//
//  Created by gaomeng on 15/9/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GChooseColorAndSizeViewController.h"
#import "GChooseColorSizeTableViewCell.h"
#import "ConfirmOrderController.h"
#import "GTtaiDetailViewController.h"

@interface GChooseColorAndSizeViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tab;
    NSDictionary *_attrDic;
    
    UILabel *_t_priceLabel;
    UILabel *_o_priceLabel;
}
@end

@implementation GChooseColorAndSizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.myTitle = @"颜色尺码选择";
    
    
    for (ProductModel *model in self.productModelArray) {
        model.isChoose = YES;
        model.ischooseColor = NO;
        model.ischooseSize = NO;
        model.tnum = 1;
    }
    
    
    [self creatTab];
    
    [self creatDownView];

    [self prepareNetData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)creatDownView{
    UIView *downView = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT-64 - 50, DEVICE_WIDTH, 50)];
    downView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:downView];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = [UIColor grayColor];
    [downView addSubview:line];
    
    UIButton *quedingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [quedingBtn setFrame:CGRectMake(DEVICE_WIDTH - 80, (50-30)*0.5, 70, 30)];
    [quedingBtn setTitle:@"确定" forState:UIControlStateNormal];
    quedingBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [quedingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [quedingBtn setBackgroundColor:RGBCOLOR(244, 76, 138)];
    quedingBtn.layer.cornerRadius = 15;
    [downView addSubview:quedingBtn];
    
    [quedingBtn addTarget:self action:@selector(quedingBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    //总价
    _t_priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 11, quedingBtn.frame.origin.x - 10, 12)];
    _t_priceLabel.font = [UIFont systemFontOfSize:12];
//    _t_priceLabel.backgroundColor = [UIColor orangeColor];
    [downView addSubview:_t_priceLabel];
    
    //原价
    _o_priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(_t_priceLabel.frame)+5, _t_priceLabel.frame.size.width, 12)];
    _o_priceLabel.font = [UIFont systemFontOfSize:12];
//    _o_priceLabel.backgroundColor = [UIColor purpleColor];
    [downView addSubview:_o_priceLabel];
    
    
    [self jisuanPrice];
    
    
}


#pragma mark - MyMethod


-(void)quedingBtnClicked{
    NSLog(@"%s",__FUNCTION__);
    
    
    NSMutableArray *resultProducts = [NSMutableArray arrayWithCapacity:1];
    for (ProductModel *model in self.productModelArray) {
        
        NSLog(@"model.ischoose %d",model.isChoose);
        if (model.isChoose) {
            NSLog(@"pid %@",model.product_id);
            NSLog(@"pname %@",model.product_name);
            NSLog(@"colorName %@  colorId %@",model.colorDic[@"color_name"],model.colorDic[@"color_id"]);
            NSLog(@"sizeName %@  sizeid %@",model.sizeDic[@"size_name"],model.sizeDic[@"size_id"]);
            NSLog(@"num %ld",(long)model.tnum);
            
            model.product_num = [NSString stringWithFormat:@"%ld",(long)model.tnum];
            model.color = model.colorDic[@"color_name"];
            model.color_id = model.colorDic[@"color_id"];
            model.size = model.sizeDic[@"size_name"];
            model.size_id = model.sizeDic[@"size_id"];
            model.small_cover_pic = model.product_cover_pic;
            
            
            [resultProducts addObject:model];
        }
        
    }
    
    NSLog(@"resultProducts.count------------%ld",resultProducts.count);
    if (resultProducts.count == 0) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请勾选您需要的商品" addToView:self.view];
    }
    
    
    
    if (self.theType == CHOOSETYPE_GOUWUCHE) {//购物车
        
        NSMutableArray *productIds = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *colorIds = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *sizeIds = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *pnums = [NSMutableArray arrayWithCapacity:1];
        
        for (ProductModel *model in resultProducts) {
            [productIds addObject:model.product_id];
            [colorIds addObject:model.color_id];
            [sizeIds addObject:model.size_id];
            [pnums addObject:model.product_num];
            
        }
        
        NSString *productsIds_str = [productIds componentsJoinedByString:@","];
        NSString *colorIds_str = [colorIds componentsJoinedByString:@","];
        NSString *sizeIds_str = [sizeIds componentsJoinedByString:@","];
        NSString *pnum_str = [pnums componentsJoinedByString:@","];
        
        [self netWorkForAddProductToShoppingCarProductId:productsIds_str colorId:colorIds_str sizeId:sizeIds_str num:pnum_str];
        
        
        
    }else if (self.theType == CHOOSETYPE_LIJIGOUMAI){//立即购买 跳转订单
        
        if (self.lastVc) {
            [self.lastVc.navigationController popViewControllerAnimated:NO];
            ConfirmOrderController *confirm = [[ConfirmOrderController alloc]init];
            confirm.productArray = resultProducts;
            [self.lastVc.navigationController pushViewController:confirm animated:YES];
        }else{
            ConfirmOrderController *confirm = [[ConfirmOrderController alloc]init];
            confirm.productArray = resultProducts;
            [self.navigationController pushViewController:confirm animated:YES];
        }
        
        
        
    }
    
    
}


/**
 *  加入到购物车
 */
- (void)netWorkForAddProductToShoppingCarProductId:(NSString *)productId
                                           colorId:(NSString *)colorId
                                            sizeId:(NSString *)sizeId
                                               num:(NSString *)pnum
{
    
    
    NSDictionary *params = @{@"authcode":[GMAPI getAuthkey],
                             @"product_id":productId,
                             @"color_id":colorId,
                             @"size_id":sizeId,
                             @"product_num":pnum
                             };
    
    NSLog(@"添加购物车postdata%@",params);
    
    NSString *api = ORDER_ADD_TO_CART;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *post = [LTools url:nil withParams:params];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    LTools *tool = [[LTools alloc]initWithUrl:api isPost:YES postData:postData];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"-->%@",result);
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [GMAPI showAutoHiddenMBProgressWithText:[result stringValueForKey:@"msg"] addToView:self.view];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATON_UPDATESHOPCAR_NUM object:nil];
        
        [self performSelector:@selector(goPop) withObject:self afterDelay:1.2];
        
        
    } failBlock:^(NSDictionary *result, NSError *erro) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];
}

-(void)goPop{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-64-50) style:UITableViewStylePlain];
    _tab.delegate = self;
    _tab.dataSource = self;
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tab];
}

-(void)prepareNetData{
    
    if (self.productModelArray.count>0) {
        NSMutableArray *idsArray = [NSMutableArray arrayWithCapacity:1];
        for (ProductModel *model in self.productModelArray) {
            [idsArray addObject:model.product_id];
        }
        NSString *theIds =[idsArray componentsJoinedByString:@","];
        
        NSString *url = [NSString stringWithFormat:@"%@&product_ids=%@",CHOOSE_COLORANDSIZE,theIds];
        
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        LTools *cc = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
        [cc requestCompletion:^(NSDictionary *result, NSError *erro) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            _attrDic = [result dictionaryValueForKey:@"attr"];
            
            for (ProductModel *model in self.productModelArray) {
                NSDictionary *ccc = [_attrDic dictionaryValueForKey:model.product_id];
                NSArray *colorArray = [ccc arrayValueForKey:@"color"];
                NSArray *sizeArray = [ccc arrayValueForKey:@"size"];
                if (colorArray.count>0) {
                    model.colorDic = colorArray[0];
                }else{
                    model.colorDic = @{
                                       @"color_id":@"0",
                                       @"color_name":@"0"
                                       };
                }
                
                if (sizeArray.count>0) {
                    model.sizeDic = sizeArray[0];
                    
                }else{
                    model.sizeDic = @{
                                       @"size_id":@"0",
                                       @"size_name":@"0"
                                       };
                }
            }
            
            
            
            [_tab reloadData];
        } failBlock:^(NSDictionary *result, NSError *erro) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
        
        
    }else{
        
    }
}



#pragma mark - UITableViewDelegate && UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    GChooseColorSizeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GChooseColorSizeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    cell.delegate = self;
    
    [cell loadCustomViewWithIndexPath:indexPath netDatamodel:_attrDic];
    
    
    
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.productModelArray.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 260;
}



-(void)jisuanPrice{
    CGFloat t_price = 0;
    CGFloat o_price = 0;
    
    for (ProductModel *model in self.productModelArray) {
        
        if (model.isChoose) {
            CGFloat p = [model.product_price floatValue];
            t_price += p;
            
            CGFloat o_p = [model.original_price floatValue];
            o_price += o_p;
        }
        
    }
    
    _t_priceLabel.text = [NSString stringWithFormat:@"总计：￥%.2f",t_price];
    NSString *o_price_str = [NSString stringWithFormat:@"￥%.2f",o_price];
    
    NSMutableAttributedString  *yyy = [[NSMutableAttributedString alloc]initWithString:o_price_str];
    [yyy addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(1, o_price_str.length-1)];
    _o_priceLabel.textColor = RGBCOLOR(81, 82, 83);
    _o_priceLabel.attributedText = yyy;
}




@end
