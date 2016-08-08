//
//  ApplicationTextsViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/21/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "GeneralSettingsViewController.h"

#define textFieldFont       [UIFont fontWithName:FONTNAME size:13]
#define CREDITCARD_SECTIONCOUNT 2

@interface GeneralSettingsViewController ()
{
    UITextField *selectedTextField;
    NSArray *cameraAllKeysArray;
}
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, assign) Component *selectedComponent;
@property (nonatomic, strong) UITextField *frontRetakeField,*frontUseField,*backRetakeField,*backUseField,*previewCancelField,*moveCloserField,*backUserInstructionField,*frontUserInstructionField,*holdSteadyField,*cancelButtonField,*userInstructionField,*centerMessageField,*zoomOutMessageField,*captureMessageField,*holdParallelMessageField,*orientationField,*pageNotFoundField,*deviceOrientationField,*depositToField,*instructionTextField,*submitAlertTextField,*submitButtonText,*amountField,*routingNumberField,*checkNumberField,*micrField,*instructionTextBackField,*instructionTextBackCaptureField,*submitCancelAlertField;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic, strong) NSMutableDictionary *previewTexts,*summaryTexts,*cameraTexts;
@end

@implementation GeneralSettingsViewController
@synthesize tableTopConstraint;

#pragma mark Constructor Methods

-(void)dealloc{
    self.frontRetakeField.delegate = nil;
    self.frontRetakeField = nil;
    self.frontUseField.delegate = nil;
    self.frontUseField = nil;
    self.backRetakeField.delegate = nil;
    self.backRetakeField = nil;
    self.backUseField.delegate = nil;
    self.backUseField = nil;
    self.previewCancelField.delegate = nil;
    self.previewCancelField = nil;
    self.moveCloserField.delegate = nil;
    self.moveCloserField = nil;
    self.backUserInstructionField.delegate = nil;
    self.backUserInstructionField = nil;
    self.frontUserInstructionField.delegate = nil;
    self.frontUserInstructionField = nil;
    self.holdSteadyField.delegate = nil;
    self.holdSteadyField = nil;
    
    self.userInstructionField.delegate = nil;
    self.userInstructionField = nil;
    self.centerMessageField.delegate = nil;
    self.centerMessageField = nil;
    self.zoomOutMessageField.delegate = nil;
    self.zoomOutMessageField = nil;
    self.captureMessageField.delegate = nil;
    self.captureMessageField = nil;
    self.holdParallelMessageField.delegate = nil;
    self.holdParallelMessageField = nil;
    self.orientationField.delegate = nil;
    self.orientationField = nil;
    
    self.cancelButtonField.delegate = nil;
    self.cancelButtonField = nil;
    self.pageNotFoundField.delegate = nil;
    self.pageNotFoundField = nil;
    self.deviceOrientationField.delegate = nil;
    self.deviceOrientationField = nil;
    self.depositToField.delegate = nil;
    self.depositToField = nil;
    self.instructionTextField.delegate = nil;
    self.instructionTextField = nil;
    self.submitAlertTextField.delegate = nil;
    self.submitAlertTextField = nil;
    self.submitButtonText.delegate = nil;
    self.submitButtonText = nil;
    self.amountField.delegate = nil;
    self.amountField = nil;
    self.routingNumberField.delegate = nil;
    self.routingNumberField = nil;
    self.checkNumberField.delegate = nil;
    self.checkNumberField = nil;
    self.micrField.delegate = nil;
    self.micrField = nil;
    self.instructionTextBackField.delegate = nil;
    self.instructionTextBackCaptureField.delegate = nil;
    self.instructionTextBackField = nil;
    self.submitCancelAlertField = nil;
    self.submitCancelAlertField = nil;
    self.previewTexts = nil;
    self.summaryTexts = nil;
    self.cameraTexts = nil;
}
-(id)initWithComponent:(Component*)component{
    self = [super init];
    if (self) {
        self.selectedComponent = component;
        self.previewTexts = [self.selectedComponent.texts.previewText mutableCopy];
        self.cameraTexts = [self.selectedComponent.texts.cameraText mutableCopy];
        self.summaryTexts = [self.selectedComponent.texts.summaryText mutableCopy];
    }
    return self;
}
#pragma mark ViewLifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //logic for showing camera screen edit labels in same order for all components.
    
    cameraAllKeysArray = [self.cameraTexts allKeys];
    cameraAllKeysArray = [cameraAllKeysArray sortedArrayUsingComparator:^(id a, id b) {
        return [a compare:b options:NSNumericSearch];
    }];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant +=20;
    }else{
        self.tableTopConstraint.constant -=42;
    }
    self.navigationItem.title = Klm(@"Edit Labels");
    
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.frontRetakeField.delegate = nil;
    self.frontUseField.delegate = nil;
    self.frontUserInstructionField.delegate = nil;
    self.backRetakeField.delegate = nil;
    self.backUseField.delegate = nil;
    self.backUserInstructionField.delegate = nil;
    self.moveCloserField.delegate = nil;
    self.holdSteadyField.delegate = nil;
    
    self.userInstructionField.delegate = nil;
    self.centerMessageField.delegate = nil;
    self.zoomOutMessageField.delegate = nil;
    self.captureMessageField.delegate = nil;
    self.holdParallelMessageField.delegate = nil;
    self.orientationField.delegate = nil;

    self.pageNotFoundField.delegate = nil;
    self.cancelButtonField.delegate = nil;
    self.deviceOrientationField.delegate = nil;
    self.depositToField.delegate = nil;
    self.checkNumberField.delegate = nil;
    self.submitButtonText.delegate = nil;
    self.submitAlertTextField.delegate = nil;
    self.routingNumberField.delegate  = nil;
    self.micrField.delegate = nil;
    self.instructionTextField.delegate = nil;
    self.amountField.delegate = nil;
    self.instructionTextBackField.delegate = nil;
    self.instructionTextBackCaptureField.delegate = nil;
}


#pragma mark UITableViewDataSource and UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.selectedComponent.type == CREDITCARD) {
        return CREDITCARD_SECTIONCOUNT;
    }
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return [[self.summaryTexts allKeys]count];
    }else if(section==1){
        return [[self.cameraTexts allKeys]count];
    }else{
        return [[self.previewTexts allKeys]count];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = TABLECELLIDENTIFIER ;
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.section==2 && [[[self.previewTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:FRONTRETAKEBUTTON]) {
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:self.selectedComponent.type==CHECKDEPOSIT?Klm(@"Front Retake Button Text:"):Klm(@"Retake Button Text:")];
            self.frontRetakeField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:self.selectedComponent.type==CHECKDEPOSIT?Klm(@"Front Retake Button Text"):Klm(@"Retake Button Text") andText:Klm([self.previewTexts valueForKey:FRONTRETAKEBUTTON])];
            self.frontRetakeField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.frontRetakeField];
    }else if(indexPath.section==2 && [[[self.previewTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:FRONTUSEBUTTON]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:self.selectedComponent.type==CHECKDEPOSIT?Klm(@"Front Use Button Text:"):Klm(@"Use Button Text:")];
            self.frontUseField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:self.selectedComponent.type==CHECKDEPOSIT?Klm(@"Front Use Button Text"):Klm(@"Use Button Text") andText:Klm([self.previewTexts valueForKey:FRONTUSEBUTTON])];
            self.frontUseField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.frontUseField];
    }else if(indexPath.section==2 && [[[self.previewTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:BACKRETAKEBUTTON]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Back Retake Button Text:")];
            self.backRetakeField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Back Retake Button Text") andText:Klm([self.previewTexts valueForKey:BACKRETAKEBUTTON])];
            self.backRetakeField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.backRetakeField];
    }else if(indexPath.section==2 && [[[self.previewTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:BACKUSEBUTTON]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Back Use Button Text:")];
            self.backUseField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Back Use Button Text") andText:Klm([self.previewTexts valueForKey:BACKUSEBUTTON])];
            self.backUseField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.backUseField];
    }else if(indexPath.section==2 && [[[self.previewTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:CANCELBUTTON]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Cancel Button Text:")];
            self.previewCancelField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Cancel Button Text") andText:Klm([self.previewTexts valueForKey:CANCELBUTTON])];
            self.previewCancelField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.previewCancelField];
    }else if(indexPath.section==1 && [[cameraAllKeysArray objectAtIndex:indexPath.row] isEqualToString:CANCELBUTTON]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Cancel Button Text:")];
            self.cancelButtonField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Cancel Button Text") andText:Klm([self.cameraTexts valueForKey:CANCELBUTTON])];
            self.cancelButtonField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.cancelButtonField];
    }else if(indexPath.section==1 && [[cameraAllKeysArray objectAtIndex:indexPath.row] isEqualToString:USERINSTRUCTIONFRONT]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:self.selectedComponent.type==CHECKDEPOSIT?Klm(@"Front User Instruction Text:"):Klm(@"User Instruction Text:")];
        self.frontUserInstructionField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:self.selectedComponent.type==CHECKDEPOSIT?Klm(@"Front User Instruction Text"):Klm(@"User Instruction Text") andText:Klm([self.cameraTexts valueForKey:USERINSTRUCTIONFRONT])];
            self.frontUserInstructionField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.frontUserInstructionField];
    }else if(indexPath.section==1 && [[cameraAllKeysArray objectAtIndex:indexPath.row] isEqualToString:USERINSTRUCTIONBACK]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Back User Instruction Text:")];
            self.backUserInstructionField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Back User Instruction Text") andText:Klm([self.cameraTexts valueForKey:USERINSTRUCTIONBACK])];
            self.backUserInstructionField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.backUserInstructionField];
    }else if(indexPath.section==1 && [[cameraAllKeysArray objectAtIndex:indexPath.row] isEqualToString:ZOOMOUTMESSAGE]){
        UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Zoom Out Text:")];
        self.zoomOutMessageField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Zoom Out Text") andText:Klm([self.cameraTexts valueForKey:ZOOMOUTMESSAGE])];
        self.zoomOutMessageField.delegate = self;
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:self.zoomOutMessageField];
    }else if(indexPath.section==1 && [[cameraAllKeysArray objectAtIndex:indexPath.row] isEqualToString:HOLDSTEADY]){
        UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Hold Steady Text:")];
        self.holdSteadyField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Hold Steady Text") andText:Klm([self.cameraTexts valueForKey:HOLDSTEADY])];
        self.holdSteadyField.delegate = self;
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:self.holdSteadyField];
    }else if(indexPath.section==1 && [[cameraAllKeysArray objectAtIndex:indexPath.row] isEqualToString:CENTERMESSAGE]){
        UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Center Message Text:")];
        self.centerMessageField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Center Message Text") andText:Klm([self.cameraTexts valueForKey:CENTERMESSAGE])];
        self.centerMessageField.delegate = self;
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:self.centerMessageField];
    }else if(indexPath.section==1 && [[cameraAllKeysArray objectAtIndex:indexPath.row] isEqualToString:CAPTUREDMESSAGE]){
        UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Captured Message Text:")];
        self.captureMessageField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Captured Message Text") andText:Klm([self.cameraTexts valueForKey:CAPTUREDMESSAGE])];
        self.captureMessageField.delegate = self;
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:self.captureMessageField];
    }else if(indexPath.section==1 && [[cameraAllKeysArray objectAtIndex:indexPath.row] isEqualToString:MOVECLOSER]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Move Closer Text:")];
            self.moveCloserField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Move Closer Text") andText:Klm([self.cameraTexts valueForKey:MOVECLOSER])];
            self.moveCloserField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.moveCloserField];
    }else if(indexPath.section==1 && [[cameraAllKeysArray objectAtIndex:indexPath.row] isEqualToString:HOLDPARALLEL]){
        UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Hold Parallel Text:")];
        self.holdParallelMessageField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Hold Parallel Text") andText:Klm([self.cameraTexts valueForKey:HOLDPARALLEL])];
        self.holdParallelMessageField.delegate = self;
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:self.holdParallelMessageField];
    }else if(indexPath.section==1 && [[cameraAllKeysArray objectAtIndex:indexPath.row] isEqualToString:ORIENTATION]){
        UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Orientation Text:")];
        self.orientationField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Orientation Text") andText:Klm([self.cameraTexts valueForKey:ORIENTATION])];
        self.orientationField.delegate = self;
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:self.orientationField];
    }
        else if(indexPath.section==0 && [[[self.summaryTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:DEPOSITTO]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Deposit To Title:")];
            self.depositToField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Deposit To Title") andText:Klm([self.summaryTexts valueForKey:DEPOSITTO])];
            self.depositToField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.depositToField];
    }else if(indexPath.section==0 && [[[self.summaryTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:INSTRUCTIONTEXT]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:self.selectedComponent.type==CHECKDEPOSIT?Klm(@"Front Instructions Text:"):Klm(@"Instructions Text")];
            self.instructionTextField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:self.selectedComponent.type==CHECKDEPOSIT?Klm(@"Front Instructions Text"):Klm(@"Instructions Text") andText:Klm([self.summaryTexts valueForKey:INSTRUCTIONTEXT])];
            self.instructionTextField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.instructionTextField];
    }else if(indexPath.section==0 && [[[self.summaryTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:SUBMITCANCELALERTTEXT]){
        UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Submit Cancel Alert Text:")];
        self.submitCancelAlertField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Submit Cancel Alert") andText:Klm([self.summaryTexts valueForKey:SUBMITCANCELALERTTEXT])];
        self.submitCancelAlertField.delegate = self;
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:self.submitCancelAlertField];
    }else if(indexPath.section==0 && [[[self.summaryTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:SUBMITALERTTEXT]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Submit Alert Text:")];
            self.submitAlertTextField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Submit Alert Text") andText:Klm([self.summaryTexts valueForKey:SUBMITALERTTEXT])];
            self.submitAlertTextField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.submitAlertTextField];
    }else if(indexPath.section==0 && [[[self.summaryTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:SUBMITBUTTONTEXT]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Submit Button Text:")];
            self.submitButtonText = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Submit Button Text") andText:Klm([self.summaryTexts valueForKey:SUBMITBUTTONTEXT])];
            self.submitButtonText.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.submitButtonText];
    }else if(indexPath.section==0 && [[[self.summaryTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:INSTRUCTIONTEXTBACK]){
        UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Back Instructions Text:")];
        self.instructionTextBackField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Back Instructions Text") andText:Klm([self.summaryTexts valueForKey:INSTRUCTIONTEXTBACK])];
        self.instructionTextBackField.delegate = self;
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:self.instructionTextBackField];
    }else if(indexPath.section==0 && [[[self.summaryTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:INSTRUCTIONTEXTBACKCAPTURE]){
        UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Back Instructions Text:")];
        self.instructionTextBackCaptureField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Back Instructions Text") andText:Klm([self.summaryTexts valueForKey:INSTRUCTIONTEXTBACKCAPTURE])];
        self.instructionTextBackCaptureField.delegate = self;
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:self.instructionTextBackCaptureField];
    }else if(indexPath.section==0 && [[[self.summaryTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:AMOUNT]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Amount Title:")];
            self.amountField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Amount Title") andText:Klm([self.summaryTexts valueForKey:AMOUNT])];
            self.amountField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.amountField];
    }else if(indexPath.section==0 && [[[self.summaryTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:MICR]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"MICR Title:")];
            self.micrField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"MICR Title") andText:Klm([self.summaryTexts valueForKey:MICR])];
            self.micrField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.micrField];
    }else if(indexPath.section==0 && [[[self.summaryTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:CHECKNUMBER]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Check Number Title:")];
            self.checkNumberField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Check Number Title") andText:Klm([self.summaryTexts valueForKey:CHECKNUMBER])];
            self.checkNumberField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.checkNumberField];
    }else if(indexPath.section==0 && [[[self.summaryTexts allKeys]objectAtIndex:indexPath.row] isEqualToString:ROUTINGNUMBER]){
            UILabel *label = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 8, 250, 22) andText:Klm(@"Routing Number Title:")];
            self.routingNumberField = [AppUtilities createTextFieldWithTag:(int)indexPath.row frame:CGRectMake([[UIScreen mainScreen]bounds].size.width-300, 32, 285, 30) placeholder:Klm(@"Routing Number Title") andText:Klm([self.summaryTexts valueForKey:ROUTINGNUMBER])];
            self.routingNumberField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.routingNumberField];
    }
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return Klm(@"Summary Screen");
    }else if(section==1){
        return Klm(@"Camera Screen");
    }else{
        return Klm(@"Preview Screen");
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
    if (textField == self.frontRetakeField) {
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.frontRetakeField.tag inSection:2]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.frontUseField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.frontUseField.tag inSection:2]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.backRetakeField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.backRetakeField.tag inSection:2]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.previewCancelField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.previewCancelField.tag inSection:2]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.backUseField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.backUseField.tag inSection:2]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.frontUserInstructionField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.frontUserInstructionField.tag inSection:1]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.backUserInstructionField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.backUserInstructionField.tag inSection:1]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.cancelButtonField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.cancelButtonField.tag inSection:1]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.pageNotFoundField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.pageNotFoundField.tag inSection:1]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.holdSteadyField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.holdSteadyField.tag inSection:1]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.moveCloserField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.moveCloserField.tag inSection:1]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }
    else if(textField == self.userInstructionField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.userInstructionField.tag inSection:1]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.centerMessageField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.centerMessageField.tag inSection:1]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.zoomOutMessageField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.zoomOutMessageField.tag inSection:1]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.captureMessageField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.captureMessageField.tag inSection:1]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.deviceOrientationField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.deviceOrientationField.tag inSection:1]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.depositToField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.depositToField.tag inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.instructionTextField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.instructionTextField.tag inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.amountField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.amountField.tag inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.micrField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.micrField.tag inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.submitAlertTextField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.submitAlertTextField.tag inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.submitButtonText){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.submitButtonText.tag inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.routingNumberField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.routingNumberField.tag inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.checkNumberField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.checkNumberField.tag inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.instructionTextBackField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.instructionTextBackField.tag inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.instructionTextBackCaptureField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.instructionTextBackCaptureField.tag inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.submitCancelAlertField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.submitCancelAlertField.tag inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.holdParallelMessageField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.holdParallelMessageField.tag inSection:1]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField == self.orientationField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.orientationField.tag inSection:1]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.frontRetakeField) {
        [self.previewTexts setValue:self.frontRetakeField.text forKey:FRONTRETAKEBUTTON];
    }else if(textField == self.frontUseField){
        [self.previewTexts setValue:self.frontUseField.text forKey:FRONTUSEBUTTON];
    }else if(textField == self.backRetakeField){
        [self.previewTexts setValue:self.backRetakeField.text forKey:BACKRETAKEBUTTON];
    }else if(textField == self.backUseField){
        [self.previewTexts setValue:self.backUseField.text forKey:BACKUSEBUTTON];
    }else if(textField == self.previewCancelField){
        [self.previewTexts setValue:self.previewCancelField.text forKey:CANCELBUTTON];
    }else if(textField == self.frontUserInstructionField){
        [self.cameraTexts setValue:self.frontUserInstructionField.text forKey:USERINSTRUCTIONFRONT];
    }else if(textField == self.backUserInstructionField){
        [self.cameraTexts setValue:self.backUserInstructionField.text forKey:USERINSTRUCTIONBACK];
    }else if(textField == self.cancelButtonField){
        [self.cameraTexts setValue:self.cancelButtonField.text forKey:CANCELBUTTON];
    }else if(textField == self.holdSteadyField){
        [self.cameraTexts setValue:self.holdSteadyField.text forKey:HOLDSTEADY];
    }else if(textField == self.moveCloserField){
        [self.cameraTexts setValue:self.moveCloserField.text forKey:MOVECLOSER];
    }else if(textField == self.moveCloserField){
        [self.cameraTexts setValue:self.centerMessageField.text forKey:CENTERMESSAGE];
    }else if(textField == self.moveCloserField){
        [self.cameraTexts setValue:self.zoomOutMessageField.text forKey:ZOOMOUTMESSAGE];
    }else if(textField == self.captureMessageField){
        [self.cameraTexts setValue:self.captureMessageField.text forKey:CAPTUREDMESSAGE];
    }else if(textField == self.holdParallelMessageField){
        [self.cameraTexts setValue:self.holdParallelMessageField.text forKey:HOLDPARALLEL];
    }else if(textField == self.orientationField){
        [self.cameraTexts setValue:self.orientationField.text forKey:ORIENTATION];
    }else if(textField == self.depositToField){
        [self.summaryTexts setValue:self.depositToField.text forKey:DEPOSITTO];
    }else if(textField == self.instructionTextField){
        [self.summaryTexts setValue:self.instructionTextField.text forKey:INSTRUCTIONTEXT];
    }else if(textField == self.amountField){
        [self.summaryTexts setValue:self.amountField.text forKey:AMOUNT];
    }else if(textField == self.micrField){
        [self.summaryTexts setValue:self.micrField.text forKey:MICR];
    }else if(textField == self.submitAlertTextField){
        [self.summaryTexts setValue:self.submitAlertTextField.text forKey:SUBMITALERTTEXT];
    }else if(textField == self.submitButtonText){
        [self.summaryTexts setValue:self.submitButtonText.text forKey:SUBMITBUTTONTEXT];
    }else if(textField == self.routingNumberField){
        [self.summaryTexts setValue:self.routingNumberField.text forKey:ROUTINGNUMBER];
    }else if(textField == self.checkNumberField){
        [self.summaryTexts setValue:self.checkNumberField.text forKey:CHECKNUMBER];
    }else if(textField == self.instructionTextBackField){
        [self.summaryTexts setValue:self.instructionTextBackField.text forKey:INSTRUCTIONTEXTBACK];
    }else if(textField == self.instructionTextBackCaptureField){
        [self.summaryTexts setValue:self.instructionTextBackCaptureField.text forKey:INSTRUCTIONTEXTBACKCAPTURE];
    }else if(textField == self.submitCancelAlertField){
        [self.summaryTexts setValue:self.submitCancelAlertField.text forKey:SUBMITCANCELALERTTEXT];
    }
    textField.font = textFieldFont;
    [AppUtilities reduceFontOfTextField:textField];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.frontRetakeField) {
        [self.previewTexts setValue:self.frontRetakeField.text forKey:FRONTRETAKEBUTTON];
    }else if(textField == self.frontUseField){
        [self.previewTexts setValue:self.frontUseField.text forKey:FRONTUSEBUTTON];
    }else if(textField == self.backRetakeField){
        [self.previewTexts setValue:self.backRetakeField.text forKey:BACKRETAKEBUTTON];
    }else if(textField == self.backUseField){
        [self.previewTexts setValue:self.backUseField.text forKey:BACKUSEBUTTON];
    }else if(textField == self.previewCancelField){
        [self.previewTexts setValue:self.previewCancelField.text forKey:CANCELBUTTON];
    }else if(textField == self.frontUserInstructionField){
        [self.cameraTexts setValue:self.frontUserInstructionField.text forKey:USERINSTRUCTIONFRONT];
    }else if(textField == self.backUserInstructionField){
        [self.cameraTexts setValue:self.backUserInstructionField.text forKey:USERINSTRUCTIONBACK];
    }else if(textField == self.cancelButtonField){
        [self.cameraTexts setValue:self.cancelButtonField.text forKey:CANCELBUTTON];
    }else if(textField == self.holdSteadyField){
        [self.cameraTexts setValue:self.holdSteadyField.text forKey:HOLDSTEADY];
    }else if(textField == self.centerMessageField){
        [self.cameraTexts setValue:self.centerMessageField.text forKey:CENTERMESSAGE];
    }else if(textField == self.zoomOutMessageField){
        [self.cameraTexts setValue:self.zoomOutMessageField.text forKey:ZOOMOUTMESSAGE];
    }else if(textField == self.captureMessageField){
        [self.cameraTexts setValue:self.captureMessageField.text forKey:CAPTUREDMESSAGE];
    }else if(textField == self.holdParallelMessageField){
        [self.cameraTexts setValue:self.holdParallelMessageField.text forKey:HOLDPARALLEL];
    }else if(textField == self.orientationField){
        [self.cameraTexts setValue:self.orientationField.text forKey:ORIENTATION];
    }else if(textField == self.moveCloserField){
        [self.cameraTexts setValue:self.moveCloserField.text forKey:MOVECLOSER];
    }else if(textField == self.depositToField){
        [self.summaryTexts setValue:self.depositToField.text forKey:DEPOSITTO];
    }else if(textField == self.instructionTextField){
        [self.summaryTexts setValue:self.instructionTextField.text forKey:INSTRUCTIONTEXT];
    }else if(textField == self.amountField){
        [self.summaryTexts setValue:self.amountField.text forKey:AMOUNT];
    }else if(textField == self.micrField){
        [self.summaryTexts setValue:self.micrField.text forKey:MICR];
    }else if(textField == self.submitAlertTextField){
        [self.summaryTexts setValue:self.submitAlertTextField.text forKey:SUBMITALERTTEXT];
    }else if(textField == self.submitButtonText){
        [self.summaryTexts setValue:self.submitButtonText.text forKey:SUBMITBUTTONTEXT];
    }else if(textField == self.routingNumberField){
        [self.summaryTexts setValue:self.routingNumberField.text forKey:ROUTINGNUMBER];
    }else if(textField == self.checkNumberField){
        [self.summaryTexts setValue:self.checkNumberField.text forKey:CHECKNUMBER];
    }else if(textField == self.instructionTextBackField){
        [self.summaryTexts setValue:self.instructionTextBackField.text forKey:INSTRUCTIONTEXTBACK];
    }else if(textField == self.instructionTextBackCaptureField){
        [self.summaryTexts setValue:self.instructionTextBackCaptureField.text forKey:INSTRUCTIONTEXTBACKCAPTURE];
    }else if(textField == self.submitCancelAlertField){
        [self.summaryTexts setValue:self.submitCancelAlertField.text forKey:SUBMITCANCELALERTTEXT];
    }
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    [textField resignFirstResponder];
    textField.font = textFieldFont;
    [AppUtilities reduceFontOfTextField:textField];
    return YES;
}

#pragma mark Local Methods
/*
 This method is used to go back to the previous screen and also save the general settings.
 */
-(IBAction)backButtonAction:(id)sender{
    self.selectedComponent.texts.previewText = self.previewTexts;
    self.selectedComponent.texts.cameraText = self.cameraTexts;
    self.selectedComponent.texts.summaryText = self.summaryTexts;
    [self.navigationController popViewControllerAnimated:YES];
}


@end
