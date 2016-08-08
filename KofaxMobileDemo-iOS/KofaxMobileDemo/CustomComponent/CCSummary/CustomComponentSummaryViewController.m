//
//  CCSummaryViewController.m
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/3/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "CustomComponentSummaryViewController.h"
#import "CaptureViewController.h"
#import "AppStateMachine.h"
#import <kfxLibLogistics/kfxLogistics.h>
#import "CustomComponentCell.h"

#define textFieldFont [UIFont fontWithName:FONTNAME size:15];

@interface CustomComponentSummaryViewController ()<UITextFieldDelegate>{
    NSDateFormatter *dateFormatter;
    UITextField *selectedTextField;
}
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic, assign) Component *componentObject;
@property (nonatomic, strong) NSMutableArray *resultsArray, *keysArray, *backupArray;
@property (nonatomic, strong) NSMutableArray*customKeysArray, *customValuesArray;
@property (nonatomic, assign) AppStateMachine *appStateMachine;
@property (nonatomic, strong) kfxKEDImage *processedImage;
@property (nonatomic, strong) kfxKEDImage *rawImage;

@property (nonatomic,strong) NSMutableArray *appStatsFieldsArray;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation CustomComponentSummaryViewController

#pragma mark Constructor Methods
-(id)initWithComponent:(Component*)component kedImage:(kfxKEDImage*)image andRawImage:(kfxKEDImage*)rawImage andResults:(NSArray*)results {
    self = [super init];
    if (self) {
        self.componentObject = component;
        self.processedImage = image;
        self.rawImage = rawImage;
        self.backupArray = results?[results mutableCopy]:[[NSMutableArray alloc]init];
    }
    return self;
}

#pragma mark ViewLifeCycle Methods

-(void)dealloc{
    self.resultsArray = nil;
    self.keysArray = nil;
    self.backupArray = nil;
    self.customKeysArray = nil;
    self.customValuesArray = nil;
    
    [self cleanTheRawImages];

    if (self.processedImage) {
        //[self.processedImage clearImageBitmap]; // Currently refrence from manager is maintained , so we should not clear the bit map . It will get cleared once the module is unloaded.
        self.processedImage = nil;
    }
    
    
    for (kfxKLOField *tempField in _appStatsFieldsArray) {
        
        kfxKLOField *tempField1 = tempField;
        tempField1 = nil;
    }
    _appStatsFieldsArray = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant += 20;
    }else{
        self.tableTopConstraint.constant -=42;
    }
    
    self.resultsArray = [[NSMutableArray alloc]init];
    
    self.appStateMachine = [AppStateMachine sharedInstance];
    //AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:Klm(STATICCANCELBUTTONTEXT) style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
    cancelButton.tintColor = [UIColor whiteColor];
    //    }
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.navigationItem.rightBarButtonItem = [AppUtilities getSettingsButtonItemWithTarget:self andAction:@selector(settingsButtonAction:)];
    
    //utilitiesObject = nil;
    self.keysArray = [[self.backupArray valueForKey:BILLPAYKEYNAME] mutableCopy];
    
    
    dateFormatter = [[NSDateFormatter alloc]init];
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // ImageBurry Debugging Option Check
    
    if([[[self.componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:EVRSDEBUGGING] boolValue]) {
        
        if(self.rawImage!=nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Klm(@"Message") message:Klm(@"Would you like to send the images via mail for debugging?") delegate:self cancelButtonTitle:Klm(@"Yes") otherButtonTitles:Klm(@"No"), nil];
                alertView.tag=PassportLicenseDebuggingTag;
                [alertView show];
            });
        }
    
    }

    // APP stats for field changes in BP
    _appStatsFieldsArray = [[NSMutableArray alloc] init];
    
    //blur the view when app goes into background
    [self createViewBlurInBackground];
}

-(void)getResultsArray{
    [self.resultsArray removeAllObjects];
    if (![[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SHOWALLFIELDS]boolValue]) {
        if ([self.customKeysArray count]== 0) {
            [self.resultsArray removeAllObjects];
        }else{
            for (NSString *key in self.customKeysArray) {
                if ([self.keysArray containsObject:key]) {
                    int index = (int)[self.keysArray indexOfObject:key];
                    int customIndex = (int)[self.customKeysArray indexOfObject:key];
                    NSMutableDictionary *dict = [[self.backupArray objectAtIndex:index]mutableCopy];
                    [dict setValue:[self.customValuesArray objectAtIndex:customIndex] forKey:BILLPAYKEYNAME];
                    [self.resultsArray addObject:dict];
                }
            }
        }
    }else{
        self.resultsArray = [NSMutableArray arrayWithArray:self.backupArray];
    }
    
    [self recordAppStatsForCC:-1];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    self.navigationItem.title = Klm(self.componentObject.name);
    
    [self getKeysAndValuesArray];
    
    
    [self getResultsArray];
    [self.table reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}


-(void)getKeysAndValuesArray{
    if (![[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SHOWALLFIELDS]boolValue]) {
        self.customKeysArray = [[NSMutableArray alloc]init];
        self.customValuesArray = [[NSMutableArray alloc]init];
        NSString *fieldsString = [[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:CUSTOMFIELDKEYVALUE];
        NSArray *array = [fieldsString componentsSeparatedByString:@";"];
        for (NSString *string in array) {
            NSArray *innerArray = [string componentsSeparatedByString:@","];
            NSString *innerString = [innerArray objectAtIndex:0];
            if (innerString.length!=0 && [innerArray count]==1) {
                [self.customKeysArray addObject:innerString];
                [self.customValuesArray addObject:innerString];
            }else if(innerString.length !=0 && [innerArray count]==2){
                NSString *secondString = [innerArray objectAtIndex:1];
                if (secondString.length !=0) {
                    [self.customValuesArray addObject:secondString];
                }else{
                    [self.customValuesArray addObject:innerString];
                }
                [self.customKeysArray addObject:innerString];
            }
        }
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark UITableViewDataSource and UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }else if(section==1){
        return [self.resultsArray count]+1;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section==0) {
        static NSString *identifier = @"Cell0" ;
        
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];     }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        

        UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        previewButton.frame = CGRectMake(([[UIScreen mainScreen]bounds].size.width-120)/2, 30, 120, 120);
        [previewButton setBackgroundImage:[UIImage imageNamed:@"bluecircle.png"] forState:UIControlStateNormal];
        
        UIImage* thumbImg = [self.processedImage getImageBitmap];
        if(thumbImg.size.height > thumbImg.size.width){
            thumbImg = [AppUtilities rotateImageLandscape:thumbImg];
        }
        
        previewButton.layer.cornerRadius = 60;
        previewButton.backgroundColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
        [previewButton setImage:[AppUtilities imageWithImage:thumbImg scaledToSize:CGSizeMake(96, 60)] forState:UIControlStateNormal];
        [previewButton addTarget:self action:@selector(previewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(([[UIScreen mainScreen]bounds].size.width-220)/2, 5, 220, 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:FONTNAME size:13];
        [AppUtilities adjustFontSizeOfLabel:label];
        label.text = Klm(TAPTOPREVIEWIMAGE);
        
        [cell.contentView addSubview:previewButton];
        [cell.contentView addSubview:label];
        
    }else if(indexPath.section==1 && indexPath.row==[self.resultsArray count]){
        static NSString *identifier = TABLECELLIDENTIFIER ;
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];     }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self designMakeButton:cell];
    }else if(indexPath.section==1){
        
        CustomComponentCell *customcell = (CustomComponentCell *)[tableView dequeueReusableCellWithIdentifier:@"CustomComponentCell"];
        if (!cell) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomComponentCell" owner:self options:nil];
            customcell = [nib objectAtIndex:0];
        }
        [customcell setSelectionStyle:UITableViewCellSelectionStyleNone];
        customcell.lblTitle.text = Klm([[self.resultsArray objectAtIndex:indexPath.row]valueForKey:BILLPAYKEYNAME]);
        customcell.txtFieldValue.text = [[self.resultsArray objectAtIndex:indexPath.row]valueForKey:BILLPAYTEXT];
        [AppUtilities reduceFontOfTextField:customcell.txtFieldValue];
        customcell.txtFieldValue.delegate = self;
        customcell.txtFieldValue.tag = indexPath.row;
        
        NSError *error = NULL;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:(NSTextCheckingTypes)NSTextCheckingTypeDate error:&error];
        
        NSArray *matches = [detector matchesInString:[[self.resultsArray objectAtIndex:indexPath.row]valueForKey:BILLPAYTEXT]
                                             options:0
                                               range:NSMakeRange(0, [[[self.resultsArray objectAtIndex:indexPath.row]valueForKey:BILLPAYTEXT] length])];
        
        for (NSTextCheckingResult *match in matches) {
            @autoreleasepool {
                if ([match resultType] == NSTextCheckingTypeDate) {
                    NSDate *date = [match date];
                    NSDateFormatter *formatter = [AppUtilities getDateFormatterOfLocale];
                    customcell.txtFieldValue.text = [formatter stringFromDate:date];
                    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
                    UIDatePicker *datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 44, [[UIScreen mainScreen]bounds].size.width, 176)];
                    datePicker.tag = indexPath.row;
                    
                    datePicker.date = date;
                    
                    [datePicker setDatePickerMode:UIDatePickerModeDate];
                    datePicker.date = date;
                    [datePicker setDatePickerMode:UIDatePickerModeDate];
                    datePicker.tintColor = [utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
                    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
                    [_toolbar setBarTintColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor]];
                    customcell.txtFieldValue.inputView = datePicker;
                    customcell.txtFieldValue.inputAccessoryView = _toolbar;
                    utilitiesObject = nil;
                }
            }
        }
        
        return customcell;
    }
    if (indexPath.section == 1 && indexPath.row<[self.resultsArray count]-1 && [self.resultsArray count]!=0) {
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(15, 53.5, [[UIScreen mainScreen]bounds].size.width-30, 1)];
        [line setBackgroundColor:[UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1.0f]];
        
        [cell.contentView addSubview:line];
    }
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return Klm(@"Document");
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0) {
        return 160;
    }else if(indexPath.section==1 && indexPath.row==[self.resultsArray count]){
        return 80;
    }else{
        return 54;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [selectedTextField resignFirstResponder];
}

- (void)designMakeButton:(UITableViewCell *)cell
{
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.frame = CGRectMake(15, 30, [[UIScreen mainScreen]bounds].size.width-30, 40);
    
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    [submitButton setTitleColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.buttonTextColor] forState:UIControlStateNormal];
    [submitButton setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.buttonColor] withTheme:[[ProfileManager sharedInstance]getActiveProfile].theme] forState:UIControlStateNormal];
    utilitiesObject = nil;
    
    [submitButton setTitle:Klm([self.componentObject.texts.summaryText valueForKey:SUBMITBUTTONTEXT]) forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    submitButton.enabled = self.resultsArray.count;
    
    cell.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:submitButton];
}


#pragma mark UITextFieldDelegate Methods
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    selectedTextField = textField;
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:1]];
    [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{

    NSMutableDictionary *dict = [[self.resultsArray objectAtIndex:textField.tag]mutableCopy];
    [dict setValue:textField.text forKey:BILLPAYTEXT];
    [self.resultsArray replaceObjectAtIndex:textField.tag withObject:dict];
    
    textField.font = textFieldFont;
    [AppUtilities reduceFontOfTextField:textField];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    NSMutableDictionary *dict = [[self.resultsArray objectAtIndex:textField.tag]mutableCopy];
    [dict setValue:textField.text forKey:BILLPAYTEXT];
    [self.resultsArray replaceObjectAtIndex:textField.tag withObject:dict];
    
    textField.font = textFieldFont;
    [AppUtilities reduceFontOfTextField:textField];

    [self recordAppStatsForCC:textField.tag];
    return YES;
}
#pragma mark Local Methods

-(void)recordAppStatsForCC:(NSInteger)fieldIndex{
    
    if(!_appStatsFieldsArray){
        
        _appStatsFieldsArray = [[NSMutableArray alloc] init];
    }
    
    if([_appStatsFieldsArray count] ==0){
        for (int i = 0; i < self.resultsArray.count; i++) {
            kfxKLOField *field = [[kfxKLOField alloc] init];
            [field updateFieldProperties:[[self.resultsArray objectAtIndex:i] valueForKey:BILLPAYTEXT] andIsValid:YES andErrorDescription:nil];
            [_appStatsFieldsArray addObject:field];
        }
    }
    else{
        
        if(fieldIndex>0){
            
            kfxKLOField *tempField = (kfxKLOField*)[_appStatsFieldsArray objectAtIndex:fieldIndex];
            NSString *oldValue = tempField.value;
            NSString *newValue = [[self.resultsArray objectAtIndex:fieldIndex] valueForKey:BILLPAYTEXT];
            
            if(![newValue isEqualToString:oldValue]){
                [tempField updateFieldProperties:newValue andIsValid:YES andErrorDescription:nil];
            }

        }
        
    }
    
}
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)cancelButtonAction:(id)sender
{
    [self.delegate summaryCancelButtonClicked];
}
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)submitButtonAction:(id)sender
{
    [self.delegate summarySubmitButtonClicked];
}

/*
 This method is used to push to settings controller.
 */
-(IBAction)settingsButtonAction:(id)sender
{
    [self updateData];
    [self.delegate summarySettingsButtonClicked];
}

-(IBAction)previewButtonAction:(id)sender{
    [self updateData];
    [self.delegate summaryPreviewButtonClicked:self.backupArray];
}

-(void)updateData{
    if (![[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SHOWALLFIELDS]boolValue]) {
        if ([self.customKeysArray count]!= 0) {
            for (NSDictionary *dict in self.resultsArray) {
                int customIndex = (int)[self.customValuesArray indexOfObject:[dict valueForKey:BILLPAYKEYNAME]];
                int index = (int)[self.keysArray indexOfObject:[self.customKeysArray objectAtIndex:customIndex]];
                NSMutableDictionary *dict1 = [[self.backupArray objectAtIndex:index]mutableCopy];
                [dict1 setValue:[dict valueForKey:BILLPAYTEXT] forKey:BILLPAYTEXT];
                [self.backupArray replaceObjectAtIndex:index withObject:dict1];
            }
        }
    }else{
        self.backupArray = [NSMutableArray arrayWithArray:self.resultsArray];
    }
}
- (IBAction)doneButtonAction:(id)sender {
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.view endEditing:YES];
}


-(IBAction)datePickerValueChanged:(UIDatePicker*)sender{
    NSDateFormatter *formatter = [AppUtilities getDateFormatterOfLocale];
    CustomComponentCell *cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:1]];
    cell.txtFieldValue.text = [formatter stringFromDate:sender.date];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == PassportLicenseDebuggingTag) {
        
        if(buttonIndex == 0){
            
            [AppUtilities addActivityIndicator];
            [self performSelector:@selector(sendImageSummary) withObject:nil afterDelay:0.25];
        }
        else{
            [self cleanTheRawImages];
        }
    }
}

-(void)sendImageSummary {
    
    NSDictionary *dictImages = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.rawImage,self.processedImage, nil] forKeys:[NSArray arrayWithObjects:@"Passport_UnProcessed",@"Passport_Processed", nil]];
    
    [self composeMailWithSubject:@"Image Summary - Passport" withImages:dictImages withResult:self.extractedError?self.extractedError.localizedDescription:self.backupArray.description];
    
    dictImages = nil;
    
    [self cleanTheRawImages];
}


#pragma mark Clean up

-(void)cleanTheRawImages
{
    if (self.rawImage != self.processedImage) {  //when extraction fails, both raw and processed image references are same. if we clear one image bitmap then other image bit map will be cleared.
        [self.rawImage clearImageBitmap];
        self.rawImage = nil;
    }
}


@end
