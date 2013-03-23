//
//  KCShareDelegateIntermediary.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 12/10/12.
//
//

#import "Kamcord.h"

@interface KCShareDelegateIntermediary : NSObject <KCShareDelegate>

@property (nonatomic, retain) id <KCShareDelegate> shareDelegate;

- (id)initWithShareDelegate:(id <KCShareDelegate>)shareDelegate;

@end
