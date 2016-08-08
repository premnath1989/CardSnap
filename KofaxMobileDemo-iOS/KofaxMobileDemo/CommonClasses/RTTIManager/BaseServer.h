//
//  BaseServer.h
//  KofaxMobileDemo
//
//  Created by Mahendra on 01/04/15.
//  Copyright (c) 2016 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <kfxLibEngines/kfxEngines.h>

@protocol ServerProtocol <NSObject>
@optional
-(void)didExtractData:(NSInteger)statusCode withResults:(NSData*)results;
-(void)didFailToExtractData:(NSError*)error responseCode:(NSInteger)responseCode;

@end


@interface BaseServer : NSObject <NSURLSessionDelegate>
{
    
}


@property id <ServerProtocol> delegate;
@property(nonatomic,strong)NSString* project;
@property(nonatomic,strong)NSURL* serverURL;
@property(nonatomic,assign)BOOL isProcessNameSync;



-(void)extractImagesData : (NSArray*)processedImages saveOriginalImages : (NSArray*)originalImages withParams:(NSDictionary*)params withMimeType :(KEDImageMimeType) MIME_TYPE;

-(NSMutableURLRequest*)formRequestWithImages:(NSArray*)processedImages originalImages: (NSArray*)originalImages withParams:(NSDictionary*)parameters withMimeType :(KEDImageMimeType) MIME_TYPE;


-(void)makeConnection : (NSMutableURLRequest*)request;

@end
