//
//  AppParser.h
//  KofaxMobileDemo
//
//  Created by Mahendra on 05/11/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

// This class acts as a parser to the app. It contains methods to parse any responses coming from webservice and also handles DL - Barcode parsing

#import <Foundation/Foundation.h>
#import "DLData.h"

@protocol ParserProtocol <NSObject>
@optional
-(void)barcodeParsed:(DLData*)dlBarcodeData;
-(void)barcodeParsingFailed;

-(void)dlFrontParsed:(DLData*)dlFrontData;
-(void)dlFrontParsingFailed;

@end

@interface AppParser : NSObject
{
    
}

@property id<ParserProtocol>delegate;
-(void)parseBarcodeResult :(NSString*)metaData;
-(void)parseDLFront : (NSData*)dlFrontData;
-(void)parseDLFrontWithODE:(NSArray*)dlFrontArray;

@end
