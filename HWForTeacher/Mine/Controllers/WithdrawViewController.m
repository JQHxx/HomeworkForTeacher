//
//  WithdrawViewController.m
//  HWForTeacher
//
//  Created by vision on 2018/9/5.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "WithdrawViewController.h"
#import "BankCardListViewController.h"
#import "AddBankCardViewController.h"
#import "NonBankCardView.h"
#import "BankCardView.h"
#import "BankModel.h"

@interface WithdrawViewController ()<UITextFieldDelegate>{
    UITextField    *withdrawTextField;
    UILabel        *balanceLabel;
    
    
}

@property (nonatomic, strong) NonBankCardView  *nonCardView;
@property (nonatomic, strong) BankCardView     *cardView;
@property (nonatomic, strong) UIView           *withdrawView;

@property (nonatomic, strong) BankModel        *myBank;
@property (nonatomic, strong) UIButton         *confirmBtn;

@end

@implementation WithdrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"提现";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    self.myBank = [[BankModel alloc] init];
    
    
    [self initWithdrawView];
    [self loadWithdrawData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([ZYHelper sharedZYHelper].isUpdateWithdraw){
        [self loadWithdrawData];
        [ZYHelper sharedZYHelper].isUpdateWithdraw = NO;
    }
}

#pragma mark -- event response
#pragma mark 确定
-(void)confirmWithrawAction{
    if (kIsEmptyString(self.myBank.bankName)||kIsEmptyString(self.myBank.bankNum)) {
        [self.view makeToast:@"请先添加银行卡" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    double money = [withdrawTextField.text doubleValue];
    if (kIsEmptyString(withdrawTextField.text)||money==0) {
        [self.view makeToast:@"请输入提现金额" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    if (money>self.withdraw_amount) {
        [self.view makeToast:@"提现金额不能超过可提现余额" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    NSDictionary *params = @{@"token":kUserTokenValue,@"card":self.myBank.bankNum,@"money":[NSNumber numberWithDouble:money]};
    [[HttpRequest sharedInstance] postWithURLString:kWalletExtractAPI parameters:params success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.view makeToast:@"您的提现申请已提交，请等待审核" duration:1.0 position:CSToastPositionCenter];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           [self.navigationController popViewControllerAnimated:YES];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
   
}

#pragma mark 选择银行卡
-(void)selectBankCardAction{
    BankCardListViewController *bankCardListVC = [[BankCardListViewController alloc] init];
    kSelfWeak;
    bankCardListVC.backBlock = ^(id object) {
        weakSelf.cardView.bank = (BankModel *)object;
    };
    [self.navigationController pushViewController:bankCardListVC animated:YES];
}

#pragma mark 全部提现
-(void)allWithdrawAction:(UIButton *)sender{
    withdrawTextField.text = [NSString stringWithFormat:@"%.2f",self.withdraw_amount];
}

#pragma mark -- UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."]invertedSet];
    // allow backspace
    if (range.length > 0 && [string length] == 0) {
        return YES;
    }
    // do not allow . at the beggining
    if (range.location == 0 && [string isEqualToString:@"."]) {
        return NO;
    }
    
    NSString *currentText = textField.text;  //当前确定的那个输入框
    if ([string isEqualToString:@"."]&&[currentText rangeOfString:@"." options:NSBackwardsSearch].length == 0) {
        
    }else if([string isEqualToString:@"."]&&[currentText rangeOfString:@"." options:NSBackwardsSearch].length== 1) {
        string = @"";
        //alreay has a decimal point
    }
    if ([currentText containsString:@"."]) {
        NSInteger pointLo = [textField.text rangeOfString:@"."].location;
        if (currentText.length-pointLo>2) {
            string = @"";
        }
    }
    // set the text field value manually
    NSString *newValue = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    newValue = [[newValue componentsSeparatedByCharactersInSet:nonNumberSet]componentsJoinedByString:@""];
    textField.text = newValue;
    return NO;
}

#pragma mark -- Private Methods
#pragma mark 初始化
-(void)initWithdrawView{
    [self.view addSubview:self.nonCardView];
    self.nonCardView.hidden = YES;
    [self.view addSubview:self.cardView];
    self.cardView.hidden = YES;
    [self.view addSubview:self.withdrawView];
}

#pragma mark 加载提现信息
-(void)loadWithdrawData{
    [[HttpRequest sharedInstance] postWithURLString:kWalletExtractPageAPI parameters:@{@"token":kUserTokenValue} success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSDictionary *bank = [data valueForKey:@"bank"];
        if (kIsDictionary(bank)&&bank.count>0) {
            self.myBank.bankName = bank[@"bank"];
            self.myBank.bankNum = bank[@"card_no"];
            NSString *cardCode = bank[@"label"];
            if (kIsEmptyString(cardCode)) {
                self.myBank.cardImage = @"bank";
                self.myBank.cardBgImage = @"bank2";
            }else{
                self.myBank.cardImage = cardCode;
                self.myBank.cardBgImage = [NSString stringWithFormat:@"%@2",cardCode];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.withdrawView.hidden = NO;
                self.cardView.hidden = NO;
                self.nonCardView.hidden = YES;
                self.cardView.bank = self.myBank;
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.withdrawView.hidden = NO;
                self.cardView.hidden = YES;
                self.nonCardView.hidden = NO;
            });
        }
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- getters
#pragma mark 无银行卡
-(NonBankCardView *)nonCardView{
    if (!_nonCardView) {
        _nonCardView = [[NonBankCardView alloc] initWithFrame:IS_IPAD?CGRectMake(12, kNavHeight+12, kScreenWidth-24, 136):CGRectMake(10, kNavHeight+10, kScreenWidth-20, 85)];
        kSelfWeak;
        _nonCardView.clickAction = ^{
            AddBankCardViewController *addBankCardVC = [[AddBankCardViewController alloc] init];
            [weakSelf.navigationController pushViewController:addBankCardVC animated:YES];
        };
    }
    return _nonCardView;
}

#pragma mark 银行卡
-(BankCardView *)cardView{
    if (!_cardView) {
        _cardView = [[BankCardView alloc] initWithFrame:IS_IPAD?CGRectMake(16, kNavHeight+15, kScreenWidth-32, 130):CGRectMake(10, kNavHeight+10, kScreenWidth-20, 85)];
        _cardView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBankCardAction)];
        [_cardView addGestureRecognizer:tap];
    }
    return _cardView;
}

#pragma mark 提现金额
-(UIView *)withdrawView{
    if (!_withdrawView) {
        _withdrawView = [[UIView alloc] initWithFrame:CGRectMake(0, self.cardView.bottom+10, kScreenWidth, kScreenHeight-self.cardView.bottom-10)];
        _withdrawView.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake(58, 21.4, 110, 36):CGRectMake(25, 14, 100, 22)];
        titleLab.font = [UIFont mediumFontWithSize:16];
        titleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        titleLab.text = @"提现金额";
        [_withdrawView addSubview:titleLab];
        
        UILabel *unitLab = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake(61,titleLab.bottom+17,28, 65):CGRectMake(27, titleLab.bottom+13, 18, 42)];
        unitLab.text = @"¥";
        unitLab.font = [UIFont mediumFontWithSize:30];
        unitLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [_withdrawView addSubview:unitLab];
        
        withdrawTextField = [[UITextField alloc] initWithFrame:IS_IPAD?CGRectMake(unitLab.right+23, titleLab.bottom+17, kScreenWidth-unitLab.right-50, 65):CGRectMake(unitLab.right+15, titleLab.bottom+13, kScreenWidth-unitLab.right-30, 42)];
        withdrawTextField.returnKeyType = UIReturnKeyDone;
        withdrawTextField.keyboardType = UIKeyboardTypeDecimalPad;
        withdrawTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        withdrawTextField.font = [UIFont mediumFontWithSize:30];
        withdrawTextField.placeholder = @"0.00";
        withdrawTextField.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        withdrawTextField.delegate = self;
        [_withdrawView addSubview:withdrawTextField];
        
        //全部提现
        UIButton *allBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-140, titleLab.bottom+30, 110,38):CGRectMake(kScreenWidth-100, titleLab.bottom+20, 70, 26)];
        [allBtn setTitle:@"全部提现" forState:UIControlStateNormal];
        [allBtn setTitleColor:[UIColor colorWithHexString:@"#6D6D6D"] forState:UIControlStateNormal];
        allBtn.layer.cornerRadius = 4.0;
        allBtn.layer.borderWidth = 1.0;
        allBtn.layer.borderColor = [UIColor colorWithHexString:@"#C5C6CF"].CGColor;
        allBtn.titleLabel.font = [UIFont regularFontWithSize:14.0f];
        [allBtn addTarget:self action:@selector(allWithdrawAction:) forControlEvents:UIControlEventTouchUpInside];
        [_withdrawView addSubview:allBtn];
        
        UIView *lineView = [[UIView alloc] initWithFrame:IS_IPAD?CGRectMake(40, withdrawTextField.bottom, kScreenWidth-80, 0.5):CGRectMake(22.5, withdrawTextField.bottom, kScreenWidth-45, 0.5)];
        lineView.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [_withdrawView addSubview:lineView];
        
        balanceLabel = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake(55, lineView.bottom+21, kScreenWidth-110, 30):CGRectMake(23, lineView.bottom+12, kScreenWidth-46, 20)];
        balanceLabel.font = [UIFont regularFontWithSize:14];
        balanceLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        balanceLabel.text = [NSString stringWithFormat:@"可提现金额：¥%.2f",self.withdraw_amount];
        [_withdrawView addSubview:balanceLabel];
        
        self.confirmBtn =  [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-300)/2.0,balanceLabel.bottom+60, 300, 62)];
        [self.confirmBtn setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
        [self.confirmBtn setTitle:@"完成" forState:UIControlStateNormal];
        [self.confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.confirmBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
        [self.confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.confirmBtn.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
        [self.confirmBtn addTarget:self action:@selector(confirmWithrawAction) forControlEvents:UIControlEventTouchUpInside];
        [_withdrawView addSubview:self.confirmBtn];
        
        
        UILabel *tipsTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(25, self.confirmBtn.bottom+50, 120,30)];
        tipsTitleLab.text = @"提现须知";
        tipsTitleLab.font = [UIFont mediumFontWithSize:14];
        tipsTitleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [_withdrawView addSubview:tipsTitleLab];
        
        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        tipsLabel.font = [UIFont regularFontWithSize:14];
        tipsLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        tipsLabel.numberOfLines = 0;
        
        NSString *labelText = @"1、每月15日为上个月可提现金额提现日；\n2、提现到账时间为一个工作日；\n3、本月已到手金额不计入可提现金额。";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5];
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
        tipsLabel.attributedText = attributedString;
        
        CGFloat tipsH = [labelText boundingRectWithSize:CGSizeMake(kScreenWidth-50, CGFLOAT_MAX) withTextFont:tipsLabel.font].height;
        tipsLabel.frame = CGRectMake(25, tipsTitleLab.bottom, kScreenWidth-50, tipsH+30);
        [_withdrawView addSubview:tipsLabel];
    }
    return _withdrawView;
}

@end
