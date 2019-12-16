//
//  SetCoachTimeViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import "SetCoachTimeViewController.h"
#import "ChooseBtnView.h"
#import "BRPickerView.h"


#define kBtnWidth     (kScreenWidth-108)/3.0
#define kTimeBtnWidth (kScreenWidth-115)/2.0

@interface SetCoachTimeViewController (){
    NSMutableArray  *selBtnsArray;
    
    NSMutableArray  *selWorkDaysArr;  //工作日
    NSMutableArray  *selWeekendDaysArr;  //周末
}

@property (nonatomic,strong) UIView      *tipsView;
@property (nonatomic,strong) UIView      *workingDayView;
@property (nonatomic,strong) UIView      *weekendView;
@property (nonatomic,strong) UIButton    *saveBtn;

@property (nonatomic,strong) UIButton    *workStartTimeBtn;
@property (nonatomic,strong) UIButton    *workEndTimeBtn;
@property (nonatomic,strong) UIButton    *weekendStartTimeBtn;
@property (nonatomic,strong) UIButton    *weekendEndTimeBtn;


@property (nonatomic, copy ) NSString    *workStartTime;
@property (nonatomic, copy ) NSString    *workEndTime;
@property (nonatomic, copy ) NSString    *weekendStartTime;
@property (nonatomic, copy ) NSString    *weekendEndTime;


@end

@implementation SetCoachTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"设置辅导时间";
    self.rightImageName = @"tutor_service";
    
    selBtnsArray = [[NSMutableArray alloc] init];
    selWorkDaysArr = [[NSMutableArray alloc] init];
    selWeekendDaysArr = [[NSMutableArray alloc] init];
    
    self.workStartTime = @"16:00";
    self.workEndTime = @"00:00";
    self.weekendStartTime = @"08:00";
    self.weekendEndTime = @"00:00";
    
    [self initSetCoachTimeView];
}

#pragma mark -- Event response
#pragma mark 设置辅导日期
-(void)setCoachTimeAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    ChooseBtnView *aView = (ChooseBtnView *)[selBtnsArray objectAtIndex:sender.tag];
    aView.hasChoosed = sender.selected;
    
    if (sender.selected) {
        if (sender.tag>4) {
            [selWeekendDaysArr addObject:[NSNumber numberWithInteger:sender.tag+1]];
        }else{
            [selWorkDaysArr addObject:[NSNumber numberWithInteger:sender.tag+1]];
        }
    }else{
        if (sender.tag>4) {
            [selWeekendDaysArr removeObject:[NSNumber numberWithInteger:sender.tag+1]];
        }else{
            [selWorkDaysArr removeObject:[NSNumber numberWithInteger:sender.tag+1]];
        }
    }
    MyLog(@"workdays:%@,weekenddays:%@",selWorkDaysArr,selWeekendDaysArr);
}

#pragma mark 设置辅导时间
-(void)chooseTimeAction:(UIButton *)sender{
    MyLog(@"time:%@",sender.currentTitle);
    
    [BRDatePickerView showDatePickerWithTitle:@"辅导时间" dateType:UIDatePickerModeTime defaultSelValue:sender.currentTitle minDateStr:sender.currentTitle maxDateStr:@"00:00" isAutoSelect:NO resultBlock:^(NSString *selectValue) {
        MyLog(@"selectValue:%@",selectValue);
        if (sender.tag==0) {
            self.workStartTime = selectValue;
            [self.workStartTimeBtn setTitle:selectValue forState:UIControlStateNormal];
        }else if (sender.tag==1){
            self.workEndTime = selectValue;
            [self.workEndTimeBtn setTitle:selectValue forState:UIControlStateNormal];
        }else if (sender.tag==2){
            self.weekendStartTime = selectValue;
            [self.weekendStartTimeBtn setTitle:selectValue forState:UIControlStateNormal];
        }else{
            self.weekendEndTime = selectValue;
            [self.weekendEndTimeBtn setTitle:selectValue forState:UIControlStateNormal];
        }
    }];
}

#pragma mark 保存辅导时间
-(void)saveCoachTimeAction:(UIButton *)sender{
    if (selWorkDaysArr.count+selWeekendDaysArr.count<6) {
        [self.view makeToast:@"辅导时间不能小于6天" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    self.saveBtn.userInteractionEnabled = NO;
    NSString *workDay = [selWorkDaysArr componentsJoinedByString:@","];
    NSString *workTime = [NSString stringWithFormat:@"%@-%@",self.workStartTime,self.workEndTime];
    NSString *offDay = [selWeekendDaysArr componentsJoinedByString:@","];
    NSString *offTime = [NSString stringWithFormat:@"%@-%@",self.weekendStartTime,self.weekendEndTime];
    NSDictionary *params = @{@"token":kUserTokenValue,@"workday":workDay,@"work_time":workTime,@"off_day":offDay,@"off_time":offTime};
    [[HttpRequest sharedInstance] postWithURLString:kSetGuideTimeAPI parameters:params success:^(id responseObject) {
        [ZYHelper sharedZYHelper].isUpdateHome = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.view makeToast:@"辅导时间设置成功，请等待审核" duration:1.0 position:CSToastPositionCenter];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.saveBtn.userInteractionEnabled = YES;
           [self.navigationController popViewControllerAnimated:YES];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.saveBtn.userInteractionEnabled = YES;
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 联系客服
-(void)rightNavigationItemAction{
    [self pushToCustomerServiceVC];
}

#pragma mark -- Private Methods
#pragma mark 初始化
-(void)initSetCoachTimeView{
    [self.view addSubview:self.tipsView];
    [self.view addSubview:self.workingDayView];
    [self.view addSubview:self.weekendView];
    [self.view addSubview:self.saveBtn];
}

#pragma mark 时间按钮
-(UIButton *)creatTimeButtonWithFrame:(CGRect)frame title:(NSString *)title tag:(NSInteger)tag{
    UIButton *timeBtn = [[UIButton alloc] initWithFrame:frame];
    [timeBtn setTitle:title forState:UIControlStateNormal];
    [timeBtn setImage:[UIImage imageNamed:@"time_choose"] forState:UIControlStateNormal];
    timeBtn.titleLabel.font = [UIFont mediumFontWithSize:13];
    [timeBtn setTitleColor:[UIColor commonColor_black] forState:UIControlStateNormal];
    timeBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:timeBtn.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#F7F8F9"] endColor:[UIColor colorWithHexString:@"#EBEDF1"]];
    [timeBtn setBorderWithCornerRadius:4.0 type:UIViewCornerTypeAll];
    timeBtn.imageEdgeInsets = UIEdgeInsetsMake(0,timeBtn.width-timeBtn.imageView.width-10, 0, 0);
    timeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -(timeBtn.width-timeBtn.titleLabel.width-10), 0, 0);
    timeBtn.tag = tag;
    [timeBtn addTarget:self action:@selector(chooseTimeAction:) forControlEvents:UIControlEventTouchUpInside];
    return timeBtn;
}

#pragma mark -- Getters
#pragma mark 说明
-(UIView *)tipsView{
    if (!_tipsView) {
        _tipsView = [[UIView alloc] initWithFrame:CGRectZero];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectZero];
        lab.text = @"辅导时间要求一个星期至少有6天，每天不得少于4小时。周一至周五的时间设置范围在16时-24时。请按规范设置，否则拒绝通过审核。";
        lab.font = [UIFont regularFontWithSize:14];
        lab.textColor = [UIColor commonColor_black];
        lab.numberOfLines = 0;
        CGFloat labH = [lab.text boundingRectWithSize:CGSizeMake(kScreenWidth-50, CGFLOAT_MAX) withTextFont:lab.font].height;
        lab.frame = CGRectMake(10, 20, kScreenWidth-50, labH);
        [_tipsView addSubview:lab];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, labH+39, kScreenWidth, 1)];
        line.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [_tipsView addSubview:line];
        
        _tipsView.frame = CGRectMake(15, kNavHeight+10, kScreenWidth-30,labH+40);
    }
    return _tipsView;
}

#pragma mark 工作日
-(UIView *)workingDayView{
    if (!_workingDayView) {
        _workingDayView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tipsView.bottom, kScreenWidth,IS_IPAD?240:200)];
        
        NSArray *values = @[@"星期一",@"星期二",@"星期三",@"星期四",@"星期五"];
        for (NSInteger i=0; i<values.count; i++) {
            ChooseBtnView *btnView = [[ChooseBtnView alloc] initWithFrame:CGRectMake(38+(i%3)*(kBtnWidth+16), 24+(i/3)*(IS_IPAD?60:48), kBtnWidth,IS_IPAD?50:38) title:values[i]];
            btnView.myBtn.tag = i;
            [btnView.myBtn addTarget:self action:@selector(setCoachTimeAction:) forControlEvents:UIControlEventTouchUpInside];
            [_workingDayView addSubview:btnView];
            
            [selBtnsArray addObject:btnView];
        }
        
        NSArray *times = @[@"16:00",@"00:00"];
        for (NSInteger i=0; i<2; i++) {
            UIButton *timeBtn = [self creatTimeButtonWithFrame:CGRectMake(38+i*(kTimeBtnWidth+39),34+2*(IS_IPAD?60:48), kTimeBtnWidth,IS_IPAD?46:34) title:times[i] tag:i];
            [_workingDayView addSubview:timeBtn];
            if (i==0) {
                self.workStartTimeBtn = timeBtn;
            }else{
                self.workEndTimeBtn = timeBtn;
            }
        }
        
    }
    return _workingDayView;
}

#pragma mark 周末
-(UIView *)weekendView{
    if (!_weekendView) {
        _weekendView = [[UIView alloc] initWithFrame:CGRectMake(0, self.workingDayView.bottom, kScreenWidth,IS_IPAD?180:120)];
        NSArray *values = @[@"星期六",@"星期日"];
        for (NSInteger i=0; i<values.count; i++) {
            ChooseBtnView *btnView = [[ChooseBtnView alloc] initWithFrame:CGRectMake(38+(i%3)*(kBtnWidth+16), 0, kBtnWidth,IS_IPAD?50:38) title:values[i]];
            btnView.myBtn.tag = i+5;
            [btnView.myBtn addTarget:self action:@selector(setCoachTimeAction:) forControlEvents:UIControlEventTouchUpInside];
            [_weekendView addSubview:btnView];
            [selBtnsArray addObject:btnView];
        }
        
        NSArray *times = @[@"08:00",@"00:00"];
        for (NSInteger i=0; i<2; i++) {
            UIButton *timeBtn = [self creatTimeButtonWithFrame:CGRectMake(38+i*(kTimeBtnWidth+39),IS_IPAD?70:58, kTimeBtnWidth,IS_IPAD?46:34) title:times[i] tag:i+2];
            [_weekendView addSubview:timeBtn];
            if (i==0) {
                self.weekendStartTimeBtn = timeBtn;
            }else{
                self.weekendEndTimeBtn = timeBtn;
            }
        }
    }
    return _weekendView;
}


#pragma mark 完成
-(UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn =  [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-300)/2.0,kScreenHeight-95, 300, 62)];
        [_saveBtn setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
        [_saveBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
        _saveBtn.titleEdgeInsets =UIEdgeInsetsMake(-10, 0, 0, 0);
        [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_saveBtn addTarget:self action:@selector(saveCoachTimeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}

@end
