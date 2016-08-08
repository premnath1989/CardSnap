//
//  CheckHistoryCustomCell.m
//  BankRight
//
//  Created by Rambabu N on 8/19/14.
//  Copyright (c) 2014 WIN Information Technology. All rights reserved.
//

#import "CheckHistoryCustomCell.h"

@implementation CheckHistoryCustomCell
@synthesize checkLabel,micrLabel,amountLabel,dateLabel,timeLabel;
@synthesize frontImage,backImage;
- (void)awakeFromNib
{
    // Initialization code
    [self.micrTitleLabel setText:Klm(@"MICR:")];
    [AppUtilities adjustFontSizeOfLabel:self.micrTitleLabel];
    [self.checkNoTitleLabel setText:Klm(@"Check No:")];
    [AppUtilities adjustFontSizeOfLabel:self.checkNoTitleLabel];
    [self.amountTitleLabel setText:Klm(@"Amount:")];
    [AppUtilities adjustFontSizeOfLabel:self.amountTitleLabel];
    [self.dateTitleLabel setText:Klm(@"Date:")];
    [AppUtilities adjustFontSizeOfLabel:self.dateTitleLabel];
    [AppUtilities adjustFontSizeOfLabel:self.micrLabel];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
