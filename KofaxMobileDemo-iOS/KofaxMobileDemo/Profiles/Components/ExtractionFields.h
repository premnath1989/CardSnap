//
//  ExtractionFields.h
//  Kofax Mobile Demo
//
//  Created by Mahendra on 14/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtractInfo.h"

@interface ExtractionFields : NSObject
@property(readonly,nonatomic) NSDictionary * extractionFields;
-(id)initWithSettings:(NSDictionary *)settings componentType:(componentType)type withExtractionResult:(NSArray *)result;
-(void)modifyExtractionInfoForCD;
@end
