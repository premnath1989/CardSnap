//
//  SummaryEtitableCell.m
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 22/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import "SummaryEtitableCell.h"
#import "BaseSummaryCell+protected.h"


@interface SummaryEtitableCell ()

@end

@implementation SummaryEtitableCell
@synthesize info = _info;
@synthesize labelTitle = _labelTitle;
@synthesize textFieldValue = _textFieldValue;
@synthesize viewConfidence = _viewConfidence;

- (void)awakeFromNib {
    // Initialization code
    [AppUtilities adjustFontSizeOfLabel:_labelTitle];
    [AppUtilities reduceFontOfTextField:_textFieldValue];
}

-(void)setInfo:(ExtractInfo *)extractInfo
{
    _info = extractInfo;
    
    [self updateChanges];
    
    [self settingUpKeyBoardAndInputViews:_textFieldValue];

}

-(void)updateChanges
{
    // assigning Left label and textfield value
    
    _labelTitle.text = Klm(_info.name);
    _textFieldValue.text = _info.value;
    
    [AppUtilities reduceFontOfTextField:_textFieldValue];
    
    // set textField Style and editable mode
    _textFieldValue.enabled = _info.editable;
    
    // set confidence circle
    [_viewConfidence setPercentNumber:_info.confidence.stringValue];
    _viewConfidence.isShow = YES;
    [_viewConfidence setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateValue
{
    _info.value = _textFieldValue.text;
}

-(void)beginEditing
{
    [_textFieldValue becomeFirstResponder];
}


@end
