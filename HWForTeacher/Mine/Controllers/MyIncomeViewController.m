//
//  MyIncomeViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/26.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MyIncomeViewController.h"
#import "DetailsTableViewCell.h"
#import "DetailsModel.h"
#import "BlankView.h"
#import <MJRefresh/MJRefresh.h>

@interface MyIncomeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView      *amountHeadView;
@property (nonatomic, strong) UITableView *detailsTableView;
@property (nonatomic, strong) BlankView   *blankView;

@property (nonatomic,assign) NSInteger page;

@property (nonatomic,strong) NSMutableArray  *detailsArray;

@end

@implementation MyIncomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.page = 1;
    
    [self.view addSubview:self.detailsTableView];
    [self.detailsTableView addSubview:self.blankView];
    self.blankView.hidden = YES;
    
    if (self.type==2) {
        self.baseTitle = @"已到手金额";
        [self loadMyWalletDetailsData];
    }else{
        self.baseTitle = self.type == 0?@"预计收益":@"提成收益";
        [self loadPreIncomeDetailsData];
    }
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.detailsArray.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(20,10, 120,40)];
    lab.textColor = [UIColor commonColor_black];
    lab.font = [UIFont mediumFontWithSize:20];
    lab.text = @"明细";
    [aView addSubview:lab];
    return aView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdenditifier = @"DetailsTableViewCell";
    DetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdenditifier];
    if (cell==nil) {
        cell = [[DetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenditifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    DetailsModel *model = self.detailsArray[indexPath.row];
    [cell displayCellWithDetails:model type:self.type];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return IS_IPAD?100:66.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}

#pragma mark -- Private Methods
#pragma mark 加载到手金额明细
-(void)loadMyWalletDetailsData{
    [[HttpRequest sharedInstance] postWithURLString:kIncomeDetailsAPI parameters:@{@"token":kUserTokenValue,@"page":[NSNumber numberWithInteger:self.page],@"pagesize":@15} success:^(id responseObject) {
        NSArray *data = [responseObject objectForKey:@"data"];
        [self parseDetailsWithData:data];
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.detailsTableView.mj_header endRefreshing];
            [self.detailsTableView.mj_footer endRefreshing];
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 加载预计收益明细
-(void)loadPreIncomeDetailsData{
    NSDictionary *params = @{@"token":kUserTokenValue,@"page":[NSNumber numberWithInteger:self.page],@"pagesize":@15,@"label":[NSNumber numberWithInteger:self.type==0?0:2]};
    [[HttpRequest sharedInstance] postWithURLString:kPreIncomeDetailsAPI parameters:params success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSArray *list = [data valueForKey:@"list"];
        [self parseDetailsWithData:list];
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.detailsTableView.mj_header endRefreshing];
            [self.detailsTableView.mj_footer endRefreshing];
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 更新界面
-(void)parseDetailsWithData:(NSArray *)data{
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in data) {
        DetailsModel *model = [[DetailsModel alloc] init];
        [model setValues:dict];
        [tempArr addObject:model];
    }
    if (self.page==1) {
        self.detailsArray = tempArr;
    }else{
        [self.detailsArray addObjectsFromArray:tempArr];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.detailsTableView.mj_footer.hidden = tempArr.count<15;
        self.blankView.hidden = self.detailsArray.count>0;
        [self.detailsTableView.mj_header endRefreshing];
        [self.detailsTableView.mj_footer endRefreshing];
        [self.detailsTableView reloadData];
    });
}

#pragma mark 加载最新明细
-(void)loadNewDetailsListData{
    self.page = 1;
    if (self.type==2) {
        [self loadMyWalletDetailsData];
    }else{
        [self loadPreIncomeDetailsData];
    }
}

#pragma mark 加载更多明细
-(void)loadMoreDetailsListData{
    self.page++;
    if (self.type==2) {
        [self loadMyWalletDetailsData];
    }else{
        [self loadPreIncomeDetailsData];
    }
}

#pragma mark -- Getters
#pragma mark 头部
-(UIView *)amountHeadView{
    if (!_amountHeadView) {
        _amountHeadView = [[UIView alloc] initWithFrame:CGRectZero];
        
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,IS_IPAD?210:170)];
        bgImgView.image = [UIImage imageNamed:@"my_wallet_background"];
        [_amountHeadView addSubview:bgImgView];
        
        NSArray *tipsTitleArray = @[@"预计收益",@"提成收益",@"已到手金额"];
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(IS_IPAD?55:40, 35, 200,IS_IPAD?32:20)];
        titleLab.textColor = [UIColor whiteColor];
        titleLab.font = [UIFont mediumFontWithSize:18];
        titleLab.text = tipsTitleArray[self.type];
        [_amountHeadView addSubview:titleLab];
         
        UILabel *valueLab = [[UILabel alloc] initWithFrame:CGRectMake(IS_IPAD?55:40, titleLab.bottom+20, kScreenWidth-150,IS_IPAD?54:42)];
        valueLab.font = [UIFont mediumFontWithSize:42];
        valueLab.textColor = [UIColor whiteColor];
        valueLab.text = [NSString stringWithFormat:@"%.2f",self.amount];
        [_amountHeadView addSubview:valueLab];
        
        UILabel *tipsTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(25, bgImgView.bottom,kScreenWidth-60,IS_IPAD?42:30)];
        tipsTitleLab.text = [NSString stringWithFormat:@"%@包括：",tipsTitleArray[self.type]];
        tipsTitleLab.font = [UIFont mediumFontWithSize:14];
        tipsTitleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [_amountHeadView addSubview:tipsTitleLab];
        
        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        tipsLabel.font = [UIFont regularFontWithSize:14];
        tipsLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        tipsLabel.numberOfLines = 0;
        
       NSArray *tipsArray = @[@"1、学生付费后的部分辅导费用；\n2、学生是您成单后的一个10%的提成费用；\n3、其他老师成单后，转给您辅导的剩余的部分辅导费用",@"学生是您成单后的一个10%的提成费用",@"1、学生辅导费用按天结算到账；\n2、提成费用按天结算到账。"];
        NSString *labelText = tipsArray[self.type];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:2];
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
        tipsLabel.attributedText = attributedString;
        
        CGFloat tipsH = [labelText boundingRectWithSize:CGSizeMake(kScreenWidth-50, CGFLOAT_MAX) withTextFont:tipsLabel.font].height;
        tipsLabel.frame = CGRectMake(25, tipsTitleLab.bottom, kScreenWidth-50, tipsH+10);
        [_amountHeadView addSubview:tipsLabel];
        
        _amountHeadView.frame = CGRectMake(0, 0, kScreenWidth, tipsH+(IS_IPAD?260:220));
        
    }
    return _amountHeadView;
}

#pragma mark 明细
-(UITableView *)detailsTableView{
    if (!_detailsTableView) {
        _detailsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStylePlain];
        _detailsTableView.dataSource = self;
        _detailsTableView.delegate = self;
        _detailsTableView.tableHeaderView = self.amountHeadView;
        _detailsTableView.tableFooterView = [[UIView alloc] init];
        _detailsTableView.showsVerticalScrollIndicator = NO;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewDetailsListData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _detailsTableView.mj_header=header;
          
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDetailsListData)];
        footer.automaticallyRefresh = NO;
        _detailsTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _detailsTableView;
}

-(BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc] initWithFrame:CGRectMake(0,IS_IPAD?400:320, kScreenWidth, 200) img:@"blank_money" msg:@"暂无收益记录哟～"];
    }
    return _blankView;
}


-(NSMutableArray *)detailsArray{
    if (!_detailsArray) {
        _detailsArray = [[NSMutableArray alloc] init];
    }
    return _detailsArray;
}

@end
