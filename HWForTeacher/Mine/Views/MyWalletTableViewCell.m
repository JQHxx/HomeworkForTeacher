//
//  MyWalletTableViewCell.m
//  HWForTeacher
//
//  Created by vision on 2019/9/26.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MyWalletTableViewCell.h"

@interface MyWalletTableViewCell ()

@property (nonatomic,strong) UILabel *amountLab;
@property (nonatomic,strong) UILabel *monthIncomeLab;


@end

@implementation MyWalletTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#F7F7FB"];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(25,10, 180,IS_IPAD?32:20)];
        titleLab.textColor = [UIColor colorWithHexString:@"#303030"];
        titleLab.font = [UIFont mediumFontWithSize:18.0f];
        titleLab.text = @"我的钱包";
        [self.contentView addSubview:titleLab];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-30, 12, 9, 16)];
        imgView.image = [UIImage imageNamed:@"my_arrow_black"];
        [self.contentView addSubview:imgView];
        
        CGFloat viewW = (kScreenWidth-55)/2.0;
        NSArray *titlesArr = @[@"已到手金额",@"本月预计收益"];
        for (NSInteger i=0; i<titlesArr.count; i++) {
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(22+(viewW+11)*i, titleLab.bottom+18, viewW,IS_IPAD?100:78)];
            bgView.backgroundColor = [UIColor whiteColor];
            bgView.layer.cornerRadius = 5.0;
            bgView.layer.shadowColor = [[UIColor blackColor] CGColor];
            bgView.layer.shadowOffset = CGSizeMake(0.5, 0.5);
            bgView.layer.shadowRadius = 5.0;
            bgView.layer.shadowOpacity = 0.15;
            [self addSubview:bgView];
            
            UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(bgView.right-43,bgView.bottom-36, 43, 36)];
            bgImgView.image = [UIImage imageNamed:@"home_profit_today"];
            [self addSubview:bgImgView];
            
            UILabel *dailyTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(bgView.left+10, bgView.top+16, bgView.width-20,IS_IPAD?26:14)];
            dailyTitleLab.text = titlesArr[i];
            dailyTitleLab.font = [UIFont regularFontWithSize:14];
            dailyTitleLab.textColor = [UIColor colorWithHexString:@"#808080"];
            [self addSubview:dailyTitleLab];
            
            UILabel *dailyContentLab = [[UILabel alloc] initWithFrame:CGRectMake(dailyTitleLab.left,dailyTitleLab.bottom+10,dailyTitleLab.width,IS_IPAD?36:25)];
            dailyContentLab.font = [UIFont mediumFontWithSize:25];
            dailyContentLab.textColor = [UIColor colorWithHexString:@"#4C5467"];
            [self addSubview:dailyContentLab];
            if (i==0) {
                self.amountLab = dailyContentLab;
            }else{
                self.monthIncomeLab = dailyContentLab;
            }
        }
        
    }
    return self;
}

-(void)setAmount:(double)amount{
    _amount = amount;
    
    NSString *str1 = [NSString stringWithFormat:@"¥%.2f",amount];
    NSMutableAttributedString *attributeStr1 = [[NSMutableAttributedString alloc] initWithString:str1];
    [attributeStr1 addAttribute:NSFontAttributeName value:[UIFont mediumFontWithSize:14.0f] range:NSMakeRange(0, 1)];
    self.amountLab.attributedText = attributeStr1;
}

-(void)setMonthIncome:(double)monthIncome{
    _monthIncome = monthIncome;
    
    NSString *str1 = [NSString stringWithFormat:@"¥%.2f",monthIncome];
    NSMutableAttributedString *attributeStr1 = [[NSMutableAttributedString alloc] initWithString:str1];
    [attributeStr1 addAttribute:NSFontAttributeName value:[UIFont mediumFontWithSize:14.0f] range:NSMakeRange(0, 1)];
    self.monthIncomeLab.attributedText = attributeStr1;
}

@end
