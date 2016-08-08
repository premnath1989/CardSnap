//
//  ProfilesViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/13/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "ProfilesViewController.h"
#import "ProfileManager.h"
#import "CreateProfileViewController.h"
#import "PersistenceManager.h"
@interface ProfilesViewController ()
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property(nonatomic)int operationType;
@end

@implementation ProfilesViewController
@synthesize tableTopConstraint;
@synthesize dataArray;

#pragma mark Constructor Methods
-(id)initWithProfileAction: (profileAction)profileAction
{
    if(self = [super init])
    {
        self.operationType = profileAction;
    }
    
    return self;
}

#pragma mark ViewLifeCycle Methods

-(void)dealloc{
    self.dataArray = nil;
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
    //self.dataArray = [[NSMutableArray alloc]initWithObjects:[[ProfileManager sharedInstance] getAllProfiles], nil];
    self.dataArray = [[NSMutableArray alloc] initWithArray:[[ProfileManager sharedInstance] getListOfProfiles]];
    self.navigationItem.title = Klm(@"Profiles");
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
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
    return  [self.dataArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier" ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if ([[[ProfileManager sharedInstance]getActiveProfile].name isEqualToString:[[self.dataArray objectAtIndex:indexPath.row]valueForKey:@"profName"]]&&self.operationType == SELECT_PROFILE) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
    cell.textLabel.text = [[self.dataArray objectAtIndex:indexPath.row] valueForKey:@"profName"];
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return Klm(@"Select Profile");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    if(self.operationType == CLONE_PROFILE)
    {
        Profile *profileObject = [[ProfileManager sharedInstance]getProfileWithID:[[[self.dataArray objectAtIndex:indexPath.row] valueForKey:@"profId"] intValue ]];
        [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:profileObject.theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:profileObject.theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
         CreateProfileViewController *createProfileController = [[CreateProfileViewController alloc] initWithProfile:profileObject Withaction:CLONE_PROFILE];
        [self.navigationController pushViewController:createProfileController animated:YES];
    }
    else if(self.operationType ==  SELECT_PROFILE)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [[ProfileManager sharedInstance] setActiveProfileWithID:[[[self.dataArray objectAtIndex:indexPath.row] valueForKey:@"profId"] intValue ]];
        Profile* profileObject = [[ProfileManager sharedInstance] getActiveProfile];
        if (cell.accessoryType!=UITableViewCellAccessoryCheckmark) {
            [PersistenceManager storeUserLoginInfo:NO];
            [PersistenceManager storeRememberUserInfo:NO];
        }
        [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:profileObject.theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:profileObject.theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
        [self.navigationController popViewControllerAnimated:YES];
    }
    utilitiesObject = nil;
}

#pragma mark Local Methods
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)backButtonAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
