//
//  AddBankCardViewController.m
//  HWForTeacher
//
//  Created by vision on 2018/9/6.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "AddBankCardViewController.h"
#import "BindBankCardViewController.h"
#import "WLCardNoFormatter.h"
#import "BankModel.h"

@interface AddBankCardViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    NSArray       *titlesArr;
}

@property (nonatomic , strong) UITableView *addBankTableView;
@property (nonatomic , strong) UILabel     *tipsLabel;
@property (nonatomic , strong) UIButton    *nextButton;
@property ( nonatomic, strong) WLCardNoFormatter *cardNoFormatter;

@property (nonatomic,strong) UITextField    *cardholderTextField;
@property (nonatomic,strong) UITextField    *bankCardTextField;

@end

@implementation AddBankCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle = @"添加银行卡";
    
    titlesArr = @[@"持卡人",@"银行卡号"];
    
    [self.view addSubview:self.addBankTableView];
    [self.view addSubview:self.tipsLabel];
    [self.view addSubview:self.nextButton];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titlesArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = titlesArr[indexPath.row];
    cell.textLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:IS_IPAD?25:16];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    
    UITextField *textfield = [[UITextField alloc] initWithFrame:IS_IPAD?CGRectMake(166, 21, kScreenWidth-180, 36):CGRectMake(106, 15, kScreenWidth-120, 22)];
    textfield.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:IS_IPAD?25:16];
    textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    textfield.placeholder = indexPath.row==0?@"请填写持卡人姓名":@"请输入银行卡号";
    textfield.delegate = self;
    textfield.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    [cell.contentView addSubview:textfield];
    if (indexPath.row==0) {
        self.cardholderTextField = textfield;
    }else{
        self.bankCardTextField = textfield;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  IS_IPAD?80:50;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPAD) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 39, 0, 38)];
    }else{
        [cell setSeparatorInset:UIEdgeInsetsMake(0,21, 0, 0)];
    }
}

#pragma mark -- Delegate
#pragma mark UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.bankCardTextField) {
        [self.cardNoFormatter bankNoField:textField shouldChangeCharactersInRange:range replacementString:string];
        return NO;
    }
    return YES;
}

#pragma mark -- Event Response
#pragma mark 下一步
-(void)nextStepAction{
    NSString *cardNum = [self.bankCardTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[HttpRequest sharedInstance] postWithURLString:kSearchBankAPI parameters:@{@"card":cardNum} success:^(id responseObject) {
        NSString *cardName = [responseObject objectForKey:@"data"];
        NSArray *cardsArr = [cardName componentsSeparatedByString:@"-"];
        if ([cardName isEqualToString:@"该卡号信息暂未录入"]||cardsArr.count==0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:@"请输入正确的持卡人姓名和卡号" duration:1.0 position:CSToastPositionCenter];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                BankModel *bank = [[BankModel alloc] init];
                bank.bankType = cardsArr[2];
                bank.cardHolder = self.cardholderTextField.text;
                bank.bankNum = self.bankCardTextField.text;
                bank.bankName = cardsArr[0];
                
                BindBankCardViewController *bindBankCardVC = [[BindBankCardViewController alloc] init];
                bindBankCardVC.bank = bank;
                [self.navigationController pushViewController:bindBankCardVC animated:YES];
            });
        }
    } failure:^(NSString *errorStr) {
       dispatch_async(dispatch_get_main_queue(), ^{
           [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
       });
    }];
}

#pragma mark -- getters and setters
-(UITableView *)addBankTableView{
    if (!_addBankTableView) {
        _addBankTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight+10, kScreenWidth, kScreenHeight-kNavHeight-10) style:UITableViewStylePlain];
        _addBankTableView.dataSource = self;
        _addBankTableView.delegate = self;
        _addBankTableView.scrollEnabled = NO;
        _addBankTableView.tableFooterView = [[UIView alloc] init];
    }
    return _addBankTableView;
}

#pragma mark 下一步
-(UIButton *)nextButton{
    if (!_nextButton) {
        _nextButton = [[UIButton alloc] initWithFrame:CGRectMake(48,kNavHeight+190,kScreenWidth-96,IS_IPAD?52:40)];
        [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        _nextButton.backgroundColor = [UIColor commonColor_red];
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _nextButton.layer.cornerRadius = 20;
        _nextButton.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
        [_nextButton addTarget:self action:@selector(nextStepAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

#pragma mark 说明
-(UILabel *)tipsLabel{
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake(50,self.nextButton.bottom+10, kScreenWidth-100, 30):CGRectMake(25, self.nextButton.bottom+10,kScreenWidth-50, 20)];
        _tipsLabel.text = @"*请绑定持卡人本人的银行卡";
        _tipsLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:IS_IPAD?22:14];
        _tipsLabel.textColor = [UIColor colorWithHexString:@"#E42A2A"];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipsLabel;
}

-(WLCardNoFormatter *)cardNoFormatter{
    if (!_cardNoFormatter) {
        _cardNoFormatter = [[WLCardNoFormatter alloc] init];
    }
    return _cardNoFormatter;
}

@end
