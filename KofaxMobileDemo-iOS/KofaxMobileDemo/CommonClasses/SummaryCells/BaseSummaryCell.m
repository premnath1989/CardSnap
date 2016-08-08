//
//  BaseSummaryCell.m
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 22/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import "BaseSummaryCell.h"


@implementation BaseSummaryCell
@synthesize info = _info;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)beginEditing
{
    // override by child cells
}

@end
