//
//  CameraSettingsViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/16/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "CameraSettingsViewController.h"
#import "ProfileManager.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface CameraSettingsViewController ()
{
    int isAnimatedCameraSelected;
    UITextField *selectedTextField;
}
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, strong)  UITextField *offsetThresholdField,*stabilityDelayField,*pitchThresholdField,*rollThresholdField,*manualCaptureTimeField,*aspectRatioField;



@property (nonatomic, strong) UISwitch  *showGallerySwitch,*autoTorchSwitch, *guidingDemoSwitch;
@property (nonatomic, strong) UISegmentedControl *captureTypeSegment, *edgeDetectionSegment;
@property (nonatomic, assign) Settings* settings;
@property (nonatomic, strong) NSMutableDictionary *cameraSettings;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic, assign) Component *componentObject;
@end

@implementation CameraSettingsViewController
@synthesize tableTopConstraint;
@synthesize cameraSettings;
@synthesize offsetThresholdField,stabilityDelayField,pitchThresholdField,rollThresholdField,manualCaptureTimeField,aspectRatioField;

@synthesize showGallerySwitch,autoTorchSwitch, guidingDemoSwitch;
@synthesize captureTypeSegment;
@synthesize table;
@synthesize edgeDetectionSegment;


-(void)dealloc{
    
    self.offsetThresholdField.delegate = nil;
    self.offsetThresholdField = nil;
    self.stabilityDelayField.delegate = nil;
    self.stabilityDelayField = nil;
    self.pitchThresholdField.delegate = nil;
    self.pitchThresholdField = nil;
    self.rollThresholdField.delegate = nil;
    self.rollThresholdField = nil;
    self.manualCaptureTimeField.delegate = nil;
    self.manualCaptureTimeField = nil;
    self.aspectRatioField.delegate =nil;
    self.aspectRatioField = nil;
    self.autoTorchSwitch=nil;
    self.captureTypeSegment = nil;
    self.cameraSettings = nil;
    self.edgeDetectionSegment = nil;

}

#pragma mark Constructor Methods
-(id)initWithSettings: (Settings*)settings andComponent:(Component*)componentObj{
    if(self = [super init])
    {
        self.settings = settings;
        self.cameraSettings = [[self.settings.settingsDictionary valueForKey:CAMERASETTINGS] mutableCopy];
        NSLog(@"Component type is %@", self.componentObject);
        self.componentObject = componentObj;
        
    }
    
    return self;
}

#pragma mark ViewLifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant +=20;
    }else{
        self.tableTopConstraint.constant -=42;
    }
    self.navigationItem.title = Klm(@"Camera Settings");
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    isAnimatedCameraSelected = [[cameraSettings valueForKey:CAPTUREEXPERIENCE] intValue];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.offsetThresholdField.delegate = nil;
    self.stabilityDelayField.delegate = nil;
    self.pitchThresholdField.delegate = nil;
    self.rollThresholdField.delegate = nil;
    self.aspectRatioField.delegate = nil;
    self.manualCaptureTimeField.delegate = nil;
    

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
    
    if (section == 1) {
        return 1; // For Reset Option
    }
    
    return [[self.cameraSettings allKeys]count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    static NSString *identifier = @"cellIdentifier" ;
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.section==0 && indexPath.row==1) {
        
        self.showGallerySwitch = [AppUtilities createSwitchWithTag:(int)indexPath.row andValue:[cameraSettings valueForKey:SHOWGALLERY]];
        [self.showGallerySwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = self.showGallerySwitch;
        
    }
    else if (indexPath.section==0 && indexPath.row==2) {
        
        self.offsetThresholdField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 50, 25) placeholder:@"" andText:[NSString stringWithFormat:@"%@",[cameraSettings valueForKey:OFFSETTHRESHOLD]]];
        self.offsetThresholdField .keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.offsetThresholdField .delegate = self;
        cell.accessoryView = self.offsetThresholdField;
    }
    else if (indexPath.section==0 && indexPath.row==3) {
        
        self.stabilityDelayField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 50, 25) placeholder:@"" andText:[NSString stringWithFormat:@"%@",[cameraSettings valueForKey:STABILITYDELAY]]];
        self.stabilityDelayField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.stabilityDelayField.delegate = self;
        cell.accessoryView = self.stabilityDelayField;
    }
    else if (indexPath.section==0 && indexPath.row==4) {
        
        self.pitchThresholdField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 50, 25) placeholder:@"" andText:[NSString stringWithFormat:@"%@",[cameraSettings valueForKey:PITCHTHRESHOLD]]];
        self.pitchThresholdField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.pitchThresholdField.delegate = self;
        cell.accessoryView = self.pitchThresholdField;
    }
    else if (indexPath.section==0 && indexPath.row==5) {
        
        self.rollThresholdField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 50, 25) placeholder:@"" andText:[NSString stringWithFormat:@"%@",[cameraSettings valueForKey:ROLLTHRESHOLD]]];
        self.rollThresholdField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.rollThresholdField.delegate = self;
        cell.accessoryView = self.rollThresholdField;
    }
    else if(indexPath.section == 0 && indexPath.row == 0){
        
       //Now we are moving capture experience type title to section header, so we are not showing any title in first row.
    }
    else if (indexPath.section==0 && indexPath.row==6) {
        
        self.manualCaptureTimeField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 50, 25) placeholder:@"" andText:[NSString stringWithFormat:@"%@",[cameraSettings valueForKey:MANUALCAPTURETIMER]]];
        self.manualCaptureTimeField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.manualCaptureTimeField.delegate = self;
        
        cell.accessoryView = self.manualCaptureTimeField;
    }
    else if (indexPath.section==0 && indexPath.row==7) {
        
        self.autoTorchSwitch = [AppUtilities createSwitchWithTag:(int)indexPath.row andValue:[cameraSettings valueForKey:AUTOTORCH]];
        [self.autoTorchSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = self.autoTorchSwitch;
    }
    else if (indexPath.section==0 && indexPath.row==8) {
        
        NSArray* itemsArray = @[Klm(@"ISG"), Klm(@"GPU")];
        self.edgeDetectionSegment = [AppUtilities createSegmentedControlWithTag:0 items:itemsArray andSelectedSegment:[[cameraSettings valueForKey:EDGEDETECTION]intValue]];
        [self.edgeDetectionSegment addTarget:self action:@selector(edgeDetectionSwitchAction:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = self.edgeDetectionSegment;
        
    }
    else if (indexPath.section==0 && indexPath.row==9) {
        
        //Adding switch for showing tutorial image for each component.
        
        self.guidingDemoSwitch = [AppUtilities createSwitchWithTag:(int)indexPath.row andValue:[cameraSettings valueForKey:SHOWGUIDINGDEMO]];
        [self.guidingDemoSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = self.guidingDemoSwitch;
    }
    else if (indexPath.section==0 && indexPath.row==10) {
        
        self.aspectRatioField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 50, 25) placeholder:@"" andText:[NSString stringWithFormat:@"%.2f",[[cameraSettings valueForKey:FRAMEASPECTRATIO]floatValue]]];
       
        //Converting "US" format aspect ratio into device locale format.

        NSNumberFormatter *numberFormatter = [self getNumberFormatterOfLocale];
        NSString *formattedAmount = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[[cameraSettings valueForKey:FRAMEASPECTRATIO]floatValue]]];
        self.aspectRatioField.text = formattedAmount;
        
        self.aspectRatioField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.aspectRatioField.delegate = self;
        
        cell.accessoryView = self.aspectRatioField;
    }
    else if (indexPath.section==0 && indexPath.row==11) {
        
        self.captureTypeSegment = [AppUtilities createSegmentedControlWithTag:0 items:[NSArray arrayWithObjects:Klm(@"Image"), Klm(@"Video"), nil] andSelectedSegment:[[cameraSettings valueForKey:CAPTURETYPE]intValue]];
        [self.captureTypeSegment addTarget:self action:@selector(captureExperienceSwitchAction:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = self.captureTypeSegment;
        
    }else if(indexPath.section==1){
        
        UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [resetBtn setTitle:Klm(@"Reset") forState:UIControlStateNormal];
        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        [resetBtn setTitleColor:[utilitiesObject colorWithHexString:self.themeObject.buttonTextColor] forState:UIControlStateNormal];
        [resetBtn setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:self.themeObject.buttonColor] withTheme:self.themeObject] forState:UIControlStateNormal];
        utilitiesObject = nil;
        [resetBtn addTarget:self action:@selector(resetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [resetBtn setFrame:CGRectMake(20, 10, [[UIScreen mainScreen]bounds].size.width-40, 40)];
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:resetBtn];
    }

    if (indexPath.section==0 && indexPath.row<[self.table numberOfRowsInSection:0]-1 && indexPath.row != 0) {
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(15, indexPath.row==0?69.5f:43.5f, [[UIScreen mainScreen]bounds].size.width-15, 1)];
        line.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
        [cell.contentView addSubview:line];
    }
    
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
    
    
    if(indexPath.section==0 && indexPath.row==1){
        
        cell.textLabel.text = Klm(@"Show Gallery:");
    }
    else if(indexPath.section==0 && indexPath.row==2){
        
        cell.textLabel.text = [[[[[Klm(@"Offset Threshold") stringByAppendingString:@" ("] stringByAppendingString:@"0 " ] stringByAppendingString:Klm(@"-")] stringByAppendingString:@" 100"]stringByAppendingString:@") :"];
        
        if (isAnimatedCameraSelected==0){
            
            if (self.componentObject.type != CUSTOM) { //Enabling user input for custom component only
                [self disableLabel:cell.textLabel iosSwitch:nil andTextField:self.offsetThresholdField];
            }
        }
    }
    else if(indexPath.section==0 && indexPath.row==3){
        
      cell.textLabel.text = [[[[[Klm(@"Stability Delay") stringByAppendingString:@" ("] stringByAppendingString:@"0 " ] stringByAppendingString:Klm(@"-")] stringByAppendingString:@" 100"]stringByAppendingString:@") :"];
    }
    else if(indexPath.section==0 && indexPath.row==4){
        
        cell.textLabel.text = [[[[[Klm(@"Pitch Threshold") stringByAppendingString:@" ("] stringByAppendingString:@"0 " ] stringByAppendingString:Klm(@"-")] stringByAppendingString:@" 45"]stringByAppendingString:@") :"];
    }
    else if(indexPath.section==0 && indexPath.row==5){
        
         cell.textLabel.text = [[[[[Klm(@"Roll Threshold") stringByAppendingString:@" ("] stringByAppendingString:@"0 " ] stringByAppendingString:Klm(@"-")] stringByAppendingString:@" 45"]stringByAppendingString:@") :"];
    }
    else if(indexPath.section==0 && indexPath.row==6){
        
         cell.textLabel.text = [[[[[Klm(@"Manual Capture Time") stringByAppendingString:@" ("] stringByAppendingString:@"0 " ] stringByAppendingString:Klm(@"-")] stringByAppendingString:@" 100"]stringByAppendingString:@") :"];
    }
    else if(indexPath.section==0 && indexPath.row==7){
        
        cell.textLabel.text = Klm(@"Auto Torch:");
        if (![AppUtilities isFlashAvailable]) {
            [self disableLabel:cell.textLabel iosSwitch:self.autoTorchSwitch andTextField:nil];
        }
    }
    else if(indexPath.section==0 && indexPath.row==8){
        
        cell.textLabel.text = Klm(@"Edge Detection:");
        if (self.componentObject.type == CHECKDEPOSIT)
        {
            self.edgeDetectionSegment.enabled = NO;
            cell.textLabel.enabled = NO;
        }
    }
    else if(indexPath.section==0 && indexPath.row==9){
        cell.textLabel.text = Klm(@"Show Guiding Demo:");
    }

    else if(indexPath.section==0 && indexPath.row==10){
        
        if (self.componentObject.type != CUSTOM || [self.componentObject.subType isEqualToString:@"Passport"]) {  //Enabling user input for custom component only
            [self disableLabel:cell.textLabel iosSwitch:nil andTextField:self.aspectRatioField];
        }
        cell.textLabel.text = Klm(@"Frame Aspect Ratio:");
    }
    if(indexPath.section==0 && indexPath.row==11){
        
        cell.textLabel.text = Klm(@"Capture Type:");
    }

    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.section == 0 && indexPath.row == 0){
        return 0.0;                         //Now we are moving capture experience type title to section header, so first row height will be zero.
    }
    return 44;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (0 == section) {     //Need to show capture type in section header.
        
        if(self.componentObject.type == CHECKDEPOSIT){
            
            return Klm(@"Check Animation");
        }
        else {
            
            return Klm(@"Uniform Guidance");
            
        }
    }
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UITextField *textField = (UITextField*)cell.accessoryView;
    
    if(textField){
        
        [textField becomeFirstResponder];
    }
    
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [selectedTextField resignFirstResponder];
}

#pragma mark UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    AppUtilities *appUtilitiesObj = [[AppUtilities alloc] init];
    
    //For french/german launguages currency will be seperated by "," string so we should allow "," from keyboard
    
    if(![appUtilitiesObj isAllDigits:string] && ![string isEqualToString:@"."] && ![string isEqualToString:@","]){
        return NO;
    }
    return YES;
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    selectedTextField = textField;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    CGRect  rect = CGRectZero;
    
    if (textField==self.offsetThresholdField) {
        rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    }
    else if(textField==self.stabilityDelayField){
        rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    }
    else if(textField==self.pitchThresholdField){
        rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    }
    else if(textField==self.rollThresholdField){
        rect = [self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    }
    else if(textField==self.manualCaptureTimeField){
        rect = [self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
    }
    else if(textField==self.aspectRatioField){
        rect = [self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:7 inSection:0]];
    }
    
    [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];

}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    // [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    if([textField isEqual:self.offsetThresholdField])
    {
        if([textField.text intValue] < 0 || [textField.text intValue] > 100)
        {
            textField.text = [NSString stringWithFormat:@"%d",100];
        }
        [self.cameraSettings setValue:[NSNumber numberWithInt:[textField.text intValue]] forKey:OFFSETTHRESHOLD];
    }
    else if([textField isEqual:self.stabilityDelayField])
    {
        if([textField.text intValue] < 0 || [textField.text intValue] > 100)
        {
            textField.text = [NSString stringWithFormat:@"%d",100];
        }
        [self.cameraSettings setValue:[NSNumber numberWithInt:[textField.text intValue]] forKey:STABILITYDELAY];
    }
    else if([textField isEqual:self.pitchThresholdField])
    {
        if([textField.text intValue] < 0 || [textField.text intValue] > 45)
        {
            textField.text = [NSString stringWithFormat:@"%d",45];
        }
        [self.cameraSettings setValue:[NSNumber numberWithInt:[textField.text intValue]] forKey:PITCHTHRESHOLD];
    }
    else if([textField isEqual:self.rollThresholdField])
    {
        
        if([textField.text intValue] < 0 || [textField.text intValue] > 45)
        {
            textField.text = [NSString stringWithFormat:@"%d",45];
        }
        [self.cameraSettings setValue:[NSNumber numberWithInt:[textField.text intValue]] forKey:ROLLTHRESHOLD];
    }
    else if([textField isEqual:self.manualCaptureTimeField]){
        
        if([textField.text intValue] < 0 || [textField.text intValue] > 100)
        {
            textField.text = [NSString stringWithFormat:@"%d",10];
        }
        [self.cameraSettings setValue:[NSNumber numberWithInt:[textField.text intValue]] forKey:MANUALCAPTURETIMER];
    }
    else if([textField isEqual:self.aspectRatioField]){
        NSNumberFormatter *numberFormatter = [self getNumberFormatterOfLocale];
        NSNumber *number = [numberFormatter numberFromString:textField.text];
        if (number != nil) {
            
            //Converting aspect ratio back to US number format.
            
            NSNumberFormatter *usNumberFormatter = [self getUSNumberFormatter];
            NSString *numberString = [usNumberFormatter stringFromNumber:number];
            [self.cameraSettings setValue:[NSNumber numberWithFloat:[numberString floatValue]] forKey:FRAMEASPECTRATIO];
        }
    }
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    if([textField isEqual:self.offsetThresholdField])
    {
        if([textField.text intValue] < 0 || [textField.text intValue] > 100)
        {
            textField.text = [NSString stringWithFormat:@"%d",100];
        }
        [self.cameraSettings setValue:[NSNumber numberWithInt:[textField.text intValue]] forKey:OFFSETTHRESHOLD];
    }
    else if([textField isEqual:self.stabilityDelayField])
    {
        if([textField.text intValue] < 0 || [textField.text intValue] > 100)
        {
            textField.text = [NSString stringWithFormat:@"%d",100];
        }
        [self.cameraSettings setValue:[NSNumber numberWithInt:[textField.text intValue]] forKey:STABILITYDELAY];
    }
    else if([textField isEqual:self.pitchThresholdField])
    {
        if([textField.text intValue] < 0 || [textField.text intValue] > 45)
        {
            textField.text = [NSString stringWithFormat:@"%d",45];
        }
        [self.cameraSettings setValue:[NSNumber numberWithInt:[textField.text intValue]] forKey:PITCHTHRESHOLD];
    }
    else if([textField isEqual:self.rollThresholdField])
    {
        
        if([textField.text intValue] < 0 || [textField.text intValue] > 45)
        {
            textField.text = [NSString stringWithFormat:@"%d",45];
        }
        [self.cameraSettings setValue:[NSNumber numberWithInt:[textField.text intValue]] forKey:ROLLTHRESHOLD];
    }else if([textField isEqual:self.manualCaptureTimeField]){
        
        if([textField.text intValue] < 0 || [textField.text intValue] > 100)
        {
            textField.text = [NSString stringWithFormat:@"%d",10];
        }
        [self.cameraSettings setValue:[NSNumber numberWithInt:[textField.text intValue]] forKey:MANUALCAPTURETIMER];
    }
    else if([textField isEqual:self.aspectRatioField]){
        NSNumberFormatter *numberFormatter = [self getNumberFormatterOfLocale];
        NSNumber *number = [numberFormatter numberFromString:textField.text];
        if (number != nil) {
            
            //Converting aspect ratio back to US number format.
            
            NSNumberFormatter *usNumberFormatter = [self getUSNumberFormatter];
            NSString *numberString = [usNumberFormatter stringFromNumber:number];
            [self.cameraSettings setValue:[NSNumber numberWithFloat:[numberString floatValue]] forKey:FRAMEASPECTRATIO];
        }
    }
    return YES;
}

#pragma mark Local Methods

-(void)disableLabel:(UILabel*)label iosSwitch:(UISwitch*)swich andTextField:(UITextField*)textField{
    if (label) {
        label.enabled = NO;
    }
    if (swich) {
        swich.enabled = NO;
    }
    if (textField) {
        textField.enabled = NO;
        textField.textColor = [UIColor lightGrayColor];
    }
}
/*
 This method is used to show the alert.
 @param: message.
 */
-(void)showAlert:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
    [alert show];
}
/*
 This method is used to go back to the previous screen and also save the camera settings.
 */
-(IBAction)backButtonAction:(id)sender{

    [self.settings.settingsDictionary setValue:self.cameraSettings forKey:CAMERASETTINGS];
    [[ProfileManager sharedInstance] updateProfile:[[ProfileManager sharedInstance]getActiveProfile]];
    [self.navigationController popViewControllerAnimated:YES];
  
}

/*
 This method is called when the switch value is changed.
 */
-(IBAction)switchValueChanged:(UISwitch*)sender{
   
    if (sender == self.autoTorchSwitch) {
        [self.cameraSettings setValue:[NSNumber numberWithBool:sender.on] forKey:AUTOTORCH];
    }
    else if(sender == self.showGallerySwitch){
        [self.cameraSettings setValue:[NSNumber numberWithBool:sender.on] forKey:SHOWGALLERY];
    }
    else if(sender == self.guidingDemoSwitch) {
        [self.cameraSettings setValue:[NSNumber numberWithBool:sender.on] forKey:SHOWGUIDINGDEMO];
    }
}

/*
This method is called when the capture experience value is changed.
*/

-(IBAction)captureExperienceSwitchAction:(UISegmentedControl*)sender{
    
    if (sender == self.captureTypeSegment) {
        [self.cameraSettings setValue:[NSNumber numberWithInteger:sender.selectedSegmentIndex] forKey:CAPTURETYPE];
    }
    
    [self.table reloadData];
}

-(IBAction)edgeDetectionSwitchAction:(UISegmentedControl*)sender{
    
    if (sender == self.edgeDetectionSegment) {
        [self.cameraSettings setValue:[NSNumber numberWithInteger:sender.selectedSegmentIndex] forKey:EDGEDETECTION];
    }
    
    [self.table reloadData];
}


-(IBAction)resetButtonAction:(id)sender{
    
    [self.cameraSettings setValue:[NSNumber numberWithInteger:0] forKey:CAPTUREEXPERIENCE];
    [self.cameraSettings setValue:[NSNumber numberWithInt:15] forKey:PITCHTHRESHOLD];
    [self.cameraSettings setValue:[NSNumber numberWithInt:15] forKey:ROLLTHRESHOLD];
    [self.cameraSettings setValue:[NSNumber numberWithBool:false] forKey:SHOWGALLERY];
    [self.cameraSettings setValue:[NSNumber numberWithInt:95] forKey:STABILITYDELAY];
    [self.cameraSettings setValue:[NSNumber numberWithInt:85] forKey:OFFSETTHRESHOLD];
    [self.cameraSettings setValue:[NSNumber numberWithInt:10] forKey:MANUALCAPTURETIMER];
    [self.cameraSettings setValue:[NSNumber numberWithInt:0] forKey:AUTOTORCH];
    [self.cameraSettings setValue:[NSNumber numberWithBool:YES] forKey:SHOWGUIDINGDEMO];
    
    if (self.componentObject.type == CUSTOM) {
        [self.cameraSettings setValue:[NSNumber numberWithInt:0] forKey:MANUALCAPTURETIMER];
        [self.cameraSettings setValue:[NSNumber numberWithInt:1] forKey:CAPTURETYPE];
        [self.cameraSettings setValue:[NSNumber numberWithFloat:0.69] forKey:FRAMEASPECTRATIO];
    }
    
    if (self.componentObject.type == CUSTOM && [self.componentObject.name isEqualToString:@"Passport"]) {
        [self.cameraSettings setValue:[NSNumber numberWithInt:0] forKey:CAPTURETYPE];
        [self.cameraSettings setValue:[NSNumber numberWithFloat:0.69] forKey:FRAMEASPECTRATIO];
    }
    if (self.componentObject.type == CHECKDEPOSIT) {
        [self.cameraSettings setValue:[NSNumber numberWithFloat:0.45] forKey:FRAMEASPECTRATIO];
        [self.cameraSettings setValue:[NSNumber numberWithInt:0] forKey:EDGEDETECTION];
    }
    else
    {
        [self.cameraSettings setValue:[NSNumber numberWithInt:1] forKey:EDGEDETECTION];
    }
    
    isAnimatedCameraSelected = [[cameraSettings valueForKey:CAPTUREEXPERIENCE] intValue];
    [self.table reloadData];
}


//Method is used for gettting numberformatter based on device locale.

- (NSNumberFormatter*)getNumberFormatterOfLocale
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return numberFormatter;
}

//Method is used for gettting "US" numberformatter

- (NSNumberFormatter*)getUSNumberFormatter
{
    NSNumberFormatter *usNumberFormatter = [[NSNumberFormatter alloc] init];
    [usNumberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [usNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return usNumberFormatter;
}

@end
