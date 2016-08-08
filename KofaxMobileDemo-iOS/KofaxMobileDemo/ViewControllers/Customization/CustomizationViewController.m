//
//  CustomizationViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/14/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "CustomizationViewController.h"
#import "SelectColorViewController.h"
#import "PersistenceManager.h"
#import "ProfileManager.h"
#import "BackgroundGraphicsViewController.h"
@interface CustomizationViewController ()<UITextFieldDelegate>
{
    UITextField *selectedTextField;
}
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, assign)Profile *profileObject;
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic, strong) UITextField *appTitleField,*footerField;
@property (nonatomic, strong) UISwitch *loginRequired;
@end

@implementation CustomizationViewController
@synthesize tableTopConstraint;

#pragma mark Constructor Methods
-(id)initWithProfile:(Profile*)profile{
    self = [super init];
    if (self) {
        self.profileObject = profile;
    }
    return self;
}

#pragma mark ViewLifeCycle Methods

-(void)dealloc{
    self.previewButton = nil;
    self.appTitleField.delegate = nil;
    self.appTitleField = nil;
    self.loginRequired = nil;
    self.footerField.delegate = nil;
    self.footerField = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant += 20;
    }else{
        self.tableTopConstraint.constant -=42;
    }
    self.navigationItem.title = Klm(@"Configure Theme");
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.table reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==2) {
        return 6;
    }else if(section==1){
        return 2;
    }else if(section==0){
        return 3;
    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier" ;
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if (indexPath.section==0 && indexPath.row==0) {
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 150, 22) andText:Klm(@"App Title:")];
            self.appTitleField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Please enter app title") andText:Klm(self.profileObject.appTitle)];
            self.appTitleField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.appTitleField];
        }else if(indexPath.section==0 && indexPath.row==1){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 150, 22) andText:Klm(@"Footer:")];
            self.footerField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Please enter footer") andText:Klm(self.profileObject.footer)];
            self.footerField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.footerField];
        }else if (indexPath.section==0 && indexPath.row==2) {
            self.loginRequired = [AppUtilities createSwitchWithTag:0 andValue:[NSNumber numberWithBool:self.profileObject.isLoginRequired]];
            [self.loginRequired addTarget:self action:@selector(loginRequiredChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = self.loginRequired;
            cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
            cell.textLabel.text = Klm(@"Login Required");
        }else if (indexPath.section==2 && indexPath.row==2) {
            UISegmentedControl *segmentedControl = [AppUtilities createSegmentedControlWithTag:1 items:[NSArray arrayWithObjects:Klm(@"Unicolor"),Klm(@"Gradient"), nil] andSelectedSegment:[self.profileObject.theme.buttonStyle intValue]];
            [segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
           // segmentedControl.frame = CGRectMake([[UIScreen mainScreen]bounds].size.width-185, 5, 170, 34);
            cell.accessoryView = segmentedControl;
        }else if(indexPath.section==2 && indexPath.row == 3){
            UISegmentedControl *segmentedControl = [AppUtilities createSegmentedControlWithTag:2 items:[NSArray arrayWithObjects:Klm(@"Rectangular"),Klm(@"Rounded"), nil] andSelectedSegment:[self.profileObject.theme.buttonBorder intValue]];
            [segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
           // segmentedControl.frame = CGRectMake([[UIScreen mainScreen]bounds].size.width-185, 5, 170, 34);
            cell.accessoryView = segmentedControl;
        }else if(indexPath.section==2 && indexPath.row == 5){
            self.previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.previewButton setTitle:Klm(@"BUTTON PREVIEW") forState:UIControlStateNormal];
            AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
            [self.previewButton setTitleColor:[utilitiesObject colorWithHexString:self.profileObject.theme.buttonTextColor] forState:UIControlStateNormal];
            [self.previewButton setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:self.profileObject.theme.buttonColor] withTheme:self.profileObject.theme] forState:UIControlStateNormal];
            utilitiesObject = nil;
            [self.previewButton setFrame:CGRectMake(20, 13, [[UIScreen mainScreen]bounds].size.width-40, 44)];
            [self.previewButton.titleLabel setFont:[UIFont fontWithName:FONTNAME size:17]];
            cell.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:self.previewButton];
        }
        if ((indexPath.section==1 && indexPath.row==0)||(indexPath.section==2 && indexPath.row<4)||(indexPath.section==0 && indexPath.row<2)){
            UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(15, (indexPath.section==0 && indexPath.row<2)?59.5f:43.5f, [[UIScreen mainScreen]bounds].size.width-15, 1)];
            line.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
            [cell.contentView addSubview:line];
        }
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
    if(indexPath.section==1 && indexPath.row==0){
        cell.textLabel.text = Klm(@"Header Color");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if(indexPath.section==1 && indexPath.row==1){
        cell.textLabel.text = Klm(@"Title Color");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if(indexPath.section==2 && indexPath.row==0){
        cell.textLabel.text = Klm(@"Button Color");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if(indexPath.section==2 && indexPath.row==1){
        cell.textLabel.text = Klm(@"Text Color");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if(indexPath.section==2 && indexPath.row==2){
        cell.textLabel.text = Klm(@"Color Style");
    }else if(indexPath.section==2 && indexPath.row==3){
        cell.textLabel.text = Klm(@"Corners");
    }else if(indexPath.section==2 && indexPath.row==4){
        cell.textLabel.text = Klm(@"Application Graphics");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return Klm(@"GENERAL TEXTS");
    }else if(section==1){
        return Klm(@"HEADERS");
    }else if(section==2){
        return Klm(@"BUTTONS");
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==2 && indexPath.row==5) {
        return 80;
    }else if(indexPath.section==0 && indexPath.row<2){
        return 60;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==2&&indexPath.row==0) {
        SelectColorViewController *selectColorController = [[SelectColorViewController alloc]initWithProfile:self.profileObject withType:BUTTON_COLOR];
        [self.navigationController pushViewController:selectColorController animated:YES];
    }if (indexPath.section==2&&indexPath.row==1) {
        SelectColorViewController *selectColorController = [[SelectColorViewController alloc]initWithProfile:self.profileObject withType:TEXT_COLOR];
        [self.navigationController pushViewController:selectColorController animated:YES];
    }else if(indexPath.section==1&&indexPath.row==0){
        SelectColorViewController *selectColorController = [[SelectColorViewController alloc]initWithProfile:self.profileObject withType:HEADER_COLOR];
        [self.navigationController pushViewController:selectColorController animated:YES];
    }else if(indexPath.section==1&&indexPath.row==1){
        SelectColorViewController *selectColorController = [[SelectColorViewController alloc]initWithProfile:self.profileObject withType:TITLE_COLOR];
        [self.navigationController pushViewController:selectColorController animated:YES];
    }else if(indexPath.section==2 && indexPath.row==4){
        BackgroundGraphicsViewController *graphicsController = [[BackgroundGraphicsViewController alloc]initWithProfile:self.profileObject];
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
    if (textField == self.appTitleField) {
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.footerField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
   // [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    if(textField == self.appTitleField){
        self.profileObject.appTitle = self.appTitleField.text;
    }else if(textField == self.footerField){
        self.profileObject.footer = self.footerField.text;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    [textField resignFirstResponder];
    if(textField == self.appTitleField){
        self.profileObject.appTitle = self.appTitleField.text;
    }else if(textField == self.footerField){
        self.profileObject.footer = self.footerField.text;
    }
    return YES;
}

#pragma mark Local Methods
/*
 This method is used to save the button styles.
 */
-(IBAction)segmentedControlAction:(UISegmentedControl*)sender{
    if (sender.tag==1) {
        self.profileObject.theme.buttonStyle = [NSNumber numberWithInteger:sender.selectedSegmentIndex];
    }else{
        self.profileObject.theme.buttonBorder = [NSNumber numberWithInteger:sender.selectedSegmentIndex];;
    }
    [self.table reloadData];
}

/*
 This method is used to save the login is required or not.
 */
-(IBAction)loginRequiredChanged:(UISwitch*)sender{
    [PersistenceManager storeUserLoginInfo:NO];
    self.profileObject.isLoginRequired = sender.on;
    [self.table reloadData];
}

/*
 This method is used to go back to the previous screen.
 */
-(IBAction)backButtonAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
