//
//  DetailsTableViewCell.m
//  HWForTeacher
//
//  Created by vision on 2019/9/26.
//  Copyright © 2019 vision. All rights reserved.
//

#import "DetailsTableViewCell.h"

@interface DetailsTableViewCell ()

@property (strong, nonatomic) UIImageView    *headImgView;         //头像
@property (strong, nonatomic) UILabel        *nameLabel;         //姓名
@property (strong, nonatomic) UILabel        *dateLab;           //日期
@property (strong, nonatomic) UILabel        *payLab;            //付费
@property (strong, nonatomic) UILabel        *commissionLab;     //提成

@end

@implementation DetailsTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.headImgView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.dateLab];
        [self.contentView addSubview:self.payLab];
        [self.contentView addSubview:self.commissionLab];
    }
    return self;
}

#pragma mark 填充数据
-(void)displayCellWithDetails:(DetailsModel *)detailsModel type:(NSInteger)type{
    if (kIsEmptyString(detailsModel.cover)) {
       [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
       [self.headImgView sd_setImageWithURL:[NSURL URLWithString:detailsModel.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    self.nameLabel.text = detailsModel.name;
    self.dateLab.text = [[ZYHelper sharedZYHelper] timeWithTimeIntervalNumber:detailsModel.create_time format:@"yyyy-MM-dd"];
    
    if (type==0) { //预计收益
        if ([detailsModel.type integerValue]==1||[detailsModel.type integerValue]==2) { //辅导、提成
            self.payLab.text = [NSString stringWithFormat:@"付费：¥%.2f", [detailsModel.pay_money doubleValue]];
            self.commissionLab.text = [NSString stringWithFormat:@"%@：+%.2f" ,[detailsModel.type integerValue]==1?@"辅导费":@"提成",[detailsModel.money doubleValue]];
            self.commissionLab.textColor = [UIColor commonColor_red];
        }else{
            self.payLab.text = [detailsModel.type integerValue]==3?@"转班":@"请假";
            self.commissionLab.text = [NSString stringWithFormat:@"辅导费：-%.2f" ,[detailsModel.money doubleValue]];
            self.commissionLab.textColor = [UIColor colorWithHexString:@"#303030"];
        }
    }else if (type==1){ //提成收益
        self.payLab.text = [NSString stringWithFormat:@"%@：%.2f",[detailsModel.status integerValue]==1?@"付费":@"退费", [detailsModel.pay_money doubleValue]];
        self.commissionLab.text = [NSString stringWithFormat:@"提成：%@%.2f" ,[detailsModel.status integerValue]==1?@"+":@"-",[detailsModel.money doubleValue]];
        self.commissionLab.textColor = [detailsModel.status integerValue]==1?[UIColor colorWithHexString:@"#303030"]:[UIColor commonColor_red];
    }else{ //已到手金额
        self.payLab.text = [NSString stringWithFormat:@"付费：¥%.2f",[detailsModel.pay_money doubleValue]];
        self.commissionLab.text = [NSString stringWithFormat:@"%@：+%.2f",[detailsModel.type integerValue]==1?@"日辅导":@"日提成",[detailsModel.money doubleValue]];
        self.commissionLab.textColor = [UIColor commonColor_red];
    }
}

#pragma mark -- Getters
#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:IS_IPAD?CGRectMake(20, 20, 60, 60):CGRectMake(18, 16, 34, 34)];
        [_headImgView setBorderWithCornerRadius:IS_IPAD?30:17 type:UIViewCornerTypeAll];
    }
    return _headImgView;
}

#pragma mark 姓名
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+12,13, 160,IS_IPAD?32:21)];
        _nameLabel.textColor = [UIColor commonColor_black];
        _nameLabel.font = [UIFont regularFontWithSize:15.0f];
    }
    return _nameLabel;
}

#pragma mark 日期
-(UILabel *)dateLab{
    if (!_dateLab) {
        _dateLab = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+12,self.nameLabel.bottom+2, 120,IS_IPAD?30:18)];
        _dateLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _dateLab.font = [UIFont regularFontWithSize:13.0f];
    }
    return _dateLab;
}

#pragma mark 付费
-(UILabel *)payLab{
    if (!_payLab) {
        _payLab = [[UILabel alloc] initWithFrame:CGRectMake(self.dateLab.right+ 5,self.nameLabel.bottom+2,kScreenWidth-self.dateLab.right-20,IS_IPAD?30:18)];
        _payLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _payLab.font = [UIFont regularFontWithSize:13.0f];
    }
    return _payLab;
}

#pragma mark 提成
-(UILabel *)commissionLab{
    if (!_commissionLab) {
        _commissionLab = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-180,14, 162,IS_IPAD?32:20)];
        _commissionLab.textColor = [UIColor commonColor_red];
        _commissionLab.font = [UIFont regularFontWithSize:13.0f];
        _commissionLab.textAlignment = NSTextAlignmentRight;
    }
    return _commissionLab;
}

@end
