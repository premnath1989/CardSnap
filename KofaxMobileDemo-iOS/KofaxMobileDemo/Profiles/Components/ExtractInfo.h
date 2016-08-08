//
//  ExtractInfo.h
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 11/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface ExtractInfo : NSObject
@property(readonly,nonatomic) NSString *name;
@property(readonly,nonatomic) NSString *key;
@property(readonly,nonatomic) NSNumber *confidence;
@property(readonly,nonatomic) BOOL editable;
@property(readonly,nonatomic) NSNumber *keyBoardType;
@property(readonly,nonatomic) NSArray<NSString *> *options;
@property(readonly,nonatomic) CGRect coordinates;
@property(readonly,nonatomic) NSInteger pageIndex;

@property(strong,nonatomic) NSString *value;

-(id)initWithDictionary: (NSDictionary *)dictInfo;
-(void)updateConfidence:(NSString *)confidence;
-(void)updateCoordinatesAndPageIndex:(NSDictionary*)dictInfo;

@property(strong,nonatomic) NSString *test;

@end
