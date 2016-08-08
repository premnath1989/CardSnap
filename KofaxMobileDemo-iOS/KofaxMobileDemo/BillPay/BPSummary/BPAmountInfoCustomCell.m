//
//  BPAmountInfoCustomCell.m

//

#import "BPAmountInfoCustomCell.h"

@implementation BPAmountInfoCustomCell
@synthesize valueLabel,leftLabel,leftLabelWithoutCircle,valueLabelWithoutCircle;
@synthesize circleView;
@synthesize withCircleView,withoutCircleView;
- (void)awakeFromNib
{
    // Initialization code
    [AppUtilities adjustFontSizeOfLabel:leftLabelWithoutCircle];
    [AppUtilities adjustFontSizeOfLabel:valueLabelWithoutCircle];
    [AppUtilities reduceFontOfTextField:self.valueTextField];
    [AppUtilities adjustFontSizeOfLabel:self.dueLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setKeyboardTypeForKey:(NSString *)key
{
    if ([key isEqualToString:@"AmountDue"]||[key isEqualToString:@"Zip"]) {
        self.valueTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    else if([key isEqualToString:@"PhoneNumber"])
    {
        self.valueTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
    else{
        self.valueTextField.keyboardType = UIKeyboardTypeDefault;
    }
}

@end

