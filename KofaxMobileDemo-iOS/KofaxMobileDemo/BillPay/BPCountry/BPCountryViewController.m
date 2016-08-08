//
//  DLRegionViewController.m
//  KofaxMobileDemo
//
//  Created by Mahendra on 24/11/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "BPCountryViewController.h"


@interface BPCountryViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    
}

@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint,*backgroundTopConstraint;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic,strong)    NSMutableArray* countriesList;
@property (nonatomic,strong)    NSMutableArray* countryCodesList;
@end


@implementation BPCountryViewController



-(void)dealloc{
    self.countriesList = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.countriesList = [[NSMutableArray alloc] initWithObjects:@"United States",@"Canada", nil];
    self.countryCodesList = [[NSMutableArray alloc] initWithObjects:@"US",@"CA", nil];
   
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableTopConstraint.constant += 20;
        //self.backgroundTopConstraint.constant +=20;
    }else{
        self.tableTopConstraint.constant -=42;
        //self.backgroundTopConstraint.constant -= 42;
    }
    
    self.navigationItem.title = Klm(@"Select Country");
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self addCancelBarItem];
     self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
     self.navigationItem.rightBarButtonItem = [AppUtilities getSettingsButtonItemWithTarget:self andAction:@selector(settingsButtonAction:)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backButtonAction:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(countrySelectionCancelled)])
        [self.delegate countrySelectionCancelled];
}

-(IBAction)settingsButtonAction:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(countrySettingsClicked)])
        [self.delegate countrySettingsClicked];
}

#pragma mark UITableViewDataSource and UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.countriesList count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cellIdentifier" ;
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(15, 9, 40, 40)];
        imageView1.image = [UIImage imageNamed:[[[self.countriesList objectAtIndex:indexPath.row] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""]];
        imageView1.layer.cornerRadius = 20;
        imageView1.backgroundColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance] getActiveProfile].theme.themeColor];
        UILabel *textLabel = [AppUtilities createLabelWithTag:0 frame:CGRectMake(62, 0, 230, 60) andText:[self.countriesList objectAtIndex:indexPath.row]];
        
        [cell.contentView addSubview:imageView1];
        [cell.contentView addSubview:textLabel];
        
        imageView1 = nil;
        textLabel = nil;

    }
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return Klm(@"Select the country of your BILL");
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(countryForBPSelected:)]){
        [self.delegate countryForBPSelected:[self.countryCodesList objectAtIndex:indexPath.row]];
    }
    
        
}


@end
