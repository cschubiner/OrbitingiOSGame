//
//  GameplayLayer.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Player.h"

@interface GameplayLayer : CCLayer {
    
    Player *player;
    NSMutableArray *planets;
    NSMutableArray *cameraObjects;
    CGFloat lastPlanetXPos;
    CGFloat lastPlanetYPos;
    CCLabelTTF *scoreLabel;
    CGSize size ;
    int planetCounter;
    int score;
    int prevScore;
    int initialScoreConstant;
    
    //this is where the player is on screen (240,160 is center of screen)
    CGPoint cameraFocusPosition;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
