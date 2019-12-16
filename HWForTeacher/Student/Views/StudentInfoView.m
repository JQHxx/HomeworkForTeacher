//
//  StudentInfoView.m
//  HWForTeacher
//
//  Created by vision on 2019/9/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import "StudentInfoView.h"

@interface StudentInfoView ()

@property (strong, nonatomic) UIView         *headBgView;       //头像背景
@property (strong, nonatomic) UIImageView    *headImgView;       //头像
@property (strong, nonatomic) UILabel        *nameLabel;         //姓名
@property (strong, nonatomic) UILabel        *gradeLab;          //年级
@property (strong, nonatomic) UILabel        *stateLab;          //辅导类型
@property (strong, nonatomic) UILabel        *timeLab;           //到期时间

@end

@implementation StudentInfoView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.headBgView];
        self.headBgView.hidden = YES;
        [self addSubview:self.headImgView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.gradeLab];
        self.gradeLab.hidden = YES;
        [self addSubview:self.stateLab];
        [self addSubview:self.timeLab];
    }
    return self;
}

#pragma mark
-(void)setModel:(StudentModel *)model{
    self.headBgView.hidden = NO;
    if (kIsEmptyString(model.cover)) {
        [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
        [self.headImgView sd_setImageWithURL:[NSURL URLWithString:model.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    self.nameLabel.text = model.name;
    CGFloat nameW = [model.name boundingRectWithSize:CGSizeMake(kScreenWidth-self.headImgView.right-80,IS_IPAD?32:20) withTextFont:self.nameLabel.font].width;
    self.nameLabel.frame = CGRectMake(self.headImgView.right+10, self.headImgView.top+10,nameW,IS_IPAD?32:20);
    
    self.gradeLab.hidden = NO;
    self.gradeLab.text = model.grade;
    self.gradeLab.frame = CGRectMake(self.nameLabel.right+10, self.headImgView.top+11,IS_IPAD?64:40,IS_IPAD?30:18);
    
    self.stateLab.text = model.status;
    
    NSString *timeStr = [[ZYHelper sharedZYHelper] timeWithTimeIntervalNumber:model.end_time format:@"yyyy-MM-dd"];
    self.timeLab.text = [NSString stringWithFormat:@"到期时间：%@",timeStr];
}

#pragma mark -- Getters
#pragma mark 头像背景
-(UIView *)headBgView{
    if (!_headBgView) {
        _headBgView = [[UIView alloc] initWithFrame:IS_IPAD?CGRectMake(28, 20, 88, 88):CGRectMake(28, 20, 68, 68)];
        _headBgView.backgroundColor = [UIColor whiteColor];
        [_headBgView setBorderWithCornerRadius:IS_IPAD?44:34 type:UIViewCornerTypeAll];
    }
    return _headBgView;
}

#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:IS_IPAD?CGRectMake(31,23, 82, 82):CGRectMake(31, 23, 62, 62)];
        [_headImgView setBorderWithCornerRadius:IS_IPAD?41:32 type:UIViewCornerTypeAll];
    }
    return _headImgView;
}

#pragma mark 姓名
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headBgView.right+10, self.headImgView.top+10, 60,IS_IPAD?32:20)];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#303030"];
        _nameLabel.font = [UIFont mediumFontWithSize:19.0f];
    }
    return _nameLabel;
}

#pragma mark 年级
-(UILabel *)gradeLab{
    if (!_gradeLab) {
        _gradeLab = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.right+10, self.headImgView.top+11,IS_IPAD?64:40,IS_IPAD?30:18)];
        _gradeLab.backgroundColor = [UIColor bm_colorGradientChangeWithSize:_gradeLab.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FF3737"] endColor:[UIColor colorWithHexString:@"#FF5777"]];
        _gradeLab.textColor = [UIColor whiteColor];
        _gradeLab.font = [UIFont regularFontWithSize:10.0f];
        _gradeLab.textAlignment = NSTextAlignmentCenter;
        [_gradeLab setBorderWithCornerRadius:3 type:UIViewCornerTypeAll];
    }
    return _gradeLab;
}

#pragma mark 辅导类型
-(UILabel *)stateLab{
    if (!_stateLab) {
       _stateLab = [[UILabel alloc] initWithFrame:CGRectMake(self.headBgView.right+10, self.nameLabel.bottom+10,IS_IPAD?70:45,IS_IPAD?26:14)];
        _stateLab.textColor = [UIColor commonColor_black];
        _stateLab.font = [UIFont regularFontWithSize:13.0f];
    }
    return _stateLab;
}

#pragma mark 到期时间
-(UILabel *)timeLab{
    if (!_timeLab) {
       _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(self.stateLab.right+10, self.nameLabel.bottom+10,kScreenWidth-self.stateLab.right-30,IS_IPAD?26:14)];
        _timeLab.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _timeLab.font = [UIFont regularFontWithSize:13.0f];
    }
    return _timeLab;
}


@end
