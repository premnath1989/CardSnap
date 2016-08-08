//
//  CircleView.m
//  BankRight
//
//  Created by Rambabu N on 8/25/14.
//  Copyright (c) 2014 WIN Information Technology. All rights reserved.
//

#import "CircleView.h"
#define FINAL_VALUE 6.2831853072
@implementation CircleView
@synthesize percentNumber;
@synthesize isShow;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(3, 4, 29, 26)];
    label.font = [UIFont fontWithName:@"Helvetica" size:11];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    if (isShow) {
        NSMutableString* percentString = [[NSMutableString alloc] initWithFormat:@"%d",[percentNumber intValue]];
        [percentString appendString:@"%"];
        label.text = [percentString copy];
    }else{
        label.text = @"NA";
    }
    [self addSubview:label];
    if ([percentNumber floatValue]==0) {
        CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
        label.textColor = [UIColor lightGrayColor];
    }else if ([percentNumber floatValue]<=50.00) {
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:255.0f/255.0f green:0.0f blue:0.0f alpha:1.0f] CGColor]);
        label.textColor = [UIColor colorWithRed:255.0f/255.0f green:0.0f blue:0.0f alpha:1.0f];
    }else if([percentNumber floatValue]<=100){
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:147.0f/255.0f green:187.0f/255.0f blue:0.0f alpha:1.0f] CGColor]);
        label.textColor = [UIColor colorWithRed:147.0f/255.0f green:187.0f/255.0f blue:0.0f alpha:1.0f];
    }
    
    CGFloat finalValue = FINAL_VALUE*([percentNumber floatValue]/100);
    UIBezierPath *blueHalf = [UIBezierPath bezierPathWithArcCenter:CGPointMake(17.5, 17.5) radius:14.5 startAngle:-M_PI_2 endAngle:finalValue-M_PI_2 clockwise:YES];
    [blueHalf setLineWidth:3.0];
    [blueHalf stroke];
    [blueHalf closePath];
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    
    UIBezierPath *redHalf = [UIBezierPath bezierPathWithArcCenter:CGPointMake(17.5, 17.5) radius:14.5 startAngle:finalValue-M_PI_2 endAngle:FINAL_VALUE-M_PI_2 clockwise:YES];
    [redHalf setLineWidth:3.0];
    [redHalf stroke];
    [redHalf closePath];
}

@end
