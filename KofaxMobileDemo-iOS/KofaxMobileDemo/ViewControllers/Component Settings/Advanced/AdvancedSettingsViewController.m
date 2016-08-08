//
//  ValidationSettingsViewController.m
//  BankRight
//
//  Created by Rambabu N on 8/26/14.
//  Copyright (c) 2014 WIN Information Technology. All rights reserved.
//

#import "AdvancedSettingsViewController.h"
#import "ProfileManager.h"
@interface AdvancedSettingsViewController ()
@property (nonatomic, strong)  UISwitch *checkForDuplicateSwitch,*searchMICRSwitch,*useHandPrintSwitch,*showCheckInfoSwitch, *showCheckGuidance;
@property (nonatomic, strong)  UISegmentedControl *useValidation,*useExtraction;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, strong) NSMutableDictionary *advancedSettings;
@property (nonatomic, assign) Settings* settings;
@end

@implementation AdvancedSettingsViewController
@synthesize checkForDuplicateSwitch,searchMICRSwitch,useHandPrintSwitch,showCheckInfoSwitch, showCheckGuidance;
@synthesize useValidation,useExtraction;
@synthesize tableTopConstraint;
@synthesize advancedSettings;


-(void)dealloc{
    self.checkForDuplicateSwitch = nil;
    self.searchMICRSwitch = nil;
    self.useHandPrintSwitch = nil;
    self.showCheckInfoSwitch = nil;
    self.showCheckGuidance = nil;
    self.useValidation = nil;
    self.useExtraction = nil;
    self.advancedSettings = nil;
}

#pragma mark Constructor Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithSettings: (Settings*)settings
{
    if(self = [super init])
    {
        self.settings = settings;
        self.advancedSettings = [[self.settings.settingsDictionary valueForKey:ADVANCEDSETTINGS] mutableCopy];
    }
    
    return self;
}

#pragma ViewLifeCycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant +=20;
    }else{
        self.tableTopConstraint.constant -=42;
    }
    
    self.navigationItem.title = Klm(@"Advanced Settings");
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource and UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        
        if([self.advancedSettings.allKeys containsObject:FIRSTTIMELAUNCHDEMO]){
            
             return [[self.advancedSettings allKeys]count]-3;
        }
        else {
            
                return [[self.advancedSettings allKeys]count]-2;
        }
       
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = TABLECELLIDENTIFIER ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if (indexPath.section==0 && indexPath.row==0) {
            self.searchMICRSwitch = [AppUtilities createSwitchWithTag:(int)indexPath.row andValue:[advancedSettings valueForKey:SEARCHMICR]];
            [self.searchMICRSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = searchMICRSwitch;
            
        }else if(indexPath.section==0&&indexPath.row==1){
            self.useHandPrintSwitch = [AppUtilities createSwitchWithTag:(int)indexPath.row andValue:[advancedSettings valueForKey:USEHANDPRINT]];
            [self.useHandPrintSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = useHandPrintSwitch;
        }else if(indexPath.section==0&&indexPath.row==2){
            
            if ([[advancedSettings valueForKey:CHECKVALIDATIONSERVER]boolValue]) {
                self.useValidation = [AppUtilities createSegmentedControlWithTag:0 items:[NSArray arrayWithObjects:Klm(@"Local"),Klm(@"Server"), nil] andSelectedSegment:1];
            }else{
                self.useValidation = [AppUtilities createSegmentedControlWithTag:0 items:[NSArray arrayWithObjects:Klm(@"Local"),Klm(@"Server"), nil] andSelectedSegment:0];
            }
            [self.useValidation addTarget:self action:@selector(validateServerAction:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = useValidation;
            
        }else if(indexPath.section==0&&indexPath.row==3){
            self.checkForDuplicateSwitch = [AppUtilities createSwitchWithTag:(int)indexPath.row andValue:[advancedSettings valueForKey:CHECKFORDUPLICATES]];
            [self.checkForDuplicateSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = checkForDuplicateSwitch;
        }else if (indexPath.section==0 && indexPath.row==4) {
            self.showCheckInfoSwitch = [AppUtilities createSwitchWithTag:(int)indexPath.row andValue:[advancedSettings valueForKey:SHOWCHECKINFO]];
            [self.showCheckInfoSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = self.showCheckInfoSwitch;
        }
        else if (indexPath.section==0 && indexPath.row==6) {
            self.showCheckGuidance = [AppUtilities createSwitchWithTag:(int)indexPath.row andValue:[advancedSettings valueForKey:SHOWCHECKGUIDINGDEMO]];
            [self.showCheckGuidance addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = self.showCheckGuidance;
        }
        if (indexPath.section==0 && indexPath.row==5) {
            
            if ([[advancedSettings valueForKey:CHECKEXTRACTION] intValue] == 2) {
                self.useExtraction = [AppUtilities createSegmentedControlWithTag:0 items:[NSArray arrayWithObjects:Klm(@"Front"),Klm(@"Both"), nil] andSelectedSegment:1];
            }else{
                self.useExtraction = [AppUtilities createSegmentedControlWithTag:0 items:[NSArray arrayWithObjects:Klm(@"Front"),Klm(@"Both"), nil] andSelectedSegment:0];
            }
            [self.useExtraction addTarget:self action:@selector(sideForExtraction:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = self.useExtraction;
            
        }
    }
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
    if (indexPath.section==0 && indexPath.row==0) {
        cell.textLabel.text = Klm(@"Search MICR:");
    }else if(indexPath.section==0 && indexPath.row==1){
        cell.textLabel.text = Klm(@"Use Hand Print:");
    }else if(indexPath.section==0 && indexPath.row==2){
        cell.textLabel.text = Klm(@"Check Validation:");
    }else if(indexPath.section==0 && indexPath.row==3){
        cell.textLabel.text = Klm(@"Check For Duplicates:");
    }else if(indexPath.section==0 && indexPath.row==4){
        cell.textLabel.text = Klm(@"Show Check Info:");
    }
    else if(indexPath.section==0 && indexPath.row==6){
        cell.textLabel.text = Klm(@"Show Check Guiding Demo:");
    }else if(indexPath.section==0 && indexPath.row==5){
        cell.textLabel.text = Klm(@"Check Extraction:");
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
        return 70;
    }
    return 44;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma Mark Local Methods
/*
 This method is used to go back to the previous screen and also save the advanced settings.
 */
-(IBAction)backButtonAction:(id)sender{
    [self.settings.settingsDictionary setValue:self.advancedSettings forKey:ADVANCEDSETTINGS];
    [[ProfileManager sharedInstance] updateProfile:[[ProfileManager sharedInstance]getActiveProfile]];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 This method is called when the search micr or use hand print or check for duplicates switch value is changed.
 */
-(IBAction)switchValueChanged:(UISwitch*)sender{
    if (sender.tag==0) {
        [self.advancedSettings setValue:[NSNumber numberWithBool:sender.on] forKey:SEARCHMICR];
    }else if(sender.tag==1){
        [self.advancedSettings setValue:[NSNumber numberWithBool:sender.on] forKey:USEHANDPRINT];
    }else if(sender.tag==3){
        [self.advancedSettings setValue:[NSNumber numberWithBool:sender.on] forKey:CHECKFORDUPLICATES];
    }else if(sender.tag==4){
        [self.advancedSettings setValue:[NSNumber numberWithBool:sender.on] forKey:SHOWCHECKINFO];
    }
    else if(sender.tag==6){
        
        [self.advancedSettings setValue:[NSNumber numberWithBool:sender.on] forKey:SHOWCHECKGUIDINGDEMO];
        
        if(!sender.on){
            
            [self.advancedSettings setValue:[NSNumber numberWithBool:sender.on] forKey:FIRSTTIMELAUNCHDEMO];
        }
    }
    //[self.navigationController popViewControllerAnimated:YES];
}
/*
 This method is called when the validation server value is changed.
 */
-(IBAction)validateServerAction:(UISegmentedControl*)sender{
    [self.advancedSettings setValue:[NSNumber numberWithInteger:sender.selectedSegmentIndex] forKey:CHECKVALIDATIONSERVER];
}

/*
 This method is called when check front or both value is selected.
 */
-(IBAction)sideForExtraction:(UISegmentedControl*)sender{
    [self.advancedSettings setValue:[NSNumber numberWithInteger:sender.selectedSegmentIndex+1] forKey:CHECKEXTRACTION];
}
@end