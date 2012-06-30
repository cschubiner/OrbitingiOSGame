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
#import "Arrow.h"

@interface GameplayLayer : CCLayer {
    
    Player *player;
    Arrow *arrow;
    NSMutableArray *planets;
    NSMutableArray *zones;
    NSMutableArray *cameraObjects;
    CGFloat lastPlanetXPos;
    CGFloat lastPlanetYPos;
    CCLabelTTF *scoreLabel;
    CCLabelTTF *zonesReachedLabel;
    CGSize size;
    CCLayer *hudLayer;
    CCLayer *cameraLayer;
    float initScaler;
    float scaler;
    float thrustMag;

    // where the player is on the screen (240,160 is center of screen)
    CGPoint cameraFocusPosition;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+ (CCScene *) scene;

- (int)RandomBetween:(int)minvalue maxvalue:(int)maxvalue;
@end
