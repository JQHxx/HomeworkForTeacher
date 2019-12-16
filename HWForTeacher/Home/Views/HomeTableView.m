//
//  HomeTableView.m
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import "HomeTableView.h"
#import "HomeTableViewCell.h"
#import "UnsuccessTableViewCell.h"

@interface HomeTableView ()<UITableViewDelegate,UITableViewDataSource>


@end

@implementation HomeTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.tableFooterView = [[UIView alloc] init];
        self.showsVerticalScrollIndicator = NO;
        self.scrollEnabled = NO;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.studentsArray.count>0?self.studentsArray.count:1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(22, 12, 200, 20)];
    lab.textColor = [UIColor commonColor_black];
    lab.font = [UIFont mediumFontWithSize:17];
    lab.text = @"未成单学生";
    [aView addSubview:lab];
    return aView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.studentsArray.count>0) {
        static NSString *cellIdenditifier = @"HomeTableViewCell";
        HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdenditifier];
        if (cell==nil) {
            cell = [[HomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenditifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        StudentModel *model = self.studentsArray[indexPath.row];
        cell.studentModel = model;
        
        return cell;
    }else{
        UnsuccessTableViewCell *cell = [[UnsuccessTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.studentsArray.count>0) {
        return IS_IPAD?108:78;
    }else{
       return 180.0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.studentsArray.count>0) {
        StudentModel *model = self.studentsArray[indexPath.row];
        if ([self.viewDelegate respondsToSelector:@selector(homeTableViewDidSelectStudent:)]) {
            [self.viewDelegate homeTableViewDidSelectStudent:model];
        }
    }
}

-(void)setStudentsArray:(NSMutableArray *)studentsArray{
    _studentsArray = studentsArray;
    [self reloadData];
}

@end
