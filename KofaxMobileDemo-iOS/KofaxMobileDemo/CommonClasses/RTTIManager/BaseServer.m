//
//  BaseServer.m
//  KofaxMobileDemo
//
//  Created by Mahendra on 01/04/15.
//  Copyright (c) 2016 Kofax. All rights reserved.
//

//This class is the base server class which should have the basic properties that a server object should have

#import "BaseServer.h"
#import "CertificatePinningManager.h"

@interface BaseServer()
{
    
}

@property (nonatomic, strong) NSURLSessionDataTask * dataTask;
@property (nonatomic)int responseCode;


@end

@implementation BaseServer

-(void)extractImagesData : (NSArray*)processedImages saveOriginalImages : (NSArray*)originalImages withParams:(NSDictionary*)params withMimeType :(KEDImageMimeType) MIME_TYPE
{
    
}


-(void)makeConnection : (NSMutableURLRequest*)request
{
    
    if(request!=nil){
        
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        defaultConfigObject.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        defaultConfigObject.URLCache = nil;
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
        
        self.dataTask =[defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSInteger extractionResponseCode = [((NSHTTPURLResponse *)response) statusCode];
            if(!error && data.length>0 && extractionResponseCode == 200)
            {
                NSString *receievedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"receievedString = %@\n",receievedString);
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(didExtractData:withResults:)])
                    [self.delegate didExtractData:[(NSHTTPURLResponse*)response statusCode] withResults:data];
            }
            else
            {
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(didFailToExtractData:responseCode:)])
                    [self.delegate didFailToExtractData:error responseCode:extractionResponseCode];
            }
            
        }];
        [self.dataTask resume];

    }
   
}

- (void)URLSession:(NSURLSession*)session didReceiveChallenge:(NSURLAuthenticationChallenge*)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential* credential))completionHandler
{
    if (![[CertificatePinningManager sharedInstance] handleURLSession:session didReceiveChallenge:challenge completionHandler:completionHandler])
    {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

@end
