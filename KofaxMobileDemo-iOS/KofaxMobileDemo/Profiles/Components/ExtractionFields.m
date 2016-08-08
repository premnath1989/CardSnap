//
//  ExtractionFields.m
//  Kofax Mobile Demo
//
//  Created by Mahendra on 14/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "ExtractionFields.h"
#import "ChecksHistory.h"
#import "CheckHistoryManager.h"
#define FieldAlernatives @"fieldAlternatives"
#import <kfxLibEngines/kfxEngines.h>

@interface ExtractionFields ()
{
    
}
@property(nonatomic,assign) componentType type;
@property(nonatomic,strong) NSString *plistName;
@property(nonatomic,strong) NSArray *result;
@property(nonatomic,strong) NSDictionary *settings;

@end

@implementation ExtractionFields

-(id)initWithSettings:(NSDictionary *)settings componentType:(componentType)type withExtractionResult:(NSArray *)result
{
    if(self = [super init])
    {
        _type = type;
        _settings = settings;
        _result = result;
        [self setDefaults];
    }
    
    return self;
}


-(void)setDefaults
{
    [self plistNameForComponentType:_type];
    NSString *path = [[NSBundle mainBundle] pathForResource:_plistName ofType:@"plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
    [self fillExtractionInfo:data];
    
}

-(void)fillExtractionInfo:(NSDictionary *)data
{
    NSMutableDictionary *allResults = [[NSMutableDictionary alloc] init];
    for (NSString *key in data.allKeys) {
        @autoreleasepool {
            NSArray *arrData = data[key];
            NSMutableArray *arrExtractionInfo = [[NSMutableArray alloc] initWithCapacity:arrData.count];
            for (NSDictionary *dictInfo in arrData) {
                @autoreleasepool {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@",dictInfo[@"key"]];
                        NSArray *tempArray = [_result filteredArrayUsingPredicate:predicate];
                        ExtractInfo *info = [[ExtractInfo alloc] initWithDictionary:dictInfo];
                        if (tempArray.count) {
                            if ([tempArray.firstObject isKindOfClass:[kfxKOEDataField class]]) {
                                kfxKOEDataField *dataField =tempArray.firstObject;
                                info.value = dataField.value;
                                [info updateConfidence:[NSString stringWithFormat:@"%.2f",dataField.confidence]];
                            }else{
                                NSDictionary *dictResult =tempArray.firstObject;
                                info.value = dictResult[@"text"];
                                if (dictResult[@"confidence"]) {
                                    [info updateConfidence:dictResult[@"confidence"]];
                                }
                                if (dictResult[@"pageIndex"]) {
                                    [info updateCoordinatesAndPageIndex:dictResult];
                                }
                            }
                        }
                        [arrExtractionInfo addObject:info];
                }
            }
            [allResults setObject:arrExtractionInfo forKey:key];
        }
    }
    _extractionFields = allResults;
    
    
    switch (_type) {
        case CHECKDEPOSIT:
            [self modifyExtractionInfoForCD];
            break;
            
        default:
            break;
    }
    
    allResults = nil;
}

-(void)modifyExtractionInfoForCD
{
    NSMutableArray *checkArray = _extractionFields[@"checkArray"];
    NSMutableArray *usabilityArray = _extractionFields[@"usabilityArray"];

    /////////////////////////////////////////////////
    //RestrictiveEndorsementPresent
    ExtractInfo *info = [self extractionInfoForKey:@"RestrictiveEndorsementPresent" withArray:checkArray];
    NSDictionary *dictResult = [self resultDictionaryForKey:@"RestrictiveEndorsementPresent" withResult:_result];
    
    if (dictResult) {
        if ([dictResult[INFO_TEXT] boolValue]) {
            info = [self extractionInfoForKey:@"RestrictiveEndorsement" withArray:checkArray];
            dictResult = [self resultDictionaryForKey:@"RestrictiveEndorsement" withResult:_result];
            info.value = Klm(dictResult[INFO_TEXT]);
        }
        else{
            [checkArray removeLastObject];
        }
    }
    else{
        [checkArray removeLastObject];
    }
    /////////////////////////////////////////////////
    //ReasonForRejection
    
    info = [self extractionInfoForKey:@"ReasonForRejection" withArray:usabilityArray];
    dictResult = [self resultDictionaryForKey:@"ReasonForRejection" withResult:_result];
    if (dictResult) {
        NSString *rejectReason = @"";
        NSArray *arrFieldAlternatives = [dictResult valueForKey:FieldAlernatives];
        if (arrFieldAlternatives.count) {
            for (NSDictionary *dictReason in arrFieldAlternatives) {
                rejectReason = [NSString stringWithFormat:@"%@%@",rejectReason,dictReason[INFO_TEXT]];
            }
            rejectReason = [rejectReason stringByAppendingString:@"."];
        }else{
            rejectReason = [dictResult valueForKey:INFO_TEXT];
        }
        if ([rejectReason isEqualToString:@"."] || [rejectReason isEqualToString:@""]) {
            [usabilityArray removeObject:info];
        }
        else{
            info.value = rejectReason;
        }
    }else{
        [usabilityArray removeObject:info];
    }
    /////////////////////////////////////////////////
    // A2iA_CheckCodeline
    
    info = [self extractionInfoForKey:@"A2iA_CheckCodeline" withArray:checkArray];
    
    NSString *check_Duplicate = NO;
    if ([self checkMICRExistOrNot:info.value]) {
        check_Duplicate = @"YES";
    }else{
        check_Duplicate = @"NO";
    }
    if (info) {
        info.value = [self removeSpecialCharacters:info.value];
    }
    /////////////////////////////////////////////////
    //Duplicate
    info = [self extractionInfoForKey:@"Duplicate" withArray:checkArray];
    info.value = Klm(check_Duplicate);
    
    /////////////////////////////////////////////////
    //CheckUsable
    info = [self extractionInfoForKey:@"CheckUsable" withArray:checkArray];
    if ([info.value boolValue]) {
        info.value = Klm(@"YES");
    }else{
        info.value = Klm(@"NO");
    }
    
    /////////////////////////////////////////////////
    //UsabilityFailure_PayeeEndorsement
    info = [self extractionInfoForKey:@"UsabilityFailure_PayeeEndorsement" withArray:checkArray];
    NSDictionary *advancedSettings = [_settings valueForKey:ADVANCEDSETTINGS];
    dictResult = [self resultDictionaryForKey:@"UsabilityFailure_PayeeEndorsement" withResult:_result];
    if([[advancedSettings valueForKey:CHECKEXTRACTION] intValue] == 2){
        info.value = [dictResult valueForKey:INFO_TEXT];
    }
    else{
        info.value  = @"FALSE";
    }
    /////////////////////////////////////////////////
    //A2iA_CheckDate
    info = [self extractionInfoForKey:@"A2iA_CheckDate" withArray:checkArray];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:INFO_DATE_FORMAT];
    NSDate *date = [dateFormat dateFromString:info.value];
    dateFormat = [AppUtilities getDateFormatterOfLocale];
    info.value = [dateFormat stringFromDate:date];
    dateFormat = nil;
    /////////////////////////////////////////////////

}


-(void)plistNameForComponentType:(componentType)type
{
    switch (type) {
        case CHECKDEPOSIT:
            _plistName = @"CheckDepositResult";
            break;
        case IDCARD:
            _plistName = @"IDCardResult";
            break;
        case BILLPAY:
            _plistName = @"PayBillsResult";
            break;
        case CREDITCARD:
            _plistName = @"CreditCardCResult";
            break;
        default:
            _plistName = @"NONE";
            break;
    }
}


-(ExtractInfo *)extractionInfoForKey:(NSString *)key withArray:(NSArray *)array
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key = %@",key];
    NSArray *tempArray = [array filteredArrayUsingPredicate:predicate];
    if (tempArray.count) {
        return tempArray[0];
    }
    return nil;
}

-(NSDictionary *)resultDictionaryForKey:(NSString *)key withResult:(NSArray *)results
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@",key];
    NSArray *tempArray = [results filteredArrayUsingPredicate:predicate];
    if (tempArray.count) {
        return tempArray[0];
    }
    return nil;
}

-(NSString*)removeSpecialCharacters:(NSString*)check_MICR{
    
    
    check_MICR = [check_MICR stringByReplacingOccurrencesOfString:@"," withString:@" "];
    
    check_MICR = [check_MICR stringByReplacingOccurrencesOfString:@"." withString:@" "];
    
    return check_MICR;
}

-(BOOL)checkMICRExistOrNot:(NSString*)micr{
    
    CheckHistoryManager *chMgr = [[CheckHistoryManager alloc] init];
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChecksHistory" inManagedObjectContext:chMgr.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entity];
    NSArray *historyArray = [chMgr.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (ChecksHistory *historyObject in historyArray) {
        if ([historyObject.micrCode isEqualToString:micr]) {
            return YES;
        }
    }
    return NO;
}

@end
