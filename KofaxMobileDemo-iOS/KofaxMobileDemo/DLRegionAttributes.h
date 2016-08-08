//
//  DLRegionAttributes.h
//  KofaxMobileDemo
//
//  Created by Kofax on 5/25/15.
//  Copyright (c) 2016 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLRegionAttributes : NSObject

@property (nonatomic, strong) NSString *strDisplayRegion; // Stores the region/ Country name to be displayed for UI
@property (nonatomic, strong) NSString *xRegion; // Stores the region name to be specified to server
@property (nonatomic, strong) NSString *xState; // Stores the State name or Country to be specified to server
@property (nonatomic, strong) NSString *strImageResize; // Stores the ID based on which resize of image is done.

@end
