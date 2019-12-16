//
//  LeaveViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import "LeaveViewController.h"
#import "UITextView+ZWPlaceHolder.h"
#import "UITextView+ZWLimitCounter.h"
#import "BRPickerView.h"
#import "NSDate+Extend.h"

@interface LeaveViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    NSArray *titlesArr;
}

@property (nonatomic,strong) UITableView *leaveTableView;
@property (nonatomic,strong) UITextView *reasonTextView;
@property (nonatomic,strong) UITextField *timeTextField;
@property (nonatomic,strong) UILabel     *tipslab;
@property (nonatomic,strong) UIButton    *submitBtn;

@property (nonatomic, copy ) NSString   *startTimeStr;
@property (nonatomic, copy ) NSString   *endTimeStr;


@end

@implementation LeaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"请假";
    self.rightImageName = @"tutor_service";
    
    titlesArr = @[@"开始时间",@"结束时间",@"时间（天）",@"请假理由"];
    
    [self initLeaveView];
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titlesArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row==3) {
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(32, 20, 100,IS_IPAD?30:18)];
        titleLab.text = @"请假理由";
        titleLab.font = [UIFont regularFontWithSize:16.0];
        [cell.contentView addSubview:titleLab];
        
        [cell.contentView addSubview:self.reasonTextView];
        
    }else{
        cell.indentationLevel = 2; //缩进层级
        cell.indentationWidth = 10;
        cell.textLabel.text = titlesArr[indexPath.row];
        cell.textLabel.font = [UIFont regularFontWithSize:14.0f];
        if (indexPath.row==2) {
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
        
            [cell.contentView addSubview:self.timeTextField];
        }else{
            cell.detailTextLabel.font = [UIFont regularFontWithSize:14.0f];
            if (indexPath.row==0) {
                cell.detailTextLabel.text = kIsEmptyString(self.startTimeStr)?@"请选择":self.startTimeStr;
            }else{
                cell.detailTextLabel.text = kIsEmptyString(self.endTimeStr)?@"请选择":self.endTimeStr;
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 58, kScreenWidth, 1)];
        line.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [cell.contentView addSubview:line];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==3) {
        return 220;
    }else{
        return 59;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0||indexPath.row==1) {
        NSString *currentDate = [NSDate currentDateTimeWithFormat:@"yyyy年MM月dd日"];
        [BRDatePickerView showDatePickerWithTitle:indexPath.row==0?@"开始时间":@"结束时间" dateType:UIDatePickerModeDate defaultSelValue:currentDate minDateStr:currentDate maxDateStr:nil isAutoSelect:NO resultBlock:^(NSString *selectValue) {
            MyLog(@"selectValue:%@",selectValue);
            if (indexPath.row==0) {
                self.startTimeStr = selectValue;
            }else{
                self.endTimeStr = selectValue;
            }
            [self.leaveTableView reloadData];
        }];
    }
}

#pragma mark -- delegate
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.timeTextField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (1 == range.length) {//按下回格键
        return YES;
    }
    if (self.timeTextField == textField) {
        if ([textField.text length] < 2) {
            return YES;
        }
    }
    return NO;
}


#pragma mark -- Event response
#pragma mark 提交
-(void)submitLeaveInfoAction:(UIButton *)sender{
    if (kIsEmptyString(self.startTimeStr)) {
        [self.view makeToast:@"请选择开始时间" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(self.endTimeStr)) {
        [self.view makeToast:@"请选择结束时间" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(self.timeTextField.text)) {
        [self.view makeToast:@"请输入时长" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(self.reasonTextView.text)) {
        [self.view makeToast:@"请输入请假理由" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    self.submitBtn.userInteractionEnabled = NO;
    
    NSNumber *startTimeSp = [[ZYHelper sharedZYHelper] timeSwitchTimestamp:self.startTimeStr format:@"yyyy年MM月dd日"];
    NSNumber *endTimeSp = [[ZYHelper sharedZYHelper] timeSwitchTimestamp:self.endTimeStr format:@"yyyy年MM月dd日"];
    
    NSDictionary *params = @{@"token":kUserTokenValue,@"start_time":startTimeSp,@"end_time":endTimeSp,@"duration":self.timeTextField.text,@"reason":self.reasonTextView.text};
    [[HttpRequest sharedInstance] postWithURLString:kLeaveAPI parameters:params success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.view makeToast:@"您的请假申请已提交，请等待审核" duration:1.0 position:CSToastPositionCenter];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.submitBtn.userInteractionEnabled = YES;
           [self.navigationController popViewControllerAnimated:YES];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.submitBtn.userInteractionEnabled = YES;
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 在线客服
-(void)rightNavigationItemAction{
    [self pushToCustomerServiceVC];
}

#pragma mark -- Private methods
-(void)initLeaveView{
    [self.view addSubview:self.leaveTableView];
    [self.view addSubview:self.tipslab];
    [self.view addSubview:self.submitBtn];
}

#pragma mark  -- Getters
#pragma mark 请假
-(UITableView *)leaveTableView{
    if (!_leaveTableView) {
        _leaveTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStylePlain];
        _leaveTableView.dataSource = self;
        _leaveTableView.delegate = self;
        _leaveTableView.tableFooterView = [[UIView alloc] init];
        _leaveTableView.scrollEnabled = NO;
        _leaveTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _leaveTableView;
}

#pragma mark 时间
-(UITextField *)timeTextField{
    if (!_timeTextField) {
        _timeTextField = [[UITextField alloc] initWithFrame:CGRectMake(kScreenWidth-184,22, 160,IS_IPAD?28:16)];
        _timeTextField.placeholder = @"请输入时长";
        _timeTextField.textColor = [UIColor commonColor_black];
        _timeTextField.font = [UIFont mediumFontWithSize:14.0f];
        _timeTextField.delegate = self;
        _timeTextField.textAlignment = NSTextAlignmentRight;
        _timeTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _timeTextField;
}


#pragma mark 请假理由
-(UITextView *)reasonTextView{
    if (!_reasonTextView) {
        _reasonTextView = [[UITextView alloc] initWithFrame:CGRectMake(30,IS_IPAD?60:48, kScreenWidth-60,IS_IPAD?200:160)];
        _reasonTextView.layer.cornerRadius = 8.0;
        _reasonTextView.backgroundColor = [UIColor colorWithHexString:@"#F1F1F5"];
        _reasonTextView.font = [UIFont regularFontWithSize:14];
        _reasonTextView.zw_limitCount = 50;
        _reasonTextView.zw_labHeight  = 30;
        _reasonTextView.zw_placeHolder = @"请输入您的请假理由";
    }
    return _reasonTextView;
}

#pragma mark 说明
-(UILabel *)tipslab{
    if (!_tipslab) {
        _tipslab = [[UILabel alloc] initWithFrame:CGRectMake(40,kScreenHeight-(IS_IPAD?136:110), kScreenWidth-80,IS_IPAD?36:24)];
        _tipslab.font = [UIFont regularFontWithSize:13.0f];
        _tipslab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _tipslab.text = @"*请提前三小时请假，且请假提交后，不可注销。";
        _tipslab.textAlignment = NSTextAlignmentCenter;
    }
    return _tipslab;
}

#pragma mark 提交
-(UIButton *)submitBtn{
    if (!_submitBtn) {
        _submitBtn =  [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-300)/2.0,kScreenHeight-85, 300, 62)];
        [_submitBtn setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
        [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submitBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submitBtn.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
        [_submitBtn addTarget:self action:@selector(submitLeaveInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}



@end
