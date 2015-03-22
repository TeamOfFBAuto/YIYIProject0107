//
//  CustomSegmentView.m
//  FbLife
//
//  Created by soulnear on 13-7-9.
//  Copyright (c) 2013年 szk. All rights reserved.
//

#import "CustomSegmentView.h"

@implementation CustomSegmentView
@synthesize currentPage = _currentPage;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _currentPage = 0;
    }
    return self;
}


-(void)setDelegate:(id<CustomSegmentViewDelegate>)delegate1
{
    delegate = delegate1;
}


-(void)setAllViewWithArray:(NSArray *)array 
{
    for (int i = 0;i < array.count/2;i++)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
                
        button.backgroundColor = [UIColor clearColor];
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = [RGBCOLOR(233, 79, 106)CGColor];
                
        button.adjustsImageWhenHighlighted = NO;
        
        button.frame = CGRectMake(0+self.frame.size.width/(array.count/2)*i,0,self.frame.size.width/(array.count/2),self.frame.size.height);
        
        [button setBackgroundImage:[UIImage imageNamed:[array objectAtIndex:(i+array.count/2)]] forState:UIControlStateSelected];
        
        [button setBackgroundImage:[UIImage imageNamed:[array objectAtIndex:i]] forState:UIControlStateNormal];
        
        if (_currentPage == i)
        {
            button.selected = YES;
        }
     
        button.tag = 1+i;
        
        [button addTarget:self action:@selector(doButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
    }
}
-(void)settitleWitharray:(NSArray *)arrayname{
    
    for (int i=0; i<arrayname.count; i++) {
        UIButton *button_=(UIButton *)[self viewWithTag:(i+1)];
        button_.titleLabel.font=[UIFont systemFontOfSize:13];
        [button_ setTitle:[NSString stringWithFormat:@"%@",[arrayname objectAtIndex:i]] forState:UIControlStateNormal];
        if (i==0) {
            [button_ setTitleColor:RGBCOLOR(233, 79, 106) forState:UIControlStateNormal];
            [button_ setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];


        }else{
            [button_ setTitleColor:RGBCOLOR(233, 79, 106) forState:UIControlStateNormal];
            [button_ setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];

        }
    }
}
-(void)doButton:(UIButton *)button
{
    UIButton * button1 = (UIButton *)[self viewWithTag:(_currentPage+1)];
    [button1 setTitleColor:RGBCOLOR(233, 79, 106) forState:UIControlStateNormal];
    button1.selected = NO;
    
    button.selected = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _currentPage = button.tag-1;
    
    
    if (delegate && [delegate respondsToSelector:@selector(buttonClick:)])
    {
        [delegate buttonClick:_currentPage];
    }
    
    
}





@end
