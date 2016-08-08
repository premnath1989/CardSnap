//
//  ComponentSettingsViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/15/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "ComponentSettingsViewController.h"
#import "CreateProfileViewController.h"
#import "AppDelegate.h"
#import "AdvancedSettingsViewController.h"
#import "EVRSSettingsViewController.h"
#import "CameraSettingsViewController.h"
#import "RTTISettingsViewController.h"
#import "SelectDestinationViewController.h"
#import "EmailSettingsViewController.h"
#import "ExtractionSettingsViewController.h"
#import "GeneralSettingsViewController.h"

#import "BackgroundGraphicsViewController.h"

@interface ComponentSettingsViewController ()
{
    UITextField *selectedTextField;
}
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, assign) IBOutlet UINavigationItem *navItem;
@property (nonatomic,strong) Component* component;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic, strong) UITextField *componentNameField;
@property (nonatomic,strong) NSMutableArray* componentSettingsArray;
@property (nonatomic, assign) Theme *themeObject;

@property (nonatomic) BOOL showComponentName;
@end

@implementation ComponentSettingsViewController
@synthesize tableTopConstraint;
@synthesize settingsArray;
@synthesize navItem;

#pragma mark Constructor Methods
-(id)initWithComponent : (Component*)component andTheme:(Theme*)themeObject
{
    if(self = [super init])
    {
        self.component = component;
        self.themeObject = themeObject;
        self.isODEEnabledForSelectedRegion = YES;
        self.isKofaxMobileIdEnabledForSelectedRegion = YES;
    }
    
    return self;
}


#pragma mark ViewLifeCycle Methods

-(void)dealloc{
    self.component = nil;
    self.componentNameField.delegate = nil;
    self.componentNameField = nil;
    self.componentSettingsArray = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant += 20;
    }else{
        self.tableTopConstraint.constant -=42;
    }
    self.navigationItem.title = Klm(@"Edit Component");
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    
    self.showComponentName = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    NSArray *controllersArray = self.navigationController.viewControllers;
    if ([controllersArray count]>2) {
        if (![[controllersArray objectAtIndex:[controllersArray count]-2] isKindOfClass:[CreateProfileViewController class]]) {
            self.showComponentName = NO;
        }
    }
    [self addComponentSettingsToArray];

    [self.table reloadData];
    

}

-(void)addComponentSettingsToArray{
    
    settingsArray = [[NSMutableArray alloc]init];
    /*If the component is credit card check extraction type
     If extraction type is cardIO do not add Camera Settings/Image Processor Settings
     */
    
    NSArray *keysArray = [self.component.settings.settingsDictionary allKeys];
    
    if(!([[[self.component.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:SERVER_MODE] boolValue] && self.component.type==CREDITCARD)){
        
        //Camera Settings and Processor settings are not required for credit card(CardIO)
        if ([keysArray containsObject:CAMERASETTINGS]) {
            [settingsArray addObject:Klm(@"Camera Settings")];
        }
        
        if ([keysArray containsObject:EVRSSETTINGS]) {
            [settingsArray addObject:Klm(@"Image Processor Settings")];
        }
    }
    
    if ([keysArray containsObject:RTTISETTINGS]) {
        [settingsArray addObject:Klm(@"Extraction Settings")];
    }
    
    if ([keysArray containsObject:ADVANCEDSETTINGS] && self.component.type==CHECKDEPOSIT) {
        [settingsArray addObject:Klm(@"Advanced Settings")];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    if (self.showComponentName) {
        self.component.name = self.componentNameField.text;
        self.componentNameField.delegate = nil;
    }
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
    if (self.showComponentName) {
        return 3;
    }
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0  && self.showComponentName) {
        return 1;
    }else if (section==2 && self.showComponentName) {
        if (self.component.type == CUSTOM) {
            return 1; //Removed component graphics row from settings because we changed flow of passport like paybils.
        }
        return 1;
    }else if (section==1 && !self.showComponentName) {
        if (self.component.type == CUSTOM) {
            return 1; //Removed component graphics row from settings because we changed flow of passport like paybils.
        }
        return 1;
    }else
    {
        //TO DO replace with actual settings
        return [settingsArray count];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier" ;
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.section==0 && self.showComponentName) {
        self.componentNameField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(15, 0, [[UIScreen mainScreen]bounds].size.width-30, 44) placeholder:Klm(@"Enter Component Name") andText:Klm(self.component.name)];
        self.componentNameField.font = [UIFont fontWithName:FONTNAME size:15];
        self.componentNameField.textAlignment = NSTextAlignmentLeft;
        self.componentNameField.delegate = self;
        [cell.contentView addSubview:self.componentNameField];
    }
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
//    if (indexPath.section==0 && indexPath.row==0) {
//        cell.textLabel.text = @"Submit to";
//        cell.detailTextLabel.text = self.component.submit;
//        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
//    }else if(indexPath.section==0 && indexPath.row==1){
//        cell.textLabel.text = @"Server Settings";
//        if ([[self.component.submit uppercaseString] isEqualToString:@"NONE"]) {
//            cell.textLabel.enabled = NO;
//        }else{
//            cell.textLabel.enabled = YES;
//        }
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }else
    if((indexPath.section==1 && self.showComponentName)||(indexPath.section==0 && !self.showComponentName)){
        cell.textLabel.text = [settingsArray objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if((indexPath.section==2 && indexPath.row==0 && self.showComponentName)|| (indexPath.section==1 && indexPath.row==0 && !self.showComponentName)){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = Klm(@"Edit Labels");
    }else if((indexPath.section==2 && indexPath.row==1 && self.component.type == CUSTOM && self.showComponentName)|| (indexPath.section==1 && indexPath.row==1 && self.component.type == CUSTOM && !self.showComponentName)){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = Klm(@"Component Graphics");
    }
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0 && self.showComponentName) {
        return Klm(@"Rename Component");
    }
    return nil;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((indexPath.section==1 && self.showComponentName)||(indexPath.section==0 && !self.showComponentName))
    {
        if ([[settingsArray objectAtIndex:indexPath.row] isEqualToString:Klm(@"Camera Settings")])
        {
            CameraSettingsViewController* cameraController = [[CameraSettingsViewController alloc] initWithSettings:self.component.settings andComponent:self.component];
            cameraController.themeObject = self.themeObject;
            [self.navigationController pushViewController:cameraController animated:YES];
        }
        else if([[settingsArray objectAtIndex:indexPath.row] isEqualToString:Klm(@"Image Processor Settings")])
        {
            EVRSSettingsViewController* evrsController = [[EVRSSettingsViewController alloc] initWithSettings:self.component.settings andComponent:self.component];
            evrsController.themeObject = self.themeObject;
            [self.navigationController pushViewController:evrsController animated:YES];
        }
        else if([[settingsArray objectAtIndex:indexPath.row] isEqualToString:Klm(@"Advanced Settings")])
        {
            AdvancedSettingsViewController *advancedController = [[AdvancedSettingsViewController alloc] initWithSettings:self.component.settings];
            [self.navigationController pushViewController:advancedController animated:YES];
        }
        else if([[settingsArray objectAtIndex:indexPath.row] isEqualToString:Klm(@"Extraction Settings")])
        {
            RTTISettingsViewController *rttiController = [[RTTISettingsViewController alloc]initWithSettings:self.component.settings component:self.component];
            rttiController.isODEEnabledForSelectedRegion = self.isODEEnabledForSelectedRegion;
            rttiController.isKofaxMobileIdEnabledForSelectedRegion = self.isKofaxMobileIdEnabledForSelectedRegion;
            [self.navigationController pushViewController:rttiController animated:YES];
        }
    }
    else if((indexPath.section==2 && indexPath.row==0 && self.showComponentName)||(indexPath.section==1 && indexPath.row==0 && !self.showComponentName)){
        GeneralSettingsViewController *generalSettingsController = [[GeneralSettingsViewController alloc]initWithComponent:self.component];
        [self.navigationController pushViewController:generalSettingsController animated:YES];
    }else if((indexPath.section==2 && indexPath.row==1 && self.component.type == CUSTOM && self.showComponentName)|| (indexPath.section==1 && indexPath.row==1 && self.component.type == CUSTOM && !self.showComponentName)){
        BackgroundGraphicsViewController *graphicsController = [[BackgroundGraphicsViewController alloc]initWithComponent:self.component];
        [self.navigationController pushViewController:graphicsController animated:YES];
    }
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
    CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
   // [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    self.component.name = textField.text;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Local Methods
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)backButtonAction:(id)sender{
    if(self.showComponentName)
    {
        if ([[self.componentNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]length]==0) {
            self.componentNameField.text = @"";
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Klm(@"Component Alert!!!") message:Klm(@"Component with empty name can't be saved. Please enter component name.") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
            [alert show];
        }
        else{
            
                [[ProfileManager sharedInstance] updateProfile:[[ProfileManager sharedInstance]getActiveProfile]];
                [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else{
        if (!self.showComponentName) {
            [[ProfileManager sharedInstance] updateProfile:[[ProfileManager sharedInstance]getActiveProfile]];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
