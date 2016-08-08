//
//  HomeViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/13/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "HomeViewController.h"
#import "SettingsViewController.h"
#import "ProfileManager.h"
#import "AppStatsViewController.h"
#import "LoginViewController.h"
#import "DLManager.h"
#import "BPManager.h"
#import "CDManager.h"
#import "CustomComponentManager.h"
#import "CreditCardManager.h"
#import "PersistenceManager.h"

@interface HomeViewController ()
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint,*backgroundTopConstraint;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic, assign) IBOutlet UIImageView *backGroundImage;
@property (nonatomic,strong)  UITableViewCell *cell;
@property(nonatomic,strong) ProfileManager* profileManager;
@property(nonatomic,strong) DLManager* dlManager;
@property(nonatomic,strong) BPManager *bpManager;
@property(nonatomic,strong)CustomComponentManager *customComponentManager;
@property (nonatomic,strong)CDManager *cdManager;
@property (nonatomic,strong) CreditCardManager *cCardManager;

@property (nonatomic,strong) AppUtilities *utilitiesObject;
@end

@implementation HomeViewController
@synthesize tableTopConstraint;
@synthesize dataArray;
@synthesize table;

#pragma mark ViewLifeCycle Methods

-(void)dealloc{
    self.dataArray = nil;
    self.cell = nil;
    self.profileManager = nil;
    if (self.dlManager) {
        [self.dlManager unloadManager];
        self.dlManager = nil;
    }
    if (self.bpManager) {
        [self.bpManager unloadBillPayManager];
        self.bpManager = nil;
    }
    if (self.customComponentManager) {
        [self.customComponentManager unloadManager];
        self.customComponentManager = nil;
    }
    if (self.cCardManager) {
        [self.cCardManager unloadManager];
        self.cCardManager = nil;
    }
    if (self.cdManager) {
        [self.cdManager unloadCheckDepositManager];
        self.cdManager = nil;
    }
    self.utilitiesObject = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant += 20;
        self.backgroundTopConstraint.constant +=20;
    }else{
        self.tableTopConstraint.constant -=42;
        self.backgroundTopConstraint.constant -= 42;
    }
    self.profileManager = [ProfileManager sharedInstance];
    
    self.table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.utilitiesObject = [[AppUtilities alloc]init];
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 68, 44)];
    UIButton *appstatsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [appstatsButton setImage:[UIImage imageNamed:APPSTATSBUTTONIMAGE] forState:UIControlStateNormal];
    [appstatsButton addTarget:self action:@selector(appStatsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    appstatsButton.frame = CGRectMake(0, 0, 34, 44);
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setImage:[UIImage imageNamed:SETTINGSBUTTONIMAGE] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(settingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    settingsButton.frame = CGRectMake(34, 0, 34, 44);
    
    [rightView addSubview:appstatsButton];
    [rightView addSubview:settingsButton];
    rightView.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
    //        rightItem.tintColor = [utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.titleColor];
    //    }
    
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.hidesBackButton = YES;

    [self.utilitiesObject setThemeColor:[self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor] andTitleColor:[self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
    
    
}

-(void) updateNavForVoiceover
{
    
 //  UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.navigationItem.titleView);
    
  //  [self.navigationController.titleView becomeFirstResponder];
    
    [self.table becomeFirstResponder];
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.table);
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    //Resetting country code when user comes to home screen.
    
    if (self.dlManager) {
        [self.dlManager unloadManager];
        self.dlManager = nil;
    }
    if (self.bpManager) {
        [self.bpManager unloadBillPayManager];
        self.bpManager = nil;
    }
    if (self.customComponentManager) {
        [self.customComponentManager unloadManager];
        self.customComponentManager = nil;
    }
    if (self.cCardManager) {
        [self.cCardManager unloadManager];
        self.cCardManager = nil;
    }
    if (self.cdManager) {
        [self.cdManager unloadCheckDepositManager];
        self.cdManager = nil;
    }
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"userLoggedIn"]) {
        //AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"logout_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonAction:)];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            logoutButton.tintColor = [UIColor whiteColor];
        }
        self.navigationItem.leftBarButtonItem = logoutButton;
        //utilitiesObject = nil;
    }else{
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    if (self.profileManager.getActiveProfile.isLoginRequired && ![PersistenceManager isUserLoggedIn]) {
        LoginViewController *loginController = [[LoginViewController alloc]initWithProfile:self.profileManager.getActiveProfile];
        [self.navigationController presentViewController:loginController animated:NO completion:^{
            
        }];
    }else{
        self.navigationItem.title = Klm(self.profileManager.getActiveProfile.appTitle);
        self.dataArray = [[self.profileManager getActiveProfile] componentArray];
        [self.table reloadData];
        
       
    }
    
    if (self.profileManager.getActiveProfile.graphics.homeScreenBackgroundImage.length != 0) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
            UIImage *homeImage = [utilitiesObject getImageFromBase64String:self.profileManager.getActiveProfile.graphics.homeScreenBackgroundImage];
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.backGroundImage.image = homeImage;
            });
        });
    }else{
        self.backGroundImage.image = [UIImage imageNamed:@"custom login screen.png"];
    }
    
    
    [self performSelector:@selector(updateNavForVoiceover) withObject:nil afterDelay:0.5];

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



#pragma mark UITableViewDataSource and UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier" ;
    
    self.cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(self.cell == nil)
    {
        self.cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [self.cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(15, 9, 39, 42)];

        imageView1.backgroundColor = [self.utilitiesObject colorWithHexString:self.profileManager.getActiveProfile.theme.themeColor];
        imageView1.image = [UIImage imageNamed:SHIELDIMAGE];
        imageView1.tag = 5;
        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(15, 9, 39, 42)];
        imageView2.backgroundColor = [UIColor clearColor];
        imageView2.tag = 10;
        
        [self.cell.contentView addSubview:imageView1];
        [self.cell.contentView addSubview:imageView2];
        
        UILabel *textLabel = [AppUtilities createLabelWithTag:0 frame:CGRectMake(62, 0, 230, 60) andText:[[self.dataArray objectAtIndex:indexPath.row] valueForKey:@"name"]];
        textLabel.tag = 15;
        [self.cell.contentView addSubview:textLabel];
        textLabel = nil;
        
        self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    Component *componentObject = [self.dataArray objectAtIndex:indexPath.row];
    UIImageView *imgview2 = (UIImageView*)[self.cell viewWithTag:10];
    if (componentObject.type==CHECKDEPOSIT) {
        imgview2.image = [UIImage imageNamed:CHECKDEPOSITICON];
    }else if(componentObject.type == BILLPAY){
        imgview2.image = [UIImage imageNamed:PAYBILLSICON];
    }else if(componentObject.type==IDCARD){
        imgview2.image = [UIImage imageNamed:DRIVERLICENSEICON];
    }else if(componentObject.type==CUSTOM){
        if ([[componentObject.componentGraphics.graphicsDictionary valueForKey:HOMEIMAGELOGO]length]!=0) {
            imgview2.image = [self.utilitiesObject getImageFromBase64String:[componentObject.componentGraphics.graphicsDictionary valueForKey:HOMEIMAGELOGO]];
        }else{
            imgview2.image = [UIImage imageNamed:CUSTOMICON];
        }
        
    }else if(componentObject.type == CREDITCARD){
        imgview2.image = [UIImage imageNamed:CREDITCARDICON];
    }
    
    UILabel *textL = (UILabel*)[self.cell viewWithTag:15];
    textL.text = Klm(componentObject.name);
    
    UIImageView *imgView1 = (UIImageView*)[self.cell viewWithTag:5];
    imgView1.backgroundColor = [self.utilitiesObject colorWithHexString:self.profileManager.getActiveProfile.theme.themeColor];
    
    return self.cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return Klm(self.profileManager.getActiveProfile.name);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //clean up all local images(frontRaw,Front Processed , BackRaw ,backProcess)
    [[AppStateMachine sharedInstance] cleanUpDisk];
    
    Component *componentObject = [self.dataArray objectAtIndex:indexPath.row];
    if (componentObject.type == BILLPAY) {
        self.bpManager = [[BPManager alloc]init];
        [self.bpManager loadBillPayManager:self.navigationController andComponent:componentObject];
    }
    else if(componentObject.type  == IDCARD)
    {
        self.dlManager = [[DLManager alloc] initWithComponent:componentObject];
        [self.dlManager loadManager:self.navigationController];
    }
    else if(componentObject.type  == CHECK_DEPOSIT){
        
        self.cdManager = [[CDManager alloc] init];
        [self.cdManager loadCheckDepositManager:self.navigationController andComponent:componentObject];
    }else if(componentObject.type  == CUSTOM){
        
        self.customComponentManager = [[CustomComponentManager alloc]init];
        [self.customComponentManager loadCustomComponentManager:self.navigationController andComponent:componentObject];
    }else if(componentObject.type == CREDITCARD){
        self.cCardManager = [[CreditCardManager alloc]init];
        [self.cCardManager loadCreditCardManager:self.navigationController andComponent:componentObject];
    }
}

/*- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
 
 UILabel *myLabel = [[UILabel alloc] init];
 myLabel.frame = CGRectMake(20, 8, 320, 20);
 myLabel.font = [UIFont boldSystemFontOfSize:18];
 myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
 
 UIView *headerView = [[UIView alloc] init];
 [headerView addSubview:myLabel];
 
 return headerView;
 }*/

#pragma mark Local Methods
/*
 This method is used to push to settings controller.
 */
-(IBAction)settingsButtonAction:(id)sender{
    SettingsViewController *settingsController = [[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:nil];
    [self.navigationController pushViewController:settingsController animated:YES];
}
/*
 This method is used to push to app stats controller.
 */
-(IBAction)appStatsButtonAction:(id)sender{
    AppStatsViewController *appStatsController = [[AppStatsViewController alloc]initWithNibName:@"AppStatsViewController" bundle:nil];
    [self.navigationController pushViewController:appStatsController animated:YES];
}

-(IBAction)logoutButtonAction:(id)sender{
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"userLoggedIn"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    LoginViewController *loginController = [[LoginViewController alloc]initWithProfile:self.profileManager.getActiveProfile];
    [self presentViewController:loginController animated:NO completion:^{
        
    }];
}

@end
