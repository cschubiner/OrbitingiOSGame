//
//  GameplayLayer.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Clayton Schubiner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Player.h"
#import "Planet.h"
#import "SimpleAudioEngine.h"
#import "MainMenuLayer.h"
#import "CCBReader.h"
#import "Flurry.h"
#import "UserWallet.h"


@interface GameplayLayer : CCLayer {
    Player *player;
    NSMutableArray *planets;
    NSMutableArray *zones;
    NSMutableArray *asteroids;
    NSMutableArray *coins;
    NSMutableArray *cameraObjects;
    CCLabelTTF *scoreLabel;
    CCLabelTTF *zonesReachedLabel;
    CGSize size;
    CCLayer *hudLayer;
    CCLayer *cameraLayer;
    CCNode * cameraFocusNode;
    CGPoint cameraLastFocusPosition;
    Planet * lastPlanetVisited;
    bool justReachedNewPlanet;
    ccTime totalGameTime;
    float timeSinceCometLeftScreen;
    float timeSincePlanetExplosion;
    bool planetJustExploded;
    bool playerIsTouchingScreen;
    
    bool isOnFirstRun;
    CGPoint initialVel;
    float initialAccelMag;
    CCLayerStreak * streak;
    
    CGPoint spotGoingTo;
    float swipeAccuracy;
    float velSoftener;
    float gravIncreaser;
    
    bool isInTutorialMode;

    int orbitState; //0 = orbiting, 1 = just left orbit and deciding things for state 2; 3 = flying to next planet
    Planet* targetPlanet;
    CGPoint swipeVector;
    
    CCParticleSystemQuad * thrustParticle;
    CCParticleSystemQuad * planetExplosionParticle;
    CCParticleSystemQuad * spaceBackgroundParticle;
    CCParticleSystemQuad * cometParticle;
    CCParticleSystemQuad * blackHoleParticle;
    CGPoint cometVelocity;
        float lastTakeoffAngleToNextPlanet;
    
    // is multiplied by the absoluteSpeedMult to cause time dilation
    float timeDilationCoefficient;
    
    // number of zones gone through without screwing up
    int numZonesHitInARow;
    int currentPtoPscore;
    
    CCSprite * background;
    CCSpriteBatchNode* spriteSheet;
}

+ (CCScene *) scene;

- (float)randomValueBetween:(float)low andValue:(float)high;

- (int)RandomBetween:(int)minvalue maxvalue:(int)maxvalue;

double lerpd(double a, double b, double t);
float lerpf(float a, float b, float t);

@end
