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
#import "PowerupManager.h"
#import "LevelObjectReturner.h"
#import "Light.h"
#import "Galaxy.h"

@interface GameplayLayer : CCLayer {
    Player *player;
    NSMutableArray *planets;
    NSMutableArray *zones;
    NSMutableArray *asteroids;
    NSMutableArray *powerups;
    NSMutableArray *coins;
    NSMutableArray *coinSprites;
    CCLabelTTF *scoreLabel;
    CCLabelTTF *coinsLabel;
    CGSize size;
    CCLayer *hudLayer;
    CCLayer* layerHudSlider;
    CCSprite* slidingSelector;
    CCLayer *cameraLayer;
    CCNode * cameraFocusNode;
    CGPoint cameraLastFocusPosition;
    float cameraDistToUse;
    Planet * lastPlanetVisited;
    bool justReachedNewPlanet;
    ccTime totalGameTime;
    float timeSinceCometLeftScreen;
    bool planetJustExploded;
    bool playerIsTouchingScreen;
    float asteroidSlower;
    float updatesWithoutBlinking;
    float updatesWithBlinking;
    CCAction* galaxyLabelAction;
    int coinAnimator;
    int coinAnimator2;
    
    float powerupCounter;
    
    NSArray * galaxies;
    Galaxy* currentGalaxy;
    Galaxy* nextGalaxy;
    int planetsHitSinceNewGalaxy;
    int segmentsSpawnedFlurry;
    int planetsHitFlurry;
    bool cameraShouldFocusOnPlayer;
    CCLabelTTF * galaxyLabel;
    bool justDisplayedGalaxyLabel;
    
    bool isOnFirstRun;
    CGPoint initialVel;
    float initialAccelMag;
    CCLayerStreak * streak;
    
    CGPoint spotGoingTo;
    float swipeAccuracy;
    float velSoftener;
    float gravIncreaser;
    
    int planetNumToRespawnSegments;
    int makingSegmentNumber;
    CGPoint indicatorPos;
    
    float dangerLevel;
    float nextPlanetScale;
    float nextPlanetOpacity;
    int updatesSinceLastPlanet;
    
    Light* light;
    
    float tempScore;
    
    int originalSegmentNumber;
    
    bool isInTutorialMode;
    CCSprite* tutImage1;
    CCSprite* tutImage2;
    CCSprite* tutImage3;

    
    bool isGameOver;
    bool didEndGameAlready;
    int orbitState; // 0 = orbiting; 1 = just left orbit and deciding things for state 2; 3 = flying to next planet
    Planet* targetPlanet;
    CGPoint swipeVector;
    int levelNumber;
    
    float totalSecondsAlive;
    
    CCParticleSystemQuad * thrustParticle;
    CCParticleSystemQuad * cometParticle;
    CCParticleSystemQuad * playerExplosionParticle;
    CGPoint cometVelocity;
    float lastTakeoffAngleToNextPlanet;
    
    // is multiplied by the absoluteSpeedMult to cause time dilation
    float timeDilationCoefficient;
    
    // number of zones gone through without screwing up
    int numZonesHitInARow;
    int currentPtoPscore;
    
    CCSprite * background;
    CCSprite * background2;
    CCSpriteBatchNode* spriteSheet;
    CCLayer *pauseLayer;
    CCLabelBMFont * gameOverScoreLabel;
}

+ (CCScene *) scene;

- (float)randomValueBetween:(float)low andValue:(float)high;

- (int)RandomBetween:(int)minvalue maxvalue:(int)maxvalue;

- (void)togglePause;

double lerpd(double a, double b, double t);
float lerpf(float a, float b, float t);

@end
