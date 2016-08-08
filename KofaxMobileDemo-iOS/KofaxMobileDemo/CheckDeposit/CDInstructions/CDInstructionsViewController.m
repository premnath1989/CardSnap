//
//  CDInstructionsViewController.m
//  KofaxMobileDemo
//
//  Created by Rambabu N on 10/31/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "CDInstructionsViewController.h"

//#import "CDHistoryViewController.h"

#import "CDSummaryViewController.h"
#import "ComponentSettingsViewController.h"
#import "AppStateMachine.h"
#import "PersistenceManager.h"


#define textFieldFont       [UIFont fontWithName:@"HelveticaNeue" size:12]


@interface CDInstructionsViewController () <UIActionSheetDelegate,UITextFieldDelegate>
{
    NSString *userEnteredAmount;
}

@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic, assign) Component *componentObject;

@property (nonatomic, retain) NSString *accountType;
@property (nonatomic, assign) IBOutlet UIToolbar* keyboardToolbar;

@property (nonatomic, assign) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, weak) AppStateMachine *appStateMachine;
@property (nonatomic) UIButton *settingsButton;


@property (assign) BOOL showCheckInfo;

@end

@implementation CDInstructionsViewController

@synthesize checkFront = _checkFront;
@synthesize checkBack = _checkBack;
@synthesize checkResults = _checkResults;




#pragma mark Constructor Methods
-(id)initWithComponent: (Component*)component
{
    if(self = [super init]){
        
        self.componentObject = component;
        _cdState = 0;
        _checkAmount = @"";
    }
    
    return self;
}
#pragma mark ViewLifeCycle Methods

-(void)dealloc{
    
    self.accountType = nil;
    self.checkBack = nil;
    self.checkFront = nil;
    self.checkResults = nil;
    self.checkAmount = nil;
    
    [self cleanTheRawImages];
    
    
    if (self.checkProcessedFront) {
        [self.checkProcessedFront clearImageBitmap];
        self.checkProcessedFront = nil;
    }
    
    if (self.checkProcessedBack) {
        [self.checkProcessedBack clearImageBitmap];
        self.checkProcessedBack = nil;
    }
    
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    //    NSLog(@"All Texts = %@\n",self.componentObject.texts.summaryText);
    
    _accountType = Klm(@"Checking");
    [self.doneButton setTitle:Klm(self.doneButton.title)];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant += 20;
    }else{
        
        self.tableTopConstraint.constant -=42;
    }
    
    if(!self.utilitiesObject)
    {
    self.utilitiesObject = [[AppUtilities alloc]init];
    }
    self.keyboardToolbar.barTintColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
    self.doneButton.tintColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.titleColor];
    
    
    
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 68, 44)];
    
    UIButton *historyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [historyButton setImage:[UIImage imageNamed:@"check_history_icon.png"] forState:UIControlStateNormal];
    [historyButton addTarget:self action:@selector(checkHistoryAction:) forControlEvents:UIControlEventTouchUpInside];
    historyButton.frame = CGRectMake(0, 0, 34, 44);
    
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingsButton setImage:[UIImage imageNamed:SETTINGSBUTTONIMAGE] forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(settingsButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.settingsButton.frame = CGRectMake(34, 0, 34, 44);
    
    [rightView addSubview:historyButton];
    [rightView addSubview:self.settingsButton];
    rightView.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    self.navigationItem.title = Klm(@"Check Deposit");
    
    self.table.separatorColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self.settingsButton setEnabled:YES];
    
    UITableViewCell *tempCell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    UITextField *textField = (UITextField*)[[tempCell contentView] viewWithTag:10];
    textField.delegate = nil;  //Delegate should be nil, because we are checking amount value when keyboard is down it may unappropriate results.
    [textField resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES]; 
    [self setNavigationLeftItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.settingsButton setEnabled:!self.disableSettings];
    
    _showCheckInfo = [[[self.componentObject.settings.settingsDictionary valueForKey:ADVANCEDSETTINGS] valueForKey:SHOWCHECKINFO] boolValue];
    
    [self.table reloadData];
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
    return 6;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"cellIdentifier" ;
    
    NSDictionary *summaryTextDict = self.componentObject.texts.summaryText;
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if(indexPath.row==0){
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, [[UIScreen mainScreen]bounds].size.width-30, 140)];
        label.numberOfLines = 0;
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
        [AppUtilities adjustFontSizeOfLabel:label];

        NSString *string = @"";
        
        
        NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc]init];
        [attrString setAttributedString:[[NSAttributedString alloc]initWithString:string]];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:6];
        [attrString addAttribute:NSParagraphStyleAttributeName
                           value:style
                           range:NSMakeRange(0, string.length)];
        
        label.attributedText = attrString;
        [label setTextAlignment:NSTextAlignmentCenter];
        
        [cell.contentView addSubview:label];
    }
    else if(indexPath.row==1){
        
        
        UILabel *line2= [[UILabel alloc]initWithFrame:CGRectMake(15, 49, [[UIScreen mainScreen] bounds].size.width-15, 1)];
        line2.backgroundColor = [UIColor lightGrayColor];
        
        
        UILabel *depositTo = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 150, 22)];
        depositTo.text = Klm([summaryTextDict valueForKey:DEPOSITTO]);
        depositTo.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
        [AppUtilities adjustFontSizeOfLabel:depositTo];

        
        UILabel *accountTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen]bounds].size.width-140, 8, 100, 30)];
        accountTypeLabel.textAlignment = NSTextAlignmentRight;
        accountTypeLabel.font = [UIFont fontWithName:@"HelveticaNeue-bold" size:15];
        [AppUtilities adjustFontSizeOfLabel:accountTypeLabel];
        accountTypeLabel.text = _accountType;
        
        
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [cell.contentView addSubview:depositTo];
        [cell.contentView addSubview:accountTypeLabel];
        [cell.contentView addSubview:line2];
        
        
    }
    else if(indexPath.row == 3){
        
        
        UIButton *checkFront = [UIButton buttonWithType:UIButtonTypeCustom];
        checkFront.contentMode = UIViewContentModeCenter;
        checkFront.exclusiveTouch = YES;
        
        if(!self.checkFront){
            
            [checkFront setImage:[UIImage imageNamed:@"check_front.png"] forState:UIControlStateNormal];
        }
        else{
            
            [checkFront setImage:[AppUtilities imageWithImage:self.checkFront scaledToSize:CGSizeMake(96, 45)] forState:UIControlStateNormal];
        }
        checkFront.layer.cornerRadius = 60;
        checkFront.backgroundColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];

        [checkFront addTarget:self action:@selector(checkFrontButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *checkBack = [UIButton buttonWithType:UIButtonTypeCustom];
        checkBack.exclusiveTouch = YES;
        
        if(!self.checkBack){
            [checkBack setImage:[UIImage imageNamed:@"check_back.png"] forState:UIControlStateNormal];
        }
        else{
            if(self.checkBack.size.height > self.checkBack.size.width)
                self.checkBack = [AppUtilities rotateImageLandscape:self.checkBack];
            
            [checkBack setImage:[AppUtilities imageWithImage:self.checkBack scaledToSize:CGSizeMake(96, 45)] forState:UIControlStateNormal];
        }
        
        [checkBack addTarget:self action:@selector(checkBackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        checkBack.layer.cornerRadius = 60;
        checkBack.backgroundColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];

        int gap = ([[UIScreen mainScreen]bounds].size.width-240)/3;
        
        checkFront.frame = CGRectMake(gap, 25, 120, 120);
        checkBack.frame = CGRectMake(2*gap+120, 25, 120, 120);
        
        UILabel *frontLabel = [[UILabel alloc]initWithFrame:CGRectMake(gap, 155, 120, 21)];
        frontLabel.textAlignment = NSTextAlignmentCenter;
        frontLabel.text = Klm(@"Check Front");
        frontLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        [AppUtilities adjustFontSizeOfLabel:frontLabel];
        
        UILabel *backLabel = [[UILabel alloc]initWithFrame:CGRectMake(2*gap+120, 155, 120, 21)];
        backLabel.textAlignment = NSTextAlignmentCenter;
        backLabel.text = Klm(@"Check Back");
        backLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        [AppUtilities adjustFontSizeOfLabel:backLabel];

        
        if(self.cdState > 0 && (self.checkFront || self.checkBack) ){
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake((tableView.frame.size.width-150)/2, 2, 150, 20)];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:FONTNAME size:10];
            [AppUtilities adjustFontSizeOfLabel:label];
            label.text = Klm(TAPTOPREVIEWIMAGE);
            
            [cell.contentView addSubview:label];
            
        }
        
        if(([self isValidAmount:userEnteredAmount] == NO) && !(self.checkFront || self.checkBack) ){
            
            [checkBack setBackgroundImage:[UIImage imageNamed:@"graycircle.png"] forState:UIControlStateNormal];
            [checkFront setBackgroundImage:[UIImage imageNamed:@"graycircle.png"] forState:UIControlStateNormal];
            
            checkFront.layer.cornerRadius = 60;
            checkFront.backgroundColor = [UIColor clearColor];
            
            checkBack.layer.cornerRadius = 60;
            checkBack.backgroundColor = [UIColor clearColor];

            
            [checkFront setEnabled:NO];
            [checkBack setEnabled:NO];
            [frontLabel setTextColor:[UIColor grayColor]];
            [backLabel setTextColor:[UIColor grayColor]];
        }
        else{
            
            [checkBack setBackgroundImage:[UIImage imageNamed:@"bluecircle.png"] forState:UIControlStateNormal];
            [checkFront setBackgroundImage:[UIImage imageNamed:@"bluecircle.png"] forState:UIControlStateNormal];

            checkFront.layer.cornerRadius = 60;
            checkFront.backgroundColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
            
            checkBack.layer.cornerRadius = 60;
            checkBack.backgroundColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];

            [checkFront setEnabled:YES];
            [checkBack setEnabled:YES];
            [frontLabel setTextColor:[UIColor blackColor]];
            [backLabel setTextColor:[UIColor blackColor]];
        }
        
        [cell.contentView addSubview:checkFront];
        [cell.contentView addSubview:checkBack];
        [cell.contentView addSubview:frontLabel];
        [cell.contentView addSubview:backLabel];
        
        [cell.contentView bringSubviewToFront:checkFront];
        [cell.contentView bringSubviewToFront:checkBack];
        
        if ([self checkForErrors]) {
            UIImageView *erorSymbol = [[UIImageView alloc]initWithFrame:CGRectMake(15, 195, 25, 21)];
            erorSymbol.image = [UIImage imageNamed:@"alerticon.png"];
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(50, 190, 270, 30)];
            label.text = Klm(@"Check is not usable.");
            label.textColor = [UIColor redColor];
            label.numberOfLines = 0;
            label.font = [UIFont fontWithName:FONTNAME size:15];
            [AppUtilities adjustFontSizeOfLabel:label];
            label.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:erorSymbol];
            [cell.contentView addSubview:label];
        }
    }
    else if(indexPath.row==2){
        
        
        UILabel *line2 = [[UILabel alloc]initWithFrame:CGRectMake(15, 49, [[UIScreen mainScreen]bounds].size.width-15, 1)];
        line2.backgroundColor = [UIColor lightGrayColor];
        
        UILabel *amount = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 100, 22)];
        amount.text = Klm([summaryTextDict valueForKey:AMOUNT]);
        amount.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
        [AppUtilities adjustFontSizeOfLabel:amount];

        UITextField *amountField = [[UITextField alloc]initWithFrame:CGRectMake([[UIScreen mainScreen]bounds].size.width-115, 10, 100, 30)];
        amountField.borderStyle = UITextBorderStyleNone;
        amountField.delegate = self;
        amountField.tag = 10;
        amountField.textAlignment = NSTextAlignmentRight;
        amountField.font = textFieldFont;
        amountField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        [amountField setClearButtonMode:UITextFieldViewModeWhileEditing];
        amountField.text = _checkAmount;
        [AppUtilities reduceFontOfTextField:amountField];
        [amountField setEnabled:YES];
        
        
        [cell.contentView addSubview:line2];
        [cell.contentView addSubview:amount];
        [cell.contentView addSubview:amountField];
    }
    else if(indexPath.row == 4 && _showCheckInfo && self.cdState == 2 && self.checkResults != nil){
        
        UILabel *line1 = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, [[UIScreen mainScreen]bounds].size.width-15, 1)];
        line1.backgroundColor = [UIColor lightGrayColor];
        
        UILabel *line2 = [[UILabel alloc]initWithFrame:CGRectMake(15, 49, [[UIScreen mainScreen]bounds].size.width-15, 1)];
        line2.backgroundColor = [UIColor lightGrayColor];
        
        UILabel *checkInfo = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, 150, 22)];
        checkInfo.text = Klm(@"Check Information");
        checkInfo.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        [AppUtilities adjustFontSizeOfLabel:checkInfo];

        checkInfo.textColor = [UIColor blackColor];
        [cell.accessoryView setAlpha:1.0];

        [cell.contentView addSubview:line1];
        [cell.contentView addSubview:line2];
        [cell.contentView addSubview:checkInfo];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    else if(indexPath.row == 5){
        
        UIButton *makeDepositBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [makeDepositBtn setTitle:Klm([summaryTextDict valueForKey:SUBMITBUTTONTEXT]) forState:UIControlStateNormal];
        makeDepositBtn.exclusiveTouch = YES;
        
        makeDepositBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
        [makeDepositBtn addTarget:self action:@selector(makeDepositButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [makeDepositBtn setFrame:CGRectMake(20, 20, [[UIScreen mainScreen]bounds].size.width-40, 40)];
        
        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        
        if(self.cdState == 2 && ![_checkAmount isEqualToString:@""]){
            [makeDepositBtn setTitleColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.buttonTextColor] forState:UIControlStateNormal];
            [makeDepositBtn setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.buttonColor] withTheme:[[ProfileManager sharedInstance] getActiveProfile].theme] forState:UIControlStateNormal];
            [makeDepositBtn setEnabled:YES];
        }
        else{
            [makeDepositBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [makeDepositBtn setBackgroundImage:[AppUtilities getcustomButtonImage:[UIColor grayColor] withTheme:[[ProfileManager sharedInstance] getActiveProfile].theme] forState:UIControlStateNormal];
            [makeDepositBtn setEnabled:NO];
        }
        
        utilitiesObject = nil;
        
        //Disabling makedeposit button when no results for check extraction.
        
        if(self.checkResults == nil) {
            [makeDepositBtn setEnabled:NO];
        }
        
        
        [cell.contentView addSubview:makeDepositBtn];
        
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    
    
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSInteger row = indexPath.row;
    
    if(row == 0){
        return 20;
    }
    if(row == 1){
        return 50;
    }
    if(row == 3){
        if ([self checkForErrors]) {
            return 226;
        }
        return 186;
    }
    if(row == 2){
        return 50;
    }
    if(row == 4){
        
        if(_showCheckInfo && self.cdState == 2 && self.checkResults != nil)
        {
            return 50;
        }
        return 1;
    }
    if(row == 5){
        return 80;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 4 && self.cdState == 2){ //&& ![_checkAmount isEqualToString:@""]){
        [self showCheckInfoScreen];
    }
    if(indexPath.row == 1){
        
        [self checkingButtonAction];
    }
    if(indexPath.row == 2){
        
        UITableViewCell *tempCell = [self.table cellForRowAtIndexPath:indexPath];
        
        UITextField *textField = (UITextField*)[[tempCell contentView] viewWithTag:10];
        
        [textField becomeFirstResponder];
    }
    
}

#pragma mark UITextFieldDelegate Methods


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    //    CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    //    [self.table setContentOffset:CGPointMake(0, rect.origin.y/2) animated:YES];
    
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    AppUtilities *appUtilitiesObj = [[AppUtilities alloc] init];

    //For french/german launguages currency will be seperated by "," string so we should allow "," from keyboard

    if(![appUtilitiesObj isAllDigits:string] && ![string isEqualToString:@"."] && ![string isEqualToString:@","]){
        return NO;
    }
    
    if(textField.tag==10){
        
        if([string isEqualToString:@""]  && textField.text.length==1){
            
             textField.text=@"";
            _checkAmount = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else if ([string isEqualToString:@""]){
            
               _checkAmount = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else{
            
            _checkAmount =  [_checkAmount stringByAppendingString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            
        }
        
        //checking text length before replacing characters.
        if ([textField.text length]) {
            userEnteredAmount = [textField.text stringByReplacingCharactersInRange:range withString:string];
        }
        else{
            userEnteredAmount = string;
        }
    }
    else {
    
    if ([string isEqualToString:@""] && textField.text.length==1) {
        textField.text=@"";
        _checkAmount = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self setNavigationLeftItem];
        [self.table reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        return NO;
    }
    
    if([string isEqualToString:@""]){
        
        _checkAmount = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else{
        
        _checkAmount =  [_checkAmount stringByAppendingString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
    }
    }
    [self setNavigationLeftItem];
    [self.table reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    return YES;
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [self setCheckAmountValue];
    textField.font = textFieldFont;
    [AppUtilities reduceFontOfTextField:textField];
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    _checkAmount = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self setNavigationLeftItem];
    textField.font = textFieldFont;
    [AppUtilities reduceFontOfTextField:textField];
    
    return YES;
}
-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text=@"";
    userEnteredAmount = @"";
    _checkAmount = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self setNavigationLeftItem];
    [self.table reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    return NO;
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    if(length > 4)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-3];
    }
    return mobileNumber;
}


-(int)getLength:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    return length;
}


#pragma mark
#pragma mark Helper Methods

-(NSString*)getCheckAmountFromResults{
    
    if(!_checkResults || [_checkResults count] == 0){
        
        return @"";
    }
    
    //A2iA_CheckAmount
    
    for (NSDictionary *dict in _checkResults) {
        
        if([[dict allKeys] containsObject:@"name"]){
            
            if([[dict valueForKey:@"name"] isEqualToString:@"A2iA_CheckAmount"]){
                
                return [dict valueForKey:@"text"];
                
            }
            
        }
    }
    
    return @"";
}

//Method is used for checking enterd amount is valid or not.

-(void)setCheckAmountValue
{
    UITextField *txtField=(UITextField *)[self.view viewWithTag:10];
    NSNumberFormatter *numberFormatter = [AppUtilities getNumberFormatterOfLocaleBasedOnCountryCode:self.countryCode];
    NSNumber *number = [numberFormatter numberFromString:txtField.text];
    NSString *amountString = [numberFormatter stringFromNumber:number];

    BOOL isMorethan2FractionDigits = NO;
    
    //Logic for finding number of fraction digits entered by user, if more than 2 fraction digits it will be invalid amount.
    if (number != nil) {
        NSArray *components = [amountString componentsSeparatedByString:@"."];
        if ([components count] > 1 && [[components lastObject] length] > 2) {
            isMorethan2FractionDigits = YES;
        }
    }

    
    if ((number == nil || isMorethan2FractionDigits) == NO) {
        _checkAmount = [numberFormatter stringFromNumber:number];
        txtField.text = [numberFormatter stringFromNumber:number];
    }
    
}

//Method is used for checking amount is valid/invalid.

- (BOOL)isValidAmount:(NSString*)amount
{
    NSNumberFormatter *numberFormatter = [AppUtilities getNumberFormatterOfLocaleBasedOnCountryCode:self.countryCode];
    NSNumber *number = [numberFormatter numberFromString:amount];
    NSString *amountString = [numberFormatter stringFromNumber:number];

    BOOL isMorethan2FractionDigits = NO;
    
    //Logic for finding number of fraction digits entered by user, if more than 2 fraction digits it will be invalid amount.
    if (number != nil) {
        NSArray *components = [amountString componentsSeparatedByString:@"."];
        if ([components count] > 1 && [[components lastObject] length] > 2) {
            isMorethan2FractionDigits = YES;
        }
    }
    
    
    if (number == nil || isMorethan2FractionDigits) {
        return NO;
    }
    return YES;
}

#pragma mark Local Action Methods

-(IBAction)doneButtonAction:(id)sender{
    
    [self setCheckAmountValue];
    
    UITableViewCell *tempCell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    UITextField *textField = (UITextField*)[[tempCell contentView] viewWithTag:10];
    
    [self textFieldShouldReturn:textField];
}

-(void)keyboardWillHide:(NSNotification*)notification{
    self.keyboardToolbar.frame = CGRectMake(0, [[UIScreen mainScreen]bounds].size.height+10, [[UIScreen mainScreen]bounds].size.width, self.keyboardToolbar.frame.size.height);
}

-(void)keyboardWillShow:(NSNotification*)notification{
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: 0.3];
    CGRect keyboardBounds = [[notification.userInfo valueForKey:@"UIKeyboardBoundsUserInfoKey"]CGRectValue ];
    self.keyboardToolbar.frame = CGRectMake(0, [[UIScreen mainScreen]bounds].size.height-(keyboardBounds.size.height+self.keyboardToolbar.frame.size.height), [[UIScreen mainScreen]bounds].size.width, self.keyboardToolbar.frame.size.height);
    [UIView commitAnimations];
}


-(void)showCheckInfoScreen{
    
    CDSummaryViewController *checkInfoVC = [[CDSummaryViewController alloc] initWithNibName:@"CDSummaryViewController" bundle:nil];;
    checkInfoVC.countryCode = self.countryCode;
    checkInfoVC.checkResults = [PersistenceManager getCheckInformation];
    checkInfoVC.componentObject = self.componentObject;
    [self.navigationController pushViewController:checkInfoVC animated:YES];
}

-(BOOL)checkForErrors{
    if (!self.checkAmount || !self.checkBack) {
        return NO;
    }
    
    if(!_checkResults || [_checkResults count] == 0){
        _appStateMachine = [AppStateMachine sharedInstance];
        if(!_appStateMachine.front_processed)
            return NO;
        else
            return YES;
    }
    
    //CheckUsable
    
    for (NSDictionary *dict in _checkResults) {
        
        if([[dict allKeys] containsObject:@"name"]){
            
            if([[dict valueForKey:@"name"] isEqualToString:@"CheckUsable"]){
                
                BOOL tempval = [[dict valueForKey:@"text"]boolValue];
                return !tempval;
               // return [[dict valueForKey:@"text"]boolValue];
                
            }
            
        }
    }
    _appStateMachine=nil;
    return YES;
}


/*
 This method is used to go back to the previous screen.
 */
-(IBAction)cancelButtonAction:(id)sender{
    
    //    if(self.cdState > 0 || ![_checkAmount isEqualToString:@""]){
    //if(self.checkFront || self.checkBack || ![_checkAmount isEqualToString:@""]){
    
    [self.delegate backButtonClicked];
    //    }
    //    else{
    //        [self.navigationController popViewControllerAnimated:YES];
    //    }
    
}

/*
 This method is used to push to settings controller.
 */

-(IBAction)settingsButtonAction{
   
    ComponentSettingsViewController *componentSettingsController = [[ComponentSettingsViewController alloc] initWithComponent:self.componentObject andTheme:[[ProfileManager sharedInstance]getActiveProfile].theme];
    [self.navigationController pushViewController:componentSettingsController animated:YES];
    
}

-(IBAction)checkHistoryAction:(id)sender{
    
    [self.delegate checkHistoryClicked];
}

-(IBAction)makeDepositButtonAction:(id)sender{
    
    
    [self.delegate makeDepositButtonClicked];
    
}

-(IBAction)checkFrontButtonAction:(id)sender{

    [self.delegate checkFrontButtonClicked];
    
}

-(IBAction)checkBackButtonAction:(id)sender{
    
    [self.delegate checkBackButtonClicked];
}


-(IBAction)checkingButtonAction{
    
    UIActionSheet *billPayActionSheet = [[UIActionSheet alloc] initWithTitle:Klm(@"Deposit to") delegate:self cancelButtonTitle:Klm(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:Klm(@"Savings"), Klm(@"Checking"),nil];
    billPayActionSheet.frame=CGRectMake(0, self.view.frame.size.height, 320, 100);
    //[billPayActionSheet showFromRect:CGRectMake(0, self.view.frame.size.height, 320, 100) inView:self.view animated:NO];
    [billPayActionSheet showInView:self.view];
    billPayActionSheet.backgroundColor = [UIColor whiteColor];
    
}

-(IBAction)backButtonAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
#pragma mark Alert Delegate 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == CheckDepositDebuggingTag) {
        
        if(buttonIndex == 0){
            
            [AppUtilities addActivityIndicator];
            [self performSelector:@selector(sendImageSummary) withObject:nil afterDelay:0.25];
        
        }
    }
    
}

-(void)sendImageSummary {
    
    NSDictionary *dictImages = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.checkFrontRaw,self.checkProcessedFront,self.checkBackRaw,self.checkProcessedBack, nil] forKeys:[NSArray arrayWithObjects:@"CheckFront_UnProcessed",@"CheckFront_Processed",@"CheckBack_UnProcessed",@"CheckBack_Processed", nil]];
    
    [self composeMailWithSubject:@"Image Summary - Check Deposit" withImages:dictImages withResult:self.extractedError?self.extractedError.localizedDescription:[PersistenceManager getCheckInformation].description];
    
    dictImages = nil;

    
}

#pragma mark Clean up

-(void)cleanTheRawImages
{
    if (self.checkBackRaw) {
        [self.checkBackRaw clearImageBitmap];
        self.checkBackRaw = nil;
    }
    
    if (self.checkFrontRaw) {
        [self.checkFrontRaw clearImageBitmap];
        self.checkFrontRaw = nil;
    }
}



#pragma mark
#pragma mark  Action Sheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 0){
        
        _accountType = Klm(@"Savings");
    }
    else{
        _accountType = Klm(@"Checking");
    }
    
    [self.table reloadData];
    
}

-(void)setNavigationLeftItem{
    if(self.checkFront || self.checkBack || ![_checkAmount isEqualToString:@""]){
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:Klm(STATICCANCELBUTTONTEXT) style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
        //    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        cancelButton.tintColor = [UIColor whiteColor];
        //    }
        self.navigationItem.leftBarButtonItem = cancelButton;
    }else{
        self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    }
}

@end
