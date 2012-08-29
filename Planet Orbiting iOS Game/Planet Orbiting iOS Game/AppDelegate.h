//
//  AppDelegate.h
//  Star Dash
//
//  Created by Clayton Schubiner on 8/13/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;
    
	CCDirectorIOS	*director_;							// weak ref
    bool isInTutorialMode;
    int chosenLevelNumber;
    bool isRetinaDisplay;
    bool wasJustBackgrounded;
    int galaxyCounter;
    
    bool shouldPlayMenuMusic;
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

-(bool)getShouldPlayMenuMusic;
-(void)setShouldPlayMenuMusic:(bool)a_shouldPlay;


@end
