//
//  RTTIServer.m
//  KofaxMobileDemo
//
//  Created by Mahendra on 01/04/15.
//  Copyright (c) 2016 Kofax. All rights reserved.
//

#import "RTTIServer.h"

@implementation RTTIServer



-(void)extractImagesData : (NSArray*)processedImages saveOriginalImages : (NSArray*)originalImages withParams:(NSDictionary*)params withMimeType :(KEDImageMimeType) MIME_TYPE
{
    NSMutableURLRequest* request = [self formRequestWithImages:processedImages originalImages:originalImages withParams:params withMimeType :(KEDImageMimeType) MIME_TYPE];
    [self makeConnection: request];
} 

-(NSMutableURLRequest*)formRequestWithImages:(NSArray*)processedImages originalImages: (NSArray*)originalImages withParams:(NSDictionary*)parameters withMimeType :(KEDImageMimeType) MIME_TYPE
{
    //Form  a request
    
    NSMutableURLRequest  *request = [NSMutableURLRequest requestWithURL:self.serverURL cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:100];
    [request setHTTPMethod:@"POST"];
    
    //make a boundary to differentiate (can be any text)
    NSString *boundary = @"---------------------------kofaxmobileteam";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    //make body of the request
    NSMutableData *body = [NSMutableData data];
    
    // If processed image and unprocessed images  are available  then add them to body. The Processed images needs to be at top of the body , so that they are sent to KTM for processing and other images are saved to output location.
    
    NSMutableArray *arrImages = [[NSMutableArray alloc]init];
    if(processedImages!=nil && processedImages.count>0) {
        
        [arrImages addObjectsFromArray:processedImages];
    }
    
    if(originalImages!=nil && originalImages.count>0) {
        
        [arrImages addObjectsFromArray:originalImages];
    }
    
    processedImages = nil;
    originalImages = nil;
    
    if(arrImages) {
        
        for (kfxKEDImage *image in arrImages) {
            
            image.imageMimeType = MIME_TYPE;
            
            int errorStatus = [image imageWriteToFileBuffer];
           
            
            if(errorStatus != KMC_SUCCESS){
                
                NSError *error = [NSError errorWithDomain:@"" code:errorStatus userInfo:nil] ;
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(didFailToExtractData:responseCode:)])
                    [self.delegate didFailToExtractData:error responseCode:errorStatus];
                
                return nil;

                
            }
           
            NSData * data = [NSData dataWithBytes:[image getImageFileBuffer] length:image.imageFileBufferSize];
            [image clearFileBuffer];
            
            NSString *fileName = @"image";
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"imageToAttach\"; filename=\"%@\"\r\n",fileName]dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Type: image/%@\r\n\r\n",MIME_TYPE==MIMETYPE_JPG?MIME_TYPE_JPEG:MIME_TYPE_TIFF] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:data];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            data = nil;
            
        }
    }
    
    arrImages = nil;
    
    
    //add parameters
    
    if(parameters)
    {
        for(int i=0;i<[[parameters allKeys] count];i++)
        {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",[[parameters allKeys] objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
            NSLog(@"key is %@",[[parameters allKeys] objectAtIndex:i]);
            [body appendData:[[parameters valueForKey:[[parameters allKeys] objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
        }
        
    }
    
    //close the form finally
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //set body to the request
    [request setHTTPBody:body];
    
    return request;

}

@end
