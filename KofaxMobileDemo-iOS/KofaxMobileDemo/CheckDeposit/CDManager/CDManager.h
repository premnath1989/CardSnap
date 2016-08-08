//
//  BillPayManager.h
//  BankRight
//
//  Created by kaushik on 02/07/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseFlowManager.h"

@class  Component;

@interface CDManager : BaseFlowManager

-(void)loadCheckDepositManager:(UINavigationController*)appNavController andComponent:(Component*)currentComponent;
-(void)unloadCheckDepositManager;

@end
