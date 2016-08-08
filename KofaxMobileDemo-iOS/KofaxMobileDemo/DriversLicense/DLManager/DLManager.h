//
//  DLManager.h
//  KofaxMobileDemo
//
//  Created by Mahendra on 31/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseFlowManager.h"
#import "DLInstructionsViewController.h"

@interface DLManager : BaseFlowManager<DLInstructionsProtocol>
{
    
}

@property (nonatomic,readonly)  NSArray * resultArray;

@end
