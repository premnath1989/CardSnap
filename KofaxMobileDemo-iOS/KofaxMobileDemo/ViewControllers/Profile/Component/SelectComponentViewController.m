//
//  SelectComponentViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/13/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//
#import "SelectComponentViewController.h"
@interface SelectComponentViewController ()
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UITextField *renameTextField;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath; //may be deprecate it
@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic,assign)  NSMutableArray * componentsArray;
@property (nonatomic)NSInteger selectedRow;
@property (nonatomic, assign) Theme *themeObject;
@end

@implementation SelectComponentViewController
@synthesize tableTopConstraint;
@synthesize dataArray;
@synthesize renameTextField;
@synthesize selectedIndexPath;
@synthesize table;

#pragma mark Constructor Methods
-(id)initwithArray : (NSMutableArray*)components andTheme:(Theme *)theme
{
    if(self == [super init])
    {
        self.componentsArray = components;
        self.themeObject = theme;
        self.selectedRow = -1;
    }
    return self;
}

#pragma mark ViewLifeCycle Methods

-(void)dealloc{
    self.dataArray = nil;
    self.renameTextField.delegate = nil;
    self.renameTextField = nil;
    self.selectedIndexPath = nil;
    self.table.delegate = nil;
    self.table.dataSource = nil;
    self.table = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant += 20;
    }else{
        self.tableTopConstraint.constant -=42;
    }
    
    self.dataArray = [[ProfileManager sharedInstance] getComponentTypes];
    self.navigationItem.title = Klm(@"Select Component");
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.renameTextField.delegate = nil;
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
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return [dataArray count];
    }else if(selectedIndexPath && section==1){
        return 1;
    }else if(section==2){
        return 1;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"cellIdentifier" ;
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if (indexPath.section==1 && indexPath.row==0 && selectedIndexPath) {
            self.renameTextField = [AppUtilities createTextFieldWithTag:0 frame:CGRectMake(15, 0, [[UIScreen mainScreen]bounds].size.width-30, 44) placeholder:@"Enter Component Name" andText:[dataArray objectAtIndex:selectedIndexPath.row]];
            renameTextField.font = [UIFont fontWithName:FONTNAME size:15];
            self.renameTextField.textAlignment = NSTextAlignmentLeft;
            renameTextField.delegate = self;
            [cell.contentView addSubview:renameTextField];
        }else if (indexPath.section==2) {
            UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
            [saveBtn setTitleColor:[utilitiesObject colorWithHexString:self.themeObject.buttonTextColor] forState:UIControlStateNormal];
            [saveBtn setBackgroundImage:[AppUtilities getcustomButtonImage:[utilitiesObject colorWithHexString:self.themeObject.buttonColor] withTheme:self.themeObject] forState:UIControlStateNormal];
            utilitiesObject = nil;
            [saveBtn setTitle:Klm(@"Save") forState:UIControlStateNormal];
            if (selectedIndexPath) {
                saveBtn.enabled = YES;
            }else{
                saveBtn.enabled = NO;
            }
           // [saveBtn setBackgroundColor: [UIColor colorWithRed:21.0f/255.0f green:123.0f/255.0f blue:191.0f/255.0f alpha:1.0f]];
            [saveBtn addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [saveBtn setFrame:CGRectMake(20, 10, [[UIScreen mainScreen]bounds].size.width-40, 36)];
            cell.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:saveBtn];
        }else if(indexPath.section==0 && indexPath.row<([self.dataArray count]-1)){
                UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(15, 43.5f, [[UIScreen mainScreen]bounds].size.width-15, 1)];
                line.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
                [cell.contentView addSubview:line];
        }
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
    if (indexPath.section==0) {
        cell.textLabel.text = Klm([dataArray objectAtIndex:indexPath.row]);
    }
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return Klm(@"Select Component");
    }else if(section==1&&selectedIndexPath){
        return Klm(@"Name Selected Component");
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==2) {
        return 60;
    }else if(indexPath.section==1 && !selectedIndexPath){
        return 0;
    }
    return 44;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if (selectedIndexPath && selectedIndexPath.row!=indexPath.row)
        {
            UITableViewCell *preSelectedCell = [tableView cellForRowAtIndexPath:selectedIndexPath];
            preSelectedCell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            selectedIndexPath = indexPath;
            [self.table reloadData];
        }
        selectedIndexPath = indexPath;
        self.selectedRow = indexPath.row;
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        renameTextField.text = Klm([dataArray objectAtIndex:indexPath.row]);
    }
}


#pragma mark UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect  rect=[self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    [self.table setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self.table setContentOffset:CGPointMake(0,0) animated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Local Methods
/*
 This method is used to add the component to the profile.
 */
-(IBAction)saveButtonAction:(id)sender
{
    if ([[renameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]length]!=0 )
    {
        BOOL isExist = NO;
      //  NSArray *componentArray = [self.emptyProfile componentArray];
        for (Component *compObject in self.componentsArray) {
            if ([renameTextField.text isEqualToString:Klm(compObject.name)]) {
                isExist = YES;
                break;
            }
        }
        if (isExist) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:Klm(@"Duplicate component name please enter other name") delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
            [alertView show];
        }else{
            Component* component = [[Component alloc] initWithType:(int)self.selectedRow];
            component.name = renameTextField.text;
            [self.componentsArray addObject:component];
            //[self.emptyProfile addComponent:component];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }else{
        renameTextField.text = @"";
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:Klm(@"Please enter the component name") delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
        [alertView show];
    }
    
    
}
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)backButtonAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
