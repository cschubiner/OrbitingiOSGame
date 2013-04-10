//
// Created by amrik on 1/15/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface KCSelectTwitterAccountSheet : NSObject

@property (nonatomic, retain) UIActionSheet * actionSheet;
@property (nonatomic, retain) ACAccountStore * accountStore;

- (id)initWithDelegate:(id<UIActionSheetDelegate>)delegate;
- (int)numOfTwitterAccounts;
- (void)handleSelectingTwitterAccountWithViewController:(UIViewController *)viewController;

+ (BOOL)hasPickedAccountAlready;
+ (void)unlinkTwitterAccount;
+ (NSString *)currentlyLinkedAccount;

@end
