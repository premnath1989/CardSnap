//
//  CheckHistoryCustomCell.h
//  BankRight
//
//  Created by Rambabu N on 8/19/14.
//  Copyright (c) 2014 WIN Information Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckHistoryCustomCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *amountLabel,*micrLabel,*checkLabel,*dateLabel,*timeLabel;
@property (nonatomic, strong) IBOutlet UIImageView *frontImage,*backImage;
@property (weak, nonatomic) IBOutlet UILabel *micrTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkNoTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountTitleLabel;
@end
