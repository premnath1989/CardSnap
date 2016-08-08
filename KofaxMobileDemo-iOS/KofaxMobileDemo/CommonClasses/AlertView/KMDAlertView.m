//
//  KMDAlertView.m
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 09/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import "KMDAlertView.h"

static KMDAlertView *alertView = nil;

@interface KMDAlertView ()<UIAlertViewDelegate>
{
}

@property (copy, nonatomic) AlertComletion completionAlert;
@property (strong, nonatomic) NSArray *alertButtons;

@end

@implementation KMDAlertView

+(KMDAlertView *)sharedInstance
{
    if(alertView == nil)
    {
        static dispatch_once_t gcdToken;
        dispatch_once(&gcdToken, ^{
            alertView = [[KMDAlertView alloc] init];
        });
    }
    return alertView;
}

// This method is used to show aletView , This will be responsible for handling UIAlertView and UIAlertViewController.
//@param
//sender : need to pass current viewController reference. it will be required to present UIAlertViewController.
// title : title to display on top of alertview as NSString
// message : message as NSString
// buttons : you can pass NSArray with titles like [NSArray arrayWithObjects:@"OK",nil];
// completion : this block will retun button title whenever you clicked on button.
-(void)showAlert:(UIViewController *)sender title:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles completion:(AlertComletion)completion
{
    int aboveIOS7 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1);
    if (aboveIOS7) {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title
                                                                         message:message preferredStyle:UIAlertControllerStyleAlert];
        for (NSString *buttonTitle in buttonTitles) {
            [alertVc addAction:[UIAlertAction actionWithTitle:buttonTitle
                                                        style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                            completion(action.title);
                                                        }]];
        }
        [sender presentViewController:alertVc animated:YES completion:nil];
    }
    else
    {
        _completionAlert = completion;
        _alertButtons = buttonTitles;
        UIAlertView * alertView = [[UIAlertView alloc]init];
        alertView.delegate = self;
        alertView.title = title;
        alertView.message = message;
        for (NSString *buttonTitle in buttonTitles) {
            [alertView addButtonWithTitle:buttonTitle];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [alertView show];
        });
    }
}

#pragma mark---AlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_completionAlert) {
        _completionAlert(_alertButtons[buttonIndex]);
    }
}

- (void)dealloc
{
    _alertButtons = nil;
    _completionAlert = nil;
}

@end
