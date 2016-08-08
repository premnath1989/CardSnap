//
// Copyright (c) 2012-2014 Kofax. Use of this code is with permission pursuant to Kofax license terms.
//

#import <Foundation/Foundation.h>

static const int SUBFILE_HEADER_LENGTH = 10;

@interface AamvaSubfileHeader : NSObject

@property(strong, nonatomic) NSString* subfileType;
@property(nonatomic) int offset;
@property(nonatomic) int length;

-(id)init:(NSString*)aamvaData;
-(id)init:(NSString*)aamvaData start:(int)start;


@end
