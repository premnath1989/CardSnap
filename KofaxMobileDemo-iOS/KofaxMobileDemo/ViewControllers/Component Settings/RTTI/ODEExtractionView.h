//
//  ODEExtractionView.h
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 28/09/15.
//  Copyright (c) 2016 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ODEExtractionView_Delegate<NSObject>

-(void)segmentedControlValueDidChange:(UISegmentedControl *)segment;

@end

@interface ODEExtractionView : UIView<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, strong) UITableViewCell *cell;
@property (nonatomic, strong) id<ODEExtractionView_Delegate> callBack;
@property (nonatomic, strong) NSMutableDictionary *rttiSettings;

-(void)reloadTableData;
-(void)designODEview;

@end
