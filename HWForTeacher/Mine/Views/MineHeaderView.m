//
//  MineHeaderView.m
//  Homework
//
//  Created by vision on 2019/9/9.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MineHeaderView.h"

@interface MineHeaderView ()

@property (nonatomic,strong) UIImageView  *headImgView;
@property (nonatomic,strong) UILabel      *nameLabel;
@property (nonatomic,strong) UILabel      *subjectLab;
@property (nonatomic,strong) UILabel      *gradeLabel;
@property (nonatomic,strong) UILabel      *coachTimeLabel;
@property (nonatomic,strong) UIButton     *coachTimeBtn;
@property (nonatomic,strong) UILabel      *tempTimeLabel;
@property (nonatomic,strong) UIButton     *leaveBtn;

@end

@implementation MineHeaderView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.headImgView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.subjectLab];
        [self addSubview:self.gradeLabel];
        [self addSubview:self.coachTimeBtn];
        [self addSubview:self.coachTimeLabel];
        [self addSubview:self.tempTimeLabel];
        [self addSubview:self.leaveBtn];
        
    }
    return self;
}

-(void)setUserModel:(UserModel *)userModel{
    _userModel = userModel;
    
    if (kIsEmptyString(userModel.cover)) {
       [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
       [self.headImgView sd_setImageWithURL:[NSURL URLWithString:userModel.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    
    self.nameLabel.text = userModel.name;
    CGFloat nameW = [userModel.name boundingRectWithSize:CGSizeMake(kScreenWidth-self.headImgView.right-30,IS_IPAD?32:20) withTextFont:self.nameLabel.font].width;
    self.nameLabel.frame = CGRectMake(self.headImgView.right+10, KStatusHeight+32, nameW,IS_IPAD?32:20);
    
    self.subjectLab.text = userModel.subject;
    self.subjectLab.frame = CGRectMake(self.nameLabel.right+10, KStatusHeight+33,IS_IPAD?60:33,IS_IPAD?30:18);
    
    NSString *gradeStr = [userModel.grade componentsJoinedByString:@" "];
    self.gradeLabel.text = [NSString stringWithFormat:@"辅导年级：%@",gradeStr];
       
    //辅导时间
    GuideTimeModel *timeModel = [[GuideTimeModel alloc] init];
    [timeModel setValues:userModel.guide_time];
       
    NSMutableArray *workdays = [[ZYHelper sharedZYHelper] parseWeeksDataWithDays:timeModel.workday];
    NSString *workDayStr = [workdays componentsJoinedByString:@" "];
    self.coachTimeLabel.text = [NSString stringWithFormat:@"%@ %@",workDayStr,timeModel.work_time];
    NSString *offDay = [NSString stringWithFormat:@"%@",timeModel.off_day];
    NSMutableArray *offdays = [[ZYHelper sharedZYHelper] parseWeeksDataWithDays:offDay];
    NSString *offDayStr = [offdays componentsJoinedByString:@" "];
    self.tempTimeLabel.text = [NSString stringWithFormat:@"%@ %@",offDayStr,timeModel.off_time];
    
    if ([self.userModel.leave boolValue]) {
        [self.leaveBtn setTitle:@"请假中" forState:UIControlStateNormal];
        self.leaveBtn.userInteractionEnabled = NO;
    }else{
        [self.leaveBtn setTitle:@"请假" forState:UIControlStateNormal];
        self.leaveBtn.userInteractionEnabled = YES;
    }
    
}

#pragma mark -- Event response
#pragma mark 请假
-(void)leaveAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(mineHeaderViewLeave)]) {
        [self.delegate mineHeaderViewLeave];
    }
}

#pragma mark 个人资料
-(void)editUserInfoAction:(UITapGestureRecognizer *)sender{
    if ([self.delegate respondsToSelector:@selector(mineHeaderViewDidEditUserInfo)]) {
        [self.delegate mineHeaderViewDidEditUserInfo];
    }
}

#pragma mark -- Getters
#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(22,KStatusHeight+27,IS_IPAD?70:58,IS_IPAD?70:58)];
        _headImgView.backgroundColor = [UIColor bgColor_Gray];
        [_headImgView setBorderWithCornerRadius:29 type:UIViewCornerTypeAll];
        _headImgView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editUserInfoAction:)];
        [_headImgView addGestureRecognizer:tap];
    }
    return _headImgView;
}

#pragma mark 姓名
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+12,KStatusHeight+32, 100,IS_IPAD?32:20)];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#303030"];
        _nameLabel.font = [UIFont mediumFontWithSize:20.0f];
    }
    return _nameLabel;
}

#pragma mark 科目
-(UILabel *)subjectLab{
    if (!_subjectLab) {
        _subjectLab = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.right+10, KStatusHeight+33,IS_IPAD?60:33,IS_IPAD?30:18)];
        _subjectLab.textColor = [UIColor whiteColor];
        _subjectLab.font = [UIFont mediumFontWithSize:12.0f];
        _subjectLab.textAlignment = NSTextAlignmentCenter;
        _subjectLab.backgroundColor = [UIColor bm_colorGradientChangeWithSize:_subjectLab.size direction:IHGradientChangeDirectionLevel startColor:[UIColor colorWithHexString:@"#FF3737"] endColor:[UIColor colorWithHexString:@"#FF5777"]];
        [_subjectLab setBorderWithCornerRadius:4 type:UIViewCornerTypeAll];
    }
    return _subjectLab;
}

#pragma mark 年级
-(UILabel *)gradeLabel{
    if (!_gradeLabel) {
        _gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+10,self.nameLabel.bottom+10,kScreenWidth-self.headImgView.right-90,IS_IPAD?30:18)];
        _gradeLabel.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _gradeLabel.font = [UIFont regularFontWithSize:IS_IPHONE_5?10:12.0f];
    }
    return _gradeLabel;
}

#pragma mark 辅导时间
-(UIButton *)coachTimeBtn{
    if (!_coachTimeBtn) {
        _coachTimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(22, self.headImgView.bottom+10,IS_IPAD?120:86,IS_IPAD?28:16)];
        [_coachTimeBtn setImage:[UIImage drawImageWithName:@"my_teacher_time" size:IS_IPAD?CGSizeMake(20, 20):CGSizeMake(16, 16)] forState:UIControlStateNormal];
        [_coachTimeBtn setTitleColor:[UIColor colorWithHexString:@"#FF8B00"] forState:UIControlStateNormal];
        [_coachTimeBtn setTitle:@"辅导时间：" forState:UIControlStateNormal];
        _coachTimeBtn.titleLabel.font = [UIFont regularFontWithSize:12.0f];
        _coachTimeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
    }
    return _coachTimeBtn;
}

#pragma mark 辅导时间
-(UILabel *)coachTimeLabel{
    if (!_coachTimeLabel) {
        _coachTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.coachTimeBtn.right,self.headImgView.bottom+10,kScreenWidth-44,IS_IPAD?30:18)];
        _coachTimeLabel.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _coachTimeLabel.font = [UIFont regularFontWithSize:12.0f];
    }
    return _coachTimeLabel;
}

#pragma mark 辅导时间
-(UILabel *)tempTimeLabel{
    if (!_tempTimeLabel) {
        _tempTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.coachTimeBtn.right,self.coachTimeLabel.bottom+5,kScreenWidth-100,IS_IPAD?30:18)];
        _tempTimeLabel.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _tempTimeLabel.font = [UIFont regularFontWithSize:12.0f];
    }
    return _tempTimeLabel;
}

#pragma mark 编辑
-(UIButton *)leaveBtn{
    if (!_leaveBtn) {
        _leaveBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-80, self.nameLabel.bottom, 80, 36):CGRectMake(kScreenWidth-60, self.nameLabel.bottom, 60, 25)];
        _leaveBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:_leaveBtn.size direction:IHGradientChangeDirectionLevel startColor:[UIColor colorWithHexString:@"#B3C0DA "] endColor:[UIColor colorWithHexString:@"#A0B2D4"]];
        [_leaveBtn setTitle:@"请假" forState:UIControlStateNormal];
        [_leaveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _leaveBtn.titleLabel.font = [UIFont mediumFontWithSize:14.0f];
        [_leaveBtn setBorderWithCornerRadius:12.5 type:UIViewCornerTypeLeft];
        [_leaveBtn addTarget:self action:@selector(leaveAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leaveBtn;
}


@end
