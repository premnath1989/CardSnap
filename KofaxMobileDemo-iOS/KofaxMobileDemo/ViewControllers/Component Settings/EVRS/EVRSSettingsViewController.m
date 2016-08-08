//
//  EVRSSettingsViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/16/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "EVRSSettingsViewController.h"
#import "ProfileManager.h"

#define NUMBEROFSECTIONS 4

#define NUMBEROFROWS_FIRSTSECTION_CUSTOM 4
#define NUMBEROFROWS_FIRSTSECTION_CREDITCARD 2
#define NUMBEROFROWS_SECONDSECTION 5
#define NUMBEROFROWS_THIRDSECTION 5
#define NUMBEROFROWS_FOURTHSECTION 1

#define SPACEBETWEEN_NAVBAR_AND_TABLEVIEW 20
#define XPOS 15
#define HEIGHT_LABEL 22
#define CSKEWLABEL_WIDTH 200
#define CSKEWLABEL_YPOS 33

#define TEXTFIELD_WIDTH 50
#define TEXTFIELD_HEIGHT 25

#define TEXTVIEW_YPOS 29
#define TEXTVIEW_HEIGHT 80

#define BUTTON_XPOS 20
#define BUTTON_YPOS 10
#define BUTTON_HEIGHT 40

#define SEPARATOR_YPOS 43.5f
#define SEPARATORCOLOR [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f]

#define FIRSTSECTION_ROWHEIGHT 44
#define SECONDSECTION_ROWHEIGHT 115
#define THIRDSECTION_ROWHEIGHT 60

#define DESPECKLE_MINVALUE 0
#define DESPECKLE_MAXVALUE 9




@interface EVRSSettingsViewController ()<UITextViewDelegate>
{
    BOOL isBankRightSettingsOn;
    BOOL isDoProcessingisOn;

    id selectedTextField;
}
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, strong) UISwitch *backrightSwitch,*quickAnalysisSwitch,*autoCropSwitch,*autoRotateSwitch,*deskewSwitch,*smoothingSwitch,*cskewSwitch,*doProcessSwitch,*debuggingSwitch;
@property (nonatomic, strong) UISegmentedControl *modeSegment,*deskewSegment,*scaleSegment,*sharpenSegment;
@property (nonatomic, strong) UITextField *despeckleField;
@property (nonatomic, strong) NSMutableDictionary *evrsSettings;
@property (nonatomic, assign) Settings* settings;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic, assign) Component *componentObject;

@property (nonatomic, strong) UITextView *cskewString;
@property (nonatomic, strong) UILabel *cskewInstruction;

@end

@implementation EVRSSettingsViewController
@synthesize evrsSettings;
@synthesize tableTopConstraint;
@synthesize backrightSwitch,quickAnalysisSwitch,autoCropSwitch,autoRotateSwitch,deskewSwitch,smoothingSwitch,cskewSwitch;
@synthesize modeSegment,deskewSegment,scaleSegment,sharpenSegment;
@synthesize despeckleField;



-(void)dealloc{
    
    self.backrightSwitch = nil;
    self.quickAnalysisSwitch = nil;
    self.autoCropSwitch = nil;
    self.autoRotateSwitch = nil;
    self.deskewSwitch = nil;
    self.smoothingSwitch = nil;
    self.cskewSwitch    = nil;
    self.doProcessSwitch = nil;
    self.modeSegment = nil;
    self.deskewSegment = nil;
    self.scaleSegment = nil;
    self.sharpenSegment = nil;
    self.despeckleField.delegate = nil;
    self.despeckleField = nil;
    self.evrsSettings = nil;
    self.cskewString.delegate = nil;
    self.cskewString = nil;
    self.cskewInstruction = nil;
}

#pragma mark Constructor Methods
-(id)initWithSettings: (Settings*)settings andComponent:(Component *)compObject
{
    if(self = [super init])
    {
        self.componentObject = compObject;
        self.settings = settings;
        self.evrsSettings = [[self.settings.settingsDictionary valueForKey:EVRSSETTINGS] mutableCopy];
    }
    
    return self;
}

#pragma mark ViewLifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableTopConstraint.constant +=SPACEBETWEEN_NAVBAR_AND_TABLEVIEW;
    
    self.navigationItem.title = Klm(@"Image Processor Settings");
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    isBankRightSettingsOn = [[evrsSettings valueForKey:USEBANKRIGHTSETTINGS]boolValue];
    
    isDoProcessingisOn = [[evrsSettings valueForKey:DOPROCESS]boolValue];
    
    //Method to assign value to boolean variable to enable/disable UseDefaultSettings
    [self setUseDefaultSettingsOption];
    
    
    CGFloat horizontalOffset=3;
    
    self.cskewInstruction = [[UILabel alloc]initWithFrame:CGRectMake(XPOS, CSKEWLABEL_YPOS, [[UIScreen mainScreen]bounds].size.width-(2*XPOS-horizontalOffset), HEIGHT_LABEL)];
    self.cskewInstruction.text = Klm(@"CSkew String");
    self.cskewInstruction.font = [UIFont fontWithName:FONTNAME size:14];
    self.cskewInstruction.textColor = [UIColor lightGrayColor];
    self.cskewInstruction.textAlignment = NSTextAlignmentRight;
}


-(void)setUseDefaultSettingsOption{
    //For ID Card component if OnDevice is selected "Use Default Settings" switch should not be configurable
    //Check if the component is ID Card
    if(self.componentObject.type==IDCARD){
        
        //Check if ODE is selected, then disable UseDefaultSettings button by assigning NO to isDoProcessingisOn
        if((((NSNumber*)[[self.settings.settingsDictionary objectForKey:RTTISETTINGS] valueForKey:SERVER_MODE]).integerValue == 2) ){
            isDoProcessingisOn = NO;
            isBankRightSettingsOn=YES;
        }
        else{
            isDoProcessingisOn=YES;
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.despeckleField.delegate = nil;
    self.cskewString.delegate = nil;
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
    return NUMBEROFSECTIONS;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        
        if (self.componentObject.type == CUSTOM) {
            return NUMBEROFROWS_FIRSTSECTION_CUSTOM;
        }
        else if(self.componentObject.type==CREDITCARD){
            return NUMBEROFROWS_FIRSTSECTION_CREDITCARD;
        }
        return NUMBEROFROWS_FIRSTSECTION_CUSTOM -1;
    }else if(section==1){
        return NUMBEROFROWS_SECONDSECTION;
    }else if(section==2 && [[self.evrsSettings allKeys] containsObject:CSKEWSTRING]
                        && [[self.evrsSettings valueForKey:CSKEWSETTINGS]boolValue]
                        && self.componentObject.type == CUSTOM){
        
        return [[self.evrsSettings allKeys] count]-(NUMBEROFROWS_SECONDSECTION+NUMBEROFROWS_FIRSTSECTION_CUSTOM);

        
    }else if(section==2 && [[self.evrsSettings allKeys] containsObject:CSKEWSTRING]
                        && ![[self.evrsSettings valueForKey:CSKEWSETTINGS]boolValue]
                        && self.componentObject.type == CUSTOM){
        
        return [[self.evrsSettings allKeys] count]-((NUMBEROFROWS_SECONDSECTION+NUMBEROFROWS_FIRSTSECTION_CUSTOM)+1);
        
    }else if(section==2 && self.componentObject.type==CREDITCARD){
        return NUMBEROFROWS_THIRDSECTION-1;//CSkew settings are not necessary for credit card as in other components.So count is reduced by 1
    }else if(section==2 && self.componentObject.type!=CUSTOM){
        return NUMBEROFROWS_THIRDSECTION;
    }else if(section==3){
        return NUMBEROFROWS_FOURTHSECTION;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cellIdentifier" ;
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.section==0 && indexPath.row==0) {
        
        /*If component type is id card and Extraction Server Type is OnDevice then BankRightSwitch(Use Default Settings) is always true
        else UseDefaultSettings switch(on/off) is based on the value from evrsSettings dictionary.*/
        
        if(self.componentObject.type==IDCARD && isBankRightSettingsOn){
            
            self.backrightSwitch = [AppUtilities createSwitchWithTag:0 andValue:[NSNumber numberWithBool:YES]];
        }
        else{
            self.backrightSwitch = [AppUtilities createSwitchWithTag:0 andValue:[evrsSettings valueForKey:USEBANKRIGHTSETTINGS]];
        }
        [self.backrightSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = self.backrightSwitch;
        if (self.componentObject.type==CUSTOM || self.componentObject.type==IDCARD) {
            self.backrightSwitch.enabled = isDoProcessingisOn;
        }
        
    }//Add quick analysis switch if component type is not Credit Card
    else if (indexPath.section==0 && indexPath.row==1 && self.componentObject.type!=CREDITCARD) {
        
        self.quickAnalysisSwitch = [AppUtilities createSwitchWithTag:0 andValue:[evrsSettings valueForKey:DOQUICKANALYSIS]];
        [self.quickAnalysisSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = quickAnalysisSwitch;
        
        
    }//Add send summary switch if component type is not Credit Card
    else if(indexPath.section==0&&indexPath.row==2 && self.componentObject.type!=CREDITCARD){
        self.debuggingSwitch = [AppUtilities createSwitchWithTag:0 andValue:[evrsSettings valueForKey:EVRSDEBUGGING]];
        [self.debuggingSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = self.debuggingSwitch;
    }//Check for indexPath and component type and add DoProcess option
    //For other components indexPath is[0 3],for credit card [0 1]
    else if ((indexPath.section==0 && indexPath.row==3 && self.componentObject.type!=CREDITCARD) ||
             (self.componentObject.type==CREDITCARD &&  indexPath.section==0 && indexPath.row==1)) {
//        if(self.componentObject.type==CREDITCARD &&  indexPath.section==0 && indexPath.row==1)
            self.backrightSwitch.enabled = isDoProcessingisOn;
        self.doProcessSwitch = [AppUtilities createSwitchWithTag:0 andValue:[evrsSettings valueForKey:DOPROCESS]];
        [self.doProcessSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = self.doProcessSwitch;
    }
    else if (indexPath.section==1 && indexPath.row==1) {
        self.autoCropSwitch = [AppUtilities createSwitchWithTag:0 andValue:[evrsSettings valueForKey:AUTOCROP]];
        [self.autoCropSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        if (isBankRightSettingsOn)
            self.autoCropSwitch.enabled = NO;
        cell.accessoryView = autoCropSwitch;
    }else if (indexPath.section==1 && indexPath.row==2) {
        self.autoRotateSwitch = [AppUtilities createSwitchWithTag:0 andValue:[evrsSettings valueForKey:AUTOROTATE]];
        [self.autoRotateSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        if (isBankRightSettingsOn)
            self.autoRotateSwitch.enabled = NO;
        cell.accessoryView = autoRotateSwitch;
    }else if (indexPath.section==1 && indexPath.row==3) {
        self.deskewSwitch = [AppUtilities createSwitchWithTag:0 andValue:[evrsSettings valueForKey:DESKEW]];
        [self.deskewSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        if (isBankRightSettingsOn)
            self.deskewSwitch.enabled = NO;
        cell.accessoryView = deskewSwitch;
    }else if (indexPath.section==2 && indexPath.row==0) {
        self.smoothingSwitch = [AppUtilities createSwitchWithTag:0 andValue:[evrsSettings valueForKey:BACKGROUNDSMOOTHING]];
        [self.smoothingSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        if (isBankRightSettingsOn)
            self.smoothingSwitch.enabled = NO;
        cell.accessoryView = smoothingSwitch;
    }else if (indexPath.section==2 && indexPath.row==4) {
        self.cskewSwitch = [AppUtilities createSwitchWithTag:0 andValue:[evrsSettings valueForKey:CSKEWSETTINGS]];
        [self.cskewSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        if (isBankRightSettingsOn)
            self.cskewSwitch.enabled = NO;
        cell.accessoryView = cskewSwitch;
    }else if(indexPath.section==1&&indexPath.row==0){
         self.modeSegment = [AppUtilities createSegmentedControlWithTag:0 items:[NSArray arrayWithObjects:Klm(@"BW"), Klm(@"Gray"), Klm(@"Color"), nil] andSelectedSegment:[[evrsSettings valueForKey:MODE]intValue]];
        [self.modeSegment addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
        if (isBankRightSettingsOn)
            self.modeSegment.enabled = NO;
        cell.accessoryView = modeSegment;
    }else if(indexPath.section==1&&indexPath.row==4){
        self.deskewSegment = [AppUtilities createSegmentedControlWithTag:0 items:[NSArray arrayWithObjects:Klm(@"Content"),Klm(@"Layout"), nil] andSelectedSegment:[[evrsSettings valueForKey:DESKEWBY]intValue]];
        [self.deskewSegment addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = deskewSegment;
    }else if(indexPath.section==2&&indexPath.row==1){
        self.scaleSegment = [AppUtilities createSegmentedControlWithTag:0 items:[NSArray arrayWithObjects:Klm(@"No"),@"200",@"300",@"400", nil] andSelectedSegment:[[evrsSettings valueForKey:SCALE]intValue]];
        if(self.componentObject.type == IDCARD) {
            
            self.scaleSegment.enabled = NO;
        }
        else {
            
            self.scaleSegment.enabled = YES;
        }
        [self.scaleSegment addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = scaleSegment;
    }else if(indexPath.section==2&&indexPath.row==3){
        self.sharpenSegment = [AppUtilities createSegmentedControlWithTag:0 items:[NSArray arrayWithObjects:Klm(@"No"),@"1",@"2",@"3", nil] andSelectedSegment:[[evrsSettings valueForKey:SHARPEN]intValue]];
        [self.sharpenSegment addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sharpenSegment;
    }else if(indexPath.section==2&&indexPath.row==2){
        self.despeckleField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT) placeholder:@"" andText:[NSString stringWithFormat:@"%@",[evrsSettings valueForKey:DESPECKLE]]];
        despeckleField.delegate = self;
        cell.accessoryView = despeckleField;
        
    }else if(indexPath.section==2&&indexPath.row==(([[self.evrsSettings allKeys] count]-(NUMBEROFROWS_SECONDSECTION+NUMBEROFROWS_FIRSTSECTION_CUSTOM))-1)){
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(XPOS, 2, CSKEWLABEL_WIDTH, HEIGHT_LABEL)];
        label.font = [UIFont fontWithName:FONTNAME size:14];
        label.text = Klm(@"CSkew String");
          if (isBankRightSettingsOn)
              label.enabled = NO;
          else
              label.enabled = YES;
        [cell.contentView addSubview:label];
        NSString *fieldsString = [self.evrsSettings valueForKey:CSKEWSTRING];
        [cell.contentView addSubview:self.cskewInstruction];
        if (fieldsString.length==0) {
            self.cskewInstruction.hidden = NO;
        }else{
            self.cskewInstruction.hidden = YES;
        }
        self.cskewString = [[UITextView alloc]initWithFrame:CGRectMake(XPOS, TEXTVIEW_YPOS, [[UIScreen mainScreen]bounds].size.width-(2*XPOS), TEXTVIEW_HEIGHT)];
        self.cskewString.font = [UIFont fontWithName:FONTNAME size:14];
        self.cskewString.returnKeyType = UIReturnKeyDone;
        self.cskewString.delegate = self;
        self.cskewString.backgroundColor = [UIColor clearColor];
        self.cskewString.textAlignment = NSTextAlignmentRight;
        self.cskewString.text = [self.evrsSettings valueForKey:CSKEWSTRING];
        [cell.contentView addSubview:self.cskewString];
        if (isBankRightSettingsOn)
        {
               self.cskewString.userInteractionEnabled = NO;
               self.cskewString.textColor = [UIColor lightGrayColor];
            
        }
        else {
         
             self.cskewString.userInteractionEnabled = YES;
             self.cskewString.textColor = [UIColor blackColor];
        }
        
        
    }else if(indexPath.section==3){
        UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [resetBtn setTitle:Klm(@"Reset") forState:UIControlStateNormal];
        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        // [addComponentBtn setBackgroundColor: [UIColor colorWithRed:21.0f/255.0f green:123.0f/255.0f blue:191.0f/255.0f alpha:1.0f]];
        [resetBtn setTitleColor:[utilitiesObject colorWithHexString:self.themeObject.buttonTextColor] forState:UIControlStateNormal];
        [resetBtn setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:self.themeObject.buttonColor] withTheme:self.themeObject] forState:UIControlStateNormal];
        utilitiesObject = nil;
        [resetBtn addTarget:self action:@selector(resetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [resetBtn setFrame:CGRectMake(BUTTON_XPOS, BUTTON_YPOS, [[UIScreen mainScreen]bounds].size.width-(2*BUTTON_XPOS), BUTTON_HEIGHT)];
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:resetBtn];
    }
    
    if ((indexPath.section==0 && indexPath.row <=1)||(indexPath.section==1&&indexPath.row<4)||(indexPath.section==2 && indexPath.row<[self.table numberOfRowsInSection:2]-1)) {
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(XPOS, SEPARATOR_YPOS, [[UIScreen mainScreen]bounds].size.width-XPOS, 1)];
        line.backgroundColor = SEPARATORCOLOR;
        [cell.contentView addSubview:line];
    }
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
    if (indexPath.section==0 && indexPath.row==0) {
        cell.textLabel.text = Klm(@"Use Default Settings:");
    //Check if the component is not credit card and add 'Use Quick Analysis' option
    }else if(indexPath.section==0 && indexPath.row==1 && self.componentObject.type!=CREDITCARD){
        cell.textLabel.text = Klm(@"Use Quick Analysis:");
    }else if(indexPath.section==0 && indexPath.row==2){
        cell.textLabel.text = Klm(@"Send Image Summary:");
    //Check the indexPath and set the label text.
    }else if((indexPath.section==0 && indexPath.row==3) ||(self.componentObject.type==CREDITCARD && indexPath.section==0 && indexPath.row==1)){
        cell.textLabel.text = Klm(@"Image Processing:" );
    }else if(indexPath.section==1 && indexPath.row==0){
        cell.textLabel.text = Klm(@"Mode:");
        [self disableLabel:cell.textLabel iosswitch:nil segment:self.modeSegment andTextField:nil];
    }else if(indexPath.section==1 && indexPath.row==1){
        cell.textLabel.text = Klm(@"Auto Crop:");
        [self disableLabel:cell.textLabel iosswitch:self.autoCropSwitch segment:nil andTextField:nil];
    }else if(indexPath.section==1 && indexPath.row==2){
        cell.textLabel.text = Klm(@"Auto Rotate:");
        [self disableLabel:cell.textLabel iosswitch:self.autoRotateSwitch segment:nil andTextField:nil];
    }else if(indexPath.section==1 && indexPath.row==3){
        cell.textLabel.text = Klm(@"Deskew:");
        [self disableLabel:cell.textLabel iosswitch:self.deskewSwitch segment:nil andTextField:nil];
    }else if(indexPath.section==1 && indexPath.row==4){
        cell.textLabel.text = Klm(@"Deskew By:");
        [self disableLabel:cell.textLabel iosswitch:nil segment:self.deskewSegment andTextField:nil];
        if (![[evrsSettings valueForKey:DESKEW]boolValue]) {
            cell.textLabel.enabled = NO;
            self.deskewSegment.enabled = NO;
        }else if(!isBankRightSettingsOn){
            cell.textLabel.enabled = YES;
            self.deskewSegment.enabled = YES;
        }
    }else if(indexPath.section==2 && indexPath.row==0){
        cell.textLabel.text = Klm(@"Background Smoothing:");
        [self disableLabel:cell.textLabel iosswitch:self.smoothingSwitch segment:nil andTextField:nil];
    }else if(indexPath.section==2 && indexPath.row==1){
        cell.textLabel.text = Klm(@"Scale(dpi):");
        [self disableLabel:cell.textLabel iosswitch:nil segment:self.scaleSegment andTextField:nil];
    }else if(indexPath.section==2 && indexPath.row==2){
        cell.textLabel.text = [[[[[Klm(@"Despeckle") stringByAppendingString:@" ("] stringByAppendingString:@"0 " ] stringByAppendingString:Klm(@"-")] stringByAppendingString:@" 9"]stringByAppendingString:@") :"];
        [self disableLabel:cell.textLabel iosswitch:nil segment:nil andTextField:self.despeckleField];
    }else if(indexPath.section==2 && indexPath.row==3){
        cell.textLabel.text = Klm(@"Sharpen:");
        [self disableLabel:cell.textLabel iosswitch:nil segment:self.sharpenSegment andTextField:nil];
    }else if(indexPath.section==2 && indexPath.row==4){
        cell.textLabel.text = Klm(@"CSkew Settings:");
        [self disableLabel:cell.textLabel iosswitch:self.cskewSwitch segment:nil andTextField:nil];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==3) {
        return THIRDSECTION_ROWHEIGHT;
    }else if(indexPath.section==2 &&indexPath.row==(([[self.evrsSettings allKeys] count]-(NUMBEROFROWS_SECONDSECTION+NUMBEROFROWS_FIRSTSECTION_CUSTOM))-1)  && self.componentObject.type == CUSTOM){
        return SECONDSECTION_ROWHEIGHT;
    }
    return FIRSTSECTION_ROWHEIGHT;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==1) {
        return Klm(@"Basic");
    }else if(section==2){
        return Klm(@"Advanced");
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [selectedTextField resignFirstResponder];
}

#pragma mark UITextFieldDelegate Methods
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    selectedTextField = textField;
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]];
    [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if([textField isEqual:self.despeckleField])
    {
        if([textField.text intValue] < DESPECKLE_MINVALUE || [textField.text intValue] > DESPECKLE_MAXVALUE)
        {
            textField.text = [NSString stringWithFormat:@"%d",DESPECKLE_MAXVALUE];
        }
        [self.evrsSettings setValue:[NSString stringWithFormat:@"%@",despeckleField.text] forKey:DESPECKLE];
    }
    
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField isEqual:self.despeckleField])
    {
        if([textField.text intValue] < DESPECKLE_MINVALUE || [textField.text intValue] > DESPECKLE_MAXVALUE)
        {
            textField.text = [NSString stringWithFormat:@"%d",DESPECKLE_MAXVALUE];
        }
        [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
        [self.evrsSettings setValue:[NSNumber numberWithInt:[despeckleField.text intValue]] forKey:DESPECKLE];
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark UITextViewDelegate Methods

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    selectedTextField  = textView;
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    if (textView == self.cskewString) {
        [self.evrsSettings setValue:self.cskewString.text forKey:CSKEWSTRING];
    }
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (textView == self.cskewString) {
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:2]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@""] && textView == self.cskewString && textView.text.length==1) {
        self.cskewInstruction.hidden = NO;
    }
    
    if (![text isEqualToString:@"\n"] && text.length!=0 && textView.text.length == 0 && textView == self.cskewString) {
        self.cskewInstruction.hidden = YES;
    }
    
    if ([text isEqualToString:@"\n"] && textView.text.length==0 && textView == self.cskewString) {
        self.cskewInstruction.hidden = NO;
    }
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];

    }
    return YES;
}

#pragma mark Local Methods

-(void)disableLabel:(UILabel*)label iosswitch:(UISwitch*)swich segment:(UISegmentedControl*)segment andTextField:(UITextField*)textField{
    if (label && isBankRightSettingsOn) {
        label.enabled = NO;
    }
    if (swich && isBankRightSettingsOn) {
        swich.enabled = NO;
    }
    if (segment && isBankRightSettingsOn) {
        segment.enabled = NO;
    }
    if (textField && isBankRightSettingsOn) {
        textField.enabled = NO;
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
 This method is used to go back to the previous screen and also save the evrs settings.
 */
-(IBAction)backButtonAction:(id)sender{
    if ([[self.evrsSettings allKeys] containsObject:CSKEWSTRING] && [[self.evrsSettings valueForKey:CSKEWSETTINGS]boolValue]&& self.cskewString && self.cskewString.text.length ==0) {
        [self showAlert:Klm(@"Please enter CSkew string")];
    }else{
        [self.settings.settingsDictionary setValue:self.evrsSettings forKey:EVRSSETTINGS];
        [[ProfileManager sharedInstance] updateProfile:[[ProfileManager sharedInstance]getActiveProfile]];
        [self.navigationController popViewControllerAnimated:YES];
    }

}
/*
 This method is called when the segment control value changed.
 */
-(IBAction)segmentValueChanged:(UISegmentedControl*)sender{
    if (self.modeSegment == sender) {
        [self.evrsSettings setValue:[NSNumber numberWithInteger:sender.selectedSegmentIndex] forKey:MODE];
    }else if(sender == self.deskewSegment){
        [self.evrsSettings setValue:[NSNumber numberWithInteger:sender.selectedSegmentIndex] forKey:DESKEWBY];
    }else if(sender == self.scaleSegment){
        [self.evrsSettings setValue:[NSNumber numberWithInteger:sender.selectedSegmentIndex] forKey:SCALE];
    }else if(sender == self.sharpenSegment){
        [self.evrsSettings setValue:[NSNumber numberWithInteger:sender.selectedSegmentIndex] forKey:SHARPEN];
    }
}
/*
 This method is called when the switch value is changed.
 */
-(IBAction)switchValueChanged:(UISwitch*)sender{
    
    if (sender==self.backrightSwitch) {
        [self.evrsSettings setValue:[NSNumber numberWithBool:sender.on] forKey:USEBANKRIGHTSETTINGS];
        isBankRightSettingsOn = sender.on;
        [self.table reloadData];
    }else if(sender==self.quickAnalysisSwitch){
        [self.evrsSettings setValue:[NSNumber numberWithBool:sender.on] forKey:DOQUICKANALYSIS];
    }else if(sender == self.autoCropSwitch){
        [self.evrsSettings setValue:[NSNumber numberWithBool:sender.on] forKey:AUTOCROP];
    }else if(sender == self.autoRotateSwitch){
        [self.evrsSettings setValue:[NSNumber numberWithBool:sender.on] forKey:AUTOROTATE];
    }else if(sender == self.deskewSwitch){
         [self.evrsSettings setValue:[NSNumber numberWithBool:sender.on] forKey:DESKEW];
        [self.table reloadData];
    }else if(sender == self.smoothingSwitch){
        [self.evrsSettings setValue:[NSNumber numberWithBool:sender.on] forKey:BACKGROUNDSMOOTHING];
    }else if(sender == self.cskewSwitch){
         [self.evrsSettings setValue:[NSNumber numberWithBool:sender.on] forKey:CSKEWSETTINGS];
         [self.table reloadData];
    }else if(sender == self.doProcessSwitch){
        [self.evrsSettings setValue:[NSNumber numberWithBool:sender.isOn] forKey:DOPROCESS];
        isDoProcessingisOn = [[self.evrsSettings valueForKey:DOPROCESS] boolValue];
        
         if(self.backrightSwitch.isOn && !isDoProcessingisOn)
        {
            isBankRightSettingsOn = true;

        }
        else if(!self.backrightSwitch.isOn)
        {
            isBankRightSettingsOn = false;
        }
        
        
        if (!isDoProcessingisOn && (self.componentObject.type==CUSTOM|| self.componentObject.type==CREDITCARD)) {
            isBankRightSettingsOn = true;
        }
        [self.table reloadData];


    }else if(sender == self.debuggingSwitch){
        [self.evrsSettings setValue:[NSNumber numberWithBool:sender.on] forKey:EVRSDEBUGGING];
    }
}

-(IBAction)resetButtonAction:(id)sender{
    isBankRightSettingsOn = YES;
    
    [self setUseDefaultSettingsOption];
    
    [self.evrsSettings setValue:[NSNumber numberWithInt:1] forKey:SCALE];
    [self.evrsSettings setValue:[NSNumber numberWithBool:true] forKey:DESKEW];
    [self.evrsSettings setValue:[NSNumber numberWithBool:true] forKey:AUTOCROP];
    [self.evrsSettings setValue:[NSNumber numberWithBool:false] forKey:DOQUICKANALYSIS];
    [self.evrsSettings setValue:[NSNumber numberWithBool:false] forKey:BACKGROUNDSMOOTHING];
    [self.evrsSettings setValue:[NSNumber numberWithBool:true] forKey:CSKEWSETTINGS];
    [self.evrsSettings setValue:[NSNumber numberWithInt:0] forKey:SHARPEN];
    [self.evrsSettings setValue:[NSNumber numberWithBool:true] forKey:USEBANKRIGHTSETTINGS];
    [self.evrsSettings setValue:[NSNumber numberWithInt:1] forKey:DESKEWBY];
    [self.evrsSettings setValue:[NSNumber numberWithInt:0] forKey:DESPECKLE];
    [self.evrsSettings setValue:[NSNumber numberWithBool:true] forKey:AUTOROTATE];
    [self.evrsSettings setValue:[NSNumber numberWithInt:0] forKey:MODE];
    [self.evrsSettings setValue:@"" forKey:CSKEWSTRING];
    [self.evrsSettings setValue:[NSNumber numberWithBool:false] forKey:EVRSDEBUGGING]; //Earlier we are not resetting this key, Now we are setting to default value.

    [self.evrsSettings setValue:[NSNumber numberWithBool:true] forKey:DOPROCESS];
    if (self.componentObject.type == IDCARD) {
        [self.evrsSettings setValue:[NSNumber numberWithInt:2] forKey:MODE];
        [self.evrsSettings setValue:[NSNumber numberWithInt:2] forKey:SCALE];
    }else if(self.componentObject.type == CUSTOM){
        [self.evrsSettings setValue:[NSNumber numberWithBool:false] forKey:CSKEWSETTINGS];
        [self.evrsSettings setValue:[NSNumber numberWithInt:2] forKey:MODE];
        [self.evrsSettings setValue:[NSNumber numberWithInt:1] forKey:SCALE];

    }
    
    [self.table reloadData];
}
@end
