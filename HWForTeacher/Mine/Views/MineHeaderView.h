//
//  MineHeaderView.h
//  Homework
//
//  Created by vision on 2019/9/9.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@protocol MineHeaderViewDelegate <NSObject>

//个人资料
-(void)mineHeaderViewDidEditUserInfo;
//请假
-(void)mineHeaderViewLeave;

@end

@interface MineHeaderView : UIView

@property (nonatomic, weak ) id<MineHeaderViewDelegate>delegate;

@property (nonatomic,strong) UserModel   *userModel;

@end

