//
//  AppDelegate.h
//  Star Dash
//
//  Created by Clayton Schubiner on 8/13/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "iRate.h"
#import "Flurry.h"

#import <Kamcord/Kamcord.h>

@interface AppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate,iRateDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;
    
	CCDirectorIOS	*director_;							// weak ref
    int chosenLevelNumber;
    bool isRetinaDisplay;
    bool wasJustBackgrounded;
    int galaxyCounter;
    
    bool shouldDisplayPredPoints;
    
    bool shouldPlayMenuMusic;
    
    bool didGetToMainMenu;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;
-(UIViewController*)getViewController;
-(void)setIsInTutorialMode:(bool)mode;
-(bool)getIsInTutorialMode;
-(bool)getIsRetinaDisplay;
-(void)setChosenLevelNumber:(int)num;
-(int)getChosenLevelNumber;
-(bool)getWasJustBackgrounded;
-(void)setWasJustBackgrounded:(bool)isItBackgrounded;
-(int)getGalaxyCounter;
-(void)setGalaxyCounter:(int)count;

-(void)setdidGetToMainMenu:(bool)didGet;
-(bool)getdidGetToMainMenu;

-(bool)getShouldDisplayPredPoints;
-(bool)getShouldPlayMenuMusic;
-(void)setShouldPlayMenuMusic:(bool)a_shouldPlay;


@end
