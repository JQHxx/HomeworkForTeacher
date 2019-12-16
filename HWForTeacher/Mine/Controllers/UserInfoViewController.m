//
//  UserInfoViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/26.
//  Copyright © 2019 vision. All rights reserved.
//

#import "UserInfoViewController.h"
#import "EditTeachInfoViewController.h"


@interface UserInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,EditTeachInfoViewControllerDelegate>{
    NSArray   *titlesArr;
}

@property (nonatomic,strong) UITableView  *profileTableView;
@property (nonatomic,strong) UITextField  *nameTextField;
@property (nonatomic,strong) UITextField  *tagsTextField1;
@property (nonatomic,strong) UITextField  *tagsTextField2;
@property (nonatomic,strong) UIImageView  *headImgView;
@property (nonatomic,strong) UIButton     *uploadBtn;
 


@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"我的资料";
    self.rightImageName = @"tutor_service";
    
    titlesArr = @[@"姓名",@"辅导科目",@"辅导年级",@"辅导时间",@"我的标签",@"上传照片",@"教学经历",@"教学风格",@"教育理念"];
    
    [self.view addSubview:self.profileTableView];
}



#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titlesArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *tagView = [[UIView alloc] initWithFrame:CGRectMake(22, 25, 5,IS_IPAD?26:14)];
    tagView.backgroundColor = [UIColor colorWithHexString:@"#FF7171"];
    [tagView setBorderWithCornerRadius:2.5 type:UIViewCornerTypeAll];
    [cell.contentView addSubview:tagView];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(tagView.right+8, 22, IS_IPAD?120:75,IS_IPAD?30:18)];
    titleLab.font = [UIFont mediumFontWithSize:18];
    titleLab.textColor = [UIColor colorWithHexString:@"#303030"];
    titleLab.text = titlesArr[indexPath.row];
    [cell.contentView addSubview:titleLab];
    
    if (indexPath.row==0) {
        [cell.contentView addSubview:self.nameTextField];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(self.nameTextField.right,titleLab.bottom+18,IS_IPAD?60:35,IS_IPAD?36:24)];
        lab.font = [UIFont regularFontWithSize:16];
        lab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        lab.text = @"老师";
        [cell.contentView addSubview:lab];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(25, lab.bottom+10,kScreenWidth-(IS_IPAD?100:50), 1)];
        line.backgroundColor = [UIColor colorWithHexString:@"#EAEBF0"];
        [cell.contentView addSubview:line];
        
    }else if (indexPath.row==1) {
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(25,titleLab.bottom+18, kScreenWidth-50,IS_IPAD?34:22)];
        lab.font = [UIFont regularFontWithSize:16];
        lab.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        lab.text = self.userDetails.subject;
        [cell.contentView addSubview:lab];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(25, lab.bottom+10, kScreenWidth-50, 1)];
        line.backgroundColor = [UIColor colorWithHexString:@"#EAEBF0"];
        [cell.contentView addSubview:line];
    }else if (indexPath.row==2) {
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(25,titleLab.bottom+18,kScreenWidth-50, IS_IPAD?34:22)];
        lab.font = [UIFont regularFontWithSize:16];
        lab.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        lab.text = [self.userDetails.grade componentsJoinedByString:@"、"];
        [cell.contentView addSubview:lab];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(25, lab.bottom+10, kScreenWidth-50, 1)];
        line.backgroundColor = [UIColor colorWithHexString:@"#EAEBF0"];
        [cell.contentView addSubview:line];
    }else if (indexPath.row==3) {
        GuideTimeModel *timeModel = [[GuideTimeModel alloc] init];
        [timeModel setValues:self.userDetails.guide_time];
        for (NSInteger i=0; i<2; i++) {
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(25,titleLab.bottom+18+50*i,kScreenWidth-50,IS_IPAD?34: 22)];
            lab.font = [UIFont regularFontWithSize:16];
            lab.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
            if (i==0) {
                NSMutableArray *workdays = [[ZYHelper sharedZYHelper] parseWeeksDataWithDays:timeModel.workday];
                NSString *workDayStr = [workdays componentsJoinedByString:@" "];
                lab.text = [NSString stringWithFormat:@"%@ %@",workDayStr,timeModel.work_time];
            }else{
                NSString *offDay = [NSString stringWithFormat:@"%@",timeModel.off_day];
                NSMutableArray *offdays = [[ZYHelper sharedZYHelper] parseWeeksDataWithDays:offDay];
                NSString *offDayStr = [offdays componentsJoinedByString:@" "];
                lab.text = [NSString stringWithFormat:@"%@ %@",offDayStr,timeModel.off_time];
            }
            [cell.contentView addSubview:lab];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(25, lab.bottom+10, kScreenWidth-50, 1)];
            line.backgroundColor = [UIColor colorWithHexString:@"#EAEBF0"];
            [cell.contentView addSubview:line];
        }
    }else if (indexPath.row==4) {
        UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(titleLab.right+8, 25, kScreenWidth-titleLab.right-20,IS_IPAD?30:18)];
        tipsLab.font = [UIFont regularFontWithSize:12];
        tipsLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        tipsLab.text = @"*每个标签不能超过10个汉字";
        [cell.contentView addSubview:tipsLab];
        
        NSArray *holdersArr = @[@"例如：x年教龄",@"例如：幽默风趣"];
        NSArray *arr = self.userDetails.label;
        for (NSInteger i=0; i<arr.count; i++) {
            UITextField *tagsTextField = [[UITextField alloc] initWithFrame:CGRectMake(25,titleLab.bottom+18+(IS_IPAD?62:50)*i, kScreenWidth-50,IS_IPAD?34:22)];
            tagsTextField.placeholder = holdersArr[i];
            tagsTextField.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
            tagsTextField.font = [UIFont regularFontWithSize:16.0f];
            tagsTextField.delegate = self;
            tagsTextField.text = arr[i];
            [cell.contentView addSubview:tagsTextField];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(25, tagsTextField.bottom+10, kScreenWidth-50, 1)];
            line.backgroundColor = [UIColor colorWithHexString:@"#EAEBF0"];
            [cell.contentView addSubview:line];
            
            if (i==0) {
                self.tagsTextField1 = tagsTextField;
            }else{
                self.tagsTextField2 = tagsTextField;
            }
        }
    }else if (indexPath.row==5){
        [cell.contentView addSubview:self.headImgView];
        [cell.contentView addSubview:self.uploadBtn];
    }else{
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectZero];
        lab.font = [UIFont regularFontWithSize:14];
        lab.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        lab.numberOfLines = 0;
        
        if (indexPath.row==6) {
            lab.text = self.userDetails.experience;
        }else if (indexPath.row==7){
            lab.text = self.userDetails.style;
        }else{
            lab.text = self.userDetails.idea;
        }
        CGFloat height = [lab.text boundingRectWithSize:CGSizeMake(kScreenWidth-60, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:14]].height;
        lab.frame = CGRectMake(30, titleLab.bottom+15, kScreenWidth-60, height);
        [cell.contentView addSubview:lab];
        
        UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-75, 17,IS_IPAD?80:55, 25)];
        [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [editBtn setTitleColor:[UIColor colorWithHexString:@"#9495A0"] forState:UIControlStateNormal];
        editBtn.titleLabel.font = [UIFont regularFontWithSize:14];
        [editBtn setImage:[UIImage imageNamed:@"my_arrow_gray"] forState:UIControlStateNormal];
        editBtn.titleEdgeInsets =  UIEdgeInsetsMake(0,-(IS_IPAD?56:20), 0, 0);
        editBtn.imageEdgeInsets =  UIEdgeInsetsMake(0, 40, 0, 0);
        editBtn.tag = indexPath.row -6;
        [editBtn addTarget:self action:@selector(editTeachInfoAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:editBtn];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0||indexPath.row==1||indexPath.row==2) {
        return IS_IPAD?113:93;
    }else if (indexPath.row==3||indexPath.row==4){
        return IS_IPAD?180:149;
    }else if (indexPath.row==5){
        return IS_IPAD?395:275;
    }else{
        NSString *str = nil;
        if (indexPath.row==6) {
            str = self.userDetails.experience;
        }else if (indexPath.row==7){
            str = self.userDetails.style;
        }else{
            str = self.userDetails.idea;
        }
        CGFloat height = [str boundingRectWithSize:CGSizeMake(kScreenWidth-60, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:14]].height;
        return height+(IS_IPAD?80:60);
    }
}

#pragma mark --UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"token"] = kUserTokenValue;
    if (textField==self.nameTextField) {
        self.userDetails.name = textField.text;
        params[@"name"] = textField.text;
    }else if (textField==self.tagsTextField1){
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:self.userDetails.label];
        [tempArr replaceObjectAtIndex:0 withObject:textField.text];
        self.userDetails.label = tempArr;
        params[@"label"] = [[ZYHelper sharedZYHelper] getValueWithParams:tempArr];
    }else if (textField==self.tagsTextField2){
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:self.userDetails.label];
        [tempArr replaceObjectAtIndex:1 withObject:textField.text];
        self.userDetails.label = tempArr;
        params[@"label"] = [[ZYHelper sharedZYHelper] getValueWithParams:tempArr];
    }
    [self changeUserInfoWithParams:params];
}

#pragma mmark UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([textField isFirstResponder]) {
        if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage]) {
            return NO;
        }
        
        //判断键盘是不是九宫格键盘
        if ([[ZYHelper sharedZYHelper] isNineKeyBoard:string] ){
            return YES;
        }else{
            if ([[ZYHelper sharedZYHelper] hasEmoji:string] || [[ZYHelper sharedZYHelper] strIsContainEmojiWithStr:string]){
                return NO;
            }
        }
    }
    
    if (1 == range.length) {//按下回格键
        return YES;
    }
    if (self.nameTextField==textField) {
        if ([textField.text length]<8) {
            return YES;
        }
    }
    
    if (self.tagsTextField1==textField||self.tagsTextField2==textField) {
        if ([textField.text length]<10) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark  UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [self.imgPicker dismissViewControllerAnimated:YES completion:nil];
    UIImage* curImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = [UIImage zipNSDataWithImage:curImage];
    NSString *encodeResult = [imageData base64EncodedStringWithOptions:0]; //base64
    [[HttpRequest sharedInstance] postWithURLString:kUploadPicAPI parameters:@{@"pic":encodeResult,@"label":@1} success:^(id responseObject) {
        self.userDetails.cover = [responseObject objectForKey:@"data"];
        NSDictionary *params = @{@"token":kUserTokenValue,@"cover":self.userDetails.cover};
        [self changeUserInfoWithParams:params];
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark EditTeachInfoViewControllerDelegate
-(void)editTeachInfoViewControllerDidSaveTeachInfo:(NSString *)teachText type:(NSString *)type{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"token"] = kUserTokenValue;
    if ([type isEqualToString:@"教学经历"]) {
        self.userDetails.experience = teachText;
        params[@"experience"] = teachText;
    }else if ([type isEqualToString:@"教学风格"]){
        self.userDetails.style = teachText;
        params[@"style"] = teachText;
    }else{
        self.userDetails.idea = teachText;
        params[@"idea"] = teachText;
    }
    [self changeUserInfoWithParams:params];
}

#pragma mark -- Event response
#pragma mark 联系客服
-(void)rightNavigationItemAction{
    [self pushToCustomerServiceVC];
}

#pragma mark 重新上传头像
-(void)uploadHeadPicAction:(UIButton *)sender{
    [self addPhoto];
}

#pragma mark 编辑教学信息
-(void)editTeachInfoAction:(UIButton *)sender{
    EditTeachInfoViewController *editInfoVC = [[EditTeachInfoViewController alloc] init];
    NSString *str = nil;
    NSString *titleStr = nil;
    if (sender.tag==0) {
        str = self.userDetails.experience;
        titleStr = @"教学经历";
    }else if (sender.tag==1){
        str = self.userDetails.style;
        titleStr = @"教学风格";
    }else{
        str = self.userDetails.idea;
        titleStr = @"教育理念";
    }
    editInfoVC.teachInfo = str;
    editInfoVC.titleStr = titleStr;
    editInfoVC.delgate = self;
    [self.navigationController pushViewController:editInfoVC animated:YES];
}


#pragma mark 修改个人信息
-(void)changeUserInfoWithParams:(NSDictionary*)params{
    [[HttpRequest sharedInstance] postWithURLString:kChangeUserInfoAPI parameters:params success:^(id responseObject) {
        [ZYHelper sharedZYHelper].isUpdateMine= YES;
        [ZYHelper sharedZYHelper].isUpdateHome = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:@"您的个人信息已修改，请等待审核" duration:1.0 position:CSToastPositionCenter];
            [self.profileTableView reloadData];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- getters
#pragma mark 个人资料
-(UITableView *)profileTableView{
    if (!_profileTableView) {
        _profileTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight)];
        _profileTableView.dataSource = self;
        _profileTableView.delegate = self;
        _profileTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _profileTableView;
}

#pragma mark 姓名
-(UITextField *)nameTextField{
    if (!_nameTextField) {
        _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(25, IS_IPAD?65:55, kScreenWidth-85,IS_IPAD?36:24)];
        _nameTextField.placeholder = @"请输入姓名";
        _nameTextField.text = self.userDetails.name;
        _nameTextField.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _nameTextField.font = [UIFont regularFontWithSize:16.0f];
        _nameTextField.delegate = self;
    }
    return _nameTextField;
}

#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(30,IS_IPAD?70:58,kScreenWidth-60,IS_IPAD?260:158)];
        if (kIsEmptyString(self.userDetails.cover)) {
            [_headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
        }else{
           [_headImgView sd_setImageWithURL:[NSURL URLWithString:self.userDetails.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
        }
    }
    return _headImgView;
}

#pragma mark 上传头像
-(UIButton *)uploadBtn{
    if (!_uploadBtn) {
        _uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(30,self.headImgView.bottom + 20,kScreenWidth-60, 40)];
        [_uploadBtn setImage:[UIImage imageNamed:@"photo_add"] forState:UIControlStateNormal];
        [_uploadBtn setTitle:@"重新上传" forState:UIControlStateNormal];
        [_uploadBtn setTitleColor:[UIColor colorWithHexString:@"#6D6D6D"] forState:UIControlStateNormal];
        _uploadBtn.titleLabel.font = [UIFont regularFontWithSize:14];
        _uploadBtn.layer.cornerRadius = 4.0;
        _uploadBtn.layer.borderColor = [UIColor colorWithHexString:@"#D8D8D8"].CGColor;
        _uploadBtn.layer.borderWidth = 1.0;
        [_uploadBtn addTarget:self action:@selector(uploadHeadPicAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _uploadBtn;
}


@end
