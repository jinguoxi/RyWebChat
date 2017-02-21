//
//  MALocationCell.m
//  SocketDemo
//
//  Created by nwk on 2017/1/10.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "MALocationCell.h"

@implementation MALocationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
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
