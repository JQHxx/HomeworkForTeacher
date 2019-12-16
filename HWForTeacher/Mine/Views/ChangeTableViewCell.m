//
//  ChangeTableViewCell.m
//  HWForTeacher
//
//  Created by vision on 2019/9/26.
//  Copyright © 2019 vision. All rights reserved.
//

#import "ChangeTableViewCell.h"

@interface ChangeTableViewCell ()

@property (strong, nonatomic) UIImageView    *headImgView;       //头像
@property (strong, nonatomic) UILabel        *nameLabel;         //姓名
@property (strong, nonatomic) UILabel        *gradeLab;           //年级
@property (strong, nonatomic) UILabel        *typeLab;           //类型 日期 状态
@property (strong, nonatomic) UILabel        *reasonLab;         //原因

@end

@implementation ChangeTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.headImgView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.gradeLab];
        [self.contentView addSubview:self.typeLab];
        [self.contentView addSubview:self.reasonLab];
    }
    return self;
}

#pragma mark -- Setters
-(void)setChangeModel:(ChangeModel *)changeModel{
    if (kIsEmptyString(changeModel.cover)) {
       [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
       [self.headImgView sd_setImageWithURL:[NSURL URLWithString:changeModel.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    self.nameLabel.text = changeModel.name;
    CGFloat nameW = [changeModel.name boundingRectWithSize:CGSizeMake(kScreenWidth,IS_IPAD?28:16) withTextFont:self.nameLabel.font].width;
    self.nameLabel.frame = CGRectMake(self.headImgView.right+10,22, nameW+10,IS_IPAD?28:16);
    self.gradeLab.frame =CGRectMake(self.nameLabel.right,21,IS_IPAD?66:38,IS_IPAD?30:18);
    self.gradeLab.text = changeModel.grade;
    
    NSString *timeStr = [[ZYHelper sharedZYHelper] timeWithTimeIntervalNumber:changeModel.create_time format:@"yyyy-MM-dd"];
    NSString *typeStr = nil;
    NSString *colorStr;
    if ([changeModel.status integerValue]==1) {
        typeStr = [NSString stringWithFormat:@"%@ %@ 转出",changeModel.guide_name,timeStr];
        colorStr = @"#280000";
    }else{
        typeStr = [NSString stringWithFormat:@"%@ %@ 转入",changeModel.guide_name,timeStr];
        colorStr = @"#FFAB00";
    }
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:typeStr];
    [attriStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:colorStr] range:NSMakeRange(typeStr.length-2, 2)];
    self.typeLab.attributedText = attriStr;
    
    self.reasonLab.text = [NSString stringWithFormat:@"原因：%@",changeModel.reason];
}

#pragma mark -- Getters
#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:IS_IPAD?CGRectMake(20, 20, 60, 60):CGRectMake(20, 18, 44, 44)];
        [_headImgView setBorderWithCornerRadius:IS_IPAD?30:22 type:UIViewCornerTypeAll];
    }
    return _headImgView;
}

#pragma mark 姓名
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+10,22, 50,IS_IPAD?28:16)];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#303030"];
        _nameLabel.font = [UIFont mediumFontWithSize:15.0f];
    }
    return _nameLabel;
}

#pragma mark 年级
-(UILabel *)gradeLab{
    if (!_gradeLab) {
        _gradeLab = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.right,21,IS_IPAD?66:38,IS_IPAD?30:18)];
        _gradeLab.backgroundColor = [UIColor colorWithHexString:@"#FFF5E9"];
        _gradeLab.textColor = [UIColor colorWithHexString:@"#FFAB00"];
        _gradeLab.font = [UIFont mediumFontWithSize:10.0f];
        _gradeLab.textAlignment = NSTextAlignmentCenter;
    }
    return _gradeLab;
}

#pragma mark 类型 日期 状态
-(UILabel *)typeLab{
    if (!_typeLab) {
        _typeLab = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-240,35, 220, 30):CGRectMake(kScreenWidth-160,23, 142,IS_IPAD?30:18)];
        _typeLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _typeLab.font = [UIFont regularFontWithSize:11.0f];
        _typeLab.textAlignment =NSTextAlignmentRight;
    }
    return _typeLab;
}

#pragma mark 原因
-(UILabel *)reasonLab{
    if (!_reasonLab) {
        _reasonLab = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+10,self.nameLabel.bottom+10,kScreenWidth-self.headImgView.right-20,IS_IPAD?26:14)];
        _reasonLab.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _reasonLab.font = [UIFont regularFontWithSize:13.0f];
    }
    return _reasonLab;
}


@end
