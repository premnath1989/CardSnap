//
// Copyright (c) 2012-2014 Kofax. Use of this code is with permission pursuant to Kofax license terms.
//

#import <Foundation/Foundation.h>
#import "AamvaSubfileHeader.h"
#import "AamvaHeader.h"

@interface AamvaSubfile : NSObject

@property(strong, retain) AamvaSubfileHeader* subfileHeader;
@property(strong, retain) NSMutableDictionary* entries;

-(id) init:(NSString*)aamvaData header:(AamvaHeader*)header subfileHeader:(AamvaSubfileHeader*) subfileHeader;

-(NSString*) getEntry:(NSString*) elemId;

@end
