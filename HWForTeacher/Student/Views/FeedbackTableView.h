//
//  FeedbackTableView.h
//  HWForTeacher
//
//  Created by vision on 2019/9/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedbackModel.h"

@class FeedbackTableView;

@protocol FeedbackTableViewDelegate <NSObject>

//查看辅导内容
-(void)feedbackTableView:(FeedbackTableView *)tableView didCheckFeedbackContent:(FeedbackModel *)model;
//填写辅导反馈
-(void)feedbackTableView:(FeedbackTableView *)tableView didEditCoachFeedback:(FeedbackModel *)model;

@end


@interface FeedbackTableView : UITableView

@property (nonatomic, weak ) id<FeedbackTableViewDelegate>viewDelegate;

@property (nonatomic,strong) NSMutableArray *feedbacksArray;


@end


