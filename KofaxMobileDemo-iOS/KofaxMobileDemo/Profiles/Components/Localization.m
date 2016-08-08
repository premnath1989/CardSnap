//
//  Localization.m
//  Kofax Mobile Demo
//
//  Created by Mahendra on 14/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "Localization.h"

@interface Localization()
{
    
}

@property(nonatomic)int componentType;

@end


@implementation Localization

-(id)initWithType :(componentType)type
{
    if(self =[super init])
    {
        self.componentType = type;
        [self setDefaults];
    }
    
    return self;
}

-(id)initWithParsedJSON : (NSDictionary*)parsedJSONDictionary
{
    if(self = [super init])
    {
        if(parsedJSONDictionary)
           [self setUpFromJSON:parsedJSONDictionary];
        else
            [self setDefaults];
    }
    
    return self;
}

//load the default settings of Localization

-(void)setDefaults
{
    if (self.componentType != CREDITCARD) {
        [self setDefaultPreviewText];
        
    }
    [self setDefaultCameraText];
    [self setDefaultSummaryText];
}

-(void)setUpFromJSON : (NSDictionary*)parsedJSONDictionary
{
    self.previewText = [parsedJSONDictionary valueForKey:PREVIEW];
    self.summaryText = [parsedJSONDictionary valueForKey:SUMMARY];
    self.cameraText = [parsedJSONDictionary valueForKey:CAMERA];
}


//Load default preview
-(void)setDefaultPreviewText
{
    self.previewText = [[NSMutableDictionary alloc] init];
    
    [self.previewText setValue:@"Retake" forKey:FRONTRETAKEBUTTON];
    [self.previewText setValue:@"Use" forKey:FRONTUSEBUTTON];
    [self.previewText setValue:@"Cancel" forKey:CANCELBUTTON];
    if(self.componentType == CHECKDEPOSIT)
    {
        [self.previewText setValue:@"Retake" forKey:BACKRETAKEBUTTON];
        [self.previewText setValue:@"Use" forKey:BACKUSEBUTTON];
    }

}

//Load default Summary
-(void)setDefaultSummaryText
{
    self.summaryText = [[NSMutableDictionary alloc] init];
    [self.summaryText setValue:@"Submit" forKey:SUBMITBUTTONTEXT];
    
    if(self.componentType == CHECKDEPOSIT)
    {
        [self.summaryText setValue:@"1. Select an account for the deposit\n2. Enter amount\n3. Take photos of front and back of the check" forKey:INSTRUCTIONTEXT];
        [self.summaryText setValue:@"Deposit Submitted For Processing" forKey:SUBMITALERTTEXT];
        [self.summaryText setValue:@"Do you want to cancel the Check Deposit?" forKey:SUBMITCANCELALERTTEXT];
        [self.summaryText setValue:@"Make Deposit" forKey:SUBMITBUTTONTEXT];
        [self.summaryText setValue:@"Take a photo of back of the check" forKey:INSTRUCTIONTEXTBACKCAPTURE];
        [self.summaryText setValue:@"Deposit To" forKey:DEPOSITTO];
        [self.summaryText setValue:@"MICR" forKey:MICR];
        [self.summaryText setValue:@"Check Number" forKey:CHECKNUMBER];
        [self.summaryText setValue:@"Routing Number" forKey:ROUTINGNUMBER];
        [self.summaryText setValue:@"Amount" forKey:AMOUNT];
    }
    else if(self.componentType == BILLPAY)
    {
        [self.summaryText setValue:@"Take a photo of Payment Coupon" forKey:INSTRUCTIONTEXT];
        [self.summaryText setValue:@"Coupon Submitted For Processing" forKey:SUBMITALERTTEXT];
        [self.summaryText setValue:@"Make Payment" forKey:SUBMITBUTTONTEXT];
        [self.summaryText setValue:@"Do you want to cancel the payment?" forKey:SUBMITCANCELALERTTEXT];
    }
    else if(self.componentType == IDCARD)
    {
        [self.summaryText setValue:@"Capture your information simply by taking a photo of your driver license" forKey:INSTRUCTIONTEXT];
        [self.summaryText setValue:@"ID Card Submitted For Processing" forKey:SUBMITALERTTEXT];
        [self.summaryText setValue:@"Do you want to cancel submission of the ID Card?" forKey:SUBMITCANCELALERTTEXT];
        
    }else if(self.componentType == CUSTOM)
    {
        [self.summaryText setValue:@"Capture the information page" forKey:INSTRUCTIONTEXT];
        [self.summaryText setValue:@"Document Submitted For Processing" forKey:SUBMITALERTTEXT];
        [self.summaryText setValue:@"Submit" forKey:SUBMITBUTTONTEXT];
        [self.summaryText setValue:@"Do you want to cancel submission of the document?" forKey:SUBMITCANCELALERTTEXT];
    }else if(self.componentType == CREDITCARD){
        [self.summaryText setValue:@"Take a photo of credit card and submit for payment" forKey:INSTRUCTIONTEXT];
        [self.summaryText setValue:@"Payment Submitted For Processing" forKey:SUBMITALERTTEXT];
        [self.summaryText setValue:@"Submit Payment" forKey:SUBMITBUTTONTEXT];
        [self.summaryText setValue:@"Do you want to cancel the credit card payment?" forKey:SUBMITCANCELALERTTEXT];
    }
    
}

//TO DO put all keys in a common file

-(void)setDefaultCameraText
{
    self.cameraText = [[NSMutableDictionary alloc] init];
    [self.cameraText setValue:@"Hold Steady" forKey:HOLDSTEADY];
    [self.cameraText setValue:@"Move Closer" forKey:MOVECLOSER];
    [self.cameraText setValue:@"Move Back" forKey:ZOOMOUTMESSAGE];
    [self.cameraText setValue:@"Done!" forKey:CAPTUREDMESSAGE];
    [self.cameraText setValue:@"Hold Device Level" forKey:HOLDPARALLEL];
    [self.cameraText setValue:@"Rotate Device" forKey:ORIENTATION];

    if(self.componentType == CHECKDEPOSIT)
    {
        [self.cameraText setValue:@"Center Check" forKey:CENTERMESSAGE];
        [self.cameraText setValue:@"Fill viewable area with check" forKey:USERINSTRUCTIONFRONT];
        [self.cameraText setValue:@"Fill viewable area with check" forKey:USERINSTRUCTIONBACK];
    }
    else if(self.componentType == BILLPAY)
    {
        [self.cameraText setValue:@"Center Payment coupon" forKey:CENTERMESSAGE];
        [self.cameraText setValue:@"Fill viewable area with payment coupon" forKey:USERINSTRUCTIONFRONT];
    }
    else if(self.componentType == IDCARD)
    {
        [self.cameraText setValue:@"Center ID card" forKey:CENTERMESSAGE];
        [self.cameraText setValue:@"Fill viewable area with ID card" forKey:USERINSTRUCTIONFRONT];
        [self.cameraText setValue:@"Fill viewable area with ID card" forKey:USERINSTRUCTIONBACK];
    }else if(self.componentType == CUSTOM)
    {
        [self.cameraText setValue:@"Center Document/ID" forKey:CENTERMESSAGE];
        [self.cameraText setValue:@"Fill viewable area with Document/ID" forKey:USERINSTRUCTIONFRONT];
    }else if(self.componentType == CREDITCARD){
        [self.cameraText setValue:@"Center credit card" forKey:CENTERMESSAGE];
        [self.cameraText setValue:@"Fill viewable area with credit card" forKey:USERINSTRUCTIONFRONT];
    }
    
}



@end
