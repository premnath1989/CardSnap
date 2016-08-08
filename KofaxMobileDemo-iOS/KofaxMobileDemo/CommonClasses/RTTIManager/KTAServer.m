//
//  KTAServer.m
//  KofaxMobileDemo
//
//  Created by Mahendra on 01/04/15.
//  Copyright (c) 2016 Kofax. All rights reserved.
//

#import "KTAServer.h"
#import "Constants.h"

@interface KTAServer ()<NSXMLParserDelegate>
@property (nonatomic, strong) NSMutableString *sessionId,*documentId;
@property (nonatomic, strong) NSArray *processedImgs,*originalImgs;
@property (nonatomic, strong) NSDictionary *inputParams;
@property (nonatomic, strong) NSMutableDictionary *responseDictionary;
@property (nonatomic, assign) KEDImageMimeType MIME_TYPE;
@end

@implementation KTAServer

-(void)extractImagesData : (NSArray*)processedImages saveOriginalImages : (NSArray*)originalImages withParams:(NSDictionary*)params withMimeType:(KEDImageMimeType)MIME_TYPE
{
    self.processedImgs = processedImages;
    self.originalImgs = originalImages;
    self.inputParams = params;
    self.MIME_TYPE = MIME_TYPE;
    
    //Send the login reqeust if user not logged into KTA
    if (self.sessionId) {
        NSMutableURLRequest* request = [self formRequestWithImages:processedImages originalImages:originalImages withParams:params withMimeType:self.MIME_TYPE];
        [self makeConnection: request];
        
        request = nil;
    }
    else{
        
        //Set documentid and responsedictionary to nil before doing extraction
        self.documentId = nil;
        self.responseDictionary = nil;
        
        //Get the document id
        NSMutableURLRequest *loginRequest = [self formLoginRequest:processedImages saveOriginalImages:originalImages withParams:params];
        [self makeConnection:loginRequest];
        
        loginRequest = nil;
    }
}

//This method is used to form the extraction request
-(NSMutableURLRequest*)formRequestWithImages:(NSArray*)processedImages originalImages: (NSArray*)originalImages withParams:(NSDictionary*)parameters withMimeType:(KEDImageMimeType)MIME_TYPE
{
    
    NSMutableArray *arrImages = [[NSMutableArray alloc]init];
    if(processedImages!=nil && processedImages.count>0) {
        
        [arrImages addObjectsFromArray:processedImages];
    }
    
    if(originalImages!=nil && originalImages.count>0) {
        
        [arrImages addObjectsFromArray:originalImages];
    }
    
    processedImages = nil;
    originalImages = nil;
    
    // Form the dictionary
    
    // Form the input variables dictionary which excludes the Username , Password and Process Identity Name from the "params" dictionary
    
    NSMutableDictionary *dictInputVariables = [[NSMutableDictionary alloc]initWithDictionary:parameters];
    [dictInputVariables removeObjectForKey:USERNAME];
    [dictInputVariables removeObjectForKey:PASSWORD];
    [dictInputVariables removeObjectForKey:PROCESS_IDENTITY_NAME];
    [dictInputVariables removeObjectForKey:DOCUMENT_GROUP_NAME];
    [dictInputVariables removeObjectForKey:DOCUMENT_NAME];
    
    NSMutableArray *arrInputVariables = [[NSMutableArray alloc]init];
    
    for( NSString *strKey in dictInputVariables.allKeys){
        
        NSDictionary * dictInput = [NSDictionary dictionaryWithObjectsAndKeys:strKey,@"Id",[dictInputVariables valueForKey:strKey],@"Value", nil];
        [arrInputVariables addObject:dictInput];
    }
    
    [arrInputVariables addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"ProcessImage",@"Id",[NSNumber numberWithBool:false],@"Value", nil]];
    
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc]init];
    
    
    if(self.isProcessNameSync){
        [jsonDict setValue:[NSMutableDictionary dictionaryWithObjectsAndKeys:arrInputVariables,@"InputVariables",[NSMutableArray arrayWithObjects:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNull null],@"Base64Data",[NSNull null],@"Data",[NSNull null],@"DocumentTypeId",[NSNull null],@"FieldsToReturn",[NSNull null],@"FilePath",[NSNull null],@"FolderId",[NSNull null],@"FolderTypeId",[NSString stringWithFormat:@"image/%@",MIME_TYPE==MIMETYPE_JPG?MIME_TYPE_JPEG:MIME_TYPE_TIFF],@"MimeType",[NSNull null],@"PageImageDataCollection",[NSNull null],@"RuntimeFields",[NSNumber numberWithBool:false],@"DeleteDocument",[NSNumber numberWithBool:false],@"ReturnFullTextOcr",[NSDictionary dictionaryWithObjectsAndKeys:[NSNull null],@"Id",[parameters valueForKey:DOCUMENT_GROUP_NAME],@"Name",[NSNumber numberWithInt:0],@"Version", nil],@"DocumentGroup",[parameters valueForKey:DOCUMENT_NAME],@"DocumentName",[NSNumber numberWithBool:true],@"ReturnAllFields",nil], nil],@"Documents",[NSNull null],@"StartDate",[NSNumber numberWithBool:true],@"StoreFolderAndDocuments", nil] forKey:@"jobWithDocsInitialization"];
    }
    else{
       [jsonDict setValue:[NSMutableDictionary dictionaryWithObjectsAndKeys:arrInputVariables,@"InputVariables",[NSMutableArray arrayWithObjects:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNull null],@"Base64Data",[NSNull null],@"Data",[NSNull null],@"DocumentTypeId",[NSNull null],@"FieldsToReturn",[NSNull null],@"FilePath",[NSNull null],@"FolderId",[NSNull null],@"FolderTypeId",[NSString stringWithFormat:@"image/%@",MIME_TYPE==MIMETYPE_JPG?MIME_TYPE_JPEG:MIME_TYPE_TIFF],@"MimeType",[NSNull null],@"PageImageDataCollection",[NSNull null],@"RuntimeFields",[NSNumber numberWithBool:false],@"DeleteDocument",[NSDictionary dictionaryWithObjectsAndKeys:[NSNull null],@"Id",[parameters valueForKey:DOCUMENT_GROUP_NAME],@"Name",[NSNumber numberWithInt:0],@"Version", nil],@"DocumentGroup",[parameters valueForKey:DOCUMENT_NAME],@"DocumentName",[NSNumber numberWithBool:true],@"ReturnAllFields",nil], nil],@"RuntimeDocumentCollection",[NSNull null],@"StartDate", nil] forKey:@"jobWithDocsInitialization"];
    }
    
    [jsonDict setValue:[NSDictionary dictionaryWithObjectsAndKeys:[NSNull null],@"Id",[parameters valueForKey:PROCESS_IDENTITY_NAME],@"Name",[NSNumber numberWithInt:0],@"Version", nil] forKey:@"processIdentity"];
    [jsonDict setValue:self.sessionId forKey:@"sessionId"];
    [jsonDict setValue:[NSDictionary dictionary] forKey:@"variablesToReturn"];
    
    NSMutableArray *pagesList = [[NSMutableArray alloc]init];
    if(arrImages) {
        for (kfxKEDImage *image in arrImages) {
            image.imageMimeType = self.MIME_TYPE;
            int errorStatus =[image imageWriteToFileBuffer];
            
           
            
            if(errorStatus != KMC_SUCCESS){
                
                NSError *error = [NSError errorWithDomain:@"" code:errorStatus userInfo:nil] ;
                if(self.delegate && [self.delegate respondsToSelector:@selector(didFailToExtractData:responseCode:)])
                    [self.delegate didFailToExtractData:error responseCode:errorStatus];
                
                return nil;
                
                
            }
            
            NSData * data = [NSData dataWithBytes:[image getImageFileBuffer] length:image.imageFileBufferSize];
            [image clearFileBuffer];
            NSString *base64String = [data base64EncodedStringWithOptions:0];
            
             [pagesList addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNull null],@"Data",base64String,@"Base64Data",[NSString stringWithFormat:@"image/%@",MIME_TYPE==MIMETYPE_JPG?MIME_TYPE_JPEG:MIME_TYPE_TIFF],@"MimeType",[NSDictionary dictionary],@"RuntimeFields", nil]];
            
            
            data = nil;
            base64String = nil;
        }
    }
    
    NSMutableArray *runTimeArray;
    if(self.isProcessNameSync){
        runTimeArray = [[jsonDict valueForKey:@"jobWithDocsInitialization"]valueForKey:@"Documents"];
    }
    else{
        runTimeArray = [[jsonDict valueForKey:@"jobWithDocsInitialization"]valueForKey:@"RuntimeDocumentCollection"];
    }
    NSMutableDictionary *runTimeDict = [runTimeArray objectAtIndex:0];
    [runTimeDict setValue:pagesList forKey:@"PageDataList"];
    
    arrImages = nil;
    
    NSError *error = nil;
    NSData *jsonOutputData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonOutputData encoding:NSUTF8StringEncoding];
    
    NSData *jsonData = [[NSData alloc]initWithBytes:[jsonString UTF8String] length:[jsonString length]];
    
    NSURL *url;
    if(self.isProcessNameSync){
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.serverURL,JOBSERVICEWITHSYNC]];
    }else{
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.serverURL,JOBSERVICE]];

    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", (int)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    jsonDict = nil;
    jsonOutputData = nil;
    jsonString = nil;
    jsonData = nil;
    url = nil;
    
    return request;
    
}

//This method is used to form the login request
-(NSMutableURLRequest*)formLoginRequest:(NSArray*)processedImages saveOriginalImages : (NSArray*)originalImages withParams:(NSDictionary*)params{
    NSString *jsonString = [NSString stringWithFormat:@"{\"userIdentityWithPassword\":{\"UserId\":\"%@\",\"Password\":\"%@\",\"LogOnProtocol\":%@,\"UnconditionalLogOn\":%@}}",[params valueForKey:USERNAME],[params valueForKey:PASSWORD],[NSNumber numberWithInt:7],[NSNumber numberWithBool:true]];
    
    NSData *jsonData = [[NSData alloc]initWithBytes:[jsonString UTF8String] length:[jsonString length]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.serverURL,USERSERVICE]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", (int)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    jsonString = nil;
    jsonData = nil;
    url = nil;
    
    return request;
}

//After getting the document id call this method to get the extracted results
-(void)getConfidenceValues{
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.sessionId,@"sessionId",self.documentId,@"documentId",[NSDictionary dictionaryWithObjectsAndKeys:[NSNull null],@"Station", nil],@"reportingData", nil];
    
    NSError *error = nil;
    NSData *jsonOutputData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonOutputData encoding:NSUTF8StringEncoding];
    
    NSData *jsonData = [[NSData alloc]initWithBytes:[jsonString UTF8String] length:[jsonString length]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.serverURL,GETDOCUMENTSERVICE]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", (int)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [self makeConnection:request];
    
    jsonDictionary = nil;
    jsonOutputData = nil;
    jsonString = nil;
    jsonData = nil;
    url = nil;
    request = nil;
}

//Delete the document from KTA server afeter getting the extracted results
-(void)deleteDocument{
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.sessionId,@"sessionId",self.documentId,@"documentId",[NSNumber numberWithBool:true],@"ignoreError",[NSDictionary dictionaryWithObjectsAndKeys:[NSNull null],@"Station", nil],@"reportingData", nil];
    
    NSError *error = nil;
    NSData *jsonOutputData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonOutputData encoding:NSUTF8StringEncoding];
    
    NSData *jsonData = [[NSData alloc]initWithBytes:[jsonString UTF8String] length:[jsonString length]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.serverURL,DELETEDOCUMENTSERVICE]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", (int)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [self makeConnection:request];
    
    jsonDictionary = nil;
    jsonOutputData = nil;
    jsonString = nil;
    jsonData = nil;
    url = nil;
    request = nil;
}

//Form the respone same as RTTI response
-(NSMutableDictionary*)mergeExtractedResult{
    NSMutableArray *fieldsArr = [[self.responseDictionary valueForKey:@"d"]valueForKey:@"Fields"];
    
    NSMutableDictionary *extractionOutput = [[NSMutableDictionary alloc]init];
    
    
    [extractionOutput setValue:self.sessionId forKey:@"sessionKey"];
    [extractionOutput setValue:[[NSArray alloc]init] forKey:@"words"];
    [extractionOutput setValue:[[NSArray alloc]init] forKey:@"classificationResult"];
    [extractionOutput setValue:[[self.responseDictionary valueForKey:@"d"]valueForKey:@"ParentId"] forKey:@"documentId"];
    [extractionOutput setValue:[self.inputParams valueForKey:DOCUMENT_NAME] forKey:@"extractionClass"];
    
    NSMutableArray *fieldArray = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in fieldsArr) {
        NSMutableDictionary *fieldObj = [[NSMutableDictionary alloc]init];
        [fieldObj setValue:[[dict valueForKey:@"Id"] isKindOfClass:[NSNull class]]?@"":[dict valueForKey:@"Id"] forKey:@"id"];
        [fieldObj setValue:[[dict valueForKey:@"Value"] isKindOfClass:[NSNull class]]?@"":[dict valueForKey:@"Value"] forKey:@"text"];
        [fieldObj setValue:[[dict valueForKey:@"Name"] isKindOfClass:[NSNull class]]?@"":[dict valueForKey:@"Name"] forKey:@"name"];
        [fieldObj setValue:[[dict valueForKey:@"Confidence"] isKindOfClass:[NSNull class]]?@"":[dict valueForKey:@"Confidence"] forKey:@"confidence"];
        [fieldObj setValue:[[dict valueForKey:@"ErrorDescription"]isKindOfClass:[NSNull class]]?@"":[dict valueForKey:@"ErrorDescription"] forKey:@"errorDescription"];
        [fieldObj setValue:[[dict valueForKey:@"Valid"]isKindOfClass:[NSNull class]]?@"":[dict valueForKey:@"Valid"] forKey:@"valid"];
        
        [fieldArray addObject:fieldObj];
        fieldObj = nil;
    }
    
    [extractionOutput setValue:fieldArray forKey:@"fields"];
    
    fieldArray = nil;
    
    return extractionOutput;
}

//This method is used to make a connection to the server
-(void)makeConnection : (NSMutableURLRequest*)request
{
    
    if(request != nil){
        
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        defaultConfigObject.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        defaultConfigObject.URLCache = nil;
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *dataTask =[defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSInteger extractionResponseCode = [((NSHTTPURLResponse *)response) statusCode];
            NSString *receivedString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"output string is %@",receivedString);
            receivedString = nil;
            
            if(!error && data.length>0 && extractionResponseCode == 200)
            {
                id jsonOutput = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                NSDictionary *receivedDictionary = nil;
                
                if ([jsonOutput isKindOfClass:[NSDictionary class]]) {
                    receivedDictionary = (NSDictionary*)jsonOutput;
                }
                
                NSLog(@"receievedString = %@\n",receivedDictionary);
                
                //If session id is available
                if (self.sessionId) {
                    //If documentid is not available
                    if (!self.documentId) {
                        
                        //Get document id response
                        
                        //Save the documentid
                        self.documentId = [[jsonOutput valueForKey:@"d"]valueForKey:@"DocumentId"];
                        
                        //If document id is available then do the extraction
                        [self getConfidenceValues];
                        
                    }
                    else{
                        
                        //If response is not available
                        if (!self.responseDictionary) {
                            
                            //Extracted results response
                            
                            //Save the response
                            self.responseDictionary = (NSMutableDictionary*)receivedDictionary;
                            
                            //If extraction is succeded then delete the document from KTA server
                            [self deleteDocument];
                            
                        }
                        else{
                            
                            //Delete document response
                            
                            //Form the response same as RTTI response from responeDictionary and send the response to the appropriate class
                            NSMutableDictionary *extractionOutput = [self mergeExtractedResult];
                            
                            NSMutableArray *extractedResults = [[NSMutableArray alloc]init];
                            [extractedResults addObject:extractionOutput];
                            
                            NSData *data1 = [NSJSONSerialization dataWithJSONObject:extractedResults options:NSJSONWritingPrettyPrinted error:nil];
                            
                            if(self.delegate && [self.delegate respondsToSelector:@selector(didExtractData:withResults:)])
                                [self.delegate didExtractData:[(NSHTTPURLResponse*)response statusCode] withResults:data1];
                            
                            extractionOutput = nil;
                            extractedResults = nil;
                            data1 = nil;
                            
                        }
                    }
                    
                }
                else{
                    
                    //This is the login response
                    
                    //Set the documentid and responsedictionary to nil before doing the extraction
                    self.documentId = nil;
                    self.responseDictionary = nil;
                    
                    //Save the session id
                    self.sessionId = [[receivedDictionary valueForKey:@"d"]valueForKey:@"SessionId"];
                    
                    //Here we are calling webservce for getting the document id
                    NSMutableURLRequest *request = [self formRequestWithImages:self.processedImgs originalImages:self.originalImgs withParams:self.inputParams withMimeType:self.MIME_TYPE];
                    [self makeConnection:request];
                    
                    request = nil;
                    
                }
                
                jsonOutput = nil;
                receivedDictionary = nil;
            }
            else
            {
                //Throw an error
                if(self.delegate && [self.delegate respondsToSelector:@selector(didFailToExtractData:responseCode:)])
                    [self.delegate didFailToExtractData:error responseCode:extractionResponseCode];
            }
            
        }];
        [dataTask resume];
        
    }
    
}

@end
