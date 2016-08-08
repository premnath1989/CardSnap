//
//  BaseSummaryCell.h
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 22/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtractInfo.h"

typedef enum : NSUInteger {
    PrevClicked,
    NextClicked,
    DoneCLicked,
} ToolBarActionType;

@protocol BaseSummaryCellProtocol <NSObject>

// data source
@optional
-(UIToolbar *)toolBarForIndexPath:(NSIndexPath *)indexPath;
-(UIDatePicker *)datePickerForIndexPath:(NSIndexPath *)indexPath;
-(UIDatePicker *)pickerViewForIndexPath:(NSIndexPath *)indexPath;
//delegate
-(void)selectedCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
// picker delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell;
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell;

// datePicker delegate
-(void)datePicker:(UIDatePicker*)sender forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell;

// textField Delegates Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell;
- (void)textFieldDidBeginEditing:(UITextField *)textField forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell;
- (void)textFieldDidEndEditing:(UITextField *)textField forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell;
- (BOOL)textFieldShouldReturn:(UITextField *)textField forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell;
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string forIndexPath:(NSIndexPath*)indexpath cell:(UITableViewCell*)cell;

@end


@interface BaseSummaryCell : UITableViewCell

-(void)beginEditing;
-(void)updateValue;
-(void)updateChanges;

@property(nonatomic,assign) id <BaseSummaryCellProtocol> delegate;
@property(nonatomic,strong) NSIndexPath *indexPath;

@property(nonatomic) ExtractInfo *info;

@end
