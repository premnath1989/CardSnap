//
//  SelectColorViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/16/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "SelectColorViewController.h"
#import "CustomColorViewController.h"
#import "ProfileManager.h"
@interface SelectColorViewController ()
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, strong) NSMutableArray *colorsArray;
@property (nonatomic, assign) Profile *profileObject;
@property (nonatomic, assign) colorType colorType;
@property (nonatomic, assign) IBOutlet UITableView *table;
@end

@implementation SelectColorViewController
@synthesize tableTopConstraint;
@synthesize colorsArray;

#pragma mark Constructor Methods
-(id)initWithProfile:(Profile*)profile withType:(colorType)colorType{
    self = [super init];
    if (self) {
        self.colorType = colorType;
        self.profileObject = profile;
    }
    return self;
}

#pragma mark ViewLifeCycle Methods

-(void)dealloc{
    self.colorsArray = nil;
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
   // self.colorsArray = [[NSMutableArray alloc]initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Custom Color",@"name",[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f],@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Blue",@"name",[UIColor colorWithRed:83.0/255.0f green:147.0f/255.0f blue:214.0f/255.0f alpha:1.0f],@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Dark Blue",@"name",[UIColor colorWithRed:34.0/255.0f green:71.0f/255.0f blue:110.0f/255.0f alpha:1.0f],@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Dark Green",@"name",[UIColor colorWithRed:53.0/255.0f green:91.0f/255.0f blue:94.0f/255.0f alpha:1.0f],@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Orange",@"name",[UIColor colorWithRed:234.0/255.0f green:139.0f/255.0f blue:55.0f/255.0f alpha:1.0f],@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Red",@"name",[UIColor colorWithRed:206.0/255.0f green:89.0f/255.0f blue:89.0f/255.0f alpha:1.0f],@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Light Gray",@"name",[UIColor colorWithRed:143.0/255.0f green:142.0f/255.0f blue:146.0f/255.0f alpha:1.0f],@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Dark Gray",@"name",[UIColor colorWithRed:74.0/255.0f green:74.0f/255.0f blue:74.0f/255.0f alpha:1.0f],@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Black",@"name",[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f],@"color", nil], nil];
    
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    
    if (self.colorType == HEADER_COLOR) {
        self.navigationItem.title = Klm(@"Select Header Color");
    }else if(self.colorType == BUTTON_COLOR){
        self.navigationItem.title = Klm(@"Select Button Color");
    }else if(self.colorType == TITLE_COLOR){
        self.navigationItem.title = Klm(@"Select Header Text Color");
    }else if(self.colorType == TEXT_COLOR){
        self.navigationItem.title = Klm(@"Select Button Text Color");
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.colorsArray = [[NSMutableArray alloc]initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Custom Color",@"name",@"#0079C2",@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Blue",@"name",@"#5393D6",@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Dark Blue",@"name",@"#22476E",@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Dark Green",@"name",@"#355B5E",@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Orange",@"name",@"#EA8B37",@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Red",@"name",@"#CE5959",@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Light Gray",@"name",@"#8F8E92",@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Dark Gray",@"name",@"#4A4A4A",@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Black",@"name",@"#000000",@"color", nil], nil];
    if (![self isNotCustomColor]) {
        self.colorsArray = [[NSMutableArray alloc]initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Custom Color",@"name",self.profileObject.theme.themeColor,@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Blue",@"name",@"#5393D6",@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Dark Blue",@"name",@"#22476E",@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Dark Green",@"name",@"#355B5E",@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Orange",@"name",@"#EA8B37",@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Red",@"name",@"#CE5959",@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Light Gray",@"name",@"#8F8E92",@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Dark Gray",@"name",@"#4A4A4A",@"color", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Black",@"name",@"#000000",@"color", nil], nil];
    }
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
    return  [self.colorsArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier" ;
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if (indexPath.row==0) {
            UIButton *editColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
            editColorButton.frame = CGRectMake([[UIScreen mainScreen]bounds].size.width-100, 6,70 , 30);
            [editColorButton setTitleColor:[UIColor colorWithRed:83.0/255.0f green:147.0f/255.0f blue:214.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [editColorButton setTitle:Klm(@"Edit Color") forState:UIControlStateNormal];
            [editColorButton.titleLabel setFont:[UIFont fontWithName:FONTNAME size:15]];
            [AppUtilities adjustFontSizeOfLabel:editColorButton.titleLabel];
            [editColorButton addTarget:self action:@selector(editColorButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:editColorButton];
        }
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 4, 36, 36)];
        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        imageView.backgroundColor = [utilitiesObject colorWithHexString:[[self.colorsArray objectAtIndex:indexPath.row]valueForKey:@"color"]];
        utilitiesObject = nil;
        if (([self.profileObject.theme.buttonColor isEqualToString:[[self.colorsArray objectAtIndex:indexPath.row]valueForKey:@"color"]] && self.colorType == BUTTON_COLOR)||([self.profileObject.theme.themeColor isEqualToString:[[self.colorsArray objectAtIndex:indexPath.row]valueForKey:@"color"]] && self.colorType == HEADER_COLOR)||([self.profileObject.theme.titleColor isEqualToString:[[self.colorsArray objectAtIndex:indexPath.row]valueForKey:@"color"]] && self.colorType == TITLE_COLOR)||([self.profileObject.theme.buttonTextColor isEqualToString:[[self.colorsArray objectAtIndex:indexPath.row]valueForKey:@"color"]] && self.colorType == TEXT_COLOR)) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(64, 10, 150, 21)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.text = Klm([[self.colorsArray objectAtIndex:indexPath.row]valueForKey:@"name"]);
        textLabel.font = [UIFont fontWithName:FONTNAME size:15];
        [AppUtilities adjustFontSizeOfLabel:textLabel];
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:textLabel];
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return Klm(@"Select the Color Scheme");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        if (self.colorType == BUTTON_COLOR) {
           self.profileObject.theme.buttonColor = [[self.colorsArray objectAtIndex:indexPath.row]valueForKey:@"color"];
        }else if(self.colorType == HEADER_COLOR){
            self.profileObject.theme.themeColor = [[self.colorsArray objectAtIndex:indexPath.row]valueForKey:@"color"];
            [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:self.profileObject.theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:self.profileObject.theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
        }else if (self.colorType == TITLE_COLOR) {
            self.profileObject.theme.titleColor = [[self.colorsArray objectAtIndex:indexPath.row]valueForKey:@"color"];
            [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:self.profileObject.theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:self.profileObject.theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
        }else if (self.colorType == TEXT_COLOR) {
            self.profileObject.theme.buttonTextColor = [[self.colorsArray objectAtIndex:indexPath.row]valueForKey:@"color"];
        }
    utilitiesObject = nil;
        [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Local Methods
/*
 This method is used for editting the custom color.
 */
-(IBAction)editColorButtonAction:(id)sender{
    CustomColorViewController *customColorController = [[CustomColorViewController alloc]initWithProfile:self.profileObject withType:self.colorType];
    [self.navigationController pushViewController:customColorController animated:YES];
}
/*
 This method is used to check the color is custom color or not.
 */
-(BOOL)isNotCustomColor{
    BOOL isCustomColor;
    for (int j=1; j<[self.colorsArray count]; j++) {
        if (([self.profileObject.theme.buttonColor isEqualToString:[[self.colorsArray objectAtIndex:j]valueForKey:@"color"]]&&self.colorType == BUTTON_COLOR)||([self.profileObject.theme.themeColor isEqualToString:[[self.colorsArray objectAtIndex:j]valueForKey:@"color"]]&& self.colorType == HEADER_COLOR)||([self.profileObject.theme.titleColor isEqualToString:[[self.colorsArray objectAtIndex:j]valueForKey:@"color"]]&& self.colorType == TITLE_COLOR)||([self.profileObject.theme.buttonTextColor isEqualToString:[[self.colorsArray objectAtIndex:j]valueForKey:@"color"]]&& self.colorType == TEXT_COLOR)) {
            isCustomColor = TRUE;
            break;
        }
    }
    return isCustomColor;
}
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)backButtonAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
