//
//  UnsuccessTableViewCell.m
//  HWForTeacher
//
//  Created by vision on 2019/9/29.
//  Copyright © 2019 vision. All rights reserved.
//

#import "UnsuccessTableViewCell.h"

@interface UnsuccessTableViewCell ()



@end

@implementation UnsuccessTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-60)/2,20, 60, 60)];
        imgView.image=[UIImage imageNamed:@"unsuccess"];
        [self.contentView addSubview:imgView];
        
        UILabel *descLab=[[UILabel alloc] initWithFrame:CGRectMake(20, imgView.bottom+10, kScreenWidth-40,IS_IPAD?32:20)];
        descLab.textAlignment=NSTextAlignmentCenter;
        descLab.text=@"暂未给您分配学生";
        descLab.font=[UIFont regularFontWithSize:14.0f];
        descLab.textColor=[UIColor colorWithHexString:@"#9495A0"];
        [self.contentView addSubview:descLab];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
