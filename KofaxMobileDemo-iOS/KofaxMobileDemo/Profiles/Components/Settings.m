//
//  Settings.m
//  Kofax Mobile Demo
//
//  Created by Mahendra on 14/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "Settings.h"
@interface Settings()
{
    
}

@property (nonatomic)int componentType;
@property(nonatomic,strong)NSDictionary* rttiSettings;
@property(nonatomic,strong)NSDictionary* advancedSettings;
@property(nonatomic,strong)NSDictionary* cameraSettings;
@property(nonatomic,strong)NSDictionary* evrsSettings;

@end

@implementation Settings

-(id)initWithType : (componentType)type
{
    if(self = [super init])
    {
        self.componentType = type;
        [self setDefaults];
        
    }
    
    return self;
}

-(id)initWithParsedJSON : (NSDictionary*)parsedJSONDictionary
{
    if(self = [super init])
    {
        if(parsedJSONDictionary)
            [self setUpFromJSON:parsedJSONDictionary];
        else
            [self setDefaults];
    }
    
    return self;
}


-(void)setDefaults
{
    
    [self setDefaultRTTISettings];
    
    if (self.componentType==CHECKDEPOSIT) {
        [self setDefaultAdvancedSettings];
    }
    [self setDefaultCameraSettings];
    [self setDefaultEVRSSettings];
    [self addSettingsToDictionary];
    
}

-(void)setUpFromJSON : (NSDictionary*)parsedJSONDictionary
{
    self.rttiSettings = [parsedJSONDictionary valueForKey:RTTISETTINGS];
    self.cameraSettings = [parsedJSONDictionary valueForKey:CAMERASETTINGS];
    self.evrsSettings = [parsedJSONDictionary valueForKey:EVRSSETTINGS];
    self.advancedSettings = [parsedJSONDictionary valueForKey:ADVANCEDSETTINGS];
    [self addSettingsToDictionary];
    
}

-(void)addSettingsToDictionary
{
    self.settingsDictionary = [[NSMutableDictionary alloc] init];
    if(self.rttiSettings)
        [self.settingsDictionary setValue:self.rttiSettings forKey:RTTISETTINGS];
    if(self.cameraSettings)
        [self.settingsDictionary setValue:self.cameraSettings forKey:CAMERASETTINGS];
    if(self.evrsSettings)
        [self.settingsDictionary setValue:self.evrsSettings forKey:EVRSSETTINGS];
    if(self.advancedSettings)
        [self.settingsDictionary setValue:self.advancedSettings forKey:ADVANCEDSETTINGS];
}


-(void)setDefaultRTTISettings
{
    self.rttiSettings = [[NSMutableDictionary alloc] init];
    if (self.componentType == BILLPAY) {
        [self.rttiSettings setValue:BILLPAYURL forKey:SERVERURL];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:HIGHLIGHTDATA];
        [self.rttiSettings setValue:[NSNumber numberWithBool:true] forKey:HIGHLIGHTSWITCH];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:SAVEORIGINALIMAGESWITCH];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:SERVER_MODE];
        [self.rttiSettings setValue:@"KMDUser" forKey:KTAUSERNAME];
        [self.rttiSettings setValue:@"DemoPassword" forKey:KTAPASSWORD];
        [self.rttiSettings setValue:@"KofaxBillPay" forKey:KTAPROCESSNAME];
        [self.rttiSettings setValue:@"" forKey:KTASERVERURL];
        
        
    }else if(self.componentType == CHECKDEPOSIT){
        [self.rttiSettings setValue:CHECKDEPOSITURL forKey:SERVERURL];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:HIGHLIGHTDATA];
        [self.rttiSettings setValue:[NSNumber numberWithBool:true] forKey:HIGHLIGHTSWITCH];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:SAVEORIGINALIMAGESWITCH];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:SERVER_MODE];
        [self.rttiSettings setValue:@"KMDUser" forKey:KTAUSERNAME];
        [self.rttiSettings setValue:@"DemoPassword" forKey:KTAPASSWORD];
        [self.rttiSettings setValue:@"KofaxCheckDeposit" forKey:KTAPROCESSNAME];
        [self.rttiSettings setValue:@"" forKey:KTASERVERURL];
        
    }else if(self.componentType == IDCARD){
        [self.rttiSettings setValue:IDCARDURL forKey:SERVERURL];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:HIGHLIGHTDATA];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:HIGHLIGHTSWITCH];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:SAVEORIGINALIMAGESWITCH];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:SERVER_MODE];
        [self.rttiSettings setValue:@"KMDUser" forKey:KTAUSERNAME];
        [self.rttiSettings setValue:@"DemoPassword" forKey:KTAPASSWORD];
        [self.rttiSettings setValue:@"KofaxMobileIDSync" forKey:KTAPROCESSNAME];
        [self.rttiSettings setValue:@"ID" forKey:KTAIDTYPE];
        [self.rttiSettings setValue:@"" forKey:KTASERVERURL];
        [self.rttiSettings setValue:ODE_RTTI_URL forKey:ODE_LICENSE_RTTI_SERVER_URL];
        [self.rttiSettings setValue:ODE_KTA_URL forKey:ODE_LICENSE_KTA_SERVER_URL];
        [self.rttiSettings setValue:[NSNumber numberWithBool:NO] forKey:ODE_SERVER_MODE];
        [self.rttiSettings setValue:[NSNumber numberWithInt:10] forKey:ODEACQUIRECOUNT];
        [self.rttiSettings setValue:ODE_MODEL_URL forKey:ODE_MODELS_SERVER_URL];
        [self.rttiSettings setValue:@"https://mobiledemo.kofax.com/mobilesdk/api/mobileID2" forKey:RTTI_KOFAX_SERVER_URL];
        [self.rttiSettings setValue:@"KMDUser" forKey:KTA_KOFAX_USERNAME];
        [self.rttiSettings setValue:@"DemoPassword" forKey:KTA_KOFAX_PASSWORD];
        [self.rttiSettings setValue:@"KofaxMobileIDCaptureSync" forKey:KTA_KOFAX_PROCESSNAME];
        [self.rttiSettings setValue:@"ID" forKey:KTA_KOFAX_IDTYPE];
        [self.rttiSettings setValue:@"" forKey:KTA_KOFAX_SERVER_URL];
        
    }else if (self.componentType == CUSTOM) {
        [self.rttiSettings setValue:CUSTOMCOMPONENTURL forKey:SERVERURL];
        [self.rttiSettings setValue:[NSNumber numberWithBool:true] forKey:SHOWALLFIELDS];
        [self.rttiSettings setValue:@"" forKey:CUSTOMFIELDKEYVALUE];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:HIGHLIGHTDATA];
        [self.rttiSettings setValue:[NSNumber numberWithBool:true] forKey:HIGHLIGHTSWITCH];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:SAVEORIGINALIMAGESWITCH];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:SERVER_MODE];
        [self.rttiSettings setValue:@"KMDUser" forKey:KTAUSERNAME];
        [self.rttiSettings setValue:@"DemoPassword" forKey:KTAPASSWORD];
        [self.rttiSettings setValue:@"" forKey:KTAPROCESSNAME];
        [self.rttiSettings setValue:@"" forKey:KTAIDTYPE];
        
        
        
    }else if(self.componentType==CREDITCARD){
        [self.rttiSettings setValue:EXTRACTION_SERVERTYPE_DEFAULT forKey:SERVER_MODE];
        [self.rttiSettings setValue:CREDITCARDURL forKey:SERVERURL];
        [self.rttiSettings setValue:EXTRACTMETHOD_DEFAULT forKey:EXTRACTMETHOD];
        
    }else{
        [self.rttiSettings setValue:BILLPAYURL forKey:SERVERURL];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:HIGHLIGHTDATA];
        [self.rttiSettings setValue:[NSNumber numberWithBool:true] forKey:HIGHLIGHTSWITCH];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:SAVEORIGINALIMAGESWITCH];
        [self.rttiSettings setValue:[NSNumber numberWithBool:false] forKey:SERVER_MODE];
        [self.rttiSettings setValue:@"KMDUser" forKey:KTAUSERNAME];
        [self.rttiSettings setValue:@"DemoPassword" forKey:KTAPASSWORD];
        [self.rttiSettings setValue:@"KofaxMobileID" forKey:KTAPROCESSNAME];
        [self.rttiSettings setValue:@"ID" forKey:KTAIDTYPE];
        [self.rttiSettings setValue:@"" forKey:KTASERVERURL];
    }
}

-(void)setDefaultCameraSettings
{
    
    self.cameraSettings = [[NSMutableDictionary alloc] init];
    [self.cameraSettings setValue:[NSNumber numberWithInt:DOCUMENT] forKey:CAPTUREEXPERIENCE];
    [self.cameraSettings setValue:[NSNumber numberWithInt:15] forKey:PITCHTHRESHOLD];
    [self.cameraSettings setValue:[NSNumber numberWithInt:15] forKey:ROLLTHRESHOLD];
    [self.cameraSettings setValue:[NSNumber numberWithBool:false] forKey:SHOWGALLERY];
    [self.cameraSettings setValue:[NSNumber numberWithInt:95] forKey:STABILITYDELAY];
    [self.cameraSettings setValue:[NSNumber numberWithInt:85] forKey:OFFSETTHRESHOLD];
    [self.cameraSettings setValue:[NSNumber numberWithInt:10] forKey:MANUALCAPTURETIMER];
    [self.cameraSettings setValue:[NSNumber numberWithInt:0] forKey:AUTOTORCH];
    [self.cameraSettings setValue:[NSNumber numberWithInt:1] forKey:SHOWGUIDINGDEMO];
    
    if (self.componentType == CUSTOM) {
        [self.cameraSettings setValue:[NSNumber numberWithFloat:1.44] forKey:FRAMEASPECTRATIO];
        [self.cameraSettings setValue:[NSNumber numberWithInt:1] forKey:CAPTURETYPE];
        [self.cameraSettings setValue:[NSNumber numberWithInt:0] forKey:MANUALCAPTURETIMER];
    }
    
    if (self.componentType == CHECKDEPOSIT) {
        [self.cameraSettings setValue:[NSNumber numberWithFloat:2.18] forKey:FRAMEASPECTRATIO];
        [self.cameraSettings setValue:[NSNumber numberWithInt:0] forKey:EDGEDETECTION];
    }
    else
    {
        [self.cameraSettings setValue:[NSNumber numberWithInt:1] forKey:EDGEDETECTION];
    }
    
    if(self.componentType == CREDITCARD){
        [self.cameraSettings setValue:[NSNumber numberWithFloat:1.585] forKey:FRAMEASPECTRATIO];
    }
   
}

-(void)setDefaultAdvancedSettings
{
    self.advancedSettings = @{SEARCHMICR:@"true",FIRSTTIMELAUNCHDEMO:@"true",USEHANDPRINT:@"true",CHECKFORDUPLICATES:@"true",CHECKVALIDATIONSERVER:@"true",SHOWCHECKINFO:@"true",SHOWCHECKGUIDINGDEMO:@"true", CHECKEXTRACTION:@"2",SHOWINSTRUCTION:@"true",DOCUMENTSNUMBER:@"1"};
}

-(void)setDefaultEVRSSettings
{
    self.evrsSettings = [[NSMutableDictionary alloc] init];
    [self.evrsSettings setValue:[NSNumber numberWithInt:1] forKey:SCALE];
    [self.evrsSettings setValue:[NSNumber numberWithBool:true] forKey:DESKEW];
    [self.evrsSettings setValue:[NSNumber numberWithBool:true] forKey:AUTOCROP];
    [self.evrsSettings setValue:[NSNumber numberWithBool:false] forKey:DOQUICKANALYSIS];
    [self.evrsSettings setValue:[NSNumber numberWithBool:false] forKey:BACKGROUNDSMOOTHING];
    [self.evrsSettings setValue:[NSNumber numberWithInt:0] forKey:SHARPEN];
    [self.evrsSettings setValue:[NSNumber numberWithBool:true] forKey:USEBANKRIGHTSETTINGS];
    [self.evrsSettings setValue:[NSNumber numberWithInt:1] forKey:DESKEWBY];
    [self.evrsSettings setValue:[NSNumber numberWithInt:0] forKey:EVRSDEBUGGING];
    if (self.componentType == CUSTOM || self.componentType==CREDITCARD) {
        [self.evrsSettings setValue:[NSNumber numberWithBool:false] forKey:CSKEWSETTINGS];
        [self.evrsSettings setValue:[NSNumber numberWithInt:2] forKey:MODE];
        [self.evrsSettings setValue:[NSNumber numberWithBool:true] forKey:DOPROCESS];
        if(self.componentType==CUSTOM)
            [self.evrsSettings setValue:@"" forKey:CSKEWSTRING];
    }
    else if(self.componentType == IDCARD)
    {
        [self.evrsSettings setValue:[NSNumber numberWithInt:2] forKey:MODE];
        [self.evrsSettings setValue:[NSNumber numberWithInt:2] forKey:SCALE];

    }
    else{
        [self.evrsSettings setValue:[NSNumber numberWithBool:true] forKey:CSKEWSETTINGS];
        [self.evrsSettings setValue:[NSNumber numberWithInt:0] forKey:MODE];

    }
    [self.evrsSettings setValue:[NSNumber numberWithInt:0] forKey:DESPECKLE];
    [self.evrsSettings setValue:[NSNumber numberWithBool:true] forKey:AUTOROTATE];
}


@end
