//
//  BPAmountInfoCustomCell.h
//
//
//  
//

#import <UIKit/UIKit.h>
#import "CircleView.h"
@interface BPAmountInfoCustomCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *valueLabel,*leftLabel,*leftLabelWithoutCircle,*valueLabelWithoutCircle,*dueLabel;
@property (nonatomic,strong) IBOutlet UITextField *valueTextField;
@property (nonatomic, strong) IBOutlet CircleView *circleView;
@property (nonatomic, strong) IBOutlet UIView *withCircleView,*withoutCircleView;
-(void)setKeyboardTypeForKey:(NSString *)key;
@end


