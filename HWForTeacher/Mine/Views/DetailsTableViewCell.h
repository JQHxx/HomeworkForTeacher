//
//  DetailsTableViewCell.h
//  HWForTeacher
//
//  Created by vision on 2019/9/26.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailsModel.h"

@interface DetailsTableViewCell : UITableViewCell

@property (nonatomic,strong) DetailsModel *detailsModel;

-(void)displayCellWithDetails:(DetailsModel *)detailsModel type:(NSInteger)type;

@end

