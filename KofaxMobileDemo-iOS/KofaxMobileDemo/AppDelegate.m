//
//  AppDelegate.m
//  Kofax Mobile Demo
//
//  Created by Mahendra on 13/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

//TODO move license checking to a common place

#import "AppDelegate.h"
#import "ProfileManager.h"
#import "PersistenceManager.h"
#import "HomeViewController.h"
#import "LicensePromptViewController.h"
#import "SettingsViewController.h"
#import "BackgroundGraphicsViewController.h"
#import <kfxLibUIControls/kfxUIControls.h>
#import "CaptureViewController.h"
#import "CertificatePinningManager.h"
#import "Crittercism.h"
#import "LicenceHelper.h"

@interface AppDelegate ()<kfxKUTAppStatisticsDelegate>
{
    BOOL isAlreadyLoggedIn;
    NSDictionary *launchOpt;
    
    BOOL fileThresholdReached;
    int errorCodeStopRecord;
    NSMutableData *appStatExportData;
    NSMutableDictionary *appStatsSettingsInfo;
}

@property(nonatomic,strong)ProfileManager* profileManager;
@property(nonatomic,strong) UINavigationController *navController;

@property (nonatomic, assign) enum KUTappStatsWriteFile APPSTATS_FILEWRITE_STATE;
@property (nonatomic, assign) enum KUTappStatsExport APPSTATS_FILEEXPORT_STATE;

@end

@implementation AppDelegate

@synthesize appStatsObj;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Crittercism enableWithAppID:@"54ed725c51de5e9f042ede01"];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.profileManager = [ProfileManager sharedInstance];
    if(![self isAnyProfileActive])
    {
        [self importDefaultProfile];
    }
    else
    {
        [self.profileManager loadActiveProfile];
    }
    
    if (![PersistenceManager isAppStatsSaved]) {
        NSMutableDictionary *appStatsInfo = [[NSMutableDictionary alloc]init];
        [appStatsInfo setValue:[NSNumber numberWithBool:false] forKey:ENABLEAPPSTATS];
        [appStatsInfo setValue:@"http://mobiledemo.kofax.com/mobilesdk/api/appStats" forKey:EXPORTURL];
        [appStatsInfo setValue:[NSNumber numberWithBool:false] forKey:EXPORTFORMAT];
        [PersistenceManager storeAppStats:appStatsInfo];
        appStatsInfo = nil;
    }
    
    launchOpt = launchOptions;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:ISCOMPLETEDOWNLOADMODELS]) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:ISCOMPLETEDOWNLOADMODELS];
    }
    
    if (launchOptions) {
        isAlreadyLoggedIn = [PersistenceManager isUserLoggedIn];
        [PersistenceManager storeUserLoginInfo:YES];
    }else{
        [PersistenceManager storeUserLoginInfo:NO];
    }
    
    appStatsObj = [kfxKUTAppStatistics appStatisticsInstance];
    [self initAppStatistics];
    
    BOOL status = [self setLicense];

    if (status) {
        HomeViewController * viewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        self.navController=[[UINavigationController alloc]initWithRootViewController:viewController];
    }
    else{
        LicensePromptViewController * viewController = [[LicensePromptViewController alloc] initWithNibName:@"LicensePromptViewController" bundle:nil];
        self.navController=[[UINavigationController alloc]initWithRootViewController:viewController];
    }
    // Setting the mobile SDK License server URL for fetching licenses
    
    
    for (Component* componentObject in [[self.profileManager getActiveProfile] componentArray]) {
        if (componentObject.type == IDCARD) {
            if (((NSNumber*)[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:ODE_SERVER_MODE]).boolValue) {
                //kta
                [[LicenceHelper sharedInstance] setMobileSDKLicenceServer:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:ODE_LICENSE_KTA_SERVER_URL] type:SERVER_TYPE_TOTALAGILITY];
            }
            else{
                // rtti
                [[LicenceHelper sharedInstance] setMobileSDKLicenceServer:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:ODE_LICENSE_RTTI_SERVER_URL] type:SERVER_TYPE_RTTI];
            }
            break;
        }
    }

    
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    return YES;
}


-(BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    if (url != nil && [url isFileURL]) {
//        self.profileManager = [ProfileManager sharedInstance];
//        [self.profileManager importProfile:url];
        [self setLicense];
        
        if (!launchOpt){
            isAlreadyLoggedIn = [PersistenceManager isUserLoggedIn];
        }else{
            launchOpt = nil;
        }
        
        if ([self.navController.topViewController isKindOfClass:[BackgroundGraphicsViewController class]]) {
            BackgroundGraphicsViewController *backgroundController = (BackgroundGraphicsViewController*)self.navController.topViewController;
            [backgroundController.pickerController dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        
        if ([self.navController.topViewController isKindOfClass:[SettingsViewController class]]) {   //We are using same settings controller when we import file from mail rather than creating new controllers.
            SettingsViewController *settingController = (SettingsViewController*)self.navController.topViewController;
            [settingController importProfile:url];
            [[settingController table] reloadData];
            [PersistenceManager storeUserLoginInfo:isAlreadyLoggedIn];
        }
        else {
            BOOL status = [self setLicense];

            UIViewController *rootController = nil;
            if (status) {
                rootController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
            }
            else{
                rootController = [[LicensePromptViewController alloc] initWithNibName:@"LicensePromptViewController" bundle:nil];
            }
            SettingsViewController *settingsController = [[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:nil];
            NSArray *viewControllers = [NSArray arrayWithObjects:rootController,settingsController, nil];
            if(self.navController){
                [self.navController setNavigationBarHidden:NO];
                self.navController.viewControllers = viewControllers;
            }
            else
            {
                self.navController=[[UINavigationController alloc]init];
                self.navController.viewControllers = viewControllers;
                self.window.rootViewController = self.navController;
                [self.window makeKeyAndVisible];
                
            }
            [settingsController importProfile:url];
            [PersistenceManager storeUserLoginInfo:isAlreadyLoggedIn];
        }
       
    }
    return YES;
    
}

//This is a temporary method

-(void)importDefaultProfile
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"bankright" ofType:@"profile"];
    NSURL* defaultProfileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
    self.profileManager = [ProfileManager sharedInstance];
    [self.profileManager importProfile:defaultProfileURL];
}

-(BOOL)isAnyProfileActive
{
    if(![[self.profileManager getListOfProfiles] count])
    {
        return NO;
    }
    else
        return YES;
}

-(BOOL)setLicense{
    
   NSArray *arrErrorMessage = [AppUtilities checkLicenseValidity];
    if(arrErrorMessage.count>0){
        return false;
    }
    return true;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if ([self.navController.visibleViewController isKindOfClass:[CaptureViewController class]]) {
        CaptureViewController *captureControl = (CaptureViewController*)self.navController.visibleViewController;
        [captureControl freeCaptureControl];
        //captureControl.appFromBackground = YES;
        [captureControl viewWillAppear:YES];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark App Stats Statistics

- (void)initAppStatistics {
    
    NSLog(@"Initializing KMD Application Statistics");
    
    appStatsSettingsInfo = [PersistenceManager getAppStatsInfo];
    //    NSLog(@"App Stats database path is %@", APP_VARIABLES.appvAppStatsDatabasePath);
    NSString *appStatsDataBasePath = [NSString stringWithFormat:@"%@/KMDAppStats.sqlite", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
    
    [[NSFileManager defaultManager] removeItemAtPath:[appStatsSettingsInfo valueForKey:EXPORTURL] error:NULL];
    
    appStatsObj.deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:RAMTHRESHOLDLIMIT]) {
        appStatsObj.ramSizeThreshold = [[[NSUserDefaults standardUserDefaults] objectForKey:RAMTHRESHOLDLIMIT] intValue]; //1097152
    }
    else{
        appStatsObj.ramSizeThreshold = 2000000; //1097152
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:FILETHRESHOLDLIMIT]) {
        appStatsObj.fileSizeThreshold = [[[NSUserDefaults standardUserDefaults] objectForKey:FILETHRESHOLDLIMIT] intValue]; //1097152
    }
    else
    {
        appStatsObj.fileSizeThreshold = 2000000;
    }
    appStatsObj.delegate = self;
    
    int appStatsInitStatus=[appStatsObj initAppStats:appStatsDataBasePath];
    
    if ([[appStatsSettingsInfo valueForKey:ENABLEAPPSTATS]boolValue]) {
        [appStatsObj startRecord];
    }
    
    
    NSLog(@"App Stats Init status is %d and result description is %@",appStatsInitStatus, [kfxError findErrMsg:appStatsInitStatus]);
    
}
//! The sizeThreshold delegate method indicates that either the memory buffer or the file size has reached a threshold.
/* Report size threshold events to the application */
- (void) sizeThresholdReached : (KUTappStatsThreshold) type andSize : (int) size
{
    appStatsSettingsInfo = [PersistenceManager getAppStatsInfo];
    NSLog(@"Threshold reached");
    switch (type)
    {
        case KUT_THRESH_TYPE_RAM:
            NSLog(@"KMDAppStats: RAM size threshold reached with size %d", size);
            if([self.appStatsObj isRecording]) {
                errorCodeStopRecord=[self.appStatsObj stopRecord];
                NSLog(@"StopRecordStatus: error code for stopRecord is %d and message is %@", errorCodeStopRecord, [kfxError findErrMsg:errorCodeStopRecord]);
                [appStatsSettingsInfo setValue:[NSNumber numberWithBool:false] forKey:ENABLEAPPSTATS];
                [PersistenceManager storeAppStats:appStatsSettingsInfo];
            }
            else {
                NSLog(@"StopRecordStatus: ALready recording stopped. error code for stopRecord is %d and message is %@", errorCodeStopRecord, [kfxError findErrMsg:errorCodeStopRecord]);
            }
            [appStatsObj writeToFile];
            break;
            
        case KUT_THRESH_TYPE_FILE:
            NSLog(@"KMDAppStats: FILE size threshold reached with size %d", size);
            //[self doExport];
            fileThresholdReached=YES;
            break;
            
        default:
            NSLog(@"KMDAppStats: Unexpected size threshold type value received: %lu",(unsigned long)type);
            break;
            
            
    }
}

-(int) doExport
{
    appStatsSettingsInfo = [PersistenceManager getAppStatsInfo];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *exportFile;
    int errorCode = 0;
    NSLog(@"KMDAppStats: Calling export and export format is %@", [appStatsSettingsInfo valueForKey:EXPORTFORMAT]);
    
    if([[appStatsSettingsInfo valueForKey:EXPORTFORMAT]intValue]==1)
    {
        exportFile = [NSString stringWithFormat: @"%@/KMDAppStats.sqlite", documentsDirectory];
        NSLog(@"Exporting MSSQL to this location %@", exportFile);
        errorCode = [appStatsObj export:exportFile withFormat:KUT_EXPORT_TYPE_SQL];
    }
    else
    {
        exportFile = [NSString stringWithFormat: @"%@/KMD_Export.json", documentsDirectory];
        NSLog(@"Exporting JSON to this location %@", exportFile);
        if([self.appStatsObj isRecording]) {
            NSLog(@"Stopping recording of App Stats for export");
            [self.appStatsObj stopRecord];
        }

        if(self.APPSTATS_FILEWRITE_STATE==KUT_WRITEFILE_STATUS_EXPORTING) {
            NSLog(@"App Stats busy writing to file.");
        }
        appStatsObj.delegate=self;
        errorCode = [appStatsObj export:exportFile withFormat:KUT_EXPORT_TYPE_JSON];
        
    }
    NSLog(@"error code for export is %d and message is %@", errorCode, [kfxError findErrMsg:errorCode]);
    return (errorCode);
}

- (void) writeFileStatusEvent : (KUTappStatsWriteFile) type andProgress : (int) percentComplete withError: (int) errorCode withMsg: (NSString *) errorMsg{
    
    appStatsSettingsInfo = [PersistenceManager getAppStatsInfo];
    // NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *exportFile;
    
    
    NSLog(@"writeFileStatusEvent: Type: %lu, percent complete: %d, error code is %d and error message is %@\n", (unsigned long)type, percentComplete, errorCode, errorMsg);
    
    
    
    if(type==KUT_WRITEFILE_STATUS_COMPLETE && fileThresholdReached) {
        BOOL exportFileExists = [[NSFileManager defaultManager] fileExistsAtPath:exportFile];
        if(exportFileExists) {
            NSError *error;
            if ([[NSFileManager defaultManager] isDeletableFileAtPath:exportFile]) {
                BOOL fileDeleteSuccess = [[NSFileManager defaultManager] removeItemAtPath:exportFile error:&error];
                if (!fileDeleteSuccess) {
                    NSLog(@"Error removing file at path: %@", error.localizedDescription);
                }
                else {
                    NSLog(@"Error removing file at path: Success");
                }
            }
        }
        appStatsObj.delegate=self;
        
        NSLog(@"BRAppStats: Delegate is %@, export file path is %@ and database file path is %@ and stop record status is %d and message is %@",appStatsObj.delegate, exportFile, appStatsObj.filePath, errorCodeStopRecord, [kfxError findErrMsg:errorCodeStopRecord]);
        if(errorCodeStopRecord==0) {
            //[self performSelector:@selector(exportJSON:) withObject:exportFile afterDelay:0.5];
            //[self performSelectorInBackground:@selector(exportJSON:) withObject:exportFile];
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self performSelector:@selector(exportJSON) withObject:nil afterDelay:1.0];
                if ([[appStatsSettingsInfo valueForKey:EXPORTFORMAT]boolValue]) {
                    [self exportSQL];
                }else{
                    [self exportJSON];
                }
                
            });
        }
    }
    else{
        NSLog(@"Stop recording is still in progress");
        if(![self.appStatsObj isRecording]){
            //[self initAppStatistics];
            [self.appStatsObj startRecord];
            [appStatsSettingsInfo setValue:[NSNumber numberWithBool:true] forKey:ENABLEAPPSTATS];
            [PersistenceManager storeAppStats:appStatsSettingsInfo];
            appStatsObj.delegate=self;
        }
    }
}
-(void)exportJSON {
    
    int errorValue=1;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *exportPath;
    exportPath = [NSString stringWithFormat: @"%@/BR_Export.json", documentsDirectory];
    NSLog(@"BRAppStats: Current RAM Size is %d", self.appStatsObj.ramSize);
    errorValue= [appStatsObj export:exportPath withFormat:KUT_EXPORT_TYPE_JSON];
    NSLog(@"ExportStatus: error code for export is %d and message is %@", errorValue, [kfxError findErrMsg:errorValue]);
}

-(void)exportSQL{
    
    int errorValue=1;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *exportPath;
    exportPath = [NSString stringWithFormat: @"%@/BR_Export.json", documentsDirectory];
    NSLog(@"BRAppStats: Current RAM Size is %d", self.appStatsObj.ramSize);
    errorValue= [appStatsObj export:exportPath withFormat:KUT_EXPORT_TYPE_SQL];
    NSLog(@"ExportStatus: error code for export is %d and message is %@", errorValue, [kfxError findErrMsg:errorValue]);

}

- (void) exportStatusEvent : (KUTappStatsExport) type andProgress : (int) percentComplete  withError: (int) errorCode withMsg: (NSString *) errorMsg{
    
    appStatsSettingsInfo = [PersistenceManager getAppStatsInfo];
    NSLog(@"exportStatusEvent: Type: %lu, percent complete: %d, error code is %d and error message is %@", type, percentComplete, errorCode, errorMsg);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *exportFile;
    exportFile = [NSString stringWithFormat: @"%@/BR_Export.json", documentsDirectory];
    NSLog(@"Exported file path is %@", exportFile);
    if(type==KUT_EXPORT_STATUS_COMPLETE &  percentComplete==100){
        
        fileThresholdReached=NO;
        [self talkToServer:exportFile];
        if(![self.appStatsObj isRecording]){
            //[self initAppStatistics];
            [self.appStatsObj startRecord];
            [appStatsSettingsInfo setValue:[NSNumber numberWithBool:true] forKey:ENABLEAPPSTATS];
            [PersistenceManager storeAppStats:appStatsSettingsInfo];
            appStatsObj.delegate=self;
            
        }
    }
}

- (BOOL)connected{
    
    Reachability_BR *reachability = [Reachability_BR reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    return !(networkStatus == NotReachable);
    
}


-(void)talkToServer:(NSString*)exportFilePath{
    
    appStatsSettingsInfo = [PersistenceManager getAppStatsInfo];
    NSString *appStatsServiceURLString = [appStatsSettingsInfo valueForKey:EXPORTURL];
    
    NSURL *appStatsServiceURL = [NSURL URLWithString:appStatsServiceURLString];
    NSLog(@"The json data file path is %@\nContents = %@\n", exportFilePath,[NSString stringWithContentsOfFile:exportFilePath encoding:NSUTF8StringEncoding error:nil]);
    NSData *jsonDataFromPath = [NSData dataWithContentsOfFile:exportFilePath];
    // NSLog(@"The json data from path is %@", jsonDataFromPath);
    //NSData *jsonData = [KFXServiceClient serviceDataFromData:jsonDataFromPath];
    //NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    //Prepare http request.
    NSMutableURLRequest  *urlRequest = [NSMutableURLRequest requestWithURL:appStatsServiceURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    
    [urlRequest setHTTPMethod:@"PUT"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:jsonDataFromPath];
    
    NSLog(@"Is%@ main thread", ([NSThread isMainThread] ? @"" : @" NOT"));
    NSURLConnection *appStartExportConnect = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
    
    [appStartExportConnect scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [appStartExportConnect start];
}
#pragma mark - URL Connection delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if(!appStatExportData)
        appStatExportData = [NSMutableData data];
    
    
    NSString* responseString = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    NSLog(@"AppStatsExport: didReceiveData and data is %lu   : %@", (unsigned long)[data length] , responseString);
    
    [appStatExportData appendData:data];
    
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    
    NSLog(@"AppStatsExport: connectionDidFinishLoading and connection is %@", [[NSString alloc] initWithData:appStatExportData encoding:NSUTF8StringEncoding]);
    
    //    NSArray *jsonArr = [KFXServiceClient arrayFromServiceData:appStatExportData];
    //    NSLog(@"AppStats export data is %@", jsonArr);
    
    if([appStatsObj isRecording])
        [appStatsObj stopRecord];
    int purgeOutput =  [appStatsObj purge];
    NSLog(@"BRAPPStats: Purge output is %d and message is %@",purgeOutput, [kfxError findErrMsg:purgeOutput]);
    [appStatsObj upgradeSchema:appStatsObj.filePath];
    [self initAppStatistics];
    int startRecordResult = [appStatsObj startRecord];
    
    NSLog(@"BRAPPStats: Recording start is %d and message is %@",startRecordResult, [kfxError findErrMsg:startRecordResult]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"AppStatsExport: didFailWithError %@", error);
    
}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    NSLog(@"AppStatsExport: canAuthenticateAgainstProtectionSpace");
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    NSLog(@"AppStatsExport: didReceiveAuthenticationChallenge");
    
    if (![[CertificatePinningManager sharedInstance] handleConnection:connection didReceiveAuthenticationChallenge:challenge])
    {
        [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}


@end
