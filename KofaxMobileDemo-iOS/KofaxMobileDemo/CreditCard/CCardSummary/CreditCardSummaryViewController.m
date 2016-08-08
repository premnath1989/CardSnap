//
//  CCardSummaryViewController.m
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/3/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "CreditCardSummaryViewController.h"
#import "AppStateMachine.h"

#define INVALIDNUMBER  10
#define INVALIDDATE 11
#define INVALIDCVV  12
#define INVALIDAMOUNT  13

@interface CreditCardSummaryViewController ()<UITextFieldDelegate>{
    
    BOOL isExtractionTypeRTTI;
}
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic, assign) Component *componentObject;

@property (nonatomic, strong) NSMutableDictionary *creditCardObject;

@property (nonatomic, strong) AppUtilities *utilitiesObject;

@property (nonatomic, assign) AppStateMachine *appStateMachine;

@property (nonatomic, strong) UITextField *numberField,*cvvField,*expiryField,*amountField,*cardNetworkField;

@property (nonatomic, assign) IBOutlet UIToolbar *keyboardToolbar;

@property (nonatomic,weak) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;


-(IBAction)dismissKeyBoard:(id)sender;
-(IBAction)nextButtonAction:(id)sender;


@property (assign) BOOL validDate;

@end

@implementation CreditCardSummaryViewController

#pragma mark Constructor Methods
-(id)initWithComponent:(Component*)component andCreditCard:(NSMutableDictionary*)creditCard{
    self = [super init];
    if (self) {
        self.componentObject = component;
        self.creditCardObject = creditCard;
    }
    return self;
}

#pragma mark ViewLifeCycle Methods

-(void)dealloc{
    
    self.creditCardObject = nil;
    self.utilitiesObject = nil;
    self.numberField.delegate = nil;
    self.numberField = nil;
    self.cvvField.delegate = nil;
    self.cvvField = nil;
    self.expiryField.delegate = nil;
    self.expiryField = nil;
    self.amountField.delegate = nil;
    self.amountField = nil;
    self.cardNetworkField.delegate = nil;
    self.cardNetworkField = nil;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.doneButton setTitle:Klm(self.doneButton.title)];
    [self.nextButton setTitle:Klm(self.nextButton.title)];
    // Do any additional setup after loading the view from its nib.
    
    self.appStateMachine = [AppStateMachine sharedInstance];
    
    isExtractionTypeRTTI=![[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:SERVER_MODE] boolValue];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant += 20;
    }else{
        self.tableTopConstraint.constant -=42;
    }

    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:Klm(STATICCANCELBUTTONTEXT) style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    cancelButton.tintColor = [UIColor whiteColor];
    
    
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 68, 44)];
    
    UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [retakeButton setImage:[UIImage imageNamed:@"CCardRetake.png"] forState:UIControlStateNormal];
    [retakeButton addTarget:self action:@selector(retakeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    retakeButton.frame = CGRectMake(0, 0, 34, 44);
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setImage:[UIImage imageNamed:SETTINGSBUTTONIMAGE] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(settingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    settingsButton.frame = CGRectMake(34, 0, 34, 44);
    [settingsButton setEnabled:NO];
    
    if(!isExtractionTypeRTTI){
    [rightView addSubview:retakeButton];
    }
    [rightView addSubview:settingsButton];
    rightView.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    
    self.utilitiesObject = [[AppUtilities alloc]init];
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.keyboardToolbar.barTintColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
    
     self.nextButton.tintColor = self.doneButton.tintColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.titleColor];
    
    
    self.validDate = NO;
}

-(void)checkDate{
    
    NSString *expiryDate = [self.creditCardObject valueForKey:@"expiryDate"];
    
    if(expiryDate && ![expiryDate isEqualToString:@""]){

        NSArray *array = [expiryDate componentsSeparatedByString:@" / "];
        
        if([array count]<2){
            self.validDate = NO;
            return;
        }
        
        NSString *month = [array objectAtIndex:0];
        NSString *year = [array objectAtIndex:1];
        
        if(month.length <2 || year.length <2){
            
            self.validDate = NO;
            return;
        }
        
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"MM"];
        NSString *actMonth = [format stringFromDate:[NSDate date]];
        [format setDateFormat:@"YY"];
        NSString *actYear = [format stringFromDate:[NSDate date]];
        
        if(!isExtractionTypeRTTI){
        if ([year intValue] >= [actYear intValue]&& [year intValue]<[actYear intValue]+14) {
            if ([actMonth intValue]>[month intValue] && [actYear intValue]==[year intValue]) {
                
                self.validDate = NO;
                self.expiryField.textColor = [UIColor redColor];
            }
            else{
                self.expiryField.textColor = [UIColor blackColor];
                self.validDate = YES;
            }
        }
        }else{
            if([self.creditCardObject valueForKey:CREDITCARDEXPIRYDATEVALID] && ![[self.creditCardObject valueForKey:CREDITCARDEXPIRYDATEVALID] integerValue]){
                    self.expiryField.textColor = [UIColor redColor];
            }
        }
        
    }
}

-(void)checkCardNumber{
    
    NSString *cardNumber = [self.creditCardObject valueForKey:@"cardNumber"];
    if(cardNumber && ![cardNumber isEqualToString:@""] && cardNumber.length < 16){
        self.numberField.textColor = [UIColor redColor];
    }
}

-(void)validateExtractedValues{
    
    [self checkDate];
    //[self checkCardNumber];
}

-(void)viewWillAppear:(BOOL)animated{

    
    [super viewWillAppear:YES];
    
    
    self.navigationItem.title = Klm(self.componentObject.name);
    
    [self validateExtractedValues];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [self.table reloadData];
    
}
//Method called to update the credit card extraction data
//This method is called only for extraction with RTTI
-(void)updateCreditCardData:(NSMutableDictionary*)creditCard{
    
    self.creditCardObject = creditCard;
    [self validateExtractedValues];
    [self.table reloadData];
    
    [AppUtilities removeActivityIndicator];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
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
    if(isExtractionTypeRTTI){
        return 2;
    }
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    /*If extraction is through RTTI there are 2 sections
     Section 1.Thumbnail Preview
     Section 2.CreditCard extracted data
     
     If extraction is through CardIO there is 1 section
     Section 1.CreditCard extracted data
     */
    
    if(isExtractionTypeRTTI){
        if(section==0){
            return 1;//Number of rows for for thumbnail
        }
        return 6;//Number of rows for credit card data
    }
        return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = TABLECELLIDENTIFIER ;
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if(indexPath.section==0 && isExtractionTypeRTTI){
    //Add thumbnail image if the credit card is captured through uniformGuidance
        
    UIImageView *thumbnail = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 126)];
    thumbnail.contentMode = UIViewContentModeScaleAspectFit;

    kfxKEDImage *frontProcessedImage = [self.appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_TIF];
    UIImage *image = [frontProcessedImage getImageBitmap];
        if(image.size.height > image.size.width){
            image = [AppUtilities rotateImageLandscape:image];
        }
    thumbnail.image=image;
        
        UIButton *thumbnailButton=[UIButton buttonWithType:UIButtonTypeCustom];
        thumbnailButton.frame=thumbnail.frame;
        [thumbnailButton addTarget:self action:@selector(thumbnailClicked) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:thumbnailButton];
    
    [cell.contentView addSubview:thumbnail];
    }

    if((indexPath.row==4 && ([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:SERVER_MODE] boolValue])) || (indexPath.row==5 && (![[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:SERVER_MODE] boolValue]) && indexPath.section==1)){
        UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        submitButton.frame = CGRectMake(15, 30, [[UIScreen mainScreen]bounds].size.width-30, 40);
        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        [submitButton setTitleColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.buttonTextColor] forState:UIControlStateNormal];
        [submitButton setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.buttonColor] withTheme:[[ProfileManager sharedInstance]getActiveProfile].theme] forState:UIControlStateNormal];
        utilitiesObject = nil;
        [submitButton setTitle:Klm([self.componentObject.texts.summaryText valueForKey:SUBMITBUTTONTEXT]) forState:UIControlStateNormal];
        [submitButton setBackgroundColor:[UIColor redColor]];
        [submitButton addTarget:self action:@selector(submitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        //cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:submitButton];
    }else if((indexPath.section==0 && !isExtractionTypeRTTI) || (indexPath.section==1 && isExtractionTypeRTTI)){
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 11, 150, 21)];
        label.font = [UIFont fontWithName:FONTNAME size:16];
        
        UITextField *valueField = [[UITextField alloc]initWithFrame:CGRectMake([[UIScreen mainScreen]bounds].size.width-185, 11, 170, 21)];
        valueField.borderStyle = UITextBorderStyleNone;
        valueField.textAlignment = NSTextAlignmentRight;
        valueField.font = [UIFont fontWithName:FONTNAME size:16];
        valueField.delegate = self;
        valueField.tag = indexPath.row;
        valueField.returnKeyType = UIReturnKeyDone;
        valueField.keyboardType = UIKeyboardTypeDecimalPad;
        
        if (indexPath.row==0) {
            label.text = Klm(@"Number") ;
            valueField.text = [self.creditCardObject valueForKey:@"cardNumber"];
            valueField.placeholder = Klm(@"Card Number");
            self.numberField = valueField;
            if([self.creditCardObject valueForKey:CREDITCARDNUMBERVALID] && ![[self.creditCardObject valueForKey:CREDITCARDNUMBERVALID] integerValue]){
                self.numberField.textColor = [UIColor redColor];
            }
            
        }else if(indexPath.row==1){
            label.text = Klm(@"Expiry Date");
            valueField.text = [self.creditCardObject valueForKey:@"expiryDate"];
            valueField.placeholder = Klm(@"MM / YY");
            self.expiryField = valueField;
        
            if([self.creditCardObject valueForKey:CREDITCARDEXPIRYDATEVALID]){
            if(![[self.creditCardObject valueForKey:CREDITCARDEXPIRYDATEVALID] integerValue]){
                self.expiryField.textColor = [UIColor redColor];
            }
            }else{
                if(!self.validDate){
                    self.expiryField.textColor = [UIColor redColor];
                }
            }
        }else if(indexPath.row==2){
            label.text = Klm(@"CVV");
            valueField.text = [self.creditCardObject valueForKey:@"cvv"];
            valueField.placeholder = Klm(@"CVV");
            self.cvvField = valueField;
            if(self.cvvField.text.length < 3){
                self.cvvField.textColor = [UIColor redColor];
            }
        }else if(indexPath.row==3){
            label.text = Klm(@"Amount");
            valueField.text = [self.creditCardObject valueForKey:@"amount"];
            valueField.placeholder = Klm(@"Amount");
            self.amountField = valueField;
        }else if(indexPath.row==4 && isExtractionTypeRTTI){
            label.text = Klm(@"Card Network");
            valueField.text =[self.creditCardObject valueForKey:@"cardNetwork"];;
            valueField.placeholder = Klm(@"Card Network");
            valueField.keyboardType = UIKeyboardTypeAlphabet;
            self.cardNetworkField = valueField;
            if([self.creditCardObject valueForKey:CREDITCARDNETWORKVALID] && (![[self.creditCardObject valueForKey:CREDITCARDNETWORKVALID] integerValue])){
                self.cardNetworkField.textColor = [UIColor redColor];
            }
            
        }
        
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:valueField];
    }
    
    if ((indexPath.section == 0 && (indexPath.row<3 && (!isExtractionTypeRTTI)))||(indexPath.section==1 && (indexPath.row<4 && (isExtractionTypeRTTI)))) {
        
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(15, 43.5, [[UIScreen mainScreen]bounds].size.width-15, 1)];
        [line setBackgroundColor:[UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1.0f]];
        
        [cell.contentView addSubview:line];
    }
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    if (section==0) {
//        return Klm(@"Credit Card");
//    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((indexPath.section==0 && indexPath.row==4 && !isExtractionTypeRTTI)||(indexPath.section==1 && indexPath.row==5 && isExtractionTypeRTTI)) {
        return 100;
    }else if(isExtractionTypeRTTI && indexPath.section==0){
        return 126;
    }
    return 44;
    

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}


#pragma mark UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if((textField != self.cardNetworkField && isExtractionTypeRTTI)||((textField != self.amountField && !isExtractionTypeRTTI))){
        [self.nextButton setEnabled:YES];
    }
    else{
        [self.nextButton setEnabled:NO];
    }
    CGRect  rect;
    if(isExtractionTypeRTTI){
      rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:1]];
    }
    else{
        rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]];
    }
    [self.table setContentOffset:CGPointMake(0, rect.origin.y/2) animated:YES];
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField == self.amountField){
        [self.creditCardObject setValue:textField.text forKey:@"amount"];
    }
    else if(textField == self.cvvField){
        [self.creditCardObject setValue:textField.text forKey:@"cvv"];
        
        // In iOS 7 , the Text Field color is not reflecting when the last character is entered in "shouldChangeCharactersInRange". So made the respective changes in "textFieldDidEndEditing".
        
        if(textField.text.length==3){
            
            self.cvvField.textColor = [UIColor blackColor];
        }
        else{
            self.cvvField.textColor = [UIColor redColor];
        }
    }
    else if(textField == self.numberField){
        [self.creditCardObject setValue:textField.text forKey:@"cardNumber"];
    }
    else if(textField == self.expiryField){
        [self.creditCardObject setValue:textField.text forKey:@"expiryDate"];
        
        // In iOS 7 , the Text Field color is not reflecting when the last character is entered in "shouldChangeCharactersInRange". So made the respective changes in "textFieldDidEndEditing".
        if(!isExtractionTypeRTTI){
        if(self.validDate) {
            
            self.expiryField.textColor = [UIColor blackColor];
        }
        else {
            
            self.expiryField.textColor = [UIColor redColor];
        }
        }
    }
    else if(textField==self.cardNetworkField){
        [self.creditCardObject setValue:textField.text forKey:@"cardNetwork"];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    [textField resignFirstResponder];
    
    
    return YES;
}

// NEW

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    if ([string isEqualToString:@""]) {
        if (textField == self.expiryField && (textField.text.length==6 || textField.text.length==5)) {
            NSArray *array = [textField.text componentsSeparatedByString:@" / "];
            textField.text = [array objectAtIndex:0];
            return NO;
        }
        if(textField != self.amountField){
            textField.textColor = [UIColor redColor];
        }
        
        return YES;
    }
    if (textField == self.cardNetworkField) {
        if ([self.utilitiesObject isAllDigits:string]) {
            return NO;
        }
        return YES;
    }
    
    if (textField == self.amountField) {
        
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        NSArray *sep = [newString componentsSeparatedByString:@"."];
        if([sep count]>=2){
            NSString *sepStr=[NSString stringWithFormat:@"%@",[sep objectAtIndex:1]];
            NSLog(@"sepStr:%@",sepStr);
            if([sepStr length] >2){
                return NO;
            }
        }
        return YES;
    }
    if ((![self.utilitiesObject isAllDigits:string]) || (textField==self.cvvField && textField.text.length>=3)||(textField == self.expiryField && textField.text.length>=7)|| (textField==self.numberField && textField.text.length>=16) || (textField.text.length==1 && [[NSString stringWithFormat:@"%@%@",textField.text,string]intValue]>12 && textField == self.expiryField)) {
        
        return NO;
    }
    if (textField.text.length == 1 && textField == self.expiryField) {
        
        textField.text = [NSString stringWithFormat:@"%@%@ / ",textField.text,string];
        return NO;
    }
    
    if (textField.text.length == 2 && textField == self.expiryField) {
        
        textField.text = [NSString stringWithFormat:@"%@ / %@",textField.text,string];
        return NO;
    }
    
    if (textField.text.length == 0 && [string intValue]>1 && textField == self.expiryField) {
        
        textField.text = [NSString stringWithFormat:@"0%@ / ",string];
        return NO;
    }
    
    
    if (textField == self.cvvField) {
        
        if(textField.text.length==2){
            self.cvvField.textColor = [UIColor blackColor];
        }
        else{
            self.cvvField.textColor = [UIColor redColor];
        }
    }
    
    if (textField.text.length == 6 && textField == self.expiryField) {
        textField.text = [NSString stringWithFormat:@"%@%@",textField.text ,string];
        NSArray *array = [textField.text componentsSeparatedByString:@" / "];
        if([array count]<2){
            self.validDate = NO;
            return NO;
        }
        NSString *month = [array objectAtIndex:0];
        NSString *year = [array objectAtIndex:1];
        
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"MM"];
        NSString *actMonth = [format stringFromDate:[NSDate date]];
        [format setDateFormat:@"YY"];
        NSString *actYear = [format stringFromDate:[NSDate date]];
        
        if ([year intValue] >= [actYear intValue]&& [year intValue]<[actYear intValue]+14) {
            if ([actMonth intValue]>[month intValue] && [actYear intValue]==[year intValue]) {
                
                self.validDate = NO;
                return NO;
            }
            
            self.expiryField.textColor = [UIColor blackColor];
            self.validDate = YES;
        }
        else{
            self.validDate = NO;
        }
        return NO;
    }else if(textField == self.expiryField){
        
        if(!isExtractionTypeRTTI){
        self.validDate = NO;
        self.expiryField.textColor = [UIColor redColor];
        }
    }
    
    if(textField == self.numberField){
        
        if (![self.utilitiesObject isAllDigits:string] && ![string isEqualToString:@"."]) {
            return NO;
        }
        
        if(textField.text.length==15){
            textField.textColor = [UIColor blackColor];
        }
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSArray  *arrayOfString = [newString componentsSeparatedByString:@"."];
        
        if ([arrayOfString count] > 2 || ([arrayOfString count]==2 && [[arrayOfString objectAtIndex:1]length]>2))
            return NO;

    }
    
    return YES;
}


/* OLD

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (![self.utilitiesObject isAllDigits:string] && ![string isEqualToString:@"."]) {
        return NO;
    }
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray  *arrayOfString = [newString componentsSeparatedByString:@"."];
    
    if ([arrayOfString count] > 2 || ([arrayOfString count]==2 && [[arrayOfString objectAtIndex:1]length]>2))
        return NO;
    
    
    return YES;
}
 */
#pragma mark Local Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == INVALIDNUMBER){
        [self.numberField becomeFirstResponder];
    }
    else if(alertView.tag == INVALIDDATE){
        [self.expiryField becomeFirstResponder];
    }
    else if(alertView.tag == INVALIDCVV){
        [self.cvvField becomeFirstResponder];
    }
    else if(alertView.tag == INVALIDAMOUNT){
        [self.amountField becomeFirstResponder];
    }
}


-(IBAction)retakeButtonAction:(id)sender{
    
    [self.delegate summaryRetakeButtonClicked];
}
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)cancelButtonAction:(id)sender
{
    [self.delegate summaryCancelButtonClicked];
}
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)submitButtonAction:(id)sender
{
    if(self.numberField.text.length == 0){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:Klm(@"Please enter valid card number") delegate:self cancelButtonTitle:nil otherButtonTitles:Klm(@"OK"), nil ];
        alert.tag = INVALIDNUMBER;
        [alert show];
    }
    else if(self.expiryField.text.length < 6 || !self.validDate){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:Klm(@"Please enter valid expiry date") delegate:self cancelButtonTitle:nil otherButtonTitles:Klm(@"OK"), nil ];
        alert.tag = INVALIDDATE;
        [alert show];
    }
    else if(self.cvvField.text.length < 3){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:Klm(@"Please enter valid CVV") delegate:self cancelButtonTitle:nil otherButtonTitles:Klm(@"OK"), nil ];
        alert.tag = INVALIDCVV;
        [alert show];
    }
    else if (self.amountField.text.length==0) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:Klm(@"Please enter amount") delegate:self cancelButtonTitle:nil otherButtonTitles:Klm(@"OK"), nil ];
        alert.tag = INVALIDAMOUNT;
        [alert show];
    }
    else{
         [self.delegate summarySubmitButtonClicked];
    }
}

/*
 This method is used to push to settings controller.
 */
-(IBAction)settingsButtonAction:(id)sender
{
    [self.delegate summarySettingsButtonClicked];
}

- (IBAction)dismissKeyBoard:(id)sender{
  
    
    if([self.numberField isFirstResponder]){
        
        [self.numberField resignFirstResponder];
    }
    else if([self.expiryField isFirstResponder]){
        
        [self.expiryField resignFirstResponder];
    }
    else if([self.cvvField isFirstResponder]){
        
        [self.cvvField resignFirstResponder];
    }
    else if([self.cardNetworkField isFirstResponder]){
        [self.cardNetworkField resignFirstResponder];
    }
    else if([self.amountField isFirstResponder]){
        
        [self.amountField resignFirstResponder];
        [self.creditCardObject setValue:self.amountField.text forKey:@"amount"];
        
    }
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(IBAction)nextButtonAction:(id)sender{
    
    if([self.numberField isFirstResponder]){
        
        [self.expiryField becomeFirstResponder];
    }
    else if([self.expiryField isFirstResponder]){
        
        [self.cvvField becomeFirstResponder];
    }
    else if([self.cvvField isFirstResponder]){
        
        [self.amountField becomeFirstResponder];
    }
    else if([self.amountField isFirstResponder]){
        
        [self.cardNetworkField becomeFirstResponder];
    }
    
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

-(void)thumbnailClicked{
        [self.delegate summaryPreviewButtonClicked];
    
}

@end
