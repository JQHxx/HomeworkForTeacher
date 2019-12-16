//
//  StudentTableViewCell.m
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import "StudentTableViewCell.h"

@interface StudentTableViewCell ()


@property (strong, nonatomic) UILabel        *nameLabel;         //姓名
@property (strong, nonatomic) UILabel        *gradeLab;          //年级
@property (strong, nonatomic) UILabel        *remarkLab;         //备注
@property (strong, nonatomic) UILabel        *stateLab;          //状态

@end

@implementation StudentTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.headImgView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.gradeLab];
        [self.contentView addSubview:self.remarkLab];
        [self.contentView addSubview:self.stateLab];
    }
    return self;
}

-(void)setStudentModel:(StudentModel *)studentModel{
    if (kIsEmptyString(studentModel.cover)) {
        [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
        [self.headImgView sd_setImageWithURL:[NSURL URLWithString:studentModel.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    
    self.nameLabel.text = studentModel.name;
    CGFloat nameW = [studentModel.name boundingRectWithSize:CGSizeMake(kScreenWidth, IS_IPAD?30:18) withTextFont:self.nameLabel.font].width;
    self.nameLabel.frame = CGRectMake(self.headImgView.right+10, self.headImgView.top,nameW, IS_IPAD?30:18);
    
    self.gradeLab.text = [NSString stringWithFormat:@"%@ %@",studentModel.grade,studentModel.version];
    CGFloat width = [self.gradeLab.text boundingRectWithSize:CGSizeMake(kScreenWidth-self.nameLabel.right-100, IS_IPAD?30:18) withTextFont:self.gradeLab.font].width;
    self.gradeLab.frame = CGRectMake(self.nameLabel.right+10, self.headImgView.top,width+10,IS_IPAD?30:18);
    
    self.remarkLab.text = [NSString stringWithFormat:@"备注：%@",kIsEmptyString(studentModel.remark)?@"无":studentModel.remark];
    self.stateLab.text = studentModel.status;
}

#pragma mark -- Getters
#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:IS_IPAD?CGRectMake(20, 20, 60, 60):CGRectMake(20, 20, 40, 40)];
        [_headImgView setBorderWithCornerRadius:IS_IPAD?30:20 type:UIViewCornerTypeAll];
        _headImgView.userInteractionEnabled = YES;
        
    }
    return _headImgView;
}

#pragma mark 姓名
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+10, self.headImgView.top, 60,IS_IPAD?30:18)];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#303030"];
        _nameLabel.font = [UIFont mediumFontWithSize:15.0f];
    }
    return _nameLabel;
}

#pragma mark 年级
-(UILabel *)gradeLab{
    if (!_gradeLab) {
       _gradeLab = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.right+8, self.headImgView.top, 75,IS_IPAD?30: 18)];
        _gradeLab.textColor = [UIColor colorWithHexString:@"#FFAB00"];
        _gradeLab.font = [UIFont regularFontWithSize:10.0f];
        _gradeLab.backgroundColor = [UIColor colorWithHexString:@"#FFF5E9"];
        _gradeLab.textAlignment = NSTextAlignmentCenter;
        _gradeLab.layer.cornerRadius = 4.0;
    }
    return _gradeLab;
}


#pragma mark 备注
-(UILabel *)remarkLab{
    if (!_remarkLab) {
        _remarkLab = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+10, self.nameLabel.bottom+10, kScreenWidth-self.headImgView.right-100, IS_IPAD?24:12)];
        _remarkLab.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _remarkLab.font = [UIFont regularFontWithSize:13.0f];
    }
    return _remarkLab;
}

#pragma mark 状态
-(UILabel *)stateLab{
    if (!_stateLab) {
        _stateLab = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-120, 24, 100,IS_IPAD?24:12)];
        _stateLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _stateLab.font = [UIFont regularFontWithSize:11.0f];
        _stateLab.textAlignment = NSTextAlignmentRight;
    }
    return _stateLab;
}


@end
