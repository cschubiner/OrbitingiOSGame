//
//  AppDelegate.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright Clayton Schubiner 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestFlight.h"
#import "Flurry.h"
#import <Kamcord/Kamcord.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    bool isInTutorialMode;
    bool isRetinaDisplay;
    bool wasJustBackgrounded;
}

@property (nonatomic, retain) UIWindow *window;
-(void)setIsInTutorialMode:(bool)mode;
-(bool)getIsInTutorialMode;
-(bool)getIsRetinaDisplay;
-(UIViewController*)getViewController;
-(bool)getWasJustBackgrounded;
-(void)setWasJustBackgrounded:(bool)isItBackgrounded;

@end
