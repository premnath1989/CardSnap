//
// Copyright (c) 2012-2014 Kofax. Use of this code is with permission pursuant to Kofax license terms.
//

#import "AamvaHeader.h"
#import "AamvaSubfileHeader.h"

@implementation AamvaHeader

@synthesize issuerIdentificationNumber = _issuerIdentificationNumber;
@synthesize aamvaVersion = _aamvaVersion;
@synthesize jurisdictionVersion = _jurisdictionVersion;
@synthesize subfileHeaders = _subfileHeaders;
@synthesize dataElementSeparator = _dataElementSeparator;
@synthesize fileType = _fileType;
@synthesize recordSeparator=_recordSeparator;
@synthesize segmentTerminator=_segmentTerminator;

-(id)init:(NSString*) aamvaData
{
    self = [super init];
    headerLength = HEADER_LENGTH_V1;
    if ([aamvaData length] < headerLength)
    {
        
        [NSException raise:@"Data length is smaller than minimum header length."
                    format:@"%lu is smaller than %d", (unsigned long)[aamvaData length], headerLength];
    }
    
    complianceIndicator = [aamvaData characterAtIndex:0];
    self.dataElementSeparator = [aamvaData characterAtIndex:1];
    self.recordSeparator = [aamvaData characterAtIndex:2];
    self.segmentTerminator = [aamvaData characterAtIndex:3];
    self.fileType = [aamvaData substringWithRange:NSMakeRange(5, 4)];
    self.issuerIdentificationNumber = [aamvaData substringWithRange:NSMakeRange(9,6)];
    self.aamvaVersion = [[aamvaData substringWithRange:NSMakeRange(15, 2)] intValue];

    if ([aamvaData characterAtIndex:17] < '0' || [aamvaData characterAtIndex:17] > '9') {
        headerLength = HEADER_LENGTH_V0;
        numSubfileEntries = 1;
    }
    else if (self.aamvaVersion <= 1) {
        numSubfileEntries = [[aamvaData substringWithRange:NSMakeRange(17, 2)] intValue];
    }
    else {
        headerLength = HEADER_LENGTH_V2;
        if ([aamvaData length] < headerLength)
            [NSException raise:@"Data length is smaller than allowed header length."
                        format:@"%lu is smaller than %d",(unsigned long)[aamvaData length], headerLength];
        
        self.jurisdictionVersion = [[aamvaData substringWithRange:NSMakeRange(17, 2)] intValue];
        numSubfileEntries = [[aamvaData substringWithRange:NSMakeRange(19, 2)] intValue];
    }
    
    if ([aamvaData length] < headerLength + numSubfileEntries * SUBFILE_HEADER_LENGTH)
        [NSException raise:@"Data length is smaller than allowed header length."
                    format:@"%lu is smaller than %d",(unsigned long)[aamvaData length], headerLength + numSubfileEntries * SUBFILE_HEADER_LENGTH];
    
    self.subfileHeaders = [[NSMutableArray alloc] init];
    for (int i = 0; i < numSubfileEntries; i++) {
        AamvaSubfileHeader *sub = [[AamvaSubfileHeader alloc] init: aamvaData start:headerLength + i * SUBFILE_HEADER_LENGTH];
        [self.subfileHeaders addObject:sub];
    }
    
    // Correct SubFile header offsets if they are 0
    for (int i = 0; i < numSubfileEntries; i++) {
        AamvaSubfileHeader *sub = [self.subfileHeaders objectAtIndex:i];
        if (sub.offset == 0)
            sub.offset = [self calculateOffset:i];
    }
    
    // Correct invalid SubFile header length if only one present
    if (self.subfileHeaders.count == 1) {
        AamvaSubfileHeader *sub = [self.subfileHeaders objectAtIndex:0];
        if (sub.offset + sub.length > aamvaData.length)
            sub.length = (int)(aamvaData.length - sub.offset);
    }
    
    return self;
}

- (int) calculateOffset:(int) subfileIndex {
    // Heuristic assumes subfile data is  packed in order without gaps, and that previous offsets are set.
    if (subfileIndex == 0)
        return headerLength + numSubfileEntries * SUBFILE_HEADER_LENGTH;
    else {
        AamvaSubfileHeader *sub = [self.subfileHeaders objectAtIndex:subfileIndex - 1];
        return sub.offset + sub.length;
    }
}


@end
