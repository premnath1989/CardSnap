//
//  BillPayInfoCustomCell.m
//  
//
//
//  
//

#import "BillPayInfoCustomCell.h"

@implementation BillPayInfoCustomCell
@synthesize valueLabel,leftLabel,leftLabelWithoutCircle,valueLabelWithoutCircle;
@synthesize circleView;
@synthesize withCircleView,withoutCircleView;
- (void)awakeFromNib
{
    // Initialization code
    [AppUtilities adjustFontSizeOfLabel:leftLabelWithoutCircle];
    [AppUtilities adjustFontSizeOfLabel:valueLabelWithoutCircle];
    [AppUtilities reduceFontOfTextField:self.valueTextField];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
