//
//  DLRegionViewController.m
//  KofaxMobileDemo
//
//  Created by Mahendra on 24/11/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "DLRegionViewController.h"
#import <kfxLibEngines/kfxEngines.h>
#import "KFXSegmentedControl.h"
#import "ProfileManager.h"


#define TagSection 3000
#define UnitedStates  @"United States"
#define Canada  @"Canada"
#define Germany @"Germany"


@interface DLRegionViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    
}

@property (nonatomic, assign) IBOutlet NSLayoutConstraint *tableTopConstraint,*labelTopConstraint;
@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic,strong)  NSMutableDictionary *dictRegions;
@property (nonatomic, assign) NSInteger intSelectedSection; // Stores the selected Section
@property (nonatomic, assign) NSInteger intSelectedSegmentForGermany; // Stores the ID for Germany
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property(nonatomic,assign) BOOL isODEActive;
@property(nonatomic,assign) BOOL isKofaxMobileIdActive;
@end


@implementation DLRegionViewController



-(void)dealloc{
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = Klm(@"Select Region");
    self.headerLabel.text = Klm(self.headerLabel.text);
    [AppUtilities adjustFontSizeOfLabel:self.headerLabel];
    
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self addCancelBarItem];
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    self.navigationItem.rightBarButtonItem = [AppUtilities getSettingsButtonItemWithTarget:self andAction:@selector(settingsButtonAction:)];
    [self updateODEMobileIdStatus];
    [self intializeTheRegionAndCountryList];
    self.intSelectedSection = -1;
    self.intSelectedSegmentForGermany = 1;
    [self.table reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backButtonAction:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(regionSelectionCancelled)])
        [self.delegate regionSelectionCancelled];
}

-(IBAction)settingsButtonAction:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(regionSettingsClicked)])
        [self.delegate regionSettingsClicked];
}

- (void)updateODEMobileIdStatus{
    self.isODEActive = NO;
    self.isKofaxMobileIdActive = NO;
    for (Component* componentObject in [[[ProfileManager sharedInstance] getActiveProfile] componentArray]) {
        if (componentObject.type == IDCARD && (self.selectedComponent == componentObject)) {
            if (((NSNumber*)[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:MOBILE_ID_TYPE]).boolValue) {
                self.isKofaxMobileIdActive = YES;
            }
            if (((NSNumber*)[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:SERVER_MODE]).integerValue == [NSNumber numberWithInt:2].integerValue) {
                self.isODEActive = YES;
            }
        }
    }
}

#pragma mark UITableViewDataSource and UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return [[self.dictRegions allKeys] count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isODEActive || self.isKofaxMobileIdActive) {
        return 0;
    }
    else{
        if(self.intSelectedSection == section){
            
            NSArray *arrRegion = [[self.dictRegions allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            NSString *strRegion = [arrRegion objectAtIndex:section];
            if([strRegion isEqualToString:UnitedStates] || [strRegion isEqualToString:Canada]){
                
                return 0;
            }
            else {
                
                NSArray *arrCountry = [self.dictRegions valueForKey:strRegion];
                return arrCountry.count;
            }
            
        }
        else {
            
            return 0;
        }
    }
    
    
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cellIdentifier" ;
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSArray *arrRegion = [[self.dictRegions allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *arrCountry = [self.dictRegions valueForKey:[arrRegion objectAtIndex:indexPath.section]];
    
    for (UIView *view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    DLRegionAttributes *objAttributes = [arrCountry objectAtIndex:indexPath.row];
    
    
    UILabel *textLabel = [AppUtilities createLabelWithTag:0 frame:CGRectMake(15, 0, 230, 40) andText:Klm(objAttributes.strDisplayRegion)]; //Changed the frame of label to fit in other languages too.
    if([textLabel.text isEqualToString:OTHERCOUNTRY]) {
        
        cell.backgroundColor = [UIColor colorWithRed:190/255.0 green:212.0/255.0 blue:226.0/255.0 alpha:1.0];
    }
    else {
        
        cell.backgroundColor = [UIColor colorWithRed:235/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
    }
    [cell.contentView addSubview:textLabel];
    [AppUtilities adjustFontSizeOfLabel:textLabel];
    
    textLabel = nil;
    
    UILabel *separator = [AppUtilities createLabelWithTag:0 frame:CGRectMake(0, 0, self.view.frame.size.width, 1) andText:nil];
    separator.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
    
    [cell.contentView addSubview:separator];
    
    separator = nil;
    
    if([Germany isEqualToString:objAttributes.strDisplayRegion]){
        
        //Used custom segment control to get the selected segment index when user tapped on already selected segment index.
        
        KFXSegmentedControl *segmentControl = [[KFXSegmentedControl alloc]initWithItems:@[Klm(@"Old-ID"), Klm(@"New-ID"), Klm(@"Driver License")]];
        [segmentControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIFont fontWithName:FONTNAME size:15.0], NSFontAttributeName,
                                                nil]  forState:UIControlStateNormal];
        segmentControl.selectedSegmentIndex = self.intSelectedSegmentForGermany;
        segmentControl.tag = 0;
        
        segmentControl.apportionsSegmentWidthsByContent = YES; // To adjust segment widths based on their content widths.
        segmentControl.tintColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance] getActiveProfile].theme.themeColor];
        [segmentControl addTarget:self action:@selector(germanIDTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [segmentControl addTarget:self action:@selector(germanIDTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];

        UIFont *font;
        
        segmentControl.frame = CGRectMake(105, 7, self.view.frame.size.width - 110, 30);  //Changed the frame of segment control to fit in other languages too.

        if([[AppUtilities platformString] isEqualToString:@"iPhone 6 Plus" ] || [[AppUtilities platformString] isEqualToString:@"iPhone 6"] ){
            font = [UIFont boldSystemFontOfSize:12.0f];
        }
        else {
            font = [UIFont boldSystemFontOfSize:9.0f];
        }
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                               forKey:NSFontAttributeName];
        [segmentControl setTitleTextAttributes:attributes
                                      forState:UIControlStateNormal];
        [cell.contentView addSubview:segmentControl];
        [AppUtilities reduceFontSizeOfSegmentControl:segmentControl];
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *viewFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    return viewFooter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 60;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NSArray *arrRegion = [[self.dictRegions allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    UIView *viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 60)];
    viewHeader.backgroundColor = [UIColor whiteColor];
    
    UIButton *btnSection = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSection.frame = CGRectMake(0, 0,  CGRectGetWidth(tableView.frame), 60);
    btnSection.tag = TagSection + section;
    btnSection.accessibilityLabel = Klm([arrRegion objectAtIndex:section]);
    [btnSection addTarget:self action:@selector(btnSectionTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(15, 9, 40, 40)];
    imageView1.image = [UIImage imageNamed:[[[arrRegion objectAtIndex:section] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    imageView1.layer.cornerRadius = 20;
    imageView1.userInteractionEnabled = YES;
    imageView1.backgroundColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance] getActiveProfile].theme.themeColor];
    
    UILabel *textLabel = [AppUtilities createLabelWithTag:0 frame:CGRectMake(62, 0, 230, 60) andText:Klm([arrRegion objectAtIndex:section])];
    textLabel.userInteractionEnabled = YES;
    [AppUtilities adjustFontSizeOfLabel:textLabel];
    
    if(![[arrRegion objectAtIndex:section] isEqualToString:UnitedStates] && ![[arrRegion objectAtIndex:section] isEqualToString:Canada] ) {
        
        if (!(self.isODEActive || self.isKofaxMobileIdActive)) {
            UIImageView *imgViewArrow = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 30, 20, 15, 20)];
            if(self.intSelectedSection == section){
                
                imgViewArrow.image = [UIImage imageNamed:@"downarrow.png"];
                imgViewArrow.frame = CGRectMake(self.view.frame.size.width - 35, 15, 20, 15);
                
                
            }
            else{
                
                imgViewArrow.image = [UIImage imageNamed:@"rightArrow.png"];
                imgViewArrow.frame = CGRectMake(self.view.frame.size.width - 30, 20, 15, 20);
                
            }
            imgViewArrow.userInteractionEnabled = YES;
            [viewHeader addSubview:imgViewArrow];
            
            imgViewArrow = nil;
        }
        
        
        
    }
    
    [viewHeader addSubview:imageView1];
    [viewHeader addSubview:textLabel];
    [viewHeader addSubview:btnSection];
    
    imageView1 = nil;
    textLabel = nil;
    
    
    return viewHeader;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *arrRegion = [[self.dictRegions allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *arrCountry = [self.dictRegions valueForKey:[arrRegion objectAtIndex:indexPath.section]];
    DLRegionAttributes *objAttributes = [arrCountry objectAtIndex:indexPath.row];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(regionForDLSelected:)]){
        [self.delegate regionForDLSelected:objAttributes];
    }
    
}

#pragma mark - Adding the Static Region and Country List

-(void)intializeTheRegionAndCountryList {
    
    if(self.dictRegions == nil) {
        
        self.dictRegions = [[NSMutableDictionary alloc]init];
    }
    else {
        
        [self.dictRegions removeAllObjects];
    }
    
    // If ODE is active add the countries that you are supporting
    
    // For United States
    
    DLRegionAttributes *objUnitedStates = [[DLRegionAttributes alloc]init];
    objUnitedStates.strDisplayRegion = UnitedStates;
    objUnitedStates.xRegion = @"United States";
    objUnitedStates.xState = @"";
    objUnitedStates.strImageResize = ImageResizeID1;
    
    [self.dictRegions setValue:@[objUnitedStates] forKey:UnitedStates];
    
    objUnitedStates = nil;
    
    
    if (!(self.isODEActive || self.isKofaxMobileIdActive)){
        
        
        // For Canada
        
        DLRegionAttributes *objCanada = [[DLRegionAttributes alloc]init];
        objCanada.strDisplayRegion = Canada;
        objCanada.xRegion = @"Canada";
        objCanada.xState = @"";
        objCanada.strImageResize = ImageResizeID1;
        [self.dictRegions setValue:@[objCanada] forKey:Canada];
        
        objCanada = nil;
        
        // For Africa
        
        DLRegionAttributes *objCameroon = [[DLRegionAttributes alloc]init];
        objCameroon.strDisplayRegion = @"Cameroon";
        objCameroon.xRegion = @"Africa";
        objCameroon.xState = @"1350";
        objCameroon.strImageResize = ImageResizeID1;
        
        DLRegionAttributes *objAfricaOther = [[DLRegionAttributes alloc]init];
        objAfricaOther.strDisplayRegion = OTHERCOUNTRY;
        objAfricaOther.xRegion = @"Africa";
        objAfricaOther.xState = @"";
        objAfricaOther.strImageResize = ImageResizeID1;
        
        
        [self.dictRegions setValue:@[objCameroon,objAfricaOther] forKey:@"Africa"];
        
        objCameroon = nil;
        objAfricaOther = nil;
        
        // For America
        
        DLRegionAttributes *objBrazil = [[DLRegionAttributes alloc]init];
        objBrazil.strDisplayRegion = @"Brazil";
        objBrazil.xRegion = @"Latin America";
        objBrazil.xState = @"130";
        objBrazil.strImageResize = ImageResizeID1;
        
        DLRegionAttributes *objEcuador = [[DLRegionAttributes alloc]init];
        objEcuador.strDisplayRegion = @"Ecuador";
        objEcuador.xRegion = @"Latin America";
        objEcuador.xState = @"710";
        objEcuador.strImageResize = ImageResizeID1;
        
        DLRegionAttributes *objElSalvador = [[DLRegionAttributes alloc]init];
        objElSalvador.strDisplayRegion = @"El Salvador";
        objElSalvador.xRegion = @"Latin America";
        objElSalvador.xState = @"380";
        objElSalvador.strImageResize = ImageResizeID1;
        
        DLRegionAttributes *objGuatemala = [[DLRegionAttributes alloc]init];
        objGuatemala.strDisplayRegion = @"Guatemala";
        objGuatemala.xRegion = @"Latin America";
        objGuatemala.xState = @"370";
        objGuatemala.strImageResize = ImageResizeID1;
        
        DLRegionAttributes *objChristNevis = [[DLRegionAttributes alloc]init];
        objChristNevis.strDisplayRegion = @"St. Christ Nevis";
        objChristNevis.xRegion = @"Latin America";
        objChristNevis.xState = @"1000";
        objChristNevis.strImageResize = ImageResizeID1;
        
        DLRegionAttributes *objAmericaOther = [[DLRegionAttributes alloc]init];
        objAmericaOther.strDisplayRegion = OTHERCOUNTRY;
        objAmericaOther.xRegion = @"Latin America";
        objAmericaOther.xState = @"";
        objAmericaOther.strImageResize = ImageResizeID1;
        
        
        [self.dictRegions setValue:@[objBrazil,objEcuador,objElSalvador,objGuatemala,objChristNevis,objAmericaOther] forKey:@"Latin America"];
        
        objBrazil = nil;
        objEcuador = nil;
        objElSalvador = nil;
        objGuatemala = nil;
        objChristNevis = nil;
        objAmericaOther = nil;
        
        
        // For Asia
        
        DLRegionAttributes *objChina = [[DLRegionAttributes alloc]init];
        objChina.strDisplayRegion = @"China";
        objChina.xRegion = @"Asia";
        objChina.xState = @"470";
        objChina.strImageResize = ImageResizeID1;
        
        DLRegionAttributes *objIndia = [[DLRegionAttributes alloc]init];
        objIndia.strDisplayRegion = @"India";
        objIndia.xRegion = @"Asia";
        objIndia.xState = @"850";
        objIndia.strImageResize = ImageResizeID1;
        
        DLRegionAttributes *objSingapore = [[DLRegionAttributes alloc]init];
        objSingapore.strDisplayRegion = @"Singapore";
        objSingapore.xRegion = @"Asia";
        objSingapore.xState = @"180";
        objSingapore.strImageResize = ImageResizeID1;
        
        DLRegionAttributes *objSouthKorea = [[DLRegionAttributes alloc]init];
        objSouthKorea.strDisplayRegion = @"South Korea";
        objSouthKorea.xRegion = @"Asia";
        objSouthKorea.xState = @"2220";
        objSouthKorea.strImageResize = ImageResizeID1;
        
        DLRegionAttributes *objAsiaOther = [[DLRegionAttributes alloc]init];
        objAsiaOther.strDisplayRegion = OTHERCOUNTRY;
        objAsiaOther.xRegion = @"Asia";
        objAsiaOther.xState = @"";
        objAsiaOther.strImageResize = ImageResizeID1;
        
        
        [self.dictRegions setValue:@[objChina,objIndia,objSingapore,objSouthKorea,objAsiaOther] forKey:@"Asia"];
        
        objChina = nil;
        objIndia = nil;
        objSingapore = nil;
        objSouthKorea = nil;
        objAsiaOther = nil;
        
        // For Australia
        
        DLRegionAttributes *objKeypass = [[DLRegionAttributes alloc]init];
        objKeypass.strDisplayRegion = @"Keypass";
        objKeypass.xRegion = @"Australia";
        objKeypass.xState = @"500";
        objKeypass.strImageResize = ImageResizeID1;
        
        DLRegionAttributes *objAustraliaOther = [[DLRegionAttributes alloc]init];
        objAustraliaOther.strDisplayRegion = OTHERCOUNTRY;
        objAustraliaOther.xRegion = @"Australia";
        objAustraliaOther.xState = @"";
        objAustraliaOther.strImageResize = ImageResizeID1;
        
        
        [self.dictRegions setValue:@[objKeypass,objAustraliaOther] forKey:@"Australia"];
        
        objKeypass = nil;
        objAustraliaOther = nil;
        
        // For Europe
        
        DLRegionAttributes *objAlbania = [[DLRegionAttributes alloc]init];
        objAlbania.strDisplayRegion = @"Albania";
        objAlbania.xRegion = @"Europe";
        objAlbania.xState = @"1010";
        objAlbania.strImageResize = ImageResizeID1;
        
        DLRegionAttributes *objGermany = [[DLRegionAttributes alloc]init];
        objGermany.strDisplayRegion = Germany;
        objGermany.xRegion = @"Europe";
        objGermany.xState = @"140";
        objGermany.strImageResize = ImageResizeID1; // By default New ID is selected for Germany
        
        DLRegionAttributes *objLithuania = [[DLRegionAttributes alloc]init];
        objLithuania.strDisplayRegion = @"Lithuania";
        objLithuania.xRegion = @"Europe";
        objLithuania.xState = @"";
        objLithuania.strImageResize = ImageResizeID1;
        
        DLRegionAttributes *objLuxembourg = [[DLRegionAttributes alloc]init];
        objLuxembourg.strDisplayRegion = @"Luxembourg";
        objLuxembourg.xRegion = @"Europe";
        objLuxembourg.xState = @"";
        objLuxembourg.strImageResize = ImageResizeID1;
        
        DLRegionAttributes *objEuropeOther = [[DLRegionAttributes alloc]init];
        objEuropeOther.strDisplayRegion = OTHERCOUNTRY;
        objEuropeOther.xRegion = @"Europe";
        objEuropeOther.xState = @"";
        objEuropeOther.strImageResize = ImageResizeID1;
        
        
        
        [self.dictRegions setValue:@[objAlbania,objGermany,objLithuania,objLuxembourg,objEuropeOther] forKey:@"Europe"];
        
        objAlbania = nil;
        objGermany = nil;
        objLithuania = nil;
        objLuxembourg = nil;
        objEuropeOther = nil;
    }
    
}

#pragma mark - Button Actions


- (void)germanIDTouchUpInside:(KFXSegmentedControl *)segmentControl {
    [self germanIDValueChanged:segmentControl];
}

- (void)germanIDTouchUpOutside:(KFXSegmentedControl *)segmentControl {
    [self germanIDValueChanged:segmentControl];
}


- (void)germanIDValueChanged:(KFXSegmentedControl*)segmentControl
{
    self.intSelectedSegmentForGermany = segmentControl.selectedSegmentIndex;
    
    NSArray *arrCountry = [self.dictRegions valueForKey:@"Europe"];
    
    for(DLRegionAttributes *objRegion in arrCountry){
        
        if([objRegion.strDisplayRegion isEqualToString:Germany]){
            
            if(self.intSelectedSegmentForGermany == 0){
                
                objRegion.strImageResize= ImageResizeGermanyOldID2;
                objRegion.xState = @"140";
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(regionForDLSelected:)]){
                    [self.delegate regionForDLSelected:objRegion];
                }
                
                break;
                
            }
            else if (self.intSelectedSegmentForGermany == 1){
                
                objRegion.strImageResize = ImageResizeID1;
                objRegion.xState = @"140";
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(regionForDLSelected:)]){
                    [self.delegate regionForDLSelected:objRegion];
                }
                
                break;
            }
            else{
                
                objRegion.strImageResize = ImageResizeID1;
                objRegion.xState = @"141";
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(regionForDLSelected:)]){
                    [self.delegate regionForDLSelected:objRegion];
                }
                
                break;
            }
            
        }
        
        
        
    }

}

-(void)btnSectionTapped:(UIButton *)btnSection {
    
    NSArray *arrRegion = [[self.dictRegions allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    if (self.isODEActive || self.isKofaxMobileIdActive) {
        NSArray *arrCountry = [self.dictRegions valueForKey:[arrRegion objectAtIndex:btnSection.tag - TagSection]];
        DLRegionAttributes *objAttributes = [arrCountry objectAtIndex:0];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(regionForDLSelected:)]){
            [self.delegate regionForDLSelected:objAttributes];
        }
    }
    else{
        if(![[arrRegion objectAtIndex:btnSection.tag - TagSection] isEqualToString:UnitedStates] && ![[arrRegion objectAtIndex:btnSection.tag - TagSection] isEqualToString:Canada] ) {
            
            if(self.intSelectedSection == btnSection.tag - TagSection) {
                
                self.intSelectedSection = -1;
            }
            else {
                
                self.intSelectedSection = btnSection.tag - TagSection;
            }
            
            [self.table reloadData];
            
        }
        else {
            
            //            NSArray *arrRegion = [[self.dictRegions allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            NSArray *arrCountry = [self.dictRegions valueForKey:[arrRegion objectAtIndex:btnSection.tag - TagSection]];
            DLRegionAttributes *objAttributes = [arrCountry objectAtIndex:0];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(regionForDLSelected:)]){
                [self.delegate regionForDLSelected:objAttributes];
            }
            
        }
    }
    
    
    
}




@end
