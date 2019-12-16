//
//  MyWalletViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MyWalletViewController.h"
#import "WithdrawViewController.h"
#import "MyIncomeViewController.h"
#import "WalletModel.h"

@interface MyWalletViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray      *titlesArr;
}

@property (nonatomic,strong) UIView       *headerView;
@property (nonatomic,strong) UITableView  *walletTableView;

@property (nonatomic,strong) WalletModel  *walletInfo;

@property (nonatomic,strong) UILabel      *amountLabel;

@end

@implementation MyWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"我的钱包";
    
    titlesArr = @[@"预计总收益",@"预计提成收益"];
    
    [self.view addSubview:self.walletTableView];
    [self loadMyWalletData];
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titlesArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(25, 32, 220,IS_IPAD?27:15)];
    titleLab.textColor = [UIColor colorWithHexString:@"#303030"];
    titleLab.font = [UIFont mediumFontWithSize:18];
    titleLab.text = titlesArr[indexPath.row];
    [cell.contentView addSubview:titleLab];
    
    UILabel *detailsLab = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-240, 28, 200,IS_IPAD?38:26)];
    detailsLab.font = [UIFont mediumFontWithSize:26.0f];
    detailsLab.textColor = [UIColor colorWithHexString:@"#FF5353"];
    detailsLab.textAlignment = NSTextAlignmentRight;
    NSString *detailStr = nil;
    if (indexPath.row==0) {
        detailStr = [NSString stringWithFormat:@"¥%.2f",[self.walletInfo.predict_money doubleValue]>0.0?[self.walletInfo.predict_money doubleValue]:0.0];
    }else{
        detailStr = [NSString stringWithFormat:@"¥%.2f",[self.walletInfo.amort_money doubleValue]>0.0?[self.walletInfo.amort_money doubleValue]:0.0];
    }
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:detailStr];
    [attributeStr addAttribute:NSFontAttributeName value:[UIFont regularFontWithSize:16] range:NSMakeRange(0, 1)];
    detailsLab.attributedText = attributeStr;
    [cell.contentView addSubview:detailsLab];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-30, 36, 9, 16)];
    imgView.image = [UIImage imageNamed:@"my_arrow_black"];
    [cell.contentView addSubview:imgView];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MyIncomeViewController *myIncomeVC = [[MyIncomeViewController alloc] init];
    myIncomeVC.type = indexPath.row;
    myIncomeVC.amount = indexPath.row==0?[self.walletInfo.predict_money doubleValue]:[self.walletInfo.amort_money doubleValue];
    [self.navigationController pushViewController:myIncomeVC animated:YES];
}

#pragma mark -- Event response
#pragma mark 提现
-(void)withdrawAction:(UIButton *)sender{
    WithdrawViewController *withdrawVC = [[WithdrawViewController alloc] init];
    withdrawVC.withdraw_amount = [self.walletInfo.withdraw_money doubleValue];
    [self.navigationController pushViewController:withdrawVC animated:YES];
}

#pragma mark 明细
-(void)checkBillDetailsAction:(UIButton *)sender{
    MyIncomeViewController *myIncomeVC = [[MyIncomeViewController alloc] init];
    myIncomeVC.type = 2;
    myIncomeVC.amount = [self.walletInfo.money doubleValue];
    [self.navigationController pushViewController:myIncomeVC animated:YES];
}

#pragma mark -- Private methods
#pragma mark 加载数据
-(void)loadMyWalletData{
    [[HttpRequest sharedInstance] postWithURLString:kMyWalletAPI parameters:@{@"token":kUserTokenValue} success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        [self.walletInfo setValues:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.amountLabel.text = [NSString stringWithFormat:@"¥%.2f",[self.walletInfo.money doubleValue]>0.0?[self.walletInfo.money doubleValue]:0.0];
            [self.walletTableView reloadData];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- Getters
#pragma mark 头部视图
-(UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,IS_IPAD?210:170)];
        
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:_headerView.bounds];
        bgImgView.image = [UIImage imageNamed:@"my_wallet_background"];
        [_headerView addSubview:bgImgView];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake(55, 40, 200, 32):CGRectMake(40, 35, 180,20)];
        titleLab.textColor = [UIColor whiteColor];
        titleLab.font = [UIFont mediumFontWithSize:18];
        titleLab.text = @"已到手金额";
        [_headerView addSubview:titleLab];
        
        UIButton *detailsBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-160, 33, 120, 36):CGRectMake(kScreenWidth-110, 33, 90,24)];
        [detailsBtn setImage:[UIImage drawImageWithName:@"detailed" size:IS_IPAD?CGSizeMake(24, 24):CGSizeMake(20, 20)] forState:UIControlStateNormal];
        [detailsBtn setTitle:@"明细" forState:UIControlStateNormal];
        [detailsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        detailsBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        detailsBtn.titleLabel.font = [UIFont mediumFontWithSize:16];
        [detailsBtn addTarget:self action:@selector(checkBillDetailsAction:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:detailsBtn];
        
        UILabel *valueLab = [[UILabel alloc] initWithFrame:CGRectMake(50, titleLab.bottom+20, kScreenWidth-150,IS_IPAD?54:42)];
        valueLab.font = [UIFont mediumFontWithSize:42];
        valueLab.textColor = [UIColor whiteColor];
        [_headerView addSubview:valueLab];
        self.amountLabel = valueLab;
        
        UIButton *withdrawBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-152, valueLab.top+10, 94, 40):CGRectMake(kScreenWidth-102, valueLab.top+10, 74,28)];
        [withdrawBtn setTitle:@"提现 >" forState:UIControlStateNormal];
        [withdrawBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        withdrawBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
        withdrawBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:withdrawBtn.size direction:IHGradientChangeDirectionLevel startColor:[UIColor colorWithHexString:@"#624AFF"] endColor:[UIColor colorWithHexString:@"#2F5FFF"]];
        [withdrawBtn setBorderWithCornerRadius:14 type:UIViewCornerTypeAll];
        [withdrawBtn addTarget:self action:@selector(withdrawAction:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:withdrawBtn];
        
    }
    return _headerView;
}

#pragma mark 钱包
-(UITableView *)walletTableView{
    if (!_walletTableView) {
        _walletTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStylePlain];
        _walletTableView.delegate = self;
        _walletTableView.dataSource = self;
        _walletTableView.tableHeaderView = self.headerView;
        _walletTableView.tableFooterView = [[UIView alloc] init];
    }
    return _walletTableView;
}

-(WalletModel *)walletInfo{
    if (!_walletInfo) {
        _walletInfo = [[WalletModel alloc] init];
    }
    return _walletInfo;
}

@end
