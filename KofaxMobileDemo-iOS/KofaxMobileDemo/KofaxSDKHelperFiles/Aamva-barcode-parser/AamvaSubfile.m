//
// Copyright (c) 2012-2014 Kofax. Use of this code is with permission pursuant to Kofax license terms.
//

#import "AamvaSubfile.h"

@implementation AamvaSubfile

@synthesize entries = _entries;
@synthesize subfileHeader = _subfileHeader;

-(id) init:(NSString*)aamvaData header:(AamvaHeader*)header subfileHeader:(AamvaSubfileHeader*) subfileHeader
{
    self = [super init];
    if ([aamvaData length] < subfileHeader.offset + subfileHeader.length)
        [NSException raise:@"Length of data is too small for given Subfile definition."
                    format:@"%lu is less than %d", (unsigned long)[aamvaData length] , subfileHeader.offset + subfileHeader.length];
    
    self.subfileHeader = subfileHeader;
    self.entries = [[NSMutableDictionary alloc] init];
    
    int offset = subfileHeader.offset;
    
    // Try to determine if the subfile begins with the 2-char subfile identifier
    // The AAMVA CDS is completely broken on this point, so it's an imprecise heuristic
    if ([[aamvaData substringWithRange:NSMakeRange(offset, 2)]
         compare:self.subfileHeader.subfileType] == NSOrderedSame) {
        offset += 2;
    }
    
    // If a record erroneously starts with a data element separator, ignore it
    if ([aamvaData characterAtIndex:offset] == header.dataElementSeparator) {
        offset += 1;
    }
    
    for (int i = offset, elemLength = 0; i < subfileHeader.offset + subfileHeader.length; i++) {
        elemLength++;
        if ([aamvaData characterAtIndex:i] == header.dataElementSeparator || [aamvaData characterAtIndex:i] == header.segmentTerminator) {
            int startIndex = i - elemLength + 1;
            if (startIndex < 0 || startIndex + 3 > i) {
                continue;
            }
            
            NSString* key = [aamvaData substringWithRange:NSMakeRange(startIndex, 3)];
            NSString* value = [aamvaData substringWithRange:NSMakeRange(startIndex + 3, i - (startIndex + 3))];
            
            [self.entries setObject:value forKey:key];
            elemLength = 0;
        }
        
        if ([aamvaData characterAtIndex:i] == header.segmentTerminator) {
            break;
        }
    }
    return self;
}

-(NSString*) getEntry:(NSString*) elemId
{
    return [self.entries objectForKey:elemId];
}

@end
