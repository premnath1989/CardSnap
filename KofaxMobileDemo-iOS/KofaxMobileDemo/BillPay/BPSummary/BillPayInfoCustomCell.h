//
//  BillPayInfoCustomCell.h
//
//
//  
//  
//

#import <UIKit/UIKit.h>
#import "CircleView.h"
@interface BillPayInfoCustomCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *valueLabel,*leftLabel,*leftLabelWithoutCircle,*valueLabelWithoutCircle;
@property (nonatomic,strong) IBOutlet UITextField *valueTextField;
@property (nonatomic, strong) IBOutlet CircleView *circleView;
@property (nonatomic, strong) IBOutlet UIView *withCircleView,*withoutCircleView;
@end
