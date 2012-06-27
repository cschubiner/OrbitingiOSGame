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
    CCLabelTTF *label;
    CCLabelTTF *label2;
    CCLabelTTF *label3;
    CCLabelTTF *scoreLabel;
    CGSize size ;
    int planetCounter;
    int score;
    int prevScore;
    int initialScoreConstant;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
