//
//  BackgroundGraphicsViewController.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/24/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "BackgroundGraphicsViewController.h"
@interface BackgroundGraphicsViewController ()
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, assign)Profile *profileObject;
@property (nonatomic, assign) NSInteger selectedTag;

@property (nonatomic, strong) UISwitch *showInstructionSwitch;

@property (nonatomic, assign) Component *componentObject;
@end

@implementation BackgroundGraphicsViewController
@synthesize selectedTag;
@synthesize table;
@synthesize profileObject;
#pragma mark Constructor Methods
-(id)initWithProfile:(Profile*)profile{
    self = [super init];
    if (self) {
        self.profileObject = profile;
    }
    return self;
}
-(id)initWithComponent:(Component*)component{
    self = [super init];
    if (self) {
        self.componentObject = component;
    }
    return self;
}

#pragma mark ViewLifeCycle Methods

-(void)dealloc{
    self.table.delegate = nil;
    self.table.dataSource = nil;
    self.table = nil;
    self.showInstructionSwitch = nil;
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
    if (self.componentObject) {
        self.navigationItem.title = Klm(@"Component Graphics");
    }else{
        self.navigationItem.title = Klm(@"Application Graphics");
    }
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
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
    return  3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier" ;
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row==2 && self.componentObject) {
        cell.textLabel.text = Klm(@"Show Instruction Screen");
        self.showInstructionSwitch = [AppUtilities createSwitchWithTag:(int)indexPath.row andValue:[self.componentObject.componentGraphics.graphicsDictionary valueForKey:SHOWINSTRUCTIONSCREEN]];
        [self.showInstructionSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = self.showInstructionSwitch;
    }else{
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 70, 120)];
        imageView.tag = indexPath.row+1;
        imageView.backgroundColor = [UIColor lightGrayColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(108, 20, [[UIScreen mainScreen]bounds].size.width-123, 21)];
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        clearButton.frame = CGRectMake(108, 80, 100, 30);
        [clearButton setTitleColor:[UIColor colorWithRed:25.0f/255.0f green:148.0f/255.0f blue:251.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        clearButton.tag = indexPath.row+10;
        [clearButton addTarget:self action:@selector(clearButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [clearButton setTitle:Klm(@"Clear") forState:UIControlStateNormal];
        UIButton *importButton = [UIButton buttonWithType:UIButtonTypeCustom];
        importButton.frame = CGRectMake([[UIScreen mainScreen]bounds].size.width-115, 80, 100, 30);
        importButton.tag = indexPath.row+10;
        [importButton setTitleColor:[UIColor colorWithRed:25.0f/255.0f green:148.0f/255.0f blue:251.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [importButton addTarget:self action:@selector(importButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [importButton setTitle:Klm(@"Import") forState:UIControlStateNormal];
        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        if (indexPath.row==0) {
            if (self.componentObject) {
                label.text = Klm(@"Instruction Screen Icon");
                if ([[self.componentObject.componentGraphics.graphicsDictionary valueForKey:INSTRUCTIONIMAGELOGO]length]!=0) {
                    clearButton.enabled = YES;
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                    dispatch_async(queue, ^{
                        UIImage *homeImage = [utilitiesObject getImageFromBase64String:[self.componentObject.componentGraphics.graphicsDictionary valueForKey:INSTRUCTIONIMAGELOGO]];
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            imageView.image = [AppUtilities imageWithImage:homeImage scaledToSize:CGSizeMake(300, 200)];
                        });
                    });
                }else{
                    imageView.image = [UIImage imageNamed:@"placeholderinstuction_ios.png"];
                    clearButton.enabled = NO;
                    [clearButton setTitleColor:[UIColor colorWithRed:173.0f/255.0f green:173.0f/255.0f blue:173.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
                }
            }else{
                label.text = Klm(@"Main Screen");
                if (self.profileObject.graphics.homeScreenBackgroundImage.length!=0) {
                    clearButton.enabled = YES;
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                    dispatch_async(queue, ^{
                        UIImage *homeImage = [utilitiesObject getImageFromBase64String:self.profileObject.graphics.homeScreenBackgroundImage];
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            imageView.image = [AppUtilities imageWithImage:homeImage scaledToSize:CGSizeMake(70, 120)];
                        });
                    });
                }else{
                    imageView.image = [UIImage imageNamed:@"custom login screen.png"];
                    clearButton.enabled = NO;
                    [clearButton setTitleColor:[UIColor colorWithRed:173.0f/255.0f green:173.0f/255.0f blue:173.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
                }
            }
        }else if(indexPath.row==1){
            if (self.componentObject.type) {
                label.text = Klm(@"Home Screen Icon");
                if ([[self.componentObject.componentGraphics.graphicsDictionary valueForKey:HOMEIMAGELOGO]length]!=0) {
                    clearButton.enabled = YES;
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                    dispatch_async(queue, ^{
                        UIImage *loginImage = [utilitiesObject getImageFromBase64String:[self.componentObject.componentGraphics.graphicsDictionary valueForKey:HOMEIMAGELOGO]];
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            imageView.image = [AppUtilities imageWithImage:loginImage scaledToSize:CGSizeMake(78, 84)];;
                        });
                    });
                }else{
                    imageView.image = [UIImage imageNamed:@"Custom Component Icon.png"];
                    clearButton.enabled = NO;
                    [clearButton setTitleColor:[UIColor colorWithRed:173.0f/255.0f green:173.0f/255.0f blue:173.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
                }
            }else{
                label.text = Klm(@"Login Screen");
                if (self.profileObject.graphics.loginScreenBackgroundImage.length!=0) {
                    clearButton.enabled = YES;
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                    dispatch_async(queue, ^{
                        UIImage *loginImage = [utilitiesObject getImageFromBase64String:self.profileObject.graphics.loginScreenBackgroundImage];
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            imageView.image = [AppUtilities imageWithImage:loginImage scaledToSize:CGSizeMake(70, 120)];;
                        });
                    });
                }else{
                    imageView.image = [UIImage imageNamed:@"login screen_bg.png"];
                    clearButton.enabled = NO;
                    [clearButton setTitleColor:[UIColor colorWithRed:173.0f/255.0f green:173.0f/255.0f blue:173.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
                }
            }
        }else if(indexPath.row==2){
            label.text = Klm(@"Logo");
            if (self.profileObject.graphics.logoImage.length!=0) {
                clearButton.enabled = YES;
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(queue, ^{
                    UIImage *logoImage = [utilitiesObject getImageFromBase64String:self.profileObject.graphics.logoImage];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        imageView.image = [AppUtilities imageWithImage:logoImage scaledToSize:CGSizeMake(70, 120)];;
                    });
                });
            }else{
                imageView.image = [UIImage imageNamed:@"kofax_logo.png"];
                clearButton.enabled = NO;
                [clearButton setTitleColor:[UIColor colorWithRed:173.0f/255.0f green:173.0f/255.0f blue:173.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            }
        }
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:clearButton];
        [cell.contentView addSubview:importButton];
    }
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.componentObject && indexPath.row == 2) {
        return 44;
    }
    return 140;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark UIImagePickerControllerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    float width = image.size.width;
    float height = image.size.height;
    
    BOOL sizeError = FALSE;
    NSString *sizeErrorString;
    
    CGFloat desiredHeight;
    CGFloat desiredWidth;
    
    
    if([[AppUtilities platformString] isEqualToString:@"iPhone 6 Plus"] && [[UIScreen mainScreen]bounds].size.height == 736){
        
        // Here the image selected should be of @3x pixels
        desiredHeight = [[UIScreen mainScreen]bounds].size.height *3;
        desiredWidth = [[UIScreen mainScreen]bounds].size.width *3;
        
    }
    else {
        
        // Here the image selected should be of @2x pixels
        desiredHeight = [[UIScreen mainScreen]bounds].size.height *2;
        desiredWidth = [[UIScreen mainScreen]bounds].size.width *2;
        
    }
    
    if (self.componentObject) { // For componenet , just leave it since irresceptive of screen size we need fixed images for it.
        
        if (width == 180 && height==180) {
            sizeError = TRUE;
        }
        image=[self imageWithImage:image];
    }else{
        
        // Check for Image Sizes rather than component object
        
        // First we check if it is logo
        
        if ( selectedTag == 12){
            
            if (height == 134 && (width == (desiredWidth - (120 * 2)))) // 60 refres to the left side space padding
            {
                sizeError = TRUE;
            }
        }
        else if ( selectedTag == 11 || selectedTag == 10){  // For the 2 Main Screens a Full Image is allowed
            
            if(width == desiredWidth &&  ( height == desiredHeight || height == (desiredHeight - ((44+20)*2)))){ //
                
                sizeError = TRUE;
            }
        }
        
    }
    
    if (!sizeError)
    {
        if (self.componentObject && ( selectedTag == 10 || selectedTag == 11 )) {
            sizeErrorString = Klm(@"Supported image size for this screen:\n\n180 x 180");
        }else if ((selectedTag == 10) || (selectedTag == 11)) { // Fot the 2 Main Screens a Full Image is allowed
            sizeErrorString = Klm(@"Supported images sizes for this screen:\n\niPhone 6plus standard: 1242 x 2080||2208\niPhone 6 standard || 6plus zoomed: 750 x 1206||1334\niPhone 5+ || 6 zoomed: 640 x 1008 || 1136\niPhone 4s: 640 x 832 || 960");
        } else {
            sizeErrorString = Klm(@"Supported images sizes for this screen:\n\niPhone 6 standard|| 6plus zoomed: 510 x 134\niPhone 6plus standard: 1002 x 134\niPhone 5+ || 6 zoomed: 400 x 134\niPhone 4s: 400 x 134");
        }
        
        
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:Klm(@"Invalid Image Size") message:sizeErrorString delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil, nil];
        [av show];
        image = nil;
        
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        AppUtilities *utilitiesObject = [[AppUtilities alloc]init];
        UITableViewCell *cell = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedTag-10 inSection:0]];
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:selectedTag-9];
        UIButton *clearButton = (UIButton*)[cell viewWithTag:selectedTag];
        clearButton.enabled = YES;
        [clearButton setTitleColor:[UIColor colorWithRed:25.0f/255.0f green:148.0f/255.0f blue:251.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        if (selectedTag==10) {
            UIImage *img;
            if (self.componentObject) {
                img = [AppUtilities imageWithImage:image scaledToSize:CGSizeMake(300, 200)];
                imgView.image = img;
                [self.componentObject.componentGraphics.graphicsDictionary setValue:[utilitiesObject getBase64StringOfImage:img] forKey:INSTRUCTIONIMAGELOGO];
            }else{
                img = [AppUtilities imageWithImage:image scaledToSize:CGSizeMake(image.size.width, image.size.height)];
                imgView.image = img;
                profileObject.graphics.homeScreenBackgroundImage = [utilitiesObject getBase64StringOfImage:img];
            }
        }else if(selectedTag==11){
            UIImage *img;
            if (self.componentObject) {
                img = [AppUtilities imageWithImage:image scaledToSize:CGSizeMake(78, 84)];
                imgView.image = img;
                [self.componentObject.componentGraphics.graphicsDictionary setValue:[utilitiesObject getBase64StringOfImage:img] forKey:HOMEIMAGELOGO];
            }else{
                img = [AppUtilities imageWithImage:image scaledToSize:CGSizeMake(image.size.width, image.size.height)];
                imgView.image = img;
                profileObject.graphics.loginScreenBackgroundImage = [utilitiesObject getBase64StringOfImage:img];
            }
            
        }else if(selectedTag==12){
            UIImage *img = [AppUtilities imageWithImage:image scaledToSize:CGSizeMake(image.size.width, 134)];
            imgView.image = img;
            profileObject.graphics.logoImage = [utilitiesObject getBase64StringOfImage:img];
        }
        // [self.table reloadData];
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark Local Methods
/*
 This method is used to go back to previous screen.
 */
-(IBAction)backButtonAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
/*
 This method is used to import the new image.
 */
-(IBAction)clearButtonAction:(UIButton*)sender{
    UITableViewCell *cell = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag-10 inSection:0]];
    UIImageView *imgView = (UIImageView*)[cell viewWithTag:sender.tag-9];
    sender.enabled = NO;
    [sender setTitleColor:[UIColor colorWithRed:173.0f/255.0f green:173.0f/255.0f blue:173.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    if (self.componentObject && sender.tag == 10) {
        [self.componentObject.componentGraphics.graphicsDictionary setValue:@"" forKey:INSTRUCTIONIMAGELOGO];
        imgView.image = [UIImage imageNamed:@"placeholderinstuction_ios.png"];
    }else if (self.componentObject && sender.tag == 11) {
        [self.componentObject.componentGraphics.graphicsDictionary setValue:@"" forKey:HOMEIMAGELOGO];
        imgView.image = [UIImage imageNamed:@"Custom Component Icon.png"];
    }else if (sender.tag==10 || sender.tag==11) {
        if (sender.tag==10) {
            self.profileObject.graphics.homeScreenBackgroundImage = @"";
            imgView.image = [UIImage imageNamed:@"custom login screen.png"];
        }else{
            self.profileObject.graphics.loginScreenBackgroundImage = @"";
            imgView.image = [UIImage imageNamed:@"login screen_bg.png"];
        }
    }else if(sender.tag==12){
        self.profileObject.graphics.logoImage = @"";
        imgView.image = [UIImage imageNamed:@"kofax_logo.png"];
    }
    //[self.table reloadData];
}

-(void)switchValueChanged:(UISwitch*)sender{
    [self.componentObject.componentGraphics.graphicsDictionary setValue:[NSNumber numberWithBool:sender.on] forKey:SHOWINSTRUCTIONSCREEN];
}
/*
 This method is used to clear the selected image.
 */
-(IBAction)importButtonAction:(UIButton*)sender{
    self.pickerController = [[UIImagePickerController alloc]init];
    self.pickerController.delegate = self;
    self.selectedTag = sender.tag;
    self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.pickerController animated:YES completion:^{
        
    }];
}
-(UIImage *)imageWithImage:(UIImage *)image {
    //UIGraphicsBeginImageContext(newSize);
    CGSize newSize=CGSizeMake(180,180);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, 180, 180)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
