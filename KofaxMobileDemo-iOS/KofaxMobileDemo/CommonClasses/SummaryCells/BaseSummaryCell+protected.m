//
//  BaseTableViewCell+protected.m
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 22/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import "BaseSummaryCell+protected.h"


@interface BaseSummaryCell ()

@property (nonatomic,assign) NSMutableArray<NSString *> *array;

@end

@implementation BaseSummaryCell (protected)

- (void)awakeFromNib {
    // Initialization code
}

-(KMDKeyboardType)getKeyBoardType
{
    NSLog(@"%@",self.info);
    
    switch (self.info.keyBoardType.integerValue) {
        case 0:
            return KMDKeyboardTypeNone;
        case 1:
            return KMDKeyboardTypeDefault;
        case 2:
            return KMDKeyboardTypeNumber;
        case 10:
            return KMDKeyboardTypeDate;
        default:
            return KMDKeyboardTypeNone;
    }
    return KMDKeyboardTypeNone;
}

-(void)settingUpKeyBoardAndInputViews:(UITextField *)textField
{
    if (self.info.editable) {
        textField.borderStyle = UITextBorderStyleLine;
    }else{
        textField.borderStyle = UITextBorderStyleNone;
    }
    switch ([self getKeyBoardType]) {
        case KMDKeyboardTypeNone:
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.inputView = nil;
            textField.inputAccessoryView = nil;

            break;
        case KMDKeyboardTypeDefault:
            textField.inputView = nil;
            textField.inputAccessoryView = nil;
            break;
        case KMDKeyboardTypeNumber:
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField.inputView = nil;
            textField.inputAccessoryView = nil;
            break;
        case KMDKeyboardTypeDate:
        {
            [self setDatePickerViewForTextField:textField];
        }
            break;
        case KMDKeyboardTypePicker:
            [self setPickerViewForTextField:textField];
            break;
        default:
            textField.inputView = nil;
            textField.inputAccessoryView = nil;
            break;
    }
    [self setToolBarForTextField:textField];
}

-(void)setToolBarForTextField:(UITextField *)textField
{
    UIToolbar *toolBar = [self.delegate toolBarForIndexPath:self.indexPath];
    textField.inputAccessoryView = toolBar;
}

-(void)setDatePickerViewForTextField:(UITextField *)textField
{
    UIDatePicker *pickerView = (UIDatePicker *)[self.delegate datePickerForIndexPath:self.indexPath];
    [pickerView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    if (self.info.value && ![self.info.value isEqualToString:@""]) {
        pickerView.date = [[AppUtilities getDateFormatterOfLocale] dateFromString:self.info.value];
    }
    textField.inputView = pickerView;
}

-(void)dateChanged:(UIDatePicker*)sender
{
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(datePicker:forIndexPath:cell:)]) {
        [self.delegate datePicker:sender forIndexPath:self.indexPath cell:self];
    }
    else{
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        dateFormat = [AppUtilities getDateFormatterOfLocale];
        self.info.value = [dateFormat stringFromDate:sender.date];
        dateFormat = nil;
        [self updateChanges];
    }
}

-(void)setPickerViewForTextField:(UITextField *)textField
{
    UIPickerView *pickerView = (UIPickerView *)[self.delegate pickerViewForIndexPath:self.indexPath];
    pickerView.delegate = self;
    textField.inputView = pickerView;
}

// picker delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(numberOfComponentsInPickerView:forIndexPath:cell:)]) {
        return [self.delegate numberOfComponentsInPickerView:pickerView forIndexPath:self.indexPath cell:self];
    }else{
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(pickerView:numberOfRowsInComponent:forIndexPath:cell:)]) {
        return [self.delegate pickerView:pickerView numberOfRowsInComponent:component forIndexPath:self.indexPath cell:self];
    }
    else{
        return self.info.options.count;
    }
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(pickerView:titleForRow:forComponent:forIndexPath:cell:)]) {
        return [self.delegate pickerView:pickerView titleForRow:row forComponent:component forIndexPath:self.indexPath cell:self];
    }
    else{
        return self.info.options[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:forIndexPath:cell:)]) {
        [self.delegate pickerView:pickerView didSelectRow:row inComponent:component forIndexPath:self.indexPath cell:self];
    }
    else{
        self.info.value = self.info.options[row];
        [self updateChanges];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(textFieldShouldReturn:forIndexPath:cell:)]) {
        return [self.delegate textFieldShouldReturn:textField forIndexPath:self.indexPath cell:self];
    }else{
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(textFieldDidEndEditing:forIndexPath:cell:)]) {
        [self.delegate textFieldDidBeginEditing:textField forIndexPath:self.indexPath cell:self];
    }
    else{
        [self updateValue];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(textFieldDidEndEditing:forIndexPath:cell:)]) {
        [self.delegate textFieldDidEndEditing:textField forIndexPath:self.indexPath cell:self];
    }
    else{
        [self updateValue];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:forIndexPath:cell:)]) {
        return [self.delegate textFieldShouldBeginEditing:textField forIndexPath:self.indexPath cell:self];
    }
    else{
        if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(selectedCell:atIndexPath:)]) {
            [self.delegate selectedCell:self atIndexPath:self.indexPath];
        }
        return YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:forIndexPath:cell:)]) {
        return [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string forIndexPath:self.indexPath cell:self];
    }
    else{
        if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(selectedCell:atIndexPath:)]) {
            [self.delegate selectedCell:self atIndexPath:self.indexPath];
        }
        return YES;
    }
}

-(void)updateValue
{
    // override by child classes
}

-(void)updateChanges
{
    // override by child classes
}


@end
