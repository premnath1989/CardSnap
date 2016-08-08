//
//  KFXSegmentedControl.m
//  KofaxMobileDemo
//
//  Created by Kofax on 12/11/15.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import "KFXSegmentedControl.h"

@implementation KFXSegmentedControl


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    CGPoint viewPoint = [self convertPoint:locationPoint fromView:self];
    
    // add touch up inside/outside events
    if ([self pointInside:viewPoint withEvent:event]) {
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else {
        [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
    }
}

@end
