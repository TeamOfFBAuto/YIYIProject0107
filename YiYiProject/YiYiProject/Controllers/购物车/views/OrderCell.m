//
//  OrderCell.m
//  WJXC
//
//  Created by lichaowei on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "OrderCell.h"
#import "OrderModel.h"
#import "ProductModel.h"

@implementation OrderCell

- (void)awakeFromNib {
    // Initialization code
    [self.commentButton setBorderWidth:0.5 borderColor:DEFAULT_TEXTCOLOR];
    [self.commentButton addCornerRadius:3.f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)heightForAddress:(NSString *)address
{
    CGFloat height = [LTools heightForText:address width:DEVICE_WIDTH - 20 font:14];
 
    return 89 + height + 10 + 10 + 50;
}

- (void)setCellWithModel:(OrderModel *)aModel
{
    //只有一个商品
    
    int productNum = (int)aModel.products.count;
    
    if (productNum == 1) {
        
        ProductModel *product = [[ProductModel alloc]initWithDictionary:[aModel.products lastObject]];
        
        NSString *imageUrl = [product.small_cover_pic stringValueForKey:@"src"];

        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:DEFAULT_YIJIAYI];
        self.titleLabel.text = product.product_name;
        _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _titleLabel.numberOfLines = 2;
        CGFloat height = [LTools heightForText:product.product_name width:_titleLabel.width font:14];
        _titleLabel.height = height;
        
        self.numLabel.text = [NSString stringWithFormat:@"x%d",[product.product_num intValue]];
        self.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[product.product_price floatValue]];;

        if (self.contentScroll) {
            
            for (UIView *aView in _contentScroll.subviews) {
                
                [aView removeFromSuperview];
            }
            
            [_contentScroll removeFromSuperview];
            _contentScroll = nil;
        }
     
    //好多商品
    }else if (productNum > 1){
        
        
        [self.iconImageView sd_setImageWithURL:nil];
        self.titleLabel.text = @"";
        self.numLabel.text = @"";
        self.priceLabel.text = @"";
        
        if (!self.contentScroll) {
            self.contentScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 10, DEVICE_WIDTH - 20, 60)];
            _contentScroll.contentSize = CGSizeMake(productNum * (60 + 10), 60);
            [self.contentView addSubview:_contentScroll];
            
            for (int i = 0; i < productNum; i ++) {
                
                ProductModel *product = [[ProductModel alloc]initWithDictionary:[aModel.products objectAtIndex:i]];

                NSString *imageUrl = [product.small_cover_pic stringValueForKey:@"src"];
                UIImageView *aImageView = [[UIImageView alloc]initWithFrame:CGRectMake((60 + 10) * i, 0, 60, 60)];
                [aImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:DEFAULT_YIJIAYI];
                [_contentScroll addSubview:aImageView];
            }
        }
    }
    
    NSString *address = [NSString stringWithFormat:@"配送地址:%@",aModel.address];
    self.addressLabel.text = address;
    _addressLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _addressLabel.numberOfLines = 2;
    CGFloat height = [LTools heightForText:address width:DEVICE_WIDTH - 20 font:14];
    _addressLabel.height = height;
    self.realPriceLabel.text = [NSString stringWithFormat:@"￥%.2f",[aModel.total_fee floatValue]];
    self.infoView.top = _addressLabel.bottom + 10;
    self.backView.height = _infoView.bottom;
}

@end
