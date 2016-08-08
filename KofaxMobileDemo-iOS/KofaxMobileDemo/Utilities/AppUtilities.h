//
//  AppUtilities.h
//  Kofax Mobile Demo
//
//  Created by kaushik on 22/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ProfileManager.h"
#import "Reachability_BR.h"
#import <AVFoundation/AVFoundation.h>
#import "BaseSummaryCell.h"
#import <kfxLibEngines/kfxKOEDataField.h>



@protocol BaseDataSourceProtocol <UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@required
-(id)initWithResult:(NSMutableArray *)result withComponent:(Component *)component;

@end

// Kofax Localization Macro - just used to keep things compact...
#define Klm(index) NSLocalizedString(index, nil)

//is device greater than 8
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface AppUtilities : NSObject
/*
 This method is used to get base64 string from image.
 @param: inputImage.
 */
-(NSString*)getBase64StringOfImage:(UIImage*)inputImage;
/*
 This method is used to get image object from base64 string.
 @param: inputString.
 */
-(UIImage*)getImageFromBase64String:(NSString*)inputString;
/*
 This method is used to get color object from hexadecimal string.
 @param: hexString.
 */
- (UIColor *)colorWithHexString:(NSString *)hexString;
/*
 This method is used to set Navigation bar tint color and the title color
 @param: themecolor, titlecolor and navigationbar.
 */
-(void)setThemeColor:(UIColor*)themeColor andTitleColor:(UIColor*)titleColor forNavigationBar:(UINavigationBar*)navBar;
/*
 This method is used to get image object based on the color.
 @param: color, themeObject.
 */
+(UIImage *)getcustomButtonImage:(UIColor*)color withTheme:(Theme*)themeObject;
/*
 This method is used to convert rgb to hexadecimal string.
 @param: red,green and red.
 */
- (NSString *) hexStringFromRed:(float)red green:(float)green blue:(float)blue;
/*
 This method is to check if there exists only digits in the input string.
 @param: input string.
 */
- (BOOL) isAllDigits:(NSString*)inputString;
/*
 This method is used to create the switch.
 @param: tag,value.
 */
+(UISwitch*)createSwitchWithTag:(int)tag andValue:(id)value;
/*
 This method is used to create the textfield.
 @param: tag,frame,placeholder and text.
 */
+(UITextField*)createTextFieldWithTag:(int)tag frame:(CGRect)frame placeholder:(NSString*)placeholder andText:(NSString*)text;
/*
 This method is used to create the textView.
 @param: tag,frame,placeholder and text.
 */
+(UITextView*)createTextViewWithTag:(int)tag frame:(CGRect)frame andText:(NSString*)text;
/*
 This method is used to create the label.
 @param: tag,frame and text.
 */
+(UILabel*)createLabelWithTag:(int)tag frame:(CGRect)frame andText:(NSString*)text;
/*
 This method is used to create the segmented control.
 @param: tag,items and selectedsegment.
 */
+(UISegmentedControl*)createSegmentedControlWithTag:(int)tag items:(NSArray*)items andSelectedSegment:(NSInteger)selectedSegment;
/*
 This method is used to check the input string is in correct email format.
 @param: inputString.
 */
-(BOOL) isValidEmail:(NSString *)inputString;
// This method will be called to set license using text input in license prompt screen
+(NSArray *)setLicense:(NSString *)license;
+(NSArray *) checkLicenseValidity;
+(void)addActivityIndicator;
+(void)removeActivityIndicator;

+(NSString *)getEVRSImagePerfectionStringFromSettings:(NSDictionary*)evrsSettings ofComponentType:(componentType)componentType isFront:(BOOL)isFront withScaleSize: (CGSize ) scaleSize withFrontImageWidth:(NSString *)strFrontWidth;

/*
 This method is used to reduce the size of the image.
 */
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

/*
 This method is used to rotate the image and make it landscape
 */
+(UIImage *)rotateImageLandscape:(UIImage*)image;

/*
 This method is used to get the sdk version.
 */
+ (NSString*)getSDKVersion;

/* 
 This method is use to determine if the current device is low end
 */
+(BOOL)isLowerEndDevice;

/*
 This method is used to determine if current device has the capability to have a torch
 */
+(BOOL)isFlashAvailable;

/*
 This method is used to get RAM size of the current device
 */
+(unsigned long long)getRAMSize;

/*
 This method is used to know about the connectivity status of the network
 */
+(BOOL)isConnectedToNetwork;

+(UIBarButtonItem*)getBackButtonItemWithTarget:(id)target andAction:(SEL)action;

+(UIBarButtonItem*)getInfoButtonItemWithTarget:(id)target andAction:(SEL)action;

+(UIBarButtonItem*)getSettingsButtonItemWithTarget:(id)target andAction:(SEL)action;

+(BOOL)isValidURL:(NSString*)url;

/*
 This method is used to create the text file.
 @param: inputString,fileName.
 */

+(void)writeToTextFile:(NSString *)inputString withFileName:(NSString *)fileName;

/*
 This method is used to generate the random string.
 @param: length.
 */

+ (NSString *)genRandStringLength:(int)length;

/*
 This method is used to generate the random string.
 @param: fileName.
 */

+(NSString *)retrieveTheFilePath:(NSString *)fileName;


/*
 This method is used to remove the file from documents directory.
 @param: fileName.
 */
+ (void)removeFile:(NSString *)fileName;

/*
 This method is used to get array of rectangles from the JSON results sent by  the file from documents directory.
 @param: fileName.
 */
+(NSMutableArray*)getRectDictsFromResults:(NSMutableArray*)results;

/*
 This method is used to get the device type
 
 */

+ (NSString *) platformString;

/*
 method to check phone type
 */

+ (BOOL) isiPhone4s;

/*
 Method is used for getting date formatter based on device locale.
 */

+ (NSDateFormatter*)getDateFormatterOfLocale;

// Method is used for getting number formatter based on device locale.

+ (NSNumberFormatter*)getNumberFormatterOfLocaleBasedOnCountryCode:(NSString*)countryCode;

//Method is used for adjusting font size of UILabel.

+ (void)adjustFontSizeOfLabel:(UILabel*)label;

//Method is used for adjusting font size of UITextField.

+ (void)reduceFontOfTextField:(UITextField*)inputTextField;

//Method is used for adjusting font size of UISegmentedControl.

+ (void)reduceFontSizeOfSegmentControl:(UISegmentedControl*)segmentControl;

// This method return error description based on error Code
+(NSArray *)getTheErrorMessage:(int)errorCode;

// This method returns dictionary from kfxKOEDataField
+ (NSDictionary *)getDictionary:(kfxKOEDataField *)dataField;

@end
