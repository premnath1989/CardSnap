//
//  CustomColorViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/16/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "CustomColorViewController.h"
#import "ProfileManager.h"
@interface CustomColorViewController ()
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, strong) UITextField *redField,*greenField,*blueField;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, assign) Profile *profileObject;
@property (nonatomic, assign) colorType colorType;
@property (nonatomic, assign) int redValue,greenValue,blueValue;
@end

@implementation CustomColorViewController
@synthesize tableTopConstraint;
@synthesize redField,greenField,blueField;
@synthesize table;
@synthesize previewButton;

#pragma mark Constructor Methods
-(id)initWithProfile:(Profile*)profile withType:(colorType)colorType{
    self = [super init];
    if (self) {
        self.profileObject = profile;
        self.colorType = colorType;
    }
    return self;
}

#pragma mark ViewLifeCycle Methods

-(void)dealloc{
    self.redField.delegate = nil;
    self.redField = nil;
    self.greenField.delegate = nil;
    self.greenField = nil;
    self.blueField.delegate = nil;
    self.blueField = nil;
    self.previewButton = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant +=20;
    }else{
        self.tableTopConstraint.constant -=42;
    }
    
    if (self.colorType == HEADER_COLOR) {
        self.navigationItem.title = Klm(@"Custom Header Color");
    }else if(self.colorType == BUTTON_COLOR){
        self.navigationItem.title = Klm(@"Custom Button Color");
    }else if(self.colorType == TITLE_COLOR){
        self.navigationItem.title = Klm(@"Custom Header Title Color");
    }else if(self.colorType == TEXT_COLOR){
        self.navigationItem.title = Klm(@"Custom Button Title Color");
    }
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    
    self.redValue = 0;
    self.greenValue = 0;
    self.blueValue = 0;
    NSString *newString = nil;
    if ([self.profileObject.theme.themeColor hasPrefix:@"#"] && self.colorType == HEADER_COLOR)
    {
        newString = [self.profileObject.theme.themeColor substringFromIndex:1];
    }
    else if([self.profileObject.theme.themeColor hasPrefix:@"0x"] && self.colorType == HEADER_COLOR)
    {
        newString = [self.profileObject.theme.themeColor substringFromIndex:2];
    }else if ([self.profileObject.theme.buttonColor hasPrefix:@"#"] && self.colorType == BUTTON_COLOR)
    {
        newString = [self.profileObject.theme.buttonColor substringFromIndex:1];
    }
    else if([self.profileObject.theme.buttonColor hasPrefix:@"0x"] && self.colorType == BUTTON_COLOR)
    {
        newString = [self.profileObject.theme.buttonColor substringFromIndex:2];
    }else if ([self.profileObject.theme.titleColor hasPrefix:@"#"] && self.colorType == TITLE_COLOR)
    {
        newString = [self.profileObject.theme.titleColor substringFromIndex:1];
    }
    else if([self.profileObject.theme.titleColor hasPrefix:@"0x"] && self.colorType == TITLE_COLOR)
    {
        newString = [self.profileObject.theme.titleColor substringFromIndex:2];
    }else if ([self.profileObject.theme.buttonTextColor hasPrefix:@"#"] && self.colorType == TEXT_COLOR)
    {
        newString = [self.profileObject.theme.buttonTextColor substringFromIndex:1];
    }
    else if([self.profileObject.theme.buttonTextColor hasPrefix:@"0x"] && self.colorType == TEXT_COLOR)
    {
        newString = [self.profileObject.theme.buttonTextColor substringFromIndex:2];
    }
    
    if([self.profileObject.theme.themeColor length] ==6 && self.colorType == HEADER_COLOR)
        newString = self.profileObject.theme.themeColor;
    else if([self.profileObject.theme.buttonColor length] ==6 && self.colorType == BUTTON_COLOR)
        newString = self.profileObject.theme.buttonColor;
    else if([self.profileObject.theme.buttonColor length] ==6 && self.colorType == TITLE_COLOR)
        newString = self.profileObject.theme.titleColor;
    else if([self.profileObject.theme.buttonColor length] ==6 && self.colorType == TEXT_COLOR)
        newString = self.profileObject.theme.buttonTextColor;
    // wrong string so retunrn a defalut white color
    if ([newString length] !=6)
    {
        return;
    }
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    NSString *rString = [newString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [newString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [newString substringWithRange:range];
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    self.redValue = (int)r;
    self.greenValue = (int)g;
    self.blueValue = (int)b;
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.redField.delegate = nil;
    self.greenField.delegate = nil;
    self.blueField.delegate = nil;
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
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 3;
    }else{
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier" ;
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if (indexPath.section==1) {
            previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [previewButton setTitle:Klm(@"PREVIEW") forState:UIControlStateNormal];
            AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
            if (self.colorType == HEADER_COLOR) {
                [utilitiesObject setThemeColor:[UIColor colorWithRed:[redField.text floatValue]/255.0f green:[greenField.text floatValue]/255.0f blue:[blueField.text floatValue]/255.0f alpha:1.0f] andTitleColor:[utilitiesObject colorWithHexString:self.profileObject.theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
                [previewButton setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:self.profileObject.theme.buttonColor] withTheme:self.profileObject.theme] forState:UIControlStateNormal];
                [previewButton setTitleColor:[utilitiesObject colorWithHexString:self.profileObject.theme.buttonTextColor] forState:UIControlStateNormal];
            }else if(self.colorType == BUTTON_COLOR){
                [previewButton setBackgroundImage:[AppUtilities getcustomButtonImage:[UIColor colorWithRed:[redField.text floatValue]/255.0f green:[greenField.text floatValue]/255.0f blue:[blueField.text floatValue]/255.0f alpha:1.0f] withTheme:self.profileObject.theme] forState:UIControlStateNormal];
                [previewButton setTitleColor:[utilitiesObject colorWithHexString:self.profileObject.theme.buttonTextColor] forState:UIControlStateNormal];
            }else if(self.colorType == TITLE_COLOR){
                [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:self.profileObject.theme.themeColor] andTitleColor:[UIColor colorWithRed:[redField.text floatValue]/255.0f green:[greenField.text floatValue]/255.0f blue:[blueField.text floatValue]/255.0f alpha:1.0f] forNavigationBar:self.navigationController.navigationBar];
                [previewButton setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:self.profileObject.theme.buttonColor] withTheme:self.profileObject.theme] forState:UIControlStateNormal];
                [previewButton setTitleColor:[utilitiesObject colorWithHexString:self.profileObject.theme.buttonTextColor] forState:UIControlStateNormal];
            }else if(self.colorType == TEXT_COLOR){
                [previewButton setTitleColor:[UIColor colorWithRed:[redField.text floatValue]/255.0f green:[greenField.text floatValue]/255.0f blue:[blueField.text floatValue]/255.0f alpha:1.0f] forState:UIControlStateNormal];
                [previewButton setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:self.profileObject.theme.buttonColor] withTheme:self.profileObject.theme] forState:UIControlStateNormal];
                
            }
            utilitiesObject = nil;
            [previewButton setFrame:CGRectMake(20, 13, [[UIScreen mainScreen]bounds].size.width-40, 44)];
            [previewButton.titleLabel setFont:[UIFont fontWithName:FONTNAME size:17]];
            cell.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:previewButton];
        }else if (indexPath.section==0 && indexPath.row==0) {
            self.redField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 50, 25) placeholder:@"" andText:[NSString stringWithFormat:@"%d",self.redValue]];
            redField.delegate = self;
            cell.accessoryView = redField;
        }else if(indexPath.section==0 && indexPath.row==1){
            self.greenField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 50, 25) placeholder:@"" andText:[NSString stringWithFormat:@"%d",self.greenValue]];
            greenField.delegate = self;
            cell.accessoryView = greenField;
        }else if(indexPath.section==0 && indexPath.row==2){
            self.blueField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(0, 0, 50, 25) placeholder:@"" andText:[NSString stringWithFormat:@"%d",self.blueValue]];
            blueField.delegate = self;
            cell.accessoryView = blueField;
        }
        if (indexPath.section==0 && indexPath.row<2){
            UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(15, 43.5f, [[UIScreen mainScreen]bounds].size.width-15, 1)];
            line.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
            [cell.contentView addSubview:line];
        }
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
    if (indexPath.section==0 && indexPath.row==0) {
        cell.textLabel.text = Klm(@"Red (0 - 255):");
    }else if(indexPath.section==0 && indexPath.row==1){
        cell.textLabel.text = Klm(@"Green (0 - 255):");
    }else if(indexPath.section==0 && indexPath.row==2){
        cell.textLabel.text = Klm(@"Blue (0 - 255):");
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
        return 70;
    }
    return 44;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return Klm(@"RGB COLOR");
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
}

#pragma mark UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField==redField) {
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField==greenField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else if(textField==blueField){
        CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
   // [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    if (textField == redField) {
        self.redValue = [textField.text intValue];
    }else if(textField == greenField){
        self.greenValue = [textField.text intValue];
    }else if(textField == blueField){
        self.blueValue = [textField.text intValue];
    }
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    if (self.colorType == HEADER_COLOR) {
        [utilitiesObject setThemeColor:[UIColor colorWithRed:[redField.text floatValue]/255.0f green:[greenField.text floatValue]/255.0f blue:[blueField.text floatValue]/255.0f alpha:1.0f] andTitleColor:[utilitiesObject colorWithHexString:self.profileObject.theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
    }else if(self.colorType == BUTTON_COLOR){
        [previewButton setBackgroundImage:[AppUtilities getcustomButtonImage:[UIColor colorWithRed:[redField.text floatValue]/255.0f green:[greenField.text floatValue]/255.0f blue:[blueField.text floatValue]/255.0f alpha:1.0f] withTheme:self.profileObject.theme] forState:UIControlStateNormal];
    }else if(self.colorType == TITLE_COLOR){
        [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:self.profileObject.theme.themeColor] andTitleColor:[UIColor colorWithRed:[redField.text floatValue]/255.0f green:[greenField.text floatValue]/255.0f blue:[blueField.text floatValue]/255.0f alpha:1.0f] forNavigationBar:self.navigationController.navigationBar];
    }else if(self.colorType == TEXT_COLOR){
        [previewButton setTitleColor:[UIColor colorWithRed:[redField.text floatValue]/255.0f green:[greenField.text floatValue]/255.0f blue:[blueField.text floatValue]/255.0f alpha:1.0f] forState:UIControlStateNormal];
    }
    utilitiesObject = nil;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField == redField) {
        self.redValue = [textField.text intValue];
    }else if(textField == greenField){
        self.greenValue = [textField.text intValue];
    }else if(textField == blueField){
        self.blueValue = [textField.text intValue];
    }
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    if (self.colorType == HEADER_COLOR) {
        [utilitiesObject setThemeColor:[UIColor colorWithRed:[redField.text floatValue]/255.0f green:[greenField.text floatValue]/255.0f blue:[blueField.text floatValue]/255.0f alpha:1.0f] andTitleColor:[utilitiesObject colorWithHexString:self.profileObject.theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
    }else if(self.colorType == BUTTON_COLOR){
        [previewButton setBackgroundImage:[AppUtilities getcustomButtonImage:[UIColor colorWithRed:[redField.text floatValue]/255.0f green:[greenField.text floatValue]/255.0f blue:[blueField.text floatValue]/255.0f alpha:1.0f] withTheme:self.profileObject.theme] forState:UIControlStateNormal];
    }else if(self.colorType == TITLE_COLOR){
        [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:self.profileObject.theme.themeColor] andTitleColor:[UIColor colorWithRed:[redField.text floatValue]/255.0f green:[greenField.text floatValue]/255.0f blue:[blueField.text floatValue]/255.0f alpha:1.0f] forNavigationBar:self.navigationController.navigationBar];
    }else if(self.colorType == TEXT_COLOR){
        [previewButton setTitleColor:[UIColor colorWithRed:[redField.text floatValue]/255.0f green:[greenField.text floatValue]/255.0f blue:[blueField.text floatValue]/255.0f alpha:1.0f] forState:UIControlStateNormal];
    }
    utilitiesObject = nil;
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    return YES;
}
                    
#pragma mark Local Methods
/*
 This method is used to go back to the previous screen and also save the color settings.
 */
-(IBAction)backButtonAction:(id)sender{
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
    if (self.colorType == BUTTON_COLOR) {
        self.profileObject.theme.buttonColor = [NSString stringWithFormat:@"#%@",[utilitiesObject hexStringFromRed:[self.redField.text floatValue] green:[self.greenField.text floatValue] blue:[self.blueField.text floatValue]]];
    }else if(self.colorType == HEADER_COLOR){
        self.profileObject.theme.themeColor = [NSString stringWithFormat:@"#%@",[utilitiesObject hexStringFromRed:[self.redField.text floatValue] green:[self.greenField.text floatValue] blue:[self.blueField.text floatValue]]];
        [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:self.profileObject.theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:self.profileObject.theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
    }else if(self.colorType == TITLE_COLOR){
        self.profileObject.theme.titleColor = [NSString stringWithFormat:@"#%@",[utilitiesObject hexStringFromRed:[self.redField.text floatValue] green:[self.greenField.text floatValue] blue:[self.blueField.text floatValue]]];
        [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:self.profileObject.theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:self.profileObject.theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
    }else if(self.colorType == TEXT_COLOR){
        self.profileObject.theme.buttonTextColor = [NSString stringWithFormat:@"#%@",[utilitiesObject hexStringFromRed:[self.redField.text floatValue] green:[self.greenField.text floatValue] blue:[self.blueField.text floatValue]]];
    }
    utilitiesObject = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
