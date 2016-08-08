//
//  SummaryEtitableCell.h
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 22/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseSummaryCell.h"
#import "CircleView.h"

@interface SummaryEtitableCell : BaseSummaryCell
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UITextField *textFieldValue;
@property (weak, nonatomic) IBOutlet CircleView *viewConfidence;
@end
