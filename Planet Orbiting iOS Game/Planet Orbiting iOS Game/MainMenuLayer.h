//
//  MainMenuLayer.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright Clayton Schubiner 2012. All rights reserved.
//

#import "cocos2d.h"
#import "CCBReader.h"
#import "TestFlight.h"
#import "Flurry.h"
#import "AppDelegate.h"
#import "StoreManager.h"

@interface MainMenuLayer : CCLayer <UIAlertViewDelegate>{
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
    CCLabelBMFont *name1Label;
    CCLabelBMFont *name2Label;
    CCLabelBMFont *name3Label;
    CCLabelBMFont *name4Label;
    CCLabelBMFont *name5Label;
    CCLabelBMFont *name6Label;
    CCLabelBMFont *name7Label;
    CCLabelBMFont *name8Label;
    CCLayer *tutorialLayer;
}

+ (CCScene *)scene;

@end