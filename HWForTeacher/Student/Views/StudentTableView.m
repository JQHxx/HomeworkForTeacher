//
//  StudentTableView.m
//  HWForTeacher
//
//  Created by vision on 2019/9/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import "StudentTableView.h"
#import "StudentTableViewCell.h"
#import "BlankView.h"

@interface StudentTableView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) BlankView  *blankView;

@end

@implementation StudentTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.tableFooterView = [[UIView alloc] init];
        self.showsVerticalScrollIndicator = NO;
        
        [self addSubview:self.blankView];
        self.blankView.hidden = YES;
    }
    return self;
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.studentsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdenditifier = @"HomeTableViewCell";
    StudentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdenditifier];
    if (cell==nil) {
        cell = [[StudentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenditifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    StudentModel *model = self.studentsArray[indexPath.row];
    cell.studentModel = model;
    
    cell.headImgView.tag = indexPath.row;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForStudentDetailsWithStudent:)];
    [cell.headImgView addGestureRecognizer:tap];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return IS_IPAD?100:80.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    StudentModel *model = self.studentsArray[indexPath.row];
    if ([self.viewDelegate respondsToSelector:@selector(studentTableViewDidSelectStudent:)]) {
        [self.viewDelegate studentTableViewDidSelectStudent:model];
    }
}

#pragma mark 查看详情
-(void)tapForStudentDetailsWithStudent:(UITapGestureRecognizer *)gesture{
    StudentModel *model = self.studentsArray[gesture.view.tag];
    if ([self.viewDelegate respondsToSelector:@selector(studentTableViewDidShowStudentDetailsWithStudent:)]) {
        [self.viewDelegate studentTableViewDidShowStudentDetailsWithStudent:model];
    }
}

-(void)setStudentsArray:(NSMutableArray *)studentsArray{
    _studentsArray = studentsArray;
    self.blankView.hidden = studentsArray.count>0;
}

#pragma mark 空白页
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, 200) img:@"blank_student" msg:@"暂无我的学生"];
    }
    return _blankView;
}

@end
