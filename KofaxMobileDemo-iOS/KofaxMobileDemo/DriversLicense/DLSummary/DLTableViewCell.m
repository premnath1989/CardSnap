//
//  DLTableViewCell.m
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 17/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import "DLTableViewCell.h"

@implementation DLTableViewCell
@synthesize lblTitle;
@synthesize txtFieldValue;

- (void)awakeFromNib
{
    // Initialization code
    [AppUtilities adjustFontSizeOfLabel:self.lblTitle];
    [AppUtilities reduceFontOfTextField:self.txtFieldValue];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
