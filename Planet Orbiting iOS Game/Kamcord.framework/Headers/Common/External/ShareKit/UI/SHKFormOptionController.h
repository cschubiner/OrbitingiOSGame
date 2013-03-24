//
//  SHKFormOptionController.h
//  PhotoToaster
//
//  Created by Steve Troppoli on 9/2/11.
//  Copyright 2011 East Coast Pixels. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KC_SHKFormFieldSettings;

@protocol KCSHKFormOptionControllerClient;
@protocol KCSHKFormOptionControllerOptionProvider;

@class KC_SHKFormOptionController;
@compatibility_alias SHKFormOptionController KC_SHKFormOptionController;

@interface KC_SHKFormOptionController : UITableViewController {
	KC_SHKFormFieldSettings* settings;
	id<KCSHKFormOptionControllerClient> client;
	id<KCSHKFormOptionControllerOptionProvider> provider;
	bool didLoad;
}

@property(nonatomic,retain) KC_SHKFormFieldSettings* settings;
@property(nonatomic,assign) id<KCSHKFormOptionControllerClient> client;


- (id)initWithOptionsInfo:(KC_SHKFormFieldSettings*) settingsItem client:(id<KCSHKFormOptionControllerClient>) optionClient;
- (void) optionsEnumerated:(NSArray*) options;
- (void) optionsEnumerationFailedWithError:(NSError *)error;;
@end




@protocol KCSHKFormOptionControllerClient

@required
// called when an item is taped or cancel is clicked, cancel passes nil pickedOption.
-(void) SHKFormOptionController:(SHKFormOptionController*) optionController pickedOption:(NSString*)pickedOption;
@end	




@protocol KCSHKFormOptionControllerOptionProvider

@required
// called when network based options need to be enumerated
// delegates must call either optionsEnumerated: or optionsEnumerationFailedWithError:
-(void) SHKFormOptionControllerEnumerateOptions:(SHKFormOptionController*) optionController;
// called to cancel an enumeration request
-(void) SHKFormOptionControllerCancelEnumerateOptions:(SHKFormOptionController*) optionController;
@end	
