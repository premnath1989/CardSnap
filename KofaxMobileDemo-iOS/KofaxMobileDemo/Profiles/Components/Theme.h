//
//  Theme.h
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/20/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Theme : NSObject
{
    
}


@property (nonatomic, strong) NSString *themeColor;
@property (nonatomic, strong) NSString *titleColor;
@property (nonatomic, strong) NSString *buttonTextColor;
@property (nonatomic, strong) NSString *buttonColor;
@property (nonatomic, strong) NSNumber *buttonBorder;
@property (nonatomic, strong) NSNumber *buttonStyle;
//@property (nonatomic,strong)  NSDictionary* themeDictionary;
-(id)initWithParsedJSON : (NSDictionary*)parsedJSONDictionary;


@end
