//
//  BPInstructionsViewController.m
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/3/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "BPInstructionsViewController.h"

@interface BPInstructionsViewController ()
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic, assign) Component *componentObject;
@property (nonatomic, strong) AppUtilities *utilitiesObject;
@end

@implementation BPInstructionsViewController

#pragma mark Constructor Methods
-(id)initWithComponent:(Component*)component{
    self = [super init];
    if (self) {
        self.componentObject = component;
    }
    return self;
}

#pragma mark ViewLifeCycle Methods

-(void)dealloc{

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
    
    self.utilitiesObject = [[AppUtilities alloc] init];
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    
    self.navigationItem.rightBarButtonItem = [AppUtilities getSettingsButtonItemWithTarget:self andAction:@selector(settingsButtonAction:)];
    
    self.table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.table.separatorColor = [UIColor clearColor];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationItem.title = Klm(self.componentObject.name);
    [self.table reloadData];
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
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = TABLECELLIDENTIFIER ;
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row==1) {
//        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(([[UIScreen mainScreen]bounds].size.width-270)/2, 30, 270, 211)];
//        imageView.image = [UIImage imageNamed:BILLPAYSAMPLE];
//        [cell.contentView addSubview:imageView];
        UIButton *captureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        captureBtn.frame = CGRectMake(([[UIScreen mainScreen]bounds].size.width-120)/2, 20, 120, 120);
        [captureBtn setBackgroundImage:[UIImage imageNamed:@"bluecircle.png"] forState:UIControlStateNormal];
        [captureBtn setImage:[UIImage imageNamed:@"bill pay capture.png"] forState:UIControlStateNormal];
        [captureBtn addTarget:self action:@selector(continueButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        captureBtn.layer.cornerRadius = 60;
        captureBtn.backgroundColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
        [cell.contentView addSubview:captureBtn];
        
        UILabel *line1 = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, [[UIScreen mainScreen]bounds].size.width-30, 1)];
        [line1 setBackgroundColor:[UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1.0f]];
        
        UILabel *line2 = [[UILabel alloc]initWithFrame:CGRectMake(15, 159, [[UIScreen mainScreen]bounds].size.width-30, 1)];
        [line2 setBackgroundColor:[UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1.0f]];
        
        [cell.contentView addSubview:line1];
        [cell.contentView addSubview:line2];
    }else if(indexPath.row==0){
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, [[UIScreen mainScreen]bounds].size.width-60, 150)];
        label.numberOfLines = 0;
        label.font = [UIFont fontWithName:FONTNAME size:18];
        NSString *string = Klm([self.componentObject.texts.summaryText valueForKey:INSTRUCTIONTEXT]);
        NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc]init];
        [attrString setAttributedString:[[NSAttributedString alloc]initWithString:string]];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:8];
        [attrString addAttribute:NSParagraphStyleAttributeName
                           value:style
                           range:NSMakeRange(0, string.length)];
        label.attributedText = attrString;
        [label setTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:label];
    }else if(indexPath.row==2){
        UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [submitBtn setTitle:Klm([self.componentObject.texts.summaryText valueForKey:SUBMITBUTTONTEXT]) forState:UIControlStateNormal];
        //AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        submitBtn.enabled = NO;
        [submitBtn setBackgroundImage:[AppUtilities getcustomButtonImage:[UIColor grayColor] withTheme:[[ProfileManager sharedInstance]getActiveProfile].theme] forState:UIControlStateNormal];
        //utilitiesObject = nil;
        submitBtn.titleLabel.font = [UIFont fontWithName:FONTNAME size:18];
        [submitBtn addTarget:self action:@selector(continueButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [submitBtn setFrame:CGRectMake(20, 50, [[UIScreen mainScreen]bounds].size.width-40, 40)];
        [cell.contentView addSubview:submitBtn];
    }
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
    
    [AppUtilities adjustFontSizeOfLabel:cell.textLabel];

    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 150;
    }else if(indexPath.row==1){
        return 160;
    }else if(indexPath.row==2){
        return 100;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

#pragma mark Local Methods
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)backButtonAction:(id)sender{
    [self.delegate instructionsBackButtonClicked];
}

/*
 This method is used to push to settings controller.
 */
-(IBAction)settingsButtonAction:(id)sender{
    [self.delegate instructionSettingsButtonClicked];
}

/*
 This method is used to push to capture controller.
 */
-(IBAction)continueButtonAction:(id)sender
{
     [self.delegate instructionContinueButtonClicked];
}



@end
