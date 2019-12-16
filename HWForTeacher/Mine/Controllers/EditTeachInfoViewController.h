//
//  EditTeachInfoViewController.h
//  HWForTeacher
//
//  Created by vision on 2019/9/28.
//  Copyright © 2019 vision. All rights reserved.
//

#import "BaseViewController.h"

@protocol EditTeachInfoViewControllerDelegate <NSObject>

-(void)editTeachInfoViewControllerDidSaveTeachInfo:(NSString *)teachText type:(NSString *)type;

@end


@interface EditTeachInfoViewController : BaseViewController

@property (nonatomic, weak ) id<EditTeachInfoViewControllerDelegate>delgate;
@property (nonatomic, copy ) NSString  *titleStr;
@property (nonatomic, copy ) NSString  *teachInfo;

@end


