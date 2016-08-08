//
//  BPManager.h
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/3/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Component.h"
#import "BaseFlowManager.h"

@interface BPManager : BaseFlowManager
-(void)loadBillPayManager:(UINavigationController*)appNavController andComponent:(Component*)currentComponent;
-(void)unloadBillPayManager;
@end
