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
#import "UserWallet.h"
#import "PowerupManager.h"
#import "LevelObjectReturner.h"
#import "Light.h"
#import "Galaxy.h"
#import "UpgradeValues.h"
#import "ObjectiveManager.h"

@interface GameplayLayer : CCLayer <UITextViewDelegate> {
    Player *player;
    NSMutableArray *planets;
    NSMutableArray *zones;
    NSMutableArray *asteroids;
    NSMutableArray *powerups;
    NSMutableArray *coins;
    NSMutableArray * coinAnimationFrames;
    CCAnimation * coinAnimation;
    CCLabelBMFont *scoreLabel;
    CCLabelBMFont *coinsLabel;
    
    bool isLeavingLastPlanetInGalaxy;
    bool allowVideoToConvert;
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
    float updatesWithoutBlinking;
    float updatesWithBlinking;
    CCAction* galaxyLabelAction;
    bool isDisplayingPowerupAnimation;
    CCLabelTTF *powerupLabel;
    float powerupPos;
    float powerupVel;
    int numCoinsDisplayed;
    
    int lastOrbitState ;
    
    NSMutableArray* predPoints;
    
    CCLayer* tutLayer;
    float tutCounter;
    bool hasOpenedTut;
    bool isDoingTutStuff;
    float pauseDuration;
    NSString* pauseText;
    CCLabelTTF* pauseLabel;
    CCLabelTTF* continueLabel;
    
    bool hasDiplayedArrowText;
    bool hasDiplayedCoinText;
    bool hasDiplayedBatteryText;
    
    CCSprite* tutHand;
    CCLabelTTF* tutLabel;
    
    CGPoint cameraLayerLastPosition;
    
    CCLabelBMFont * zeroCoinsLabel;
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
    float timeToAddToTimer;
    
    int originalSegmentNumber;
    int flurrySegmentsVisitedSinceGalaxyJump;
    CCSprite* tutImage1;
    CCSprite* tutImage2;
    CCSprite* tutImage3;

    CCSprite* batteryDecreaserSprite;
    CCSprite* batteryGlowSprite;
    CCSpeed* batteryGlowScaleAction;
    
    bool isGameOver;
    bool didEndGameAlready;
    int orbitState; // 0 = orbiting; 1 = just left orbit and deciding things for state 2; 3 = flying to next planet
    Planet* targetPlanet;
    CGPoint swipeVector;
    
    int lastOrigSegmentNum;
    
    CCLabelTTF * loadingLabelHelperText2;
    
    float totalSecondsAlive;
    CCLabelBMFont * starStashLabel;
    CCSprite * starStashSprite;
    CCParticleSystemQuad * starStashParticle;
    CCParticleSystemQuad * playerSpawnedParticle;
    CCParticleSystemQuad * thrustParticle;
    CCParticleSystemQuad * thrustBurstParticle;
    CCParticleSystemQuad * cometParticle;
    CCParticleSystemQuad * playerExplosionParticle;
    CCParticleSystemQuad * feverModeInitialExplosionParticle;
    CCParticleSystemQuad * feverModeLabelParticle;
    CGPoint cometVelocity;
    float lastTakeoffAngleToNextPlanet;
    CCAction * cameraFollowAction;
    float timeSinceGotLastCoin;
    float lastCoinPitch;
    ALuint lastCoinSoundID;
    
    // is multiplied by the absoluteSpeedMult to cause time dilation
    float timeDilationCoefficient;
    
    // number of zones gone through without screwing up
    int numZonesHitInARow;
    int currentPtoPscore;
    
    CCSprite * coinsLabelStarSprite;
    
    CCLayerColor * loadingLayerBackground;
    CCLayer * loadingLayer;
    CCLabelBMFont * loadingHelperTextLabel;
    CCLabelBMFont * loadingLabel;
    CCLabelBMFont * loadingDidYouKnowLabel;
    bool loading_playerHasReachedFirstPlanet;
    
    float directionPlanetSegmentsGoIn;
    
    bool isFinishedLoading;
    
    NSMutableArray * backgroundStars;
    CCSpriteBatchNode* backgroundSpriteSheet;
    CCSprite * backgroundClouds;
    CCSprite * batteryInnerSprite;
    CCSpriteBatchNode* spriteSheet;
    CCLayer *pauseLayer;
    CCLabelBMFont * gameOverScoreLabel;
    
    CCTexture2D * coinTexture;
    
    UITextView *playerNameLabel;
    CCLabelBMFont *displayName;
    CCLabelBMFont *underscore;
    NSString *recentName;
    
    float lastPercentOfTheWayToNext;
    bool percentToNextHasAlreadyBeenBelowZeroForThisPlanet;
    
    CCMenuItemImage *soundButton;
    
    CCMotionStreak *streak;
}

+ (CCScene *) scene;

- (float)randomValueBetween:(float)low andValue:(float)high;

- (int)RandomBetween:(int)minvalue maxvalue:(int)maxvalue;

- (void)togglePause;

//- (BOOL)textFieldShouldReturn:(UITextField *)textFiel;

double lerpd(double a, double b, double t);
float lerpf(float a, float b, float t);

@end