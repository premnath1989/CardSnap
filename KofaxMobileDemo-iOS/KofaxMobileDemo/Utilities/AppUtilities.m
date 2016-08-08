//
//  AppUtilities.m
//  Kofax Mobile Demo
//
//  Created by kaushik on 22/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "AppUtilities.h"
#import <kfxLibEngines/kfxEngines.h>
#import <kfxLibUIControls/kfxUIControls.h>
#import <kfxLibLogistics/kfxLogistics.h>
#import <kfxLibUtilities/kfxUtilities.h>
#import <sys/sysctl.h>
#import "PersistenceManager.h"
#import "AppDelegate.h"
#import "kfxEVRS_License.h"

// For Check Deposit start
#import "AppStateMachine.h"
// For Check Deposit end
#import <sys/utsname.h>

#define minimumFontSize 8.0

UIView *indicatorView;
UIActivityIndicatorView *activityIndicator;
@implementation AppUtilities

/*
 This method is used to get base64 string from image.
 @param: inputImage.
 */
-(NSString*)getBase64StringOfImage:(UIImage*)inputImage{
 
    if (!inputImage) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(inputImage);
    
   return [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

/*
 This method is used to get image object from base64 string.
 @param: inputString.
 */
-(UIImage*)getImageFromBase64String:(NSString*)inputString{
    if(!inputString){
        
        return nil;
    }
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:inputString options:NSDataBase64DecodingIgnoreUnknownCharacters];

    UIImage *outputImage = nil;
    outputImage = [UIImage imageWithData:imageData];
    
    return outputImage;
}

/*
 This method is used to get color object from hexadecimal string.
 @param: hexString.
 */
- (UIColor *)colorWithHexString:(NSString *)hexString
{
    if(hexString != nil)
    {
        unsigned rgbValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:hexString];
        [scanner setScanLocation:1]; // bypass '#' character
        [scanner scanHexInt:&rgbValue];
        return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
    }
    
    return [UIColor blueColor];
    
}
/*
 This method is used to set Navigation bar tint color and the title color
 @param: themecolor, titleColor and navigationbar.
 */
-(void)setThemeColor:(UIColor*)themeColor andTitleColor:(UIColor*)titleColor forNavigationBar:(UINavigationBar*)navBar{
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0) {
        [navBar setBarTintColor:themeColor];
    }else{
        [navBar setTintColor:themeColor];
    }
    [navBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:titleColor, NSForegroundColorAttributeName, nil]];
}

/*
 This method is used to get image object based on the color.
 @param: color, themeObject.
 */
+(UIImage *)getcustomButtonImage:(UIColor*)color withTheme:(Theme *)themeObject
{
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 280.0f, 48.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    // CGContextSetRGBFillColor(context, redColor/255.0, greenColor/255.0, blueColor/255.0, 1.0);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *buttonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    if ([themeObject.buttonStyle intValue]== 1) // Gradient
    {
        buttonImage = [self getGradientButtonImage:buttonImage];
    }
    
    
    if ([themeObject.buttonBorder intValue]==0)
    {
        return buttonImage;
    } else {
        return [self getRoundedButtonImage:buttonImage];
    }
}


+(UIImage *)getRoundedButtonImage:(UIImage *)img
{
    
    UIGraphicsBeginImageContextWithOptions(img.size, NO, [UIScreen mainScreen].scale);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    CGRect imgRect = CGRectMake(0.0, 0.0, img.size.width, img.size.height);
    
    [[UIBezierPath bezierPathWithRoundedRect:imgRect cornerRadius:5.0] addClip];
    
    // Draw your image
    [img drawInRect:imgRect];
    
    // Get the image
    UIImage *imgWithRoundedCorners = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return imgWithRoundedCorners;
}

+(UIImage *)getGradientButtonImage:(UIImage *)image
{
    
    CGFloat scale = image.scale;
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scale, image.size.height * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeLuminosity);
    CGRect rect = CGRectMake(0, 0, image.size.width * scale, image.size.height * scale);
    CGContextDrawImage(context, rect, image.CGImage);
    
    // Create gradient
    // Use Gray Shades for Gradient Blend Mode Luminosity
    
    UIColor *colorTwo = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    UIColor *colorOne = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, (id)colorTwo.CGColor, nil];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, NULL);
    
    // Apply gradient
    
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0,image.size.height * scale), 0);
    
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    
    CGColorSpaceRelease(space);
    CGGradientRelease(gradient);
    
    UIGraphicsEndImageContext();
    
    
    
    return gradientImage;
}

/*
 This method is used to convert rgb to hexadecimal string.
 @param: red,green and red.
 */
- (NSString *) hexStringFromRed:(float)red green:(float)green blue:(float)blue
{
    CGFloat r, g, b;
    r = red/255.0f;
    g = green/255.0f;
    b = blue/255.0f;
    
    // Fix range if needed
    if (r < 0.0f) r = 0.0f;
    if (g < 0.0f) g = 0.0f;
    if (b < 0.0f) b = 0.0f;
    
    if (r > 1.0f) r = 1.0f;
    if (g > 1.0f) g = 1.0f;
    if (b > 1.0f) b = 1.0f;
    
    // Convert to hex string between 0x00 and 0xFF
    return [NSString stringWithFormat:@"%02X%02X%02X",
            (int)(r * 255), (int)(g * 255), (int)(b * 255)];
}

/*
 This method is to check if there exists only digits in the input string.
 @param: input string.
 */
- (BOOL) isAllDigits:(NSString*)inputString
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [inputString rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound;
}

/*
 This method is used to create the switch.
 @param: tag,value.
 */
+(UISwitch*)createSwitchWithTag:(int)tag andValue:(id)value{
    UISwitch *newSwitch = [[UISwitch alloc]init];
    newSwitch.on = [value boolValue];
    newSwitch.tag = tag;
    return newSwitch;
}

/*
 This method is used to create the textfield.
 @param: tag,frame,placeholder and text.
 */
+(UITextField*)createTextFieldWithTag:(int)tag frame:(CGRect)frame placeholder:(NSString*)placeholder andText:(NSString*)text{
    UITextField *textField = [[UITextField alloc]init];
    textField.tag = tag;
    textField.font = [UIFont fontWithName:FONTNAME size:13];
    textField.borderStyle = UITextBorderStyleNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.returnKeyType = UIReturnKeyDone;
    textField.placeholder = placeholder;
    textField.textAlignment = NSTextAlignmentRight;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.text = text;
    textField.frame = frame;
    [self reduceFontOfTextField:textField];
    return textField;
}


/*
 This method is used to create the textView.
 @param: tag,frame,placeholder and text.
 */
+(UITextView*)createTextViewWithTag:(int)tag frame:(CGRect)frame andText:(NSString*)text{
    UITextView *textView = [[UITextView alloc]init];
    textView.tag = tag;
    textView.font = [UIFont fontWithName:FONTNAME size:13];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.returnKeyType = UIReturnKeyDone;
    textView.textAlignment = NSTextAlignmentRight;
    textView.text = text;
    textView.frame = frame;
    return textView;
}

/*
 This method is used to create the label.
 @param: tag,frame and text.
 */
+(UILabel*)createLabelWithTag:(int)tag frame:(CGRect)frame andText:(NSString*)text{
    UILabel *label = [[UILabel alloc]init];
    label.text = text;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:FONTNAME size:15];
    [self adjustFontSizeOfLabel:label];
    label.tag = tag;
    label.frame = frame;
    return label;
}

/*
 This method is used to create the segmented control.
 @param: tag,items and selectedsegment.
 */
+(UISegmentedControl*)createSegmentedControlWithTag:(int)tag items:(NSArray*)items andSelectedSegment:(NSInteger)selectedSegment{
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc]initWithItems:items];
    [segmentControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIFont fontWithName:FONTNAME size:15.0], NSFontAttributeName,
                                           nil]  forState:UIControlStateNormal];
    segmentControl.selectedSegmentIndex = selectedSegment;
    segmentControl.tag = tag;
    return segmentControl;
}
/*
 This method is used to check the input string is in correct email format.
 @param: inputString.
 */
-(BOOL) isValidEmail:(NSString *)inputString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:inputString];
}


// This method will be called to set license using text input in license prompt screen
+(NSArray *)setLicense:(NSString *)license
{
    NSArray *licenseError ;
    int lic = KMC_IP_LICENSE_INVALID;
    
    if ([license length]) {
        lic = [self isLicenseValid:license];
    }
    
    switch (lic) {
        case KMC_SUCCESS:
            [PersistenceManager setLicenseString:license];
            break;
        case KMC_IP_LICENSE_ALREADY_SET:
            NSLog(@"[+] License already set.");
            break;
        case KMC_IP_LICENSE_EXPIRED:
            NSLog(@"[+] License expired.");
            licenseError = [self getTheErrorMessage:KMC_IP_LICENSE_EXPIRED];
            break;
        case KMC_IP_LICENSE_INVALID:
            NSLog(@"[+] License invalid.");
            licenseError = [self getTheErrorMessage:KMC_IP_LICENSE_INVALID];
            break;
        default:
            NSLog(@"[+] License unknown.");
            licenseError = [NSArray arrayWithObjects:Klm(@"License Error!!!"),Klm(@"Unknown KMC License error!"), nil];
            break;
    }
    return licenseError;
}

// licenseString is blank we are
+(NSArray *) checkLicenseValidity
{
    
#define EVRS_IP_LICENSING_FAILURE              -1000
#define EVRS_IP_LICENSE_EXPIRATION_ERROR       -1001
    
    NSArray *licenseError ;
    NSString *license = @"";
    int lic = KMC_IP_LICENSE_INVALID;
    
        // license from persistance storage
        license = [PersistenceManager getLicenseString];
        if ([license length]) {
            lic = [self isLicenseValid:license];
        }
        
        // license from hardcode string
        if (lic != KMC_SUCCESS) {
            const char *cLicense = PROCESS_PAGE_SDK_LICENSE;
            license = [NSString stringWithFormat:@"%s",cLicense];
            lic = [self isLicenseValid:license];
        }
    
    switch (lic) {
        case KMC_SUCCESS:
            [PersistenceManager setLicenseString:license];
            break;
        case KMC_IP_LICENSE_ALREADY_SET:
            NSLog(@"[+] License already set.");
            break;
        case KMC_IP_LICENSE_EXPIRED:
            NSLog(@"[+] License expired.");
            licenseError = [self getTheErrorMessage:KMC_IP_LICENSE_EXPIRED];
            break;
        case KMC_IP_LICENSE_INVALID:
            NSLog(@"[+] License invalid.");
            licenseError = [self getTheErrorMessage:KMC_IP_LICENSE_INVALID];
            break;
        default:
            NSLog(@"[+] License unknown.");
            licenseError = [NSArray arrayWithObjects:Klm(@"License Error!!!"),Klm(@"Unknown KMC License error!"), nil];
            break;
    }
    return licenseError;
}

+(int)isLicenseValid:(NSString *)license
{
    kfxKUTLicensing *licenseConfig = [[kfxKUTLicensing alloc] init];
    int lic = [licenseConfig setMobileSDKLicense:license];
    return lic;
}


// This method return error description based on error Code
+(NSArray *)getTheErrorMessage:(int)errorCode {
    
    NSString * message = [kfxError findErrMsg:errorCode];
    
    NSString * description = [kfxError findErrDesc:errorCode];
    
    NSString *alertTitle;
    NSString *alertDescription;
    
    NSArray * split = [message componentsSeparatedByString:@":"];
    
    if (split.count == 2)
        
    {
        alertTitle = [split objectAtIndex:0];
        alertDescription = [NSString stringWithFormat:@"%@\n\n%@", [split objectAtIndex:1], description];
        
    }
    else if(split.count > 2)
        
    {
        
        NSString * info = @"";
        
        for (int i = 1; i < split.count ; i++)
            
        {
            
            info = [NSString stringWithFormat:@"%@ %@", info, [split objectAtIndex:i]];
            
        }
        
        alertTitle = [split objectAtIndex:0];
        alertDescription = [NSString stringWithFormat:@"%@\n\n%@", info, description];
        
    }
    else
    {
        alertTitle = Klm(@"License Error!!!");
        alertDescription = [NSString stringWithFormat:@"%@\n\n%@", message, description];
        
    }
   
    return [[NSArray alloc]initWithObjects:alertTitle,alertDescription, nil];
    
}

+(void)addActivityIndicator{
   /* dispatch_queue_t lowQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(lowQueue, ^{
        dispatch_async(mainQueue, ^{
            UIWindow *currAppWindow = [[[UIApplication sharedApplication] delegate] window];
            
            activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            activityIndicator.frame = CGRectMake(currAppWindow.frame.size.width/2 -10, currAppWindow.frame.size.height/2 -10, 20, 20);
            [activityIndicator startAnimating];
            indicatorView = [[UIView alloc] initWithFrame:currAppWindow.frame];
            indicatorView.alpha = 0.81;
            indicatorView.backgroundColor = [UIColor blackColor];
            [indicatorView addSubview:activityIndicator];
            [currAppWindow addSubview:indicatorView];
        });
    });*/
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *currAppWindow = [[[UIApplication sharedApplication] delegate] window];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.frame = CGRectMake(currAppWindow.frame.size.width/2 -10, currAppWindow.frame.size.height/2 -10, 20, 20);
        [activityIndicator startAnimating];
        indicatorView = [[UIView alloc] initWithFrame:currAppWindow.frame];
        indicatorView.alpha = 0.81;
        indicatorView.backgroundColor = [UIColor blackColor];
        [indicatorView addSubview:activityIndicator];
        [currAppWindow addSubview:indicatorView];
    });
}

+(void)removeActivityIndicator{
   /* dispatch_queue_t lowQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(lowQueue, ^{
        dispatch_async(mainQueue, ^{
            [activityIndicator stopAnimating];
            [indicatorView removeFromSuperview];
            
            activityIndicator = nil;
            indicatorView = nil;
        });
    });*/
    dispatch_async(dispatch_get_main_queue(), ^{
        [activityIndicator stopAnimating];
        [indicatorView removeFromSuperview];
        
        activityIndicator = nil;
        indicatorView = nil;
    });
}

//Build EVRS Image Perfection String from Settings based on component and side of capture
+(NSString *)getEVRSImagePerfectionStringFromSettings:(NSDictionary*)evrsSettings ofComponentType:(componentType)componentType isFront:(BOOL)isFront withScaleSize: (CGSize ) scaleSize withFrontImageWidth:(NSString *)strFrontWidth
{
    // The EVRS Operation String
    NSString *perfectionProfileString = @"";
    
    int bpcolorMode = [[evrsSettings valueForKey:MODE]intValue];
    switch (bpcolorMode) {
        case 0:
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DoBinarization_"];
            break;
        case 1:
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DoGrayOutput_"];
            break;
        case 2:
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DoColor_"];
            break;
        case 3:
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DoColorDetection_"];
            break;
        default:
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DoBinarization_"];
            break;
    }
    //Auto Crop - Default TRUE
    BOOL bpAutoCropValue = [[evrsSettings valueForKey:AUTOCROP]boolValue];
    if (bpAutoCropValue)
    {
        perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DoCropCorrection_"];
    }
    
    // Deskew - Default = TRUE
    if ([[evrsSettings valueForKey:DESKEW] boolValue])
    {
        int bpdeskewMethod = [[evrsSettings valueForKey:DESKEWBY] intValue];
        if (bpdeskewMethod == 0)
        {
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DoSkewCorrectionAlt_"]; // Content based Deskew
            
        } else
        {
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DoSkewCorrectionPage_"]; // Layout based Deskew
        }
    }
    
    // Auto Rotate Image - Default TRUE
    BOOL bpautoRotateValue = [[evrsSettings valueForKey:AUTOROTATE] boolValue];
    if (bpautoRotateValue)
    {
        perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_Do90DegreeRotation_4"];
    }
    // Background Smoothing
    BOOL bpbgSmoothing = [[evrsSettings valueForKey:BACKGROUNDSMOOTHING] boolValue];
    if (bpbgSmoothing)
    {
        perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DoBackgroundSmoothing_"];
    }
    
    
    
    // Sharpen Image
    int bpsharpenImage = [[evrsSettings valueForKey:SHARPEN] intValue];
    NSLog(@"KPR: Bill pay sharpen image value is %d", bpsharpenImage);
    if (bpsharpenImage > 0 ){
        perfectionProfileString =[perfectionProfileString stringByAppendingString:[NSString stringWithFormat:@"_DoSharpen_%d",bpsharpenImage]];
    }
    
    // Despeckle Image
    int bpdespeckleValue = [[evrsSettings valueForKey:DESPECKLE] intValue];
    if (bpdespeckleValue > 0) {
        perfectionProfileString =[perfectionProfileString stringByAppendingString:[NSString stringWithFormat:@"_DoDespeck_%d",bpdespeckleValue]];
    }
    
    
    
    // Scale to DPI
    int bpscaleImage = [[evrsSettings valueForKey:SCALE] intValue];
    NSLog(@"KPR: Bill pay scale image value is %d", bpscaleImage);
    int bpscaleDPI;
    switch (bpscaleImage) {
        case 0:
            bpscaleDPI = 0;
            break;
        case 1:
            bpscaleDPI = 200;
            break;
        case 2:
            bpscaleDPI = 300;
            break;
        case 3:
            bpscaleDPI = 400;
            break;
        default:
            bpscaleDPI = 0;
            break;
    }
    
    if (bpscaleDPI > 0) {
        perfectionProfileString =[perfectionProfileString stringByAppendingString:[NSString stringWithFormat:@"_DoScaleImageToDPI_%d",bpscaleDPI]];
    }
    
    // Search MICR and HandPrint
    if(componentType == CHECKDEPOSIT) {
        NSLog(@"EVRS settings %@", evrsSettings);
        BOOL bpDetectHandPrint = [[evrsSettings valueForKey:USEHANDPRINT] boolValue];
        if (bpDetectHandPrint) {
            perfectionProfileString =[perfectionProfileString stringByAppendingString:[NSString stringWithFormat:@"_DoFindTextHP_"]];
        }
        BOOL bpSerachMICR = [[evrsSettings valueForKey:SEARCHMICR] boolValue];
        if (bpSerachMICR) {
            if(isFront)
                perfectionProfileString =[perfectionProfileString stringByAppendingString:[NSString stringWithFormat:@"_ProcessCheckFront_"]];
            else
                perfectionProfileString =[perfectionProfileString stringByAppendingString:[NSString stringWithFormat:@"_ProcessCheckBack_"]];
        }
    }
    
    if([[evrsSettings valueForKey:USEBANKRIGHTSETTINGS] boolValue])
    {
        perfectionProfileString = @"";
        if (componentType == BILLPAY) {
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DoBinarization__DoCropCorrection__DoSkewCorrectionAlt__Do90DegreeRotation_4"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkewDetect.convert_to_gray.Bool\" Value=\"1\" Comment=\"DEFAULT 0 \" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkewDetect.scale_image_down.Bool\" Value=\"1\" Comment=\"DEFAULT 0 \" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkewDetect.scale_down_factor.Int\" Value=\"80\"  Comment=\"DEFAULT  80:60 or  4:3 \" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkewDetect.document_size.Int\" Value=\"2\" Comment=\"MEDIUM, DEFAULT  0\" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkewDetect.correct_illumination.Bool\" Value = \"0\"/>"];
        }else if(componentType == CHECKDEPOSIT){
            
            NSString *commonString = @"_DeviceType_2_";
            
            
            perfectionProfileString = [perfectionProfileString stringByAppendingString:commonString];
            
            
            if(isFront){
                
                perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DoSkewCorrectionPage__DoCropCorrection__Do90DegreeRotation_9_DoScaleImageToDPI_200_DoFindTextHP__ProcessCheckFront__DoBinarization__LoadInlineSetting_[CSkewDetect.convert_to_gray.Bool=1]__LoadInlineSetting_[CSkewDetect.scale_image_down.Bool=1]_LoadInlineSetting_[CSkewDetect.scale_down_factor.Int=80]_LoadInlineSetting_[CSkewDetect.correct_illumination.Bool=0]" ];
            }
            else{
                
                if(strFrontWidth.length > 0){
                    
                    
                    perfectionProfileString = [perfectionProfileString stringByAppendingString:[NSString stringWithFormat:@"_DoSkewCorrectionPage__DoCropCorrection__Do90DegreeRotation_4__DoFindTextHP__ProcessCheckBack__DocDimLarge_%@_DoBinarization__LoadSetting_<Property Name=\"CSkewDetect.convert_to_gray.Bool\" Value=\"1\" Comment=\"DEFAULT 0 \" />_LoadSetting_<Property Name=\"CSkewDetect.scale_image_down.Bool\" Value=\"1\" Comment=\"DEFAULT 0 \" />_LoadSetting_<Property Name=\"CSkewDetect.scale_down_factor.Int\" Value=\"80\"  Comment=\"DEFAULT  80:60 or  4:3 \" />_LoadSetting_<Property Name=\"CSkewDetect.correct_illumination.Bool\" Value = \"0\"/>_LoadInlineSetting_[CDetectMpHp.RegionOfInterestPercX2.Int=96]_LoadInlineSetting_[CDetectMpHp.RegionOfInterestPercY1.Int=4]_LoadInlineSetting_[CDetectMpHp.RegionOfInterestPercY2.Int=96]_LoadInlineSetting_[CBinarize.Contrast_Slider_Pos.Int=4]_LoadInlineSetting_[CBinarize.Cleanup_Slider_Pos.Int=4]_LoadInlineSetting_[CDetectMpHp.RegionOfInterestPercX1.Int=4]",strFrontWidth]];
                    
                    
                }
                else {
                    
                    
                     perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DoSkewCorrectionPage__DoCropCorrection__Do90DegreeRotation_4__DoScaleImageToDPI_200__DoFindTextHP__ProcessCheckBack__DoBinarization__LoadSetting_<Property Name=\"CSkewDetect.convert_to_gray.Bool\" Value=\"1\" Comment=\"DEFAULT 0 \" />_LoadSetting_<Property Name=\"CSkewDetect.scale_image_down.Bool\" Value=\"1\" Comment=\"DEFAULT 0 \" />_LoadSetting_<Property Name=\"CSkewDetect.scale_down_factor.Int\" Value=\"80\"  Comment=\"DEFAULT  80:60 or  4:3 \" />_LoadSetting_<Property Name=\"CSkewDetect.document_size.Int\" Value=\"2\" Comment=\"MEDIUM, DEFAULT  0\" />_LoadSetting_<Property Name=\"CSkewDetect.correct_illumination.Bool\" Value = \"0\"/>_LoadInlineSetting_[CDetectMpHp.RegionOfInterestPercX2.Int=96]_LoadInlineSetting_[CDetectMpHp.RegionOfInterestPercY1.Int=4]_LoadInlineSetting_[CDetectMpHp.RegionOfInterestPercY2.Int=96]_LoadInlineSetting_[CBinarize.Contrast_Slider_Pos.Int=4]_LoadInlineSetting_[CBinarize.Cleanup_Slider_Pos.Int=4]_LoadInlineSetting_[CDetectMpHp.RegionOfInterestPercX1.Int=4]"];
                }
                
                
            }
            

            
        }else if(componentType == IDCARD){
            
            if(CGSizeEqualToSize(CGSizeZero, scaleSize)){
                
                  perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DoSkewCorrectionPage__DoCropCorrection__Do90DegreeRotation_4__DoScaleImageToDPI_300_DocDimSmall_2.123_DocDimLarge_3.363"];
            }
            else {
                
                 perfectionProfileString = [perfectionProfileString stringByAppendingString:[NSString stringWithFormat:@"_DoSkewCorrectionPage__DoCropCorrection__Do90DegreeRotation_4__DoScaleImageToDPI_300_DocDimSmall_%f_DocDimLarge_%f",scaleSize.height, scaleSize.width ]];
            }
            
          
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkewDetect.prorate_error_sum_thr_bkg_brightness.Bool\" Value=\"1\" Comment=\"DEFAULT 0\" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkwCor.Do_Fast_Rotation.Bool\" Value=\"0\" Comment=\"DEFAULT 1\" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkewDetect.correct_illumination.Bool\" Value=\"0\" Comment=\"DEFAULT 1\" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkwCor.Fill_Color_Scanner_Bkg.Bool\" Value=\"0\" Comment=\"DEFAULT 1 \" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkwCor.Fill_Color_Red.Byte\" Value=\"255\" Comment=\"DEFAULT 0 \" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkwCor.Fill_Color_Green.Byte\" Value=\"255\" Comment=\"DEFAULT 0 \" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkwCor.Fill_Color_Blue.Byte\" Value=\"255\" Comment=\"DEFAULT 0 \" />"];

            
        }else if(componentType == CREDITCARD){
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DoColorDetection__DeviceType_2_Do90DegreeRotation_4_DoCropCorrection__DoScaleImageToDPI_200_DoSkewCorrectionPage__DocDimLarge_3.375_DocDimSmall_2.125_"];
        }
        else if(componentType==CUSTOM){
             perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DeviceType_2__DoCropCorrection__DoSkewCorrectionAlt__Do90DegreeRotation_4_DoScaleImageToDPI_300_DocDimSmall_3.465_DocDimLarge_4.921_"];
        }
        
    }
    else if([[evrsSettings valueForKey:CSKEWSETTINGS] boolValue])
    {
        if (componentType == BILLPAY) {
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkewDetect.convert_to_gray.Bool\" Value=\"1\" Comment=\"DEFAULT 0 \" />_LoadSetting_<Property Name=\"CSkewDetect.scale_image_down.Bool\" Value=\"1\" Comment=\"DEFAULT 0 \" />_LoadSetting_<Property Name=\"CSkewDetect.scale_down_factor.Int\" Value=\"80\"  Comment=\"DEFAULT  80:60 or  4:3 \" />_LoadSetting_<Property Name=\"CSkewDetect.document_size.Int\" Value=\"2\" Comment=\"MEDIUM, DEFAULT  0\" />_LoadSetting_<Property Name=\"CSkewDetect.correct_illumination.Bool\" Value = \"0\"/>"];
        }else if(componentType == CHECKDEPOSIT){
            
            
            NSString *commonString = @"_DeviceType_2__LoadSetting_<Property Name=\"CSkewDetect.convert_to_gray.Bool\" Value=\"1\" Comment=\"DEFAULT 0 \" />_LoadSetting_<Property Name=\"CSkewDetect.scale_image_down.Bool\" Value=\"1\" Comment=\"DEFAULT 0 \" />_LoadSetting_<Property Name=\"CSkewDetect.scale_down_factor.Int\" Value=\"80\"  Comment=\"DEFAULT  80:60 or  4:3 \" />_LoadSetting_<Property Name=\"CSkewDetect.document_size.Int\" Value=\"2\" Comment=\"MEDIUM, DEFAULT  0\" />_LoadSetting_<Property Name=\"CSkewDetect.correct_illumination.Bool\" Value = \"0\"/>";
            
            perfectionProfileString = [perfectionProfileString stringByAppendingString:commonString];
            
            if(isFront){
                
                perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadInlineSetting_<Property Name=\"CDetectMpHp.RegionOfInterestPercX1.Int\" Value=\"50\" Comment=\"DEFAULT 10 \" />_LoadInlineSetting_<Property Name=\"CDetectMpHp.RegionOfInterestPercX2.Int\" Value=\"95\" Comment=\"DEFAULT 90 \" />_LoadInlineSetting_<Property Name=\"CDetectMpHp.RegionOfInterestPercY1.Int\" Value=\"60\" Comment=\"DEFAULT 50 \" />_LoadInlineSetting_<Property Name=\"CDetectMpHp.RegionOfInterestPercY2.Int\" Value=\"90\" Comment=\"DEFAULT 80 \" />_LoadInlineSetting_<Property Name=\"CBinarize.Contrast_Slider_Pos.Int\" Value=\"4\" Comment=\"DEFAULT 10 \" />_LoadInlineSetting_<Property Name=\"CBinarize.Cleanup_Slider_Pos.Int\" Value=\"4\" Comment=\"DEFAULT 10 \" />" ];
            }
            else
            {
                
                perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadInlineSetting_[CDetectMpHp.RegionOfInterestPercX2.Int=96]_LoadInlineSetting_[CDetectMpHp.RegionOfInterestPercY1.Int=4]_LoadInlineSetting_[CDetectMpHp.RegionOfInterestPercY2.Int=96]_LoadInlineSetting_[CBinarize.Contrast_Slider_Pos.Int=4]_LoadInlineSetting_[CBinarize.Cleanup_Slider_Pos.Int=4]_LoadInlineSetting_[CDetectMpHp.RegionOfInterestPercX1.Int=4]"];
                
            }
            
        }else if(componentType == IDCARD){
            
            if(CGSizeEqualToSize(CGSizeZero, scaleSize)){
                
               perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DocDimSmall_2.125_DocDimLarge_3.375"];
            }
            else {
                
                perfectionProfileString = [perfectionProfileString stringByAppendingString:[NSString stringWithFormat:@"_DocDimSmall_%f_DocDimLarge_%f",scaleSize.height, scaleSize.width ]];
            }
            
           
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkewDetect.prorate_error_sum_thr_bkg_brightness.Bool\" Value=\"1\" Comment=\"DEFAULT 0\" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkwCor.Do_Fast_Rotation.Bool\" Value=\"0\" Comment=\"DEFAULT 1\" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkewDetect.correct_illumination.Bool\" Value=\"0\" Comment=\"DEFAULT 1\" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkwCor.Fill_Color_Scanner_Bkg.Bool\" Value=\"0\" Comment=\"DEFAULT 1 \" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkwCor.Fill_Color_Red.Byte\" Value=\"255\" Comment=\"DEFAULT 0 \" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkwCor.Fill_Color_Green.Byte\" Value=\"255\" Comment=\"DEFAULT 0 \" />"];
            perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_LoadSetting_<Property Name=\"CSkwCor.Fill_Color_Blue.Byte\" Value=\"255\" Comment=\"DEFAULT 0 \" />"];
            
        }
        else if(componentType == CUSTOM){
            perfectionProfileString = [perfectionProfileString stringByAppendingString:[evrsSettings valueForKey:CSKEWSTRING]];
        }
        else if(componentType==CREDITCARD){
            perfectionProfileString=[perfectionProfileString stringByAppendingString:@"LoadSetting_<Property Name=\"CSkewDetect.correct_illumination.Bool\" Value=\"0\" />_LoadSetting_<Property Name=\"CSkewDetect.Remove_Shadows\" Value=\"0\" />_LoadSetting_<Property Name=\"CSkewDetect.color_stats_error_sum_thr_white_bkg\" Value=\"36\" />_LoadSetting_<Property Name=\"CSkewDetect.step_white_bkg\" Value=\"16\" />_LoadSetting_<Property Name=\"CSkewDetect.bright_window\" Value=\"255\" />_LoadSetting_<Property Name=\"EdgeCleanup.enable\" Value=\"0\" />_LoadSetting_<Property Name=\"CZoneExtract.PerformRecognition\" Value=\"1\" />_LoadSetting_<Property Name=\"CZoneExtract.Enable\" Value=\"1\" />_LoadSetting_<Property Name=\"CZoneExtract.UseFieldType\" Value=\"2\" />_LoadSetting_<Property Name=\"CZoneExtract.NumZones\" Value=\"1\" />_LoadSetting_<Property Name=\"CZoneExtract.AspectRatio.Double\" Value=\"1.584112\" />_LoadSetting_<Property Name=\"CZoneExtract.LineLabels.00.00.String\" Value=\"DLNumber\" />_LoadSetting_<Property Name=\"CZoneExtract.LineLabelsTemplate.00.00.String\" Value=\"1:9999[0-9 ]\" />_LoadSetting_<Property Name=\"CZoneExtract.Max_bbX1.00.Int\" Value=\"843\" />_LoadSetting_<Property Name=\"CZoneExtract.Max_bbY1.00.Int\" Value=\"5000\" />_LoadSetting_<Property Name=\"CZoneExtract.Max_bbX2.00.Int\" Value=\"9500\" />_LoadSetting_<Property Name=\"CZoneExtract.Max_bbY2.00.Int\" Value=\"6954\" />_LoadSetting_<Property Name=\"CZoneExtract.Median_bbX1.00.Int\" Value=\"931\" />_LoadSetting_<Property Name=\"CZoneExtract.Median_bbY1.00.Int\" Value=\"5503\" />_LoadSetting_<Property Name=\"CZoneExtract.Median_bbX2.00.Int\" Value=\"9068\" />_LoadSetting_<Property Name=\"CZoneExtract.Median_bbY2.00.Int\" Value=\"6463\" />_LoadSetting_<Property Name=\"CZoneExtract.Intermittent.00.Int\" Value=\"0\" />_LoadSetting_<Property Name=\"CZoneExtract.Invert.00.Int\" Value=\"0\" />_LoadSetting_<Property Name=\"CZoneExtract.LineHeight.00.00.Int\" Value=\"961\" />_LoadSetting_<Property Name=\"CZoneExtract.LineWidth.00.00.Int\" Value=\"8396\" />_LoadSetting_<Property Name=\"CZoneExtract.LineMedianX1.00.00.Int\" Value=\"1058\" />_LoadSetting_<Property Name=\"CZoneExtract.LineMedianX2.00.00.Int\" Value=\"9010\" />_LoadSetting_<Property Name=\"CZoneExtract.LineMedianY1.00.00.Int\" Value=\"5504\" />_LoadSetting_<Property Name=\"CZoneExtract.LineMedianY2.00.00.Int\" Value=\"6478\" />_LoadSetting_<Property Name=\"CZoneExtract.Penalty_Coe.00.Int\" Value=\"0\" />_LoadSetting_<Property Name=\"CZoneExtract.Median_Delta_RG.00.Int\" Value=\"0\" />_LoadSetting_<Property Name=\"CZoneExtract.Median_Delta_RB.00.Int\" Value=\"0\" />_LoadSetting_<Property Name=\"CZoneExtract.Median_Delta_GB.00.Int\" Value=\"0\" />_LoadSetting_<Property Name=\"CZoneExtract.Binarization_Method.00.Int\" Value=\"3\" />"];
        }
    }
    else
    {
        if(componentType == IDCARD){
            
            if(CGSizeEqualToSize(CGSizeZero, scaleSize)){
                
                perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DocDimSmall_2.125_DocDimLarge_3.375"];
            }
            else {
                
                perfectionProfileString = [perfectionProfileString stringByAppendingString:[NSString stringWithFormat:@"_DocDimSmall_%f_DocDimLarge_%f",scaleSize.height, scaleSize.width]];
            }
        }
        else if(componentType==CREDITCARD){
            
            if(CGSizeEqualToSize(CGSizeZero, scaleSize)){
                
                perfectionProfileString = [perfectionProfileString stringByAppendingString:@"_DocDimSmall_2.125_DocDimLarge_3.375"];
            }
            else {
                
                perfectionProfileString = [perfectionProfileString stringByAppendingString:[NSString stringWithFormat:@"_DocDimSmall_%f_DocDimLarge_%f",scaleSize.height, scaleSize.width]];
            }
        }
    }
    //NSLog(@"The operation string is %@", perfectionProfileString);
    
    if (componentType == BILLPAY || componentType == IDCARD)
    {
        // Use document detector based crop for bill and id
        NSRange range = [perfectionProfileString rangeOfString:@"DoCropCorrection" options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound)
        {
            perfectionProfileString = [NSString stringWithFormat:@"%@_DoDocumentDetectorBasedCrop_", perfectionProfileString];
        }
    }
    
    return perfectionProfileString;
}

/*
 This method is used to reduce the size of the image.
 */
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    float width = newSize.width;
    float fact = newSize.height / newSize.width;
    float height = width * fact;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] >= 2.0) {   //scale value should be greater than 2 and fetchin image based on device scale value.
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), YES, [[UIScreen mainScreen] scale]);
        } else {
            UIGraphicsBeginImageContext(CGSizeMake(width, height));
        }
    } else {
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
    }
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/*
 This method is used to rotate the image and make it landscape
 */
+(UIImage *)rotateImageLandscape:(UIImage*)image
{
    UIImage * landscapeImage = [[UIImage alloc] initWithCGImage: image.CGImage scale: 1.0
                                                   orientation: UIImageOrientationLeft];
    
    return landscapeImage;
}

/*
 This method is used to get the sdk version.
 */
+ (NSString*)getSDKVersion{
    kfxKUTSdkVersion *sdkVersin = [kfxKUTSdkVersion sdkInstance];
    return sdkVersin.sdkVersion;
}

#pragma mark
#pragma device specific methods
+(BOOL)isLowerEndDevice
{
    unsigned long long inMB = 1024*1024;
    unsigned long long  value = ([NSProcessInfo processInfo].physicalMemory)/inMB;
    NSLog(@"Ram Memory: %llu MB",value);
    if(value > 512)
        return NO;
    else
        return YES;
    
    return NO;
}

/*
 method to check phone type
 */

+ (BOOL) isiPhone4s
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *machineName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ( [machineName isEqualToString: @"iPhone4,1"])
        return true;
    else
        return false;
    
}


+(BOOL)isFlashAvailable
{
    // check if flashlight available
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (![device hasTorch] && ![device hasFlash]){
            return NO;
        }
    }
    return YES;
}

+(unsigned long long)getRAMSize{
    return (unsigned long long)[NSProcessInfo processInfo].physicalMemory;
}

#pragma mark
#pragma mark Network Checks
+(BOOL)isConnectedToNetwork
{
    Reachability_BR *reachability = [Reachability_BR reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    return !(networkStatus == NotReachable);
}

+(UIBarButtonItem*)getBackButtonItemWithTarget:(id)target andAction:(SEL)action{
    UIButton* customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton setImage:[UIImage imageNamed:BACKBUTTONIMAGE] forState:UIControlStateNormal];
    [customButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [customButton setTitle: Klm(@"Back") forState:UIControlStateNormal];
    [customButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    [customButton sizeToFit];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
//        backButton.tintColor = [utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.titleColor];
//        utilitiesObject = nil;
//    }
    return backButton;
}

+(UIBarButtonItem*)getInfoButtonItemWithTarget:(id)target andAction:(SEL)action
{
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:INFOBUTTONIMAGE] style:UIBarButtonItemStylePlain target:target action:action];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        infoButton.tintColor = [UIColor whiteColor];
    }
    return infoButton;
}


+(UIBarButtonItem*)getSettingsButtonItemWithTarget:(id)target andAction:(SEL)action{
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:SETTINGSBUTTONIMAGE] style:UIBarButtonItemStylePlain target:target action:action];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        settingsButton.tintColor = [UIColor whiteColor];
    }
    return settingsButton;
}


+(BOOL)isValidURL:(NSString*)url{
    BOOL validURL = NO;
    NSURL *candidateURL = [NSURL URLWithString:url];
    if (candidateURL && candidateURL.scheme && candidateURL.host)
        validURL = YES;
    return validURL;
    /*NSString *urlRegEx =
     @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
     NSPredicate *urlPredic = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
     BOOL isURL = [urlPredic evaluateWithObject:url];
     return isURL;*/
}

#pragma mark 
#pragma mark File Creation for Image Summary

+(void)writeToTextFile:(NSString *)inputString withFileName:(NSString *)fileName {
    
    NSError *error;
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:fileName];
    [inputString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

+ (NSString *)genRandStringLength:(int)length {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    for (int i=0; i<length; i++) {
        @autoreleasepool {
            [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
        }
    }
    return randomString;
}

+(NSString *)retrieveTheFilePath:(NSString *)fileName {
    
    return  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:fileName];
}

+ (void)removeFile:(NSString *)fileName
{
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:fileName];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    
}

+(BOOL)array:(NSMutableArray*)coloredAreas hasBoundingRectangle:(kfxKEDBoundingRectangle*)bRect{
    
    BOOL isPresent = false;
    
    for (kfxKEDBoundingRectangle *iterRect in coloredAreas) {
        
        
        CGRect boundingRect = CGRectMake(bRect.rectLeft, bRect.rectTop, bRect.rectRight - bRect.rectLeft, bRect.rectBottom - bRect.rectTop);
        CGRect iterRectboundingRect = CGRectMake(iterRect.rectLeft, iterRect.rectTop, iterRect.rectRight - iterRect.rectLeft, iterRect.rectBottom - iterRect.rectTop);

        if(iterRect.rectTop == bRect.rectTop && iterRect.rectBottom == bRect.rectBottom &&
           iterRect.rectLeft == bRect.rectLeft && iterRect.rectRight == bRect.rectRight){
            
            isPresent = true;
            break;
        }
        // checking two rects if the are overlapped . overlap tolerance is +7 to -7
        else if((iterRectboundingRect.origin.x == boundingRect.origin.x ) && (iterRectboundingRect.origin.y - boundingRect.origin.y < 7 && iterRectboundingRect.origin.y - boundingRect.origin.y > -7 ))
        {
            isPresent = true;
            break;
        }
        // checking two rects if the are overlapped . overlap tolerance is +7 to -7
        else if((iterRectboundingRect.origin.y - boundingRect.origin.y < 7 && iterRectboundingRect.origin.y - boundingRect.origin.y > -7 ) && (iterRectboundingRect.origin.x + iterRectboundingRect.size.width - boundingRect.origin.x > 0))
        {
            isPresent = true;
            break;
        }
    }
    
    return isPresent;
}
+(NSMutableArray*)getRectDictsFromResults:(NSMutableArray*)results{
    
    if(!results || [results count] == 0){
        return nil;
    }
    
    NSMutableArray *coloredAreas = [NSMutableArray array];
    
    for(NSDictionary *areaDict in results){
        
        float left = [[areaDict valueForKey:@"left"] floatValue];
        float top = [[areaDict valueForKey:@"top"] floatValue];
        float width = [[areaDict valueForKey:@"width"] floatValue];
        float height = [[areaDict valueForKey:@"height"] floatValue];
        
        kfxKEDBoundingRectangle *boundingRect = [[kfxKEDBoundingRectangle alloc] initWithLeft:left top:top width:width height:height];
        
        if(left >= 0 && top >= 0 && width > 0 && height > 0){
            
            if(![self array:coloredAreas hasBoundingRectangle:boundingRect]){
                [coloredAreas addObject:boundingRect];
                NSLog(@"BoundingRectangle %d\t%d\t%d\t%d\n",boundingRect.rectTop,boundingRect.rectBottom,boundingRect.rectLeft,boundingRect.rectRight);
            }
        }
        
    }
    return coloredAreas;
}


/*
 This method is used to get the device type
 
 */

+ (NSString *) platformString {
    // Gets a string with the device model
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    return platform;
}

// Method is used for getting date formatter based on device locale.

+ (NSDateFormatter*)getDateFormatterOfLocale
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setLocale:[NSLocale currentLocale]];
    return formatter;
}

// Method is used for getting number formatter based on device locale.

+ (NSNumberFormatter*)getNumberFormatterOfLocaleBasedOnCountryCode:(NSString*)countryCode;
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:countryCode];
    [numberFormatter setLocale:locale];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return numberFormatter;
}

//Method is used for adjusting font size of UILabel.

+ (void)adjustFontSizeOfLabel:(UILabel*)label
{
    label.adjustsFontSizeToFitWidth = YES;
    CGFloat minimumScaleFactor = 8.0/[[label font] pointSize];  //Setting minimum font size as 8.0
    label.minimumScaleFactor = minimumScaleFactor;
}

//Method is used for adjusting font size of UITextField.

+ (void)reduceFontOfTextField:(UITextField*)inputTextField
{
    UIFont *font = inputTextField.font;
    
    NSDictionary *textAttributes = @{NSFontAttributeName: font};
    
    NSString *inputString = inputTextField.text;
    
    if(([inputTextField.text isEqual:nil] || [inputTextField.text isEqualToString:@""]) &&
       (![inputTextField.placeholder isEqual:nil] && ![inputTextField.placeholder isEqualToString:@""])){
        
        inputString = inputTextField.placeholder;
    }
    
    CGSize textWidth = [inputString sizeWithAttributes:textAttributes]; // get exact width occupied by the string.
    
    const CGRect  textBounds = [inputTextField textRectForBounds:inputTextField.frame];   // get exact width available. This is width availble for
    const CGFloat maxWidth   = textBounds.size.width;
    // drawing the text and is different to width of textfield.
    
    if((font.pointSize > minimumFontSize) && (textWidth.width > maxWidth)){
        [inputTextField setFont:[font fontWithSize:font.pointSize-1]];
        [self reduceFontOfTextField:inputTextField];
    }
}


//Method is used for adjusting font size of UISegmentedControl.

+ (void)reduceFontSizeOfSegmentControl:(UISegmentedControl*)segmentControl
{
    for (id segment in [segmentControl subviews])
    {
        for (id label in [segment subviews])
        {
            if ([label isKindOfClass:[UILabel class]])
                [AppUtilities adjustFontSizeOfLabel:label];
        }
    }
}

+ (NSDictionary *)getDictionary:(kfxKOEDataField *)dataField{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    if (dataField.name) {
        [dictionary setObject:dataField.name forKey:@"name"];
    }
    if (dataField.value) {
        [dictionary setObject:dataField.value forKey:@"text"];
    }
    [dictionary setObject:[NSNumber numberWithFloat:dataField.confidence] forKey:@"confidence"];
    if (dataField.rect) {
        [dictionary setObject:[NSNumber numberWithInt:dataField.rect.rectBottom] forKey:@"rectBottom"];
        [dictionary setObject:[NSNumber numberWithInt:dataField.rect.rectTop] forKey:@"rectTop"];
        [dictionary setObject:[NSNumber numberWithInt:dataField.rect.rectLeft] forKey:@"rectLeft"];
        [dictionary setObject:[NSNumber numberWithInt:dataField.rect.rectRight] forKey:@"rectRight"];
    }
    return [dictionary copy];
}

@end
