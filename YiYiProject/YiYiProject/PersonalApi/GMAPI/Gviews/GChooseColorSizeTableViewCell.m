//
//  GChooseColorSizeTableViewCell.m
//  YiYiProject
//
//  Created by gaomeng on 15/9/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GChooseColorSizeTableViewCell.h"
#import "GBtn.h"


@implementation GChooseColorSizeTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)loadCustomViewWithIndexPath:(NSIndexPath*)theIndexPath netDatamodel:(NSDictionary *)dic productModel:(ProductModel*)thePmodel{
    //选择button
    GBtn *chooseBtn = [GBtn buttonWithType:UIButtonTypeCustom];
    [chooseBtn setFrame:CGRectMake(0, 8, 35, 44)];
    [chooseBtn setImage:[UIImage imageNamed:@"Ttaixq_xuanze_xuanzhong.png"] forState:UIControlStateSelected];
    [chooseBtn setImage:[UIImage imageNamed:@"Ttaixq_xuanze1.png"] forState:UIControlStateNormal];
    chooseBtn.theIndex = theIndexPath;
    [chooseBtn addTarget:self action:@selector(GchooseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
//    if ([amodel.isChoose[indexPath.row] intValue] == 1) {
//        chooseBtn.selected = YES;
//    }else{
//        chooseBtn.selected = NO;
//    }
//    
    [self.contentView addSubview:chooseBtn];
    
    
//    NSDictionary *product_cover_pic = [dic dictionaryValueForKey:@"product_cover_pic"];
//    NSString *imvUrl = [product_cover_pic stringValueForKey:@"src"];
    
    UIImageView *picImv = [[UIImageView alloc]initWithFrame:CGRectMake(35, 8, 44, 44)];
    [picImv l_setImageWithURL:[NSURL URLWithString:nil] placeholderImage:DEFAULT_YIJIAYI];
    [self.contentView addSubview:picImv];
    
    UILabel *productNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(picImv.frame)+10, picImv.frame.origin.y, DEVICE_WIDTH - CGRectGetMaxX(picImv.frame)-10, picImv.frame.size.height*0.5)];
    productNameLabel.font = [UIFont systemFontOfSize:12];
    productNameLabel.text = @"上衣：白色纯棉";
    [self.contentView addSubview:productNameLabel];
    
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(productNameLabel.frame.origin.x, CGRectGetMaxY(productNameLabel.frame), productNameLabel.frame.size.width, productNameLabel.frame.size.height)];
    priceLabel.font = [UIFont systemFontOfSize:12];
    priceLabel.textColor = RGBCOLOR(249, 165, 196);
    priceLabel.text = @"238";
    [self.contentView addSubview:priceLabel];
}



-(void)GchooseBtnClicked:(GBtn *)sender{

    sender.selected = !sender.selected;
    
//    GTtaiRelationStoreModel *model = _relationStoreArray[sender.theIndex.section];
//    if ([model.isChoose[sender.theIndex.row]intValue] == 1) {
//        model.isChoose[sender.theIndex.row] = @"0";
//    }else{
//        model.isChoose[sender.theIndex.row] = @"1";
//    }
    
    
}

@end
