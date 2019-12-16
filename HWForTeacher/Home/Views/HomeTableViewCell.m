//
//  HomeTableViewCell.m
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import "HomeTableViewCell.h"

@interface HomeTableViewCell ()

@property (nonatomic,strong) UIView          *bgView;
@property (strong, nonatomic) UIImageView    *headImgView;       //头像
@property (strong, nonatomic) UILabel        *nameLabel;         //姓名
@property (strong, nonatomic) UILabel        *gradeLab;          //年级
@property (strong, nonatomic) UILabel        *timeLab;           //注册时间
@property (strong, nonatomic) UILabel        *stateLab;          //状态


@end

@implementation HomeTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.bgView];
        [self.contentView addSubview:self.headImgView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.gradeLab];
        [self.contentView addSubview:self.timeLab];
        [self.contentView addSubview:self.stateLab];
    }
    return self;
}

#pragma mark 显示数据
-(void)setStudentModel:(StudentModel *)studentModel{
    if (kIsEmptyString(studentModel.cover)) {
        [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
        [self.headImgView sd_setImageWithURL:[NSURL URLWithString:studentModel.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    self.nameLabel.text = studentModel.name;
    CGFloat nameW = [studentModel.name boundingRectWithSize:CGSizeMake(kScreenWidth, IS_IPAD?30:16) withTextFont:self.nameLabel.font].width;
    self.nameLabel.frame = CGRectMake(self.headImgView.right+10, self.bgView.top+10, nameW, IS_IPAD?30:16);
    self.gradeLab.frame = CGRectMake(self.nameLabel.right+10,  self.bgView.top+10, 80, IS_IPAD?30:16);
    self.gradeLab.text = studentModel.grade;
    NSString *timeStr = [[ZYHelper sharedZYHelper] timeWithTimeIntervalNumber:studentModel.create_time format:@"yyyy-MM-dd"];
    self.timeLab.text = [NSString stringWithFormat:@"注册时间：%@",timeStr];
    self.stateLab.text = @"未付费";
}


#pragma mark -- Getters
#pragma mark 背景
-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(18, 6, kScreenWidth-32,IS_IPAD?96:66)];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 5.0;
        _bgView.layer.shadowColor = [[UIColor blackColor] CGColor];
        _bgView.layer.shadowOffset = CGSizeMake(0.5, 0.5);
        _bgView.layer.shadowRadius = 8.0;
        _bgView.layer.shadowOpacity = 0.15;
    }
    return _bgView;
}

#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bgView.left+15,self.bgView.top+13,IS_IPAD?70:40,IS_IPAD?70:40)];
        [_headImgView setBorderWithCornerRadius:IS_IPAD?35:20 type:UIViewCornerTypeAll];
    }
    return _headImgView;
}

#pragma mark 学生
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+10, self.bgView.top+10, 95,IS_IPAD?30:16)];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#303030"];
        _nameLabel.font = [UIFont mediumFontWithSize:14.0f];
    }
    return _nameLabel;
}

#pragma mark 年级
-(UILabel *)gradeLab{
    if (!_gradeLab) {
        _gradeLab = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.right+10, self.bgView.top+10, 80,IS_IPAD?30:16)];
        _gradeLab.font = [UIFont mediumFontWithSize:14.0f];
        _gradeLab.textColor = [UIColor colorWithHexString:@"#FF8B00"];
    }
    return _gradeLab;
}

#pragma mark 注册时间
-(UILabel *)timeLab{
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+10, self.nameLabel.bottom+10, kScreenWidth-self.headImgView.right-100,IS_IPAD?24:12)];
        _timeLab.textColor = [UIColor colorWithHexString:@"#303030"];
        _timeLab.font = [UIFont regularFontWithSize:12.0f];
    }
    return _timeLab;
}

#pragma mark 状态
-(UILabel *)stateLab{
    if (!_stateLab) {
        _stateLab = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-132, self.bgView.top+30, 90, 36):CGRectMake(kScreenWidth-112,self.bgView.top+20, 76, 26)];
        _stateLab.textColor = [UIColor whiteColor];
        _stateLab.backgroundColor = [UIColor colorWithHexString:@"#CFCFD5"];
        _stateLab.font = [UIFont regularFontWithSize:14.0f];
        _stateLab.textAlignment = NSTextAlignmentCenter;
        [_stateLab setBorderWithCornerRadius:13 type:UIViewCornerTypeAll];
    }
    return _stateLab;
}

@end
