//
//  CDSummaryDataSource.m
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 19/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import "CDSummaryDataSource.h"
#import "ExtractionFields.h"
#import "AppStateMachine.h"

@interface CDSummaryDataSource ()
@property(nonatomic,assign) Component *componentObject;
@property(nonatomic,strong) NSMutableArray *extractionFields;
@property (nonatomic,strong) AppStateMachine *appStats;
@property (nonatomic,assign) UICollectionView *collectionView;

@end

@implementation CDSummaryDataSource

@synthesize componentObject;
@synthesize extractionFields;
@synthesize appStats;

-(id)initWithResult:(NSMutableArray *)result withComponent:(Component *)component
{
    if(self = [super init])
    {
        self.extractionFields = result;
        self.componentObject = component;
        self.appStats = [AppStateMachine sharedInstance];
    }
    return self;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    ExtractInfo *info = self.extractionFields[indexPath.row];
    SummaryEtitableCell *customcell = (SummaryEtitableCell *)[self dequeueReusableCellWithIdentifier:[self reusableIdentifierForType:[info.keyBoardType integerValue]] fortableView:tableView];
    if (customcell.delegate == nil) {
        customcell.delegate = self.delegate;
    }
    customcell.indexPath = indexPath;
    customcell.info = info;
    if ([info.name isEqualToString:@"Routing No."]) {
        customcell.labelTitle.text = Klm(self.componentObject.texts.summaryText[ROUTINGNUMBER]);
    }else if([info.name isEqualToString:@"Check Number"]){
        customcell.labelTitle.text = Klm(self.componentObject.texts.summaryText[CHECKNUMBER]);
    }else if([info.name isEqualToString:@"Amount"]){
        customcell.labelTitle.text = Klm(self.componentObject.texts.summaryText[AMOUNT]);
    }
    return customcell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.extractionFields.count;
}

-(UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier fortableView:(UITableView *)tableView
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell;
}

-(NSString *)reusableIdentifierForType:(NSInteger)type
{
    switch (type) {
        case 0:
            return @"SummaryEtitableCell";
            break;
        default:
            return @"SummaryEtitableCell";
            break;
    }
}

-(UIImageView*)getImageViewofIndex:(NSInteger)index{
    UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake((index?3:self.collectionView.frame.size.width-27), (self.collectionView.frame.size.height/2-20), 24, 40)];
    arrowImage.image = [UIImage imageNamed:(index?@"arow_left":@"arow_right")];
    arrowImage.tag = index;
    arrowImage.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(arrowAction:)];
    [arrowImage addGestureRecognizer:gesture];
    gesture = nil;
    
    return arrowImage;
}

-(void)arrowAction:(UITapGestureRecognizer*)gesture{
    UIImageView *imageView = (UIImageView*)gesture.view;
    NSArray *visibleItems = [self.collectionView indexPathsForVisibleItems];
    NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
    NSIndexPath *nextItem = [NSIndexPath indexPathForItem:(imageView.tag?currentItem.item-1:currentItem.item + 1) inSection:currentItem.section];
    [self.collectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

// CollectionView Delegates
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    self.collectionView = collectionView;
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewIdentifier" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor grayColor];
    
    [cell.contentView addSubview:[self getImageViewofIndex:indexPath.row]];
    
    UIImageView *thumbnail = [[UIImageView alloc]initWithFrame:CGRectMake(30, 0, collectionView.frame.size.width-60, collectionView.frame.size.height)];
    thumbnail.contentMode = UIViewContentModeScaleAspectFit;
    
    
    
    kfxKEDImage *frontProcessedImage = [self.appStats getImage:indexPath.row?BACK_PROCESSED:FRONT_PROCESSED mimeType:MIMETYPE_TIF];
    UIImage *image = [frontProcessedImage getImageBitmap];
    
   /* float origSize = image.size.width;
    
    image = [self getScaledImage:image destSize:[self getSizeOfImageThumbnail:indexPath.row withHeight:collectionView.frame.size.height] fact:4.0];
    
    NSLog(@"--%@",NSStringFromCGSize(image.size));
    
    float scaledSize = image.size.width;
    
    float fact = scaledSize/origSize;
    
    // highlight the found RTTI Fields
    
    for (int i=0; i <self.extractionFields.count; i ++)
    {
        ExtractInfo *info = self.extractionFields[i];
        float left = info.coordinates.origin.x * fact;
        float top = info.coordinates.origin.y * fact;
        float width = info.coordinates.size.width * fact;
        float height = info.coordinates.size.height * fact;
        NSInteger pageIndex = info.pageIndex;
        
        if (indexPath.row == pageIndex)
        {
            
            if ((left >= 0) && (left <= image.size.width) && (top >= 0) && (top <= image.size.height))
            {
                if ((left + width) > image.size.width) {
                    width = image.size.width - left;
                }
                if ((top + height) > image.size.height) {
                    height = image.size.height - top;
                }
                
                @autoreleasepool {
                    
                    // begin a graphics context of sufficient size
                    UIGraphicsBeginImageContext(image.size);
                    
                    // draw original image into the context
                    [image drawAtPoint:CGPointZero];
                    
                    // create context
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    
                    // drawing with a white stroke color
                    CGContextSetRGBStrokeColor(context, 0.0, 255.0, 0.0, 0.5);
                    
                    // drawing with a white fill color
                    CGContextSetRGBFillColor(context, 0.0, 255.0, 0.0, 0.5);
                    
                    // Add Filled Rectangle,
                    CGContextFillRect(context, CGRectMake(left, top, width, height));
                    
                    //UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    
                    UIGraphicsEndImageContext();
                    
                    context = nil;
                    
                }
                
            }
        }
    }*/
    
    
    thumbnail.image = image;
    
    [cell.contentView addSubview:thumbnail];
    
    image = nil;
    
    return cell;
    
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width,collectionView.frame.size.height);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

/*// Get Size of thumbnail of image
-(CGSize)getSizeOfImageThumbnail:(NSInteger)index withHeight:(float)thumbnailSize
{
    kfxKEDImage *kedImage = [self.appStats getImage:index?BACK_PROCESSED:FRONT_PROCESSED mimeType:MIMETYPE_TIF];
    UIImage *img= kedImage.getImageBitmap;
    float x = img.size.width;
    float y = img.size.height;
    
    img=nil;
    kedImage = nil;
    
    if (x>y) {
        float fact = y / x;
        return CGSizeMake( thumbnailSize,thumbnailSize *fact);
    } else {
        float fact = x / y;
        return CGSizeMake(thumbnailSize *fact,thumbnailSize);
    }
}

// Get ScaledImage
-(UIImage *)getScaledImage:(UIImage *)img destSize:(CGSize)destSize fact:(float)fact;
{
    
    //UIImage *tempImage = nil;
    
    CGSize scaledSize = CGSizeMake(destSize.width*fact, destSize.height*fact);
    
    UIGraphicsBeginImageContext(scaledSize);
    
    CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
    thumbnailRect.origin = CGPointMake(0.0,0.0);
    thumbnailRect.size.width  = scaledSize.width;
    thumbnailRect.size.height = scaledSize.height;
    
    [img drawInRect:thumbnailRect];
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
    
}*/

@end
