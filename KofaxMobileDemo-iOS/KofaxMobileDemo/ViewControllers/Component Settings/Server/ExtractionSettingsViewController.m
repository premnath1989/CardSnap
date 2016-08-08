//
//  ServerSettingsViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/16/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "ExtractionSettingsViewController.h"
#import "ProfileManager.h"
@interface ExtractionSettingsViewController ()
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, strong) UITextField *hostNameField,*portNumberField,*documentTypeField;
@property (nonatomic, assign) IBOutlet UITableView *table;
@end

@implementation ExtractionSettingsViewController
@synthesize tableTopConstraint;

#pragma mark ViewLifeCycle Methods

-(void)dealloc{
    self.hostNameField.delegate = nil;
    self.hostNameField = nil;
    self.portNumberField.delegate = nil;
    self.portNumberField = nil;
    self.documentTypeField.delegate = nil;
    self.documentTypeField = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant +=20;
    }else{
        self.tableTopConstraint.constant -=42;
    }
    self.navigationItem.title = Klm(@"Extraction Settings");
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.hostNameField.delegate = nil;
    self.portNumberField.delegate = nil;
    self.documentTypeField.delegate = nil;
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
        return 3;
    }else if(section==1){
        return 2;
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
            self.hostNameField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 200, 30) placeholder:Klm(@"Host name or IP address") andText:@""];
            self.hostNameField.delegate = self;
            cell.accessoryView = self.hostNameField;
        }else if(indexPath.section==0 && indexPath.row==1){
            UISwitch *sslSwitch = [[UISwitch alloc]init];
            cell.accessoryView = sslSwitch;
        }else if(indexPath.section==0 && indexPath.row==2){
            self.portNumberField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 100, 30) placeholder:Klm(@"Port Number") andText:@""];
            self.portNumberField.delegate = self;
            cell.accessoryView = self.portNumberField;
        }else if(indexPath.section==1 && indexPath.row==0){
            self.documentTypeField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 150, 30) placeholder:Klm(@"Used Document Type") andText:@""];
            self.documentTypeField.delegate = self;
            cell.accessoryView = self.documentTypeField;
        }else if(indexPath.section==1 && indexPath.row==1){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 0, [[UIScreen mainScreen]bounds].size.width-30, 44) andText:Klm(@"If the Document Type is not configured, a list containing all available ones will be shown")];
            label.numberOfLines = 0;
            cell.backgroundColor = [UIColor clearColor];
            label.font = [UIFont fontWithName:FONTNAME size:13];
            [cell.contentView addSubview:label];
        }
    }
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
    if (indexPath.section==0 && indexPath.row==0) {
        cell.textLabel.text = Klm(@"Server Path:");
    }else if(indexPath.section==0 && indexPath.row==1){
        cell.textLabel.text = Klm(@"Use SSL:");
    }else if(indexPath.section==0 && indexPath.row==2){
        cell.textLabel.text = Klm(@"Port");
    }else if(indexPath.section==1 && indexPath.row==0){
        cell.textLabel.text = Klm(@"Document Type");
    }
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return Klm(@"Extraction Settings");
    }else if(section==1){
        return Klm(@"Document Type");
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
}

#pragma mark UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == self.hostNameField) {
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.portNumberField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.documentTypeField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Local Methods
/*
 This method is used to go back to the previous screen and also save the server settings.
 */
-(IBAction)backButtonAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
