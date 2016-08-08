//
//  AppStatsViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/16/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "AppStatsViewController.h"
#import "AppDelegate.h"
#import "PersistenceManager.h"
#import "ProfileManager.h"
@interface AppStatsViewController ()
{
    AppDelegate *appdelegate;

}
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic, strong)UITextField *exportUrlField;
@property (nonatomic, strong)UISwitch *enableSwitch;
@property (nonatomic, strong)UISegmentedControl *formatSegment;
@property (nonatomic, strong)  UITextField *txtRamThreshold;
@property (nonatomic, strong)  UITextField *txtFilehold;


@property (nonatomic, strong) NSMutableDictionary *appStatsInfo;
@end

@implementation AppStatsViewController
@synthesize tableTopConstraint;
@synthesize txtRamThreshold;
@synthesize txtFilehold;

-(void)dealloc{
    self.exportUrlField.delegate = nil;
    self.exportUrlField = nil;
    self.enableSwitch = nil;
    self.formatSegment = nil;
    self.appStatsInfo = nil;
    
    self.txtRamThreshold.delegate = nil;
    self.txtRamThreshold = nil;

    self.txtFilehold.delegate = nil;
    self.txtFilehold = nil;

}
#pragma mark ViewLifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant +=20;
    }else{
        self.tableTopConstraint.constant -=42;
    }
    self.navigationItem.title = Klm(@"App Stats Settings");
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    
    self.appStatsInfo = [PersistenceManager getAppStatsInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.exportUrlField.delegate = nil;
    self.txtFilehold.delegate = nil;
    self.txtRamThreshold.delegate = nil;

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
        return 5;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier" ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if (indexPath.section==0 && indexPath.row==0) {
            self.enableSwitch = [AppUtilities createSwitchWithTag:0 andValue:[self.appStatsInfo valueForKey:ENABLEAPPSTATS]];
            [self.enableSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = self.enableSwitch;
        }else if(indexPath.section==0&&indexPath.row==1){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(CGRectGetWidth(self.view.frame) - 60, 10, 60, 22) andText:Klm(@"JSON")];
            [cell.contentView addSubview:label];
            
        }else if(indexPath.section==0&&indexPath.row==2){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 100, 22) andText:Klm(@"Export URL:")];
            self.exportUrlField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Export URL") andText:[self.appStatsInfo valueForKey:EXPORTURL]];
            self.exportUrlField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.exportUrlField];
            
        }
        else if(indexPath.section ==0 && indexPath.row == 3)
        {
            
            NSString *ramThreshold = [NSString stringWithFormat:@"%d",appdelegate.appStatsObj.ramSizeThreshold/1000];
            
            self.txtRamThreshold = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 100, 25) placeholder:@"" andText:ramThreshold];
            self.txtRamThreshold.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            self.txtRamThreshold.delegate = self;
            
            cell.accessoryView = self.txtRamThreshold;

        }
        else if(indexPath.section ==0 && indexPath.row == 4)
        {
            NSString *fileThreshold = [NSString stringWithFormat:@"%d",appdelegate.appStatsObj.fileSizeThreshold/1000];

            self.txtFilehold = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 100, 25) placeholder:@"" andText:fileThreshold];
            self.txtFilehold.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            self.txtFilehold.delegate = self;
            
            cell.accessoryView = self.txtFilehold;
            
        }

    }
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
    if (indexPath.section==0 && indexPath.row==0) {
        cell.textLabel.text = Klm(@"Enable App Stats:");
    }else if(indexPath.section==0 && indexPath.row==1){
        cell.textLabel.text = Klm(@"Export Format:");
    }else if(indexPath.section==0 && indexPath.row==3){
        cell.textLabel.text = Klm(@"RAM Threshold (KB):");
    }else if(indexPath.section==0 && indexPath.row==4){
        cell.textLabel.text = Klm(@"File Threshold (KB):");
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((indexPath.section==0 && indexPath.row==2)||indexPath.section==1) {
        return 70;
    }
    return 44;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if(textField==self.txtRamThreshold){
        
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }
    else if(textField==self.txtFilehold){
        
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }
    else
    {
    CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }

}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if([textField isEqual:self.txtRamThreshold]){
        appdelegate.appStatsObj.ramSizeThreshold = [textField.text floatValue]*1000;
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",appdelegate.appStatsObj.ramSizeThreshold] forKey:RAMTHRESHOLDLIMIT];

    }
    else     if([textField isEqual:self.txtFilehold]){
        
        appdelegate.appStatsObj.fileSizeThreshold = [textField.text floatValue]*1000;
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",appdelegate.appStatsObj.fileSizeThreshold] forKey:FILETHRESHOLDLIMIT];
    }
    else
    {
        [self.appStatsInfo setValue:textField.text forKey:EXPORTURL];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if([textField isEqual:self.txtRamThreshold]){
        appdelegate.appStatsObj.ramSizeThreshold = [textField.text floatValue]*1000;
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",appdelegate.appStatsObj.ramSizeThreshold] forKey:RAMTHRESHOLDLIMIT];

    }
    else if([textField isEqual:self.txtFilehold]){
        appdelegate.appStatsObj.fileSizeThreshold = [textField.text floatValue]*1000;
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",appdelegate.appStatsObj.fileSizeThreshold] forKey:FILETHRESHOLDLIMIT];

    }

    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Local Methods
/*
 This method is used to go back to the previous screen and also save the app stats settings.
 */
-(IBAction)backButtonAction:(id)sender{
    if ((self.enableSwitch.on && self.exportUrlField.text.length == 0) || (self.enableSwitch.on && ![AppUtilities isValidURL:self.exportUrlField.text])) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Klm(@"Invalid Export URL") message:Klm(@"Please enter a valid export URL") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
        [alert show];
    }else{
        [PersistenceManager storeAppStats:self.appStatsInfo];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(IBAction)switchValueChanged:(UISwitch*)sender{
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    if (sender.on) {
        [delegate.appStatsObj startRecord];
    }else{
        [delegate.appStatsObj stopRecord];
    }
    [self.appStatsInfo setValue:[NSNumber numberWithBool:sender.on] forKey:ENABLEAPPSTATS];
}

-(IBAction)segmentValueChanged:(UISegmentedControl*)sender{
    [self.appStatsInfo setValue:[NSNumber numberWithInteger:sender.selectedSegmentIndex] forKey:EXPORTFORMAT];
}
@end
