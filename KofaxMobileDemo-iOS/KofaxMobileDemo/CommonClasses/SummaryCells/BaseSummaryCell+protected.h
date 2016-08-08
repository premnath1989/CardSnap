//
//  BaseTableViewCell+protected.h
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 22/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseSummaryCell.h"

typedef enum : NSUInteger {
    KMDKeyboardTypeNone,
    KMDKeyboardTypeDefault,
    KMDKeyboardTypeNumber,
    KMDKeyboardTypeDate,
    KMDKeyboardTypePicker,
} KMDKeyboardType;


@interface BaseSummaryCell (protected)<UIPickerViewDelegate,UIPickerViewDataSource>
-(KMDKeyboardType)getKeyBoardType;
-(void)settingUpKeyBoardAndInputViews:(UITextField *)textField;
-(void)updateValue;
-(void)updateChanges;
@end

