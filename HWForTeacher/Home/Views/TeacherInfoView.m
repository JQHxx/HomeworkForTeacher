//
//  TeacherInfoView.m
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import "TeacherInfoView.h"

@interface TeacherInfoView ()

@property (nonatomic,strong) UIView         *bgView;
@property (nonatomic,strong) UIImageView    *headImgView;
@property (nonatomic,strong) UILabel        *nameLab;
@property (nonatomic,strong) UIButton       *subjectBtn;
@property (nonatomic,strong) UILabel        *stateLab;
@property (nonatomic,strong) UILabel        *gradesLab;
@property (nonatomic,strong) UIButton       *timeTitleBtn;
@property (nonatomic,strong) UILabel        *timeLab;
@property (nonatomic,strong) UILabel        *tempTimeLabel;


@end

@implementation TeacherInfoView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bgView];
        [self addSubview:self.subjectBtn];
        [self addSubview:self.headImgView];
        [self addSubview:self.nameLab];
        [self addSubview:self.stateLab];
        [self addSubview:self.gradesLab];
        [self addSubview:self.timeTitleBtn];
        [self addSubview:self.timeLab];
        [self addSubview:self.tempTimeLabel];
    }
    return self;
}

#pragma mark 设置用户信息
-(void)setUser:(UserModel *)user{
    _user = user;
    
    [self.subjectBtn setTitle:user.subject forState:UIControlStateNormal];
    
    if (kIsEmptyString(user.cover)) {
        [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
        [self.headImgView sd_setImageWithURL:[NSURL URLWithString:user.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    self.nameLab.text = user.name;
    CGFloat nameW = [user.name boundingRectWithSize:CGSizeMake(kScreenWidth-80,IS_IPAD?30:18) withTextFont:self.nameLab.font].width;
    self.nameLab.frame = CGRectMake(self.headImgView.right+10,self.bgView.top+30, nameW+10,IS_IPAD?30:18);
    
    if ([user.leave boolValue]) {
        self.stateLab.hidden = NO;
        self.stateLab.frame = CGRectMake(self.nameLab.right, self.nameLab.top, 54,IS_IPAD?30:18);
    }else{
        self.stateLab.hidden = YES;
    }

    NSString *gradeStr = nil;
    if (kIsArray(user.grade)&&user.grade.count>0) {
        gradeStr = [user.grade componentsJoinedByString:@" "];
    }else{
        gradeStr = @"";
    }
    self.gradesLab.text = [NSString stringWithFormat:@"辅导年级：%@",gradeStr];
    
    //辅导时间
    GuideTimeModel *timeModel = [[GuideTimeModel alloc] init];
    [timeModel setValues:user.guide_time];
    
    NSMutableArray *workdays = [[ZYHelper sharedZYHelper] parseWeeksDataWithDays:timeModel.workday];
    NSString *workDayStr = [workdays componentsJoinedByString:@" "];
    self.timeLab.text = [NSString stringWithFormat:@"%@ %@",workDayStr,timeModel.work_time];
    NSString *offDay = [NSString stringWithFormat:@"%@",timeModel.off_day];
    NSMutableArray *offdays = [[ZYHelper sharedZYHelper] parseWeeksDataWithDays:offDay]; 
    NSString *offDayStr = [offdays componentsJoinedByString:@" "];
    self.tempTimeLabel.text = [NSString stringWithFormat:@"%@ %@",offDayStr,timeModel.off_time];
}

#pragma mark -- Getters
#pragma mark 背景
-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, kScreenWidth-40,IS_IPAD?180:142)];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 5.0;
        _bgView.layer.shadowColor = [[UIColor blackColor] CGColor];
        _bgView.layer.shadowOffset = CGSizeMake(0.5, 0.5);
        _bgView.layer.shadowRadius = 5.0;
        _bgView.layer.shadowOpacity = 0.15;
    }
    return _bgView;
}

#pragma mark 科目
-(UIButton *)subjectBtn{
    if (!_subjectBtn) {
        _subjectBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(20, 20, 66, 27):CGRectMake(20, 20, 44, 18)];
        [_subjectBtn setBackgroundImage:[UIImage drawImageWithName:@"home_subject_label" size:_subjectBtn.size] forState:UIControlStateNormal];
        [_subjectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _subjectBtn.titleLabel.font = [UIFont mediumFontWithSize:11.0f];
    }
    return _subjectBtn;
}

#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:IS_IPAD?CGRectMake(self.bgView.left+30, self.bgView.top+36, 66, 66): CGRectMake(self.bgView.left+24,self.bgView.top+28, 48, 48)];
        [_headImgView setBorderWithCornerRadius:IS_IPAD?33:24 type:UIViewCornerTypeAll];
    }
    return _headImgView;
}

#pragma mark 姓名
-(UILabel *)nameLab{
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+10,self.bgView.top+30, 120,IS_IPAD?30:18)];
        _nameLab.textColor = [UIColor colorWithHexString:@"#303030"];
        _nameLab.font = [UIFont regularFontWithSize:17.0f];
    }
    return _nameLab;
}

#pragma mark 请假
-(UILabel *)stateLab{
    if (!_stateLab) {
        _stateLab = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLab.right, self.nameLab.top, 64,IS_IPAD?30:18)];
        _stateLab.textColor = [UIColor colorWithHexString:@"#809AD3"];
        _stateLab.font = [UIFont regularFontWithSize:12.0f];
        _stateLab.backgroundColor = [UIColor colorWithHexString:@"#EBF1FF"];
        _stateLab.textAlignment = NSTextAlignmentCenter;
        _stateLab.text = @"请假中";
        [_stateLab setBorderWithCornerRadius:2.0 type:UIViewCornerTypeAll];
    }
    return _stateLab;
}

#pragma mark 年级
-(UILabel *)gradesLab{
    if (!_gradesLab) {
        _gradesLab = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+10,self.nameLab.bottom+10,kScreenWidth-self.headImgView.right-20,IS_IPAD?28:16)];
        _gradesLab.textColor = [UIColor colorWithHexString:@"#303030"];
        _gradesLab.font = [UIFont regularFontWithSize:13.0f];
    }
    return _gradesLab;
}

#pragma mark 辅导时间
-(UIButton *)timeTitleBtn{
    if (!_timeTitleBtn) {
        _timeTitleBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bgView.left+24, self.headImgView.bottom+10,IS_IPAD?126:(IS_IPHONE_5?66: 86),IS_IPAD?24:16)];
        [_timeTitleBtn setImage:[UIImage imageNamed:@"my_teacher_time"] forState:UIControlStateNormal];
        [_timeTitleBtn setTitleColor:[UIColor colorWithHexString:@"#FF8B00"] forState:UIControlStateNormal];
        [_timeTitleBtn setTitle:@"辅导时间：" forState:UIControlStateNormal];
        _timeTitleBtn.titleLabel.font = [UIFont regularFontWithSize:IS_IPHONE_5?10.0f:12.0f];
        _timeTitleBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
    }
    return _timeTitleBtn;
}

#pragma mark 辅导时间
-(UILabel *)timeLab{
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(self.timeTitleBtn.right, self.headImgView.bottom+10, kScreenWidth-self.timeTitleBtn.right-30,IS_IPAD?24:16)];
        _timeLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _timeLab.font = [UIFont regularFontWithSize:IS_IPHONE_5?10.0f:12.0f];
    }
    return _timeLab;
}

#pragma mark 辅导时间
-(UILabel *)tempTimeLabel{
    if (!_tempTimeLabel) {
        _tempTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.timeTitleBtn.right, self.timeLab.bottom+5,self.timeLab.width,IS_IPAD?24:16)];
        _tempTimeLabel.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _tempTimeLabel.font = [UIFont regularFontWithSize:IS_IPHONE_5?10.0f:12.0f];
    }
    return _tempTimeLabel;
}

@end
