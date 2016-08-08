//
//  CDSummaryViewController.m
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 19/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import "CDSummaryViewController.h"
#import "CDSummaryDataSource.h"
#import "CheckHistoryManager.h"
#import "ChecksHistory.h"
#import "CheckInfoViewController.h"
#import "AppStateMachine.h"
#import <kfxLibLogistics/kfxLogistics.h>
#import "PersistenceManager.h"

#define INFO_NAME @"name"

@interface CDSummaryViewController ()<BaseSummaryCellProtocol,UIScrollViewDelegate>
{
    CDSummaryDataSource *dataSource;
}

@property (weak, nonatomic) IBOutlet UITableView *tblSummary;
@property(nonatomic,strong) NSMutableArray *extractionFields;
@property(nonatomic,strong) ExtractionFields *extractionResult;
@property (weak, nonatomic) IBOutlet UICollectionView *imagesThumbnailCollectionView;
@property (nonatomic, strong)AppStateMachine *appStats;
@property (nonatomic, strong) UIScrollView *fieldsScrollView;
@property (nonatomic, strong) UIImageView *fieldView;

@property (nonatomic,strong) NSMutableArray *appStatsFieldsArray;
@end

@implementation CDSummaryViewController

@synthesize extractionFields;
@synthesize extractionResult;
@synthesize tblSummary;
@synthesize imagesThumbnailCollectionView;
@synthesize fieldsScrollView;
@synthesize fieldView;

@synthesize appStatsFieldsArray;


-(void)dealloc{
    self.tblSummary.delegate = nil;
    self.tblSummary.dataSource = nil;
    self.imagesThumbnailCollectionView.dataSource = nil;
    self.imagesThumbnailCollectionView.delegate = nil;
    self.imagesThumbnailCollectionView = nil;
    self.appStats = nil;
    self.extractionResult = nil;
    self.extractionFields = nil;
    self.fieldView = nil;
    self.fieldsScrollView.delegate = nil;
    self.fieldsScrollView = nil;
    self.checkResults = nil;
    self.componentObject = nil;

    for (kfxKLOField *tempField in self.appStatsFieldsArray) {
        
        kfxKLOField *tempField1 = tempField;
        tempField1 = nil;
    }
    self.appStatsFieldsArray = nil;

}



- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.appStats = [AppStateMachine sharedInstance];
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    self.navigationItem.rightBarButtonItem = [AppUtilities getInfoButtonItemWithTarget:self andAction:@selector(btnInfoTouchUpInside:)];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = Klm(@"Check Information");

    [self getExtractionInfo];
    [self removeNonEditableFields];

    dataSource = [[CDSummaryDataSource alloc] initWithResult:self.extractionFields withComponent:self.componentObject];
    dataSource.delegate = self;
    self.tblSummary.dataSource = dataSource;
    
    self.imagesThumbnailCollectionView.dataSource = dataSource;
    self.imagesThumbnailCollectionView.delegate = dataSource;
    
    [self.imagesThumbnailCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewIdentifier"];
    
    self.appStatsFieldsArray = [[NSMutableArray alloc] init];
    [self recordAppStatsForCD:-1];
    
    //blur the view when app goes into background
    [self createViewBlurInBackground];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)getExtractionInfo
{
    self.extractionResult = [[ExtractionFields alloc] initWithSettings:self.componentObject.settings.settingsDictionary componentType:self.componentObject.type withExtractionResult:_checkResults];
    self.extractionFields = self.extractionResult.extractionFields[@"checkArray"];
}

-(void)removeNonEditableFields{
    for (int index = (int)([self.extractionFields count]-1); index>=0; index--) {
        ExtractInfo *info = [self.extractionFields objectAtIndex:index];
        if(!([info.name isEqualToString:@"Amount"] ||
           [info.name isEqualToString:@"Routing No."] ||
           [info.name isEqualToString:@"Account No."] ||
           [info.name isEqualToString:@"Date"] ||
           [info.name isEqualToString:@"Check Number"] ||
           [info.name isEqualToString:@"Payee name"]
           )){
            [self.extractionFields removeObjectAtIndex:index];
        }
    }
}

-(void)recordAppStatsForCD:(NSInteger)fieldIndex{
    
    if(!self.appStatsFieldsArray){
        
        self.appStatsFieldsArray = [[NSMutableArray alloc] init];
    }
    
    if([self.appStatsFieldsArray count] == 0){
        
        for (ExtractInfo *info in self.extractionFields) {
            if([info.name isEqualToString:@"Amount"] ||
               [info.name isEqualToString:@"Routing No."] ||
               [info.name isEqualToString:@"Account No."] ||
               [info.name isEqualToString:@"Date"] ||
               [info.name isEqualToString:@"Check Number"] ||
               [info.name isEqualToString:@"Payee name"]
               ){
                kfxKLOField *individualField = [[kfxKLOField alloc] init];
                [individualField updateFieldProperties:info.value andIsValid:YES andErrorDescription:nil];
                [self.appStatsFieldsArray addObject:individualField];
            }
        }
    }
    else{
        
        BaseSummaryCell *cell = [self.tblSummary cellForRowAtIndexPath:[NSIndexPath indexPathForRow:fieldIndex inSection:0]];
        
        int index;
        if([cell.info.name isEqualToString:@"Amount"]){
            index = 0;
        }
        else if([cell.info.name isEqualToString:@"Routing No."]){
            index = 1;
        }
        else if([cell.info.name isEqualToString:@"Account No."]){
            index = 2;
        }
        else if([cell.info.name isEqualToString:@"Date"]){
            index = 3;
        }
        else if([cell.info.name isEqualToString:@"Check Number"]){
            index = 4;
        }
        else if([cell.info.name isEqualToString:@"Payee name"]){
            index = 5;
        }
        kfxKLOField *tempField = [self.appStatsFieldsArray objectAtIndex:index];
        NSString *oldValue = tempField.value;
        NSString *newValue = cell.info.value;
        if(![newValue isEqualToString:oldValue]){
            [tempField updateFieldProperties:newValue andIsValid:YES andErrorDescription:nil];
            [self updateCorrections:cell.info.name andValue:newValue];
        }
    }
    
}

-(void)updateCorrections:(NSString *)key andValue:(NSString *)value
{
    NSMutableArray *arrUpdatedCheckResults = [[NSMutableArray alloc] init];
    
    for (NSDictionary *result in [PersistenceManager getCheckInformation]) {
        @autoreleasepool {
            NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithDictionary:result];
            [arrUpdatedCheckResults addObject:mutableDict];
        }
    }
    
    for (NSMutableDictionary *dictResult in arrUpdatedCheckResults) {
        
        if ([key caseInsensitiveCompare:AMOUNT] == NSOrderedSame && [[dictResult objectForKey:INFO_NAME] isEqualToString:@"A2iA_CheckAmount"]) {
            NSNumberFormatter *numberFormatter = [AppUtilities getNumberFormatterOfLocaleBasedOnCountryCode:self.countryCode];
            NSString *formattedAmount = [numberFormatter stringFromNumber:[numberFormatter numberFromString:value]];
            [dictResult setValue:formattedAmount forKey:INFO_TEXT];
            break;
            
        }else if([key caseInsensitiveCompare:Klm(@"Routing No.")] == NSOrderedSame &&[[dictResult objectForKey:INFO_NAME] isEqualToString:@"A2iA_CheckCodeline_Transit"]){
            [dictResult setValue:value forKey:INFO_TEXT];
            break;
            
        }else if([key caseInsensitiveCompare:Klm(@"Account No.")] == NSOrderedSame && [[dictResult objectForKey:INFO_NAME] isEqualToString:@"A2iA_CheckCodeline_OnUs1"]){
            [dictResult setValue:value forKey:INFO_TEXT];
            break;
            
        }else if([key caseInsensitiveCompare:Klm(@"Date")] == NSOrderedSame && [[dictResult objectForKey:INFO_NAME] isEqualToString:@"A2iA_CheckDate"]){
            
            NSDateFormatter *dateFormat = [AppUtilities getDateFormatterOfLocale];
            NSDate *date = [dateFormat dateFromString:value];
            [dateFormat setDateFormat:INFO_DATE_FORMAT];
            NSString *strDate = [dateFormat stringFromDate:date];
            [dictResult setValue:strDate forKey:INFO_TEXT];
            
            break;
            
        }else if([key caseInsensitiveCompare:Klm(@"Check Number")] == NSOrderedSame && [[dictResult objectForKey:INFO_NAME] isEqualToString:@"A2iA_CheckNumber"]){
            [dictResult setValue:value forKey:INFO_TEXT];
            break;
            
        }else if([key caseInsensitiveCompare:Klm(@"Payee name")] == NSOrderedSame && [[dictResult objectForKey:INFO_NAME] isEqualToString:@"A2iA_CheckPayeeName"]){
            [dictResult setValue:value forKey:INFO_TEXT];
            break;
        }
    }
    
    [PersistenceManager storeCheckInformation:arrUpdatedCheckResults];
    
    arrUpdatedCheckResults = nil;
    
}

-(void)updateTextFieldChanges:(UITextField *)textField
{
    
    ExtractInfo *info = [self.extractionFields objectAtIndex:textField.tag];
    
    if ([info.name isEqualToString:@"Amount"]) {
        
        //checking entered amount is valid/invalid.
        
        if ([self isAmountValid:textField.text]) {
            NSNumberFormatter *numberFormatter = [AppUtilities getNumberFormatterOfLocaleBasedOnCountryCode:self.countryCode];
            NSString *formattedAmount = [numberFormatter stringFromNumber:[numberFormatter numberFromString:textField.text]];
            textField.text = formattedAmount;
            info.value = formattedAmount;
            [self updateValueForCell:[self.tblSummary cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]]];
            [self recordAppStatsForCD:textField.tag];
            
        }
        else {
            if (!self.backButtonClicked) {
                [textField becomeFirstResponder];
                [self showInvalidAmountAlert];
            }
        }
    }
    else {
        info.value = textField.text;
        [self updateValueForCell:[self.tblSummary cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]]];
        [self recordAppStatsForCD:textField.tag];
    }
    
    [AppUtilities reduceFontOfTextField:textField];
}

//Method is used for checking enterd amount is valid or not.

- (BOOL)isAmountValid:(NSString*)amount
{
    NSNumberFormatter *numberFormatter = [AppUtilities getNumberFormatterOfLocaleBasedOnCountryCode:self.countryCode];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnInfoTouchUpInside:(id)sender {
    CheckInfoViewController *checkInfoVC = [[CheckInfoViewController alloc] initWithNibName:@"CheckInfoViewController" bundle:nil];;
//    checkInfoVC.countryCode = self.countryCode;
    checkInfoVC.checkResults = self.checkResults;
    checkInfoVC.componentObject = self.componentObject;
    [self.navigationController pushViewController:checkInfoVC animated:YES];
}

-(void)didFinishEditing
{
    [self.tblSummary setContentOffset:CGPointZero animated:YES];
}

-(void)selectedCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
//    CGRect  rect = cell.frame;
//    [self.tblSummary setContentOffset:CGPointMake(0, rect.origin.y-rect.size.height) animated:YES];
//    NSLog(@"%@",cell);
    if (indexPath.row!=0) {
        CGRect  rect = [self.tblSummary rectForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row  inSection:0]];
        [self.tblSummary setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BaseSummaryCell *cell = [self.tblSummary cellForRowAtIndexPath:indexPath];
    [cell beginEditing];
}

-(UIToolbar *)toolBarForIndexPath:(NSIndexPath *)indexPath
{
    AppUtilities *utilitiesObject = [[AppUtilities alloc] init];
    
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    [toolBar setBarTintColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor]];
    [toolBar sizeToFit];
    
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:Klm(@"Previous"),Klm(@"Next"), nil]];
    segmentControl.tintColor = [utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.buttonTextColor];
    [segmentControl addTarget:self action:@selector(segmentControlAction:) forControlEvents:UIControlEventValueChanged];
    segmentControl.momentary = YES;
    segmentControl.tag = indexPath.row;
    
    if (indexPath.row == 0) {
        [segmentControl setEnabled:NO forSegmentAtIndex:0];
    }else if(indexPath.row == self.extractionFields.count-1){
        [segmentControl setEnabled:NO forSegmentAtIndex:1];
    }
    
    UIBarButtonItem *prevNextButtonItem = [[UIBarButtonItem alloc]initWithCustomView:segmentControl];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]initWithTitle:Klm(@"Done") style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
    doneButton.tintColor = [utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.buttonTextColor];
    [toolBar setItems:[NSArray arrayWithObjects:prevNextButtonItem,spacer,doneButton, nil]];
    
    utilitiesObject = nil;
    
    return toolBar;
}

-(void)doneButtonAction:(UIBarButtonItem*)doneButtonItem{
    [self.view endEditing:YES];
    [self.tblSummary setContentOffset:CGPointZero animated:YES];
}

-(void)segmentControlAction:(UISegmentedControl*)segmentControl{
    if (segmentControl.selectedSegmentIndex == 0) {
        CGRect size = [self.tblSummary rectForRowAtIndexPath:[NSIndexPath indexPathForRow:segmentControl.tag-1 inSection:0]];
        [self.tblSummary setContentOffset:CGPointMake(0, size.origin.y) animated:YES];
        [self.tblSummary reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:segmentControl.tag-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        BaseSummaryCell *cell = [self.tblSummary cellForRowAtIndexPath:[NSIndexPath indexPathForRow:segmentControl.tag-1 inSection:0]];
        [cell beginEditing];
    }else{
        BaseSummaryCell *currentCell = [self.tblSummary cellForRowAtIndexPath:[NSIndexPath indexPathForRow:segmentControl.tag inSection:0]];
        if (segmentControl.tag == 0 && ![self isAmountValid:currentCell.info.value]) {
            [self showInvalidAmountAlert];
        }else{
            BaseSummaryCell *nextCell = [self.tblSummary cellForRowAtIndexPath:[NSIndexPath indexPathForRow:segmentControl.tag+1 inSection:0]];
            [nextCell beginEditing];
        }
    }
}

-(UIDatePicker *)datePickerForIndexPath:(NSIndexPath *)indexPath
{
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    datePicker.tintColor = [self themeColor];
    return datePicker;
}

-(UIPickerView *)pickerViewForIndexPath:(NSIndexPath *)indexPath
{
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.tintColor = [self themeColor];
    return pickerView;
}

-(UIColor *)themeColor
{
    return [[[AppUtilities alloc] init]  colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
}


#pragma mark- Picker View Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell
{
    ExtractInfo *info = self.extractionFields[indexpath.row];
    return info.options.count;
}


- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell
{
    ExtractInfo *info = self.extractionFields[indexpath.row];
    return info.options[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell
{
    ExtractInfo *info = self.extractionFields[indexpath.row];
    info.value = info.options[row];
    [self updateChangesForCell:cell];
}

// datePicker delegate
-(void)datePicker:(UIDatePicker*)sender forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    dateFormat = [AppUtilities getDateFormatterOfLocale];
    ExtractInfo *info = self.extractionFields[indexpath.row];
    info.value = [dateFormat stringFromDate:sender.date];
    dateFormat = nil;
    [self updateChangesForCell:cell];
    [self recordAppStatsForCD:indexpath.row];
}


// Gesture for rttiScrollView
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return self.fieldView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
}



// textField Delegates Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell
{
    [self selectedCell:cell atIndexPath:indexpath];
    textField.tag = indexpath.row;
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell{
    if([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:HIGHLIGHTSWITCH] boolValue])
    {
        
        if([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:HIGHLIGHTDATA] boolValue]){
            
            [self createFieldsHighlightView:indexpath.row];
        }
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell
{
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
            self.imagesThumbnailCollectionView.hidden = FALSE;
        }
    }
    
    
    [self updateTextFieldChanges:textField];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell{
    BaseSummaryCell *presentCell = (BaseSummaryCell*)cell;
    if ([presentCell.info.name isEqualToString:@"Amount"]) {
        AppUtilities *appUtilitiesObj = [[AppUtilities alloc] init];
        
        //For french/german launguages currency will be seperated by "," string so we should allow "," from keyboard
        
        if(![appUtilitiesObj isAllDigits:string] && ![string isEqualToString:@"."] && ![string isEqualToString:@","]){
            return NO;
        }
        
        if (range.length==1 && string.length == 0) {
            presentCell.info.value = [presentCell.info.value substringToIndex:presentCell.info.value.length-1];
        }else{
            presentCell.info.value = [NSString stringWithFormat:@"%@%@",textField.text,string];
        }
        
        appUtilitiesObj = nil;
        
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField forIndexPath:(NSIndexPath *)indexpath cell:(UITableViewCell *)cell
{
    [textField resignFirstResponder];
    [self.tblSummary setContentOffset:CGPointZero animated:YES];
    return YES;
}

-(void)updateChangesForCell:(UITableViewCell *)cell
{
    BaseSummaryCell *baseCell = (BaseSummaryCell *)cell;
    [baseCell updateChanges];
}

-(void)updateValueForCell:(UITableViewCell *)cell
{
    BaseSummaryCell *baseCell = (BaseSummaryCell *)cell;
    [baseCell updateValue];
}

// create fields highlight view
-(void)createFieldsHighlightView:(NSInteger)fieldNumber
{
    
    // the fields Coordinates
    ExtractInfo *extractInfo = [extractionFields objectAtIndex:fieldNumber];
    
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
            fieldsScrollView.delegate = self;
        }
        
        if ((width < 0) || (height < 0)) // Leave if no width or height
        {
            return;
        }
        
        // Get the image
        kfxKEDImage *kedImage = [self.appStats getImage:FRONT_PROCESSED mimeType:MIMETYPE_TIF];
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
