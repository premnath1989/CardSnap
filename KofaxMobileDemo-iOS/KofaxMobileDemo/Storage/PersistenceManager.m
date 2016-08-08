//
//  PersistentManager.m
//  Kofax Mobile Demo
//
//  Created by kaushik on 15/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "PersistenceManager.h"
#import <sqlite3.h>
#import "KeychainItemWrapper.h"

@interface PersistenceManager ()

@property (assign) int profileCounter;
@property (assign) sqlite3 *database;

@property (nonatomic,retain) NSString *databasePath;
@end


@implementation PersistenceManager

-(id)init{
    
    self = [super init];
    
    if(self){
        
        self.profileCounter = [self getProfileCounter];
        
        [self setDatabasePath];
        
        [self initializeDatabase];
    }
    
    return self;
}

#pragma mark
#pragma mark Supporting Methods

-(void)setDatabasePath{
    
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc] initWithString:
                     [docsDir stringByAppendingPathComponent: @"profiles.db"]];
}

// It will create the DB & table only for the first time.
// From the 2nd time onwards it just checks for their existence. If they are thare it does nothing, else it creates again.

-(void)initializeDatabase{
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:_databasePath]){ // Will be called the very first time
        
        const char *dbPath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbPath, &_database) == SQLITE_OK){
            
            NSLog(@"Creating DB\n");
            
            char *errMsg;
            const char *sql_stmt =  "CREATE TABLE IF NOT EXISTS profilesTable (profId INT PRIMARY KEY NOT NULL, profName TEXT NOT NULL UNIQUE, profContents BLOB)";
            
            if (sqlite3_exec(_database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK){
                
                NSLog(@"Table Already Exists\n");
            }
            else{
                
                NSLog(@"Creating Table\n");
            }
            
            sqlite3_close(_database);
        }
        
    }
    else{
        
        NSLog(@"Database Already Exists\n");
    }
    
}

#pragma mark
#pragma mark Exposed Methods

-(void)storeProfileCounter:(int)profileCounter
{
    [[NSUserDefaults standardUserDefaults] setInteger:profileCounter forKey:PROFILECOUNTER];
}
-(int)getProfileCounter
{
    if([[NSUserDefaults standardUserDefaults] valueForKey:PROFILECOUNTER])
        return  (int)[[NSUserDefaults standardUserDefaults] integerForKey:PROFILECOUNTER];
    
    else
        return 0;

}

-(NSString*)addProfileWithName:(NSString*)profileName profileID:(int)profileID AndContents:(NSString*)profileContents{
    
    NSString *result = @"SUCCESS";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:_databasePath]){
        
        const char *dbPath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbPath, &_database) == SQLITE_OK){
            
            const char *queryString = "INSERT INTO profilesTable (profId,profName,profContents) VALUES (?,?,?)";
            sqlite3_stmt *compiledStatement = nil;
            
            if(sqlite3_prepare_v2(_database, queryString, -1, &compiledStatement, NULL) == SQLITE_OK){
                
                sqlite3_bind_int(compiledStatement, 1, profileID);
                sqlite3_bind_text(compiledStatement, 2, [profileName UTF8String], -1, SQLITE_TRANSIENT);
                NSData* data = [profileContents dataUsingEncoding:NSUTF8StringEncoding];
                sqlite3_bind_blob(compiledStatement, 3, [data bytes], [data length], SQLITE_TRANSIENT);
                data = nil;
                if(sqlite3_step(compiledStatement) != SQLITE_DONE){
                    result = @"Error creating profile";
                    NSLog(@"%s---%@",sqlite3_errmsg(_database),result);
                    return [NSString stringWithFormat:@"%s",sqlite3_errmsg(_database)];
                    
                }
            }
            else{
                result = @"Error creating INSERT statement";
            }
            
            sqlite3_finalize(compiledStatement);
            sqlite3_close(_database);
        }
    }
    else{
        result = @"Database not found";
    }
    
    return result;
}

-(NSString*)deleteProfileData:(NSString*)profileName{
    
    NSString *result = @"SUCCESS";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:_databasePath]){
        
        const char *dbPath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbPath, &_database) == SQLITE_OK){
            
            NSString *deleteStatement = [NSString stringWithFormat:@"DELETE FROM profilesTable where profName = '%@'",profileName];
            
            char *errMsg;
            const char *sql_stmt = [deleteStatement UTF8String];
            
            if (!sqlite3_exec(_database, sql_stmt, NULL, NULL, &errMsg) == SQLITE_OK){
                result = [NSString stringWithCString:errMsg encoding:NSUTF8StringEncoding];
            }
            
            sqlite3_close(_database);
        }
        
    }
    else{
        result = @"Database not found";
    }
    
    return result;
    
}

-(NSString*)getProfile:(int)profileID{
    
    NSString *profileContents = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:_databasePath]){
        
        const char *dbPath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbPath, &_database) == SQLITE_OK){
            
            NSString *selectStatement = [NSString stringWithFormat:@"SELECT profContents FROM profilesTable WHERE profId=%d",profileID];
            const char *sql_stmt = [selectStatement UTF8String];
            sqlite3_stmt *statement = nil;
            
            int result = sqlite3_prepare_v2(_database, sql_stmt, -1, &statement, NULL);
            
            if(result == SQLITE_OK){
                
                if(sqlite3_step(statement) == SQLITE_ROW){
                    @autoreleasepool {
                        NSData *data = [[NSData alloc] initWithBytes: sqlite3_column_blob(statement, 0) length: sqlite3_column_bytes(statement, 0)];
                        profileContents = [[NSString alloc] initWithBytes:(char *)data.bytes length:data.length encoding:NSUTF8StringEncoding];;
                    };
                }
            }
            sqlite3_finalize(statement);
            sqlite3_close(_database);
        }
    }
    
    
    return profileContents;
}

-(NSString*)getProfileWithName : (NSString*)profileName
{
    NSString *profileContents = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:_databasePath]){
        
        const char *dbPath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbPath, &_database) == SQLITE_OK){
            
           // NSString *selectStatement = [NSString stringWithFormat:@"SELECT profContents FROM profilesTable WHERE profName= ' ",@"%@",profileName];
            NSString* selectStatement = [[NSString alloc] initWithFormat:@"%@%@%@",@"SELECT profContents FROM profilesTable WHERE profName='",profileName,@"';" ];
            const char *sql_stmt = [selectStatement UTF8String];
            sqlite3_stmt *statement = NULL;//(sqlite3_stmt*)malloc(sizeof(sqlite3_stmt*));
            
            int result = sqlite3_prepare_v2(_database, sql_stmt, -1, &statement, 0);
            
            if(result == SQLITE_OK){
                
                //NSLog(@"error is %d",sqlite3_step(statement));
                if(sqlite3_step(statement) == SQLITE_ROW){
                    @autoreleasepool {
                        NSData *data = [[NSData alloc] initWithBytes: sqlite3_column_blob(statement, 0) length: sqlite3_column_bytes(statement, 0)];
                        profileContents = [[NSString alloc] initWithBytes:(char *)data.bytes length:data.length encoding:NSUTF8StringEncoding];;
                    };
                }
            }
            sqlite3_finalize(statement);
            sqlite3_close(_database);
        }
    }
    
    
    return profileContents;
}

-(NSString*)updateProfile:(int)profileID withContents:(NSString*)profileContents
{  //This method will replace a row in the table {
    
    NSString *result = @"SUCCESS";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:_databasePath]){
        
        const char *dbPath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbPath, &_database) == SQLITE_OK){
            
           /// NSString *selectStatement = [NSString stringWithFormat:@"UPDATE profilesTable SET profContents=\"%@\" WHERE profId=%d",profileContents,profileID];
            NSString *selectStatement = [NSString stringWithFormat:@"%@%@%@%d",@"UPDATE profilesTable SET profContents='",profileContents,@"' WHERE profId =",profileID];
            char *errMsg;
            const char *sql_stmt = [selectStatement UTF8String];
            
            if (!sqlite3_exec(_database, sql_stmt, NULL, NULL, &errMsg) == SQLITE_OK){
                
                result = [NSString stringWithCString:errMsg encoding:NSUTF8StringEncoding];
            }
            sqlite3_close(_database);
        }
    }
    else{
        result = @"Database not found";
    }
    
    return result;
}

//temporary method remove
-(NSString*)replaceProfile:(NSString*)profileName withID:(int)profileID withContents: (NSString*)profileContents
{
    NSString *result = @"SUCCESS";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:_databasePath]){
        
        const char *dbPath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbPath, &_database) == SQLITE_OK){
            
            const char *queryString = "REPLACE INTO profilesTable (profId,profName,profContents) VALUES (?,?,?)";
            sqlite3_stmt *compiledStatement = nil;
            
            if(sqlite3_prepare_v2(_database, queryString, -1, &compiledStatement, NULL) == SQLITE_OK){
                
                sqlite3_bind_int(compiledStatement, 1, profileID);
                sqlite3_bind_text(compiledStatement, 2, [profileName UTF8String], -1, SQLITE_TRANSIENT);
                NSData* data = [profileContents dataUsingEncoding:NSUTF8StringEncoding];
                sqlite3_bind_blob(compiledStatement, 3, [data bytes], [data length], SQLITE_TRANSIENT);
                data = nil;
                if(sqlite3_step(compiledStatement) != SQLITE_DONE){
                    result = @"Error creating profile";
                    NSLog(@"%s---%@",sqlite3_errmsg(_database),result);
                    return [NSString stringWithFormat:@"%s",sqlite3_errmsg(_database)];
                    
                }
            }
            else{
                result = @"Error creating INSERT statement";
            }
            
            sqlite3_finalize(compiledStatement);
            sqlite3_close(_database);
        }
    }
    else{
        result = @"Database not found";
    }
    
    return result;

}

-(NSArray*)getListofProfiles{
    
    NSMutableArray *profilesList = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:_databasePath]){
        
        const char *dbPath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbPath, &_database) == SQLITE_OK){
            
            NSString *selectStatement = [NSString stringWithFormat:@"SELECT profID,profName FROM profilesTable"];
            const char *sql_stmt = [selectStatement UTF8String];
            sqlite3_stmt *statement = nil;
            
            
            if(sqlite3_prepare_v2(_database, sql_stmt, -1, &statement, NULL) == SQLITE_OK){
                
                while(sqlite3_step(statement) == SQLITE_ROW){
                    
                    @autoreleasepool {
                        NSDictionary *rowDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:(const char*)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding], @"profId",[NSString stringWithCString:(const char*)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding],@"profName", nil];
                        [profilesList addObject:rowDict];
                        rowDict = nil;
                    }
                }
            }
            sqlite3_finalize(statement);
            sqlite3_close(_database);
        }
    }
    
    
    
    return profilesList;
}

+(BOOL)isAppStatsSaved{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:APPSTATSINFO]) {
        return YES;
    }
    return NO;
}
+(void)storeAppStats:(NSDictionary*)appStatsInfo{
    [[NSUserDefaults standardUserDefaults]setObject:appStatsInfo forKey:APPSTATSINFO];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+(NSMutableDictionary*)getAppStatsInfo{
    return [[[NSUserDefaults standardUserDefaults]valueForKey:APPSTATSINFO]mutableCopy];
}

+(void)storeUserLoginInfo:(BOOL)login{
    [[NSUserDefaults standardUserDefaults]setBool:login forKey:LOGGEDININFO];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+(BOOL)isUserLoggedIn{
    return [[NSUserDefaults standardUserDefaults]boolForKey:LOGGEDININFO];
}
+(void)storeLoginInfo:(NSDictionary*)loginInfo{
    [[NSUserDefaults standardUserDefaults]setObject:loginInfo forKey:USERLOGINDETAILS];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+(NSMutableDictionary*)getUserLoginInfo{
    return [[[NSUserDefaults standardUserDefaults]valueForKey:USERLOGINDETAILS]mutableCopy];
}

+(void)storeRememberUserInfo:(BOOL)rememberUser{
    [[NSUserDefaults standardUserDefaults]setBool:rememberUser forKey:REMEMBERUSERINFO];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+(BOOL)getRememberUserInfo{
    return [[NSUserDefaults standardUserDefaults]boolForKey:REMEMBERUSERINFO];
}

+(void)storeActiveProfileName:(NSString*)profileName{
    [[NSUserDefaults standardUserDefaults]setValue:profileName forKey:ACTIVEPROFILE];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+(NSString*)getActiveProfileName{
    return [[NSUserDefaults standardUserDefaults]valueForKey:ACTIVEPROFILE];
}
+(BOOL)isActiveProfileNameSaved{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:ACTIVEPROFILE]) {
        return YES;
    }
    return NO;
}

+(void)storeBackSignature:(BOOL)backSignature{
    [[NSUserDefaults standardUserDefaults]setBool:backSignature forKey:CDBACKSIGNATURE];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+(BOOL)getBackSignature{
    return [[NSUserDefaults standardUserDefaults]boolForKey:CDBACKSIGNATURE];
}

+(void)storeCheckInformation:(NSArray*)results{
    [[NSUserDefaults standardUserDefaults]setValue:results forKey:CDCHECKINFORMATION];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+(NSMutableArray*)getCheckInformation{
    return [[[NSUserDefaults standardUserDefaults]valueForKey:CDCHECKINFORMATION]mutableCopy];
}

+(void)setAppRunStatus{
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:FIRSTTIMELAUNCH];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(BOOL)hasAppRunBefore{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:FIRSTTIMELAUNCH]) {
        return YES;
    }
    return NO;
}


+(NSString *)getLicenseString
{
    // reset keychain license for evry fresh install.
    if ([self hasAppRunBefore] == NO) {
        [self resetKeychainItem];
    }
    
    NSString *license = @"";
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
    if ([[keychain objectForKey:(__bridge id)(kSecAttrAccount)] length]) {
        license = [NSString stringWithFormat:@"%@",[keychain objectForKey:(__bridge id)(kSecAttrAccount)]];
    }
    return license;
}

+(void )setLicenseString:(NSString *)license
{
    if ([self hasAppRunBefore] == NO) {
        [self setAppRunStatus];
    }
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
    [keychain setObject:license forKey:(__bridge id)(kSecAttrAccount)];
}

+(void)resetKeychainItem
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
    [keychain resetKeychainItem];
}


@end
