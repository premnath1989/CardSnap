//
//  LoginViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/17/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PersistenceManager.h"
#import "ProfileManager.h"
@interface LoginViewController ()
@property (nonatomic, assign) IBOutlet UITextField *usernameField,*passwordField,*emailField;
@property (nonatomic, assign) IBOutlet UIButton *rememberButton,*loginButton;
@property (nonatomic, assign) IBOutlet UILabel *background1,*background2;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *viewTopConstraint,*viewLeftConstraint,*backgroundTopConstraint;
@property (nonatomic, assign) IBOutlet UIImageView *backGroundImage,*logoImage;
@property (nonatomic, assign) Profile *profileObject;
@property (nonatomic, assign) IBOutlet UIView *loginView;

@property (nonatomic, assign) IBOutlet UILabel *footerLabel;

@property (weak, nonatomic) IBOutlet UILabel *rememberMeLabel;
@property (nonatomic, assign) CGRect defaultFrame;

@property (nonatomic, strong) UIImage *checkedImage,*uncheckedImage;
@end

@implementation LoginViewController
@synthesize usernameField,passwordField,emailField;
@synthesize rememberButton,loginButton;
@synthesize background1,background2;
@synthesize viewTopConstraint,viewLeftConstraint;
@synthesize loginView;
@synthesize defaultFrame;

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
    self.checkedImage = nil;
    self.uncheckedImage = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    background1.layer.cornerRadius = 2;
    loginButton.layer.cornerRadius = 2;
    background1.layer.borderWidth = 1;
    background1.layer.borderColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.7f].CGColor;
    background2.layer.cornerRadius = 2;
    background2.layer.borderWidth = 1;
    background2.layer.borderColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.7f].CGColor;
    if ([usernameField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed:118.0f/255.0f green:141.0f/255.0f blue:158.0f/255.0f alpha:1.0f];
        usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Klm(@"Username") attributes:@{NSForegroundColorAttributeName: color}];
        passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Klm(@"Password") attributes:@{NSForegroundColorAttributeName: color}];
        emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Klm(@"Email Address") attributes:@{NSForegroundColorAttributeName: color}];
    }
    self.rememberMeLabel.text = Klm(self.rememberMeLabel.text);
    [self.loginButton setTitle:Klm(self.loginButton.titleLabel.text) forState:UIControlStateNormal];
    self.footerLabel.text = Klm(self.footerLabel.text);
    self.checkedImage = [UIImage imageNamed:CHECKBUTTONIMAGE];
    self.uncheckedImage = [UIImage imageNamed:UNCHECKBUTTONIMAGE];
    
    
    CGFloat actualWidth = [[UIScreen mainScreen]bounds].size.width;
    CGFloat deductedWidth = actualWidth-320;
    CGFloat leftPosition = deductedWidth/2;
    self.viewLeftConstraint.constant = leftPosition;
    self.navigationItem.title = @"Login";
    if ([PersistenceManager getRememberUserInfo]) {
        NSMutableDictionary *userDetails = [PersistenceManager getUserLoginInfo];
        usernameField.text = [userDetails valueForKey:USERNAMEVALUE];
        passwordField.text = [userDetails valueForKey:PASSWORDVALUE];
        [rememberButton setImage:self.checkedImage forState:UIControlStateNormal];
        emailField.text = [userDetails valueForKey:EMAILVALUE];
    }else{
        usernameField.text = @"";
        passwordField.text = @"";
        emailField.text = @"";
        [rememberButton setImage:self.uncheckedImage forState:UIControlStateNormal];
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    self.defaultFrame = CGRectMake(self.viewLeftConstraint.constant, self.viewTopConstraint.constant, self.loginView.frame.size.width, self.loginView.frame.size.height);
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    if (self.profileObject.graphics.loginScreenBackgroundImage.length != 0) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            UIImage *homeImage = [utilitiesObject getImageFromBase64String:self.profileObject.graphics.loginScreenBackgroundImage];
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.backGroundImage.image = homeImage;
            });
        });
    }else{
        self.backGroundImage.image = [UIImage imageNamed:@"login screen_bg.png"];
    }
    if (self.profileObject.graphics.logoImage.length != 0) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
            UIImage *homeImage = [utilitiesObject getImageFromBase64String:self.profileObject.graphics.logoImage];
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.logoImage.image = homeImage;
            });
        });
    }else{
        self.logoImage.image = [UIImage imageNamed:@"kofax_logo.png"];
    }
    
    self.footerLabel.text = [NSString stringWithFormat:@"%@",self.profileObject.footer ];
    
    [self.loginButton setTitleColor:[utilitiesObject colorWithHexString:self.profileObject.theme.buttonTextColor] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:self.profileObject.theme.buttonColor] withTheme:self.profileObject.theme] forState:UIControlStateNormal];
    self.loginButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.loginButton.layer.borderWidth = 1.0;
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

#pragma mark UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: 0.3];
    if (textField==usernameField) {
        self.viewTopConstraint.constant = self.defaultFrame.origin.y-50;
        [self.loginView setFrame:CGRectMake(self.defaultFrame.origin.x, self.defaultFrame.origin.y-50 , self.defaultFrame.size.width, self.defaultFrame.size.height)];
    }else if(textField==passwordField){
        self.viewTopConstraint.constant = self.defaultFrame.origin.y-100;
        [self.loginView setFrame:CGRectMake(self.defaultFrame.origin.x, self.defaultFrame.origin.y-100 , self.defaultFrame.size.width, self.defaultFrame.size.height)];
    }else if(textField==emailField){
        self.viewTopConstraint.constant = self.defaultFrame.origin.y-150;
        [self.loginView setFrame:CGRectMake(self.defaultFrame.origin.x, self.defaultFrame.origin.y-150 , self.defaultFrame.size.width, self.defaultFrame.size.height)];
    }
    [UIView commitAnimations];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    // [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: 0.3];
    self.viewTopConstraint.constant = self.defaultFrame.origin.y;
    self.loginView.frame = defaultFrame;
    [UIView commitAnimations];
    return YES;
}

#pragma mark Local Methods
/*
 This method is used for login.
 */
-(IBAction)loginButtonAction:(id)sender{
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    if (usernameField.text.length==0) {
        [self showAlert:Klm(@"Please enter username")];
    }else if(passwordField.text.length==0){
        [self showAlert:Klm(@"Please enter password")];
    }else if(emailField.text.length==0){
        [self showAlert:Klm(@"Please enter email address")];
    }else if(![utilitiesObject isValidEmail:emailField.text]){
        [self showAlert:Klm(@"Please enter valid email address")];
    }else{
        if (rememberButton.imageView.image == self.checkedImage) {
            [PersistenceManager storeRememberUserInfo:YES];
            NSMutableDictionary *userDetails = [[NSMutableDictionary alloc]init];
            [userDetails setValue:usernameField.text forKey:USERNAMEVALUE];
            [userDetails setValue:passwordField.text forKey:PASSWORDVALUE];
            [userDetails setValue:emailField.text forKey:EMAILVALUE];
            [PersistenceManager storeLoginInfo:userDetails];
        }else{
            [PersistenceManager storeRememberUserInfo:NO];
        }
        [PersistenceManager storeUserLoginInfo:YES];
        [self dismissViewControllerAnimated:NO completion:^{
        }];
    }
    utilitiesObject = nil;
}

/*
 This method is used to show the alert.
 @param: message.
 */
-(void)showAlert:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
    [alert show];
}
/*
 This method is used to check or uncheck the remember button.
 */
-(IBAction)rememberButtonAction:(id)sender{
    if (rememberButton.imageView.image == self.checkedImage) {
        [rememberButton setImage:self.uncheckedImage forState:UIControlStateNormal];
    }else{
        [rememberButton setImage:self.checkedImage forState:UIControlStateNormal];
    }
}


@end
