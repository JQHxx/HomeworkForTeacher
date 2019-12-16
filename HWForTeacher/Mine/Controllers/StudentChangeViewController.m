//
//  StudentChangeViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import "StudentChangeViewController.h"
#import "ChangeTableViewCell.h"
#import "BlankView.h"
#import "SlideMenuView.h"
#import "BlankView.h"
#import <MJRefresh/MJRefresh.h>

@interface StudentChangeViewController ()<UITableViewDataSource,UITableViewDelegate,SlideMenuViewDelegate>

@property (nonatomic,strong) SlideMenuView     *menuView;
@property (nonatomic,strong) UITableView       *myTableView;
@property (nonatomic,strong) BlankView         *blankView;

@property (nonatomic,strong) NSMutableArray  *studentsArray;
@property (nonatomic,assign) NSInteger       type;
@property (nonatomic,assign) NSInteger       page;

@end

@implementation StudentChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"我的学生变动";
    
    self.page = 1;
    self.type = 0;
    
    [self.view addSubview:self.menuView];
    [self.view addSubview:self.myTableView];
    [self.myTableView addSubview:self.blankView];
    self.blankView.hidden = YES;
    
    [self loadStudentsChangeData];
}


#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.studentsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdenditifier = @"ChangeTableViewCell";
    ChangeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdenditifier];
    if (cell==nil) {
        cell = [[ChangeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenditifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ChangeModel *model = self.studentsArray[indexPath.row];
    cell.changeModel = model;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return IS_IPAD?110:80.0;
}

#pragma mark SlideMenuViewDelegate
-(void)slideMenuView:(SlideMenuView *)menuView didSelectedWithIndex:(NSInteger)index{
    self.type = index;
    [self loadStudentsChangeData];
}


#pragma mark -- Private methods
#pragma mark 加载数据
-(void)loadStudentsChangeData{
    NSDictionary *params = @{@"token":kUserTokenValue,@"type":[NSNumber numberWithInteger:self.type],@"page":[NSNumber numberWithInteger:self.page],@"pagesize":@20};
    [[HttpRequest sharedInstance] postWithURLString:kStudentChangeAPI parameters:params success:^(id responseObject) {
        NSArray *data = [responseObject objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in data) {
            ChangeModel *model = [[ChangeModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        
        if (self.page==1) {
            self.studentsArray = tempArr;
        }else{
            [self.studentsArray addObjectsFromArray:tempArr];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.myTableView.mj_footer.hidden = tempArr.count<20;
            [self.myTableView.mj_header endRefreshing];
            [self.myTableView.mj_footer endRefreshing];
            self.blankView.hidden = self.studentsArray.count>0;
            [self.myTableView reloadData];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.myTableView.mj_header endRefreshing];
            [self.myTableView.mj_footer endRefreshing];
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 加载最新
-(void)loadNewStudentChangeData{
    self.page = 1;
    [self loadStudentsChangeData];
}

#pragma mark 加载更多
-(void)loadMoreStudentChangeData{
    self.page++;
    [self loadStudentsChangeData];
}

#pragma mark -- Getters
#pragma mark 菜单栏
-(SlideMenuView *)menuView{
    if (!_menuView) {
        _menuView = [[SlideMenuView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth,IS_IPAD?56:40) btnTitleFont:[UIFont regularFontWithSize:13] color:[UIColor colorWithHexString:@"#9495A0"] selColor:[UIColor colorWithHexString:@"#FF5353"]];
        _menuView.backgroundColor = [UIColor colorWithHexString:@"#F6F6FA"];
        _menuView.selectTitleFont = [UIFont regularFontWithSize:13.0f];
        _menuView.lineWidth = 0;
        _menuView.myTitleArray = [NSMutableArray arrayWithArray:@[@"全部",@"转入",@"转出"]];
        _menuView.currentIndex = self.type;
    }
    return _menuView;
}

#pragma mark 变动
-(UITableView *)myTableView{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.menuView.bottom, kScreenWidth, kScreenHeight-self.menuView.bottom) style:UITableViewStylePlain];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.tableFooterView = [[UIView alloc] init];
        _myTableView.showsVerticalScrollIndicator = NO;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewStudentChangeData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _myTableView.mj_header=header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreStudentChangeData)];
        footer.automaticallyRefresh = NO;
        _myTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _myTableView;
}

#pragma mark 空白页
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, 200) img:@"blank_student" msg:@"暂无学生变动"];
    }
    return _blankView;
}

-(NSMutableArray *)studentsArray{
    if (!_studentsArray) {
        _studentsArray = [[NSMutableArray alloc] init];
    }
    return _studentsArray;
}

@end
