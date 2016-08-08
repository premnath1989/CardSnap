//
//  ODEExtractionView.m
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 28/09/15.
//  Copyright (c) 2016 Kofax. All rights reserved.
//

#import "ODEExtractionView.h"
#import "LicenceHelper.h"
#import "kfxEVRS_License.h"
#import "OnDeviceExtractor.h"


#define YPOS_TEXTVIEW 30
#define HEIGHT_TEXTVIEW 60
#define WIDTH_TEXTVIEW 200


@interface ODEExtractionView ()<UITextViewDelegate,UITextFieldDelegate,kfxKUTAcquireVolumeLicenseDelegate,UIAlertViewDelegate>
{
    UITextView *odeServerUrlField;
    UITextView *odeModelServerUrlField;
    UITableView *tblODE;
    UITextField *offlineCountField;
    UITextField *acquireCountField;
    UISwitch *acquireCountSwitch;
    UIAlertView* downloadModelsAlert;
    

}
@property (nonatomic, strong) UISegmentedControl *segmentControlODE;
@property (nonatomic, strong) UISegmentedControl *segmentControlODEServeryType;

@property (nonatomic) OnDeviceExtractor* onDeviceExtractor;

@end

@implementation ODEExtractionView
@synthesize cell;
@synthesize rttiSettings;

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self == [super initWithFrame:frame])
    {
        // initialise variables here
    }
    
    return self;
}
-(void)designODEview
{
    tblODE = [[UITableView alloc]initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y-24, self.frame.size.width, self.frame.size.height) style:UITableViewStyleGrouped];
    tblODE.delegate = self;
    tblODE.dataSource = self;
    tblODE.backgroundColor = [UIColor whiteColor];
    [self addSubview:tblODE];
}

#pragma mark UITableViewDataSource and UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 3;
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        return 4;
    }
    else
    {
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"cellIdentifier" ;
    
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:14];

    if (indexPath.section == 1)
    {
        if (indexPath.row == 0) {
            cell.textLabel.font = [UIFont fontWithName:FONTNAME size:14];
            cell.textLabel.text = Klm(@"Server Type");
            int previousSelectedIndex = [[rttiSettings valueForKey:ODE_SERVER_MODE]intValue];
            self.segmentControlODEServeryType = [AppUtilities createSegmentedControlWithTag:0 items:[NSArray arrayWithObjects:Klm(@"RTTI"),Klm(@"KTA"), nil] andSelectedSegment:previousSelectedIndex];
            [self.segmentControlODEServeryType addTarget:self action:@selector(odeSegmentValueChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = self.segmentControlODEServeryType;
        }
        else if(indexPath.row == 1){
            cell.textLabel.text = Klm(@"Server URL");
        NSString *serverurl;
        if (((NSNumber*)[self.rttiSettings valueForKey:ODE_SERVER_MODE]).boolValue) {
            // kta
            serverurl = (NSString*)[self.rttiSettings valueForKey:ODE_LICENSE_KTA_SERVER_URL];
        }
        else{
            serverurl = (NSString*)[self.rttiSettings valueForKey:ODE_LICENSE_RTTI_SERVER_URL];
        }
        
        odeServerUrlField =[AppUtilities createTextViewWithTag:0 frame:CGRectMake(0, YPOS_TEXTVIEW,WIDTH_TEXTVIEW,HEIGHT_TEXTVIEW) andText:serverurl];

        odeServerUrlField.delegate = self;
        cell.accessoryView = odeServerUrlField;
    }
        else if (indexPath.row == 2) {
            
            cell.textLabel.text = Klm(@"Available Offline Count");
            
            offlineCountField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 50, 25) placeholder:@"" andText:[NSString stringWithFormat:@"%d",[[LicenceHelper sharedInstance] getRemainingLicenseCount:LIC_ON_DEVICE_EXTRACTION]]];
            offlineCountField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            offlineCountField.delegate = self;
            offlineCountField.userInteractionEnabled = NO;
            
            cell.accessoryView = offlineCountField;
            
        } else if (indexPath.row == 3)
        {
            cell.textLabel.text = Klm(@"Acquire Count");
            
            NSNumber *acquireCount = [self.rttiSettings valueForKey:ODEACQUIRECOUNT];
            acquireCountField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 50, 25) placeholder:@"" andText:[NSString stringWithFormat:@"%d",acquireCount.intValue]];
            acquireCountField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            acquireCountField.delegate = self;
            cell.accessoryView = acquireCountField;
            
        }

    }
    else if (indexPath.section == 2)
    {
        if(indexPath.row == 0){
            cell.textLabel.text = Klm(@"Server URL");
            NSString *serverurl;
            serverurl = (NSString*)[self.rttiSettings valueForKey:ODE_MODELS_SERVER_URL];
            
            odeModelServerUrlField=[AppUtilities createTextViewWithTag:0 frame:CGRectMake(0, YPOS_TEXTVIEW,WIDTH_TEXTVIEW, HEIGHT_TEXTVIEW) andText:serverurl];
            odeModelServerUrlField.delegate = self;
            cell.accessoryView = odeModelServerUrlField;
        }
            
    }
    
    return cell;
}

- (void)odeSegmentValueChanged: (UISegmentedControl*)sender{
    [self.rttiSettings setValue:[NSNumber numberWithInteger:sender.selectedSegmentIndex] forKey:ODE_SERVER_MODE];
    
    [tblODE reloadData];
}

//This method sets the license server Url
-(void)setLicenseServerUrl{
    
    if (((NSNumber*)[self.rttiSettings valueForKey:ODE_SERVER_MODE]).boolValue) {
        // kta
        [[LicenceHelper sharedInstance] setMobileSDKLicenceServer:[self.rttiSettings valueForKey:ODE_LICENSE_KTA_SERVER_URL] type:SERVER_TYPE_TOTALAGILITY];
    }
    
    else{
        // Set the license to RTTI
        [[LicenceHelper sharedInstance] setMobileSDKLicenceServer:[self.rttiSettings valueForKey:ODE_LICENSE_RTTI_SERVER_URL] type:SERVER_TYPE_RTTI];
    }
   
}

-(void)switchValueChanged:(UISwitch *) sender
{
    [self.rttiSettings setValue:[NSNumber numberWithBool:sender.on] forKey:ODELICENCEAUTOFETCH];
    [tblODE reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 1;
    }else if ((indexPath.section == 1 && indexPath.row == 1)  || (indexPath.section == 2 && indexPath.row == 0)){
        return 80;
    }
    
    return 44; // For All Others
    
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return nil;
    }
    else if (section == 1){
        return Klm(@"License Volume");
    }
    else if (section == 2){
        return Klm(@"Models Download");
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return  40;
    }else if(section == 2)
    {
        return 60;
    }
    else
    {
        return 20;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return  40;
    }else if(section == 2){
        return  80;
    }
    else
    {
        return 0;
    }
}

-(void)reloadTableData
{
    [tblODE reloadData];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *vwForExtractionType = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
        vwForExtractionType.backgroundColor = [UIColor whiteColor];
        vwForExtractionType.userInteractionEnabled = YES;
        
        UILabel  *lblExtractionType = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, vwForExtractionType.frame.size.width/2, 30)];
        lblExtractionType.text = Klm(@"Extraction Type");
        lblExtractionType.font = [UIFont fontWithName:FONTNAME size:14];
        lblExtractionType.textColor = [UIColor blackColor];
        lblExtractionType.textAlignment = NSTextAlignmentLeft;
        [vwForExtractionType addSubview:lblExtractionType];
        

        _segmentControlODE = [[UISegmentedControl alloc]initWithItems:@[Klm(@"Server"),Klm(@"On Device")]];
        _segmentControlODE.frame = CGRectMake(vwForExtractionType.frame.size.width-150, 5, 140, 30);
        [_segmentControlODE addTarget:self action:@selector(segmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
        [_segmentControlODE setSelectedSegmentIndex:1];
        [vwForExtractionType addSubview:_segmentControlODE];
        
        return vwForExtractionType;
    }
    return  nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        UIView *vfForFetch = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width-40, 40)];
        vfForFetch.backgroundColor = [UIColor whiteColor];
        vfForFetch.userInteractionEnabled = YES;
        
        UIButton *btnFetch = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnFetch setTitle:Klm(@"Fetch") forState:UIControlStateNormal];
        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        
        Theme *themeObject = [[ProfileManager sharedInstance]getActiveProfile].theme;
        
        [btnFetch setTitleColor:[utilitiesObject colorWithHexString:themeObject.buttonTextColor] forState:UIControlStateNormal];
        [btnFetch setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:themeObject.buttonColor] withTheme:themeObject] forState:UIControlStateNormal];
        utilitiesObject = nil;
        [btnFetch addTarget:self action:@selector(btnFetchClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnFetch setFrame:CGRectMake(20, 10, [[UIScreen mainScreen]bounds].size.width-40, 40)];
        [vfForFetch addSubview:btnFetch];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 60, self.frame.size.width, 1.0)];
        line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [vfForFetch addSubview:line];

        return vfForFetch;

    }else if (section == 2) {
        UIView *vfForModel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width-40, 40)];
        vfForModel.backgroundColor = [UIColor whiteColor];
        vfForModel.userInteractionEnabled = YES;
        UIButton *btnModelDownload = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnModelDownload setTitle:Klm(@"Download Models") forState:UIControlStateNormal];
        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        
        Theme *themeObject = [[ProfileManager sharedInstance]getActiveProfile].theme;
        
        [btnModelDownload setTitleColor:[utilitiesObject colorWithHexString:themeObject.buttonTextColor] forState:UIControlStateNormal];
        [btnModelDownload setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:themeObject.buttonColor] withTheme:themeObject] forState:UIControlStateNormal];
        utilitiesObject = nil;
        [btnModelDownload addTarget:self action:@selector(btnDownloadModelsClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnModelDownload setFrame:CGRectMake(20, 10, [[UIScreen mainScreen]bounds].size.width-40, 40)];
        [vfForModel addSubview:btnModelDownload];
        return vfForModel;
        
    }
    return  nil;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self endEditing:YES];
}

-(void)segmentedControlValueDidChange:(UISegmentedControl *)segment
{
    [self endEditing:YES];
    
    if (self.callBack != nil && [self.callBack respondsToSelector:@selector(segmentedControlValueDidChange:)]) {
        [self.callBack segmentedControlValueDidChange:segment];
    }
}


#pragma mark UITextViewDelegate Methods

- (void)textViewDidEndEditing:(UITextView *)textView{
    [tblODE setContentOffset:CGPointMake(0, 0) animated:YES];
    
    if (textView == odeServerUrlField ) {
        if (((NSNumber*)[self.rttiSettings valueForKey:ODE_SERVER_MODE]).boolValue) {
            // kta
            [self.rttiSettings setValue:odeServerUrlField.text forKey:ODE_LICENSE_KTA_SERVER_URL];
        }
        
        else{
            [self.rttiSettings setValue:odeServerUrlField.text forKey:ODE_LICENSE_RTTI_SERVER_URL];
        }
        
    }else if (textView == odeModelServerUrlField){
        [self.rttiSettings setValue:odeModelServerUrlField.text forKey:ODE_MODELS_SERVER_URL];
    }
    
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    CGPoint pointInTable = [textView convertPoint:textView.bounds.origin toView:tblODE];
    NSIndexPath *indexPath = [tblODE indexPathForRowAtPoint:pointInTable];
    CGRect  rect=[tblODE rectForRowAtIndexPath:indexPath];
    [tblODE setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    return YES;
}

#pragma mark UITextFieldDelegate Methods
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    CGPoint pointInTable = [textField convertPoint:textField.bounds.origin toView:tblODE];
    NSIndexPath *indexPath = [tblODE indexPathForRowAtPoint:pointInTable];
    CGRect  rect=[tblODE rectForRowAtIndexPath:indexPath];
    [tblODE setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    // [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    if (acquireCountField == textField) {
        
        textField.text = [NSString stringWithFormat:@"%d",[self getAcquireCountValue:[textField.text intValue]]];
        [self.rttiSettings setValue:[NSNumber numberWithInteger:textField.text.integerValue]  forKey:ODEACQUIRECOUNT];
        
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (acquireCountField == textField) {
        
        textField.text = [NSString stringWithFormat:@"%d",[self getAcquireCountValue:[textField.text intValue]]];
        [self.rttiSettings setValue:[NSNumber numberWithInteger:textField.text.integerValue]  forKey:ODEACQUIRECOUNT];
    }
    [tblODE setContentOffset:CGPointMake(0, 0) animated:YES];
    [textField resignFirstResponder];
    return YES;
}


//Method to validate and return acquire count value
-(int)getAcquireCountValue:(int)textFieldValue{
    
    int acquireCountValue=0;
    if (textFieldValue>100)
        acquireCountValue = 100;
    else if(textFieldValue>=1 &&textFieldValue<=100)
        acquireCountValue=textFieldValue;
    return acquireCountValue;
}


-(void)btnFetchClicked:(UIButton *)sender
{
    // Check if the user is online
    if ([AppUtilities isConnectedToNetwork]) {
        // Add activity indicator
        [AppUtilities addActivityIndicator];
        LicenceHelper *helper = [LicenceHelper sharedInstance];
        [self setLicenseServerUrl];
        helper.licenceDelegate = self;
        [helper acquireVolumeLicenses:LIC_ON_DEVICE_EXTRACTION withCount:acquireCountField.text.intValue];
        
    }
    else{
        dispatch_async(dispatch_get_main_queue(),^{
            
            UIAlertView* licenseFetchError = [[UIAlertView alloc] initWithTitle:Klm(@"No Network") message:Klm(@"Network is not available!!") delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
            [licenseFetchError show];
        });
    }
   
}

-(void)btnDownloadModelsClicked:(UIButton *)sender
{
    [self endEditing:YES];
    [tblODE setContentOffset:CGPointMake(0, 0) animated:YES];
    // Check if the user is online
    if ([AppUtilities isConnectedToNetwork]) {
        if(odeModelServerUrlField.text.length > 0){
            // Add activity indicator
            [AppUtilities addActivityIndicator];
            if (self.onDeviceExtractor == nil) {
                self.onDeviceExtractor = [[OnDeviceExtractor alloc] init];
            }
            bool isCompleteDownload = ((NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:ISCOMPLETEDOWNLOADMODELS]).boolValue;
            //Check for updates
            [self.onDeviceExtractor checkForModelUpdates:kfxKOEIDRegion_US onServer:[NSURL URLWithString:odeModelServerUrlField.text]  completionHandler:^(BOOL isupdateAvailable,NSError *error){
                if ((isupdateAvailable && error.code == KMC_SUCCESS) || !isCompleteDownload)
                {
                    [AppUtilities removeActivityIndicator];
                    dispatch_async(dispatch_get_main_queue(),^{
                        downloadModelsAlert = [[UIAlertView alloc] initWithTitle:nil message:Klm(@"Do you want to download Models now") delegate:self cancelButtonTitle:Klm(@"Yes") otherButtonTitles:Klm(@"No"), nil];
                        [downloadModelsAlert show];
                    });
                }
                else{
                        [AppUtilities removeActivityIndicator];
                        dispatch_async(dispatch_get_main_queue(),^{
                            if (error && error.code != KMC_SUCCESS) {
                                NSString* errorMessage = [kfxError findErrDesc:(int)error.code];
                                UIAlertView* updateError = [[UIAlertView alloc] initWithTitle:nil message:errorMessage delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
                                [updateError show];
                            }else if (!isupdateAvailable){
                                UIAlertView* updateError = [[UIAlertView alloc] initWithTitle:nil message:Klm(@"Models are up to date") delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
                                [updateError show];
                            }
                        });
                        
                    }
                }];
            }else{
                dispatch_async(dispatch_get_main_queue(),^{
                    UIAlertView* updateError = [[UIAlertView alloc] initWithTitle:nil message:Klm(@"Please enter a valid server URL") delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
                    [updateError show];
                });
            }
        
        
    }
    else{
        dispatch_async(dispatch_get_main_queue(),^{
            
            UIAlertView* licenseFetchError = [[UIAlertView alloc] initWithTitle:Klm(@"No Network") message:Klm(@"Network is not available!!") delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
            [licenseFetchError show];
        });
    }
    
}


- (void)acquireVolumeLicenseDone:(int) licAcquired error: (NSError*) error
{
    [[LicenceHelper sharedInstance] setLicenceDelegate:nil];
    // Remove activity indicator
    [AppUtilities removeActivityIndicator];
    // error handling here
    if (error) {
        dispatch_async(dispatch_get_main_queue(),^{
            NSString* errorMessage = [kfxError findErrMsg:(int)error.code];
            UIAlertView* licenseFetchError = [[UIAlertView alloc] initWithTitle:@"" message:errorMessage delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
            [licenseFetchError show];
        });
    }
    else{
        // reload table
        dispatch_async(dispatch_get_main_queue(),^{
            [self reloadTableData];
        });
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(downloadModelsAlert == alertView){
        if (buttonIndex == 0) {
            [AppUtilities addActivityIndicator];
                    //Download or update models
                    [self.onDeviceExtractor bulkDownloadLocalExtractionAssetsForRegion:kfxKOEIDRegion_US onServer:[NSURL URLWithString:odeModelServerUrlField.text]  completionHandler:^(NSError *error){
                        [AppUtilities removeActivityIndicator];
                        NSString *message = nil;
                        NSString *title = nil;

                        if (!error) {
                            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:ISCOMPLETEDOWNLOADMODELS];

                            message = Klm(@"Download Completed");
                        } else {
                             [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:ISCOMPLETEDOWNLOADMODELS];
                            title = Klm(@"Download Failed");
                            message = error.localizedDescription;
                        }
                        dispatch_async(dispatch_get_main_queue(),^{
                            
                            UIAlertView* downloadCompleteAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
                            [downloadCompleteAlert show];
                        });
                    }];
        }else{
            [AppUtilities removeActivityIndicator];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
