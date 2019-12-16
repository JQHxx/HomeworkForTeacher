//
//  FeedbackTableViewCell.m
//  HWForTeacher
//
//  Created by vision on 2019/9/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import "FeedbackTableViewCell.h"

@interface FeedbackTableViewCell ()

@property (strong, nonatomic) UIImageView    *headImgView;       //头像
@property (strong, nonatomic) UILabel        *nameLabel;         //姓名
@property (strong, nonatomic) UILabel        *gradeLab;          //年级 版本


@end

@implementation FeedbackTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.headImgView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.gradeLab];
        [self.contentView addSubview:self.checkContentBtn];
        [self.contentView addSubview:self.editFeedbackBtn];
    }
    return self;
}

#pragma mark 显示数据
-(void)setFeedbackModel:(FeedbackModel *)feedbackModel{
   if (kIsEmptyString(feedbackModel.cover)) {
        [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
        [self.headImgView sd_setImageWithURL:[NSURL URLWithString:feedbackModel.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    
    self.nameLabel.text = feedbackModel.name;
    CGFloat nameW = [feedbackModel.name boundingRectWithSize:CGSizeMake(kScreenWidth,IS_IPAD?28: 16) withTextFont:self.nameLabel.font].width;
    self.nameLabel.frame = CGRectMake(self.headImgView.right+8, self.headImgView.top,nameW, IS_IPAD?28:16);
    
    self.gradeLab.text = [NSString stringWithFormat:@"%@ %@",feedbackModel.grade,feedbackModel.version];
    self.gradeLab.frame = CGRectMake(self.headImgView.right+10, self.nameLabel.bottom+10,IS_IPAD?140:85,IS_IPAD?28:16);
     
    if ([feedbackModel.status boolValue]) { //已填写
        [self.editFeedbackBtn setTitleColor:[UIColor colorWithHexString:@"#B6BECA"] forState:UIControlStateNormal];
        [self.editFeedbackBtn setTitle:@"已提交反馈" forState:UIControlStateNormal];
        self.editFeedbackBtn.backgroundColor = [UIColor colorWithHexString:@"#EFF1F3"];
    }else{
        [self.editFeedbackBtn setTitleColor:[UIColor colorWithHexString:@"#FF5353"] forState:UIControlStateNormal];
        [self.editFeedbackBtn setTitle:@"填写反馈" forState:UIControlStateNormal];
        self.editFeedbackBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:_editFeedbackBtn.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FFF1F2"] endColor:[UIColor colorWithHexString:@"#FFE1E5"]];
    }
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
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+10, self.headImgView.top, 60,IS_IPAD?28:16)];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#303030"];
        _nameLabel.font = [UIFont mediumFontWithSize:15.0f];
    }
    return _nameLabel;
}

#pragma mark 年级 教材版本
-(UILabel *)gradeLab{
    if (!_gradeLab) {
       _gradeLab = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+10, self.nameLabel.bottom+10,IS_IPAD?140:85,IS_IPAD?28:16)];
        _gradeLab.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _gradeLab.font = [UIFont regularFontWithSize:13.0f];
    }
    return _gradeLab;
}

#pragma mark 查看辅导内容
-(UIButton *)checkContentBtn{
    if (!_checkContentBtn) {
        _checkContentBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-285, 50, 142, 36):CGRectMake(kScreenWidth-175, 38,82,24)];
        [_checkContentBtn setTitle:@"查看辅导内容" forState:UIControlStateNormal];
        [_checkContentBtn setTitleColor:[UIColor colorWithHexString:@"#B6BECA"] forState:UIControlStateNormal];
        _checkContentBtn.titleLabel.font = [UIFont mediumFontWithSize:11.0f];
        _checkContentBtn.layer.borderWidth = 1.0;
        _checkContentBtn.layer.borderColor = [UIColor colorWithHexString:@"#B6BECA"].CGColor;
        _checkContentBtn.layer.cornerRadius = IS_IPAD?18.0:12.0;
    }
    return _checkContentBtn;
}

#pragma mark 填写辅导反馈
-(UIButton *)editFeedbackBtn{
    if (!_editFeedbackBtn) {
        _editFeedbackBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(self.checkContentBtn.right+8, 50, 110, 36):CGRectMake(self.checkContentBtn.right+8,38,70,24)];
        _editFeedbackBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:_editFeedbackBtn.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FFF1F2"] endColor:[UIColor colorWithHexString:@"#FFE1E5"]];
        [_editFeedbackBtn setTitle:@"填写反馈" forState:UIControlStateNormal];
        [_editFeedbackBtn setTitleColor:[UIColor colorWithHexString:@"#FF5353"] forState:UIControlStateNormal];
        _editFeedbackBtn.titleLabel.font = [UIFont regularFontWithSize:11.0f];
        _editFeedbackBtn.layer.cornerRadius = IS_IPAD?18.0:12.0;
    }
    return _editFeedbackBtn;
}

@end
