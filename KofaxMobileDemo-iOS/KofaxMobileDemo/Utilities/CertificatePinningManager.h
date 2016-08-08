//
//  CertificatePinningManager.h
//  Kofax Mobile Demo
//
//  Copyright (c) 2016 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CertificatePinningManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)handleConnection:(NSURLConnection*)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge;

- (BOOL)handleURLSession:(NSURLSession*)session
     didReceiveChallenge:(NSURLAuthenticationChallenge*)challenge
       completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential* credential))completionHandler;

@end
