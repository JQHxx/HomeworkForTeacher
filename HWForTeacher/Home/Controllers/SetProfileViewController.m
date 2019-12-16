//
//  SetProfileViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import "SetProfileViewController.h"
#import "UITextView+ZWPlaceHolder.h"
#import "UITextView+ZWLimitCounter.h"
#import "UserModel.h"

@interface SetProfileViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate>{
    NSArray   *titlesArr;
}

@property (nonatomic,strong) UITableView  *profileTableView;
@property (nonatomic,strong) UIView       *bottomView;
@property (nonatomic,strong) UIButton     *confirmBtn;

@property (nonatomic,strong) UITextField  *nameTextField;
@property (nonatomic,strong) UITextField  *tagsTextField1;
@property (nonatomic,strong) UITextField  *tagsTextField2;
@property (nonatomic,strong) UIButton     *uploadBtn;
@property (nonatomic,strong) UITextView   *experienceTextView; //教学经历
@property (nonatomic,strong) UITextView   *styleTextView;  //教学风格
@property (nonatomic,strong) UITextView   *ideaTextView;  //教育理念

@property (nonatomic,strong) UserModel    *userInfo;

@property (nonatomic, copy ) NSString    *headPicUrl;


@end

@implementation SetProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle = @"个人资料";
    self.rightImageName = @"tutor_service";
    
    self.userInfo = [[UserModel alloc] init];
    
    titlesArr = @[@"姓名",@"我的标签",@"上传照片",@"教学经历",@"教学风格",@"教育理念"];
    
    [self.view addSubview:self.profileTableView];
    self.profileTableView.tableFooterView = self.bottomView;
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
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(tagView.right+8, 22,IS_IPAD?120:75,IS_IPAD?30:18)];
    titleLab.font = [UIFont mediumFontWithSize:18];
    titleLab.textColor = [UIColor colorWithHexString:@"#303030"];
    titleLab.text = titlesArr[indexPath.row];
    [cell.contentView addSubview:titleLab];
    
    if (indexPath.row==0) {
        self.nameTextField.text = kIsEmptyString(self.userInfo.name)?@"":self.userInfo.name;
        [cell.contentView addSubview:self.nameTextField];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(self.nameTextField.right,titleLab.bottom+15,IS_IPAD?60:35,IS_IPAD?36:24)];
        lab.font = [UIFont regularFontWithSize:16];
        lab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        lab.text = @"老师";
        [cell.contentView addSubview:lab];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(25, lab.bottom+5, kScreenWidth-(IS_IPAD?100:50), 1)];
        line.backgroundColor = [UIColor colorWithHexString:@"#EAEBF0"];
        [cell.contentView addSubview:line];
        
    }else if (indexPath.row==1) {
        UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(titleLab.right+8, 25,kScreenWidth-titleLab.right-20,IS_IPAD?30:18)];
        tipsLab.font = [UIFont regularFontWithSize:12];
        tipsLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        tipsLab.text = @"*每个标签不能超过10个汉字";
        [cell.contentView addSubview:tipsLab];
        
        NSArray *arr = @[@"例如：x年教龄",@"例如：幽默风趣"];
        for (NSInteger i=0; i<arr.count; i++) {
            UITextField *tagsTextField = [[UITextField alloc] initWithFrame:CGRectMake(25,titleLab.bottom+18+(IS_IPAD?62:50)*i, kScreenWidth-50,IS_IPAD?34:22)];
            tagsTextField.placeholder = arr[i];
            tagsTextField.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
            tagsTextField.font = [UIFont regularFontWithSize:16.0f];
            tagsTextField.delegate = self;
            [cell.contentView addSubview:tagsTextField];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(25, tagsTextField.bottom+7, kScreenWidth-50, 1)];
            line.backgroundColor = [UIColor colorWithHexString:@"#EAEBF0"];
            [cell.contentView addSubview:line];
            
            if (i==0) {
                self.tagsTextField1 = tagsTextField;
                self.tagsTextField1.text = kIsEmptyString(self.userInfo.tag1)?@"":self.userInfo.tag1;
            }else{
                self.tagsTextField2 = tagsTextField;
                self.tagsTextField2.text = kIsEmptyString(self.userInfo.tag2)?@"":self.userInfo.tag2;
            }
        }
    }else if (indexPath.row==2){
        [cell.contentView addSubview:self.uploadBtn];
    }else{
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(30, titleLab.bottom+18, kScreenWidth-60,IS_IPAD?240:160)];
        textView.backgroundColor = [UIColor colorWithHexString:@"#F1F1F5"];
        textView.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        textView.font = [UIFont regularFontWithSize:14];
        textView.layer.cornerRadius = 8.0;
        textView.zw_limitCount = 300;
        textView.zw_labHeight  = 30;
        textView.delegate = self;
        textView.zw_placeHolder = [NSString stringWithFormat:@"请输入您的%@",titlesArr[indexPath.row]];
        [cell.contentView addSubview:textView];
        
        if (indexPath.row==3) {
            self.experienceTextView = textView;
            self.experienceTextView.text = kIsEmptyString(self.userInfo.experience)?@"":self.userInfo.experience;
        }else if (indexPath.row==4){
            self.styleTextView = textView;
            self.styleTextView.text = kIsEmptyString(self.userInfo.style)?@"":self.userInfo.style;
        }else{
            self.ideaTextView = textView;
            self.ideaTextView.text = kIsEmptyString(self.userInfo.idea)?@"":self.userInfo.idea;
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return IS_IPAD?112:88;
    }else if (indexPath.row==1){
        return IS_IPAD?180:144;
    }else if (indexPath.row==2){
        return IS_IPAD?340:215;
    }else{
        return IS_IPAD?314:224;
    }
}

#pragma mark UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField==self.nameTextField) {
        self.userInfo.name = textField.text;
    }else if (textField==self.tagsTextField1){
        self.userInfo.tag1 = textField.text;
    }else if (textField==self.tagsTextField2){
        self.userInfo.tag2 = textField.text;
    }
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
        if ([textField.text length]<20) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark UITextViewDelegate
-(void)textViewDidEndEditing:(UITextView *)textView{
    if (textView==self.experienceTextView) {
        self.userInfo.experience = textView.text;
    }else if (textView==self.styleTextView){
        self.userInfo.style = textView.text;
    }else{
        self.userInfo.idea = textView.text;
    }
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([textView isFirstResponder]) {
        if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textView textInputMode] primaryLanguage]) {
            return NO;
        }
        
        //判断键盘是不是九宫格键盘
        if ([[ZYHelper sharedZYHelper] isNineKeyBoard:text] ){
            return YES;
        }else{
            if ([[ZYHelper sharedZYHelper] hasEmoji:text] || [[ZYHelper sharedZYHelper] strIsContainEmojiWithStr:text]){
                return NO;
            }
        }
    }
    
    if ([textView.text length]+text.length>200) {
        return NO;
    }else{
        return YES;
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
        self.headPicUrl = [responseObject objectForKey:@"data"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.uploadBtn setBackgroundImage:curImage forState:UIControlStateNormal];
            [self.uploadBtn setImage:nil forState:UIControlStateNormal];
            [self.uploadBtn setTitle:nil forState:UIControlStateNormal];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- Event response
#pragma mark 上传头像
-(void)uploadHeadPicAction:(UIButton *)sender{
    [self addPhoto];
}

#pragma mark 完成
-(void)completeSetProfileAction:(UIButton *)sender{
    if (kIsEmptyString(self.nameTextField.text)) {
        [self.view makeToast:@"姓名不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(self.tagsTextField1.text)||kIsEmptyString(self.tagsTextField2.text)) {
        [self.view makeToast:@"我的标签不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(self.headPicUrl)) {
        [self.view makeToast:@"请先上传头像" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(self.experienceTextView.text)) {
        [self.view makeToast:@"教学经历不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(self.styleTextView.text)) {
        [self.view makeToast:@"教学风格不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(self.ideaTextView.text)) {
        [self.view makeToast:@"教育理念不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    self.confirmBtn.userInteractionEnabled = NO;
    NSArray *tags = @[self.tagsTextField1.text,self.tagsTextField2.text];
    NSString *labelStr = [[ZYHelper sharedZYHelper] getValueWithParams:tags];
    NSDictionary *params = @{@"token":kUserTokenValue,@"name":self.nameTextField.text,@"cover":self.headPicUrl,@"label":labelStr,@"experience":self.experienceTextView.text,@"style":self.styleTextView.text,@"idea":self.ideaTextView.text};
    [[HttpRequest sharedInstance] postWithURLString:kSetUserInfoAPI parameters:params success:^(id responseObject) {
        [ZYHelper sharedZYHelper].isUpdateHome = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.view makeToast:@"个人资料提交成功，请等待审核" duration:1.0 position:CSToastPositionCenter];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.confirmBtn.userInteractionEnabled = YES;
           [self.navigationController popViewControllerAnimated:YES];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.confirmBtn.userInteractionEnabled = YES;
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 联系客服
-(void)rightNavigationItemAction{
    [self pushToCustomerServiceVC];
}

#pragma mark -- Getters
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
        _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(25,IS_IPAD?65:55, kScreenWidth-85,IS_IPAD?36:24)];
        _nameTextField.placeholder = @"请输入姓名";
        _nameTextField.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _nameTextField.font = [UIFont regularFontWithSize:16.0f];
        _nameTextField.delegate = self;
    }
    return _nameTextField;
}

#pragma mark 上传头像
-(UIButton *)uploadBtn{
    if (!_uploadBtn) {
        _uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(30,IS_IPAD?70:58,kScreenWidth-60,IS_IPAD?260:158)];
        [_uploadBtn setBackgroundImage:[UIImage imageNamed:@"id_photo"] forState:UIControlStateNormal];
        [_uploadBtn setImage:[UIImage drawImageWithName:@"certificate_add" size:IS_IPAD?CGSizeMake(111, 105):CGSizeMake(74, 70)] forState:UIControlStateNormal];
        [_uploadBtn setTitle:@"如图所示，照片要求正装照" forState:UIControlStateNormal];
        [_uploadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _uploadBtn.titleLabel.font = [UIFont regularFontWithSize:12];
        _uploadBtn.imageEdgeInsets = UIEdgeInsetsMake(-(_uploadBtn.height - _uploadBtn.titleLabel.height- _uploadBtn.titleLabel.y-54),(_uploadBtn.width-_uploadBtn.imageView.width)/2.0, 0, 0);
        _uploadBtn.titleEdgeInsets = UIEdgeInsetsMake(_uploadBtn.imageView.height+_uploadBtn.imageView.y-15, -_uploadBtn.imageView.width, 0, 0);
        [_uploadBtn addTarget:self action:@selector(uploadHeadPicAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _uploadBtn;
}

#pragma mark
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 128)];
        
       _confirmBtn =  [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-300)/2.0,40, 300, 62)];
       [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
       [_confirmBtn setTitle:@"完成" forState:UIControlStateNormal];
       [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
       _confirmBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
       [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.titleEdgeInsets =UIEdgeInsetsMake(-10, 0, 0, 0);
       [_confirmBtn addTarget:self action:@selector(completeSetProfileAction:) forControlEvents:UIControlEventTouchUpInside];
       [_bottomView addSubview:_confirmBtn];
    }
    return _bottomView;
}

@end
