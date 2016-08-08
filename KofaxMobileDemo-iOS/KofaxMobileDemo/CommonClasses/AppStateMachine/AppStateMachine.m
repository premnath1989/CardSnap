//
//  BRAppStateMachine.m
//  BankRight
//
//  Created by kaushik on 02/07/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "AppStateMachine.h"


// Used to fetch the name of the image currently being stored on the disk
NSString * const imageType_toString[] = {
    [FRONT_RAW] = @"frontRawImage",
    [FRONT_PROCESSED] = @"frontProcessedImage",
    [BACK_RAW] = @"backRawImage",
    [BACK_PROCESSED] = @"backProcessedImage"
};

// Used to fetch the type of file extension based on MIME type. The MIME types currently considered are from the SDK .

// TODO : Implemenet this in SDK . So that whenever a MIME type is added/ removed , this will require a change respectively
NSString * const KEDImageMimeType_toString[] = {
    [MIMETYPE_UNKNOWN] = @"jpg",
    [MIMETYPE_JPG] = @"jpg",
    [MIMETYPE_PNG] = @"png",
    [MIMETYPE_TIF] = @"tif",
    [MIMETYPE_LAST] = @"jpg"
};


// Used to fetch the MIME  type need for attachment in Mail 
NSString * const KEDImageMimeType_toExtensionString[] = {
    [MIMETYPE_UNKNOWN] = @"image/jpeg",
    [MIMETYPE_JPG] = @"image/jpeg",
    [MIMETYPE_PNG] = @"image/png",
    [MIMETYPE_TIF] = @"image/tiff",
    [MIMETYPE_LAST] = @"image/jpeg"
};

#define IMAGESSDIRECTORY @"IMAGES"

@implementation AppStateMachine



+(id)sharedInstance{
    
    static AppStateMachine *appStateMachine = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
            appStateMachine = [[AppStateMachine alloc] init];
            [appStateMachine createPhotosDircetory];
    });

    return appStateMachine;
}


// This method is used to store the image in disk by using the SDK "imageWriteToFile" method

-(BOOL)storeImage:(kfxKEDImage*)image withType:(imageType)type mimeType:(KEDImageMimeType)mimeType
{
    NSString* filepath = [self getFilePathWithType:type mimeType:mimeType];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        [[NSFileManager defaultManager]removeItemAtPath:filepath error:nil];
    }
    //uncomment this if you want to use SDK methods to write the image to disk
    /*
    image.imageMimeType = MIMETYPE_PNG;
     NSLog(@"time now ");
    [image specifyFilePath:filepath];
    
    int error = [image imageWriteToFile];
     NSLog(@"time after");
    [image clearImageBitmap];
     NSLog(@"error is %d",error);
     NSLog(@"error is %@",[kfxError findErrDesc:error]);
    */
    
    [image specifyFilePath:filepath];
    if([image imageWriteToFile] == KMC_SUCCESS)
    {
        //[image clearImageBitmap];
        return YES;
    }
    else
    {
        [image clearImageBitmap];
    }
    
    return NO;
}

// This method is used to fetch the image on disk by using the SDK method
-(kfxKEDImage*)getImage : (imageType)type mimeType:(KEDImageMimeType)mimeType
{
    
    NSString* filePath = [self getFilePathWithType:type mimeType:mimeType];
    
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        kfxKEDImage* image =  [[kfxKEDImage alloc] init];
        [image specifyFilePath:filePath];
        [image imageReadFromFile];
        
        return image;

    }
    return nil;
}

// This method is used to fetch the raw or captured images stored on the disk .
-(BOOL)storeToDisk:(kfxKEDImage*)image withType:(imageType)type mimeType:(KEDImageMimeType)mimeType
{
    NSString* filePath = [self getFilePathWithType:type mimeType:mimeType];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
    }
    
    // Currently we are storing the JPEG of the image instead of kfxKEDImage , since this is used only for raw images . Currently we don't use any properties of raw images.
    NSData *data = UIImageJPEGRepresentation([image getImageBitmap], 1.0);
    if ([data writeToFile:filePath atomically:YES])
    {
        NSLog(@"Success");
        return YES;
    }
    else
    {
        NSLog(@"Failed");
    }
    data = nil;
    return NO;
}

// This methid is used to check if the specified image is on Disk .
-(BOOL)isImageInDisk:(imageType)type mimeType:(KEDImageMimeType)mimeType
{
    NSString* filePath = [self getFilePathWithType:type mimeType:mimeType];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return YES;
    }
    return NO;
}

// Creates the Photo Directory and Directory Path
-(void)createPhotosDircetory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.directoryPath = [paths objectAtIndex:0];
    NSString *dirPath = [self.directoryPath stringByAppendingPathComponent:IMAGESSDIRECTORY];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    BOOL isDirExists = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    if (!isDirExists)
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:nil];
    self.photoDirectoryPath = dirPath;
}

// Clears all the images on Disk
-(BOOL)cleanUpDisk
{
    for (NSString *path  in [self getAllFilesAtPath:self.photoDirectoryPath]) {
        [self removeFilePathIfExists:[self.photoDirectoryPath stringByAppendingPathComponent:path]];
    }
    return YES;;
}

-(NSArray *)getAllFilesAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path  error:nil];
}

// This generates the file path from the image type anf MIME type
-(NSString *)getFilePathWithType:(imageType)type mimeType:(KEDImageMimeType)mimeType
{
    NSString* fileName;
    fileName = [self.photoDirectoryPath stringByAppendingPathComponent:imageType_toString[type]];
    fileName = [fileName stringByAppendingPathExtension:KEDImageMimeType_toString[mimeType]];
    return fileName;
}


// Removes the specified file  from the disk .
-(void)removeFilePathIfExists :(NSString *)strFilePath {
    
    
    if([[NSFileManager defaultManager] fileExistsAtPath:strFilePath])
    {
        [[NSFileManager defaultManager]removeItemAtPath:strFilePath error:nil];
    }
}


@end
