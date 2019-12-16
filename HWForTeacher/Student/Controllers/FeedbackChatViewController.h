//
//  FeedbackChatViewController.h
//  HWForTeacher
//
//  Created by vision on 2019/10/16.
//  Copyright © 2019 vision. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "FeedbackModel.h"

@interface FeedbackChatViewController : RCConversationViewController

@property (nonatomic,strong) FeedbackModel *feedbackModel;

@end

