//
//  MainMenuLayer.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright Clayton Schubiner 2012. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "CCBReader.h"
#import "AppDelegate.h"
#import "ObjectiveManager.h"
#import "UpgradesLayer.h"
#import "CreditsLayer.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MainMenuLayer : CCLayer <UIAlertViewDelegate,GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate,UIAlertViewDelegate, KamcordDelegate>{
    CCLayer* layer;
    CCLabelBMFont *coinBalanceLabel;
    CCLabelBMFont *numMagnetsLabel;
    CCLabelBMFont *numImmunitiesLabel;
    CCLabelBMFont *highScore1Label;
    CCLabelBMFont *highScore2Label;
    CCLabelBMFont *highScore3Label;
    CCLabelBMFont *highScore4Label;
    CCLabelBMFont *highScore5Label;
    CCLabelBMFont *highScore6Label;
    CCLabelBMFont *highScore7Label;
    CCLabelBMFont *highScore8Label;
    CCLabelBMFont *highScore9Label;
    CCLabelBMFont *name1Label;
    CCLabelBMFont *name2Label;
    CCLabelBMFont *name3Label;
    CCLabelBMFont *name4Label;
    CCLabelBMFont *name5Label;
    CCLabelBMFont *name6Label;
    CCLabelBMFont *name7Label;
    CCLabelBMFont *name8Label;
    CCLabelBMFont *name9Label;
    CCLabelBMFont *proScoreLabel;
    CCLabelBMFont *funScoreLabel;
    CCLayer *tutorialLayer;
    CCMenuItemImage * highScoreButton;
    CCMenuItemImage * objectivesButton;
    CCMenuItemImage * creditsButton;
    CCMenuItemImage * upgradesButton;
    CCMenuItemImage * soundButton;
    CGSize size ;
    
    CCNode* playerAndParticleNode;
    CCNode* bottomBarNode;
    CCNode* topBarNode;
    
    CCSprite* playerSprite;
    
    bool addedMoviePlayerObserver;
}

+ (CCScene *)scene;
//+(void)completeObjectiveFromGroupNumber:(int)a_groupNumber itemNumber:(int)a_itemNumber;

@property (strong,nonatomic) MPMoviePlayerController *myPlayer;

@end