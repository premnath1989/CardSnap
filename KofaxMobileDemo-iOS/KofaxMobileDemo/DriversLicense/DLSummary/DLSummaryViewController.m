//
//  DLSummaryViewController.m
//  KofaxMobileDemo
//
//  Created by Mahendra on 05/11/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//This Class is responsible to show the summary results of the DL

#import "DLSummaryViewController.h"
#import <kfxLibLogistics/kfxLogistics.h>
#import "DLTableViewCell.h"

#define DOBPICKER 111
#define GENDERPICKERVIEW 222
#define INFO_NAME @"name"

#define defaultFont  [UIFont fontWithName:FONTNAME size:14]

@interface DLSummaryViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSDateFormatter *dateFormatter;
    NSString *formatString;
    UITextField *selectedTextField;
}

@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic,strong) NSMutableArray* keysArray;
@property (nonatomic, assign) Component *componentObject;
@property (nonatomic,strong) DLData* dlDataObject;
@property (nonatomic,strong) UIAlertView* cancelAlert;
@property (nonatomic,strong) UIAlertView* submitAlert;
@property (nonatomic,strong) UIPickerView *pickerView;
@property (nonatomic,strong) NSMutableArray *appStatsFieldsArray;
@property (nonatomic,assign) BOOL isODEActive;

@end

@implementation DLSummaryViewController

-(id)initWithComponent:(Component*)component andDLData: (DLData*)dlData
{
    if(self = [super init])
    {
        
        self.componentObject = component;
        if (((NSNumber*)[[component.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:SERVER_MODE]).integerValue == [NSNumber numberWithInt:2].integerValue) {
            self.isODEActive = YES;
        }
        if(dlData)
            self.dlDataObject = dlData;
        else
            self.dlDataObject = [[DLData alloc] init];  //if nil allocate an object to use for user edit
        [self makeResultsDictionary];
    }
    
    return self;
}

-(void)dealloc{
    self.resultsArray = nil;
    self.keysArray = nil;
    self.dlDataObject = nil;
    self.cancelAlert.delegate = nil;
    self.cancelAlert = nil;
    self.submitAlert.delegate = nil;
    self.submitAlert = nil;
    self.pickerView.delegate = nil;
    self.pickerView.dataSource = nil;
    self.pickerView = nil;
    dateFormatter = nil;
    if (self.frontProcessedImage) {
        [self.frontProcessedImage clearImageBitmap];
        self.frontProcessedImage = nil;
    }
    if (self.barCodeImage) {
        [self.barCodeImage clearImageBitmap];
        self.barCodeImage = nil;
    }
    [self cleanTheRawImages];
    
    for (kfxKLOField *tempField in _appStatsFieldsArray) {
        
        kfxKLOField *tempField1 = tempField;
        tempField1 = nil;
    }
    _appStatsFieldsArray = nil;
}


-(void)makeResultsDictionary
{
    
    //This is needed as we need all the keys in particular order
    if (!self.keysArray) {
        self.keysArray = [[NSMutableArray alloc] init];
    }
    [self.keysArray removeAllObjects];
    
    // Signature and photo aren't extracted as part of ODE
    self.componentObject.extractionFields = [[ExtractionFields alloc] initWithSettings:self.componentObject.settings.settingsDictionary componentType:self.componentObject.type withExtractionResult:_resultsArray];

    self.keysArray = self.componentObject.extractionFields.extractionFields[@"keysArray"];
    
    if (self.isODEActive || [[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:MOBILE_ID_TYPE] boolValue]) {
        ExtractInfo *info = [self extractionInfoForKey:@"DLDRIVERPHOTO" withArray:_keysArray];
        [_keysArray removeObject:info];
        info = [self extractionInfoForKey:@"SignatureImage64" withArray:_keysArray];
        [_keysArray removeObject:info];
    }
    
    if (self.captureSide == OTHERSIDEBARCODE && self.dlDataObject.drivinglicenseID.length == 0) {
        ExtractInfo *info = [self extractionInfoForKey:@"IDNumber" withArray:_keysArray];
        [_keysArray removeObject:info];
    }
   
    
    if(self.shouldImageDebuggingShown) {
        
        self.shouldImageDebuggingShown = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Klm(@"Message") message:Klm(@"Would you like to send the images via mail for debugging?") delegate:self cancelButtonTitle:Klm(@"Yes") otherButtonTitles:Klm(@"No"), nil];
            alertView.tag=DriverLicenseDebuggingTag;
            [alertView show];
        });
    }
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
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    dateFormatter = [[NSDateFormatter alloc]init];
    if (!self.utilitiesObject) {
        self.utilitiesObject = [[AppUtilities alloc] init];
    }
    
    // APP stats for field changes in BP
    _appStatsFieldsArray = [[NSMutableArray alloc] init];
    [self recordAppStatsForDL:-1 withValue:nil];
    
    //blur the view when app goes into background
    [self createViewBlurInBackground];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self makeResultsDictionary];
    [self.table reloadData];
    self.navigationItem.rightBarButtonItem = [AppUtilities getSettingsButtonItemWithTarget:self andAction:@selector(settingsButtonAction:)];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    self.navigationItem.title = Klm(self.componentObject.name);
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:Klm(STATICCANCELBUTTONTEXT) style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    
    cancelButton.tintColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    formatString = @"yyyy-MM-dd";
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateDLData:(DLData*)dlData
{
    self.dlDataObject = dlData;
}

#pragma mark UITableViewDataSource and UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0)
    {
        return 1; //this section for the buttons on top (License front/back)
    }
    else if(section==1)
    {
        return [self.keysArray count]; //this section for actual values
    }
    else
    {
        return 1; //this section for the submit button
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = TABLECELLIDENTIFIER ;
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.section==0)
    {
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake((tableView.frame.size.width-150)/2, 2, 150, 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:FONTNAME size:13];
        label.text = Klm(TAPTOPREVIEWIMAGE);
        [AppUtilities adjustFontSizeOfLabel:label];
        
        //Front
        UIButton *licenseFront = [UIButton buttonWithType:UIButtonTypeCustom];
        [licenseFront setBackgroundImage:[UIImage imageNamed:@"bluecircle.png"] forState:UIControlStateNormal];
        licenseFront.layer.cornerRadius = 60;
        licenseFront.backgroundColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
        
        if(self.frontProcessedImage)
        {
            UIImage* frontImage = [self.frontProcessedImage getImageBitmap];
            if(frontImage.size.height > frontImage.size.width)
                frontImage = [AppUtilities rotateImageLandscape:frontImage];
            [licenseFront setImage:[AppUtilities imageWithImage:frontImage scaledToSize:CGSizeMake(96, 60)] forState:UIControlStateNormal];
        }
        
        else
            [licenseFront setImage:[UIImage imageNamed:@"dl_front.png"] forState:UIControlStateNormal];
        
        [licenseFront addTarget:self action:@selector(licenseFrontButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        int gap;
        gap = ([[UIScreen mainScreen]bounds].size.width-240)/3;
        licenseFront.frame = CGRectMake(gap, 30, 120, 120);
        
        UILabel *frontLabel = [[UILabel alloc]initWithFrame:CGRectMake(gap, 160, 120, 21)];
        frontLabel.textAlignment = NSTextAlignmentCenter;
        frontLabel.text = Klm(@"Front");
        frontLabel.font = [UIFont fontWithName:FONTNAME size:18];
        
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:licenseFront];
        [cell.contentView addSubview:frontLabel];
        [AppUtilities adjustFontSizeOfLabel:frontLabel];
        
        //  if (self.captureSide != ONESIDE) {
        //Back Thumbnail construction
        UIButton *licenseBack = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (self.captureSide != ONESIDE) {
            licenseBack.userInteractionEnabled = YES;
            [licenseBack setBackgroundImage:[UIImage imageNamed:@"bluecircle.png"] forState:UIControlStateNormal];
            
        }
        else {
            
            licenseBack.userInteractionEnabled = NO;
            [licenseBack setBackgroundImage:[UIImage imageNamed:@"graycircle.png"] forState:UIControlStateNormal];
            
            
        }
        licenseBack.layer.cornerRadius = 60;
        licenseBack.backgroundColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
        
        if(self.barCodeImage)
        {
            UIImage* backImage = [self.barCodeImage getImageBitmap];
            if(backImage.size.height > backImage.size.width)
                backImage = [AppUtilities rotateImageLandscape:backImage];
            [licenseBack setImage:[AppUtilities imageWithImage:backImage scaledToSize:CGSizeMake(96, 60)] forState:UIControlStateNormal];
        }
        
        else
            [licenseBack setImage:[UIImage imageNamed:@"dl_back.png"] forState:UIControlStateNormal];
        
        [licenseBack addTarget:self action:@selector(licenseBackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        licenseBack.frame = CGRectMake(2*gap+120, 30, 120, 120);
        
        UILabel *backLabel = [[UILabel alloc]initWithFrame:CGRectMake(2*gap+120, 160, 120, 21)];
        backLabel.textAlignment = NSTextAlignmentCenter;
        backLabel.text = Klm(@"Back Side");
        backLabel.font = [UIFont fontWithName:FONTNAME size:18];
        
        
        
        [cell.contentView addSubview:licenseBack];
        [cell.contentView addSubview:backLabel];
        [AppUtilities adjustFontSizeOfLabel:backLabel];
        
        licenseBack = nil;
        licenseFront = nil;
        
    }
    else if(indexPath.section==1)
    {
        DLTableViewCell *customCell = [tableView dequeueReusableCellWithIdentifier:@"DLTableViewCell"];
        
        if (!customCell) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DLTableViewCell" owner:self options:nil];
            customCell = [nib objectAtIndex:0];
        }
        
        ExtractInfo *info = self.keysArray[indexPath.row];
        customCell.txtFieldValue.tag = indexPath.row;
        customCell.txtFieldValue.delegate = self;
        NSString *placeHolder=[NSString stringWithFormat:@"Enter %@",info.name];
        customCell.txtFieldValue.placeholder = Klm(placeHolder);
        customCell.txtFieldValue.inputView = nil;
        customCell.txtFieldValue.inputAccessoryView = nil;

        if ([info.name caseInsensitiveCompare:@"Signature"] == NSOrderedSame || [info.name caseInsensitiveCompare:@"Photo"] == NSOrderedSame) {
            customCell.txtFieldValue.hidden = YES;
            customCell.dlImage.hidden = NO;
            if ([info.name caseInsensitiveCompare:@"Photo"] == NSOrderedSame) {
                customCell.dlImage.image = self.dlDataObject.imgDriverPhoto;
            }
            else{
                customCell.dlImage.image = self.dlDataObject.imgDriverSignature;
            }
        }
        else {
            customCell.txtFieldValue.hidden = NO;
            customCell.dlImage.hidden = YES;
        }
        
        customCell.txtFieldValue.text = info.value;
        if ([info.key isEqualToString:@"ZIP"] || [info.key isEqualToString:@"License"] ) {
            customCell.txtFieldValue.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        }
        else if ([info.key isEqualToString:@"Gender"]){
            self.pickerView = (UIPickerView *)[self pickerViewForCell:cell];
            self.pickerView.tag = GENDERPICKERVIEW + indexPath.row;
            UIToolbar *toolbar = (UIToolbar *)[self inputAccessoryViewForCell:cell forIndexPath:indexPath];
            customCell.txtFieldValue.inputView = self.pickerView;
            customCell.txtFieldValue.inputAccessoryView = toolbar;
            if (info.value && ([info.value isEqualToString:@"M"]||[info.value isEqualToString:@"MALE"])) {
                customCell.txtFieldValue.text = Klm(@"MALE");
                [self.pickerView selectRow:0 inComponent:0 animated:YES];
            }else if(info.value && ([info.value isEqualToString:@"F"]||[info.value isEqualToString:@"FEMALE"])){
                customCell.txtFieldValue.text = Klm(@"FEMALE");
                [self.pickerView selectRow:1 inComponent:0 animated:YES];
            }
        }
        else if ([info.key isEqualToString:@"IssueDate"] || [info.key isEqualToString:@"ExpirationDate"] || [info.key isEqualToString:@"DateOfBirth"]){
            
            NSLog(@"date set is %@",info.value);

            [dateFormatter setDateFormat:formatString];
            NSDate *dob = [dateFormatter dateFromString:info.value];
            UIDatePicker *datePicker = (UIDatePicker *)[self inputViewForCell:cell];
            datePicker.tag = DOBPICKER + indexPath.row;
            if (dob) {
                customCell.txtFieldValue.text = [[AppUtilities getDateFormatterOfLocale] stringFromDate:dob];
                datePicker.date = dob;
            }else{
                datePicker.date = [NSDate date];
                customCell.txtFieldValue.text = @"";
            }
            UIToolbar *toolbar = (UIToolbar *)[self inputAccessoryViewForCell:cell forIndexPath:indexPath];
            customCell.txtFieldValue.inputView = datePicker;
            customCell.txtFieldValue.inputAccessoryView = toolbar;
        }
        
        if([self.dlDataObject.userPickedregion isEqualToString:@"Canada"] && [info.key isEqualToString:DLSTATE])
            customCell.lblTitle.text = Klm(@"Province");
        else
            customCell.lblTitle.text = Klm(info.name);
        
        return customCell;
    }
    else if(indexPath.section==2)
    {
        [self designMakeButton:cell];
    }
    
    if ((indexPath.section == 1 && indexPath.row<self.keysArray.count-1)) {
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(15, 43.5, [[UIScreen mainScreen]bounds].size.width-15, 1)];
        [line setBackgroundColor:[UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1.0f]];
        
        [cell.contentView addSubview:line];
    }
    return cell;
}

- (void)designMakeButton:(UITableViewCell *)cell
{
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.frame = CGRectMake(15, 10, [[UIScreen mainScreen]bounds].size.width-30, 40);
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    [submitButton setTitleColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.buttonTextColor] forState:UIControlStateNormal];
    [submitButton setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.buttonColor] withTheme:[[ProfileManager sharedInstance]getActiveProfile].theme] forState:UIControlStateNormal];
    utilitiesObject = nil;
    [submitButton setTitle:Klm([self.componentObject.texts.summaryText valueForKey:SUBMITBUTTONTEXT]) forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    if(self.launchedByExtractionFailed){
        submitButton.enabled = NO;
    }
    else {
        submitButton.enabled = YES;
    }
    cell.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:submitButton];
}

-(UIView *)pickerViewForCell:(UITableViewCell *)cell
{
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    UIPickerView *pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 44, [[UIScreen mainScreen]bounds].size.width, 176)];
    pickerView.tintColor = [utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
    pickerView.delegate = self;
    return pickerView;
}


-(UIView *)inputViewForCell:(UITableViewCell *)cell
{
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    UIDatePicker *datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 44, [[UIScreen mainScreen]bounds].size.width, 176)];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    datePicker.tintColor = [utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    return datePicker;
}

-(UIView *)inputAccessoryViewForCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 44)];
    [toolbar setBarTintColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor]];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:Klm(STATICDONEBUTTONTEXT) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
    doneButton.tintColor = [utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.buttonTextColor];
    doneButton.tag = indexPath.row;
    
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace,doneButton, nil]];
    
    return toolbar;
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0)
    {
        return Klm(@"ID Card");
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.section==0)
    {
        return 190;
    }
    else if(indexPath.section==1)
    {
        return 50;
    }
    else
    {
        return 60;
    }
    
    return 44;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [selectedTextField resignFirstResponder];
}

#pragma mark
#pragma mark textfield delegate methods
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    selectedTextField = textField;
    return YES;
}

//Text field methods would handle the editing of the fileds by user
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:1]];
    [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
}


//Check which key is being edited For some keys the display and actual properties differ hence redo the key
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.inputView) {
        return;
    }
    
    if(textField.tag < [self.keysArray count])
    {
        ExtractInfo *info = self.keysArray[textField.tag];
        info.value = textField.text;
        [self recordAppStatsForDL:textField.tag withValue:info.value];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    textField.font = defaultFont;
    [AppUtilities reduceFontOfTextField:textField];
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    return YES;
}

#pragma mark
#pragma mark UIPickerViewDelegate and UIPickerViewDatasource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (row == 0) {
        return Klm(@"MALE");
    }else{
        return Klm(@"FEMALE");
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    int indexPath = pickerView.tag - GENDERPICKERVIEW;
    ExtractInfo *info = _keysArray[indexPath];
    UITableViewCell *cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath inSection:1]];
    UITextField *valueField = (UITextField*)[cell viewWithTag:(indexPath)];
    if (row == 0) {
        self.dlDataObject.gender = @"MALE";
        info.value = @"MALE";
    }else{
        self.dlDataObject.gender = @"FEMALE";
        info.value = @"FEMALE";
    }
    valueField.text = info.value;
    [self recordAppStatsForDL:valueField.tag withValue:info.value];
}


-(ExtractInfo *)extractionInfoForKey:(NSString *)key withArray:(NSArray *)array
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key = %@",key];
    NSArray *tempArray = [array filteredArrayUsingPredicate:predicate];
    if (tempArray.count) {
        return tempArray[0];
    }
    return nil;
}

#pragma mark
#pragma mark button action methods
-(void)recordAppStatsForDL:(NSInteger)index withValue:(NSString *)newValue{
    
    if(!_appStatsFieldsArray){
        _appStatsFieldsArray = [[NSMutableArray alloc] init];
    }
    
    if([_appStatsFieldsArray count] == 0){
        for (ExtractInfo *info in _keysArray) {
            kfxKLOField *individualField = [[kfxKLOField alloc] init];
            [individualField updateFieldProperties:info.value andIsValid:YES andErrorDescription:nil];
            [_appStatsFieldsArray addObject:individualField];
        }
    }
    else{
        
        if(index<0)
            return;
        
        kfxKLOField *tempField = [_appStatsFieldsArray objectAtIndex:index];
        ExtractInfo *info = [self.keysArray objectAtIndex:index];
        NSString *oldValue = tempField.value;
        NSString *newValue = info.value;
        if(![newValue isEqualToString:oldValue]){
            [tempField updateFieldProperties:newValue andIsValid:YES andErrorDescription:nil];
        }
        [self updateResultsArray];
    }
}

-(void)updateResultsArray
{
    NSMutableArray *arrUpdatedCheckResults = [[NSMutableArray alloc] init];
    
    for (id result in _resultsArray) {
        @autoreleasepool {
            if ([result isKindOfClass:[kfxKOEDataField class]]) {
                [arrUpdatedCheckResults addObject:result];
            }else{
                NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithDictionary:result];
                [arrUpdatedCheckResults addObject:mutableDict];
            }
        }
    }
    
    for (id dictResult in arrUpdatedCheckResults) {
        kfxKOEDataField *dataField = (kfxKOEDataField*)dictResult;
        if ([dictResult isKindOfClass:[kfxKOEDataField class]]) {
            ExtractInfo *info = [self extractionInfoForKey:dataField.name withArray:_keysArray];
            if (info) {
                dataField.value = info.value;
            }
        }else{
            ExtractInfo *info = [self extractionInfoForKey:[dictResult valueForKey:INFO_NAME] withArray:_keysArray];
            if (info) {
                [dictResult setValue:info.value forKey:INFO_TEXT];
            }
        }
    }
    
    _resultsArray = arrUpdatedCheckResults;
    arrUpdatedCheckResults = nil;
    
}


//Action method when License front thumbnail is clicked
-(IBAction)licenseFrontButtonAction:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(licenseFrontThumbNailClicked)])
        [self.delegate licenseFrontThumbNailClicked];
}

//Action method when License back thumbnail is clicked
-(IBAction)licenseBackButtonAction:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(licenseBackThumbNailClicked)])
        [self.delegate licenseBackThumbNailClicked];
    
}

-(IBAction)cancelButtonAction:(id)sender
{
    self.cancelAlert = [[UIAlertView alloc] initWithTitle:Klm([self.componentObject.texts.summaryText valueForKey:SUBMITCANCELALERTTEXT]) message:nil delegate:self cancelButtonTitle:Klm(@"YES") otherButtonTitles:Klm(@"NO"), nil];
    [self.cancelAlert show];
}


-(IBAction)submitButtonAction:(id)sender
{
    self.submitAlert = [[UIAlertView alloc] initWithTitle:Klm([self.componentObject.texts.summaryText valueForKey:SUBMITALERTTEXT]) message:nil delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
    [self.submitAlert show];
}

-(IBAction)settingsButtonAction:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(settingsClicked)])
        [self.delegate settingsClicked];
}


-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([alertView isEqual:self.submitAlert])
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(submitButtonClicked)])
            [self.delegate submitButtonClicked];
        
    }
    else if([alertView isEqual:self.cancelAlert])
    {
        if(buttonIndex == 0)
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(summaryCancelClicked)])
                [self.delegate summaryCancelClicked];
        }
    }
}

-(IBAction)doneButtonAction:(UIButton*)sender{
    UITableViewCell *cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:1]];
    UITextField *valueField = (UITextField*)[cell viewWithTag:sender.tag];
    [self textFieldShouldReturn:valueField];
}


-(IBAction)datePickerValueChanged:(UIDatePicker*)sender
{
    UITableViewCell *cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag - DOBPICKER inSection:1]];
    UITextField *valueField = (UITextField*)[cell viewWithTag:(sender.tag - DOBPICKER)];
    // [valueField resignFirstResponder];
    valueField.text = [[AppUtilities getDateFormatterOfLocale] stringFromDate:sender.date];
    [dateFormatter setDateFormat:formatString];
    self.dlDataObject.dob = [dateFormatter stringFromDate:sender.date];
    ExtractInfo *info = [_keysArray objectAtIndex:sender.tag - DOBPICKER];
    info.value = [dateFormatter stringFromDate:sender.date];
    [self recordAppStatsForDL:valueField.tag withValue:info.value];
    NSLog(@"date set is %@",info.value);

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == DriverLicenseDebuggingTag) {
        if(buttonIndex == 0){
            [AppUtilities addActivityIndicator];
            [self performSelector:@selector(sendImageSummary) withObject:nil afterDelay:0.25];
        }
        else {
            [self cleanTheRawImages];
        }
    }
}

-(void)sendImageSummary {
    NSDictionary *dictImages = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.frontRawImage,self.frontProcessedImage, self.backRawImage?self.backRawImage:nil,self.backRawImage?self.barCodeImage:nil,nil] forKeys:[NSArray arrayWithObjects:@"IDCardFront_UnProcessed",@"IDCardFront_Processed", self.backRawImage?@"IDCardBack_UnProcessed":nil,self.backRawImage?@"IDCardBack_Processed":nil,nil]];
    if (self.isODEActive) {
        NSMutableArray* fieldsArray = [[NSMutableArray alloc] init];
        for (kfxKOEDataField* dataField in self.resultsArray) {
            [fieldsArray addObject:[AppUtilities getDictionary:dataField]];
        }
        [self composeMailWithSubject:@"Image Summary - ID Card" withImages:dictImages withResult:self.extractedError?self.extractedError.localizedDescription:fieldsArray.description];
    }
    else{
        [self composeMailWithSubject:@"Image Summary - ID Card" withImages:dictImages withResult:self.extractedError?self.extractedError.localizedDescription:self.resultsArray.description];
    }
    
    dictImages = nil;
    [self cleanTheRawImages];
}

-(void)cleanTheRawImages
{
    if(self.frontRawImage) {
        [self.frontRawImage clearImageBitmap];
        self.frontRawImage = nil;
    }
    
    if(self.backRawImage) {
        [self.backRawImage clearImageBitmap];
        self.backRawImage = nil;
    }
}

@end
