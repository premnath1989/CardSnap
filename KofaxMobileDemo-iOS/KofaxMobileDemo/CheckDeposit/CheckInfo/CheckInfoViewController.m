//
//  CheckInfoViewController.m
//  BankRight
//
//  Created by Rambabu N on 8/18/14.
//  Copyright (c) 2014 WIN Information Technology. All rights reserved.
//

#import "CheckInfoViewController.h"
#import "ChecksHistory.h"
#import "CheckHistoryManager.h"
#import "PersistenceManager.h"
#import "ExtractionFields.h"

#define INFO_NAME @"name"
#define INFO_VALUE @"value"


@interface CheckInfoViewController () <UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *checkArray,*iqaArray,*usabilityArray;
@property (nonatomic, strong) IBOutlet UISegmentedControl *checkInfoSegmentControl;
@property (nonatomic, strong) IBOutlet UITableView *checkInfoTableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *segmentTopConstraint;

@end

@implementation CheckInfoViewController

@synthesize checkArray,iqaArray,usabilityArray;
@synthesize checkInfoSegmentControl;
@synthesize checkInfoTableView;
@synthesize componentObject;

@synthesize checkResults = _checkResults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLayoutSubviews{
    [AppUtilities reduceFontSizeOfSegmentControl:self.checkInfoSegmentControl];
}


-(void)dealloc{
    
    self.checkArray = nil;
    self.iqaArray = nil;
    self.usabilityArray = nil;
    self.checkInfoSegmentControl = nil;
    self.checkInfoTableView.delegate = nil;
    self.checkInfoTableView.dataSource = nil;
    self.checkInfoTableView = nil;
    self.checkResults = nil;
    self.componentObject = nil;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
}

-(void)viewWilldDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.checkInfoSegmentControl setTitle:Klm([self.checkInfoSegmentControl titleForSegmentAtIndex:0]) forSegmentAtIndex:0];
    [self.checkInfoSegmentControl setTitle:Klm([self.checkInfoSegmentControl titleForSegmentAtIndex:1]) forSegmentAtIndex:1];
    [self.checkInfoSegmentControl setTitle:Klm([self.checkInfoSegmentControl titleForSegmentAtIndex:2]) forSegmentAtIndex:2];
    
    // Do any additional setup after loading the view from its nib.
    [checkInfoSegmentControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [UIFont fontWithName:@"HelveticaNeue" size:14.0], NSFontAttributeName,
                                                     nil]  forState:UIControlStateNormal];
    [AppUtilities reduceFontSizeOfSegmentControl:self.checkInfoSegmentControl];
    
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.segmentTopConstraint.constant = self.segmentTopConstraint.constant+=20;
    }
    
    self.navigationItem.title = Klm(@"Check Information");
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];

    self.componentObject.extractionFields = [[ExtractionFields alloc] initWithSettings:self.componentObject.settings.settingsDictionary componentType:self.componentObject.type withExtractionResult:_checkResults];
    iqaArray = self.componentObject.extractionFields.extractionFields[@"iqaArray"];
    checkArray = self.componentObject.extractionFields.extractionFields[@"checkArray"];
    usabilityArray = self.componentObject.extractionFields.extractionFields[@"usabilityArray"];
    // APP stats for field changes in Check Info
    [self removeEditableFields];
}

-(void)removeEditableFields{
    for (int index = (int)([checkArray count]-1); index>=0; index--) {
        ExtractInfo *info = [checkArray objectAtIndex:index];
        if([info.name isEqualToString:@"Amount"] ||
           [info.name isEqualToString:@"Routing No."] ||
           [info.name isEqualToString:@"Account No."] ||
           [info.name isEqualToString:@"Date"] ||
           [info.name isEqualToString:@"Check Number"] ||
           [info.name isEqualToString:@"Payee name"]
           ){
            [checkArray removeObjectAtIndex:index];
        }
    }
}


#pragma mark UITextFieldDelegate Methods End

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (checkInfoSegmentControl.selectedSegmentIndex==0) {
        return [checkArray count];
    }else if(checkInfoSegmentControl.selectedSegmentIndex==1){
        return [iqaArray count];
    }else{
        return [usabilityArray count];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"ChartListCell";
    
    CheckInfoCustomCell *cell = (CheckInfoCustomCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CheckInfoCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    ExtractInfo *info;
    if (checkInfoSegmentControl.selectedSegmentIndex==0) {
        info = [checkArray objectAtIndex:indexPath.row];
    }else if(checkInfoSegmentControl.selectedSegmentIndex==1){
        info = [iqaArray objectAtIndex:indexPath.row];
    }else{
        info = [usabilityArray objectAtIndex:indexPath.row];
    }
    
    cell.localization = self.componentObject.texts;
    cell.extractInfo = info;
    [cell setttingupUIForSelectedSegment:checkInfoSegmentControl.selectedSegmentIndex withIndexPath:indexPath];

    if (checkInfoSegmentControl.selectedSegmentIndex==0) {
        if ([info.name isEqualToString:@"MICR"]) {
            cell.leftLabel.text = Klm(self.componentObject.texts.summaryText[MICR]);
        }else{
            cell.leftLabel.text = Klm(info.name);
        }
        cell.valueLabel.text = [info.value capitalizedString];
        
    }else{
        cell.leftLabelWithoutCircle.text = Klm(info.name);
        cell.valueLabelWithoutCircle.text = [info.value capitalizedString];
        
        if ([cell.valueLabelWithoutCircle.text isEqualToString:Klm(@"True")]) {
            cell.valueLabelWithoutCircle.textColor = [UIColor redColor];
            cell.valueLabelWithoutCircle.text = Klm(@"Failed");
        }else{
            cell.valueLabelWithoutCircle.text = Klm(@"Succeeded");
            
            if(checkInfoSegmentControl.selectedSegmentIndex == 1 || checkInfoSegmentControl.selectedSegmentIndex == 2){
                if(indexPath.row == 12 || indexPath.row == 13 || indexPath.row == 15 || (checkInfoSegmentControl.selectedSegmentIndex == 2 && indexPath.row == 6)){
                    
                    NSDictionary *advancedSettings = [componentObject.settings.settingsDictionary valueForKey:ADVANCEDSETTINGS];
                    
                    if([[advancedSettings valueForKey:CHECKEXTRACTION] intValue] == 1){
                        cell.valueLabelWithoutCircle.text = Klm(@"Not Tested");
                    }
                }
            }
        }
        if([cell.leftLabelWithoutCircle.text isEqualToString:@"ReasonForRejection"]) {
            
            cell.valueLabelWithoutCircle.text = info.value;
            cell.valueLabelWithoutCircle.textColor = [UIColor redColor];
            cell.valueLabelWithoutCircle.textAlignment = NSTextAlignmentLeft;
            cell.leftLabelWithoutCircle.text = Klm(@"Reason For Rejection");
            
            CGSize size;
            CGSize constrainedSize = CGSizeMake([[UIScreen mainScreen]bounds].size.width-20, 10000);
            
                size = [cell.valueLabelWithoutCircle.text boundingRectWithSize:constrainedSize options: NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes: @{ NSFontAttributeName: cell.valueLabelWithoutCircle.font } context: nil].size;
            cell.valueLabelWithoutCircle.frame = CGRectMake(7, cell.leftLabelWithoutCircle.frame.origin.y + cell.leftLabelWithoutCircle.frame.size.height + 5, [[UIScreen mainScreen]bounds].size.width-20, size.height);
            
        }
        else {
            
            cell.valueLabelWithoutCircle.frame = CGRectMake(233, 11, 77, 30);
            cell.valueLabelWithoutCircle.textAlignment = NSTextAlignmentRight;
        }
    }
    [AppUtilities reduceFontOfTextField:cell.valueTextField];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (checkInfoSegmentControl.selectedSegmentIndex==2){
        
        CGSize size;
        CGSize constrainedSize = CGSizeMake([[UIScreen mainScreen]bounds].size.width-20, 10000);
        
        NSDictionary *dict = [usabilityArray objectAtIndex:indexPath.row];
        NSString *strKey = [dict valueForKey:INFO_NAME];
        NSString *strValue = [dict valueForKey:INFO_VALUE];
        if([strKey isEqualToString:@"ReasonForRejection"]) {
            
            size = [strValue boundingRectWithSize:constrainedSize options: NSStringDrawingUsesLineFragmentOrigin
                                       attributes: @{ NSFontAttributeName: HelveticaBold(18) } context: nil].size;
            
            size.height += 50;
            return size.height;
            
        }
        else {
            
            return 44;
        }
    }
    return 50;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(IBAction)backButtonAction:(id)sender{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)segmentedControlAction:(id)sender{
    [checkInfoTableView reloadData];
}

@end
