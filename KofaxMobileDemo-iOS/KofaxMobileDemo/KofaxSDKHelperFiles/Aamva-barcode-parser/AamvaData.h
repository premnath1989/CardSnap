//
// Copyright (c) 2012-2014 Kofax. Use of this code is with permission pursuant to Kofax license terms.
//

#import <Foundation/Foundation.h>
#import "AamvaHeader.h"

@interface AamvaData : NSObject

@property(strong, nonatomic) AamvaHeader* header;
@property(strong, nonatomic) NSMutableDictionary* subfiles;

-(id)init:(NSString*)aamvaData;
-(NSString*) getElement:(NSString*)subfileId elemId:(NSString*) elemId;
-(NSString*) getElement:(NSString*) elemId;

-(NSDate*) getElementAsDate:(NSString*) elemId;
-(NSDate*) getElementAsDate:(NSString*)subfileId elemId:(NSString*) elemId;

+ (NSDate*) dateFromString:(NSString*)dateStr withFormat:(NSString*)fmt;
-(NSDate*) parseDate:(NSString*) date;

@end
