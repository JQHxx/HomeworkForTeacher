//
//  StudentTableViewCell.h
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StudentModel.h"


@interface StudentTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView    *headImgView;       //头像

@property (nonatomic,strong)StudentModel *studentModel;

@end


