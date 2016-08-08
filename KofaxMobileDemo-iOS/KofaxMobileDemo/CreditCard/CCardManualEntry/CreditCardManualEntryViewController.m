//
//  CCardSummaryViewController.m
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/3/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "CreditCardManualEntryViewController.h"
#import "CaptureViewController.h"
#import "AppStateMachine.h"
@interface CreditCardManualEntryViewController ()<UITextFieldDelegate>
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *expiryWidthConstraint;
@property (nonatomic, strong) KFXCreditCard *creditCardObject;
@property (nonatomic, assign) Component *componentObject;

@property (nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, assign) IBOutlet UITextField *cardNumberField,*cardCVVField,*cardExpiryField;

@property (nonatomic, strong) AppUtilities *utilitiesObject;

@property (nonatomic, strong) UIColor *redColor, *blackColor;

@end

@implementation CreditCardManualEntryViewController

#pragma mark Constructor Methods
-(id)initWithCreditCard:(KFXCreditCard*)creditCard andComponent:(Component*)component{
    self = [super init];
    if (self) {
        self.creditCardObject = creditCard;
        self.componentObject = component;
    }
    return self;
}

#pragma mark ViewLifeCycle Methods

-(void)dealloc{

    self.creditCardObject = nil;
    self.doneButton = nil;
    self.utilitiesObject = nil;
    self.redColor = nil;
    self.blackColor = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cardNumberField.leftViewMode = UITextFieldViewModeAlways;
    self.cardCVVField.leftViewMode = UITextFieldViewModeAlways;
    self.cardExpiryField.leftViewMode = UITextFieldViewModeAlways;
    
    self.cardNumberField.delegate = self;
    self.cardCVVField.delegate = self;
    self.cardExpiryField.delegate = self;
    
    [self.cardNumberField setLeftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 44)]];
    [self.cardCVVField setLeftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 44)]];
    [self.cardExpiryField setLeftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 44)]];
    
    self.expiryWidthConstraint.constant = [[UIScreen mainScreen]bounds].size.width/2;

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:Klm(STATICCANCELBUTTONTEXT) style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    cancelButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.doneButton = [[UIBarButtonItem alloc]initWithTitle:Klm(STATICDONEBUTTONTEXT) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
    self.doneButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    self.redColor = [UIColor redColor];
    self.blackColor = [UIColor blackColor];
    
    self.cardExpiryField.textColor = self.redColor;
    self.cardExpiryField.tag = 111;
    self.cardCVVField.textColor = self.redColor;
    self.cardCVVField.tag = 111;
    self.utilitiesObject = [[AppUtilities alloc]init];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    self.navigationItem.title =self.componentObject.name;
    self.doneButton.enabled = NO;
    
    if(!self.creditCardObject.expirationMonth && !self.creditCardObject.expirationYear){
       [self.cardExpiryField becomeFirstResponder];
    }
    else{
         [self.cardCVVField becomeFirstResponder];
    }
    
    self.cardNumberField.text = self.creditCardObject.cardNumber;
    
//    self.creditCardObject.expirationYear = self.creditCardObject.expirationYear?self.creditCardObject.expirationYear:@"";
//    self.creditCardObject.expirationMonth = self.creditCardObject.expirationMonth?self.creditCardObject.expirationMonth:@"";
    
    if(self.creditCardObject.expirationMonth || self.creditCardObject.expirationYear){
        self.cardExpiryField.text = [NSString stringWithFormat:@"%@/%@",self.creditCardObject.expirationMonth,self.creditCardObject.expirationYear];
    }
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
    
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@""]) {
        if (textField == self.cardExpiryField && (textField.text.length==6 || textField.text.length==5)) {
            NSArray *array = [textField.text componentsSeparatedByString:@" / "];
            textField.text = [array objectAtIndex:0];
            return NO;
        }
        textField.textColor = self.redColor;
        textField.tag = 111;
        self.doneButton.enabled = NO;
        return YES;
    }
    if ((![self.utilitiesObject isAllDigits:string]) || (textField==self.cardCVVField && textField.text.length>=3)||(textField == self.cardExpiryField && textField.text.length>=7)|| (textField.text.length==1 && [[NSString stringWithFormat:@"%@%@",textField.text,string]intValue]>12 && textField == self.cardExpiryField)) {
        return NO;
    }
    if (textField.text.length == 1 && textField == self.cardExpiryField) {
        textField.text = [NSString stringWithFormat:@"%@%@ / ",textField.text,string];
        return NO;
    }
    
    if (textField.text.length == 2 && textField == self.cardExpiryField) {
        textField.text = [NSString stringWithFormat:@"%@ / %@",textField.text,string];
        return NO;
    }
    
    if (textField.text.length == 0 && [string intValue]>1 && textField == self.cardExpiryField) {
        textField.text = [NSString stringWithFormat:@"0%@ / ",string];
        return NO;
    }
    
    
    if (textField.text.length==2 && textField == self.cardCVVField) {
        self.cardCVVField.textColor = self.blackColor;
        self.cardCVVField.tag = 222;
    }else if(textField == self.cardCVVField){
        self.cardCVVField.textColor = self.redColor;
        self.cardCVVField.tag = 111;
    }
    
    if (textField.text.length == 6 && textField == self.cardExpiryField) {
        textField.text = [NSString stringWithFormat:@"%@%@",textField.text ,string];
        NSArray *array = [textField.text componentsSeparatedByString:@" / "];
        NSString *month = [array objectAtIndex:0];
        NSString *year = [array objectAtIndex:1];
        
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"MM"];
        NSString *actMonth = [format stringFromDate:[NSDate date]];
        [format setDateFormat:@"YY"];
        NSString *actYear = [format stringFromDate:[NSDate date]];
        
        if ([year intValue] >= [actYear intValue]&& [year intValue]<[actYear intValue]+14) {
            if ([actMonth intValue]>[month intValue] && [actYear intValue]==[year intValue]) {
                return NO;
            }
            self.cardExpiryField.tag = 222;
            self.cardExpiryField.textColor = self.blackColor;
            [self.cardCVVField becomeFirstResponder];
            if (self.cardExpiryField.tag == 222 && self.cardCVVField.tag ==222) {
                self.doneButton.enabled = YES;
            }else{
                self.doneButton.enabled = NO;
            }
        }
        return NO;
    }else if(textField == self.cardExpiryField){
        self.cardExpiryField.tag = 111;
        self.cardExpiryField.textColor = self.redColor;
    }
    
    
    if (self.cardExpiryField.tag == 222 && self.cardCVVField.tag ==222) {
        self.doneButton.enabled = YES;
    }else{
        self.doneButton.enabled = NO;
    }
    
    return YES;
}
#pragma mark Local Methods
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)cancelButtonAction:(id)sender
{
    [self.delegate manualCancelButtonClicked];
}
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)doneButtonAction:(id)sender
{
    NSArray *array = [self.cardExpiryField.text componentsSeparatedByString:@"/"];
    self.creditCardObject.cvv = self.cardCVVField.text;
    self.creditCardObject.expirationMonth = [array objectAtIndex:0];
    self.creditCardObject.expirationYear = [array objectAtIndex:1];
    [self.delegate manualDoneButtonClicked:self.creditCardObject];
}




@end
