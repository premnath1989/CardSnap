//
//  RTTIManager.m
//  BankRight
//
//  Created by kaushik on 04/08/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "ExtractionManager.h"
#import "AppStateMachine.h"
#import "RTTIServer.h"
#import "KTAServer.h"
#import "CertificatePinningManager.h"

@interface ExtractionManager()<ServerProtocol, NSURLSessionDelegate> {
    
    
    NSMutableData *receivedData;
}

//@property(nonatomic,strong) NSURL *serverURL;
//
//@property(nonatomic,strong) kfxKEDImage *inputImage;

@property (nonatomic, strong) NSURLSessionDataTask * dataTask;
@property (nonatomic)int responseCode;
@property (nonatomic) OnDeviceExtractor* onDeviceExtractor;

@end
@implementation ExtractionManager


-(id)init
{
    if(self = [super init])
    {
        self.onDeviceExtractor = [[OnDeviceExtractor alloc] init];
        [self setDefaults];
    }
    
    return self;
}


-(void)setDefaults
{
    _serverType = RTTI;
}

-(void)extractDataForImage:(kfxKEDImage*)processedImage URL:(NSURL*)serverURL withMimeType :(KEDImageMimeType) MIME_TYPE
{
    // This would talk to RTTI Server and send result of extraction to CD/BP/DL Manager as a dictionary
    
    if(![AppUtilities isConnectedToNetwork])
    {
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(extractionSucceeded:withResults:)])
            [self.delegate extractionSucceeded:0 withResults:nil];
        
        return;
    }
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    defaultConfigObject.URLCache = nil;
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    
    processedImage.imageMimeType = MIMETYPE_TIF;
    [processedImage imageWriteToFileBuffer];
    
    NSData * imageData;
    imageData = [NSData dataWithBytes:[processedImage getImageFileBuffer] length:processedImage.imageFileBufferSize];
    [processedImage clearFileBuffer];
    
    NSMutableURLRequest  *urlRequest = [NSMutableURLRequest requestWithURL:serverURL cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
    [urlRequest setHTTPMethod:@"PUT"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:[NSString stringWithFormat:@"image/%@",MIME_TYPE==MIMETYPE_JPG?MIME_TYPE_JPEG:MIME_TYPE_TIFF] forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:imageData];
    
    self.dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSInteger extractionResponseCode = [((NSHTTPURLResponse *)response) statusCode];
        if(!error && data.length>0)
        {
            NSString *receievedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"receievedString = %@\n",receievedString);
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(extractionSucceeded:withResults:)])
                [self.delegate extractionSucceeded:[(NSHTTPURLResponse*)response statusCode] withResults:data];
        }else{
            if(self.delegate && [self.delegate respondsToSelector:@selector(extractionFailedWithError:responseCode:)])
                [self.delegate extractionFailedWithError:error responseCode:extractionResponseCode];
        }
        
    }];
    [self.dataTask resume];
    
}

- (void)URLSession:(NSURLSession*)session didReceiveChallenge:(NSURLAuthenticationChallenge*)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential* credential))completionHandler
{
    if (![[CertificatePinningManager sharedInstance] handleURLSession:session didReceiveChallenge:challenge completionHandler:completionHandler])
    {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

-(void)cancelExtraction
{
    //cancel extraction
    [self.dataTask suspend];
}




//This method makes a mulit-part request to the RTTI server Send's the processed and unprocessed images and the server URL Required parameters can be passed as a dictionary and all the keys and values are added as parameters The same method can be used to send even one image



-(void)extractImagesData:(NSArray*)processedImagesArray saveOriginalImages:(NSArray*)originalImagesArray withURL:(NSURL*)url withParams: (NSDictionary*)paramsDict withMimeType :(KEDImageMimeType) MIME_TYPE
{
    
    if(self.serverType == RTTI)
    {
        RTTIServer* rttiServerObj = [[RTTIServer alloc] init];
        rttiServerObj.serverURL = url;
        rttiServerObj.delegate = self;
        
        [rttiServerObj extractImagesData:processedImagesArray saveOriginalImages:originalImagesArray withParams:paramsDict withMimeType:MIME_TYPE];
        
    }
    else if(self.serverType == KTA)
    {
        //instantiate KTA object and form a request
        KTAServer *ktaServerObj = [[KTAServer alloc]init];
        ktaServerObj.delegate = self;
        ktaServerObj.serverURL = url;
        ktaServerObj.isProcessNameSync=NO;
        [ktaServerObj extractImagesData:processedImagesArray saveOriginalImages:originalImagesArray withParams:paramsDict withMimeType:MIME_TYPE];
    }
}

-(void)extractImagesDataWithProcessNameSync:(NSArray*)processedImagesArray saveOriginalImages:(NSArray*)originalImagesArray withURL:(NSURL*)url withParams: (NSDictionary*)paramsDict withMimeType :(KEDImageMimeType) MIME_TYPE
{
    
    if(self.serverType == RTTI)
    {
        RTTIServer* rttiServerObj = [[RTTIServer alloc] init];
        rttiServerObj.serverURL = url;
        rttiServerObj.delegate = self;
        
        [rttiServerObj extractImagesData:processedImagesArray saveOriginalImages:originalImagesArray withParams:paramsDict withMimeType:MIME_TYPE];
        
    }
    else if(self.serverType == KTA)
    {
        //instantiate KTA object and form a request
        KTAServer *ktaServerObj = [[KTAServer alloc]init];
        ktaServerObj.delegate = self;
        ktaServerObj.serverURL = url;
        ktaServerObj.isProcessNameSync=YES;
        [ktaServerObj extractImagesData:processedImagesArray saveOriginalImages:originalImagesArray withParams:paramsDict withMimeType:MIME_TYPE];
    }
}

-(int)extractImageFilesWithProcessSync : (NSArray*)processedImageFiles saveOriginalImages: (NSArray*)originalImageFiles withURL:(NSURL*)url withParams:(NSDictionary*)paramsDict withMimeType :(KEDImageMimeType) MIME_TYPE{
    
    @autoreleasepool {
        NSMutableArray* processedImageArray = [[NSMutableArray alloc] init];
        NSMutableArray* originalImageArray = [[NSMutableArray alloc] init];
        int errorCode;
        //iterate through the file paths and read corresponding images
        for(int i=0;i<[processedImageFiles count];i++){
            //Read the image from the file path
            kfxKEDImage* imageFromFilePath = [[kfxKEDImage alloc] init];
            errorCode = [imageFromFilePath specifyFilePath:[processedImageFiles objectAtIndex:i]];
            
            if(errorCode != KMC_SUCCESS)
                return errorCode;
            
            errorCode = [imageFromFilePath imageReadFromFile];
            
            if(errorCode != KMC_SUCCESS)
                return errorCode;
            
            //Allocate a new image with the bitmap of image in file path. This is needed for us to be able to write to the file buffer and read the file buffer subsequently
            kfxKEDImage* imageTemporary = [[kfxKEDImage alloc] init];
            [imageTemporary specifyImageBitmap:[imageFromFilePath getImageBitmap]];
            imageTemporary.imageDPI = imageFromFilePath.imageDPI; //preserve the dpi
            
            [processedImageArray addObject:imageTemporary];
            
            [imageFromFilePath clearImageBitmap];
            imageFromFilePath = nil;
            imageTemporary = nil;
            
        }
        
        for(int i=0;i<[originalImageFiles count];i++){
            //Read the image from the file path
            kfxKEDImage* imageFromFilePath = [[kfxKEDImage alloc] init];
            errorCode = [imageFromFilePath specifyFilePath:[originalImageFiles objectAtIndex:i]];
            
            if(errorCode != KMC_SUCCESS)
                return errorCode;
            
            errorCode = [imageFromFilePath imageReadFromFile];
            
            if(errorCode != KMC_SUCCESS)
                return errorCode;
            
            //Allocate a new image with the bitmap of image in file path. This is needed for us to be able to write to the file buffer and read the file buffer subsequently
            kfxKEDImage* imageTemporary = [[kfxKEDImage alloc] init];
            [imageTemporary specifyImageBitmap:[imageFromFilePath getImageBitmap]];
            imageTemporary.imageDPI = imageFromFilePath.imageDPI; //preserve the dpi
            
            [originalImageArray addObject:imageTemporary];
            
            [imageFromFilePath clearImageBitmap];
            imageFromFilePath = nil;
            imageTemporary = nil;
            
        }
        
        
        [self extractImagesDataWithProcessNameSync:processedImageArray saveOriginalImages:originalImageArray withURL:url withParams:paramsDict withMimeType:MIME_TYPE];
        
        return KMC_SUCCESS;
    }

}


-(int)extractImageFiles : (NSArray*)processedImageFiles saveOriginalImages: (NSArray*)originalImageFiles withURL:(NSURL*)url withParams:(NSDictionary*)paramsDict withMimeType :(KEDImageMimeType) MIME_TYPE
{
    @autoreleasepool {
        NSMutableArray* processedImageArray = [[NSMutableArray alloc] init];
        NSMutableArray* originalImageArray = [[NSMutableArray alloc] init];
        int errorCode;
        //iterate through the file paths and read corresponding images
        for(int i=0;i<[processedImageFiles count];i++){
            //Read the image from the file path
            kfxKEDImage* imageFromFilePath = [[kfxKEDImage alloc] init];
            errorCode = [imageFromFilePath specifyFilePath:[processedImageFiles objectAtIndex:i]];
            
            if(errorCode != KMC_SUCCESS)
                return errorCode;
            
            errorCode = [imageFromFilePath imageReadFromFile];
            
            if(errorCode != KMC_SUCCESS)
                return errorCode;
            
            //Allocate a new image with the bitmap of image in file path. This is needed for us to be able to write to the file buffer and read the file buffer subsequently
            kfxKEDImage* imageTemporary = [[kfxKEDImage alloc] init];
            [imageTemporary specifyImageBitmap:[imageFromFilePath getImageBitmap]];
            imageTemporary.imageDPI = imageFromFilePath.imageDPI; //preserve the dpi
            
            [processedImageArray addObject:imageTemporary];
            
            [imageFromFilePath clearImageBitmap];
            imageFromFilePath = nil;
            imageTemporary = nil;
            
        }
        
        for(int i=0;i<[originalImageFiles count];i++){
            //Read the image from the file path
            kfxKEDImage* imageFromFilePath = [[kfxKEDImage alloc] init];
            errorCode = [imageFromFilePath specifyFilePath:[originalImageFiles objectAtIndex:i]];
            
            if(errorCode != KMC_SUCCESS)
                return errorCode;
            
            errorCode = [imageFromFilePath imageReadFromFile];
            
            if(errorCode != KMC_SUCCESS)
                return errorCode;
            
            //Allocate a new image with the bitmap of image in file path. This is needed for us to be able to write to the file buffer and read the file buffer subsequently
            kfxKEDImage* imageTemporary = [[kfxKEDImage alloc] init];
            [imageTemporary specifyImageBitmap:[imageFromFilePath getImageBitmap]];
            imageTemporary.imageDPI = imageFromFilePath.imageDPI; //preserve the dpi
            
            [originalImageArray addObject:imageTemporary];
            
            [imageFromFilePath clearImageBitmap];
            imageFromFilePath = nil;
            imageTemporary = nil;
            
        }
        
        
        [self extractImagesData:processedImageArray saveOriginalImages:originalImageArray withURL:url withParams:paramsDict withMimeType:MIME_TYPE];
        
        return KMC_SUCCESS;
    }
    
}
- (void)extractFieldsOnDeviceFrontImage:(kfxKEDImage*)frontImage backImage:(kfxKEDImage*)backImage region:(kfxKOEIDRegion)region modelsType:(assetProvider)type url:(NSURL*)serverUrl
{
    self.onDeviceExtractor.delegate = self;
    [self.onDeviceExtractor extractFieldsFrontImage:frontImage backImage:backImage region:region modelsType:(assetProvider)type url:serverUrl];
}

-(void)extractFieldsFrontImage:(kfxKEDImage *)frontImage barcode:(NSString *)barcode region:(kfxKOEIDRegion)region modelsType:(assetProvider)type url:(NSURL *)serverUrl
{
    self.onDeviceExtractor.delegate = self;
    [self.onDeviceExtractor extractFieldsFrontImage:frontImage barcode:barcode region:region modelsType:(assetProvider)type url:serverUrl];
}

-(BOOL)isLocalVersionAvailable:(kfxKOEIDRegion)region
{
   return [self.onDeviceExtractor isLocalVersionAvailable:region];
}


#pragma mark
#pragma server protocol methods
-(void)didExtractData:(NSInteger)statusCode withResults:(NSData *)results
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(extractionSucceeded:withResults:)])
        [self.delegate extractionSucceeded:statusCode withResults:results];
}

-(void)didFailToExtractData:(NSError *)error responseCode:(NSInteger)responseCode
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(extractionFailedWithError:responseCode:)])
        [self.delegate extractionFailedWithError:error responseCode:responseCode];
}


@end
