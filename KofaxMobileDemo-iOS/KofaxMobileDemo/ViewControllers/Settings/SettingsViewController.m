//
//  SettingsViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/13/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "SettingsViewController.h"
#import "ProfilesViewController.h"
#import "CreateProfileViewController.h"
#import "PersistenceManager.h"
#import "Version.h"

#define ArrowImageViewFrame CGRectMake(CGRectGetWidth(self.view.frame) - 35, 10, 14, 24)

@interface SettingsViewController ()
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic,strong)  IBOutlet UITableView* settingsTable;
@property (nonatomic, strong) Profile *importedProfile;
@end

@implementation SettingsViewController
@synthesize tableTopConstraint;

#pragma mark ViewLifeCycle Methods

-(void)dealloc{
    self.settingsTable.delegate = nil;
    self.settingsTable.dataSource = nil;
    self.settingsTable = nil;
    self.importedProfile = nil;
    self.table.delegate = nil;
    self.table.dataSource = nil;
    self.table = nil;
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
    self.navigationItem.title = Klm(@"Profile Settings");
   
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
    utilitiesObject = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.settingsTable reloadData];
    //self.navigationItem.leftBarButtonItem.title = @"Home";
    [super viewWillAppear:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
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



#pragma mark UIAlertViewDelegate Methods
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    
    if (alertView.tag==123 && buttonIndex==0) {
        [PersistenceManager storeUserLoginInfo:NO];
        [PersistenceManager storeRememberUserInfo:NO];
        [[ProfileManager sharedInstance]updateProfile:self.importedProfile];
        [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
        [self.table reloadData];
        
    }else if(alertView.tag==111 && buttonIndex==0){
        [PersistenceManager storeUserLoginInfo:NO];
        [PersistenceManager storeRememberUserInfo:NO];
        [[ProfileManager sharedInstance] deleteProfile:[[ProfileManager sharedInstance] getActiveProfile]];
        [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
        
        [self.table reloadData];
    }
    utilitiesObject = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        
    }
}



#pragma mark UITableViewDataSource and UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==3) {
        return 2;
    }else if(section==1){
        return 2;
    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier" ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if (indexPath.section==3 && indexPath.row == 0) {
            UILabel *programVersion = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 13, 130, 21) andText:Klm(@"App:")];
            NSString* appVersion = [NSString stringWithFormat:@"%s",BR];
            if ([appVersion hasPrefix:@"BUILD"])
            {
                appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
            }
            UILabel *programValue = [AppUtilities createLabelWithTag:0 frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-165, 13, 150, 21) andText:appVersion];
            UILabel *sdkVersion = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 37, 130, 21) andText:Klm(@"SDK:")];
            UILabel *sdkValue = [AppUtilities createLabelWithTag:0 frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-165, 37, 150, 21) andText:[AppUtilities getSDKVersion]];
            programValue.textAlignment = NSTextAlignmentRight;
            sdkValue.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:programVersion];
            [cell.contentView addSubview:programValue];
            [cell.contentView addSubview:sdkVersion];
            [cell.contentView addSubview:sdkValue];
        }else if(indexPath.section==3 && indexPath.row==1){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 0, [[UIScreen mainScreen]bounds].size.width-30, 70) andText:Klm(@"If you have any questions, comments or suggestions please contact Technical Support")];
            label.numberOfLines = 0;
            [cell.contentView addSubview:label];
        }else if(indexPath.section==0 && indexPath.row==0){
           
            UIImageView *arrowImageView = [[UIImageView alloc]initWithFrame:ArrowImageViewFrame];
            arrowImageView.image = [UIImage imageNamed:@"rightArrow.png"];
            [cell.contentView addSubview:arrowImageView];
        }
    }
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
    if (indexPath.section==0) {
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.text = Klm([[[ProfileManager sharedInstance] getActiveProfile] name]);
    }else if(indexPath.section == 1 && indexPath.row==0){
        cell.textLabel.text = Klm(@"Create Profile");
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }else if(indexPath.section == 1 && indexPath.row==1){
        cell.textLabel.text = Klm(@"Clone Profile");
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }else if(indexPath.section == 2){
        cell.textLabel.text = Klm(@"Export Profile");
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((indexPath.section==3 && indexPath.row==0)||(indexPath.section==3 && indexPath.row==1)) {
        return 75;
    }
    return 44;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return Klm(@"Active Profile");
    }else if(section==3){
        return Klm(@"Version Information");
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //For section 0 & 3 only have headers.
    
    if (section == 0 || section == 3) {
        return 44.0;
    }
    else {
        return 0.0;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 44)];
    UILabel *headerTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, CGRectGetWidth(headerView.frame) - 120, CGRectGetHeight(headerView.frame))];
    [headerTextLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
    [headerView addSubview:headerTextLabel];
    if (section == 0) {
        [headerTextLabel setText:Klm(@"Active Profile")];
        
         UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editButton setFrame:CGRectMake(CGRectGetWidth(tableView.frame) - 50, 0, 50, 44)];
        [editButton setImage:[UIImage imageNamed:EDITBUTTONIMAGE] forState:UIControlStateNormal];
         editButton.accessibilityLabel = Klm(@"Edit");
        [editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:editButton];
        
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setFrame:CGRectMake(CGRectGetWidth(tableView.frame) - 100, 0, 50, 44)];
        [deleteButton setImage:[UIImage imageNamed:DELETEBUTTONIMAGE] forState:UIControlStateNormal];
        deleteButton.accessibilityLabel = Klm(@"Delete");
        [deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:deleteButton];
  
    }
    else if (section == 3) {
        [headerTextLabel setText:Klm(@"Version Information")];
    }
    
    return headerView;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1)
    {
        
        if (indexPath.row==0)
        {
            AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
            Profile* emptyProfile = [[Profile alloc] init];
            [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:emptyProfile.theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:emptyProfile.theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
            CreateProfileViewController *createProfileController = [[CreateProfileViewController alloc] initWithProfile:emptyProfile Withaction:CREATE_PROFILE];
            [self.navigationController pushViewController:createProfileController animated:YES];
            utilitiesObject = nil;
        }
        else
        {
            ProfilesViewController *profileController = [[ProfilesViewController alloc] initWithProfileAction:CLONE_PROFILE];
            //profileController.operationType = 1;
            [self.navigationController pushViewController:profileController animated:YES];
            //            CreateProfileViewController *createProfileController = [[CreateProfileViewController alloc] initWithProfile:[[ProfileManager sharedInstance] getActiveProfile]];
            //            createProfileController.profileState = CLONE_PROFILE;
            //             [self.navigationController pushViewController:createProfileController animated:YES];
        }
        
    }
    else if (indexPath.section==0 && indexPath.row == 0)
    {
        ProfilesViewController *profileController = [[ProfilesViewController alloc]initWithProfileAction:SELECT_PROFILE];
        [self.navigationController pushViewController:profileController animated:YES];
    }
    else if(indexPath.section==2 && indexPath.row == 0)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:Klm(@"The Current Profile"),Klm(@"All Profiles"),Klm(@"Cancel"), nil];
        actionSheet.tag = 222;
        [actionSheet showInView:self.view];
    }
}

#pragma mark UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex==0)
    {
        NSMutableArray* profilesArray = [[NSMutableArray alloc] init];
        [profilesArray addObject:[[ProfileManager sharedInstance] getActiveProfile]];
        [self sendEmailForProfiles:profilesArray];
    }
    else if(buttonIndex==1)
    {
        NSMutableArray* profilesArray = [[NSMutableArray alloc] init];
        NSArray* listOfProfiles = [[ProfileManager sharedInstance] getListOfProfiles];
        
        for(int i=0; i < [listOfProfiles count];i++)
        {
            [profilesArray addObject:[[ProfileManager sharedInstance] getProfileWithID:[[[listOfProfiles objectAtIndex:i] valueForKey:@"profId"] intValue]]];
        }
        
        [self sendEmailForProfiles:profilesArray];
    }
    
}



#pragma mark MFMailComposerDelegate Methods

//Export Profiles
-(void)sendEmailForProfiles : (NSArray*)profileArray
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        
        NSString *mailBody;
        mailBody= [NSString stringWithFormat:Klm(@"To import a Kofax Mobile Demo Profile tap on the attached File and select 'Open in Kofax Mobile Demo'")];
        NSString* profileName;
        
        for(int i=0;i < [profileArray count];i++)
        {
            profileName = [[profileArray objectAtIndex:i] name];
            NSData* data = [[ProfileManager sharedInstance] getExportDataForProfile:[profileArray objectAtIndex:i]];
            
            if(data)
            {
                [mailController addAttachmentData:data mimeType:@"application/kofax mobile demo" fileName:[NSString stringWithFormat:@"%@.profile",profileName]];
                data = nil;
            }
        }
        [mailController setSubject: Klm(@"Kofax Mobile Demo - Exported Profile")];
        [mailController setMessageBody:mailBody isHTML:FALSE];
        [self presentViewController:mailController animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Klm(@"Error") message:Klm(@"Unable to create mail") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
        [alert show];
    }

}
//Sending email for exporting profile
-(void)sendEmailForProfileData: (NSData*)profileData withName:(NSString*)attachmentName
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        
        NSString *mailBody;
        mailBody= [NSString stringWithFormat:Klm(@"To import a Kofax Mobile Demo Profile tap on the attached File and select 'Open in Kofax Mobile Demo")];
        
        if (profileData)
        {
            [mailController addAttachmentData:profileData mimeType:@"application/kofax mobile demo" fileName:[NSString stringWithFormat:@"%@.profile",attachmentName]];
            [mailController setSubject: Klm(@"Kofax Mobile Demo - Exported Profile")];
            [mailController setMessageBody:mailBody isHTML:FALSE];
            [self presentViewController:mailController animated:YES completion:nil];
            
        }
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Klm(@"Error") message:Klm(@"Unable to create mail") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
    [self becomeFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark Local Methods
/*
 This method is used for editting the profile.
 */
-(IBAction)editButtonAction:(UITapGestureRecognizer*)sender
{
    CreateProfileViewController *createProfileController = [[CreateProfileViewController alloc] initWithProfile:[[ProfileManager sharedInstance] getActiveProfile] Withaction:EDIT_PROFILE];
    [self.navigationController pushViewController:createProfileController animated:YES];
}
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)backButtonAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
/*
 This method is used to delete the active profile and set the default profile as active.
 */
-(IBAction)deleteButtonAction:(UITapGestureRecognizer*)sender
{
    
    if([[[ProfileManager sharedInstance] getActiveProfile] profileID] == DEFAULTPROFILEID)
    {
        UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:nil message:Klm(@"Default profile cannot be deleted!!!") delegate:self cancelButtonTitle:nil otherButtonTitles:Klm(@"OK"), nil];
        [alertView show];
    }
    else
    {
        UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:nil message:Klm(@"Would you like to delete Active Profile?") delegate:self cancelButtonTitle:nil otherButtonTitles:Klm(@"Yes"),Klm(@"No"), nil];
        alertView.tag = 111;
        [alertView show];
        alertView = nil;
    }
    
}

-(void)importProfile:(NSURL*)url{
    if(![url isFileURL])
        return; //throw error may be
    
    NSData* importedProfileData = [NSData dataWithContentsOfURL:url];
    
    if(!importedProfileData)
        NSLog(@"error importing file"); //throw error
    
    NSArray *profileArray = [[ProfileManager sharedInstance]getListOfProfiles];
    
    PersistenceManager *storageManager = [[PersistenceManager alloc] init];
    JSONEngine *jsonEngine = [[JSONEngine alloc]init];
    NSDictionary *parsedProfileData = [jsonEngine parseJSONData:importedProfileData];
    int profileCounter = [storageManager getProfileCounter];
    self.importedProfile = [[Profile alloc] initWithParsedJSONData:parsedProfileData];
    BOOL sameNameExist = NO;
    for (NSDictionary *dict in profileArray) {
        if ([[dict valueForKey:@"profName"] isEqualToString:[[parsedProfileData valueForKey:METADATA]valueForKey:NAME]]) {
            self.importedProfile.profileID = [[dict valueForKey:@"profId"]intValue];
            sameNameExist = YES;
            break;
        }
    }
    
    if (sameNameExist) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Klm(@"Profile Alert!!") message:Klm(@"Profile with same name exists. Do you want to overwrite existing?") delegate:self cancelButtonTitle:nil otherButtonTitles:Klm(@"Yes"),Klm(@"No"), nil];
        alert.tag = 123;
        [alert show];
    }else{
        profileCounter++;
        self.importedProfile.profileID = profileCounter;
        [storageManager storeProfileCounter:profileCounter];
        NSData *newProfileData = [jsonEngine createJSONForProfile:self.importedProfile];
        NSString* jsonString = [[NSString alloc] initWithData:newProfileData encoding:NSUTF8StringEncoding];
        [storageManager addProfileWithName:self.importedProfile.name profileID:self.importedProfile.profileID AndContents:jsonString];
        [[ProfileManager sharedInstance] setActiveProfile:self.importedProfile];
        
        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:self.importedProfile.theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:self.importedProfile.theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
        utilitiesObject = nil;
    }
}
@end
