//
//  CheckHistoryViewController.m
//  BankRight
//
//  Created by Rambabu N on 8/19/14.
//  Copyright (c) 2014 WIN Information Technology. All rights reserved.
//

#import "CheckHistoryViewController.h"
#import "CheckHistoryCustomCell.h"
#import "ChecksHistory.h"

#import "CheckHistoryManager.h"

#import "ImageDisplayViewController.h"


#define CHECK_NUMBER_KEY @"CheckNumber"
#define MICR_CODE_KEY @"MicrCode"
#define AMOUNT_KEY @"Amount"
#define DATE_KEY @"Date"
#define TIME_KEY @"Time"
#define FRONT_IMAGE_KEY @"FrontImage"
#define FRONT_THUMBNAIL_KEY @"FrontThumbnail"
#define BACK_IMAGE_KEY @"BackImage"
#define BACK_THUMBNAIL_KEY @"BackThumbnail"
#define DATE_FORMAT_STRING @"dd MMM YYYY"
#define TIME_FORMAT_STRING @"hh:mm a"

@interface CheckHistoryViewController ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic,assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@end

@implementation CheckHistoryViewController
@synthesize dataArray;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc{
    self.dataArray = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant += 20;
    }else{
        self.tableTopConstraint.constant -=42;
    }
    
    self.navigationItem.title = Klm(@"Check History");
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    
    dataArray = [[NSMutableArray alloc]init];
    
    // Do any additional setup after loading the view from its nib.
    [self getAndSetData];
}

-(void)getAndSetData{
    
    CheckHistoryManager *chMgr = [[CheckHistoryManager alloc] init];
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChecksHistory" inManagedObjectContext:chMgr.managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entity];
    
    NSArray *resultsArray = [chMgr.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    if ([resultsArray count] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Klm(@"No history found") delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil, nil];
        [alertView show];
        alertView = nil;
    }
    for (ChecksHistory *historyObject in [resultsArray reverseObjectEnumerator]) {
        
        NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc]init];
        [dataDictionary setValue:historyObject.checkNumber forKey:CHECK_NUMBER_KEY];
        [dataDictionary setValue:historyObject.micrCode forKey:MICR_CODE_KEY];
        [dataDictionary setValue:historyObject.amount forKey:AMOUNT_KEY];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateStyle:NSDateFormatterMediumStyle];
        [dateFormat setLocale:[NSLocale currentLocale]];
        [dataDictionary setValue:[dateFormat stringFromDate:historyObject.payDate] forKey:DATE_KEY];
        [dateFormat setTimeStyle:NSDateFormatterShortStyle];
        [dataDictionary setValue:[dateFormat stringFromDate:historyObject.payDate] forKey:TIME_KEY];
        dateFormat = nil;
        UIImage *frontImage = [UIImage imageWithData:historyObject.frontImageFilePath];
        [dataDictionary setValue:frontImage forKey:FRONT_IMAGE_KEY];
        //[dataDictionary setValue:[self createThumbnailFromImage:frontImage withSize:CGSizeMake(150, 70)] forKey:FRONT_THUMBNAIL_KEY];
        [dataDictionary setValue:frontImage forKey:FRONT_THUMBNAIL_KEY];
        frontImage = nil;
        UIImage *backImage = [UIImage imageWithData:historyObject.backImageFilePath];
        [dataDictionary setValue:backImage forKey:BACK_IMAGE_KEY];
       // [dataDictionary setValue:[self createThumbnailFromImage:backImage withSize:CGSizeMake(150, 70)] forKey:BACK_THUMBNAIL_KEY];
        [dataDictionary setValue:backImage forKey:BACK_THUMBNAIL_KEY];
        backImage = nil;
        [dataArray addObject:dataDictionary];
        dataDictionary = nil;
    }
    
}

-(UIImage*)createThumbnailFromImage:(UIImage*)originalImage withSize:(CGSize)destinationSize{
    UIGraphicsBeginImageContext(destinationSize);
    [originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [dataArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"CheckHistoryListCell";
    
    CheckHistoryCustomCell *cell = (CheckHistoryCustomCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CheckHistoryCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.frontImage.tag = indexPath.row;
        cell.backImage.tag = indexPath.row;
        UITapGestureRecognizer *frontTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(frontImageTapped:)];
        UITapGestureRecognizer *backTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backImageTapped:)];
        [cell.frontImage setUserInteractionEnabled:YES];
        [cell.backImage setUserInteractionEnabled:YES];
        [cell.frontImage addGestureRecognizer:frontTap];
        [cell.backImage addGestureRecognizer:backTap];
        frontTap = nil;
        backTap = nil;
    }
    NSDictionary *dict = [dataArray objectAtIndex:indexPath.row];
    cell.checkLabel.text = [dict objectForKey:CHECK_NUMBER_KEY];
    cell.amountLabel.text = [dict objectForKey:AMOUNT_KEY];
    cell.micrLabel.text = [self removeSpecialCharacters:[dict objectForKey:MICR_CODE_KEY]];
//    cell.dateLabel.text = [NSString stringWithFormat:@"%@ | %@", [[dict objectForKey:DATE_KEY] uppercaseString], [[dict objectForKey:TIME_KEY] uppercaseString]];
    cell.timeLabel.text = [[dict objectForKey:TIME_KEY] uppercaseString];
    cell.frontImage.image = [dict objectForKey:FRONT_THUMBNAIL_KEY];
    cell.backImage.image = [dict objectForKey:BACK_THUMBNAIL_KEY];
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 148.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark
#pragma mark Action Methods

-(NSString*)removeSpecialCharacters:(NSString*)check_MICR{
    
    
    check_MICR = [check_MICR stringByReplacingOccurrencesOfString:@"," withString:@" "];
    
    check_MICR = [check_MICR stringByReplacingOccurrencesOfString:@"." withString:@" "];
    
    return check_MICR;
}


-(IBAction)backButtonAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)frontImageTapped:(UITapGestureRecognizer*)gesture{
    UIView *view = gesture.view;
    ImageDisplayViewController *imageController = [[ImageDisplayViewController alloc]initWithImage:[[kfxKEDImage alloc]initWithImage:[[dataArray objectAtIndex:view.tag] objectForKey:FRONT_IMAGE_KEY]]];
    [self.navigationController pushViewController:imageController animated:YES];
    imageController = nil;
}
-(void)backImageTapped:(UITapGestureRecognizer*)gesture{
    UIView *view = gesture.view;
    ImageDisplayViewController *imageController = [[ImageDisplayViewController alloc]initWithImage:[[kfxKEDImage alloc]initWithImage:[[dataArray objectAtIndex:view.tag] objectForKey:BACK_IMAGE_KEY]]];
    [self.navigationController pushViewController:imageController animated:YES];
    imageController = nil;
}


#pragma mark
#pragma mark Alert view delegate method

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
 
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
