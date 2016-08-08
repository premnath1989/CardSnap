//
//  BRAppStateMachine.h
//  BankRight
//
//  Created by kaushik on 02/07/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <kfxLibEngines/kfxEngines.h>



@interface AppStateMachine : NSObject

@property (atomic,assign) moduleType module;

@property (assign) BOOL isFront;

@property (atomic,assign) appStateVal appState;

@property(nonatomic,strong)NSString* directoryPath; // It specifies the current directory path
@property(nonatomic,strong)NSString* photoDirectoryPath; // It specifies the directory path of Images where our images are stored


//deprecated

// uncommented following for CD start

@property (nonatomic,strong) kfxKEDImage *front_raw; // should be replaced with UIImage if no other details are required

@property (nonatomic,strong) kfxKEDImage *front_processed;

@property (nonatomic,strong) kfxKEDImage *back_raw; // should be replaced with UIImage if no other details are required

@property (nonatomic,strong) kfxKEDImage *back_processed;

// uncommented following for CD End




+(id)sharedInstance;

-(BOOL)storeImage:(kfxKEDImage*)image withType:(imageType)type mimeType:(KEDImageMimeType)mimeType;
-(kfxKEDImage*)getImage : (imageType)type mimeType:(KEDImageMimeType)mimeType;
-(BOOL)isImageInDisk:(imageType)type mimeType:(KEDImageMimeType)mimeType;
-(BOOL)cleanUpDisk;

-(void)removeFilePathIfExists :(NSString *)strFilePath;
-(BOOL)storeToDisk:(kfxKEDImage*)image withType:(imageType)type mimeType:(KEDImageMimeType)mimeType;
-(NSString *)getFilePathWithType:(imageType)type mimeType:(KEDImageMimeType)mimeType;
@end
