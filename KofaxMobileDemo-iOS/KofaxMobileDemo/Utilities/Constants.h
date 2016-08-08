//
//  Constants.h
//  Kofax Mobile Demo
//
//  Created by Mahendra on 14/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KMDAlertView.h"

typedef enum moduleType{
    
    CHECK_DEPOSIT =0,
    BILL_PAY,
    ID_CARD,
    CREDIT_CARD,
    CUSTOM_COMPONENT
}moduleType;

typedef enum appStateVal{
    
    NOOP = 10,
    CAPTURING,
    CAPTURED,
    PROCESSING,
    PROCESSED,
    CANCELLING,
    CANCELLED,
    EXTRRACTING,
    EXTRACTED,
    BCSCANNING,
    BCSCANNED,
    FAILED,
    PROCESSING_USECLICKED,
    REPROCESSING
}appStateVal;

typedef enum imageType {
    FRONT_RAW,
    FRONT_PROCESSED,
    BACK_RAW,
    BACK_PROCESSED
    
}imageType;

typedef enum
{
    CHECKDEPOSIT,
    BILLPAY,
    IDCARD,
    CREDITCARD,
    CUSTOM
    
} componentType;

typedef enum
{
    HEADER_COLOR,
    BUTTON_COLOR,
    TITLE_COLOR,
    TEXT_COLOR
    
} colorType;


typedef enum PROFILE_STATE
{
    CREATE_PROFILE,//0
    CLONE_PROFILE,//1
    EDIT_PROFILE, //2
    SELECT_PROFILE//3
}profileAction;


typedef enum captureSides{
    
    NONESIDE,
    ONESIDE,
    OTHERSIDEBARCODE,
    TWOSIDECAPTURE
    
}captureSides;

typedef enum CAPATUREANIMATIONTYPE
{
    DOCUMENT=0,
    CHECK
    
}captureAnimationType;


#define DEFAULTPROFILEID 1

#define DLASPECTRATIO 2.125/3.375
#define DLASECTRATIO_GERMANY_ID2  2.913/4.134
#define DLPADDINGPERCENT 8

#define FORCECAPTURETIMER 15

// Country and Region Selection

#define OTHERCOUNTRY @"Other"

//******----------------------------JSON Key String-------------------------------****////

///Keys for the JSON
#define METADATA @"metadata"
#define NAME @"name"
#define APPTITLE @"apptitle"
#define NUMBEROFCOMPONENTS @"numberofcomponents"
#define ID @"id"
#define FOOTER @"footer"
#define LOGINREQUIRED @"loginrequired"

#define CREDENTIALS @"credentials"
#define USERNAME @"username"
#define PASSWORD @"password"
#define LOGINURL @"loginurl"

#define THEME @"theme"
#define COLOR @"color"
#define TITLECOLOR @"titlecolor"
#define BUTTONCOLOR @"buttoncolor"
#define BUTTONCORNERSTYLE @"buttoncornerstyle"
#define BUTTONCOLORSTYLE @"buttoncolorstyle"
#define BUTTONTEXTCOLOR @"buttontextcolor"

#define GRAPHICS @"graphics"
#define LOGO @"logo"
#define HOMESCREENBACKGROUND @"homescreenbackground"
#define LOGINSCREENBACKGROUND @"loginscreenbackground"

#define COMPONENTS @"components"
#define COMPONENTNAME @"name"
#define TYPE @"type"
#define SUBMITTO @"submitto"

//screen texts
#define SCREENTEXTS @"screentexts"

#define STATICDONEBUTTONTEXT @"Done"
#define STATICCANCELBUTTONTEXT @"Cancel"
#define STATICSERVERFIELDS @"fields"
#define STATICPERFECTIONPROFILE @"PerfectionProfile"

#define PREVIEW @"preview"
#define FRONTRETAKEBUTTON @"frontretakebutton"
#define FRONTUSEBUTTON @"frontusebutton"
#define BACKRETAKEBUTTON @"backretakebutton"
#define BACKUSEBUTTON @"backusebutton"

#define SUMMARY @"summary"
#define INSTRUCTIONTEXT @"instructiontext"
#define SUBMITALERTTEXT @"submitalerttext"
#define DEPOSITTO @"depositto"
#define MICR @"micr"
#define AMOUNT @"amount"
#define CHECKNUMBER @"checknumber"
#define ROUTINGNUMBER @"routingnumber"
#define SUBMITBUTTONTEXT @"submitbuttontext"
#define SUBMITALERTTEXT @"submitalerttext"
#define SUBMITCANCELALERTTEXT @"submitcancelalerttext"
#define CONTINUEBUTTONTEXT @"continuebuttontext"


#define CAMERA @"camera"
#define USERINSTRUCTIONFRONT @"ueuserinstructionfront"
#define MOVECLOSER @"uemovecloser"
//#define USERINSTRUCTIONMESSAGE @"userInstructionmessage"
#define CENTERMESSAGE @"uecenter"
#define ZOOMOUTMESSAGE @"uemoveback"
#define CAPTUREDMESSAGE @"uecaptured"


#define HOLDSTEADY @"ueholdsteady"
#define USERINSTRUCTIONBACK @"ueuserinstructionback"
#define CANCELBUTTON @"cancelbutton"
#define INSTRUCTIONTEXTBACK @"ueinstructiontextforback"
#define INSTRUCTIONTEXTBACKCAPTURE @"instructiontextforback"
#define HOLDPARALLEL @"ueholdparallel"
#define ORIENTATION @"ueorientation"

//Component Names

#define COMP_CHECKDEPOSIT   @"Check Deposit"
#define COMP_BILLPAY        @"Pay Bills"
#define COMP_IDCARD         @"ID Card"
#define COMP_CREDITCARD     @"Credit Card"
#define COMP_CUSTOM         @"Custom"


//Settings
#define SETTINGS @"settings"

#define COMPONENTGRAPHICS @"componentgraphics"


//Camera settings
#define CAMERASETTINGS @"camerasettings"
#define AUTOTORCH      @"autotorch"
#define CAMERACOMPONENT @"cameracomponent"
#define OFFSETTHRESHOLD @"offsetthreshold"
#define STABILITYDELAY @"stabilitydelay"
#define CAPTUREEXPERIENCE @"captureexperiencemode"
#define ROLLTHRESHOLD @"rollthreshold"
#define PITCHTHRESHOLD @"pitchthreshold"
#define MANUALCAPTURETIMER @"manualcapturetimer"
#define FRAMEASPECTRATIO @"frameaspectratio"
#define CAPTURETYPE @"capturetype"
#define SHOWGALLERY @"showgallery"
#define EDGEDETECTION @"edgedetection"

//evrs settings
#define EVRSSETTINGS @"evrssettings"
#define BACKGROUNDSMOOTHING @"backgroundsmoothing"
#define AUTOCROP @"autocrop"
#define SCALE @"scale"
#define DESKEW @"deskew"
#define CSKEWSETTINGS @"cskewsettings"
#define DOQUICKANALYSIS @"doquickanalysis"
#define USEBANKRIGHTSETTINGS @"usebankrightsettings"
#define AUTOROTATE @"autorotate"
#define SHARPEN @"sharpen"
#define DESKEWBY @"deskewby"
#define MODE @"mode"
#define DESPECKLE @"despeckle"
#define EVRSDEBUGGING @"sendimagesummary"

#define DOPROCESS @"imageprocessing"
#define CSKEWSTRING @"cskewstring"


//advanced settings
#define ADVANCEDSETTINGS @"advancedsettings"
#define USEHANDPRINT @"usehandprint"
#define CHECKFORDUPLICATES @"checkforduplicates"
#define SEARCHMICR @"searchmicr"
#define CHECKVALIDATIONSERVER @"checkvalidationatserver"
#define SHOWCHECKINFO @"showcheckinfo"
#define SHOWCHECKGUIDINGDEMO @"showcapturedemo"
#define SHOWGUIDINGDEMO @"showcapturedemo"
#define CHECKEXTRACTION @"checkextraction"
#define SHOWINSTRUCTION @"showinstruction"
#define DOCUMENTSNUMBER @"numberofdocumentstocapture"
#define SHOWINSTRUCTIONSCREEN @"showinstructionscreen"
#define FIRSTTIMELAUNCHDEMO @"isfirsttimecheckdemo" // This instance is used to track if the app is launched for the forst time . This value goes to false when the user sees the check demo for front and back atleast once or if the user manually switches off the Settings for Guiding Demo .


//rtti settings
#define RTTISETTINGS @"extractionsettings"
#define HTTPPROTOCOL @"serverprotocol"
#define SERVERPORT  @"serverport"
#define SERVERURL @"rttiserverurl"
#define KTASERVERURL @"ktaserverurl"
#define CUSTOMFIELDKEYVALUE @"fieldlabels"
#define SHOWALLFIELDS @"showallfields"
#define INSTRUCTIONIMAGELOGO @"instructionimage"
#define HOMEIMAGELOGO @"homescreenlogo"
#define HIGHLIGHTDATA @"highlightextracteddata"
#define HIGHLIGHTSWITCH @"showhighlightsswitch"
#define SAVEORIGINALIMAGESWITCH @"saveoriginalimage"
#define BILLPAYURL          @"https://mobiledemo.kofax.com:443/mobilesdk/api/billpay?customer=Kofax"
#define CHECKDEPOSITURL     @"https://mobiledemo.kofax.com:443/mobilesdk/api/CheckDeposit?customer=Kofax"
#define IDCARDURL           @"https://mobiledemo.kofax.com/mobilesdk/api/MobileID"
#define CUSTOMCOMPONENTURL  @"https://mobiledemo.kofax.com/mobilesdk/api/MobileID?xIdType=passport"
#define CREDITCARDURL       @"https://mobiledemo.kofax.com/mobilesdk/api/cardcapture"
#define EXTRACTMETHOD @"cardtype"
#define EXTRACTMETHOD_DEFAULT @"2"
#define EXTRACTION_SERVERTYPE_DEFAULT @"3"
#define CREDITCARDNUMBERVALID @"cardNumberValid"
#define CREDITCARDEXPIRYDATEVALID @"expiryDateValid"
#define CREDITCARDNETWORKVALID @"cardNetworkValid"


#define ODEEXTRACTIONENABLED @"odeextractionenabled"

#define ODELICENCESERVERURL @"odelicenseserverurl"
#define ODELICENCEAUTOFETCH @"odelicenseautofetch"
#define ODEACQUIRECOUNT @"odeacquirecount"
#define ODE_RTTI_URL @"http://mobiledemo.kofax.com/mobilesdk"
#define ODE_KTA_URL @""
#define ODE_LICENSE_RTTI_SERVER_URL @"odelicenserttiserverurl"
#define ODE_LICENSE_KTA_SERVER_URL @"odelicensektaserverurl"
#define ODE_MODELS_SERVER_URL @"odemodelsserverurl"
#define ODE_MODEL_URL @"https://mobiledemo.kofax.com/mobileupdater/api/ExtractionModelService/"
#define IP_PROFILE @"ipprofile"
#define PASSPORT_PROFILE @"IpProfilePassport"


#define ODE_SERVER_MODE @"odelicenseservertype"
#define SERVER_MODE @"extractionservertype"
#define ONLINE_SERVER_MODE @"onlineextractionservertype"
#define MOBILE_ID_TYPE @"mobileidtype"
#define RTTI_KOFAX_SERVER_URL @"rttikofaxserverurl"
#define KTA_KOFAX_SERVER_URL @"ktakofaxserverurl"
#define KTAUSERNAME @"ktausername"
#define KTAPASSWORD @"ktapassword"
#define KTAPROCESSNAME @"ktaprocessname"
#define KTAIDTYPE  @"ktaidtype"
#define KTA_KOFAX_USERNAME @"ktakofaxusername"
#define KTA_KOFAX_PASSWORD @"ktakofaxpassword"
#define KTA_KOFAX_PROCESSNAME @"ktakofaxprocessname"
#define KTA_KOFAX_IDTYPE  @"ktakofaxidtype"

//Image Names
#define EDITBUTTONIMAGE @"edit_icon_gray.png"
#define DELETEBUTTONIMAGE @"delete_icon_gray.png"
#define SETTINGSBUTTONIMAGE @"settings_icon.png"
#define INFOBUTTONIMAGE @"info.png"
#define APPSTATSBUTTONIMAGE @"app stats settings.png"
#define BACKBUTTONIMAGE @"back_icon.png"
#define CHECKBUTTONIMAGE @"check.png"
#define UNCHECKBUTTONIMAGE @"uncheck.png"
#define PAYBILLSICON @"pay bills.png"
#define CHECKDEPOSITICON @"chek deposit.png"
#define DRIVERLICENSEICON @"dl_icon.png"
#define CUSTOMICON @"Custom Component Icon.png"
#define CREDITCARDICON @"creditcardcomponenticon.png"
#define SHIELDIMAGE @"shield_bg"
#define BILLPAYSAMPLE @"bill_pay_sample.png"

//Bill Pay Results Keys
#define BILLPAYKEYNAME @"name"
#define BILLPAYNAME @"Name"
#define BILLPAYAMOUNTDUE @"AmountDue"
#define BILLPAYDUEDATE @"DueDate"
#define BILLPAYTEXT @"text"
#define BILLPAYPHONENUM @"PhoneNumber"

//DL Results Keys
#define DLNAME @"Name"
#define DLFIRSTNAME @"First Name"
#define DLLASTNAME @"Last Name"
#define DLMIDDLENAME @"Middle Name"
#define DLSTREET @"Street"
#define DLCITY @"City"
#define DLSTATE @"State"
#define DLZIPCODE @"Zip Code"
#define DLDOB @"Date Of Birth"
#define DLNUMBER @"Driver License"
#define DLGENDER @"Gender"
#define DLISSUEDATE @"Issue Date"
#define DLEXPIRYDATE @"Expiry Date"
#define DLID @"ID"
#define DLDRIVERPHOTO @"FaceImage64"
#define DLDRIVERSIGNATURE @"SignatureImage64"

// Germany ID's

#define ImageResizeID1 @"ID-1" // All by default
#define ImageResizeGermanyOldID2 @"ID-2" // Old ID

#define TAPTOPREVIEWIMAGE @"Tap on image to preview"





//NSUserDefaults Keys
#define ENABLEAPPSTATS @"enableappstats"
#define EXPORTFORMAT @"exportformat"
#define EXPORTURL @"exporturl"
#define APPSTATSINFO @"appstatsinfo"
#define LOGGEDININFO @"userLoggedIn"
#define USERLOGINDETAILS @"userlogindetails"
#define REMEMBERUSERINFO @"rememberUser"
#define FLASHSETTINGS @"flashsettings"
#define USERNAMEVALUE @"usernameValue"
#define PASSWORDVALUE @"passwordValue"
#define EMAILVALUE @"emailValue"
#define PROFILECOUNTER @"profilecounter"
#define CDCHECKINFORMATION @"checkInformation"
#define CDBACKSIGNATURE @"backSignature"
#define ACTIVEPROFILE @"ActiveProfile"
#define ISCOMPLETEDOWNLOADMODELS @"completedownloadmodels"

#define FIRSTTIMELAUNCH @"firstTimeLaunch"


//Font Names
#define FONTNAME @"HelveticaNeue"

//Cell Identifier
#define TABLECELLIDENTIFIER @"cellIdentifier"

//NIB Names
#define EXHIBITORVIEWCONTROLLER @"ExhibitorViewController"


//general text
#define DLREGIONSECTIONHEADER @"SELECT THE COUNTRY OF YOUR ID"
#define DLCONTINENTSECTIONHEADER @"SELECT THE REGION OF YOUR ID"
#define DLSUBMITCANCELALERT @"Do you want to cancel submission of ID Card?"

//AppStats
#define ENABLEAPPSTATS @"enableappstats"
#define EXPORTFORMAT @"exportformat"
#define EXPORTURL @"exporturl"
#define APPSTATSINFO @"appstatsinfo"
#define RAMTHRESHOLDLIMIT @"ramthresholdlimit"
#define FILETHRESHOLDLIMIT @"filethresholdlimit"

//Camera Permission
#define ATITLE_CAMERA_PERMISSION  Klm(@"Allow camera access")
#define AMSG_CAMERA_PERMISSION    Klm(@"\n To capture documents with your device,allow application to use your camera \n \n Settings->Privacy->Camera")

//ImageDebugging Tag
#define FileNameLength 7
#define CheckDepositDebuggingTag 11111
#define BillPayDebuggingTag 22222
#define DriverLicenseDebuggingTag 33333
#define PassportLicenseDebuggingTag 44444

//KTA server constants
#define JOBSERVICE @"/JobService.svc/json/CreateJobWithDocumentsAndProgress2"
#define JOBSERVICEWITHSYNC @"/JobService.svc/json/CreateJobSyncWithDocuments"

#define USERSERVICE @"/UserService.svc/json/LogOnWithPassword"
#define GETDOCUMENTSERVICE @"/CaptureDocumentService.svc/json/GetDocument"
#define DELETEDOCUMENTSERVICE @"/CaptureDocumentService.svc/json/DeleteDocument"

#define PROCESS_IDENTITY_NAME @"processIdentityName"
#define DOCUMENT_NAME @"documentName"
#define DOCUMENT_GROUP_NAME @"documentGroupName"
#define KTA_SERVER_URL @"serverURL"
#define PROCESS_ID_TYPE @"IDType"
// Image Mime Type

#define MIME_TYPE_TIFF @"tiff"
#define MIME_TYPE_JPEG @"jpeg"


//Error codes

#define FRONT_IMAGE_ERROR @"frontimageerror"
#define BACK_IMAGE_ERROR @"backimageerror"

//Server Response Codes

#define REQUEST_SUCCESS 200
#define REQUEST_FAILURE 500
#define REQUEST_TIMEDOUT -1001
#define NONETWORK -1009

#define EXTRACTION_FAILED_TAG 9999

#define INFO_DATE_FORMAT @"MM-dd-yyyy"
#define INFO_TEXT @"text"

#define HEADER_HEIGHT 64

@interface Constants : NSObject

@end
