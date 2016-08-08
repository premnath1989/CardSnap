//
//  ExtractInfo.m
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 11/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import "ExtractInfo.h"

@implementation ExtractInfo
@synthesize name = _name;

-(id)initWithDictionary: (NSDictionary *)dictInfo
{
    if(self = [super init])
    {
        _name = dictInfo[@"name"];
        _key = dictInfo[@"key"];
        _value = dictInfo[@"value"];
        _coordinates = CGRectMake([dictInfo[@"left"] floatValue], [dictInfo[@"top"] floatValue], [dictInfo[@"width"] floatValue], [dictInfo[@"height"] floatValue]);
        if (dictInfo[@"confidence"]) {
            _confidence = [NSNumber numberWithInt:[dictInfo[@"confidence"] intValue]];
        }
        if (dictInfo[@"editable"]) {
            _editable = [dictInfo[@"editable"] boolValue];
        }
        if (dictInfo[@"keyboardtype"]) {
            _keyBoardType = dictInfo[@"keyboardtype"];
        }
        if (!_options) {
            _options = @[@"Male", @"Female"];
        }
        
        _pageIndex = [dictInfo[@"pageIndex"] integerValue];
    }
    return self;
}

-(void)updateConfidence:(NSString *)confidence
{
    if (confidence) {
        _confidence = [NSNumber numberWithInt:[confidence floatValue]*100];
    }
    
    
}

-(void)updateCoordinatesAndPageIndex:(NSDictionary *)dictInfo{
    if (dictInfo) {
        _coordinates = CGRectMake([dictInfo[@"left"] floatValue], [dictInfo[@"top"] floatValue], [dictInfo[@"width"] floatValue], [dictInfo[@"height"] floatValue]);
        _pageIndex = [dictInfo[@"pageIndex"] integerValue];
    }
}



@end
