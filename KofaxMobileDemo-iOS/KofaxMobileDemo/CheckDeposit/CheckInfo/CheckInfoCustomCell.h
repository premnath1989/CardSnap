//
//  CheckInfoCustomCell.h
//  BankRight
//
//  Created by Rambabu N on 8/18/14.
//  Copyright (c) 2014 WIN Information Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleView.h"
#import "ExtractInfo.h"
#import "Localization.h"
#define HelveticaBold(x)  [UIFont fontWithName:@"HelveticaNeue-Bold" size:x]

@interface CheckInfoCustomCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *valueLabel,*leftLabel,*leftLabelWithoutCircle,*valueLabelWithoutCircle;
@property (nonatomic,strong) IBOutlet UITextField *valueTextField;
@property (nonatomic, strong) IBOutlet CircleView *circleView;
@property (nonatomic, strong) IBOutlet UIView *withCircleView,*withoutCircleView;
@property (nonatomic, strong) ExtractInfo *extractInfo;
@property (nonatomic, strong) Localization *localization;

-(void)setttingupUIForSelectedSegment:(int)segmentIndex withIndexPath:(NSIndexPath *)indexPath;
@end
