//
//  SelectDestinationViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/16/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "SelectDestinationViewController.h"
#import "ProfileManager.h"
@interface SelectDestinationViewController ()
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation SelectDestinationViewController
@synthesize tableTopConstraint;
@synthesize dataArray;
#pragma mark ViewLifeCycle Methods

-(void)dealloc{
    self.dataArray = nil;
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
    self.navigationItem.title = Klm(@"Submit To");
    self.dataArray = [[NSMutableArray alloc]initWithObjects:Klm(@"Kofax Front Office Server"), Klm(@"Kofax TotalAgility"), Klm(@"Email Message"), Klm(@"None"), nil];
    
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

#pragma mark UITableViewDataSource and UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [self.dataArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier" ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    cell.textLabel.font = [UIFont fontWithName:FONTNAME size:15];
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return Klm(@"Select Destination");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Local Methods
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)backButtonAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
