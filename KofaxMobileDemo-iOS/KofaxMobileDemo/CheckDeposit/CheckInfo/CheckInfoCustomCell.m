//
//  CheckInfoCustomCell.m
//  BankRight
//
//  Created by Rambabu N on 8/18/14.
//  Copyright (c) 2014 WIN Information Technology. All rights reserved.
//

#import "CheckInfoCustomCell.h"

@implementation CheckInfoCustomCell
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

-(void)setValuesForSelectedSegment:(int)segmentIndex withIndexPath:(NSIndexPath *)indexPath extractionInfo:(ExtractInfo *)info
{
    _extractInfo = info;
    
    [self setttingupUIForSelectedSegment:segmentIndex withIndexPath:indexPath];
    
    if (segmentIndex == 0) {
        leftLabel.text = Klm(info.name);
        if([info.name isEqualToString:[_localization.summaryText valueForKey:AMOUNT]] ||
           [info.name isEqualToString:@"Routing No."] ||
           [info.name isEqualToString:@"Account No."] || [info.name isEqualToString:@"Date"] ||
           [info.name isEqualToString:@"Check Number"] || [info.name isEqualToString:@"Payee name"])
        {
            valueLabel.hidden = YES;
            self.valueTextField.hidden = NO;
            self.tag = indexPath.row;

        }

    }
}

-(void)setttingupUIForSelectedSegment:(int)segmentIndex withIndexPath:(NSIndexPath *)indexPath
{
    leftLabel.font = HelveticaBold(16);
    valueLabel.font = HelveticaBold(16);
    _valueTextField.font = HelveticaBold(16);
    leftLabelWithoutCircle.font = HelveticaBold(16);
    valueLabelWithoutCircle.font = HelveticaBold(16);

    if (segmentIndex == 0) {
        
        withCircleView.hidden = NO;
        withoutCircleView.hidden = YES;
        [circleView setPercentNumber:_extractInfo.confidence.stringValue];
        if (indexPath.row==0) {
            circleView.isShow = NO;
        }else{
            circleView.isShow = YES;
        }
        [circleView setNeedsDisplay];
        
        if([_extractInfo.name isEqualToString:[_localization.summaryText valueForKey:AMOUNT]] ||
           [_extractInfo.name isEqualToString:@"Routing No."] ||
           [_extractInfo.name isEqualToString:@"Account No."] || [_extractInfo.name isEqualToString:@"Date"] ||
           [_extractInfo.name isEqualToString:@"Check Number"] || [_extractInfo.name isEqualToString:@"Payee name"])
        {
            valueLabel.hidden = YES;
            _valueTextField.hidden = NO;
            _valueTextField.tag = indexPath.row;
        }
        else{
            _valueTextField.hidden = YES;
            valueLabel.hidden = NO;
            valueLabel.text = [_extractInfo.value capitalizedString];
        }
    }
    else{
        withCircleView.hidden = YES;
        withoutCircleView.hidden = NO;
    }
}

@end
