//
//  CDSummaryDataSource.h
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 19/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SummaryEtitableCell.h"

@interface CDSummaryDataSource : NSObject<BaseDataSourceProtocol>
@property(nonatomic,assign) id <BaseSummaryCellProtocol> delegate;
@end
