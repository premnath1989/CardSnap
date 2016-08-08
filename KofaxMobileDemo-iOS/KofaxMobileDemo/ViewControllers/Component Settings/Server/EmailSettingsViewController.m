//
//  EmailSettingsViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/16/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "EmailSettingsViewController.h"
#import "ProfileManager.h"
@interface EmailSettingsViewController ()
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, strong) UITextField *emailField,*demoField;
@property (nonatomic, assign) IBOutlet UITableView *table;
@end

@implementation EmailSettingsViewController
@synthesize tableTopConstraint;

#pragma mark ViewLifeCycle Methods
-(void)dealloc{
    self.emailField.delegate = nil;
    self.emailField = nil;
    self.demoField.delegate = nil;
    self.demoField = nil;
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
    self.navigationItem.title = Klm(@"Email Settings");
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.emailField.delegate = nil;
    self.demoField.delegate = nil;
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
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 4;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier" ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if (indexPath.row==0 && indexPath.section==0) {
            self.emailField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 200, 30) placeholder:Klm(@"Default Email Address") andText:@""];
            self.emailField.delegate = self;
            cell.accessoryView = self.emailField;
        }else if(indexPath.row==1){
            self.demoField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 200, 30) placeholder:Klm(@"Kofax Mobile Demo") andText:@""];
            self.demoField.delegate = self;
            cell.accessoryView = self.demoField;
        }else if(indexPath.row==2){
            UISwitch *attachSwitch = [AppUtilities createSwitchWithTag:0 andValue:[NSNumber numberWithBool:YES]];
            cell.accessoryView = attachSwitch;
        }else if(indexPath.row==3){
            UISwitch *evrsSwitch = [AppUtilities createSwitchWithTag:0 andValue:[NSNumber numberWithBool:YES]];
            cell.accessoryView = evrsSwitch;
        }
    }
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
    if (indexPath.row==0) {
        cell.textLabel.text = Klm(@"Recipient:");
    }else if(indexPath.row==1){
        cell.textLabel.text = Klm(@"Subject:");
    }else if(indexPath.row==2){
        cell.textLabel.text = Klm(@"Prompt for Attachment Name:");
    }else if(indexPath.row==3){
        cell.textLabel.text = Klm(@"Add Image Processor Settings to Mail Body:");
    }
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return Klm(@"Email Settings");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
}

#pragma mark UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == self.emailField) {
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.demoField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
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
 This method is used to go back to the previous screen and also save the email settings.
 */
-(IBAction)backButtonAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
