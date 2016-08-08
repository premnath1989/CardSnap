//
//  CreateProfileViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/13/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "CreateProfileViewController.h"
#import "SelectComponentViewController.h"
#import "CustomizationViewController.h"
#import "ProfilesViewController.h"
#import "ProfileManager.h"
#import "PersistenceManager.h"
#import "ComponentSettingsViewController.h"
#import "SettingsViewController.h"
@interface CreateProfileViewController () <UIAlertViewDelegate>
{
    UITextField *selectedTextField;
}
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, strong) NSMutableArray *componentsArray;
@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, assign) profileAction profileState;
@property (nonatomic, strong) UITextField *profileNameField;

@property (nonatomic, strong) NSString *profileName;

@property (nonatomic,strong)  Profile* emptyProfile;
@end

@implementation CreateProfileViewController

@synthesize tableTopConstraint;
@synthesize componentsArray;
@synthesize table;
@synthesize profileNameField;
@synthesize profileState;


#pragma mark Constructor Methods
-(id)initWithProfile: (Profile*)profile Withaction:(profileAction)action
{
    if(self = [super init])
    {
        if (action==EDIT_PROFILE) {
            self.emptyProfile = [[Profile alloc]init];
            self.emptyProfile.profileID = profile.profileID;
            self.emptyProfile.name = profile.name;
            self.emptyProfile.appTitle = profile.appTitle;
            self.emptyProfile.numberOfComponents = profile.numberOfComponents;
            self.emptyProfile.footer = profile.footer;
            self.emptyProfile.isLoginRequired = profile.isLoginRequired;
            self.emptyProfile.userName = profile.userName;
            self.emptyProfile.passWord = profile.passWord;
            self.emptyProfile.loginURL = profile.loginURL;
            self.emptyProfile.componentArray = profile.componentArray;
            Theme *themeObject = [[Theme alloc]init];
            themeObject.themeColor = profile.theme.themeColor;
            themeObject.titleColor = profile.theme.titleColor;
            themeObject.buttonBorder = profile.theme.buttonBorder;
            themeObject.buttonColor = profile.theme.buttonColor;
            themeObject.buttonStyle = profile.theme.buttonStyle;
            themeObject.buttonTextColor = profile.theme.buttonTextColor;
            self.emptyProfile.theme = themeObject;
            Graphics *graphicsObject = [[Graphics alloc]init];
            graphicsObject.logoImage = profile.graphics.logoImage;
            graphicsObject.loginScreenBackgroundImage = profile.graphics.loginScreenBackgroundImage;
            graphicsObject.homeScreenBackgroundImage = profile.graphics.homeScreenBackgroundImage;
            self.emptyProfile.graphics = graphicsObject;
        }else{
            self.emptyProfile = profile;
        }
        
        self.profileState = action;
    }
    
    return self;
}

#pragma mark ViewLifeCycle Methods

-(void)dealloc{
    self.componentsArray = nil;
    self.table.delegate = nil;
    self.table.dataSource = nil;
    self.table = nil;
    self.profileNameField.delegate = nil;
    self.profileNameField = nil;
    self.profileName = nil;
    self.emptyProfile = nil;
}
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
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    
    self.componentsArray = [self.emptyProfile.componentArray mutableCopy];
    self.profileName = [NSString stringWithFormat:@"%@",Klm(self.emptyProfile.name)];
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
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

-(void)viewWillAppear:(BOOL)animated
{
    if (profileState == EDIT_PROFILE)
        self.navigationItem.title = Klm(@"Edit Profile");
    
    else if(profileState == CREATE_PROFILE)
        self.navigationItem.title = Klm(@"Create New Profile");
    
    else
        self.navigationItem.title = Klm(@"Clone Profile");
    
    [self.table reloadData];
    [super viewWillAppear:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.profileName = self.profileNameField.text;
    self.profileNameField.delegate = nil;
}



#pragma mark UITableViewDataSource and UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==1) {
        return [componentsArray count]+1;
    }else if(section==2 || section==0||section==3){
        return 1;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier" ;
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.section==0) {
        self.profileNameField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(15, 0, [[UIScreen mainScreen]bounds].size.width-30, 44) placeholder:Klm(@"Enter Profile Name") andText:self.profileName];
        self.profileNameField.textAlignment = NSTextAlignmentLeft;
        self.profileNameField.font = [UIFont fontWithName:FONTNAME size:15];
        profileNameField.delegate = self;
//        if (profileState == EDIT_PROFILE || profileState == CLONE_PROFILE) {
//            profileNameField.text = self.profileName;
//        }
        [cell.contentView addSubview:profileNameField];
    }else if(indexPath.section==1 && indexPath.row== [componentsArray count]){
        UIButton *addComponentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addComponentBtn setTitle:Klm(@"Add Component") forState:UIControlStateNormal];
        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
       // [addComponentBtn setBackgroundColor: [UIColor colorWithRed:21.0f/255.0f green:123.0f/255.0f blue:191.0f/255.0f alpha:1.0f]];
        [addComponentBtn setTitleColor:[utilitiesObject colorWithHexString:self.emptyProfile.theme.buttonTextColor] forState:UIControlStateNormal];
        [addComponentBtn setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:self.emptyProfile.theme.buttonColor] withTheme:self.emptyProfile.theme] forState:UIControlStateNormal];
        utilitiesObject = nil;
        [addComponentBtn addTarget:self action:@selector(addComponentAction:) forControlEvents:UIControlEventTouchUpInside];
        [addComponentBtn setFrame:CGRectMake(20, 30, [[UIScreen mainScreen]bounds].size.width-40, 40)];
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:addComponentBtn];
    }else if(indexPath.section==3&&indexPath.row==0){
        UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (profileState == EDIT_PROFILE) {
            [saveBtn setTitle:Klm(@"Save Profile") forState:UIControlStateNormal];
            [saveBtn addTarget:self action:@selector(editProfile:) forControlEvents:UIControlEventTouchUpInside];
        }else if(profileState == CREATE_PROFILE){
            [saveBtn setTitle:Klm(@"Create Profile") forState:UIControlStateNormal];
            [saveBtn addTarget:self action:@selector(createProfileAction:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [saveBtn setTitle:Klm(@"Clone Profile") forState:UIControlStateNormal];
            [saveBtn addTarget:self action:@selector(createProfileAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        [saveBtn setTitleColor:[utilitiesObject colorWithHexString:self.emptyProfile.theme.buttonTextColor] forState:UIControlStateNormal];
        [saveBtn setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:self.emptyProfile.theme.buttonColor] withTheme:self.emptyProfile.theme] forState:UIControlStateNormal];
        utilitiesObject = nil;
        //[saveBtn setBackgroundColor:[UIColor colorWithRed:21.0f/255.0f green:123.0f/255.0f blue:191.0f/255.0f alpha:1.0f]];
        [saveBtn setFrame:CGRectMake(20, 10, [[UIScreen mainScreen]bounds].size.width-40, 40)];
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:saveBtn];
    }else if(indexPath.section==1 && [componentsArray count]>indexPath.row){
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake([[UIScreen mainScreen]bounds].size.width-100, 0, 100, 44)];
        
  
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editButton setFrame:CGRectMake(50, 0, 50, 44)];
        editButton.tag = indexPath.row;
        [editButton setImage:[UIImage imageNamed:EDITBUTTONIMAGE] forState:UIControlStateNormal];
        editButton.accessibilityLabel = Klm(@"Edit");
        [editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:editButton];
        
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setFrame:CGRectMake(0, 0, 50, 44)];
        deleteButton.tag = indexPath.row;
        [deleteButton setImage:[UIImage imageNamed:DELETEBUTTONIMAGE] forState:UIControlStateNormal];
        deleteButton.accessibilityLabel = Klm(@"Delete");
        [deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:deleteButton];

        
        
        if (indexPath.row<([componentsArray count]-1)) {
            UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(15, 43.5f, [[UIScreen mainScreen]bounds].size.width-120, 1)];
            line.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
            [cell.contentView addSubview:line];
        }
        cell.accessoryView = view;
        //[cell.contentView addSubview:view];
        view = nil;
    }
    if (indexPath.section==1 && (indexPath.row<componentsArray.count)) {
        cell.textLabel.text = Klm([[componentsArray objectAtIndex:indexPath.row]valueForKey:@"name"]);
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if(indexPath.section==2 && indexPath.row==0){
        cell.textLabel.text = Klm(@"Configure Theme");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
    return cell;
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return Klm(@"Profile Name");
    }else if(componentsArray.count>0 && section==1){
        return Klm(@"List of Components");
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     if(indexPath.section==3 && indexPath.row==0){
        return 60;
     }else if(indexPath.section==1 && indexPath.row== [componentsArray count]){
         return 80;
     }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==2 && indexPath.row ==0) {
        CustomizationViewController *customController = [[CustomizationViewController alloc]initWithProfile:self.emptyProfile];
        [self.navigationController pushViewController:customController animated:YES];
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
    //[self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    self.profileName = textField.text;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==111) {
        if (buttonIndex==0) {
            if (profileState == EDIT_PROFILE) {
                [self editProfile:nil];
            }else if(profileState == CREATE_PROFILE || profileState == CLONE_PROFILE){
                [self createProfileAction:nil];
            }
        }else{
            NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            for (UIViewController *aViewController in allViewControllers) {
                if ([aViewController isKindOfClass:[SettingsViewController class]]) {
                    [self.navigationController popToViewController:aViewController animated:YES];
                }
            }
            AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
            [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
            utilitiesObject = nil;
        }
    }else {
        if(buttonIndex == 0)
        {
            //[self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            //over write existing profile
            [[ProfileManager sharedInstance] updateProfile:self.emptyProfile];
            AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
            [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:self.emptyProfile.theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:self.emptyProfile.theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
            utilitiesObject = nil;
            NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            for (UIViewController *aViewController in allViewControllers) {
                if ([aViewController isKindOfClass:[SettingsViewController class]]) {
                    [self.navigationController popToViewController:aViewController animated:YES];
                }
            }
        }
    }
}

#pragma mark Local Methods
/*
 This method is used to create new profile or clone the existing profile.
 */
-(IBAction)createProfileAction:(id)sender{
    [self.profileNameField resignFirstResponder];
    self.emptyProfile.name = self.profileNameField.text;
    if([[self.profileNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        self.profileNameField.text = @"";
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Klm(@"Profile Alert!!!") message:Klm(@"Profile with empty name can't be created. Please enter a name.") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    self.emptyProfile.componentArray = self.componentsArray;
    int error = [[ProfileManager sharedInstance] createNewProfile:self.emptyProfile];
    if(error == 0)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Klm(@"Profile Alert!!!") message:Klm(@"Profile with same name exists. Do you want to overwrite existing?") delegate:self cancelButtonTitle:Klm(@"NO") otherButtonTitles:Klm(@"YES"), nil];
        [alert show];
    }
    else if(error == 1)
    {
        profileNameField.delegate = nil;
        if(self.profileState == CLONE_PROFILE)
        {
            NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            for (UIViewController *aViewController in allViewControllers) {
                if ([aViewController isKindOfClass:[SettingsViewController class]]) {
                    [self.navigationController popToViewController:aViewController animated:YES];
                }
            }
            
        }
        else if(self.profileState == CREATE_PROFILE)
            [self.navigationController popViewControllerAnimated:YES];
        
        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:self.emptyProfile.theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:self.emptyProfile.theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
        utilitiesObject = nil;
        [PersistenceManager storeUserLoginInfo:NO];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Klm(@"Profile Alert!!!") message:Klm(@"Profile cant be created") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
        [alert show];
    }
    
}
/*
 This method is used to save the editted profile.
 */
-(IBAction)editProfile:(id)sender
{
    if([[self.profileNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        self.profileNameField.text = @"";
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Klm(@"Profile Alert!!!") message:Klm(@"Profile with empty name cant be saved. Please enter a name.") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
        [alert show];
        return;
    }
    NSMutableArray *profileArray = [[NSMutableArray alloc] initWithArray:[[ProfileManager sharedInstance] getListOfProfiles]];
    BOOL isAlreadyExist = NO;
    for (NSDictionary *profileDict in profileArray) {
        if ([[profileDict valueForKey:@"profName"] isEqualToString:self.profileNameField.text]&& [[profileDict valueForKey:@"profId"]intValue] != self.emptyProfile.profileID) {
            isAlreadyExist = YES;
        }
    }
    if (isAlreadyExist) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Klm(@"Profile Alert!!") message:Klm(@"Profile with same name exists. Please enter another name.") delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
        [alert show];
    }else{
        self.emptyProfile.name = self.profileNameField.text;
        self.emptyProfile.componentArray = self.componentsArray;
        [[ProfileManager sharedInstance] updateProfile:self.emptyProfile];
        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:self.emptyProfile.theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:self.emptyProfile.theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
        utilitiesObject = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}
/*
 This method is used to push the screen to select component controller.
 */
-(IBAction)addComponentAction:(id)sender
{
    SelectComponentViewController *selectComponentController = [[SelectComponentViewController alloc] initwithArray:self.componentsArray andTheme:self.emptyProfile.theme];
    [self.navigationController pushViewController:selectComponentController animated:YES];
}
/*
 This method is used to edit the selected component settings.
 */
-(IBAction)editButtonAction:(UIButton *)sender
{
    ComponentSettingsViewController *componentSettingsController = [[ComponentSettingsViewController alloc] initWithComponent:[self.componentsArray objectAtIndex:sender.tag] andTheme:self.emptyProfile.theme];
    [self.navigationController pushViewController:componentSettingsController animated:YES];
}
/*
 This method is used to delete the selected component.
 */
-(IBAction)deleteButtonAction:(UIButton *)sender
{
    [self.componentsArray removeObjectAtIndex:sender.tag];
   // [[self.emptyProfile componentArray] removeObjectAtIndex:sender.tag];
    [self.table reloadData];
}
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)backButtonAction:(id)sender{
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:Klm(@"Do you want to save your changes?") delegate:self cancelButtonTitle:nil otherButtonTitles:Klm(@"Yes"),Klm(@"No"), nil];
    alert.tag= 111;
    [alert show];
}

@end
