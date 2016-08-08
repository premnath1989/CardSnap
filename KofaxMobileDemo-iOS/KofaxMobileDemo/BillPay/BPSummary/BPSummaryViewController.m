//
//  BPSummaryViewController.m
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/3/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "BPSummaryViewController.h"
#import "CaptureViewController.h"
#import "AppStateMachine.h"
#import <kfxLibLogistics/kfxLogistics.h>
#import "BillPayInfoCustomCell.h"
#import "BPAmountInfoCustomCell.h"

#define DEFAULTFONT [UIFont fontWithName:FONTNAME size:16];
#define INFO_CONFIDENCE @"confidence"
#define INFO_NAME @"name"

@interface BPSummaryViewController ()<UITextFieldDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>{
    NSDateFormatter *dateFormatter;
    UITextField *selectedTextField;
}
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, weak) IBOutlet UITableView *table;
@property (nonatomic, assign) Component *componentObject;
@property (nonatomic, strong) NSMutableArray *resultsArray, *keysArray;
@property (nonatomic, assign) AppStateMachine *appStateMachine;
@property (nonatomic, strong) kfxKEDImage *processedImage;
@property (nonatomic, strong) kfxKEDImage *rawImage;

@property (weak, nonatomic) IBOutlet UICollectionView *imagesThumbnailCollectionView;

@property (nonatomic, weak) IBOutlet UIToolbar* keyboardToolbar;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, weak) IBOutlet UISegmentedControl *prevNextSegment;

@property (nonatomic,strong) NSMutableArray *appStatsFieldsArray;

@property (nonatomic, strong) UIScrollView *fieldsScrollView;
@property (nonatomic, strong) UIImageView *fieldView;
@end

@implementation BPSummaryViewController

#pragma mark Constructor Methods
-(id)initWithComponent:(Component*)component kedImage:(kfxKEDImage*)image andRawImage:(kfxKEDImage*)rawImage andResults:(NSArray*)results
{
    self = [super init];
    if (self) {
        self.componentObject = component;
        self.resultsArray = [results mutableCopy];
        self.processedImage = image;
        self.rawImage = rawImage;
    }
    return self;
}

#pragma mark ViewLifeCycle Methods


-(void)dealloc{
    
    self.resultsArray = nil;
    self.keysArray = nil;
    
    if (self.processedImage) {
        [self.processedImage clearImageBitmap];
        self.processedImage = nil;
    }
    
    [self cleanTheRawImages];
    
    for (kfxKLOField *tempField in _appStatsFieldsArray) {
        
        kfxKLOField *tempField1 = tempField;
        tempField1 = nil;
    }
    _appStatsFieldsArray = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.doneButton setTitle:Klm(self.doneButton.title)];
    [self.prevNextSegment setTitle:Klm([self.prevNextSegment titleForSegmentAtIndex:0]) forSegmentAtIndex:0];
    [self.prevNextSegment setTitle:Klm([self.prevNextSegment titleForSegmentAtIndex:1]) forSegmentAtIndex:1];
    
    // Do any additional setup after loading the view from its nib.
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant += 20;
    }else{
        self.tableTopConstraint.constant -=42;
    }
    self.appStateMachine = [AppStateMachine sharedInstance];
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:Klm(STATICCANCELBUTTONTEXT) style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    
    cancelButton.tintColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.navigationItem.rightBarButtonItem = [AppUtilities getSettingsButtonItemWithTarget:self andAction:@selector(settingsButtonAction:)];
    
    self.keyboardToolbar.barTintColor = [utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
    self.doneButton.tintColor = [utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.titleColor];
    self.prevNextSegment.tintColor = [utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.titleColor];
    
    utilitiesObject = nil;
    
    
//    self.keysArray = [[self.resultsArray valueForKey:BILLPAYKEYNAME] mutableCopy];
    dateFormatter = [[NSDateFormatter alloc]init];
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // ImageBurry Debugging Option Check
    
    if([[[self.componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:EVRSDEBUGGING] boolValue]) {
        if(self.rawImage!=nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Klm(@"Message") message:Klm(@"Would you like to send the images via mail for debugging?") delegate:self cancelButtonTitle:Klm(@"Yes") otherButtonTitles:Klm(@"No"), nil];
                alertView.tag=BillPayDebuggingTag;
                [alertView show];
            });
        }
    }
    
    self.componentObject.extractionFields = [[ExtractionFields alloc] initWithSettings:self.componentObject.settings.settingsDictionary componentType:self.componentObject.type withExtractionResult:_resultsArray];
    self.keysArray = self.componentObject.extractionFields.extractionFields[@"keysArray"];
    
    self.imagesThumbnailCollectionView.dataSource = self;
    self.imagesThumbnailCollectionView.delegate = self;
    
    [self.imagesThumbnailCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewIdentifier"];


    // APP stats for field changes in BP
    _appStatsFieldsArray = [[NSMutableArray alloc] init];
    [self recordAppStatsForBP:-1];
    
    //blur the view when app goes into background
    [self createViewBlurInBackground];
    
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

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    self.navigationItem.title =Klm(self.componentObject.name);
   // [self.table reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    selectedTextField.delegate = nil; //Delegate should be nil, because we are checking amount value when keyboard is down it may unappropriate results.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource and UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.keysArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"ChartListCell";
    
    BPAmountInfoCustomCell *billPayCell = (BPAmountInfoCustomCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (billPayCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BPAmountInfoCustomCell" owner:self options:nil];
        billPayCell = [nib objectAtIndex:0];
        
    }
    ExtractInfo *info = self.keysArray[indexPath.row];

    billPayCell.withCircleView.hidden = NO;
    billPayCell.withoutCircleView.hidden = YES;
    billPayCell.circleView.isShow = YES;
    billPayCell.selectionStyle = UITableViewCellSelectionStyleNone;
    billPayCell.withoutCircleView.hidden = YES;
    
    billPayCell.leftLabel.font = DEFAULTFONT;
    billPayCell.valueLabel.hidden = YES;
    [AppUtilities adjustFontSizeOfLabel:billPayCell.leftLabel];
    
    billPayCell.valueTextField.borderStyle = UITextBorderStyleNone;
    billPayCell.valueTextField.textAlignment = NSTextAlignmentRight;
    billPayCell.valueTextField.font = DEFAULTFONT;
    billPayCell.valueTextField.delegate = self;
    billPayCell.valueTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    billPayCell.valueTextField.tag = indexPath.row+1;
    billPayCell.valueTextField.returnKeyType = UIReturnKeyDone;
    billPayCell.valueTextField.inputView=nil;
    billPayCell.valueTextField.inputAccessoryView=nil;
    [billPayCell setKeyboardTypeForKey:info.key];
    if ([info.key isEqualToString:BILLPAYAMOUNTDUE] || [info.key isEqualToString:BILLPAYDUEDATE]) {
        NSString *amount = info.value;
        if ([info.key isEqualToString:BILLPAYAMOUNTDUE]) {
            //Converting server returned amount into "US" format.
            NSNumberFormatter *usNumberFormatter = [[NSNumberFormatter alloc] init];
            [usNumberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
            [usNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber *usNumber = [usNumberFormatter numberFromString:amount];
            
            //Converting "US" format amount into device locale format.
            NSNumberFormatter *numberFormatter = [self getNumberFormatterOfLocale];
            NSString *formattedAmount = [numberFormatter stringFromNumber:usNumber];
            billPayCell.valueTextField.text = formattedAmount;
            billPayCell.dueLabel.text = [NSString stringWithFormat:@"%@: %@", Klm(@"Amount Due"), formattedAmount];
        }
        else{
            UIDatePicker *datePicker = [[UIDatePicker alloc]init];
            [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
            datePicker.datePickerMode = UIDatePickerModeDate;
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            NSDate *dueDate;
            dueDate = [dateFormatter dateFromString:info.value];
            
            billPayCell.leftLabel.text = Klm(@"Pay By");
            [self updateDateFomatteraWithLocale];
            if (dueDate) {
                billPayCell.dueLabel.text = [NSString stringWithFormat:@"%@ %@", Klm(@"Payment Due:"), [dateFormatter stringFromDate:dueDate]];
            }else{
                billPayCell.dueLabel.text = Klm(@"Payment Due:");
            }
            
            //Showing current date only for "Pay By" field.
            
            [self updateDateFomatteraWithLocale];
            datePicker.date = [NSDate date];
            billPayCell.valueTextField.text = [dateFormatter stringFromDate:[NSDate date]];
            
            billPayCell.valueTextField.inputView = datePicker;
            datePicker = nil;
        }
        billPayCell.dueLabel.hidden = NO;
    } else {

        billPayCell.dueLabel.hidden = YES;
        billPayCell.valueTextField.text = info.value;
        billPayCell.leftLabel.frame = CGRectMake(billPayCell.leftLabel.frame.origin.x, 10, billPayCell.leftLabel.frame.size.width, billPayCell.leftLabel.frame.size.height);
    }
    
    if([info.key isEqualToString:BILLPAYDUEDATE]||[info.key isEqualToString:BILLPAYPHONENUM]){
        UIToolbar *toolbar = (UIToolbar *)[self inputAccessoryViewForCell:billPayCell forIndexPath:indexPath];
        billPayCell.valueTextField.inputAccessoryView=toolbar;
    }
    billPayCell.leftLabel.text = Klm(info.name);
    NSString *placeHolder = [NSString stringWithFormat:@"Enter %@",info.name];
    billPayCell.valueTextField.placeholder = Klm(placeHolder);

    billPayCell.circleView.percentNumber = info.confidence.stringValue;
    [billPayCell.circleView setNeedsDisplay];
    [AppUtilities reduceFontOfTextField:billPayCell.valueTextField];
    
   // billPayCell.valueTextField.inputAccessoryView = self.keyboardToolbar;
    return billPayCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView* cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 40)];
        cellView.backgroundColor = [UIColor whiteColor];
        UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        submitButton.frame = CGRectMake(15, 5, [[UIScreen mainScreen]bounds].size.width-30, 40);
        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        [submitButton setTitleColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.buttonTextColor] forState:UIControlStateNormal];
        [submitButton setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.buttonColor] withTheme:[[ProfileManager sharedInstance]getActiveProfile].theme] forState:UIControlStateNormal];
        utilitiesObject = nil;
        [submitButton setTitle:Klm([self.componentObject.texts.summaryText valueForKey:SUBMITBUTTONTEXT]) forState:UIControlStateNormal];
        [submitButton addTarget:self action:@selector(submitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cellView addSubview:submitButton];
    return cellView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 50;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView != self.fieldsScrollView) {
        [selectedTextField resignFirstResponder];
    }
}

#pragma mark UITextFieldDelegate Methods
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    selectedTextField = textField;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:textField.tag-1 inSection:0];
    CGRect  rect=[self.table rectForRowAtIndexPath:indexPath];
    [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:HIGHLIGHTSWITCH] boolValue])
    {
        
        if([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:HIGHLIGHTDATA] boolValue]){
            
            [self createFieldsHighlightView:textField.tag-1];
        }
    }
    self.doneButton.tag = textField.tag;
    self.prevNextSegment.tag = textField.tag;
    if (textField.tag == 1) {
        [self.prevNextSegment setEnabled:NO forSegmentAtIndex:0];
        [self.prevNextSegment setEnabled:YES forSegmentAtIndex:1];
    }else if(textField.tag == 10){
        [self.prevNextSegment setEnabled:YES forSegmentAtIndex:0];
        [self.prevNextSegment setEnabled:NO forSegmentAtIndex:1];
    }else{
        [self.prevNextSegment setEnabled:YES forSegmentAtIndex:0];
        [self.prevNextSegment setEnabled:YES forSegmentAtIndex:1];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    // [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    if([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:HIGHLIGHTSWITCH] boolValue])
    {
        
        if([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:HIGHLIGHTDATA] boolValue]){
            
            // Hide the fields Scroll View
            if (self.fieldsScrollView) {
                self.fieldsScrollView.hidden = TRUE;
                
                self.fieldView.image = nil;
                if (self.fieldsScrollView.subviews.count > 0)
                {
                    for (UIView *subView in [self.fieldsScrollView subviews])
                    {
                        [subView removeFromSuperview];
                    }
                }
                self.fieldsScrollView = nil;
            }
        }
    }
    
    self.imagesThumbnailCollectionView.hidden = FALSE;
    [self updateAndRecordValues:textField];
}

-(ExtractInfo *)extractionInfoForKey:(NSString *)key withArray:(NSArray *)array
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key = %@",key];
    NSArray *tempArray = [array filteredArrayUsingPredicate:predicate];
    if (tempArray.count) {
        return tempArray.firstObject;
    }
    return nil;
}

-(NSDictionary *)resultDictionaryForKey:(NSString *)key
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@",key];
    NSArray *tempArray = [_resultsArray filteredArrayUsingPredicate:predicate];
    if (tempArray.count) {
        return tempArray.firstObject;
    }
    return nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
//    if (textField) {
//        [self updateAndRecordValues:textField];
//    }
    [self.view endEditing:YES];
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    return YES;
}

-(void)updateAndRecordValues:(UITextField *)textField
{
    if (textField.inputView) {
        return;
    }
    ExtractInfo *info = self.keysArray[textField.tag-1];
    
    if (textField.tag == 1) {
        if ([self isAmountValid:textField.text]) {
            NSNumberFormatter *numberFormatter = [self getNumberFormatterOfLocale];
            NSString *formattedAmount = [numberFormatter stringFromNumber:[numberFormatter numberFromString:textField.text]];
            formattedAmount = [formattedAmount stringByReplacingOccurrencesOfString:@"," withString:@"."];
            textField.text = formattedAmount;
            info.value = formattedAmount;
        }
        else {
            if (!self.backButtonClicked) {
                [textField becomeFirstResponder];
                [self showInvalidAmountAlert];
            }
        }
    }
    else{
        info.value = textField.text;
    }
    [self updateResultsArray];
    textField.font = DEFAULTFONT;
    [AppUtilities reduceFontOfTextField:textField];
    [self recordAppStatsForBP:textField.tag];

}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.tag != 1) {
        return YES;
    }
    
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    if (![utilitiesObject isAllDigits:string] && ![string isEqualToString:@"."] && ![string isEqualToString:@","]) {
        return NO;
    }
    utilitiesObject = nil;
    return YES;
}

//Method is used for checking enterd amount is valid or not.

- (BOOL)isAmountValid:(NSString*)amount
{
    NSNumberFormatter *numberFormatter = [self getNumberFormatterOfLocale];
    NSNumber *number = [numberFormatter numberFromString:amount];
    NSString *amountString = [numberFormatter stringFromNumber:number];
    BOOL isMorethan2FractionDigits = NO;
    
    //Logic for finding number of fraction digits entered by user, if more than 2 fraction digits it will be invalid amount.
    if (number != nil) {
        NSArray *components = [amountString componentsSeparatedByString:@"."];
        if ([components count] > 1 && [[components lastObject] length] > 2) {
            isMorethan2FractionDigits = YES;
        }
    }
    if (number == nil || isMorethan2FractionDigits) {
        return NO;
    }
    return YES;
    
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    if(length > 4)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-3];
    }
    return mobileNumber;
}

-(int)getLength:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    return length;
}
#pragma mark Local Methods

/*
 This method starts recording all the field level changes.
 */

-(void)recordAppStatsForBP:(NSInteger)fieldIndex{
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
        int index = (int)fieldIndex-1;
        ExtractInfo *info = _keysArray[index];
        NSString *newValue = info.value;

        kfxKLOField *tempField = (kfxKLOField*)[_appStatsFieldsArray objectAtIndex:index];
        NSString *oldValue = tempField.value;
        
        if(![newValue isEqualToString:oldValue]){
            [tempField updateFieldProperties:newValue andIsValid:YES andErrorDescription:nil];
        }
    }
}

-(void)updateResultsArray
{
    NSMutableArray *arrUpdatedCheckResults = [[NSMutableArray alloc] init];
    
    for (NSDictionary *result in _resultsArray) {
        @autoreleasepool {
            NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithDictionary:result];
            [arrUpdatedCheckResults addObject:mutableDict];
        }
    }
    
    for (NSMutableDictionary *dictResult in arrUpdatedCheckResults) {
        
        ExtractInfo *info = [self extractionInfoForKey:[dictResult valueForKey:INFO_NAME] withArray:_keysArray];
        if (info) {
            [dictResult setValue:info.value forKey:INFO_TEXT];
        }
    }
    
    _resultsArray = arrUpdatedCheckResults;
    arrUpdatedCheckResults = nil;
    
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
    //checking entered amount is valid/invalid.
    
    if (selectedTextField.tag == 1 && [selectedTextField isFirstResponder]) {
        
        if ([self isAmountValid:selectedTextField.text] == NO) {
            [self showInvalidAmountAlert];
            return;
        }
    }
    [self.delegate summarySettingsButtonClicked];
}

-(IBAction)previewButtonAction:(id)sender{
    [self.delegate summaryPreviewButtonClicked:self.resultsArray];
}

-(IBAction)datePickerValueChanged:(UIDatePicker*)sender{
    [self updateDateFomatteraWithLocale];
    UITableViewCell *cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITextField *valueField = (UITextField*)[cell viewWithTag:2];
    valueField.font = DEFAULTFONT;
    valueField.text = [dateFormatter stringFromDate:sender.date];
    [AppUtilities reduceFontOfTextField:valueField];
    
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    ExtractInfo *info = [self extractionInfoForKey:@"DueDate" withArray:_keysArray];
    NSString *dueString = [dateFormatter stringFromDate:sender.date];
    info.value = dueString;
    [self updateResultsArray];
    [self recordAppStatsForBP:2];
}

#pragma mark Local Action Methods

-(IBAction)doneButtonAction:(UIButton*)sender{
    [self.view endEditing:YES];
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(IBAction)segmentControlAction:(UISegmentedControl*)segmentedControl{
    if (segmentedControl.selectedSegmentIndex == 0) {
        [self previousButtonAction];
    }else if(segmentedControl.selectedSegmentIndex == 1){
        [self nextButtonAction];
    }
}

-(void)previousButtonAction{
   
    NSInteger tag = selectedTextField.tag;
    CGRect size = [self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:tag-2 inSection:0]];
    [self.table setContentOffset:CGPointMake(0, size.origin.y) animated:YES];
    [self.table reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:tag-2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    BPAmountInfoCustomCell *cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag-2 inSection:0]];
    [cell.valueTextField becomeFirstResponder];
}

-(void)nextButtonAction{
    if (selectedTextField.tag == 1 && ![self isAmountValid:selectedTextField.text]) {
        [self showInvalidAmountAlert];
    }else{
        NSInteger tag = selectedTextField.tag;
        BPAmountInfoCustomCell *cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
        [cell.valueTextField becomeFirstResponder];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == BillPayDebuggingTag) {
        if(buttonIndex == 0){
            [AppUtilities addActivityIndicator];
            [self performSelector:@selector(sendImageSummary) withObject:nil afterDelay:0.25];
        }
        else {
            [self cleanTheRawImages];
        }
    }
}

-(void)cleanTheRawImages
{
    if (self.rawImage) {
        [self.rawImage clearImageBitmap];
        self.rawImage = nil;
    }
}

-(void)sendImageSummary {
    NSDictionary *dictImages = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.rawImage,self.processedImage, nil] forKeys:[NSArray arrayWithObjects:@"BillPay_UnProcessed",@"BillPay_Processed", nil]];
    [self composeMailWithSubject:@"Image Summary - Bill Pay" withImages:dictImages withResult:self.extractedError?self.extractedError.localizedDescription:self.resultsArray.description];
    [self cleanTheRawImages];
    dictImages = nil;
}

- (void)updateDateFomatteraWithLocale
{
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
}

//Method is used for gettting numberformatter based on device locale.
- (NSNumberFormatter*)getNumberFormatterOfLocale
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return numberFormatter;
}

// CollectionView Delegates
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewIdentifier" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor grayColor];
    
    UIImageView *thumbnail = [[UIImageView alloc]initWithFrame:collectionView.bounds];
    thumbnail.contentMode = UIViewContentModeScaleAspectFit;
    
    
    
    kfxKEDImage *frontProcessedImage = [self.appStateMachine getImage:indexPath.row?BACK_PROCESSED:FRONT_PROCESSED mimeType:MIMETYPE_TIF];
    UIImage *image = [frontProcessedImage getImageBitmap];
    
   /* float origSize = image.size.width;
    
    image = [self getScaledImage:image destSize:[self getSizeOfImageThumbnail:indexPath.row withHeight:collectionView.frame.size.height] fact:4.0];
    
    NSLog(@"--%@",NSStringFromCGSize(image.size));
    
    float scaledSize = image.size.width;
    
    float fact = scaledSize/origSize;
    
    // highlight the found RTTI Fields
    
    for (int i=0; i <self.keysArray.count; i ++)
    {
        ExtractInfo *info = self.keysArray[i];
        float left = info.coordinates.origin.x * fact;
        float top = info.coordinates.origin.y * fact;
        float width = info.coordinates.size.width * fact;
        float height = info.coordinates.size.height * fact;
        NSInteger pageIndex = info.pageIndex;
        
        if (indexPath.row == pageIndex)
        {
            
            if ((left >= 0) && (left <= image.size.width) && (top >= 0) && (top <= image.size.height))
            {
                if ((left + width) > image.size.width) {
                    width = image.size.width - left;
                }
                if ((top + height) > image.size.height) {
                    height = image.size.height - top;
                }
                
                @autoreleasepool {
                    
                    // begin a graphics context of sufficient size
                    UIGraphicsBeginImageContext(image.size);
                    
                    // draw original image into the context
                    [image drawAtPoint:CGPointZero];
                    
                    // create context
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    
                    // drawing with a white stroke color
                    CGContextSetRGBStrokeColor(context, 0.0, 255.0, 0.0, 0.5);
                    
                    // drawing with a white fill color
                    CGContextSetRGBFillColor(context, 0.0, 255.0, 0.0, 0.5);
                    
                    // Add Filled Rectangle,
                    CGContextFillRect(context, CGRectMake(left, top, width, height));
                    
                    //UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    
                    UIGraphicsEndImageContext();
                    
                    context = nil;
                    
                }
                
            }
        }
    }*/
    
    
    thumbnail.image = image;
    
    [cell.contentView addSubview:thumbnail];
    
    image = nil;
    
    return cell;
    
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width,collectionView.frame.size.height);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self previewButtonAction:nil];
}

/*// Get Size of thumbnail of image
-(CGSize)getSizeOfImageThumbnail:(NSInteger)index withHeight:(float)thumbnailSize
{
    kfxKEDImage *kedImage = [self.appStateMachine getImage:index?BACK_PROCESSED:FRONT_PROCESSED mimeType:MIMETYPE_TIF];
    UIImage *img= kedImage.getImageBitmap;
    float x = img.size.width;
    float y = img.size.height;
    
    img=nil;
    kedImage = nil;
    
    if (x>y) {
        float fact = y / x;
        return CGSizeMake( thumbnailSize,thumbnailSize *fact);
    } else {
        float fact = x / y;
        return CGSizeMake(thumbnailSize *fact,thumbnailSize);
    }
}

// Get ScaledImage
-(UIImage *)getScaledImage:(UIImage *)img destSize:(CGSize)destSize fact:(float)fact;
{
    
    //UIImage *tempImage = nil;
    
    CGSize scaledSize = CGSizeMake(destSize.width*fact, destSize.height*fact);
    
    UIGraphicsBeginImageContext(scaledSize);
    
    CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
    thumbnailRect.origin = CGPointMake(0.0,0.0);
    thumbnailRect.size.width  = scaledSize.width;
    thumbnailRect.size.height = scaledSize.height;
    
    [img drawInRect:thumbnailRect];
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
    
}*/

// Gesture for rttiScrollView
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return self.fieldView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
}
// create fields highlight view
-(void)createFieldsHighlightView:(NSInteger)fieldNumber
{
    
    // the fields Coordinates
    ExtractInfo *extractInfo = [self.keysArray objectAtIndex:fieldNumber];
    
    float left = extractInfo.coordinates.origin.x ;
    float top = extractInfo.coordinates.origin.y;
    float width = extractInfo.coordinates.size.width;
    float height = extractInfo.coordinates.size.height;
    if (width>0 && height>0) {
        self.imagesThumbnailCollectionView.hidden = TRUE;
        if (self.fieldsScrollView) { // Display the fields Scollview if already existing
            self.fieldsScrollView.hidden = FALSE;
        } else // create fields Scroll View
        {
            self.fieldsScrollView = [[UIScrollView alloc] initWithFrame:self.imagesThumbnailCollectionView.frame];
            self.fieldsScrollView.delegate = self;
        }
        
        if ((width < 0) || (height < 0)) // Leave if no width or height
        {
            return;
        }
        
        // Get the image
        kfxKEDImage *kedImage = [self.appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_TIF];
        UIImage *rttiImage = [kedImage getImageBitmap];
        
        if (self.fieldView) {
            self.fieldView = nil;
        }
        
        self.fieldView = [[UIImageView alloc] initWithImage:rttiImage];
        
        self.fieldView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=rttiImage.size};
        
        
        self.fieldView.userInteractionEnabled = TRUE;
        
        self.fieldView.backgroundColor = [UIColor clearColor];
        
        
        [self.view addSubview:self.fieldsScrollView];
        [self.fieldsScrollView addSubview:self.fieldView];
        
        
        // Tell the scroll view the size of the contents
        self.fieldsScrollView.contentSize = rttiImage.size;
        
        
        // Set up the minimum & maximum zoom scales
        
        CGRect scrollViewFrame = self.fieldsScrollView.frame;
        
        CGFloat scaleWidth = scrollViewFrame.size.width / self.fieldsScrollView.contentSize.width;
        
        self.fieldsScrollView.minimumZoomScale = scaleWidth; // min zoom is defined by the screen width (320)
        
        [self.fieldsScrollView setShowsHorizontalScrollIndicator:YES];
        [self.fieldsScrollView setShowsVerticalScrollIndicator:YES];
        self.fieldsScrollView.maximumZoomScale = 1.0f;
        
        self.fieldsScrollView.zoomScale = scaleWidth;
        
        //draw the highlight zone and move to the field
        if ((left >= 0) && (left <= rttiImage.size.width) && (top >= 0) && (top <= rttiImage.size.height))
        {
            if ((left + width) > rttiImage.size.width) {
                width = rttiImage.size.width - left;
            }
            if ((top + height) > rttiImage.size.height) {
                height = rttiImage.size.height - top;
            }
            
            // Draw the highlights
            
            CAShapeLayer *retangle = [CAShapeLayer layer];
            
            // Give the layer the same bounds as your image view
            [retangle setBounds:CGRectMake(0.0f, 0.0f, [self.fieldView bounds].size.width,
                                           [self.fieldView bounds].size.height)];
            
            // Position the rectangle anywhere you like, but this will center it
            // In the parent layer, which will be your image view's root layer
            [retangle setPosition:CGPointMake([self.fieldView bounds].size.width/2.0f,
                                              [self.fieldView bounds].size.height/2.0f)];
            // Create a rectangle path
            UIBezierPath *path = [UIBezierPath bezierPathWithRect: CGRectMake(left, top, width, height)];
            // Set the path on the layer
            [retangle setPath:[path CGPath]];
            // Set the stroke color
            [retangle setStrokeColor:[[[UIColor alloc] initWithRed:0.0 green:255.0 blue:0.0 alpha:0.5] CGColor]];
            
            //[retangle setOpacity:0.5];
            [retangle setFillColor:[[[UIColor alloc] initWithRed:0.0 green:255.0 blue:0.0 alpha:0.5] CGColor]];
            
            // Set the stroke line width
            [retangle setLineWidth:1.0f];
            
            // Add the sublayer to the image view's layer tree
            [[self.fieldView layer] addSublayer:retangle];
            
            // zoom to the field
            [self.fieldsScrollView zoomToRect:CGRectMake(left, top, width, height) animated:NO];
            
        }
    }else{
        self.imagesThumbnailCollectionView.hidden = FALSE;
    }
}



@end
