//
//  ExhibitorViewController1.m
//  Kofax Mobile Demo
//
//  Created by kaushik on 30/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "ExhibitorViewController.h"
#import "AppStateMachine.h"
#import <kfxLibUIControls/kfxUIControls.h>

#define SCREEN_WIDTH        CGRectGetWidth([[UIScreen mainScreen] bounds])
#define SCREEN_HEIGHT       CGRectGetHeight([[UIScreen mainScreen] bounds])

@interface ExhibitorViewController() <UIScrollViewDelegate>
{
    
}
@property (nonatomic,strong) IBOutlet UIToolbar* bottomBar;
@property(nonatomic,strong)IBOutlet UIBarButtonItem* retakeButton;
@property(nonatomic,strong)IBOutlet UIBarButtonItem* useButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *flexibleSpace;

@property (strong, nonatomic) IBOutlet UIToolbar *topBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *albumButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *usePhotoButton;
@property (strong, nonatomic) UIBarButtonItem * leftBtn;




@property(nonatomic,strong)kfxKUIImageReviewAndEdit *imageReviewAndEdit;

@property(nonatomic,strong)UIImageView *imageView;

@end

@implementation ExhibitorViewController
@synthesize showTopBar;


-(void)dealloc{
    
    self.bottomBar = nil;
    self.retakeButton = nil;
    self.useButton = nil;
    self.flexibleSpace = nil;
    self.imageView = nil;
    [self.imageReviewAndEdit removeFromSuperview];
    self.imageReviewAndEdit = nil;
    self.leftButtonTitle = nil;
    self.rightButtonTitle = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.retakeButton setTitle:Klm(self.retakeButton.title)];
    [self.useButton setTitle:Klm(self.useButton.title)];

    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //blur the view when app goes into background
    [self createViewBlurInBackground];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self addCancelBarItem];
    self.navigationItem.title = Klm(@"Preview");
    if(showTopBar){
        
    _leftBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"albums.png"] style:UIBarButtonItemStylePlain target:self action:@selector(reselectImage:)];
    _leftBtn.imageInsets = UIEdgeInsetsMake(0, -10, 0, 0);

    _leftBtn.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = _leftBtn;
        
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],
                                    NSForegroundColorAttributeName,
                                    nil];
        
        
        UIBarButtonItem *btnUse = [[UIBarButtonItem alloc]
                                   initWithTitle:Klm(@"Use")
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(useSelectedPhoto:)];
        [btnUse setTitleTextAttributes:attributes forState:UIControlStateNormal];
        
        
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

        self.bottomBar.items = [NSArray arrayWithObjects:flexibleItem,btnUse,flexibleItem,nil];
        
        
    }
    else{
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        self.topBar.items = [NSArray array];
       
        self.retakeButton.enabled = YES;
        self.useButton.enabled = YES;
        self.bottomBar.items = [NSArray arrayWithObjects:self.retakeButton,self.flexibleSpace,self.useButton,nil];
        
    }
    
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
    
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0) {
        self.bottomBar.barTintColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
    }else{
        self.bottomBar.tintColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
    }
    
    if(![AppUtilities isLowerEndDevice]){
        if (self.imageReviewAndEdit) {
            [self.imageReviewAndEdit removeFromSuperview];
        }
    }
    else{
        if(self.imageView){
            [self.imageView removeFromSuperview];
        }
    }
    
    //self.bottomBar.backgroundColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor];
    self.retakeButton.tintColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.titleColor];
    self.useButton.tintColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.titleColor];
    [self.retakeButton setTitle:self.leftButtonTitle];
    [self.useButton setTitle:self.rightButtonTitle];
    
    if(![AppUtilities isLowerEndDevice]){
        
        
        self.imageReviewAndEdit = [[kfxKUIImageReviewAndEdit alloc] initWithFrame:CGRectMake(0, ([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0?64:0), SCREEN_WIDTH, SCREEN_HEIGHT-([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0?108:44))];    //self.view.frame is giving "xib" frame not device frame, so changed to device frame
        //Disable the zooming feature
        self.imageReviewAndEdit.userInteractionEnabled = YES;
        [self.imageReviewAndEdit setImage:self.inputImage];
        
        if(self.coloredAreas && [self.coloredAreas count] > 0){
            [self.imageReviewAndEdit showHighlights:self.coloredAreas];
            [self.imageReviewAndEdit setHighlightColor:[UIColor yellowColor]];
        }
        [self.view addSubview:self.imageReviewAndEdit];
    }
    else{
        
        UIScrollView *previewScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, ([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0?64:0), SCREEN_WIDTH, SCREEN_HEIGHT-([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0?108:44))]; //self.view.frame is giving "xib" frame not device frame, so changed to device frame

        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, ([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0?64:0), SCREEN_WIDTH, SCREEN_HEIGHT-([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0?108:44))];
        
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.imageView setBackgroundColor:[UIColor blackColor]];
        
        [self.imageView setImage:[self.inputImage getImageBitmap]];
        
        [previewScrollView addSubview:self.imageView];
        self.imageView.frame = previewScrollView.bounds;
        
        previewScrollView.contentSize = CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height);
        previewScrollView.maximumZoomScale = 4.0;
        previewScrollView.minimumZoomScale = 1.0;
        previewScrollView.delegate = self;
        previewScrollView.bouncesZoom = NO;
        previewScrollView.bounces = NO;
        
        [self.view addSubview:previewScrollView];
    }
}

/*
-(void) hideRegularToolBar
{
    self.bottomBar.hidden = YES;
    self.topBar.hidden = NO;
}

-(void) showRegularToolBar
{
    self.bottomBar.hidden = NO;
    self.topBar.hidden = YES;
    
}
 */


-(void) removeNavigationBarItems
{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.bottomBar.hidden = NO;
    self.useButton.enabled = YES;
    self.retakeButton.enabled = YES;
    self.showTopBar = NO;
    
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return self.imageView;
}

-(void)viewWillDisappear:(BOOL)animated
{
    //clear image review and edit
    [super viewWillDisappear:animated];
    

    if(![AppUtilities isLowerEndDevice]){
        
        UIImage *tempimg = [[UIImage alloc]init];
        [tempimg drawInRect:CGRectMake(0, 0, 1.0, 1.0)];
        kfxKEDImage *cleanUpImg = [[kfxKEDImage alloc]initWithImage:tempimg];
        [self.imageReviewAndEdit setImage:cleanUpImg];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)reselectImage:(id)sender {
    
    [self.delegate albumButtonClicked];
    
}
- (IBAction)useSelectedPhoto:(id)sender {
    [self.delegate useSelectedPhotoButtonClicked];
}

- (IBAction)discardImageCaptured {
    
    [self.delegate retakeButtonClicked];
}

- (IBAction)useImageCaptured:(UIButton*)sender {
    
    
    if (!self.isCancelButtonShow) {
       [self.delegate useButtonClicked];
    }
    else{
        [self.delegate cancelButtonClicked];
    }
}

#pragma mark Local Methods
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
