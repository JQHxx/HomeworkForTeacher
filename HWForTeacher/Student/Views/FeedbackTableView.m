//
//  FeedbackTableView.m
//  HWForTeacher
//
//  Created by vision on 2019/9/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import "FeedbackTableView.h"
#import "FeedbackTableViewCell.h"
#import "BlankView.h"
#import "FeedbackModel.h"

@interface FeedbackTableView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) BlankView  *blankView;

@end

@implementation FeedbackTableView

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
    return self.feedbacksArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdenditifier = @"HomeTableViewCell";
    FeedbackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdenditifier];
    if (cell==nil) {
        cell = [[FeedbackTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenditifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    FeedbackModel *model = self.feedbacksArray[indexPath.row];
    cell.feedbackModel = model;
    
    cell.checkContentBtn.tag = indexPath.row;
    [cell.checkContentBtn addTarget:self action:@selector(checkFeedbackContentAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([model.status boolValue]) {
        cell.editFeedbackBtn.userInteractionEnabled = NO;
    }else{
        cell.editFeedbackBtn.userInteractionEnabled = YES;
        cell.editFeedbackBtn.tag = indexPath.row;
        [cell.editFeedbackBtn addTarget:self action:@selector(editFeedbackAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return IS_IPAD?100.0:80.0;
}

-(void)setFeedbacksArray:(NSMutableArray *)feedbacksArray{
    _feedbacksArray = feedbacksArray;
    
    self.blankView.hidden = feedbacksArray.count>0;
}

#pragma mark -- Event response
#pragma mark 查看反馈内容
-(void)checkFeedbackContentAction:(UIButton *)sender{
    FeedbackModel *model = self.feedbacksArray[sender.tag];
    if ([self.viewDelegate respondsToSelector:@selector(feedbackTableView:didCheckFeedbackContent:)]) {
        [self.viewDelegate feedbackTableView:self didCheckFeedbackContent:model];
    }
}

#pragma mark 填写辅导反馈
-(void)editFeedbackAction:(UIButton *)sender{
    FeedbackModel *model = self.feedbacksArray[sender.tag];
    if ([self.viewDelegate respondsToSelector:@selector(feedbackTableView:didEditCoachFeedback:)]) {
        [self.viewDelegate feedbackTableView:self didEditCoachFeedback:model];
    }
}

#pragma mark 空白页
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, 200) img:@"blank_feedback" msg:@"暂无辅导反馈～"];
    }
    return _blankView;
}

@end
