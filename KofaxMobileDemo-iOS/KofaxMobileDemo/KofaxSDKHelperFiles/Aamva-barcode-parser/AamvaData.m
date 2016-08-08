//
// Copyright (c) 2012-2014 Kofax. Use of this code is with permission pursuant to Kofax license terms.
//

#import "AamvaData.h"
#import "AamvaSubfile.h"
#import "AamvaSubfileHeader.h"

@implementation AamvaData

@synthesize header = _header;
@synthesize subfiles = _subfiles;

-(id)init:(NSString*)aamvaData
{
    self = [super init];
    self.subfiles = [[NSMutableDictionary alloc] init];
    self.header = [[AamvaHeader alloc] init:aamvaData];
    
    for (AamvaSubfileHeader* subfileHeader in self.header.subfileHeaders) {
        AamvaSubfile* subfile = [[AamvaSubfile alloc]
                                 init:aamvaData header:self.header subfileHeader:subfileHeader];
        [self.subfiles setObject:subfile forKey: subfile.subfileHeader.subfileType];
    }
    
    return self;
}

-(NSString*) getElement:(NSString*)subfileId elemId:(NSString*) elemId
{
    return [[self.subfiles objectForKey:subfileId] getEntry:elemId];
}

-(NSString*) getElement:(NSString*) elemId
{
    for (AamvaSubfile* subfile in [self.subfiles allValues]) {
        NSString* result = [self getElement:subfile.subfileHeader.subfileType elemId:elemId];
        if (result != nil)
            return result;
    }
    
    return nil;
}

+ (NSDate*) dateFromString:(NSString*)dateStr withFormat:(NSString*)fmt
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
	[dateFormatter setDateFormat:fmt];
	NSDate* d = [dateFormatter dateFromString:dateStr];
	
	return d;
}


+ (NSString*) stringFromDate:(NSDate*)date withFormat:(NSString*)fmt
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
	[dateFormatter setDateFormat:fmt];
	NSString* s = [dateFormatter stringFromDate:date];
	
	return s;
}

-(NSDate*) getElementAsDate:(NSString*) elemId
{
    for (AamvaSubfile* subfile in [self.subfiles allValues]) {
        NSString* result = [self getElement:subfile.subfileHeader.subfileType elemId:elemId];
        if (result != nil)
            return [self parseDate:result];
    }

    return nil;
}

-(NSDate*) getElementAsDate:(NSString*)subfileId elemId:(NSString*) elemId
{
    return [self parseDate:[self getElement:subfileId elemId:elemId]];
}


-(NSDate*) parseDate:(NSString*) date
{
    if (date == nil)
        return nil;
    
    if ([date length] != 8)
        return nil;
    
    @try {
        int firstTwo = (int)[[date substringWithRange:NSMakeRange(0, 2)] integerValue];
        NSString* fmt = nil;

        if (firstTwo >= 19) {
            fmt = @"yyyyMMdd";
        }
        else if (firstTwo <= 12) {
            fmt = @"MMddyyyy";
        }
        else {
           
            return nil;
        }
        
        NSDate *d = [AamvaData dateFromString:date withFormat:fmt];
        if ([date compare:[AamvaData stringFromDate:d withFormat:fmt]] != NSOrderedSame) {
            return nil;
        }
        return d;    
    }
    @catch (NSException *e) {
        
        return nil;
    }
    return nil;
}

@end
