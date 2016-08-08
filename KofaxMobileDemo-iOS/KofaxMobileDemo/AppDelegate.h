//
//  AppDelegate.h
//  KofaxMobileDemo
//
//  Created by Mahendra on 30/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <kfxLibUtilities/kfxUtilities.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic,strong) kfxKUTAppStatistics *appStatsObj;
@end

