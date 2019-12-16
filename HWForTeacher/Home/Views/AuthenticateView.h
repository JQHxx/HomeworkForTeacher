//
//  AuthenticateView.h
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@protocol AuthenticateViewDelegate <NSObject>

-(void)authenticateViewDidClickBtn:(NSInteger)btnTag step:(NSInteger)step;

@end

@interface AuthenticateView : UIView

@property (nonatomic,assign) NSInteger selectStep;
@property (nonatomic,strong) UserModel *userModel;

@property (nonatomic, weak ) id<AuthenticateViewDelegate>delegate;

@end


