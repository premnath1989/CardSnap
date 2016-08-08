//
// Copyright (c) 2012-2014 Kofax. Use of this code is with permission pursuant to Kofax license terms.
//

#import "AamvaSubfileHeader.h"

@implementation AamvaSubfileHeader

@synthesize subfileType = _subfileType;
@synthesize offset = _offset;
@synthesize length = _length;

-(id)init:(NSString*)aamvaData {
    return [self init:aamvaData start: 0];
}

-(id)init:(NSString*)aamvaData start:(int)start {
    if ([aamvaData length] < start + SUBFILE_HEADER_LENGTH)
        [NSException raise:@"Not enough data to parser subfile header."
                    format:@"%lu is less than %d", (unsigned long)[aamvaData length], start + SUBFILE_HEADER_LENGTH];
    
    self.subfileType = [aamvaData substringWithRange:NSMakeRange(start, 2)];
    self.offset = [[aamvaData substringWithRange:NSMakeRange(start+2, 4)] intValue];
    self.length = [[aamvaData substringWithRange:NSMakeRange(start+6, 4)] intValue];
    return self;
}

@end
