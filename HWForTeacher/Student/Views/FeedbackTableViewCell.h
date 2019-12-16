//
//  FeedbackTableViewCell.h
//  HWForTeacher
//
//  Created by vision on 2019/9/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedbackModel.h"


@interface FeedbackTableViewCell : UITableViewCell

@property (strong, nonatomic) UIButton   *checkContentBtn;    //查看辅导内容
@property (strong, nonatomic) UIButton   *editFeedbackBtn;    //填写辅导反馈

@property (nonatomic,strong) FeedbackModel *feedbackModel;



@end

