//
//  DLInstructionsViewController.m
//  KofaxMobileDemo
//
//  Created by Mahendra on 31/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "DLInstructionsViewController.h"



@interface DLInstructionsViewController ()<UIAlertViewDelegate,UIActionSheetDelegate>
{
    
}
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic, assign) Component *componentObject;
@property (nonatomic) captureSides captureSide;

@end

@implementation DLInstructionsViewController



-(id)initWithComponent: (Component*)component
{
    if(self = [super init])
    {
        self.componentObject = component;
        if(self.componentObject.type != IDCARD)
        {
            NSLog(@"DLInstructionsViewController: Component passed is not DL");
            return nil;
        }
    }
    
    return self;
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

-(void)dealloc{
    self.frontThumbnail = nil;
    self.backThumbnail = nil;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant += 20;
    }else{
        self.tableTopConstraint.constant -=42;
    }
    self.navigationItem.rightBarButtonItem = [AppUtilities getSettingsButtonItemWithTarget:self andAction:@selector(settingsButtonAction:)];
    
    self.table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.table.separatorColor = [UIColor clearColor];
    if (!self.utilitiesObject) {
        self.utilitiesObject = [[AppUtilities alloc] init];
    }
    
    self.captureSide = NONESIDE;
    
    //blur the view when app goes into background
    [self createViewBlurInBackground];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.navigationItem.title = Klm(self.componentObject.name);
    
    if(self.frontThumbnail || self.backThumbnail)
    {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:Klm(STATICCANCELBUTTONTEXT) style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
        cancelButton.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    else
        self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    
   

    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.table reloadData];
}


#pragma mark UITableViewDataSource and UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.componentObject.type == IDCARD)
        return 3;
    
    return  0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cellIdentifier" ;
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
     if(self.componentObject.type == IDCARD && indexPath.row==0)
     {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, tableView.rowHeight/2, [[UIScreen mainScreen]bounds].size.width-30, 160)];
        label.numberOfLines = 0;
        label.font = [UIFont fontWithName:FONTNAME size:18];
        NSString *string = Klm([self.componentObject.texts.summaryText valueForKey:INSTRUCTIONTEXT]);
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
        [AppUtilities adjustFontSizeOfLabel:label];
    }
     else if(self.componentObject.type == IDCARD && indexPath.row==1)
     {
        UIButton *licenseFront = [UIButton buttonWithType:UIButtonTypeCustom];
        [licenseFront setBackgroundImage:[UIImage imageNamed:@"bluecircle.png"] forState:UIControlStateNormal];
         licenseFront.layer.cornerRadius = 60;
         licenseFront.backgroundColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];

         //changed to accomodate new instructions get image from storage and show thumbnail
         if(self.frontThumbnail)
         {
             //check the orientation and rotate if necessary
             if(self.frontThumbnail.size.height > self.frontThumbnail.size.width)
                 self.frontThumbnail = [AppUtilities rotateImageLandscape:self.frontThumbnail];
             
             [licenseFront setImage:[AppUtilities imageWithImage:self.frontThumbnail scaledToSize:CGSizeMake(96, 60)] forState:UIControlStateNormal];
         }
         
         else
             [licenseFront setImage:[UIImage imageNamed:@"dl_front.png"] forState:UIControlStateNormal];
         
        [licenseFront addTarget:self action:@selector(licenseFrontButtonAction:) forControlEvents:UIControlEventTouchUpInside];
         [licenseFront setExclusiveTouch:YES];
         int gap;
//         if (self.captureSide == ONESIDE) {
//             gap = ([[UIScreen mainScreen]bounds].size.width-120)/2;
//         }else{
             gap = ([[UIScreen mainScreen]bounds].size.width-240)/3;
        // }
         
         licenseFront.frame = CGRectMake(gap, 30, 120, 120);
         
         UILabel *frontLabel = [[UILabel alloc]initWithFrame:CGRectMake(gap, 160, 120, 21)];
         frontLabel.textAlignment = NSTextAlignmentCenter;
         frontLabel.text = Klm(@"Front");
         frontLabel.font = [UIFont fontWithName:FONTNAME size:18];
         
         [cell.contentView addSubview:licenseFront];
         [cell.contentView addSubview:frontLabel];
         [AppUtilities adjustFontSizeOfLabel:frontLabel];
         
         
        // if (self.captureSide != ONESIDE) {
             UIButton *licenseBack = [UIButton buttonWithType:UIButtonTypeCustom];
             licenseBack.layer.cornerRadius = 60;
             licenseBack.backgroundColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
         
         
             if (self.captureSide != ONESIDE) {
                 licenseBack.userInteractionEnabled = YES;
                 [licenseBack setBackgroundImage:[UIImage imageNamed:@"bluecircle.png"] forState:UIControlStateNormal];

             }
             else {
                 
                 licenseBack.userInteractionEnabled = NO;
                 [licenseBack setBackgroundImage:[UIImage imageNamed:@"graycircle.png"] forState:UIControlStateNormal];


             }

             if(self.backThumbnail)
             {
                 if(self.backThumbnail.size.height > self.backThumbnail.size.width)
                     self.backThumbnail = [AppUtilities rotateImageLandscape:self.backThumbnail];
                 [licenseBack setImage:[AppUtilities imageWithImage:self.backThumbnail scaledToSize:CGSizeMake(96, 60)] forState:UIControlStateNormal];
             }
             
             else
                 [licenseBack setImage:[UIImage imageNamed:@"dl_back.png"] forState:UIControlStateNormal];
             
             [licenseBack addTarget:self action:@selector(licenseBackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
             
             [licenseBack setExclusiveTouch:YES];
             licenseBack.frame = CGRectMake(2*gap+120, 30, 120, 120);
             
             UILabel *backLabel = [[UILabel alloc]initWithFrame:CGRectMake(2*gap+120, 160, 120, 21)];
             backLabel.textAlignment = NSTextAlignmentCenter;
             backLabel.text = Klm(@"Back Side");
             backLabel.font = [UIFont fontWithName:FONTNAME size:18];
             
             [cell.contentView addSubview:licenseBack];
             [cell.contentView addSubview:backLabel];
             [AppUtilities adjustFontSizeOfLabel:backLabel];
         
       //  }
        

         UILabel *line1 = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, [[UIScreen mainScreen]bounds].size.width-30, 1)];
         [line1 setBackgroundColor:[UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1.0f]];
         
         UILabel *line2 = [[UILabel alloc]initWithFrame:CGRectMake(15, 229, [[UIScreen mainScreen]bounds].size.width-30, 1)];
         [line2 setBackgroundColor:[UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1.0f]];
         
         [cell.contentView addSubview:line1];
         [cell.contentView addSubview:line2];
    }else if(self.componentObject.type == IDCARD && indexPath.row == 2){
        
        UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [submitBtn setTitle:Klm([self.componentObject.texts.summaryText valueForKey:SUBMITBUTTONTEXT]) forState:UIControlStateNormal];
        [submitBtn setExclusiveTouch:YES];
        [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        submitBtn.enabled = NO;
        [submitBtn setBackgroundImage:[AppUtilities getcustomButtonImage:[UIColor grayColor] withTheme:[[ProfileManager sharedInstance]getActiveProfile].theme] forState:UIControlStateNormal];
        submitBtn.titleLabel.font = [UIFont fontWithName:FONTNAME size:18];
        [submitBtn setFrame:CGRectMake(20, 40, [[UIScreen mainScreen]bounds].size.width-40, 40)];
        [cell.contentView addSubview:submitBtn];
    }
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

//TODO replace all numbers with either constants or values deduced

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.componentObject.type == IDCARD && indexPath.row==0)
    {
        return 180;
    }
    else if(self.componentObject.type == IDCARD && indexPath.row==1)
    {
        return 230;
    }else if(self.componentObject.type == IDCARD && indexPath.row == 2){
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

-(IBAction)cancelButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 This method is used to push to settings controller.
 */
-(IBAction)settingsButtonAction:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onSettingsClicked)])
        [self.delegate onSettingsClicked];
}


-(IBAction)licenseFrontButtonAction:(id)sender
{
    if(self.backThumbnail == nil) {
        
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(onDLFrontClicked)])
        [self.delegate onDLFrontClicked];

}

-(IBAction)licenseBackButtonAction:(id)sender
{
    BOOL isModlesAvailable = YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(checkForModels)])
     isModlesAvailable = [self.delegate checkForModels];
    if (isModlesAvailable) {
    if(self.backThumbnail == nil) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:Klm(@"Capture Image"), Klm(@"Capture Barcode"), Klm(@"Skip"), Klm(@"Cancel"), nil];
        
        [actionSheet showInView:self.view];
        [self.view bringSubviewToFront:actionSheet];
        
    }
    else {
       
        if(self.delegate && [self.delegate respondsToSelector:@selector(onDLBackClicked)])
            [self.delegate onDLBackClicked];
    }
    }
   
}

-(IBAction)backButtonAction:(id)sender{
    
    if(self.frontThumbnail || self.backThumbnail)
    {
        UIAlertView* cancelAlert = [[UIAlertView alloc] initWithTitle:Klm([self.componentObject.texts.summaryText valueForKey:SUBMITCANCELALERTTEXT]) message:nil delegate:self cancelButtonTitle:Klm(@"YES") otherButtonTitles:Klm(@"NO"), nil];
        [cancelAlert show];
    }
    else
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(backButtonClicked)])
            [self.delegate backButtonClicked];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(backButtonClicked)])
            [self.delegate backButtonClicked];
    }
        
}

#pragma mark - Action Sheet Delegate 

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
            switch (buttonIndex) {
                case 0:
                    if(self.delegate && [self.delegate respondsToSelector:@selector(assignCaptureSide:)])
                        [self.delegate assignCaptureSide:TWOSIDECAPTURE];
                    break;
                case 1:
                    if(self.delegate && [self.delegate respondsToSelector:@selector(assignCaptureSide:)])
                        [self.delegate assignCaptureSide:OTHERSIDEBARCODE];
                    break;
                case 2: {
                    
                    self.captureSide = ONESIDE;
                    [self.table reloadData];
                    
                    if(self.delegate && [self.delegate respondsToSelector:@selector(skipButtonClicked)])
                        [self.delegate skipButtonClicked];
                }
                    
                default:
                    break;
            }
    

}



@end
