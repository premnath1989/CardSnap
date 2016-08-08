//
//  RTTISettingsViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/15/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "RTTISettingsViewController.h"
#import "ProfileManager.h"
#import "ODEExtractionView.h"
#import "ExtractionManager.h"

typedef enum : NSUInteger {
    kRTTI_Extraction,
    kKTA_Extraction,
    kOD_Extraction,
    kCCARDIO_Extraction
} ExtractionType;

typedef enum : NSUInteger{
    kMobile_ID_Server = 0,
    kMobile_ID_Server_And_Device
}MobileIDType;


@interface RTTISettingsViewController ()<ODEExtractionView_Delegate,UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, strong)  UITextView *serverNameView, *fieldsName;
@property (nonatomic, strong)  UISwitch *showAllFields;
@property (nonatomic, strong)  UISwitch *highlightAreasSwitch;
@property (nonatomic, strong)  UISwitch *saveOriginalImageSwitch;
@property (nonatomic, strong)  UITextField *customValueFields;
@property (nonatomic, strong)  UITextField *customKeyFields;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, strong) NSMutableDictionary *rttiSettings;
@property (nonatomic, assign) Settings* settings;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic, strong) UITableViewCell *cell;
@property (nonatomic, strong) ODEExtractionView *viewODE;

@property (nonatomic, strong) UISegmentedControl *extractionServerType;
@property (nonatomic, strong) UISegmentedControl *segmentControlODE;
@property (nonatomic, strong) UITextField *serverUsernameField,*serverPasswordField, * serverProcessName, * serverIDType,*mobileIDTypeTextField;

@property (nonatomic, strong) UILabel *instructionLabel, *serverInstructionLabel;

@property (nonatomic, assign) Component *componentObject;
@property (nonatomic, strong) NSUserDefaults* standardDefaults;
@property (nonatomic) BOOL isODEActive;
//This variable holds the indexPath of selected extractMethod.
@property(strong)  NSIndexPath* lastIndexPath;
//List of extractMethod types
@property (nonatomic, strong) NSArray *extractMethodTypes;
@property (nonatomic) UIPickerView* mobileIDPickerView;
@property (nonatomic) UIToolbar* mobileIDToolBar;
@property (assign) MobileIDType mobileIDType;



@end

@implementation RTTISettingsViewController
@synthesize serverNameView;
@synthesize showAllFields;
@synthesize highlightAreasSwitch;
@synthesize saveOriginalImageSwitch;
@synthesize customValueFields;
@synthesize customKeyFields;
@synthesize tableTopConstraint;
@synthesize rttiSettings;
@synthesize cell;

@synthesize extractionServerType;
@synthesize serverUsernameField,serverPasswordField;


-(void)dealloc{
    self.serverNameView.delegate = nil;
    self.serverNameView = nil;
    self.fieldsName.delegate = nil;
    self.fieldsName = nil;
    self.showAllFields = nil;
    self.highlightAreasSwitch = nil;
    self.saveOriginalImageSwitch = nil;
    self.customValueFields.delegate = nil;
    self.customValueFields = nil;
    self.customKeyFields.delegate = nil;
    self.customKeyFields = nil;
    self.tableTopConstraint = nil;
    self.rttiSettings = nil;
    self.cell = nil;
    self.instructionLabel = nil;
    self.serverInstructionLabel = nil;
}

#pragma mark Constructor Methods
-(id)initWithSettings: (Settings*)settings component:(Component*)component
{
    if(self = [super init])
    {
        self.settings = settings;
        self.rttiSettings = [[self.settings.settingsDictionary valueForKey:RTTISETTINGS] mutableCopy];
        self.componentObject = component;
    }
    
    return self;
}

#pragma mark ViewLifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.standardDefaults = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view from its nib.
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant +=20;
    }else{
        self.tableTopConstraint.constant -=42;
    }
    
    self.instructionLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 33, [[UIScreen mainScreen]bounds].size.width-33, 22)];
    self.instructionLabel.text = Klm(@"Key 1,Display Label 1;Key 2,Display Label 2;");
    self.instructionLabel.font = [UIFont fontWithName:FONTNAME size:14];
    self.instructionLabel.textColor = [UIColor lightGrayColor];
    self.instructionLabel.textAlignment = NSTextAlignmentRight;
    
    self.serverInstructionLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 9, [[UIScreen mainScreen]bounds].size.width-33, 22)];
    self.serverInstructionLabel.text = Klm(@"Server Name");
    self.serverInstructionLabel.font = [UIFont fontWithName:FONTNAME size:14];
    self.serverInstructionLabel.textColor = [UIColor lightGrayColor];
    self.serverInstructionLabel.textAlignment = NSTextAlignmentRight;
    
    
    self.navigationItem.title = Klm(@"Extraction Settings");
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    
    self.extractMethodTypes=[[NSArray alloc]initWithObjects:Klm(@"Embossed"),Klm(@"Non-Embossed"),Klm(@"Detect"), nil];
    //get the value of extract method type from settings and
    self.lastIndexPath=[NSIndexPath indexPathForRow:[[self.rttiSettings valueForKey:EXTRACTMETHOD] intValue] inSection:1];
    
    // Checking the settings and then updating other settings accordingly
    
    if(self.componentObject.type==CREDITCARD){
        if(((NSNumber*)[self.rttiSettings valueForKey:SERVER_MODE]).integerValue == [NSNumber numberWithInt:kRTTI_Extraction].integerValue){
            [self.standardDefaults setValue:[NSNumber numberWithInt:1] forKey:ONLINE_SERVER_MODE];
        }
        else if(((NSNumber*)[self.rttiSettings valueForKey:SERVER_MODE]).integerValue == [NSNumber numberWithInt:kCCARDIO_Extraction].integerValue){
            [self.standardDefaults setValue:[NSNumber numberWithInt:0] forKey:ONLINE_SERVER_MODE];
        }
    }else{
    if(((NSNumber*)[self.rttiSettings valueForKey:SERVER_MODE]).integerValue == [NSNumber numberWithInt:kRTTI_Extraction].integerValue){
        [self.standardDefaults setValue:[NSNumber numberWithInt:kRTTI_Extraction] forKey:ONLINE_SERVER_MODE];
    }
    else if(((NSNumber*)[self.rttiSettings valueForKey:SERVER_MODE]).integerValue == [NSNumber numberWithInt:kKTA_Extraction].integerValue){
        [self.standardDefaults setValue:[NSNumber numberWithInt:kKTA_Extraction] forKey:ONLINE_SERVER_MODE];
    }
    }
    
    if (((NSNumber*)[self.rttiSettings valueForKey:MOBILE_ID_TYPE]).boolValue) {
        self.mobileIDType = kMobile_ID_Server_And_Device;
    }
    else{
        self.mobileIDType = kMobile_ID_Server;
    }
    
    
    
    if ([self.rttiSettings valueForKey:ODE_SERVER_MODE]) {
        [self designODE];
    }
}

-(void)designODE
{
    CGRect odeFrame = self.table.frame;
    odeFrame.size=CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - HEADER_HEIGHT);
    self.viewODE = [[ODEExtractionView alloc] initWithFrame:odeFrame];
    self.viewODE.backgroundColor = [UIColor whiteColor];
    self.viewODE.callBack = self;
    self.viewODE.rttiSettings = self.rttiSettings;
    [self.viewODE designODEview];
    [self.view addSubview:self.viewODE];
    self.viewODE.hidden = YES;
    
    if (((NSNumber*)[self.rttiSettings valueForKey:SERVER_MODE]).integerValue == [NSNumber numberWithInt:kOD_Extraction].integerValue) {
        [self.table reloadData];
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"Custom fields dictionalry is %@", [self.rttiSettings valueForKey:CUSTOMFIELDKEYVALUE]);
    [super viewWillAppear:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.serverNameView.delegate = nil;
    self.fieldsName.delegate = nil;
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
    
    
    if(![[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]) {
        
        
        if (self.componentObject.type != CUSTOM){
            //If extraction type is CardIO return 1
            if(self.componentObject.type == CREDITCARD)
                return 1; //Extraction Type
            return 2;//Extraction Type ,Server Url
        }
        else
            return 3; // Server type, Server URL , Show All Fields
        
    }
    else {
        
        // For KTA
        
        if (self.componentObject.type == CHECKDEPOSIT || self.componentObject.type == BILLPAY ) {
            
            return 4; // Server Type, Account , Process Name  , Server URL
        }
        else if (self.componentObject.type == IDCARD){
            
            return 5; // Server Type, Account , Process Name , ID Type , Server URL
            
        }
        else if (self.componentObject.type == CUSTOM){
            
            return 6; // Server Type, Account , Process Name , ID Type , Server URL , Show ALL Fields
            
        }
        //If extraction type is RTTI return 2.
        else if(self.componentObject.type == CREDITCARD){
            return 3;//Extraction Type,Card Type, Server Url
        }
        
        
    }
    
    return 0;
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    if( ![[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && section == 1 && (self.componentObject.type == CHECKDEPOSIT || self.componentObject.type == BILLPAY)){
        
        return 3;
    }
    else if ((![[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && section == 1 && (self.componentObject.type == IDCARD ||
             self.componentObject.type == CUSTOM))||
             (![[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && section == 2 && ![[self.rttiSettings valueForKey:SHOWALLFIELDS]boolValue])||
             ([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && section == 5 && ![[self.rttiSettings valueForKey:SHOWALLFIELDS]boolValue]) ||
             (section == 0 && self.componentObject.type == IDCARD && self.isKofaxMobileIdEnabledForSelectedRegion)){
        
        return 2;
        
    }
    
     if([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && self.componentObject.type==CREDITCARD && section==1){
        
        return [self.extractMethodTypes count];
    }
        return 1;
    
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"cellIdentifier" ;
    
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.row ==0 && indexPath.section == 0) {
        cell.textLabel.font = [UIFont fontWithName:FONTNAME size:14];
        
        if (self.componentObject.type == CREDITCARD) {
            cell.textLabel.text = Klm(@"Extraction Type");
            self.extractionServerType = [AppUtilities createSegmentedControlWithTag:1 items:[NSArray arrayWithObjects:Klm(@"CardIO"),Klm(@"RTTI"), nil] andSelectedSegment:[[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]intValue]];
        }
        else{
            cell.textLabel.text = Klm(@"Server Type");
            self.extractionServerType = [AppUtilities createSegmentedControlWithTag:0 items:[NSArray arrayWithObjects:Klm(@"RTTI"),Klm(@"KTA"), nil] andSelectedSegment:[[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]intValue]];
        }
        
        
        [self.extractionServerType addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = self.extractionServerType;
        
    }
    
    if (indexPath.row==1 && indexPath.section==0 && self.componentObject.type == ID_CARD) {
        cell.textLabel.text = Klm(@"Mobile ID");
        cell.textLabel.font = [UIFont fontWithName:FONTNAME size:14];
        self.mobileIDTypeTextField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(160, 7, [[UIScreen mainScreen]bounds].size.width-160, 35) placeholder:nil andText:self.mobileIDType?Klm(@"Server & Device Extraction"):Klm(@"Server Extraction")];
        self.mobileIDTypeTextField.delegate = self;
        self.mobileIDTypeTextField.clearButtonMode = UITextFieldViewModeNever;
        self.mobileIDPickerView = [self pickerView];
        self.mobileIDPickerView.delegate = self;
        self.mobileIDPickerView.dataSource = self;
        self.mobileIDTypeTextField.inputView = self.mobileIDPickerView;
        self.mobileIDToolBar = [self toolBar];
        self.mobileIDTypeTextField.inputAccessoryView = self.mobileIDToolBar;
        cell.accessoryView = self.mobileIDTypeTextField;
    }
    
    if((indexPath.section==1 && indexPath.row==0 && ![[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && self.componentObject.type!=CREDITCARD)||
       (indexPath.section==2 && indexPath.row==0 && (([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && self.componentObject.type == CREDITCARD))) ||
       (indexPath.section==3 && indexPath.row==0 && [[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && (self.componentObject.type == CHECKDEPOSIT || self.componentObject.type == BILLPAY)) ||
       (indexPath.section==4 && indexPath.row==0 && [[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && (self.componentObject.type == IDCARD || self.componentObject.type == CUSTOM))) {
        
        NSString *serverurl;
        
        //If component type is CREDITCARD and 'ONLINE_SERVER_MODE' is 1(RTTI) and set RTTI Url for credit card
        if (self.componentObject.type == CREDITCARD) {
            serverurl = [self.rttiSettings valueForKey:SERVERURL];
        }
        else if (self.componentObject.type == IDCARD){
            serverurl = [self serverURLForIDFromSettings];
        }
        else{
            serverurl = [[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]?[self.rttiSettings valueForKey:KTASERVERURL]:[self.rttiSettings valueForKey:SERVERURL];
        }
        [cell.contentView addSubview:self.serverInstructionLabel];
        if (serverurl.length==0) {
            self.serverInstructionLabel.hidden = NO;
        }else{
            self.serverInstructionLabel.hidden = YES;
        }
        self.serverNameView = [[UITextView alloc]initWithFrame:CGRectMake(15, 5, [[UIScreen mainScreen]bounds].size.width-30, 80)];
        self.serverNameView.font = [UIFont fontWithName:FONTNAME size:14];
        self.serverNameView.returnKeyType = UIReturnKeyDone;
        self.serverNameView.delegate = self;
        self.serverNameView.backgroundColor = [UIColor clearColor];
        self.serverNameView.textAlignment = NSTextAlignmentRight;
        self.serverNameView.text = serverurl;
        [cell.contentView addSubview:self.serverNameView];
        
    }
    
    if (indexPath.section==1 && indexPath.row==2 && ![[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && (self.componentObject.type == CHECKDEPOSIT || self.componentObject.type == BILLPAY)) {
        
        cell.textLabel.font = [UIFont fontWithName:FONTNAME size:14];
        cell.textLabel.text = Klm(@"Save Original Image");
        
        self.saveOriginalImageSwitch = [AppUtilities createSwitchWithTag:1 andValue:[rttiSettings valueForKey:SAVEORIGINALIMAGESWITCH]];
        self.saveOriginalImageSwitch.on=[[self.rttiSettings valueForKey:SAVEORIGINALIMAGESWITCH] boolValue];
        [self.saveOriginalImageSwitch addTarget:self action:@selector(saveOriginalImageValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        cell.accessoryView = self.saveOriginalImageSwitch;
    }
    
    
    if ((indexPath.section==1 && indexPath.row==1 && ![[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue])) {
        
        if((self.componentObject.type == IDCARD) ||  (self.componentObject.type == CUSTOM)) {
            
            cell.textLabel.font = [UIFont fontWithName:FONTNAME size:14];
            cell.textLabel.text =Klm(@"Save Original Image");
            
            self.saveOriginalImageSwitch = [AppUtilities createSwitchWithTag:1 andValue:[rttiSettings valueForKey:SAVEORIGINALIMAGESWITCH]];
            self.saveOriginalImageSwitch.on=[[self.rttiSettings valueForKey:SAVEORIGINALIMAGESWITCH] boolValue];
            [self.saveOriginalImageSwitch addTarget:self action:@selector(saveOriginalImageValueChanged:) forControlEvents:UIControlEventValueChanged];
            
            cell.accessoryView = self.saveOriginalImageSwitch;
            
        }
        else {
            
            cell.textLabel.font = [UIFont fontWithName:FONTNAME size:14];
            cell.textLabel.text = Klm(@"Highlight extracted data");
            
            self.highlightAreasSwitch = [AppUtilities createSwitchWithTag:1 andValue:[rttiSettings valueForKey:HIGHLIGHTSWITCH]];
            if ([AppUtilities getRAMSize] <= (512*1024*1024)) {
                self.highlightAreasSwitch.on = FALSE;
                self.highlightAreasSwitch.enabled = NO;
            }else{
                self.highlightAreasSwitch.on=[[self.rttiSettings valueForKey:HIGHLIGHTDATA] boolValue];
            }
            [self.highlightAreasSwitch addTarget:self action:@selector(showHighlightsValueChanged:) forControlEvents:UIControlEventValueChanged];
            
            cell.accessoryView = self.highlightAreasSwitch;
        }
        
    }
    
    
    
    if (indexPath.section == 1 && indexPath.row==0 && [[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && self.componentObject.type!=CREDITCARD) {
        
        self.serverUsernameField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(30, 10, [[UIScreen mainScreen]bounds].size.width-60, 35) placeholder:Klm(@"Enter Username") andText:[self userNameFromSettings]];
        self.serverUsernameField.font = [UIFont fontWithName:FONTNAME size:15];
        self.serverUsernameField.textAlignment = NSTextAlignmentLeft;
        self.serverUsernameField.delegate = self;
        self.serverUsernameField.layer.borderWidth = 1;
        self.serverUsernameField.layer.borderColor = [UIColor grayColor].CGColor;
        self.serverUsernameField.layer.cornerRadius = 3;
        self.serverUsernameField.leftViewMode = UITextFieldViewModeAlways;
        self.serverUsernameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 35)];
        [cell.contentView addSubview:self.serverUsernameField];
        
        self.serverPasswordField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(30, 55, [[UIScreen mainScreen]bounds].size.width-60, 35) placeholder:@"Enter Password" andText:[self passwordFromSettings]];
        self.serverPasswordField.font = [UIFont fontWithName:FONTNAME size:15];
        self.serverPasswordField.secureTextEntry = YES;
        self.serverPasswordField.textAlignment = NSTextAlignmentLeft;
        self.serverPasswordField.delegate = self;
        self.serverPasswordField.layer.borderWidth = 1;
        self.serverPasswordField.layer.borderColor = [UIColor grayColor].CGColor;
        self.serverPasswordField.layer.cornerRadius = 3;
        self.serverPasswordField.leftViewMode = UITextFieldViewModeAlways;
        self.serverPasswordField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 35)];
        [cell.contentView addSubview:self.serverPasswordField];
    }
    
    if(indexPath.section == 2 && indexPath.row == 0 && [[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && self.componentObject.type!=CREDITCARD){
        
        
        self.serverProcessName = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(30, 7, [[UIScreen mainScreen]bounds].size.width-60, 35) placeholder:Klm(@"Enter Process Name") andText:[self processNameFromSettings]];
        self.serverProcessName.font = [UIFont fontWithName:FONTNAME size:15];
        self.serverProcessName.textAlignment = NSTextAlignmentLeft;
        self.serverProcessName.delegate = self;
        self.serverProcessName.layer.borderWidth = 1;
        self.serverProcessName.layer.borderColor = [UIColor grayColor].CGColor;
        self.serverProcessName.layer.cornerRadius = 3;
        self.serverProcessName.leftViewMode = UITextFieldViewModeAlways;
        self.serverProcessName.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 35)];
        [cell.contentView addSubview:self.serverProcessName];
        
    }
    
    if(indexPath.section == 3 && indexPath.row == 0 && [[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && (self.componentObject.type == IDCARD || self.componentObject.type == CUSTOM)){
        
        self.serverIDType = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(30, 7, [[UIScreen mainScreen]bounds].size.width-60, 35) placeholder:Klm(@"Enter ID Type ") andText:[self idTypeFromSettings]];
        
        self.serverIDType.font = [UIFont fontWithName:FONTNAME size:15];
        self.serverIDType.textAlignment = NSTextAlignmentLeft;
        self.serverIDType.delegate = self;
        self.serverIDType.layer.borderWidth = 1;
        self.serverIDType.layer.borderColor = [UIColor grayColor].CGColor;
        self.serverIDType.layer.cornerRadius = 3;
        self.serverIDType.leftViewMode = UITextFieldViewModeAlways;
        self.serverIDType.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 35)];
        [cell.contentView addSubview:self.serverIDType];
        
    }
    
    if((indexPath.section==2 && indexPath.row==0 && ![[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]) || (indexPath.section == 5 && indexPath.row == 0  &&  [[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] &&  self.componentObject.type == CUSTOM )) {
        
        self.showAllFields = [AppUtilities createSwitchWithTag:0 andValue:[rttiSettings valueForKey:SHOWALLFIELDS]];
        cell.textLabel.font = [UIFont fontWithName:FONTNAME size:14];
        self.showAllFields.on=[[self.rttiSettings valueForKey:SHOWALLFIELDS] boolValue];
        cell.textLabel.text = Klm(@"Show All Fields");
        [self.showAllFields addTarget:self action:@selector(showAllFieldsValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = self.showAllFields;
        
    }
    else if ((indexPath.section == 2 && indexPath.row == 1 && ![[self.rttiSettings valueForKey:SHOWALLFIELDS] boolValue] && self.componentObject.type == CUSTOM && ![[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]  && ![[self.rttiSettings valueForKey:SHOWALLFIELDS] boolValue]) || (indexPath.section == 5 && indexPath.row == 1 && ![[self.rttiSettings valueForKey:SHOWALLFIELDS] boolValue] && self.componentObject.type == CUSTOM && [[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue])) {
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 2, 200, 22)];
        label.font = [UIFont fontWithName:FONTNAME size:14];
        label.text = Klm(@"Custom Fields");
        [cell.contentView addSubview:label];
        NSString *fieldsString = [self.rttiSettings valueForKey:CUSTOMFIELDKEYVALUE];
        [cell.contentView addSubview:self.instructionLabel];
        if (fieldsString.length==0) {
            self.instructionLabel.hidden = NO;
        }else{
            self.instructionLabel.hidden = YES;
        }
        self.fieldsName = [[UITextView alloc]initWithFrame:CGRectMake(15, 29, [[UIScreen mainScreen]bounds].size.width-30, 80)];
        self.fieldsName.font = [UIFont fontWithName:FONTNAME size:14];
        self.fieldsName.returnKeyType = UIReturnKeyDone;
        self.fieldsName.delegate = self;
        self.fieldsName.backgroundColor = [UIColor clearColor];
        self.fieldsName.textAlignment = NSTextAlignmentRight;
        self.fieldsName.text = [self.rttiSettings valueForKey:CUSTOMFIELDKEYVALUE];
        [cell.contentView addSubview:self.fieldsName];
        
        
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if(indexPath.section==1 && self.componentObject.type==CREDITCARD){
        cell.textLabel.font = [UIFont fontWithName:FONTNAME size:14];
        cell.textLabel.text=  [self.extractMethodTypes objectAtIndex:indexPath.row];
        //Check for the selected indexPath and set the accessory type
        if ([indexPath compare:self.lastIndexPath] == NSOrderedSame)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 1 && indexPath.row ==0 && ([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && self.componentObject.type!=CREDITCARD)){
        return 100; //  For Account
    }
    else if ((indexPath.section==1 && indexPath.row==0 && ![[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]) ||
             ([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && indexPath.section == 3 && indexPath.row== 0 && (self.componentObject.type == CHECKDEPOSIT || self.componentObject.type == BILLPAY)) || ([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && indexPath.section == 4 && indexPath.row== 0 && (self.componentObject.type == IDCARD || self.componentObject.type == CUSTOM))||([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && indexPath.section == 2 && indexPath.row== 0 && (self.componentObject.type == CREDITCARD)) ){
        
        return 90; // For Server URL
    }
    else if ((indexPath.section==2 && indexPath.row==1 && ![[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]) ||( [[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && indexPath.row == 1 && indexPath.section == 4 && (self.componentObject.type == CHECKDEPOSIT || self.componentObject.type == BILLPAY)) || ( [[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && indexPath.row == 1 && indexPath.section == 5 && (self.componentObject.type == IDCARD || self.componentObject.type == CUSTOM))){
        
        return 115; // For Custom Fields
    }
    else if (([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && indexPath.section ==2 && indexPath.row == 0) || ([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && indexPath.section ==3 && indexPath.row == 0 && (self.componentObject.type == IDCARD || self.componentObject.type == CUSTOM)) ){
        
        return 50; // For Process Name or ID Type
        
    }
    
    return 44; // For All Others
    
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if((section == 1 &&  ![[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]) || (section == 3 && (self.componentObject.type == CHECKDEPOSIT || self.componentObject.type == BILLPAY)) || (section ==4 && (self.componentObject.type == IDCARD || self.componentObject.type == CUSTOM)) || (section ==2 && (self.componentObject.type == CREDITCARD))){
        
        return Klm(@"Server URL");
    }
    if (section==1 && [[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && self.componentObject.type!=CREDITCARD ) {
        return Klm(@"Account");
    }
    if(section ==1 && (self.componentObject.type == CREDITCARD)){
        return  Klm(@"Extract method");
    }
    if(([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && section == 4 && (self.componentObject.type == CHECKDEPOSIT || self.componentObject.type == BILLPAY)) || ([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && section == 4 && (self.componentObject.type == IDCARD || self.componentObject.type == CUSTOM))) {
        
        return Klm(@"Show All Fields");
    }
    
    if(section == 2 &&  [[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]){
        
        return Klm(@"Process Name");
        
    }
    
    if(section == 3 && [[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && (self.componentObject.type == IDCARD || self.componentObject.type == CUSTOM)){
        
        return Klm(@"ID Type");
        
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return  40;
    }
    else
    {
        return 30;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 && [self.rttiSettings valueForKey:ODE_SERVER_MODE] && self.componentObject.type==IDCARD) {
        UIView *vwForExtractionType = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        vwForExtractionType.backgroundColor = [UIColor whiteColor];
        vwForExtractionType.userInteractionEnabled = YES;
        
        UILabel  *lblExtractionType = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, vwForExtractionType.frame.size.width/2, 30)];
        lblExtractionType.text = Klm(@"Extraction Type");
        lblExtractionType.font = [UIFont fontWithName:FONTNAME size:14];
        lblExtractionType.textColor = [UIColor blackColor];
        lblExtractionType.textAlignment = NSTextAlignmentLeft;
        [vwForExtractionType addSubview:lblExtractionType];
        
        if (_segmentControlODE) {
            [_segmentControlODE removeFromSuperview];
            _segmentControlODE = nil;
        }
        _segmentControlODE = [[UISegmentedControl alloc]initWithItems:@[Klm(@"Server"),Klm(@"On Device")]];
        [_segmentControlODE setUserInteractionEnabled:self.isODEEnabledForSelectedRegion];
        if (!self.isODEEnabledForSelectedRegion) {
            [_segmentControlODE setAlpha:0.3];
        }
        
        _segmentControlODE.frame = CGRectMake(vwForExtractionType.frame.size.width-150, 5, 140, 30);
        [_segmentControlODE addTarget:self action:@selector(segmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
        
        if (((NSNumber*)[self.rttiSettings valueForKey:SERVER_MODE]).integerValue == [NSNumber numberWithInt:kOD_Extraction].integerValue) {
            if (_segmentControlODE.selectedSegmentIndex!=1) {
                [self showHideODEView:YES];
            }
            [_segmentControlODE setSelectedSegmentIndex:1];
        }else{
            if (_segmentControlODE.selectedSegmentIndex!=0) {
                [self showHideODEView:NO];
            }
            [_segmentControlODE setSelectedSegmentIndex:0];
        }
        [vwForExtractionType addSubview:_segmentControlODE];
        
        return vwForExtractionType;
    }
    return  nil;
}
-(void)segmentedControlValueDidChange:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:{
            //action for the first button (Current)
            [self showHideODEView:NO];
            break;}
        case 1:{
            [self showHideODEView:YES];
            break;}
    }
    [_table reloadData];
    [self.viewODE reloadTableData];
    
}

-(void)showHideODEView:(BOOL)show
{
    self.table.hidden = show;
    self.viewODE.hidden = !show;
    self.isODEActive = show;
    if (show) {
        [self.rttiSettings setValue:[NSNumber numberWithInt:kOD_Extraction] forKey:SERVER_MODE];
    }
    else{
        [self.rttiSettings setValue:[NSNumber numberWithInteger:self.extractionServerType.selectedSegmentIndex] forKey:SERVER_MODE];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //If component type is credit card and section is 1 i.e. if one of the "ExtractMethod" type is selected then reload the table
    if(indexPath.section==1 && self.componentObject.type==CREDITCARD){
    self.lastIndexPath = indexPath;
    [self.rttiSettings setValue:[NSString stringWithFormat:@"%ld",((long)indexPath.row)] forKey:EXTRACTMETHOD];
    [tableView reloadData];
    }
}

#pragma mark UITextViewDelegate Methods

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    if (textView == self.serverNameView) {
        NSString* key;
        // Save it based on Key
        if (self.mobileIDType==kMobile_ID_Server) {
            if ([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]) {
                // KTA
                key = KTASERVERURL;
            }
            else{
                // RTTI
                key = SERVERURL;
            }
        }
        else{
            if ([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]) {
                // KTA
                key = KTA_KOFAX_SERVER_URL;
            }
            else{
                // RTTI
                key = RTTI_KOFAX_SERVER_URL;
            }
        }
        [self.rttiSettings setValue:serverNameView.text forKey:key];
    }else if(textView == self.fieldsName){
        [self.rttiSettings setValue:self.fieldsName.text forKey:CUSTOMFIELDKEYVALUE];
    }
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    CGPoint pointInTable = [textView convertPoint:textView.bounds.origin toView:self.table];
    NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:pointInTable];
    CGRect  rect=[self.table rectForRowAtIndexPath:indexPath];
    [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@""] && textView == self.fieldsName && textView.text.length==1) {
        self.instructionLabel.hidden = NO;
    }
    
    if (![text isEqualToString:@"\n"] && text.length!=0 && textView.text.length == 0 && textView == self.fieldsName) {
        self.instructionLabel.hidden = YES;
    }
    
    if ([text isEqualToString:@""] && textView == self.serverNameView && textView.text.length==1) {
        self.serverInstructionLabel.hidden = NO;
    }
    
    if (![text isEqualToString:@"\n"] && text.length!=0 && textView.text.length == 0 && textView == self.serverNameView) {
        self.serverInstructionLabel.hidden = YES;
    }
    
    if ([text isEqualToString:@"\n"] && textView.text.length==0 && textView == self.serverNameView) {
        self.serverInstructionLabel.hidden = NO;
    }
    
    if ([text isEqualToString:@"\n"] && textView.text.length==0 && textView == self.fieldsName) {
        self.fieldsName.hidden = NO;
    }
    
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
    
    if (self.serverUsernameField == textField || self.serverPasswordField == textField ) {
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }
    else if (self.serverProcessName == textField){
        
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }
    else if (self.serverIDType == textField) {
        
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }
    else if (self.mobileIDTypeTextField == textField){
        [self.mobileIDPickerView selectRow:self.mobileIDType inComponent:0 animated:YES];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    // [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    if (self.serverUsernameField == textField) {
        if (self.mobileIDType == kMobile_ID_Server) {
            [self.rttiSettings setValue:textField.text forKey:KTAUSERNAME];
        }else{
            [self.rttiSettings setValue:textField.text forKey:KTA_KOFAX_USERNAME];
        }
    }else if(self.serverPasswordField == textField){
        if (self.mobileIDType == kMobile_ID_Server) {
            [self.rttiSettings setValue:textField.text forKey:KTAPASSWORD];
        }else{
            [self.rttiSettings setValue:textField.text forKey:KTA_KOFAX_PASSWORD];
        }
    }else if (self.serverProcessName == textField) {
        
        if (self.mobileIDType == kMobile_ID_Server) {
            [self.rttiSettings setValue:textField.text forKey:KTAPROCESSNAME];
        }else{
            [self.rttiSettings setValue:textField.text forKey:KTA_KOFAX_PROCESSNAME];
        }
        
    }else if (self.serverIDType == textField) {
        
        if (self.mobileIDType == kMobile_ID_Server) {
            [self.rttiSettings setValue:textField.text forKey:KTAIDTYPE];
        }else{
            [self.rttiSettings setValue:textField.text forKey:KTA_KOFAX_IDTYPE];
        }
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Local Methods
-(IBAction)showAllFieldsValueChanged:(UISwitch*)sender{
    [self.rttiSettings setValue:[NSNumber numberWithBool:sender.on] forKey:SHOWALLFIELDS];
    [self.table reloadData];
}

-(IBAction)showHighlightsValueChanged:(UISwitch*)sender{
    [self.rttiSettings setValue:[NSNumber numberWithBool:sender.on] forKey:HIGHLIGHTDATA];
    [self.table reloadData];
}

-(IBAction)saveOriginalImageValueChanged:(UISwitch*)sender{
    [self.rttiSettings setValue:[NSNumber numberWithBool:sender.on] forKey:SAVEORIGINALIMAGESWITCH];
    [self.table reloadData];
}

-(IBAction)segmentValueChanged:(UISegmentedControl*)sender{
    [self.rttiSettings setValue:[NSNumber numberWithInteger:sender.selectedSegmentIndex] forKey:SERVER_MODE];
    
    if(self.componentObject.type==CREDITCARD){
        if(sender.selectedSegmentIndex==0){
            [self.rttiSettings setValue:[NSNumber numberWithInt:kCCARDIO_Extraction] forKey:SERVER_MODE];
        }else{
            [self.rttiSettings setValue:[NSNumber numberWithInt:kRTTI_Extraction] forKey:SERVER_MODE];
        }
    }
    [self.standardDefaults setValue:[NSNumber numberWithInteger:sender.selectedSegmentIndex] forKey:ONLINE_SERVER_MODE];
    NSString *serverurl = [[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]?[self.rttiSettings valueForKey:KTASERVERURL]:[self.rttiSettings valueForKey:SERVERURL];
    self.serverNameView.text = serverurl;  //We should update "serverNameView" when server mode is changed because when we tap on back we are fetching from this field only.
    [self.table reloadData];
}

/*
 This method is used to go back to the previous screen and also save the RTTI settings.
 */

-(IBAction)backButtonAction:(id)sender{
    //    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    //    if (serverNameField.text.length==0) {
    //        [self showAlert:@"Please enter valid server name"];
    //    }else if(portNumberField.text.length==0 || ![utilitiesObject isAllDigits:portNumberField.text]){
    //        [self showAlert:@"Please enter valid port number"];
    //    }else{
    //        [self.rttiSettings setValue:serverNameField.text forKey:SERVERURL];
    //        [self.rttiSettings setValue:portNumberField.text forKey:SERVERPORT];
    
    //Checking wether "serverNameView" field is created or not, if not created then we are fetching server url from rttisettings.
    
    NSString *serverUrl = @"";
    NSString *licenseServerUrl = @"";
    if (self.serverNameView == nil) {
        if (self.componentObject.type != IDCARD) {
            NSString *serverurl = [[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]?[self.rttiSettings valueForKey:KTASERVERURL]:[self.rttiSettings valueForKey:SERVERURL];
            serverUrl = serverurl;
        }
        else{
            serverUrl = [self serverURLForIDFromSettings];
        }
        
    }
    else {
        serverUrl = self.serverNameView.text;
    }
    
    //Checking wether "fieldsName" is created or not, if not created then we are fetching custom fields from rttisettings.
    
    NSString *fields = @"";
    if (self.fieldsName == nil) {
        fields = [self.rttiSettings valueForKey:CUSTOMFIELDKEYVALUE];
    }
    else {
        fields = self.fieldsName.text;
    }
    
    if(self.componentObject.type!=CREDITCARD){
        if(self.componentObject.type == IDCARD && self.isODEActive){
            if (((NSNumber*)[self.rttiSettings valueForKey:ODE_SERVER_MODE]).boolValue) {
                licenseServerUrl = [NSString stringWithFormat:@"%@",[self.rttiSettings valueForKey:ODE_LICENSE_KTA_SERVER_URL]];
            }else{
                licenseServerUrl = [NSString stringWithFormat:@"%@",[self.rttiSettings valueForKey:ODE_LICENSE_RTTI_SERVER_URL]];
            }
        }
        
        if (self.componentObject.type == IDCARD && self.isODEActive && licenseServerUrl.length == 0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Klm(((NSNumber*)[self.rttiSettings valueForKey:ODE_SERVER_MODE]).boolValue?@"Invalid KTA URL":@"Invalid RTTI URL") message:Klm(((NSNumber*)[self.rttiSettings valueForKey:ODE_SERVER_MODE]).boolValue?@"Please enter a valid KTA URL":@"Please enter a valid RTTI URL") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
            [alert show];
            return;
        }else if (self.componentObject.type == IDCARD && self.isODEActive && [NSString stringWithFormat:@"%@",[self.rttiSettings valueForKey:ODE_MODELS_SERVER_URL]].length == 0) {
            [self showAlert:Klm(@"Please enter a valid Models server URL")];
    }
    else if ([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && (self.serverUsernameField.text.length == 0 || self.serverPasswordField.text.length == 0)) {
        [self showAlert:Klm(@"Please enter account details")];
    }else if ((serverUrl.length==0 || ![AppUtilities isValidURL:serverUrl]) && !self.isODEActive) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Klm([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]?@"Invalid KTA URL":@"Invalid RTTI URL") message:Klm([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]?@"Please enter a valid KTA URL":@"Please enter a valid RTTI URL") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
        [alert show];
    }else if (self.showAllFields !=nil && !self.showAllFields.on && fields.length==0 && self.componentObject.type == CUSTOM) {
        [self showAlert:Klm(@"Please enter custom fields")];
    }else if([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && self.serverProcessName.text.length == 0){
        [self showAlert:Klm(@"Please enter process name")];
    }else if ([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue] && self.serverIDType.text.length == 0 && (self.componentObject.type == IDCARD || (self.componentObject.type == CUSTOM && [self.componentObject.name isEqualToString:@"Passport"]))){
        
        [self showAlert:Klm(@"Please enter ID type")];
        
    }else{
        
        if(self.serverUsernameField!=nil){
            if (self.mobileIDType == kMobile_ID_Server) {
                [self.rttiSettings setValue:self.serverUsernameField.text forKey:KTAUSERNAME];
            }else{
                [self.rttiSettings setValue:self.serverUsernameField.text forKey:KTA_KOFAX_USERNAME];
            }
        }
        
        if(self.serverPasswordField!=nil) {
            if (self.mobileIDType == kMobile_ID_Server) {
                [self.rttiSettings setValue:self.serverPasswordField.text forKey:KTAPASSWORD];
            }else{
                [self.rttiSettings setValue:self.serverPasswordField.text forKey:KTA_KOFAX_PASSWORD];
            }
        }
        
        if(self.serverIDType != nil){
            if (self.mobileIDType == kMobile_ID_Server) {
                [self.rttiSettings setValue:self.serverIDType.text forKey:KTAIDTYPE];
            }else{
                [self.rttiSettings setValue:self.serverIDType.text forKey:KTA_KOFAX_IDTYPE];
            }
        }
        
        if(self.serverProcessName != nil){
            if (self.mobileIDType == kMobile_ID_Server) {
                [self.rttiSettings setValue:self.serverProcessName.text forKey:KTAPROCESSNAME];
            }else{
                [self.rttiSettings setValue:self.serverProcessName.text forKey:KTA_KOFAX_PROCESSNAME];
            }
        }
        ExtractionManager *extractionManager = [[ExtractionManager alloc] init];
        if (![extractionManager isLocalVersionAvailable:kfxKOEIDRegion_US] && self.isODEActive) {
            [AppUtilities removeActivityIndicator];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:Klm(@"Download Models first to continue with ODE") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
                
                [alertView show];
                
            });
        }
        
        [self.rttiSettings setValue:[NSNumber numberWithBool:self.showAllFields.on] forKey:SHOWALLFIELDS];
        [self.rttiSettings setValue:[NSNumber numberWithBool:self.highlightAreasSwitch.on] forKey:HIGHLIGHTDATA];
        [self.rttiSettings setValue:[NSNumber numberWithBool:self.saveOriginalImageSwitch.on] forKey:SAVEORIGINALIMAGESWITCH];
        [self.rttiSettings setValue:fields forKey:CUSTOMFIELDKEYVALUE];
        if ([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]) {
            if (self.componentObject.type != IDCARD ) {
                [self.rttiSettings setValue:serverUrl forKey:KTASERVERURL];
            }
            else{
                if (self.mobileIDType==kMobile_ID_Server) {
                    [self.rttiSettings setValue:serverUrl forKey:KTA_SERVER_URL];
                }
                else{
                    [self.rttiSettings setValue:serverUrl forKey:KTA_KOFAX_SERVER_URL];
                }
            }
            
        }else{
            if (self.componentObject.type != IDCARD) {
                [self.rttiSettings setValue:serverUrl forKey:SERVERURL];
            }
            else{
                if (self.mobileIDType==kMobile_ID_Server) {
                    [self.rttiSettings setValue:serverUrl forKey:SERVERURL];
                }
                else{
                    [self.rttiSettings setValue:serverUrl forKey:RTTI_KOFAX_SERVER_URL];
                }
            }
            
            
        }
        [self.standardDefaults setValue:[NSNumber numberWithInt:(int)self.extractionServerType.selectedSegmentIndex] forKey:ONLINE_SERVER_MODE];
       
      }
    }
    else{
        
        if ([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]) {
            [self.rttiSettings setValue:serverUrl forKey:SERVERURL];
        }
        [self.standardDefaults setValue:[NSNumber numberWithInt:(int)self.extractionServerType.selectedSegmentIndex] forKey:ONLINE_SERVER_MODE];

    }
    // Adding the saved mobile ID Type
    [self.rttiSettings setValue:[NSNumber numberWithInt:self.mobileIDType] forKey:MOBILE_ID_TYPE];
    
    [self.settings.settingsDictionary setValue:self.rttiSettings forKey:RTTISETTINGS];
    [[ProfileManager sharedInstance] updateProfile:[[ProfileManager sharedInstance]getActiveProfile]];
    [self.navigationController popViewControllerAnimated:YES];

}

/*
 This method is used to show the alert.
 */

-(void)showAlert:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:nil otherButtonTitles:Klm(@"OK"),nil];
    [alert show];
}
-(IBAction)switchValueChanged:(UISwitch*)sender{
    if (sender.tag==0) {
        [self.rttiSettings setValue:[NSNumber numberWithBool:sender.on] forKey:SHOWALLFIELDS];
    }
}



// picker delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return 2;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
    label.textAlignment = NSTextAlignmentCenter;
    switch (row) {
        case 0:
            label.text = Klm(@"Server Extraction");
            break;
        case 1:
            label.text = Klm(@"Server & Device Extraction");
            break;
            
        default:
            break;
    }
    [AppUtilities adjustFontSizeOfLabel:label];
    return label;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            self.mobileIDType = kMobile_ID_Server;
            break;
            
        case 1:
            self.mobileIDType = kMobile_ID_Server_And_Device;
            break;
            
        default:
            break;
    }
}

- (IBAction)doneButtonAction:(id)sender{
    [self.table reloadData];
}

- (UIPickerView*)pickerView{
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.tintColor = [self themeColor];
    return pickerView;
}

-(UIColor *)themeColor
{
    return [[[AppUtilities alloc] init]  colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
}

-(UIToolbar *)toolBar{
    AppUtilities *utilitiesObject = [[AppUtilities alloc] init];
    
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    [toolBar setBarTintColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor]];
    [toolBar sizeToFit];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]initWithTitle:Klm(@"Done") style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
    doneButton.tintColor = [utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.buttonTextColor];
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    
    utilitiesObject = nil;
    
    return toolBar;
}

-(NSString*)userNameFromSettings{
    if (self.mobileIDType==kMobile_ID_Server) {
        return [self.rttiSettings valueForKey:KTAUSERNAME];
    }
    else{
        return [self.rttiSettings valueForKey:KTA_KOFAX_USERNAME];
    }
}

-(NSString*)passwordFromSettings{
    if (self.mobileIDType==kMobile_ID_Server) {
        return [self.rttiSettings valueForKey:KTAPASSWORD];
    }
    else{
        return [self.rttiSettings valueForKey:KTA_KOFAX_PASSWORD];
    }
}

-(NSString*)processNameFromSettings{
    if (self.mobileIDType==kMobile_ID_Server) {
        return [self.rttiSettings valueForKey:KTAPROCESSNAME];
    }
    else{
        return [self.rttiSettings valueForKey:KTA_KOFAX_PROCESSNAME];
    }
}

-(NSString*)idTypeFromSettings{
    if (self.mobileIDType==kMobile_ID_Server) {
        return [self.rttiSettings valueForKey:KTAIDTYPE];
    }
    else{
        return [self.rttiSettings valueForKey:KTA_KOFAX_IDTYPE];
    }
}

- (NSString*)serverURLForIDFromSettings{
    NSString* serverurl;
    if ([[self.standardDefaults valueForKey:ONLINE_SERVER_MODE]boolValue]) {
        // KTA
        if (self.mobileIDType==kMobile_ID_Server) {
            serverurl = [self.rttiSettings valueForKey:KTASERVERURL];
        }
        else{
            serverurl = [self.rttiSettings valueForKey:KTA_KOFAX_SERVER_URL];
        }
    }
    else{
        // RTTI
        if (self.mobileIDType==kMobile_ID_Server) {
            serverurl = [self.rttiSettings valueForKey:SERVERURL];
        }
        else{
            serverurl = [self.rttiSettings valueForKey:RTTI_KOFAX_SERVER_URL];
        }
    }
    return serverurl;
}

@end
