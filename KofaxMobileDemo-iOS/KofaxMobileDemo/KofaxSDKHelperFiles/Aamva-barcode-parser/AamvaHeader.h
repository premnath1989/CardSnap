//
// Copyright (c) 2012-2014 Kofax. Use of this code is with permission pursuant to Kofax license terms.
//

#import <Foundation/Foundation.h>

static const int HEADER_LENGTH_V0 = 17;
static const int HEADER_LENGTH_V1 = 19;
static const int HEADER_LENGTH_V2 = 21;

@interface AamvaHeader : NSObject {
    char complianceIndicator;
    char recordSeparator;
    char segmentTerminator;
    int numSubfileEntries;
    int headerLength;
}


-(id)init:(NSString*) aamvaData;

@property(strong, nonatomic) NSString* issuerIdentificationNumber;
@property(nonatomic) int aamvaVersion;
@property(nonatomic) int jurisdictionVersion;
@property(strong, nonatomic) NSString* fileType;
@property(strong, nonatomic) NSMutableArray* subfileHeaders;

@property(nonatomic) char dataElementSeparator;
@property(nonatomic) char recordSeparator;
@property(nonatomic) char segmentTerminator;

@end
