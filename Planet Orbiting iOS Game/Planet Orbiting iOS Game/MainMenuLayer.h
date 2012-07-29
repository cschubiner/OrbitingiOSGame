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

@interface MainMenuLayer : CCLayer {
    CCLayer* layer;
    CCLabelBMFont *coinBalanceLabel;
    CCLabelBMFont *numMagnetsLabel;
    CCLabelBMFont *numImmunitiesLabel;
    CCLabelBMFont *highScore1;
    CCLabelBMFont *highScore2;
    CCLabelBMFont *highScore3;
    CCLabelBMFont *highScore4;
}

+ (CCScene *)scene;

@end