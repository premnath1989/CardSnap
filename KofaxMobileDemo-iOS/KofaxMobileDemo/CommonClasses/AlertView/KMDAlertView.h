//
//  KMDAlertView.h
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 09/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^AlertComletion)(NSString *buttonTitle);

@interface KMDAlertView : NSObject
+(KMDAlertView *)sharedInstance;
// This method is used to show aletView that will be responsible for handling UIAlertView and UIAlertViewController.
//@param
//sender : need to pass current viewController it will be required to present UIAlertViewController
// title : title to display on top of alertview as NSString
// message : message as NSString
// buttons : you can pass NSArray with titles like [NSArray arrayWithObjects:@"OK",nil];
// completion : this block will retun button title whenever you clicked on button.
-(void)showAlert:(UIViewController *)sender title:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles completion:(AlertComletion)completion;
@end
