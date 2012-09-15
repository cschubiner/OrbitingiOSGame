//
//  GameplayLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright Clayton Schubiner 2012. All rights reserved.

#import "GameplayLayer.h"
#import "CameraObject.h"
#import "Player.h"
#import "Planet.h"
#import "Asteroid.h"
#import "Zone.h"
#import "Constants.h"
#import "Coin.h"
#import "DataStorage.h"
#import "PlayerStats.h"
#import "Powerup.h"
#import "UpgradeItem.h"
#import "UpgradeManager.h"
#import "Toast.h"
#import "GKAchievementHandler.h"
#import "StoreLayer.h"
#import "MissionsCompleteLayer.h"

#define pauseLayerTag       100
#define gameOverLayerTag    200
#define LOADING_LAYER_TAG   212
#define LABEL_0_TAG 1219

@implementation GameplayLayer {
    int planetCounter;
    int score;
    int zonesReached;
    int prevCurrentPtoPScore;
    int initialScoreConstant;
    float killer;
    int startingCoins;
    BOOL paused;
    BOOL muted;
    BOOL scoreAlreadySaved;
    bool wasGoingClockwise;
    
    bool isInFeverMode;
    int feverModePlanetHitsInARow;
    float timeInOrbit;
    float timeDilationUponFeverEnter;
    CCLabelTTF* feverLabel;
    CCLayer* loadedPauseLayer;
    NSString *blankAvoiderName;
    BOOL isKeyboardShowing;
    
    BOOL pauseEnabled;
    int asteroidsCrashedInto;
    int asteroidsDestroyedWithArmor;
    int numTimesSwiped;
    int numTimesDied;
    
    CCLayer *layerToAdd;
    
    CCParticleSystemQuad * powerupParticle;
}


typedef struct {
    CGPoint velocity;
    CGPoint acceleration;
    CGPoint position;
} VelocityAccelerationPositionStruct;

// returns a singleton scene
+ (CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameplayLayer *layer = [GameplayLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene.
	return scene;
}


- (void)CreateCoin:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale {
    //NSLog(@"started coin");
    Coin *coin = [[Coin alloc]init];
    coin.sprite = [CCSprite spriteWithSpriteFrameName:@"15.png"];
    if ([[UpgradeValues sharedInstance] hasPinkStars])
        coin.sprite.color = ccc3(255, 20, 147);
    coin.sprite.position = ccp(xPos, yPos);
    [coin.sprite setScale:scale];
    coin.whichSegmentThisObjectIsOriginallyFrom = originalSegmentNumber;
    coin.segmentNumber = makingSegmentNumber;
    coin.number = coins.count;
    coin.whichGalaxyThisObjectBelongsTo  = currentGalaxy.number;
    [coin.sprite runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:coinAnimation]]];
    
    coin.movingSprite = [CCSprite spriteWithSpriteFrameName:@"25.png"];
    coin.movingSprite.scale = coin.sprite.scale*.3;
    [hudLayer addChild: coin.movingSprite];
    if ([[UpgradeValues sharedInstance] hasPinkStars])
        coin.movingSprite.color = ccc3(255, 20, 147);
    coin.movingSprite.position = ccp(-20, -20);
    
    [coins addObject:coin];
    //NSLog(@"adding coin");
    [spriteSheet addChild:coin.sprite];
    //[spriteSheet reorderChild:coin.sprite z:5];
    ////NSLog(@"ended coin");
    
}

- (void)CreatePowerup:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale type:(int)type {
    //NSLog(@"started powerup");
    
    Powerup *powerup = [[Powerup alloc]initWithType:type];
    
    powerup.sprite.position = ccp(xPos, yPos);
    powerup.sprite.scale = scale;
    
    [powerup.glowSprite setVisible:false];
    powerup.glowSprite.scale = 1;
    
    powerup.whichSegmentThisObjectIsOriginallyFrom = originalSegmentNumber;
    powerup.segmentNumber = makingSegmentNumber;
    powerup.number = powerups.count;
    powerup.whichGalaxyThisObjectBelongsTo = currentGalaxy.number;
    
    [powerups addObject:powerup];
    
    //NSLog(@"adding powerup");
    [spriteSheet addChild:powerup.sprite];
    //NSLog(@"adding powerup2");
    [spriteSheet addChild:powerup.glowSprite];
    powerup.glowSprite.scale = playerSizeScale;
    [powerup.glowSprite setZOrder:5];
    
    //NSLog(@"galaxy114powerup");
    //[spriteSheet reorderChild:powerup.glowSprite z:2.5];
    
    ////NSLog(@"ended powerup");
    
}

- (void) setGlow:(CCSprite*)sprite forHowLong:(float)secondsToGlow{
    [sprite setBlendFunc: (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
    [self schedule:@selector(restoreNormalStateOfSprite) interval:secondsToGlow];
}
//restore normal state.
- (void) restoreNormalStateOfSprite:(CCSprite*)sprite {
    [self unschedule:@selector(restoreNormalStateOfSprite)];
    [sprite setBlendFunc: (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA }];
}

- (void)CreateAsteroid:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale {
    //NSLog(@"started asteroid");
    
    //  [self setGlow];
    Asteroid *asteroid = [[Asteroid alloc]init];
    asteroid.sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"asteroid%d-%d.png",[self RandomBetween:1 maxvalue:3],currentGalaxy.number]];
    asteroid.sprite.position = ccp(xPos, yPos);
    [asteroid.sprite setScale:scale];
    asteroid.whichSegmentThisObjectIsOriginallyFrom = originalSegmentNumber;
    asteroid.segmentNumber = makingSegmentNumber;
    asteroid.number = asteroids.count;
    asteroid.whichGalaxyThisObjectBelongsTo = currentGalaxy.number;
    [asteroids addObject:asteroid];
    //NSLog(@"adding asteroid");
    [currentGalaxy.spriteSheet addChild:asteroid.sprite];
    //NSLog(@"ended asteroid");
}

- (void)CreatePlanetAndZone:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale {
    //NSLog(@"started planet and zone");
    Planet *planet = [[Planet alloc]init];
    planet.sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"planet%d-%d.png",[self RandomBetween:1 maxvalue:currentGalaxy.numberOfDifferentPlanetsDrawn],currentGalaxy.number]];
    planet.sprite.position = ccp(xPos, yPos);
    planet.sprite.rotation = [self randomValueBetween:-180 andValue:180];
    [planet.sprite setScale:scale];
    planet.mass = 1;
    planet.segmentNumber = makingSegmentNumber;
    planet.whichSegmentThisObjectIsOriginallyFrom = originalSegmentNumber;
    Zone *zone = [[Zone alloc]init];
    zone.sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"zone%d.png",currentGalaxy.number]];
    [zone.sprite setScale:scale*zoneScaleRelativeToPlanet];
    zone.sprite.position = planet.sprite.position;
    zone.segmentNumber = makingSegmentNumber;
    zone.whichSegmentThisObjectIsOriginallyFrom = originalSegmentNumber;
    planet.orbitRadius = zone.radius*zoneCollisionFactor;
    
    planet.whichGalaxyThisObjectBelongsTo = currentGalaxy.number;
    zone.whichGalaxyThisObjectBelongsTo = currentGalaxy.number;
    planet.number = [planets count];
    zone.number = [zones count];
    [planets addObject:planet];
    [zones addObject:zone];
    
    //NSLog(@"adding planet/zone");
    [currentGalaxy.spriteSheet addChild:planet.sprite];
    [currentGalaxy.spriteSheet addChild:zone.sprite];
    planetCounter++;
    ////NSLog(@"ended planet and zone");
}

-(CGPoint)getPositionBasedOnOrigin:(CGPoint)origin offset:(CGPoint)offset andAngle:(float)angle {
    return ccpRotateByAngle(ccp(offset.x+(origin).x,offset.y+(origin).y), origin, angle);
}

-(void)CreateCoinArrowAtPosition:(CGPoint)position withAngle:(float)angle {
    angle = CC_DEGREES_TO_RADIANS(angle);
    const int numCoins = 14;
    CGPoint coinPosArray[numCoins];
    coinPosArray[0]= ccp(44,0);
    coinPosArray[1]= ccp(89,0);
    coinPosArray[2]= ccp(130,0);
    coinPosArray[3]= ccp(173,0);
    coinPosArray[4]= ccp(217,0);
    coinPosArray[5]= ccp(260,0);
    coinPosArray[6]= ccp(303,0);
    coinPosArray[7]= ccp(266,53);
    coinPosArray[8]= ccp(233,92);
    coinPosArray[9]= ccp(266,-53);
    coinPosArray[10]= ccp(233,-92);
    coinPosArray[11]= ccp(201,-130);
    coinPosArray[12]= ccp(201,130);
    coinPosArray[13]= CGPointZero;
    
    for (int i = 0 ; i < numCoins; i++) {
        CGPoint positionForCoin = [self getPositionBasedOnOrigin:position offset:ccpMult(coinPosArray[i],generalScale) andAngle:angle];
        [self CreateCoin:positionForCoin.x yPos:positionForCoin.y scale:1];
    }
}

- (bool)CreateSegment
{
    float rotationOfSegment = CC_DEGREES_TO_RADIANS([self RandomBetween:-segmentRotationVariation+directionPlanetSegmentsGoIn maxvalue:segmentRotationVariation+directionPlanetSegmentsGoIn]);
    Galaxy *galaxy = currentGalaxy;
    int segNumber = [self RandomBetween:0 maxvalue:[[galaxy segments ]count]-1];
    NSArray *chosenSegment = [[galaxy segments] objectAtIndex:segNumber];
    
    int planetsInSegment = 0;
    bool canBeFlipped = true;
    for (int i = 0 ; i < [chosenSegment count]; i++) {
        LevelObjectReturner * returner = [chosenSegment objectAtIndex:i];
        if (returner.canBeFlipped==false)
            canBeFlipped = false;
        if (returner.type == kplanet)
            planetsInSegment++;
    }

    
    int futurePlanetCount = planetsHitSinceNewGalaxy + planetsInSegment;
    if (abs(currentGalaxy.optimalPlanetsInThisGalaxy-planetsHitSinceNewGalaxy)<abs(currentGalaxy.optimalPlanetsInThisGalaxy-futurePlanetCount))
        return false;
    
    originalSegmentNumber = segNumber;
    
    segmentsSpawnedFlurry++;
    
    int levelFlipper;
    if ([self RandomBetween:0 maxvalue:100]>50 && canBeFlipped) {
        levelFlipper = -1; //flip segment
    }
    else levelFlipper = 1; //don't flip segment
    
    for (int i = 0 ; i < [chosenSegment count]; i++) {
        LevelObjectReturner * returner = [chosenSegment objectAtIndex:i];
        CGPoint newPos = ccpRotateByAngle(ccp(returner.pos.x*generalScale+(indicatorPos).x,levelFlipper*returner.pos.y*generalScale+(indicatorPos).y), indicatorPos, rotationOfSegment);
        if (i == [chosenSegment count]-1) {
            indicatorPos = newPos;
            break;
        }
        
        if (returner.type == kplanet)
            [self CreatePlanetAndZone:newPos.x yPos:newPos.y scale:returner.scale];
        if (returner.type == kcoin)
            [self CreateCoin:newPos.x yPos:newPos.y scale:returner.scale];
        if (returner.type == kasteroid)
            [self CreateAsteroid:newPos.x yPos:newPos.y scale:returner.scale];
        if (returner.type == kpowerup)
            [self CreatePowerup:newPos.x yPos:newPos.y scale:powerupScaleSize type:returner.scale];
        
    }
    makingSegmentNumber++;
    return true;
}

- (void)CreateGalaxies // paste level creation code here
{
    galaxies = [[NSMutableArray alloc]initWithObjects:
#include "LevelsFromLevelCreator"
                nil];
}

- (void)setGalaxyProperties {
    
    float darkScaler = .35;
    
    Galaxy* galaxy;
    galaxy = [galaxies objectAtIndex:0];
    [galaxy setName:@"Galaxy 1"];
    [galaxy setNumberOfDifferentPlanetsDrawn:7];
    [galaxy setOptimalPlanetsInThisGalaxy:17];
    [galaxy setGalaxyColor: ccc3(45*darkScaler, 53*darkScaler, 147*darkScaler)]; //a dark blue
    
    galaxy = [galaxies objectAtIndex:1];
    [galaxy setName:@"Galaxy 2"];
    [galaxy setNumberOfDifferentPlanetsDrawn:3];
    [galaxy setOptimalPlanetsInThisGalaxy:21];
    [galaxy setGalaxyColor: ccc3(0, 103*darkScaler, 3*darkScaler)];
    
    galaxy = [galaxies objectAtIndex:2];
    [galaxy setName:@"Galaxy 3"];
    [galaxy setNumberOfDifferentPlanetsDrawn:3];
    [galaxy setOptimalPlanetsInThisGalaxy:26];
    [galaxy setGalaxyColor: ccc3(114*darkScaler, 0, 115*darkScaler)];
    
    galaxy = [galaxies objectAtIndex:3];
    [galaxy setName:@"Galaxy 4"];
    [galaxy setNumberOfDifferentPlanetsDrawn:1];
    [galaxy setOptimalPlanetsInThisGalaxy:33];
    [galaxy setGalaxyColor: ccc3(0, 130*darkScaler, 115*darkScaler)];
    
    galaxy = [galaxies objectAtIndex:4];
    [galaxy setName:@"Galaxy 5"];
    [galaxy setNumberOfDifferentPlanetsDrawn:1];
    [galaxy setOptimalPlanetsInThisGalaxy:36];
    [galaxy setGalaxyColor: ccc3(154*darkScaler, 86*darkScaler, 0)];
    
    galaxy = [galaxies objectAtIndex:5];
    [galaxy setName:@"Galaxy 6"];
    [galaxy setNumberOfDifferentPlanetsDrawn:2];
    [galaxy setOptimalPlanetsInThisGalaxy:40];
    [galaxy setGalaxyColor: ccc3(42*darkScaler, 112*darkScaler, 199*darkScaler)];
    
    galaxy = [galaxies objectAtIndex:6];
    [galaxy setName:@"Galaxy 7"];
    [galaxy setNumberOfDifferentPlanetsDrawn:3];
    [galaxy setOptimalPlanetsInThisGalaxy:43];
    [galaxy setGalaxyColor: ccc3(161*darkScaler, 163*darkScaler, 42*darkScaler)];
    
    galaxy = [galaxies objectAtIndex:7];
    [galaxy setName:@"Galaxy 8"];
    [galaxy setNumberOfDifferentPlanetsDrawn:3];
    [galaxy setOptimalPlanetsInThisGalaxy:43];
    [galaxy setGalaxyColor: ccc3(148*darkScaler, 74*darkScaler, 0*darkScaler)];
    
    galaxy = [galaxies objectAtIndex:8];
    [galaxy setName:@"Galaxy 9"];
    [galaxy setNumberOfDifferentPlanetsDrawn:3];
    [galaxy setOptimalPlanetsInThisGalaxy:43];
    [galaxy setGalaxyColor: ccc3(64, 104, 149)];
    
    galaxy = [galaxies objectAtIndex:9];
    [galaxy setName:@"Galaxy 10"];
    [galaxy setNumberOfDifferentPlanetsDrawn:3];
    [galaxy setOptimalPlanetsInThisGalaxy:43];
    [galaxy setGalaxyColor: ccc3(95*darkScaler, 95*darkScaler, 95*darkScaler)];
    
    float maxPercentTimeToAdd = .56;
    float minPercentTimeToAdd = .2434;
    int maxOptimalPlanets = 37;
    int minOptimalPlanets = 25;
    for (Galaxy* galaxy in galaxies) {
     //[galaxy setOptimalPlanetsInThisGalaxy:11];
        
        float galaxyPercent = ((float)galaxy.number)/((float)galaxies.count-1);
        [galaxy setOptimalPlanetsInThisGalaxy:lerpf(minOptimalPlanets, maxOptimalPlanets,galaxyPercent)];
    [galaxy setPercentTimeToAddUponGalaxyCompletion:lerpf(maxPercentTimeToAdd, minPercentTimeToAdd, galaxyPercent)];
   
    }
}

- (void)initUpgradedVariables {
    [[UpgradeValues sharedInstance] setCoinMagnetDuration:400 + 50*[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:0] equipped]];
    
    [[UpgradeValues sharedInstance] setAsteroidImmunityDuration:400 + 50*[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:1] equipped]];
    
    [[UpgradeValues sharedInstance] setAbsoluteMinTimeDilation:initialTimeDilation + .08*[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:2] equipped]];
    
    [[UpgradeValues sharedInstance] setHasDoubleCoins:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:3] equipped]];
    
    [[UpgradeValues sharedInstance] setMaxBatteryTime:70 + 5*[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:4] equipped]];
    
    [[UpgradeValues sharedInstance] setHasStarMagnet:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:5] equipped]];
    
    [[UpgradeValues sharedInstance] setHasAsteroidArmor:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:6] equipped]];
    
    [[UpgradeValues sharedInstance] setHasAutoPilot:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:7] equipped]];
    
    [[UpgradeValues sharedInstance] setHasStartPowerup:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:8] equipped]];
    
    [[UpgradeValues sharedInstance] setHasHeadStart:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:9] equipped]];
    
    [[UpgradeValues sharedInstance] setAutopilotDuration:5*60*1.3 + 50*[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:10] equipped]];
    
    [[UpgradeValues sharedInstance] setHasPinkStars:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:11] equipped]];
    
    [[UpgradeValues sharedInstance] setHasGreenShip:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:17] equipped]];
    
    [[UpgradeValues sharedInstance] setHasBlueShip:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:18] equipped]];
    
    [[UpgradeValues sharedInstance] setHasGoldShip:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:19] equipped]];
    
    [[UpgradeValues sharedInstance] setHasOrangeShip:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:20] equipped]];
    
    [[UpgradeValues sharedInstance] setHasRedShip:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:21] equipped]];
    
    [[UpgradeValues sharedInstance] setHasPurpleShip:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:22] equipped]];
    
    [[UpgradeValues sharedInstance] setHasPinkShip:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:23] equipped]];
    
    [[UpgradeValues sharedInstance] setHasGreenTrail:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:24] equipped]];
    
    [[UpgradeValues sharedInstance] setHasBlueTrail:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:25] equipped]];
    
    [[UpgradeValues sharedInstance] setHasGoldTrail:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:26] equipped]];
    
    [[UpgradeValues sharedInstance] setHasOrangeTrail:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:27] equipped]];
    
    [[UpgradeValues sharedInstance] setHasRedTrail:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:28] equipped]];
    
    [[UpgradeValues sharedInstance] setHasPurpleTrail:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:29] equipped]];
    
    [[UpgradeValues sharedInstance] setHasPinkTrail:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:30] equipped]];
    
    [[UpgradeValues sharedInstance] setHasBlackTrail:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:31] equipped]];
    
    [[UpgradeValues sharedInstance] setHasBrownTrail:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:32] equipped]];
}

- (void)startGame {
    [self addChild:cometParticle];
    [self addChild:backgroundSpriteSheet];
    [self addChild:cameraLayer];
    [self addChild:hudLayer];
    [self addChild:layerHudSlider];
    
    
    [self reorderChild:loadingLayer z:30];
    id removeLoadingLayer = [CCCallBlock actionWithBlock:(^{
        [self removeChild:loadingLayer cleanup:YES];
    })];
    
    float fadeOutDuration = 4;
    [loadingLabelHelperText2 runAction:[CCFadeOut actionWithDuration:fadeOutDuration*.5]];
    [loadingLabel runAction:[CCFadeOut actionWithDuration:fadeOutDuration*.5]];
    [loadingHelperTextLabel runAction:[CCFadeOut actionWithDuration:fadeOutDuration*.5]];
    [loadingDidYouKnowLabel runAction:[CCFadeOut actionWithDuration:fadeOutDuration*.5]];
    [loadingLayerBackground runAction:[CCSequence actions:
                                       [CCFadeOut actionWithDuration:fadeOutDuration],removeLoadingLayer, nil]];
    
    
    
    
    [self scheduleUpdates];
    [Kamcord startRecording];
}

- (void)loadEverything {
    [((AppDelegate*)[[UIApplication sharedApplication]delegate]) setGalaxyCounter:0];
    //isInTutorialMode = [((AppDelegate*)[[UIApplication sharedApplication]delegate]) getIsInTutorialMode];
    [self initUpgradedVariables];
    loadedPauseLayer = [self createPauseLayer];
    
    directionPlanetSegmentsGoIn = [self randomValueBetween:defaultDirectionPlanetSegmentsGoIn-directionPlanetSegmentsGoInVariance andValue:defaultDirectionPlanetSegmentsGoIn+directionPlanetSegmentsGoInVariance];
    
    [Kamcord prepareNextVideo];
    
    planetCounter = 0;
    planets = [[NSMutableArray alloc] init];
    asteroids = [[NSMutableArray alloc] init];
    zones = [[NSMutableArray alloc] init];
    powerups = [[NSMutableArray alloc] init];
    coins = [[NSMutableArray alloc] init];
    backgroundStars = [[NSMutableArray alloc]init];
    
    hudLayer = [[CCLayer alloc] init];
    cameraLayer = [[CCLayer alloc] init];
    [cameraLayer setAnchorPoint:CGPointZero];
    
    powerupParticle = [CCParticleSystemQuad particleWithFile:@"powerupGottenExplosionTexture.plist"];
    [powerupParticle stopSystem];
    [cameraLayer addChild:powerupParticle];
    [powerupParticle setZOrder:30];
    [powerupParticle setScale:1.2];
    
    feverModeInitialExplosionParticle = [CCParticleSystemQuad particleWithFile:@"feverModeInitialExplosion.plist"];
    [feverModeInitialExplosionParticle stopSystem];
    [feverModeInitialExplosionParticle setPositionType:kCCPositionTypeRelative];
    [cameraLayer addChild:feverModeInitialExplosionParticle z:28];
    [feverModeInitialExplosionParticle setScale:1];
    
    feverModeLabelParticle = [CCParticleSystemQuad particleWithFile:@"powerupGottenExplosionTexture.plist"];
    [feverModeLabelParticle stopSystem];
    [feverModeLabelParticle setPositionType:kCCPositionTypeRelative];
    [hudLayer addChild:feverModeLabelParticle z:28];
    [feverModeLabelParticle setScale:.5];
    
    
    starStashParticle = [CCParticleSystemQuad particleWithFile:@"starStashParticle.plist"];
    [starStashParticle stopSystem];
    
    cometParticle = [CCParticleSystemQuad particleWithFile:@"cometParticle.plist"];
    playerExplosionParticle = [CCParticleSystemQuad particleWithFile:@"playerExplosionParticle.plist"];
    [cameraLayer addChild:playerExplosionParticle];
    [playerExplosionParticle setVisible:false];
    [playerExplosionParticle stopSystem];
    
    playerSpawnedParticle = [CCParticleSystemQuad particleWithFile:@"playerSpawnedParticle.plist"];
    [hudLayer addChild:playerSpawnedParticle];
    [playerSpawnedParticle setVisible:false];
    [playerSpawnedParticle stopSystem];
    thrustParticle = [CCParticleSystemQuad particleWithFile:@"thrustParticle3.plist"];
    thrustBurstParticle = [CCParticleSystemQuad particleWithFile:@"thrustBurstParticle.plist"];
    [thrustBurstParticle stopSystem];
    
    CCSprite *pauseButton =  [CCSprite spriteWithFile:@"pauseButton7.png"];
    pauseButton.position = ccp(457, 298);
    [hudLayer addChild:pauseButton];
    
    powerupLabel = [CCLabelTTF labelWithString:@" " fontName:@"HelveticaNeue-CondensedBold" fontSize:44];
    powerupLabel.position = ccp(-[powerupLabel boundingBox].size.width/2, 160);
    [hudLayer addChild: powerupLabel];
    
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"bomb.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"SWOOSH.WAV"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"buttonpress.mp3"];
    
    
    
    backgroundSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"backgroundStars.pvr.ccz"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"backgroundStars.plist"];
    
    spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"generalSpritesheet.pvr.ccz"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"generalSpritesheet.plist"];
    
    coinAnimationFrames = [[NSMutableArray alloc]init];
    for (int i = 0; i <= 29; ++i) {
        [coinAnimationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%d.png", i]]];
    }
    coinAnimation = [[CCAnimation alloc ]initWithSpriteFrames:coinAnimationFrames delay:coinAnimationDelay];
    
    [self CreateGalaxies];
    currentGalaxy = [galaxies objectAtIndex:0];
    nextGalaxy = [galaxies objectAtIndex:1];
    [self setGalaxyProperties];
    indicatorPos = CGPointZero;
    for (int j = 0 ; j < numberOfSegmentsAtATime; j++) {
        [self CreateSegment];
    }
    
    player = [[Player alloc]init];
    //player.sprite = [CCSprite spriteWithSpriteFrameName:@"playercute.png"];
    
    if ([[UpgradeValues sharedInstance] hasGreenShip]) {
        player.sprite = [CCSprite spriteWithSpriteFrameName:@"playercamo.png"];
    } else {
        player.sprite = [CCSprite spriteWithSpriteFrameName:@"player.png"];
    }
    player.sprite.scale = playerSizeScale;
    [player.sprite setZOrder:4];
    
    player.alive=true;
    player.segmentNumber = -10;
    orbitState = 1;
    player.sprite.position = ccp(-750, -500);
    swipeVector = ccp(0, 1);
    targetPlanet = [planets objectAtIndex:0];
    // player.sprite.position = [self GetPositionForJumpingPlayerToPlanet:0];
    if ([[UpgradeValues sharedInstance] hasGreenShip]) {
        //player.sprite.color = ccGREEN;
    } else if ([[UpgradeValues sharedInstance] hasBlueShip]) {
        player.sprite.color = ccBLUE;
    } else if ([[UpgradeValues sharedInstance] hasGoldShip]) {
        player.sprite.color = ccYELLOW;
    } else if ([[UpgradeValues sharedInstance] hasOrangeShip]) {
        player.sprite.color = ccORANGE;
    } else if ([[UpgradeValues sharedInstance] hasRedShip]) {
        player.sprite.color = ccRED;
    } else if ([[UpgradeValues sharedInstance] hasPurpleShip]) {
        player.sprite.color = ccMAGENTA;
    } else if ([[UpgradeValues sharedInstance] hasPinkShip]) {
        player.sprite.color = ccc3(255, 20, 147);
    }
    
    
    CGPoint planPos = [[planets objectAtIndex:0] sprite].position;
    CGPoint pToUse = ccpAdd(planPos, ccp(0, [[planets objectAtIndex:0] orbitRadius])); //= ccpAdd(ccpMult(ccpNormalize(ccpSub(planPos, [[planets objectAtIndex:1] sprite].position)), -1*[[planets objectAtIndex:0] orbitRadius]), planPos);
    
    if ([[UpgradeValues sharedInstance] hasHeadStart])
        [self CreatePowerup:pToUse.x yPos:pToUse.y scale:1 type:kheadStart];
    else if ([[UpgradeValues sharedInstance] hasStartPowerup])
        [self CreatePowerup:pToUse.x yPos:pToUse.y scale:1 type:krandomPowerup];
    else if ([[UpgradeValues sharedInstance] hasStarMagnet])
        [self CreatePowerup:pToUse.x yPos:pToUse.y scale:1 type:kcoinMagnet];
    else if ([[UpgradeValues sharedInstance] hasAsteroidArmor])
        [self CreatePowerup:pToUse.x yPos:pToUse.y scale:1 type:kasteroidImmunity];
    else if ([[UpgradeValues sharedInstance] hasAutoPilot])
        [self CreatePowerup:pToUse.x yPos:pToUse.y scale:1 type:kautopilot];
    
    cameraDistToUse = 1005.14;
    [cameraLayer setScale:.43608];
    [cameraLayer setPosition:ccp(98.4779,67.6401)];
    cameraLastFocusPosition = ccp(325.808,213.3);
    [cameraFocusNode setPosition:ccp(142.078,93.0159)];
    galaxyLabel = [[CCLabelTTF alloc]initWithString:currentGalaxy.name fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
    [galaxyLabel setAnchorPoint:ccp(.5f,.5f)];
    [galaxyLabel setPosition:ccp(240,45)];
    
    id fadeAction = [CCFadeIn actionWithDuration:.8];
    id action2 = [CCSequence actions:[CCSpawn actions:fadeAction,[CCScaleTo actionWithDuration:.3 scale:1], nil], nil] ;
    id repeatAction = [CCRepeat actionWithAction:[CCSequence actions:[CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.8 scale:1.0f]],[CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.8 scale:1]], nil] times:2];
    galaxyLabelAction = [CCSequence actions:action2,repeatAction, [CCFadeOut actionWithDuration:.8],nil];
    [galaxyLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.1], galaxyLabelAction,nil]];
    justDisplayedGalaxyLabel = true;
    
    [hudLayer addChild:galaxyLabel];
    
    float streakWidth = streakWidthWITHOUTRetinaDisplay;
    if ([((AppDelegate*)[[UIApplication sharedApplication]delegate]) getIsRetinaDisplay])
        streakWidth = streakWidthOnRetinaDisplay;
    
    streak = [CCMotionStreak streakWithFade:2 minSeg:3 width:streakWidth color:ccWHITE textureFilename:@"streak2.png"];
    
    if ([[UpgradeValues sharedInstance] hasGreenTrail]) {
        streak.color = ccGREEN;
    } else if ([[UpgradeValues sharedInstance] hasBlueTrail]) {
        streak.color = ccBLUE;
    } else if ([[UpgradeValues sharedInstance] hasGoldTrail]) {
        streak.color = ccYELLOW;
    } else if ([[UpgradeValues sharedInstance] hasOrangeTrail]) {
        streak.color = ccORANGE;
    } else if ([[UpgradeValues sharedInstance] hasRedTrail]) {
        streak.color = ccRED;
    } else if ([[UpgradeValues sharedInstance] hasPurpleTrail]) {
        streak.color = ccMAGENTA;
    } else if ([[UpgradeValues sharedInstance] hasPinkTrail]) {
        streak.color = ccc3(255, 20, 147);
    } else if ([[UpgradeValues sharedInstance] hasBlackTrail]) {
        streak.color = ccBLACK;
    } else if ([[UpgradeValues sharedInstance] hasBrownTrail]) {
        streak.color = ccc3(139, 69, 19);
    }
    
    
    
    cameraFocusNode = [[CCNode alloc]init];
    //cameraFollowAction =  [CCFollow actionWithTarget:cameraFocusNode];
    
    killer = 0;
    //orbitState = 0; // 0 = orbiting, 1 = just left orbit and deciding things for state 3; 3 = flying to next planet
    velSoftener = 1;
    initialAccelMag = 0;
    isOnFirstRun = true;
    timeDilationCoefficient = [[UpgradeValues sharedInstance] absoluteMinTimeDilation];
    dangerLevel = 0;
    swipeVector = ccp(0, -1);
    gravIncreaser = 1;
    updatesSinceLastPlanet = 0;
    powerupCounter = 0;
    updatesWithoutBlinking = 0;
    updatesWithBlinking = 999;
    powerupPos = 0;
    powerupVel = 0;
    numCoinsDisplayed = 0;
    feverModePlanetHitsInARow = 0;
    timeInOrbit = 0;
    feverLabel = [CCLabelTTF labelWithString:@" " fontName:@"HelveticaNeue-CondensedBold" fontSize:30];
    [feverLabel setPosition:ccp(240, feverLabel.boundingBox.size.height*.6)];
    [hudLayer addChild:feverLabel];
    isInFeverMode = false;
    timeDilationUponFeverEnter = 1;
    hasOpenedTut = false;
    isDoingTutStuff = false;
    
    hasDiplayedArrowText = false;
    hasDiplayedCoinText = false;
    hasDiplayedBatteryText = false;
    
    asteroidsCrashedInto = 0;
    asteroidsDestroyedWithArmor = 0;
    numTimesSwiped = 0;
    numTimesDied = 0;
    
    backgroundClouds = [CCSprite spriteWithSpriteFrameName:@"backgroundClouds.png"];
    [backgroundClouds setPosition:ccp(size.width/2,size.height/2)];
    [backgroundClouds setColor:currentGalaxy.galaxyColor];
    [backgroundSpriteSheet addChild:backgroundClouds];
    
    int numStars = 74;
    int numSectors = 7;
    for (int i = 0 ; i <= numStars; i++) {
        int sector = i/(numStars/numSectors);
        if (sector == numSectors)
            sector = [self RandomBetween:0 maxvalue:numSectors-1];
        CCSprite * star = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"bstar%d-hd.png",i]];
        for (int j = 0 ; j < 4; j++) {
            [star setPosition:ccp([self randomValueBetween:(480*sector)/numSectors andValue:(480*(sector+1))/numSectors],[self randomValueBetween:0 andValue:320])];
            bool collidesWithOtherStar = false;
            for (CCSprite * star2 in backgroundStars) {
                if (CGRectContainsRect(star.boundingBox, star2.boundingBox)){
                    // [star setVisible:false];
                    collidesWithOtherStar = true;
                    break;
                }
            }
            if (collidesWithOtherStar ==false) {
                //NSLog(@"star pos: %f,%f between %d and %d",star.position.x,star.position.y,(480*(sector))/numSectors,(480*(sector+1))/numSectors);
                //NSLog(@"adding backroudnstars");
                [backgroundSpriteSheet addChild:star];
                [backgroundStars addObject:star];
            }
        }
        
    }
    
    
    cometParticle.position = ccp([self RandomBetween:0 maxvalue:390],325);
    cometVelocity = ccp([self RandomBetween:-10 maxvalue:10]/5,-[self RandomBetween:1 maxvalue:23]/5);
    [self resetVariablesForNewGame];
    
    light = [[Light alloc] init];
    
    light.sprite = [CCSprite spriteWithFile:@"OneByOne.png"];
    [light.sprite setPosition:CGPointZero];
    [light.sprite setColor:ccc3(0, 0, 0)]; //this makes the light black!
    
    light.hasPutOnLight = false;
    
    [cameraLayer addChild:currentGalaxy.spriteSheet];
    [cameraLayer addChild:spriteSheet];
    
    lastPlanetVisited = [planets objectAtIndex:0];
    layerHudSlider = (CCLayer*)[CCBReader nodeGraphFromFile:@"hudLayer.ccb" owner:self];
    float durationForScaling = .7;
    id scaleBiggerAction = [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:durationForScaling scale:.973]];
    id scaleSmallerAction = [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:durationForScaling scale:.858]];
    id sequenceAction = [CCRepeatForever actionWithAction:[CCSequence actions:scaleBiggerAction,[CCDelayTime actionWithDuration:.4],scaleSmallerAction,[CCDelayTime actionWithDuration:.2], nil]];
    batteryGlowScaleAction = [CCSpeed actionWithAction:sequenceAction speed:1];
    [batteryGlowSprite setScale:.873];
    
    [backgroundSpriteSheet setPosition:CGPointZero];
    [self UpdateScore];
    
    recentName = [[PlayerStats sharedInstance] recentName];
    playerNameLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [scoreLabel setVisible:false];
    [coinsLabel setVisible:false];
    [coinsLabelStarSprite setVisible:false];
    [zeroCoinsLabel setVisible:false];
    
    cameraShouldFocusOnPlayer = true;
    
    for (int i = 0 ; i < 7; i++) {
        [self UpdateCamera:-1.0/60.0f];
    }
    
    [Flurry logEvent:@"Played Game"timed:YES];
    [self scheduleOnce:@selector(startGame) delay:2.5];
}

/* On "init," initialize the instance */
- (id)init {
	// always call "super" init.
	// Apple recommends to re-assign "self" with the "super" return value
	if ((self = [super init])) {
        size = [[CCDirector sharedDirector] winSize];
        startingCoins = [[UserWallet sharedInstance] getBalance];
        self.isTouchEnabled= TRUE;
        
        loadingLayer = (CCLayer*)[CCBReader nodeGraphFromFile:@"LoadingLayerCCB.ccb" owner:self];
        
        NSArray * helperTextArray = [NSArray arrayWithObjects:
                                     @"Stars increase your score and let you buy upgrades in the store!",
                                     @"Aim your swipes - they determine the direction you'll move in.",
                                     @"Complete missions to earn more stars!",
                                     @"Orbit planets as briefly as you can to move as fast as possible.",
                                     @"Your time is limited; watch the battery in the lower-left corner of the screen.",
                                     @"Your battery recharges as you move between galaxies.",
                                     @"Try not orbiting planets at all - you'll start moving super quickly!",
                                     nil];
        
        [loadingHelperTextLabel setString:[helperTextArray objectAtIndex:[self RandomBetween:0 maxvalue:helperTextArray.count-1]]];
        
        [self addChild:loadingLayer z:0 tag:LOADING_LAYER_TAG];
        CGPoint startPosition = ccp(MAX(480-loadingHelperTextLabel.boundingBox.size.width+79,79),loadingHelperTextLabel.position.y);
        [loadingHelperTextLabel setPosition:startPosition];
        
        id moveLoadingLabelToStartPosition = [CCCallBlock actionWithBlock:(^{
            [loadingHelperTextLabel setPosition:startPosition];
        })];
        
        id repeatScrollingLeftAction = [CCCallBlock actionWithBlock:(^{
            [loadingHelperTextLabel runAction: [CCRepeatForever actionWithAction:[CCSequence actions:
                                                                                  [CCMoveTo actionWithDuration:loadingHelperLabelMoveTime*loadingHelperTextLabel.boundingBox.size.width/529.313538 position:ccp(-loadingHelperTextLabel.boundingBox.size.width-20,loadingHelperTextLabel.position.y)],
                                                                                  moveLoadingLabelToStartPosition,
                                                                                  nil]]];
        })];
        
        
        loadingLabelHelperText2 = [CCLabelTTF labelWithString:[helperTextArray objectAtIndex:[self RandomBetween:0 maxvalue:helperTextArray.count-1]] dimensions:CGSizeMake(size.width*.499999999999999999999999, 90) hAlignment:UITextAlignmentCenter vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
        
        loadingLabelHelperText2.position = ccp(size.width/2,size.height/2);
        [loadingLabelHelperText2 setAnchorPoint:ccp(.5,.5)];
        [loadingLayerBackground addChild:loadingLabelHelperText2];
        
        [loadingHelperTextLabel setOpacity:0];
        float fadeInTime = 1.4;
        id fadeInAction = [CCFadeIn actionWithDuration:fadeInTime];
        [loadingHelperTextLabel runAction:[CCSequence actions:[CCSpawn actions:fadeInAction,
                                                               [CCMoveBy actionWithDuration:fadeInTime position:ccp(-80*fadeInTime/4.0,0)],
                                                               nil],
                                           repeatScrollingLeftAction,
                                           nil]];
        
        
        [loadingLabel setString:@"loading..."];
        
        /*id loadingLabelSetOneZero = [CCCallBlock actionWithBlock:(^{
         [loadingLabel setString:@"loading..."];
         })];
         id loadingLabelSetTwoZeroes = [CCCallBlock actionWithBlock:(^{
         [loadingLabel setString:@"loading..."];
         })];
         id loadingLabelSetThreeZeros = [CCCallBlock actionWithBlock:(^{
         [loadingLabel setString:@"loading..."];
         })];
         
         id delayBetweenLoadingLabelsAction = [CCDelayTime actionWithDuration:1.2];
         [loadingLabel runAction:[CCRepeatForever actionWithAction:
         [CCSequence actions:loadingLabelSetOneZero,
         delayBetweenLoadingLabelsAction,
         loadingLabelSetTwoZeroes,
         delayBetweenLoadingLabelsAction,
         loadingLabelSetThreeZeros,
         delayBetweenLoadingLabelsAction, nil]]];*/
        
        
        [self scheduleOnce:@selector(loadEverything) delay:1.2];
        // [self loadEverything];
	}
	return self;
}

- (void)UpdateCamera:(float)dt {
    if (player.alive) {
        player.velocity = ccpAdd(player.velocity, player.acceleration);
        if (player.currentPowerup.type == kheadStart)
            player.velocity = ccpMult(player.velocity, 1.234);
        else if (player.currentPowerup.type == kautopilot)
            player.velocity = ccpMult(player.velocity, 1.1);
            
        player.sprite.position = ccpAdd(ccpMult(player.velocity, 60*dt*timeDilationCoefficient), player.sprite.position);
        [streak setPosition:player.sprite.position];
    }
    
    if (isnan(player.sprite.position.x)) {
        player.alive = true;
        player.velocity = CGPointZero;
        player.sprite.position = [self GetPositionForJumpingPlayerToPlanet:lastPlanetVisited.number];
        player.acceleration = CGPointZero;
    }
    
    //camera code follows -----------------------------
    Planet * nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number+1)];
    
    float firsttoplayer = ccpToAngle(ccpSub(lastPlanetVisited.sprite.position, player.sprite.position));
    float planetAngle = ccpToAngle(ccpSub(lastPlanetVisited.sprite.position, nextPlanet.sprite.position));

    float firstToPlayerAngle = firsttoplayer-planetAngle;
    float firstToPlayerDistance = ccpDistance(lastPlanetVisited.sprite.position, player.sprite.position)*cos(firstToPlayerAngle);
    float firsttonextDistance = ccpDistance(lastPlanetVisited.sprite.position, nextPlanet.sprite.position);
    float percentofthewaytonext = firstToPlayerDistance/firsttonextDistance;

    /*if (orbitState == 0) {
        if (percentofthewaytonext<lastPercentOfTheWayToNext)
        {
            if (percentToNextHasAlreadyBeenBelowZeroForThisPlanet)
                percentofthewaytonext = lastPercentOfTheWayToNext;
        }
        else
            percentToNextHasAlreadyBeenBelowZeroForThisPlanet = true;
        lastPercentOfTheWayToNext = percentofthewaytonext;
    }
    if (lastOrbitState != orbitState && orbitState == 0) {
        lastPercentOfTheWayToNext= .8;
        percentToNextHasAlreadyBeenBelowZeroForThisPlanet = false;
    }
    lastOrbitState = orbitState;*/
    
    Planet * planet1 = lastPlanetVisited;
    Planet * planet2 = nextPlanet;
    
    CGPoint focusPointOne = ccpAdd(ccpMult(ccpSub(planet2.sprite.position, planet1.sprite.position), percentofthewaytonext) ,planet1.sprite.position);
    planet1 = [planets objectAtIndex:lastPlanetVisited.number+2];
    planet2 = [planets objectAtIndex:lastPlanetVisited.number+3];
    CGPoint focusPointTwo = ccpAdd(ccpMult(ccpSub(planet2.sprite.position, planet1.sprite.position), percentofthewaytonext) ,planet1.sprite.position);
    
    if (orbitState == 0 )
        percentofthewaytonext *=.5;
        
    CGPoint planet01;
    CGPoint planet02;
    if (lastPlanetVisited.whichGalaxyThisObjectBelongsTo == nextPlanet.whichGalaxyThisObjectBelongsTo) {
        planet01 = lastPlanetVisited.sprite.position;
        planet02 = nextPlanet.sprite.position;
    }
    else {
        planet01 = player.sprite.position;
        planet02 = ccpAdd(planet01,ccp(-100,-100));
    }
    CGPoint planet03;
    if (planet1.whichGalaxyThisObjectBelongsTo == lastPlanetVisited.whichGalaxyThisObjectBelongsTo)
        planet03= ((Planet*)[planets objectAtIndex:lastPlanetVisited.number+2]).sprite.position;
    else
        planet03 = ccpAdd(planet02, ccpMult(ccpNormalize(ccpForAngle(defaultDirectionPlanetSegmentsGoIn)), 400));

    CGPoint planet04;
    if (planet2.whichGalaxyThisObjectBelongsTo == lastPlanetVisited.whichGalaxyThisObjectBelongsTo)
        planet04 = ((Planet*)[planets objectAtIndex:lastPlanetVisited.number+3]).sprite.position;
    else
        planet04 = ccpAdd(planet03, ccpMult(ccpNormalize(ccpForAngle(defaultDirectionPlanetSegmentsGoIn)), 400));
    
    CGPoint focusPoint = ccpMult(planet01,2-percentofthewaytonext);
    focusPoint = ccpAdd(focusPoint, planet02);
    focusPoint = ccpAdd(focusPoint, planet03);
    focusPoint = ccpAdd(focusPoint, ccpMult(planet04, percentofthewaytonext));
    focusPoint = ccpMult(focusPoint, .25f);
    
    float centerToPlanet1 = ccpDistance(planet01, focusPoint)+lastPlanetVisited.orbitRadius*2.25;
    float centerToPlanet3 = ccpDistance(focusPoint, planet03)-lastPlanetVisited.orbitRadius*.33;
    cameraDistToUse = lerpf(cameraDistToUse, MAX(centerToPlanet1,centerToPlanet3),cameraZoomSpeed);
    
    float horizontalScale = 294.388933833*pow(cameraDistToUse,-1);
    float newAng = CC_RADIANS_TO_DEGREES(fabs(ccpToAngle(ccpSub(focusPointTwo, focusPointOne))));
    if (newAng > 270)
        newAng = 360 - newAng;
    if (newAng > 180)
        newAng = newAng - 180;
    if (newAng > 90)
        newAng = 180 - newAng;
    float numerator;
    if (newAng < 35)
        numerator = 240-(3.1/10)*newAng+(4.6/100)*powf(newAng, 2);
    else numerator = 499-8.1*newAng + (4.9/100)*powf(newAng, 2);
    float scalerToUse = numerator/240; //CCLOG(@"num: %f, newAng: %f", numerator, newAng);
    
    float scale = horizontalScale*scalerToUse;//*zoomMultiplier;
    scale = clampf(scale, .15, 1.4);
    
  //  if (fabsf(scale-cameraLayer.scale)<.06) //jerky camera scaling
    //    scale = cameraLayer.scale;
    //else scale = lerpf(cameraLayer.scale, scale, .1);
    

    cameraLayerLastPosition = cameraLastFocusPosition;
    cameraLastFocusPosition = ccpLerp(cameraLastFocusPosition, focusPoint, cameraMovementSpeed);
    [self scaleLayer:cameraLayer scaleToZoomTo:lerpf(cameraLayer.scale, scale, cameraZoomSpeed*.3) scaleCenter:cameraLastFocusPosition];
    [cameraLayer runAction: [CCFollow actionWithTarget:cameraFocusNode]];
}

- (void) scaleLayer:(CCLayer*)layerToScale scaleToZoomTo:(CGFloat) newScale scaleCenter:(CGPoint) scaleCenter {
    // Get the original center point.
    CGPoint oldCenterPoint = ccp(scaleCenter.x * layerToScale.scaleX, scaleCenter.y * layerToScale.scaleY);
    // Set the scale.
    layerToScale.scale = newScale;
    // Get the new center point.
    CGPoint newCenterPoint = ccp(scaleCenter.x * layerToScale.scaleX, scaleCenter.y * layerToScale.scaleY);
    cameraFocusNode.position = newCenterPoint;
    // Then calculate the delta.
    CGPoint centerPointDelta  = ccpSub(oldCenterPoint, newCenterPoint);
    // Now adjust layer by the delta.
    layerToScale.position = ccpAdd(layerToScale.position, centerPointDelta);
}

-(bool)checkShouldDisplayTextForVar:(bool)varToCheck {
    int numTimesPlayed = [[PlayerStats sharedInstance] getPlays];
    if (numTimesPlayed <= 99999 && !varToCheck) //change 999 to 1
        return true;
    else
        return false;
}

- (void)UserTouchedCoin: (Coin*)coin dt:(float)dt{
    
    if (numTimesSwiped != 0) {
        if ([self checkShouldDisplayTextForVar:hasDiplayedCoinText]) {
            [self pauseWithDuration:5.5 message:@"You just picked up a star! Stars increase your score and you can use them in the shop to buy awesome new spaceships, upgrades, perks, and more!"];
            hasDiplayedCoinText = true;
        }
    }
    
    [[UserWallet sharedInstance] addCoins: ([[UpgradeValues sharedInstance] hasDoubleCoins] ? 2 : 1) ];
    score += howMuchCoinsAddToScore*([[UpgradeValues sharedInstance] hasDoubleCoins] ? 2 : 1);
    
    CGPoint coinPosOnHud = [cameraLayer convertToWorldSpace:coin.sprite.position];
    coin.movingSprite.position = ccp(coinPosOnHud.x+4, coinPosOnHud.y-4);
    
    coin.movingSprite.scale *= 1.0f/generalScale;
    [coin.movingSprite runAction:[CCSequence actions:
                                  [CCSpawn actions:[CCAnimate actionWithAnimation:coinAnimation],
                                   [CCSequence actions:[CCMoveTo actionWithDuration:.28 position:coinsLabel.position],[CCHide action],nil], nil],
                                  [CCHide action],
                                  [CCCallFunc actionWithTarget:self selector:@selector(coinDone)],
                                  nil]];
    
    //id scaleAction = [CCScaleTo actionWithDuration:.1 scale:.2*coin.sprite.scale];
    // [coin.sprite runAction:[CCSequence actions:[CCSpawn actions:scaleAction,[CCRotateBy actionWithDuration:.1 angle:360], nil],[CCHide action], nil]];
    [coin.sprite setVisible:false];
    [spriteSheet removeChild:coin.sprite cleanup:YES];
    coin.isAlive = false;
    if (timeSinceGotLastCoin<.4){
        lastCoinPitch +=.1;
    }
    else lastCoinPitch = 0;
    timeSinceGotLastCoin = 0;
    if (lastCoinSoundID!=0)
        [[SimpleAudioEngine sharedEngine]stopEffect:lastCoinSoundID];
    lastCoinSoundID = [self playSound:@"buttonpress.mp3" shouldLoop:false pitch:1.1+lastCoinPitch];
}

- (void)coinDone {
    
    numCoinsDisplayed += ([[UpgradeValues sharedInstance] hasDoubleCoins] ? 2 : 1);
    
    if (numCoinsDisplayed<10)
        [zeroCoinsLabel setString:@"00"];
    else
        if (numCoinsDisplayed<100)
            [zeroCoinsLabel setString:@"0"];
        else
            [zeroCoinsLabel setVisible:false];
    [coinsLabel setString:[NSString stringWithFormat:@"%d",numCoinsDisplayed]];
    
    [coinsLabel runAction:[CCSequence actions:
                           [CCScaleTo actionWithDuration:.03 scale:1.4],
                           [CCScaleTo actionWithDuration:.03 scale:1],
                           nil]];
    
    
}

-(void)completeObjectiveFromGroupNumber:(int)a_groupNumber itemNumber:(int)a_itemNumber {
    [[ObjectiveManager sharedInstance] completeObjectiveFromGroupNumber:a_groupNumber itemNumber:a_itemNumber view:self];
}

- (ALuint)playSound:(NSString*)soundFile shouldLoop:(bool)shouldLoop pitch:(float)pitch{
    [Kamcord playSound:soundFile loop:shouldLoop];
    if (shouldLoop)
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:soundFile loop:YES];
    else
        return [[SimpleAudioEngine sharedEngine]playEffect:soundFile pitch:pitch pan:0 gain:1];
    return 0;
}

- (void)ApplyGravity:(float)dt {
    
    //NSLog(@"how many %d", feverModePlanetHitsInARow);
    
    for (Coin* coin in coins) {
        
        CGPoint p = coin.sprite.position;
        coin.velocity = ccpMult(ccpNormalize(ccpSub(player.sprite.position, p)), coin.speed);
        if (coin.isAlive)
            coin.sprite.position = ccpAdd(coin.sprite.position, coin.velocity);
        
        if (ccpLength(ccpSub(player.sprite.position, p)) <= coin.radius + player.sprite.height/1.9 && coin.isAlive) {
            [self UserTouchedCoin:coin dt:dt];
        }
    }
    
    //bool isHittingAsteroid = false;
    if (!(player.currentPowerup.type == kautopilot || player.currentPowerup.type == kheadStart))
        for (Asteroid* asteroid in asteroids) {
            CGPoint p = asteroid.sprite.position;
            if (player.alive && ccpLength(ccpSub(player.sprite.position, p)) <= asteroid.radius * asteroidRadiusCollisionZone && asteroid.sprite.visible) {
                if (orbitState == 3 || player.currentPowerup.type == kasteroidImmunity) {
                    for (Asteroid* a in asteroids) {
                        if (ccpDistance(p, a.sprite.position) <= 100) {
                            [a.sprite setVisible:false];
                            if (player.currentPowerup.type == kasteroidImmunity)
                                asteroidsDestroyedWithArmor++;
                        }
                    }
                    if (!(player.currentPowerup.type == kasteroidImmunity)) {
                        asteroidsCrashedInto++;
                        [self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number asteroidHit:asteroid];
                    }
                }
            }
        }
    
    if (!(player.currentPowerup.type == kautopilot || player.currentPowerup.type == kheadStart))
        for (Powerup* powerup in powerups) {
            CGPoint p = powerup.sprite.position;
            if (player.alive && ccpLength(ccpSub(player.sprite.position, p)) <= powerup.sprite.width * .5 * powerupRadiusCollisionZone) {
                if (powerup.sprite.visible) {
                    [powerup.sprite setVisible:false];
                    if (player.currentPowerup != nil) {
                        [player.currentPowerup.glowSprite setVisible:false];
                    }
                    paused = true;
                    isDisplayingPowerupAnimation = true;
                    powerupPos = 0;
                    powerupVel = 0;
                    player.currentPowerup = powerup;
                    [player.currentPowerup.glowSprite setVisible:true];
                    powerupCounter = 0;
                    updatesWithBlinking = 0;
                    updatesWithoutBlinking = 99999;
                    
                    
                    [powerupParticle setPosition:player.sprite.position];
                    [powerupParticle resetSystem];
                    
                }
            }
        }
    
    if (player.currentPowerup != nil) {
        
        int updatesLeft = player.currentPowerup.duration - powerupCounter;
        float blinkAfterThisManyUpdates = updatesLeft*.06;
        
        if (player.currentPowerup.glowSprite.visible) {
            updatesWithoutBlinking++;
        }
        
        if (updatesWithoutBlinking >= blinkAfterThisManyUpdates && updatesLeft <= 90) {
            updatesWithoutBlinking = 0;
            [player.currentPowerup.glowSprite setVisible:false];
            
        }
        if (!player.currentPowerup.glowSprite.visible) {
            updatesWithBlinking++;
        }
        
        if (updatesWithBlinking >= clampf(4*updatesLeft/100, 3, 99999999)) {
            updatesWithBlinking = 0;
            [player.currentPowerup.glowSprite setVisible:true];
        }
        
        if (powerupCounter >= player.currentPowerup.duration) {
            [player.currentPowerup.glowSprite setVisible:false];
            player.currentPowerup = nil;
        }
    }
    powerupCounter++;
    
    for (Planet* planet in planets)
    {
        if (planet.number < lastPlanetVisited.number - 1)
            continue;
        
        if (planet.number == lastPlanetVisited.number) {
            if (isOnFirstRun) {
                
                [self playSound:@"kick_shock.mp3" shouldLoop:YES pitch:1];
                initialVel = ccp(0, sqrtf(planet.orbitRadius*gravity));
                isOnFirstRun = false;
                player.velocity = initialVel;
            }
            
            if (orbitState == 0) {
                if (!loading_playerHasReachedFirstPlanet) {
                    
                    dangerLevel = 0;
                    
                    CGPoint a = ccpSub(player.sprite.position, planet.sprite.position);
                    
                    player.sprite.position = ccpAdd(player.sprite.position, ccpMult(ccpNormalize(a), (planet.orbitRadius*.0 - ccpLength(a))*howFastOrbitPositionGetsFixed*timeDilationCoefficient*60*dt/[[UpgradeValues sharedInstance] absoluteMinTimeDilation]));
                    [streak setPosition:player.sprite.position];
                    
                    //CGPoint hi = ccpAdd(player.sprite.position,ccpMult(ccpNormalize(a), (planet.orbitRadius*.0 - ccpLength(a))*howFastOrbitPositionGetsFixed*timeDilationCoefficient*60*dt/[[UpgradeValues sharedInstance] absoluteMinTimeDilation]));
                    
                    //hi = ccpMult(a, -1*.1);
                    
                    //player.velocity = ccpAdd(player.velocity, hi);
                    
                    velSoftener += 1/updatesToMakeOrbitVelocityPerfect*60*dt;
                    velSoftener = clampf(velSoftener, 0, 1);
                    
                    CGPoint dir2 = ccpNormalize(CGPointApplyAffineTransform(a, CGAffineTransformMakeRotation(M_PI/2)));
                    CGPoint dir3 = ccpNormalize(CGPointApplyAffineTransform(a, CGAffineTransformMakeRotation(-M_PI/2)));
                    if (ccpLength(ccpSub(ccpAdd(a, dir2), ccpAdd(a, player.velocity))) < ccpLength(ccpSub(ccpAdd(a, dir3), ccpAdd(a, player.velocity)))) { //up is closer
                        player.velocity = ccpAdd(ccpMult(player.velocity, (1-velSoftener)*1), ccpMult(dir2, velSoftener*ccpLength(initialVel)));
                        
                    }
                    else {
                        player.velocity = ccpAdd(ccpMult(player.velocity, (1-velSoftener)*1), ccpMult(dir3, velSoftener*ccpLength(initialVel)));
                    }
                    
                } else {
                    dangerLevel = 0;
                    CGPoint a = ccpSub(player.sprite.position, planet.sprite.position);
                    if (ccpLength(a) != planet.orbitRadius) {
                        player.sprite.position = ccpAdd(player.sprite.position, ccpMult(ccpNormalize(a), (planet.orbitRadius - ccpLength(a))*howFastOrbitPositionGetsFixed*timeDilationCoefficient*60*dt/[[UpgradeValues sharedInstance] absoluteMinTimeDilation]));
                    }
                    [streak setPosition:player.sprite.position];
                    
                    //CGPoint hi = ccpMult(a, -1*.002);
                    
                    //player.velocity = ccpAdd(player.velocity, hi);
                    
                    velSoftener += 1/updatesToMakeOrbitVelocityPerfect*60*dt;
                    velSoftener = clampf(velSoftener, 0, 1);
                    
                    CGPoint dir2 = ccpNormalize(CGPointApplyAffineTransform(a, CGAffineTransformMakeRotation(M_PI/2)));
                    CGPoint dir3 = ccpNormalize(CGPointApplyAffineTransform(a, CGAffineTransformMakeRotation(-M_PI/2)));
                    if (ccpLength(ccpSub(ccpAdd(a, dir2), ccpAdd(a, player.velocity))) < ccpLength(ccpSub(ccpAdd(a, dir3), ccpAdd(a, player.velocity)))) { //up is closer
                        player.velocity = ccpAdd(ccpMult(player.velocity, (1-velSoftener)*1), ccpMult(dir2, velSoftener*ccpLength(initialVel)));
                        wasGoingClockwise = false;
                        
                    }
                    else {
                        player.velocity = ccpAdd(ccpMult(player.velocity, (1-velSoftener)*1), ccpMult(dir3, velSoftener*ccpLength(initialVel)));
                        wasGoingClockwise = true;
                    }
                    
                    
                    //NSLog(@"feverModePlanetHitsInARow: %i, timeInOrbit: %f", feverModePlanetHitsInARow, timeInOrbit);
                    
                    timeInOrbit += dt;
                    
                    if (timeInOrbit > maxTimeInOrbitThatCountsAsGoodSwipe) {
                        [self endFeverMode];
                    }
                    
                    CGPoint direction = ccpNormalize(ccpSub(planet.sprite.position, player.sprite.position));
                    player.acceleration = ccpMult(direction, gravity);
                    
                    if (player.currentPowerup.type == kautopilot || player.currentPowerup.type == kheadStart) {
                        [self JustSwiped];
                    }
                }
            }
            else
                if (orbitState == 1) {
                    velSoftener = 0;
                    gravIncreaser = 1;
                    if (loading_playerHasReachedFirstPlanet)
                        [self playSound:@"SWOOSH.WAV" shouldLoop:false pitch:1];
                    player.acceleration = CGPointZero;
                    
                    CGPoint d = ccpSub(targetPlanet.sprite.position, player.sprite.position);
                    CGPoint d2 = ccpSub(targetPlanet.sprite.position, planet.sprite.position);
                    
                    CGPoint dir2 = ccpNormalize(CGPointApplyAffineTransform(d, CGAffineTransformMakeRotation(M_PI/2)));
                    CGPoint dir3 = ccpNormalize(CGPointApplyAffineTransform(d, CGAffineTransformMakeRotation(-M_PI/2)));
                    CGPoint dir4 = ccpNormalize(CGPointApplyAffineTransform(d2, CGAffineTransformMakeRotation(M_PI/2)));
                    CGPoint dir5 = ccpNormalize(CGPointApplyAffineTransform(d2, CGAffineTransformMakeRotation(-M_PI/2)));
                    
                    
                    CGPoint left = ccpAdd(ccpMult(dir2, targetPlanet.orbitRadius), targetPlanet.sprite.position);
                    CGPoint right = ccpAdd(ccpMult(dir3, targetPlanet.orbitRadius), targetPlanet.sprite.position);
                    CGPoint spot1 = ccpAdd(dir4, planet.sprite.position);
                    CGPoint spot2 = ccpAdd(dir5, planet.sprite.position);
                    
                    float howMuchOfSwipeVectorToUse = .45;
                    CGPoint vectorToCheck = ccpAdd(ccpMult(ccpNormalize(swipeVector), howMuchOfSwipeVectorToUse), ccpMult(ccpNormalize(player.velocity), 1-howMuchOfSwipeVectorToUse));
                    
                    CGPoint targetForPred;
                    
                    float newAng = 0;
                    //CGPoint vel = CGPointZero;
                    if (ccpLength(ccpSub(ccpAdd(player.sprite.position, vectorToCheck), left)) <= ccpLength(ccpSub(ccpAdd(player.sprite.position, vectorToCheck), right))) { //closer to the left
                        float distToUse2 = factorToPlaceGravFieldWhenCrossingOverTheMiddle; //crossing over the middle
                        if (ccpLength(ccpSub(player.sprite.position, spot1)) < ccpLength(ccpSub(player.sprite.position, spot2)))
                            distToUse2 = factorToPlaceGravFieldWhenStayingOutside; //staying outside
                        spotGoingTo = ccpAdd(ccpMult(dir2, targetPlanet.orbitRadius*distToUse2), targetPlanet.sprite.position);
                        targetForPred = ccpAdd(ccpMult(dir2, targetPlanet.orbitRadius), targetPlanet.sprite.position);
                        newAng = ccpToAngle(ccpSub(left, player.sprite.position));
                        //vel = ccpSub(left, player.sprite.position);
                    }
                    else {
                        float distToUse2 = factorToPlaceGravFieldWhenCrossingOverTheMiddle; //crossing over the middle
                        if (ccpLength(ccpSub(player.sprite.position, spot1)) > ccpLength(ccpSub(player.sprite.position, spot2)))
                            distToUse2 = factorToPlaceGravFieldWhenStayingOutside; //staying outside
                        spotGoingTo = ccpAdd(ccpMult(dir3, targetPlanet.orbitRadius*distToUse2), targetPlanet.sprite.position);
                        targetForPred = ccpAdd(ccpMult(dir3, targetPlanet.orbitRadius), targetPlanet.sprite.position);
                        newAng = ccpToAngle(ccpSub(right, player.sprite.position));
                        //vel = ccpSub(right, player.sprite.position);
                    }
                    
                    if (loading_playerHasReachedFirstPlanet) {
                        if (!(player.currentPowerup.type == kautopilot || player.currentPowerup.type == kheadStart)) {
                            if (isLeavingLastPlanetInGalaxy)
                                [self removeOldPredLine];
                            else {
                                [self createPredPointsFrom:player.sprite.position to:targetForPred withColor:ccWHITE andRemoveOldLine:true];
                                
                                if ([self checkShouldDisplayTextForVar:hasDiplayedArrowText]) {
                                    [self pauseWithDuration:6 message:@"See that arrow that just popped up? It's telling you which side of the planet you swiped towards. You'll fly towards whichever side it points to."];
                                    hasDiplayedArrowText = true;
                                }
                                
                                
                            }
                        }
                    }
                    
                    
                    
                    float curAng = ccpToAngle(player.velocity);
                    swipeAccuracy = fabsf(CC_RADIANS_TO_DEGREES(curAng) - CC_RADIANS_TO_DEGREES(newAng));;
                    
                    if (swipeAccuracy > 180)
                        swipeAccuracy = 360 - swipeAccuracy;
                    
                    orbitState = 3;
                    initialAccelMag = 0;
                    
                    if (timeInOrbit <= maxTimeInOrbitThatCountsAsGoodSwipe)
                        feverModePlanetHitsInARow++;
                    else
                        [self endFeverMode];
                    
                    timeInOrbit = 0;
                    
                    
                    
                    if (player.currentPowerup.type == kautopilot || player.currentPowerup.type == kheadStart) {
                        CGPoint targetPoint1 = ccpAdd(ccpMult(dir2, targetPlanet.orbitRadius*.7), targetPlanet.sprite.position);
                        CGPoint targetPoint2 = ccpAdd(ccpMult(dir3, targetPlanet.orbitRadius*.7), targetPlanet.sprite.position);
                        
                        if (ccpLengthSQ(ccpSub(ccpSub(targetPoint1, player.sprite.position), player.velocity))<ccpLengthSQ(ccpSub(ccpSub(targetPoint2, player.sprite.position), player.velocity)))
                            spotGoingTo = targetPoint1;
                        else
                            spotGoingTo = targetPoint2;
                    }
                }
            
            if (orbitState == 3) {
                gravIncreaser += increaseGravStrengthByThisMuchEveryUpdate*60*dt;
                
                //Danger Level Code
                CGPoint playerToTarget = ccpSub(targetPlanet.sprite.position, player.sprite.position);
                float anglePlayToTarg = ccpToAngle(playerToTarget);
                
                if (ccpLength(playerToTarget) > ccpLength(ccpAdd(playerToTarget, player.velocity)))
                {
                    if (ccpToAngle(player.velocity) > (anglePlayToTarg + (80 * M_PI/180)) || ccpToAngle(player.velocity) < (anglePlayToTarg - (80 * M_PI/180)))
                    {
                        dangerLevel += .015;
                    }
                }
                
                CGPoint accelToAdd = CGPointZero;
                CGPoint direction = ccpNormalize(ccpSub(spotGoingTo, player.sprite.position));
                accelToAdd = ccpAdd(accelToAdd, ccpMult(direction, gravity));
                
                player.velocity = ccpMult(ccpNormalize(player.velocity), ccpLength(initialVel));
                
                float scaler = multiplyGravityThisManyTimesOnPerfectSwipe - swipeAccuracy * multiplyGravityThisManyTimesOnPerfectSwipe / 180;
                scaler = clampf(scaler, 0, 99999999);
                
                player.acceleration = ccpMult(accelToAdd, [[UpgradeValues sharedInstance] absoluteMinTimeDilation]*1.11*timeDilationCoefficient*gravIncreaser*freeGravityStrength*scaler*60*dt);
                if (player.currentPowerup.type == kheadStart)
                    player.acceleration = ccpMult(player.acceleration, 9);
                else if (player.currentPowerup.type == kautopilot)
                    player.acceleration = ccpMult(player.acceleration, 2);
                
                if (initialAccelMag == 0)
                    initialAccelMag = ccpLength(player.acceleration);
                
                player.acceleration = ccpMult(ccpNormalize(player.acceleration), initialAccelMag);
            }
            
            if (ccpLength(ccpSub(player.sprite.position, targetPlanet.sprite.position)) <= targetPlanet.orbitRadius) {
                orbitState = 0;
            }
        }
        
        if (!(player.currentPowerup.type == kautopilot || player.currentPowerup.type == kheadStart))
            if (ccpLength(ccpSub(player.sprite.position, planet.sprite.position)) <= planet.radius * planetRadiusCollisionZone && planet.number >= lastPlanetVisited.number) {
                [self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number asteroidHit:Nil];
            }
        
        if (!(player.currentPowerup.type == kautopilot || player.currentPowerup.type == kheadStart))
            if (dangerLevel >= 1) {
                dangerLevel = 0;
                [self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number asteroidHit:Nil];
            }
        
        if (planet.number >lastPlanetVisited.number+2)
            break;
    }
}

- (void)KillIfEnoughTimeHasPassed {
    killer++;
    if (orbitState == 0 || orbitState == 2)
        killer = 0;
    if (!(player.currentPowerup.type == kautopilot || player.currentPowerup.type == kheadStart))
        if (killer > deathAfterThisLong)
            [self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number asteroidHit:Nil];
}

- (void)endFeverMode {
    if (isInFeverMode) {
        
        
        if (player.currentPowerup.type != kheadStart) {
            timeDilationCoefficient = clampf(timeDilationUponFeverEnter, [[UpgradeValues sharedInstance] absoluteMinTimeDilation], absoluteMaxTimeDilation);
        }
        
        [self playSound:@"endFeverMode.mp3" shouldLoop:false pitch:1];
        [thrustParticle setEmissionRate:20];
        
        
        [feverLabel runAction:[CCSequence actions:
                               [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.1 scale:1.2]],
                               [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.2 scale:.6]],
                               [CCFadeTo actionWithDuration:1.5 opacity:0],
                               [CCCallBlock actionWithBlock:(^{
            [feverLabel setString:[NSString stringWithFormat:@""]];
            [feverLabel setOpacity:255];
        })],
                               
                               nil]
         ];
        
    }
    isInFeverMode = false;
    feverModePlanetHitsInARow = 0;
}

// FIX you don't really need planetIndex passed in because it's just going to spawn at the position of the last thrust point anyway
- (void)RespawnPlayerAtPlanetIndex:(int)planetIndex asteroidHit:(Asteroid*)asteroidHit {
    numTimesDied++;
    lastPercentOfTheWayToNext= -.3;
    percentToNextHasAlreadyBeenBelowZeroForThisPlanet = false;
    [self endFeverMode];
    
    timeDilationCoefficient *= factorToScaleTimeDilationByOnDeath;
    numZonesHitInARow = 0;
    orbitState = 0;
    
    [playerExplosionParticle resetSystem];
    [playerExplosionParticle setPosition:player.sprite.position];
    if (asteroidHit)
        [playerExplosionParticle setPosition:asteroidHit.sprite.position];
    [playerExplosionParticle setPositionType:kCCPositionTypeGrouped];
    [playerExplosionParticle setVisible:true];
    
    CGPoint curPlanetPos = lastPlanetVisited.sprite.position;
    CGPoint nextPlanetPos = [[[planets objectAtIndex:(lastPlanetVisited.number+1)] sprite] position];
    CGPoint pToGoTo = ccpAdd(curPlanetPos, ccpMult(ccpNormalize(ccpSub(nextPlanetPos, curPlanetPos)), -lastPlanetVisited.orbitRadius));
    
    
    CGPoint vel = ccpSub(pToGoTo, curPlanetPos);
    if (wasGoingClockwise)
        vel = CGPointApplyAffineTransform(vel, CGAffineTransformMakeRotation(-M_PI/2));
    else
        vel = CGPointApplyAffineTransform(vel, CGAffineTransformMakeRotation(M_PI/2));
    player.sprite.visible = false;
    if (player.currentPowerup)
        player.currentPowerup.glowSprite.visible = false;
    
    id moveAction = [CCMoveTo actionWithDuration:.2 position:pToGoTo];
    id blink = [CCBlink actionWithDuration:delayTimeAfterPlayerExplodes-.2 blinks:(delayTimeAfterPlayerExplodes-.2)*respawnBlinkFrequency];
    id movingSpawnActions = [CCSpawn actions:moveAction, /*[CCRotateTo actionWithDuration:.2 angle:ccpToAngle(vel)],*/ nil];
    player.moveAction = [CCSequence actions:[CCHide action],movingSpawnActions,blink, [CCShow action], nil];
    
    
    
    //if (player.currentPowerup)
    //    [player.currentPowerup runAction:[CCSequence actions:[CCHide action],movingSpawnActions,blink, [CCShow action], nil]];
    
    [player.sprite runAction:player.moveAction];
    [thrustParticle stopSystem];
    streak.visible = false;
    player.alive = false;
    
    
    
    player.velocity = ccpMult(ccpNormalize(vel), 9);//ccp(0, .05);
    player.acceleration=CGPointZero;

    @try {
          [Flurry logEvent:@"Player Died" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Galaxy %d-%d",currentGalaxy.number+1,lastPlanetVisited.whichSegmentThisObjectIsOriginallyFrom+1],@"Location of death",[NSNumber numberWithInt:currentGalaxy.number],@"Galaxy",[NSNumber numberWithInt:numZonesHitInARow],@"Pre-death combo", nil]];
    }
    @catch (NSException *exception) {}
  
    totalSecondsAlive = 0;
}

- (void)UpdatePlayer:(float)dt {
    if (player.alive) {
        [self ApplyGravity:dt];
        //CCLOG(@"state: %d", orbitState);
        timeDilationCoefficient -= timeDilationReduceRate;
        
        timeDilationCoefficient = clampf(timeDilationCoefficient, [[UpgradeValues sharedInstance] absoluteMinTimeDilation], absoluteMaxTimeDilation);
        
        if (loading_playerHasReachedFirstPlanet ==false && timeDilationCoefficient > loadingTimeDilationAsPlayerIsGoingToFirstPlanet)
            timeDilationCoefficient = loadingTimeDilationAsPlayerIsGoingToFirstPlanet;
        
        //CCLOG(@"thrust mag: %f", timeDilationCoefficient);
        
        [self KillIfEnoughTimeHasPassed];
        
        // if player is off-screen
        if (![self IsNonConvertedPositionOnScreen:[self GetPlayerPositionOnScreen]]) {
            //[self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number];
        }
        
        Planet * nextPlanet;
        if (lastPlanetVisited.number +1 < [planets count]) {
            nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number+1)];
        } else {
            nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number-1)];
        }
        
        bool isGoingCounterClockwise=false;
        if (orbitState == 0) { //may want to keep on calculating lastAngle... not sure.
            float takeoffAngleToNextPlanet=CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(nextPlanet.sprite.position, lastPlanetVisited.sprite.position)))-CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(player.sprite.position, lastPlanetVisited.sprite.position)));
            isGoingCounterClockwise = (takeoffAngleToNextPlanet-lastTakeoffAngleToNextPlanet<0);
            if (isGoingCounterClockwise) {// if you are going CCW
                if ((takeoffAngleToNextPlanet<=-270+anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees&&takeoffAngleToNextPlanet>=-360+anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees)||
                    (takeoffAngleToNextPlanet>=0-anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees && takeoffAngleToNextPlanet <= 90+anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees)) {
                }
                
            } else if ((takeoffAngleToNextPlanet>=270-anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees&&takeoffAngleToNextPlanet<=360+anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees)||
                       (takeoffAngleToNextPlanet >=-90-anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees && takeoffAngleToNextPlanet <=0+anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees)) {
            }
            lastTakeoffAngleToNextPlanet = takeoffAngleToNextPlanet;
        }
        
        //spaceship rotating code follows --------------------
        float targetRotation = -CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity));
        if (isGoingCounterClockwise) {
            if (targetRotation-player.sprite.rotation>=180)
                player.sprite.rotation+=360;
        }
        else if (targetRotation-player.sprite.rotation<=-180)
            player.sprite.rotation-=360;
        player.sprite.rotation = targetRotation;
        if (player.currentPowerup)
            player.currentPowerup.glowSprite.rotation = player.sprite.rotation;
        //end spaceship rotating code --------------------
    }
    else if (player.moveAction.isDone){
        player.alive=true;
        id resetStreak = [CCCallBlock actionWithBlock:(^{
            [streak reset];
        })];
        [streak runAction:[CCSequence actions:resetStreak,[CCShow action], nil]];
        [thrustParticle resetSystem];
        
        [playerSpawnedParticle resetSystem];
        [playerSpawnedParticle setPosition:[self GetPlayerPositionOnScreen]];
        [playerSpawnedParticle setPositionType:kCCPositionTypeGrouped];
        //[playerSpawnedParticle setVisible:true];
        
    }
}

- (void)resetVariablesForNewGame {
    [cameraLayer removeChild:thrustParticle cleanup:NO];
    
    CGPoint focusPosition= ccpMidpoint(((Planet*)[planets objectAtIndex:0]).sprite.position, ((Planet*)[planets objectAtIndex:1]).sprite.position);
    focusPosition = ccpLerp(focusPosition, ccpMidpoint(focusPosition, player.sprite.position), .25f) ;
    [cameraLayer setPosition:focusPosition];
    
    score=0;
    zonesReached=0;
    planetsHitSinceNewGalaxy=0;
    totalGameTime = 0 ;
    lastPlanetVisited = [planets objectAtIndex:0];
    timeSinceCometLeftScreen=0;
    prevCurrentPtoPScore=0;
    
    [player setVelocity:CGPointZero];
    justReachedNewPlanet = true;
    
    [thrustParticle setPositionType:kCCPositionTypeRelative];
    //[cameraLayer addChild:thrustParticle z:2];
    [cameraLayer addChild:thrustBurstParticle z:2];
    [cameraLayer addChild:streak z:1];
    //NSLog(@"adding player.sprite");
    [spriteSheet addChild:player.sprite z:3];
}

- (CGPoint)GetPositionForJumpingPlayerToPlanet:(int)planetIndex {
    //CCLOG([NSString stringWithFormat:@"thrust mag:"]);
    CGPoint dir = ccpNormalize(ccpSub(((Planet*)[planets objectAtIndex:planetIndex+1]).sprite.position,((Planet*)[planets objectAtIndex:planetIndex]).sprite.position));
    return ccpAdd(((Planet*)[planets objectAtIndex:planetIndex]).sprite.position, ccpMult(dir, ((Planet*)[planets objectAtIndex:planetIndex]).orbitRadius*respawnOrbitRadius));
}

- (void)RenumberCamObjectArray:(NSMutableArray *)array {
    for (int i = 0 ; i < [array count]; i++)
        ((CameraObject*)[array objectAtIndex:i]).number = i;
}

- (void)DisposeAllContentsOfArray:(NSMutableArray*)array shouldRemoveFromArray:(bool)shouldRemove{
    for (int i = 0 ; i < [array count]; i++) {
        CameraObject * object = [array objectAtIndex:i];
        object.segmentNumber--;
        if (object.segmentNumber == -1 ) {
            if ([[spriteSheet children]containsObject:object.sprite])
                [spriteSheet removeChild:object.sprite cleanup:YES];
            if ([[currentGalaxy.spriteSheet children]containsObject:object.sprite]) {
                   [currentGalaxy.spriteSheet removeChild:object.sprite cleanup:YES];
            }
            
            //   if (lastPlanetVisited.whichGalaxyThisObjectBelongsTo != targetPlanet.whichGalaxyThisObjectBelongsTo) {
            //  [object.sprite stopAllActions];
            [object.sprite removeAllChildrenWithCleanup:YES];
            [object.sprite removeFromParentAndCleanup:YES];
            [object removeAllChildrenWithCleanup:YES];
            [object removeFromParentAndCleanup:YES];
            //   }
            
            if (shouldRemove) {
                [array removeObject:object];
                i--;
            }
        }
    }
}

- (void)UpdateGalaxies:(float)dt{
    if (lastPlanetVisited.number!=0) {
        //NSLog(@"galaxy");
        
        Planet * nextPlanet;
        if (lastPlanetVisited.number+1<[planets count])
            nextPlanet= [planets objectAtIndex:(lastPlanetVisited.number+1)];
        else nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number-1)];
        //NSLog(@"galaxy11");
        
        if (targetPlanet.whichGalaxyThisObjectBelongsTo>lastPlanetVisited.whichGalaxyThisObjectBelongsTo || loading_playerHasReachedFirstPlanet==false) {
            isLeavingLastPlanetInGalaxy = true;
            cameraShouldFocusOnPlayer=true;
            //NSLog(@"galaxy112");
            
            light.timeLeft += howMuchSlowerTheBatteryRunsOutWhenYouAreTravelingBetweenGalaxies*dt;
            
            if (light.timeLeft<1)
                light.timeLeft += dt;
            
            float firsttoplayer = ccpToAngle(ccpSub(lastPlanetVisited.sprite.position, player.sprite.position));
            float planetAngle = ccpToAngle(ccpSub(lastPlanetVisited.sprite.position, nextPlanet.sprite.position));
            float firstToPlayerAngle = firsttoplayer-planetAngle;
            float firstToPlayerDistance = ccpDistance(lastPlanetVisited.sprite.position, player.sprite.position)*cosf(firstToPlayerAngle);
            float firsttonextDistance = ccpDistance(lastPlanetVisited.sprite.position, nextPlanet.sprite.position);
            //NSLog(@"galaxy113");
            float percentofthewaytonext = firstToPlayerDistance/firsttonextDistance;
            percentofthewaytonext*=1.18;
            
            if (percentofthewaytonext>1) percentofthewaytonext = 1;
            
            Galaxy * thisGalaxy = [galaxies objectAtIndex:lastPlanetVisited.whichGalaxyThisObjectBelongsTo];
            Galaxy * nextGalaxy2 = [galaxies objectAtIndex:targetPlanet.whichGalaxyThisObjectBelongsTo];
            
            ccColor3B lastColor;
            if (thisGalaxy != [NSNull null])
                lastColor= thisGalaxy.galaxyColor;
            else lastColor = lastGalaxyColor;
            ccColor3B nextColor = nextGalaxy2.galaxyColor;
            
            if (percentofthewaytonext>.35) {
                float colorPercent = (percentofthewaytonext-.3)/.7;
                [backgroundClouds setColor:ccc3(lerpf(lastColor.r, nextColor.r, colorPercent),
                                                lerpf(lastColor.g, nextColor.g, colorPercent),
                                                lerpf(lastColor.b, nextColor.b, colorPercent))];
                
            }
            if (percentofthewaytonext>.85&&justDisplayedGalaxyLabel==false&&(int)galaxyLabel.opacity<=0)
            {
                Galaxy * lastGalaxy = [galaxies objectAtIndex:currentGalaxy.number-1];
                lastGalaxyColor = lastGalaxy.galaxyColor;
                
                timeToAddToTimer = lastGalaxy.percentTimeToAddUponGalaxyCompletion*[[UpgradeValues sharedInstance] maxBatteryTime];
                if (timeToAddToTimer+light.timeLeft > [[UpgradeValues sharedInstance] maxBatteryTime])
                    timeToAddToTimer = [[UpgradeValues sharedInstance] maxBatteryTime] - light.timeLeft;

                for (CCSprite* sprite in lastGalaxy.spriteSheet.children)
                    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromTexture:sprite.texture];

                if ([[cameraLayer children]containsObject:lastGalaxy.spriteSheet]) {
                    [cameraLayer removeChild:lastGalaxy.spriteSheet cleanup:YES];
                }

                if ([[cameraLayer children]containsObject:currentGalaxy.spriteSheet]==false) {
                    [lastGalaxy.spriteSheet removeAllChildrenWithCleanup:YES];
                    [lastGalaxy.spriteSheet removeFromParentAndCleanup:YES];
                    [lastGalaxy.spriteSheet.children removeAllObjects];
                    lastGalaxy.spriteSheet = NULL;
                    //[[CCTextureCache sharedTextureCache] removeUnusedTextures];
                    lastGalaxy.segments = NULL;
                    [lastGalaxy removeAllChildrenWithCleanup:YES];

                    [galaxies replaceObjectAtIndex:lastGalaxy.number withObject:[NSNull null]];

                   // [lastGalaxy cleanup];

                    
                    
                    [cameraLayer addChild:currentGalaxy.spriteSheet z:3];
                    //NSLog(@"galaxy1155");
                    [cameraLayer reorderChild:spriteSheet z:4];
                    [cameraLayer reorderChild:streak z:4];
                    [cameraLayer reorderChild:thrustParticle z:4];
                    [cameraLayer reorderChild:thrustBurstParticle z:4];
                    
                }
                //NSLog(@"galaxy4");
                
                [self CheckMissionsGalaxyChange];
                
                for (int i = 0 ; i <= 9 ; i++) {
                    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFrameByName:[NSString stringWithFormat:@"planet%d-%d.png",i,currentGalaxy.number-1]];
                    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFrameByName:[NSString stringWithFormat:@"asteroid%d-%d.png",i,currentGalaxy.number-1]];
                }
                [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFrameByName:[NSString stringWithFormat:@"zone%d.png",currentGalaxy.number-1]];
                
                flurrySegmentsVisitedSinceGalaxyJump = 0;
                
                [batteryGlowSprite setColor:ccc3(0, 255, 0)];
                [batteryGlowSprite stopAllActions];
                [batteryGlowSprite runAction:batteryGlowScaleAction];
                
                if ([[hudLayer children]containsObject:galaxyLabel]==false)
                    [hudLayer addChild:galaxyLabel];
                [galaxyLabel setOpacity:1];
                [galaxyLabel setString:[currentGalaxy name]];
                [galaxyLabel stopAllActions];
                [galaxyLabel runAction:galaxyLabelAction];
                justDisplayedGalaxyLabel= true;
            }
        }
        else {
            isLeavingLastPlanetInGalaxy = false;
            cameraShouldFocusOnPlayer=false;
            //[background setOpacity:255];
        }
    }
    //NSLog(@"galaxy5");
    if ((int)galaxyLabel.opacity <=0&&justDisplayedGalaxyLabel==false&&[[hudLayer children]containsObject:galaxyLabel])
        [hudLayer removeChild:galaxyLabel cleanup:NO];
    
    if (lastPlanetVisited.segmentNumber == numberOfSegmentsAtATime-1) {
        CCLOG(@"Planet Count: %d",[planets count]);
        [self DisposeAllContentsOfArray:planets shouldRemoveFromArray:true];
        [self DisposeAllContentsOfArray:zones shouldRemoveFromArray:true];
        [self DisposeAllContentsOfArray:asteroids shouldRemoveFromArray:true];
        [self DisposeAllContentsOfArray:coins shouldRemoveFromArray:true];
        [self DisposeAllContentsOfArray:powerups shouldRemoveFromArray:YES];
        
        [self RenumberCamObjectArray:planets];
        [self RenumberCamObjectArray:zones];
        [self RenumberCamObjectArray:asteroids];
        [self RenumberCamObjectArray:powerups];
        [self RenumberCamObjectArray:coins];
        
        
        makingSegmentNumber--;
        if ([self CreateSegment]==false) {
            justDisplayedGalaxyLabel = false;
            
            makingSegmentNumber--;
            [self CreatePlanetAndZone:indicatorPos.x yPos:indicatorPos.y scale:1];
            makingSegmentNumber++;
            
            planetsHitSinceNewGalaxy=0;
            if (currentGalaxy.number+1<[galaxies count]) {
                currentGalaxy = nextGalaxy;
                if (currentGalaxy.number+1<[galaxies count])
                    nextGalaxy = [galaxies objectAtIndex:currentGalaxy.number+1];
                
                Planet*lastPlanetOfThisGalaxy = [planets objectAtIndex:planets.count-1];
                [self CreateCoinArrowAtPosition:ccpAdd(lastPlanetOfThisGalaxy.sprite.position, ccpMult(ccpForAngle(CC_DEGREES_TO_RADIANS(directionPlanetSegmentsGoIn)), lastPlanetOfThisGalaxy.orbitRadius*2.1)) withAngle:directionPlanetSegmentsGoIn];
                indicatorPos = ccpAdd(indicatorPos, ccpMult(ccpNormalize(ccpForAngle(CC_DEGREES_TO_RADIANS(directionPlanetSegmentsGoIn))), distanceBetweenGalaxies));
            }
            [self CreateSegment];
        }
        CCLOG(@"Planet Count: %d",[planets count]);
    }
}

- (void)UpdateFeverMode {
    isInFeverMode = true;
    [thrustParticle setEmissionRate:400];
    [feverLabel setString:[NSString stringWithFormat:@"%d Combo!", feverModePlanetHitsInARow]];
    
    [feverLabel runAction:[CCSequence actions:
                           [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.1 scale:1.2]],
                           [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.2 scale:1]],
                           nil]
     ];
    
    
    
    
    timeDilationUponFeverEnter = timeDilationCoefficient;
    if (player.currentPowerup.type != kheadStart) {
        timeDilationCoefficient *= timeDilationFeverModeMultiplier;
        timeDilationCoefficient = clampf(timeDilationCoefficient, [[UpgradeValues sharedInstance] absoluteMinTimeDilation], absoluteMaxTimeDilation);
    }
    
    if (feverModePlanetHitsInARow == minPlanetsInARowForFeverMode) {
        [self playSound:@"startFeverMode.mp3" shouldLoop:false pitch:1];
        [feverModeInitialExplosionParticle resetSystem];
        [feverModeInitialExplosionParticle setPosition:player.sprite.position];
        [feverModeInitialExplosionParticle setAngle:180+CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity))];
    } else {
        [feverModeLabelParticle resetSystem];
        [feverModeLabelParticle setPosition:feverLabel.position];
    }
}

- (void)UpdatePlanets {
    // Zone-to-Player collision detection follows-------------
    player.isInZone = false;
    
    int zoneCount = zones.count;
    for (int i = MAX(lastPlanetVisited.number-1,0); i < MIN(zoneCount,lastPlanetVisited.number+3);i++)
    {
        Zone * zone = [zones objectAtIndex:i];
        if (zone.number<=lastPlanetVisited.number+1&& ccpDistance([[player sprite]position], [[zone sprite]position])<[zone radius]*zoneCollisionFactor)
        {
            player.isInZone = true;
            /*    Zone * nextZone = [zones objectAtIndex:zone.number+1];
             if (orbitState == 0 && nextZone.hasPlayerHitThisZone && zone.hasPlayerHitThisZone)
             nextZone.hasPlayerHitThisZone = false;*/
            
            if (!zone.hasPlayerHitThisZone)
            {
                if (i>0)
                    if ([[zones objectAtIndex:i - 1]hasPlayerHitThisZone]) {
                        lastPlanetVisited = [planets objectAtIndex:zone.number];
                        updatesSinceLastPlanet = 0;
                    }
                
                // CCLOG(@"lastplanet: %d targetplanet = %d lastplanethitzone: %d nextplanethitzone: %d",lastPlanetVisited.number,targetPlanet.number,(int)zone.hasPlayerHitThisZone,(int)((Zone*)[zones objectAtIndex:zone.number+1]).hasPlayerHitThisZone);
                
                if (i==0||((Planet*)[planets objectAtIndex:zone.number-1]).whichSegmentThisObjectIsOriginallyFrom!=lastPlanetVisited.whichSegmentThisObjectIsOriginallyFrom) {
                    NSLog(@"Entering galaxy %d segment %d (1-based index)",currentGalaxy.number+1,lastPlanetVisited.whichSegmentThisObjectIsOriginallyFrom+1);
                    flurrySegmentsVisitedSinceGalaxyJump++;
                }
                
                
                
                [zone.sprite setColor:ccc3(140, 140, 140)];
                zone.hasPlayerHitThisZone = true;
                
                //if (feverModePlanetHitsInARow >= minPlanetsInARowForFeverMode) {
                //    [self UpdateFeverMode];
                //}
                
                percentToNextHasAlreadyBeenBelowZeroForThisPlanet = false;
                zonesReached++;
                planetsHitSinceNewGalaxy++;
                score+=currentPtoPscore;
                currentPtoPscore=0;
                prevCurrentPtoPScore=0;
                numZonesHitInARow++;
                if (player.currentPowerup.type != kheadStart)
                    timeDilationCoefficient += timeDilationIncreaseRate;
                planetsHitFlurry++;
                
                if (planetsHitFlurry == 1) {
                    [coinsLabelStarSprite setVisible:true];
                    [coinsLabel setVisible: true];
                    [scoreLabel setVisible: true];
                    [zeroCoinsLabel setVisible:true];
                    id fadeInAction = [CCFadeIn actionWithDuration:1];
                    [coinsLabelStarSprite runAction:fadeInAction];
                    [coinsLabel runAction:fadeInAction];
                    [scoreLabel runAction:fadeInAction];
                    [zeroCoinsLabel runAction:fadeInAction];
                    loading_playerHasReachedFirstPlanet = true;
                    pauseEnabled = YES;
                    score = 0;
                    tempScore = 0;
                }
            }
        }
    } // end collision detection code-----------------
}

/* Your score goes up as you move along the vector between the current and next planet. Your score will also never go down, as the user doesn't like to see his score go down.*/
- (void)UpdateScore {
    tempScore = ccpDistance(CGPointZero, player.sprite.position)-160;
    tempScore *= [[ObjectiveManager sharedInstance]getscoreMultFromCurrentGroupNumber];
    if (tempScore > score)
        score = tempScore;
    [scoreLabel setString:[NSString stringWithFormat:@"%d",score]];
    
    if (!loading_playerHasReachedFirstPlanet)
        score = 0;
    
    //int numCoins = [[UserWallet sharedInstance] getBalance];
    //int coinsDiff = numCoins - startingCoins;
    //[coinsLabel setString:[NSString stringWithFormat:@"%i",coinsDiff]];
    
}

- (void)UpdateParticles:(ccTime)dt {
    //[streak runAction:[CCFollow actionWithTarget:player.sprite]];
    
    [thrustParticle setPosition:player.sprite.position];
    [thrustParticle setAngle:180+CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity))];
    
    // [thrustParticle setEmissionRate:ccpLengthSQ(player.velocity)*ccpLength(player.velocity)/2.2f];
    float speedPercent = (timeDilationCoefficient-[[UpgradeValues sharedInstance] absoluteMinTimeDilation])/(absoluteMaxTimeDilation-[[UpgradeValues sharedInstance] absoluteMinTimeDilation]);
    [thrustParticle setEndColor:ccc4FFromccc4B(
                                               ccc4(lerpf(slowParticleColor[0], fastParticleColor[0], speedPercent),
                                                    lerpf(slowParticleColor[1], fastParticleColor[1], speedPercent),
                                                    lerpf(slowParticleColor[2], fastParticleColor[2], speedPercent),
                                                    lerpf(slowParticleColor[3], fastParticleColor[3], speedPercent)))];
    /*[streak setColor:ccc3(lerpf(slowStreakColor[0], fastStreakColor[0], speedPercent),
     lerpf(slowStreakColor[1], fastStreakColor[1], speedPercent),
     lerpf(slowStreakColor[2], fastStreakColor[2], speedPercent))];*/
    
    if (cometParticle.position.y<0) {
        [cometParticle stopSystem];
        timeSinceCometLeftScreen+=dt;
        if (timeSinceCometLeftScreen>cometRespawnTimer) {
            [cometParticle resetSystem];
            cometParticle.position = ccp([self RandomBetween:0 maxvalue:480],325);
            cometVelocity = ccp([self RandomBetween:-10 maxvalue:10]/5,-[self RandomBetween:cometMinYSpeed maxvalue:cometMaxYSpeed]);
            timeSinceCometLeftScreen=0;
            [cometParticle setAngle:180+CC_RADIANS_TO_DEGREES(ccpToAngle(cometVelocity))];
        }
    }
    [cometParticle setPosition:ccpAdd(cometParticle.position, cometVelocity)];
}

-(void)nameDidChange {
    NSString *newName = [playerNameLabel.text uppercaseString];
    if (newName.length <= maxNameLength) {
        [displayName setString:[newName stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
    }
    [playerNameLabel setText:displayName.string];
    if (newName.length == 0) {
        [underscore setPosition:displayName.position];
        return;
    }
    [underscore setPosition:ccp(displayName.position.x + displayName.boundingBox.size.width/2 + underscore.boundingBox.size.width/2, displayName.position.y)];
}

- (BOOL)textViewShouldReturn:(UITextView*)textView {
    if (textView == playerNameLabel) {
        [textView resignFirstResponder];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [self hideKeyboard];
    }
    return YES;
}

- (void)showKeyboard {
    isKeyboardShowing = YES;
    blankAvoiderName = [playerNameLabel text];
    [playerNameLabel becomeFirstResponder];
    [playerNameLabel setText:@""];
    [displayName setString:@""];
    underscore = [[CCLabelBMFont alloc] initWithString:@"_" fntFile:@"score_label_font.fnt"];
    [pauseLayer addChild:underscore];
    [underscore setPosition:displayName.position];
    [underscore runAction: [CCRepeatForever actionWithAction: [CCBlink actionWithDuration:5 blinks:5]]];
}

- (void)hideKeyboard {
    isKeyboardShowing = NO;
    if ([[playerNameLabel text] isEqualToString:@""]) {
        [playerNameLabel setText:blankAvoiderName];
        [displayName setString:blankAvoiderName];
    }
    [playerNameLabel resignFirstResponder];
    [underscore removeFromParentAndCleanup:YES];
    underscore = nil;
}

- (void)GameOver {
    if (!isGameOver) { // this line ensures that it only runs once
        isGameOver = true;
        if ([[self children]containsObject:layerHudSlider])
            [self removeChild:layerHudSlider cleanup:YES];
        
        [Kamcord stopRecording];
          
        CCSprite* dark = [CCSprite spriteWithFile:@"OneByOne.png"];
        [self addChild:dark];
        //[dark setZOrder:112];
        dark.position = ccp(240, 160);
        dark.color = ccBLACK;
        dark.opacity = 0;
        dark.scaleX = 480;
        dark.scaleY = 320;
        //dark.visible = false;
        
        
        [playerExplosionParticle resetSystem];
        [playerExplosionParticle setPosition:player.sprite.position];
        [playerExplosionParticle setVisible:true];
        player.sprite.visible = false;
        if (player.currentPowerup)
            player.currentPowerup.glowSprite.visible = false;
        [thrustParticle stopSystem];
        
        
        id gameOverBlock = [CCCallBlock actionWithBlock:(^{
            [dark setVisible:false];
            if ([[ObjectiveManager sharedInstance] shouldDisplayLevelUpAnimation]) {
                [[CCDirector sharedDirector] pushScene:[MissionsCompleteLayer scene]];
            }
            [self startGameOver];
        })];
        
        [self CheckEndGameMissions];
        
        [dark runAction:[CCSequence actions:
                         [CCFadeTo actionWithDuration:2 opacity:240],
                         gameOverBlock,
                         nil]];
        
    }
}

-(void) startGameOver {
    int finalScore = score + prevCurrentPtoPScore;
    BOOL isHighScore = [[PlayerStats sharedInstance] isHighScore:finalScore];
    NSString *ccbFile = @"GameOverLayer.ccb";
    //NSString *scoreText = [NSString stringWithFormat:@"Score: %d",finalScore];
    pauseLayer = (CCLayer*)[CCBReader nodeGraphFromFile:ccbFile owner:self];
    
    if (finalScore > 40000)
        [[iRate sharedInstance] logEvent:YES];
    //finalScore = 69669;
    //numCoinsDisplayed = 69;
    
    int rateOfScoreIncrease = finalScore / 640;
    if (rateOfScoreIncrease == 0 )
        rateOfScoreIncrease = 1;
    @try {
    NSDictionary *dictForFlurry = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:finalScore],@"Highscore Value", [NSNumber numberWithInt:planetsHitFlurry],@"Planets traveled to",[NSNumber numberWithInt:segmentsSpawnedFlurry],@"Segments spawned",[NSString stringWithFormat:@"Galaxy %d-%d",currentGalaxy.number+1,lastPlanetVisited.whichSegmentThisObjectIsOriginallyFrom+1],@"Location of death",[NSString stringWithFormat:@"%d galaxies and %d segments",currentGalaxy.number+1,flurrySegmentsVisitedSinceGalaxyJump],@"How far player went",[NSNumber numberWithInt:[[PlayerStats sharedInstance] getPlays]],@"Number of total plays",[[PlayerStats sharedInstance] recentName],@"Player Name",nil];
       
    if (isHighScore) {
        [Flurry logEvent:@"Got a top 10 highscore" withParameters:dictForFlurry];
    }
    }
    @catch (NSException *exception) {}

    [[DDGameKitHelper sharedGameKitHelper] submitScore:finalScore category:@"highscore_leaderboard"];
    
    [[[[CCDirector sharedDirector]view]window]addSubview:playerNameLabel];
    [self schedule:@selector(nameDidChange) interval:.05];
    playerNameLabel.delegate = self;
    playerNameLabel.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    playerNameLabel.autocorrectionType = UITextAutocorrectionTypeNo;
    playerNameLabel.keyboardType = UIKeyboardTypeAlphabet;
    [displayName setString:recentName];
    playerNameLabel.text = recentName;
    playerNameLabel.returnKeyType = UIReturnKeyDone;
    
    //starStashSprite.position = ccpAdd(starStashLabel.position, ccp(30, 0));
    [starStashLabel setString:[NSString stringWithFormat:@"%d",numCoinsDisplayed]];//[[UserWallet sharedInstance]getBalance]]];
    [gameOverScoreLabel setString:@"0"];
    
    id increaseNumber = [CCCallBlock actionWithBlock:(^{
        [gameOverScoreLabel setString:[NSString stringWithFormat:@"%d",gameOverScoreLabel.string.intValue+[self RandomBetween:rateOfScoreIncrease-1 maxvalue:rateOfScoreIncrease+1]]];
    })];
    id setNumber = [CCCallBlock actionWithBlock:(^{
        [gameOverScoreLabel setString:[NSString stringWithFormat:@"%d",finalScore]];
    })];
    
    id displayParticles = [CCCallBlock actionWithBlock:(^{
        [self addChild:starStashParticle];
        [starStashParticle setScale:2.5];
        [starStashParticle setPosition:gameOverScoreLabel.position];
        [starStashParticle resetSystem];
    })];
    
    id pulsate = [CCCallBlock actionWithBlock:(^{
        [gameOverScoreLabel runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                                                                         [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.4 scale:2.8]],
                                                                         [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.4 scale:2.5]],
                                                                         nil]
                                       ]];
    })];
    
    
    [gameOverScoreLabel runAction:[CCSequence actions:[CCRepeat actionWithAction:[CCSequence actions:increaseNumber,
                                                                                  [CCDelayTime actionWithDuration:.003],
                                                                                  nil] times:finalScore/rateOfScoreIncrease],setNumber,displayParticles, pulsate, nil]];
    
    [Flurry endTimedEvent:@"Played Game" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:score],@"Score", nil]];
    
    [pauseLayer setTag:gameOverLayerTag];
    [self addChild:pauseLayer];
    // [gameOverScoreLabel setString:scoreText];
    
    scoreAlreadySaved = YES;
}

- (void)pressedStoreButton {
    [self tryHighScore];
    
    //[Flurry logEvent:@"Opened Store" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[UserWallet sharedInstance] getBalance]],@"Coin Balance" ,nil]];
    
    [self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
    
    if (allowVideoToConvert==false)
        [Kamcord cancelConversionForLatestVideo];

    [[CCDirector sharedDirector] replaceScene:[MainMenuLayer scene]];//[StoreLayer scene]];
    
    
    //id action = [CCMoveTo actionWithDuration:.8f position:ccp(-960,-320)];
    //id ease = [CCEaseSineInOut actionWithAction:action]; //does this "CCEaseSineInOut" look better than the above "CCEaseInOut"???
    //[layer runAction: ease];
}

- (void)UpdateLight:(float)dt {
    light.timeLeft -= dt;
    float timerAddSpeed = 10;
    timeToAddToTimer-= timerAddSpeed * dt;
    if (timeToAddToTimer>0) {
        light.timeLeft += timerAddSpeed * dt;
    }
    else
    {
        [batteryGlowSprite setColor:ccc3(0, 255,202)];
        [batteryGlowSprite stopAllActions];
    }
    
    float percentDead = 1-light.timeLeft/[[UpgradeValues sharedInstance] maxBatteryTime];

    // y = -(x-1)^2+1
    float percentDeadToDisplay = -powf(percentDead-1,2)+1.00001;
    [batteryDecreaserSprite setScaleX:lerpf(0, 66, percentDeadToDisplay)];
    
    if (percentDeadToDisplay<.5)
        [batteryInnerSprite setColor:ccc3(lerpf(0, 255, percentDeadToDisplay*2), 255, 0)];
    else [batteryInnerSprite setColor:ccc3(255, lerpf(255, 0, percentDeadToDisplay    *2-1), 0)];
    
    [batteryGlowScaleAction setSpeed:lerpf(1, 3.6, percentDeadToDisplay)];
    
    if (light.timeLeft <= 0) {
        if (!light.hasPutOnLight) {
            light.hasPutOnLight = true;
            [light.sprite setOpacity:0];
            light.sprite.position = ccp(-240, 160);
            [light.sprite setTextureRect:CGRectMake(0, 0, 480, 320)];
            if (light.sprite)
                [hudLayer reorderChild:light.sprite z:-1];
            [light.sprite setOpacity:0];
        }
    }
    
    if (light.hasPutOnLight) {
        light.sprite.position = ccp(light.sprite.position.x+48, light.sprite.position.y);
        [light.sprite setOpacity:clampf((light.sprite.position.x+240)*255/480, 0, 255)];
    }
    
    if (light.sprite)
        if (light.sprite.position.x >= 240
            ||batteryDecreaserSprite.scaleX>67)//failsafe -- this condition should never have to trigger game over. fix this alex b!!
        {
            [self GameOver];
        }
    
    
}

- (void)UpdateCoins {
    if (player.alive)
        for (Coin* coin in coins) {
            
            CGPoint p = coin.sprite.position;
            
            if (player.currentPowerup.type == kcoinMagnet) {
                if (ccpLength(ccpSub(player.sprite.position, p)) <= 4*(coin.radius + player.sprite.height/1.3) && coin.isAlive && coin.speed < .1) {
                    coin.speed = .5;
                }
                
            }
            if (coin.speed != 0)
                coin.speed += .5;
        }
}

- (void) updatePowerupAnimation:(float)dt {
    
    if (powerupPos <= 250)
        powerupVel = 15*1.5;
    else if (powerupPos <= 430)
        powerupVel = 2.3*1.5;
    else
        powerupVel = 18*1.5;
    
    //powerupPos = 999;
    if (powerupPos > 480 + [powerupLabel boundingBox].size.width) {
        paused = false;
        isDisplayingPowerupAnimation = false;
    }
    
    powerupPos += powerupVel*60*dt;
    [powerupLabel setString:player.currentPowerup.title];
    
    powerupLabel.position = ccp(-[powerupLabel boundingBox].size.width/2 + powerupPos, 160);
    //powerupLabel.position = ccp(- 500, 500);
    
}

- (void)UpdateBackgroundStars:(float)dt{
    for (CCSprite * star in backgroundStars) {
          CGPoint camLayerVelocity = ccpSub(cameraLastFocusPosition, cameraLayerLastPosition);
        //float angle = ccpToAngle(player.velocity);
        //if (angle>=0 && angle <=90)
        
        if (paused)
            camLayerVelocity = CGPointZero;
        
        
        //NSLog([NSString stringWithFormat:@"x: %f, y: %f", camLayerVelocity.x, camLayerVelocity.y]);
        
        star.position = ccpLerp(star.position,ccpAdd(star.position,  ccpMult(camLayerVelocity, -1*cameraLayer.scale*.3*60*dt)), .10);
        
        if (star.position.x<0-star.width/2 || star.position.y <0-star.height/2) { //if star is off-screen
            star.position = ccp([self RandomBetween:star.width/2 maxvalue:480*1.8],[self RandomBetween:320+star.height/2 maxvalue:320+5*star.height/2]);
        }
    }
}

-(void)unscheduleUpdates {
    /*    [self unschedule:@selector(UpdateScore) ];
     [self unschedule:@selector(UpdateParticles:)];
     [self unschedule:@selector(UpdateBackgroundStars:) ];
     [self unschedule:@selector(UpdateLight:)];*/
    [self unscheduleAllSelectors];
}

-(void)scheduleUpdates {
    //NSLog(@"start4");
    [self schedule:@selector(UpdateScore) interval:1.0/25.0f];
    [self schedule:@selector(UpdateParticles:) interval:1.0/60.0f];
    [self schedule:@selector(UpdateBackgroundStars:) interval:1.0/24.0f];
    [self schedule:@selector(UpdateLight:) interval:1.0/10.0f];
    [self schedule:@selector(Update:) interval:0];// this makes the update loop loop!!!!
    //    [self UpdateScore];
    //NSLog(@"start6");
    //  [self UpdateParticles:dt];
    //[self UpdateBackgroundStars];
    
    //NSLog(@"start7");
    //    [self UpdateLight:dt];
}

- (void) CheckMissions {
    
    if (numCoinsDisplayed >= 10)
        [self completeObjectiveFromGroupNumber:0 itemNumber:0];
    
    if (score >= 5000)
        [self completeObjectiveFromGroupNumber:0 itemNumber:1];
    
    
    
    if (player.currentPowerup != nil)
        [self completeObjectiveFromGroupNumber:1 itemNumber:0];
    
    if (score >= 10000)
        [self completeObjectiveFromGroupNumber:1 itemNumber:1];
    
    if (numTimesSwiped >= 25)
        [self completeObjectiveFromGroupNumber:1 itemNumber:2];
    
    
    
    if (numCoinsDisplayed >= 100)
        [self completeObjectiveFromGroupNumber:2 itemNumber:1];
    
    
    
    if (asteroidsDestroyedWithArmor >= 5)
        [self completeObjectiveFromGroupNumber:3 itemNumber:0];
    
    if (numCoinsDisplayed >= 150) {
        [self completeObjectiveFromGroupNumber:3 itemNumber:2];
    }
    
    
    
    if (score >= 24000)
        [self completeObjectiveFromGroupNumber:4 itemNumber:1];
    
    
    
    if (asteroidsCrashedInto >= 7)
        [self completeObjectiveFromGroupNumber:5 itemNumber:1];
    
    
    
    if ([[UpgradeValues sharedInstance] hasGreenTrail] ||
        [[UpgradeValues sharedInstance] hasBlueTrail] ||
        [[UpgradeValues sharedInstance] hasGoldTrail] ||
        [[UpgradeValues sharedInstance] hasOrangeTrail] ||
        [[UpgradeValues sharedInstance] hasRedTrail] ||
        [[UpgradeValues sharedInstance] hasPurpleTrail] ||
        [[UpgradeValues sharedInstance] hasPinkTrail] ||
        [[UpgradeValues sharedInstance] hasBlackTrail] ||
        [[UpgradeValues sharedInstance] hasBrownTrail]) {
        [self completeObjectiveFromGroupNumber:6 itemNumber:0];
    }
    
    if (score >= 40000)
        [self completeObjectiveFromGroupNumber:6 itemNumber:1];
    
    if (numTimesSwiped >= 50)
        [self completeObjectiveFromGroupNumber:6 itemNumber:2];
    
    
    
    if (numCoinsDisplayed >= 200)
        [self completeObjectiveFromGroupNumber:7 itemNumber:0];
    
    if (asteroidsDestroyedWithArmor >= 15)
        [self completeObjectiveFromGroupNumber:7 itemNumber:2];
    
    
    
    if ([[UpgradeValues sharedInstance] hasGreenShip] ||
        [[UpgradeValues sharedInstance] hasBlueShip] ||
        [[UpgradeValues sharedInstance] hasGoldShip] ||
        [[UpgradeValues sharedInstance] hasOrangeShip] ||
        [[UpgradeValues sharedInstance] hasRedShip] ||
        [[UpgradeValues sharedInstance] hasPurpleShip] ||
        [[UpgradeValues sharedInstance] hasPinkShip]) {
        [self completeObjectiveFromGroupNumber:8 itemNumber:0];
    }
    
    if (score >= 55000)
        [self completeObjectiveFromGroupNumber:8 itemNumber:1];
    
    
    
    if (numCoinsDisplayed >= 300)
        [self completeObjectiveFromGroupNumber:9 itemNumber:1];
    
    if (player.currentPowerup.type == kautopilot)
        [self completeObjectiveFromGroupNumber:9 itemNumber:2];
    
    
    
    if (asteroidsCrashedInto >= 15)
        [self completeObjectiveFromGroupNumber:10 itemNumber:1];
    
    if (score >= 70000)
        [self completeObjectiveFromGroupNumber:10 itemNumber:2];
    
    
    
    if (numCoinsDisplayed >= 400)
        [self completeObjectiveFromGroupNumber:11 itemNumber:1];
    
}

- (void) CheckMissionsGalaxyChange {
    
    if (currentGalaxy.number == 1)
        [self completeObjectiveFromGroupNumber:0 itemNumber:2];
    
    
    
    
    if (currentGalaxy.number == 2)
        [self completeObjectiveFromGroupNumber:2 itemNumber:0];
    
    
    
    if (currentGalaxy.number == 2 & numTimesDied == 0)
        [self completeObjectiveFromGroupNumber:4 itemNumber:0];
    
    if (currentGalaxy.number == 3)
        [self completeObjectiveFromGroupNumber:4 itemNumber:2];
    
    if (currentGalaxy.number == 2 && asteroidsCrashedInto == 0)
        [self completeObjectiveFromGroupNumber:5 itemNumber:0];
    
    
    
    if (currentGalaxy.number == 4)
        [self completeObjectiveFromGroupNumber:9 itemNumber:0];
    
    
    
    if (currentGalaxy.number == 3 & numTimesDied == 0)
        [self completeObjectiveFromGroupNumber:10 itemNumber:0];
    
    
    
    if (currentGalaxy.number == 5)
        [self completeObjectiveFromGroupNumber:11 itemNumber:0];
    
}

- (void) CheckEndGameMissions {
    
    if (score >= 14000 && score <= 16000)
        [self completeObjectiveFromGroupNumber:2 itemNumber:2];
    
    
    
    if (numCoinsDisplayed >= 150 && numCoinsDisplayed <= 160)
        [self completeObjectiveFromGroupNumber:5 itemNumber:2];
    
    
    
    if (score >= 41000 && score <= 43000)
        [self completeObjectiveFromGroupNumber:7 itemNumber:1];
    
    
    
    if (numCoinsDisplayed >= 220 && numCoinsDisplayed <= 230)
        [self completeObjectiveFromGroupNumber:8 itemNumber:2];
    
    
    
    if (numCoinsDisplayed >= 300 && numCoinsDisplayed <= 310)
        [self completeObjectiveFromGroupNumber:11 itemNumber:2];
    
}

- (void) Update:(ccTime)dt {
    if (dt > .2) {
		dt = 1.0 / 60.0f;
	}
    //NSLog(@"start");
    if (!paused&&isGameOver==false) {
        totalGameTime+=dt;
        totalSecondsAlive+=dt;
        timeSinceGotLastCoin+=dt;
        
        
        [self UpdateGalaxies:dt];
        //NSLog(@"start2");
        if (player.alive) {
            [self UpdatePlanets];
            //NSLog(@"start1");
        }
        [self UpdateCoins];
        //NSLog(@"start3");
        [self UpdatePlayer: dt];
        
        [self CheckMissions];
        
        if (targetPlanet.number >= 6) {
            if ([self checkShouldDisplayTextForVar:hasDiplayedBatteryText]) {
                [self pauseWithDuration:5 message:@"Notice the battery on the lower-left corner of the screen? It recharges as you move between galaxies, but you need to travel as far as you can before it runs out!"];
                hasDiplayedBatteryText = true;
            }
        }
        
        if (numTimesSwiped == 0) {
            if (loading_playerHasReachedFirstPlanet) {
                if (!tutHand) {
                    tutHand = [CCSprite spriteWithFile:@"hand.png"];
                    tutHand.scale = .5;
                    
                    [hudLayer addChild:tutHand];
                    CGPoint startPos = ccp(250, 50);
                    tutHand.position = startPos;
                    tutHand.opacity = 0;
                    
                    
                    [tutHand runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                                                                          [CCFadeTo actionWithDuration:.5 opacity:255],
                                                                          [CCMoveTo actionWithDuration:.5 position:ccp(400, 150)],
                                                                          [CCFadeTo actionWithDuration:.5 opacity:0],
                                                                          [CCMoveTo actionWithDuration:.2 position:startPos],
                                                                          nil]]];
                    
                    
                    tutLabel = [CCLabelTTF labelWithString:@"Swipe to fly towards the next planet!" fontName:@"HelveticaNeue-CondensedBold" fontSize:20];
                    tutLabel.opacity = 0;
                    [tutLabel runAction:[CCFadeIn actionWithDuration:.5]];
                    [hudLayer addChild:tutLabel];
                    tutLabel.position = ccp(240, 280);
                }
            }
        } else if (tutHand) {
            [tutHand removeFromParentAndCleanup:true];
            tutHand = Nil;
            [tutLabel removeFromParentAndCleanup:true];
            tutLabel = Nil;
        }
        
        //NSLog(@"start5");
        [self UpdateCamera:dt];
        
        //NSLog(@"start7b");
        updatesSinceLastPlanet++;
    } else if (isDisplayingPowerupAnimation)
        [self updatePowerupAnimation: dt];
    
    // if ([[self children]containsObject:background]&&[[self children]containsObject:background2])
    //    //NSLog(@"both backgrounds are on the screen! this should only happen when transitioning between galaxies.");
    //NSLog(@"startx");
    
    if (!paused&&[((AppDelegate*)[[UIApplication sharedApplication]delegate])getWasJustBackgrounded])
    {
        //NSLog(@"startx2");
        [((AppDelegate*)[[UIApplication sharedApplication]delegate])setWasJustBackgrounded:false];
        //NSLog(@"startx3");
        [self togglePause];
        //NSLog(@"startx4");
    }
    
    player.currentPowerup.glowSprite.position = player.sprite.position;
    //NSLog(@"startx5");
}


- (void)endGame {
    int finalScore = score + prevCurrentPtoPScore;
    //NSLog(@"1");
    if ([[PlayerStats sharedInstance] isHighScore:finalScore]) {
        //NSLog(@"2");
        NSString *playerName = displayName.string;
        //NSLog(@"3");
        [[PlayerStats sharedInstance] addScore:score+prevCurrentPtoPScore withName:playerName];
        //NSLog(@"4");
        [[PlayerStats sharedInstance] setRecentName:playerName];
        [DataStorage storeData];
        if ([[[[[CCDirector sharedDirector] view] window] subviews]containsObject:playerNameLabel])
            [playerNameLabel removeFromSuperview];
        
    }
    //NSLog(@"5");
    if (!didEndGameAlready) {
        didEndGameAlready = true;
        
        [self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
        
        if (allowVideoToConvert==false)
            [Kamcord cancelConversionForLatestVideo];

        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene: [MainMenuLayer scene]]];
        //        [[CCDirector sharedDirector] pushScene:[MainMenuLayer scene]];
        
        //NSLog(@"7");
    }
}

- (void)launchSurvey {
    [Flurry logEvent:@"Launched survey from gameplaylayer"];
    NSURL *url = [NSURL URLWithString:@"https://docs.google.com/spreadsheet/viewform?formkey=dGwxbVRnd1diQTlKTkpBUE5mRHRBMGc6MQ#gid=0"];//"http://www.surveymonkey.com/s/VJJ3RGJ"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)tryHighScore {
    // LOL T NOOBS
    int finalScore = score + prevCurrentPtoPScore;
    //NSLog(@"1");
    if ([[PlayerStats sharedInstance] isHighScore:finalScore]) {
        //NSLog(@"2");
        NSString *playerName = displayName.string;
        //NSLog(@"3");
        [[PlayerStats sharedInstance] addScore:score+prevCurrentPtoPScore withName:playerName];
        //NSLog(@"4");
        [[PlayerStats sharedInstance] setRecentName:playerName];
        [DataStorage storeData];
        if ([[[[[CCDirector sharedDirector] view] window] subviews]containsObject:playerNameLabel])
            [playerNameLabel removeFromSuperview];
        
    }
}

- (void)restartGame {
    [self tryHighScore];
    [self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
    [Flurry logEvent:@"restarted game"];
    scoreAlreadySaved = NO;
    if ([[PlayerStats sharedInstance] getPlays] == 1) {
        [[PlayerStats sharedInstance] addPlay];
    }
    //CCLOG(@"number of plays ever: %i", [[PlayerStats sharedInstance] getPlays]);
    [((AppDelegate*)[[UIApplication sharedApplication]delegate])setIsInTutorialMode:FALSE];
    
    [[UIApplication sharedApplication]setStatusBarOrientation:[[UIApplication sharedApplication]statusBarOrientation]];
    
    //CCLOG(@"GameplayLayerScene launched, game starting");
    if (allowVideoToConvert==false)
        [Kamcord cancelConversionForLatestVideo];

    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        if (location.x >= 7 * size.width/8 && location.y >= 5*size.height/6) {
            if (!paused && !isGameOver)
                [self togglePause];
        }
        if (loading_playerHasReachedFirstPlanet==false)
            return;
        
        //else if (orbitState == 0) {
        [player setThrustBeginPoint:location];
        //playerIsTouchingScreen=true;
        //}
        
        if (!isKeyboardShowing && location.x <= size.width/3 && location.y >= 4*size.height/5) {
            [self showKeyboard];
        } else
            [self hideKeyboard];
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (loading_playerHasReachedFirstPlanet==false)
        return;
    
    if (orbitState == 0) {
        CGPoint location;
        for (UITouch *touch in touches) {
            location = [touch locationInView:[touch view]];
            location = [[CCDirector sharedDirector] convertToGL:location];
            [player setThrustEndPoint:location];
            swipeVector = ccpAdd(ccp(-player.thrustBeginPoint.x,-player.thrustBeginPoint.y), player.thrustEndPoint);
            player.positionAtLastThrust = player.sprite.position;
            player.rotationAtLastThrust = player.sprite.rotation;
        }
    }
    
    if (ccpLength(swipeVector) >= minSwipeStrength && orbitState == 0 && !playerIsTouchingScreen && player.alive) {
        playerIsTouchingScreen = true;
        [self JustSwiped];
        numTimesSwiped++;
    }
}

- (void)JustSwiped {
    orbitState = 1;
    targetPlanet = [planets objectAtIndex: (lastPlanetVisited.number + 1)];
    
    if (feverModePlanetHitsInARow >= minPlanetsInARowForFeverMode) {
        [self UpdateFeverMode];
    }
    
    if (false)
        if (isInFeverMode) {
            [thrustBurstParticle setPosition:player.sprite.position];
            [thrustBurstParticle setAngle:180+CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity))];
            [thrustBurstParticle resetSystem];
        }
    
}

-(void)removeOldPredLine {
    for (CCSprite * sprite in predPoints) {
        [sprite removeAllChildrenWithCleanup:YES];
        [sprite removeFromParentAndCleanup:YES];
    }
    //    [predPoints removeAllObjects];
}

- (void)createPredPointsFrom:(CGPoint)fromPos to:(CGPoint)toPos withColor:(ccColor3B)col andRemoveOldLine:(bool)shouldRemove {
    if (shouldRemove)
        [self removeOldPredLine];
    
    predPoints = [[NSMutableArray alloc] init];
    float currentDist = INT_MAX;
    
    CCSprite* point = [CCSprite spriteWithSpriteFrameName:@"point.png"];
    CGPoint dir = ccpNormalize(ccpSub(toPos, fromPos));
    
    int i = 0;
    while (currentDist > point.width*3)
    {
        CCSprite* p1 = [CCSprite spriteWithSpriteFrameName:@"point.png"];
        p1.color = col;
        
        p1.position = ccpAdd(fromPos, ccpMult(dir, i*1.5*p1.width + p1.width/2));
        p1.rotation = -1*CC_RADIANS_TO_DEGREES(ccpToAngle(dir));
        
        currentDist = ccpDistance(toPos, p1.position);
        
        [predPoints addObject:p1];
        
        i++;
    }
    
    CCSprite* tip = [CCSprite spriteWithSpriteFrameName:@"justthetip.png"];
    tip.scale = .5;
    tip.color = col;
    
    tip.position = ccpAdd(fromPos, ccpMult(dir, i*1.5*point.width + point.width/2));
    tip.rotation = -1*CC_RADIANS_TO_DEGREES(ccpToAngle(dir));
    
    [predPoints addObject:tip];
    
    //NSLog(@"adding pred");
    for (CCSprite* s in predPoints)
        [spriteSheet addChild:s];
    point = nil;
    
    for (CCSprite* s in predPoints)
        [s runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                                                        [CCScaleTo actionWithDuration:.05 scale:s.scale*1.3],
                                                        [CCScaleTo actionWithDuration:.1 scale:s.scale],
                                                        [CCFadeOut actionWithDuration:1.5],
                                                        [CCCallBlock actionWithBlock:(^{ [s removeFromParentAndCleanup:true]; })],
                                                        nil]]];
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    playerIsTouchingScreen = false;
    
    
    if (orbitState == 0) {
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInView:[touch view]];
            location = [[CCDirector sharedDirector] convertToGL:location];
            [player setThrustEndPoint:location];
            swipeVector = ccpAdd(ccp(-player.thrustBeginPoint.x,-player.thrustBeginPoint.y), player.thrustEndPoint);
        }
    }
    
}

double lerpd(double a, double b, double t) {
    return a + (b - a) * t;
}

float lerpf(float a, float b, float t) {
    return a + (b - a) * t;
}

- (float) randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

- (int)RandomBetween:(int)minvalue maxvalue:(int)maxvalue  {
    int randomNumber = minvalue+  arc4random() % (1+maxvalue-minvalue);
    return randomNumber;
}

- (CGPoint)GetPlayerPositionOnScreen {
    return [cameraLayer convertToWorldSpace:player.sprite.position];
}

- (bool)IsNonConvertedPositionOnScreen:(CGPoint)position {
    return CGRectContainsPoint(CGRectMake(0, 0, size.width, size.height), position);
}

- (bool)IsPositionOnScreen:(CGPoint)position{
    return CGRectContainsPoint(CGRectMake(0, 0, size.width, size.height), [cameraLayer convertToWorldSpace:position]);
}

- (void)pauseGame {
    paused = NO;
    [self togglePause];
}

- (void)unpauseGame {
    paused = YES;
    [((AppDelegate*)[[UIApplication sharedApplication]delegate])setWasJustBackgrounded:false];
    [self togglePause];
}

/*
 -(void)facebookShareStartedWithSuccess:(BOOL)success error:(KCShareStatus)error {
 [[UserWallet sharedInstance] addCoins: 100];
 }
 -(void)youTubeUploadStartedWithSuccess:(BOOL)success error:(KCShareStatus)error {
 [[UserWallet sharedInstance] addCoins: 100];
 }
 -(void)twitterShareStartedWithSuccess:(BOOL)success error:(KCShareStatus)error {
 [[UserWallet sharedInstance] addCoins: 100];
 }
 -(void)emailSentWithSuccess:(BOOL)success error:(KCShareStatus)error{
 [[UserWallet sharedInstance] addCoins: 100];
 }*/

-(void)showRecording {
    muted = false;
    [self toggleMute];
    //[Kamcord stopRecording];
    allowVideoToConvert = true;
    [Kamcord showView];
}

+(CCSprite*)labelWithString:(NSString *)string fontName:(NSString *)fontName fontSize:(CGFloat)fontSize color:(ccColor3B)color strokeSize:(CGFloat)strokeSize stokeColor:(ccColor3B)strokeColor{CCLabelTTF *label = [CCLabelTTF labelWithString:string fontName:fontName fontSize:fontSize];CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:label.texture.contentSize.width + strokeSize*2  height:label.texture.contentSize.height+strokeSize*2];[label setFlipY:YES];[label setColor:strokeColor];ccBlendFunc originalBlendFunc = [label blendFunc];[label setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];CGPoint bottomLeft = ccp(label.texture.contentSize.width * label.anchorPoint.x + strokeSize, label.texture.contentSize.height * label.anchorPoint.y + strokeSize);CGPoint position = ccpSub([label position], ccp(-label.contentSize.width / 2.0f, -label.contentSize.height / 2.0f));[rt begin];for (int i=0; i<360; i++)/*you should optimize that for your needs*/{[label setPosition:ccp(bottomLeft.x + sin(CC_DEGREES_TO_RADIANS(i))*strokeSize, bottomLeft.y + cos(CC_DEGREES_TO_RADIANS(i))*strokeSize)];[label visit];}[label setPosition:bottomLeft];[label setBlendFunc:originalBlendFunc];[label setColor:color];[label visit];[rt end];[rt setPosition:position];return [CCSprite spriteWithTexture:rt.sprite.texture];}

-(CCLayer*)createPauseLayer {
    layerToAdd = [[CCLayer alloc] init];
    [layerToAdd addChild:[[ObjectiveManager sharedInstance] createMissionPopupWithX:false withDark:true]];
    
    
    CCSprite* topBar = [CCSprite spriteWithFile:@"banner.png"];
    [layerToAdd addChild:topBar];
    [topBar setPosition: ccp(240, 320 - topBar.boundingBox.size.height/2 + 2)];
    
    NSString* stringToUse;
    stringToUse = @"GAME PAUSED";
    
    CCSprite* topSpriteLabel = [self.class labelWithString:stringToUse fontName:@"HelveticaNeue-CondensedBold" fontSize:31 color:ccWHITE strokeSize:1.1 stokeColor: ccBLACK];
    [layerToAdd addChild:topSpriteLabel];
    topSpriteLabel.position = ccp(240, 300.5);
    
    CCMenuItem *replay = [CCMenuItemImage
                          itemWithNormalImage:@"retry.png" selectedImage:@"retrypressed.png"
                          target:self selector:@selector(restartGame)];
    replay.position = ccp(240, 20);
    
    CCMenuItem *resume = [CCMenuItemImage
                          itemWithNormalImage:@"resume.png" selectedImage:@"resumepressed.png"
                          target:self selector:@selector(unpauseGame)];
    resume.position = ccp(360, 20);
    
    CCMenuItem *quit = [CCMenuItemImage
                        itemWithNormalImage:@"quit.png" selectedImage:@"quitpressed.png"
                        target:self selector:@selector(endGame)];
    quit.position = ccp(120, 20);
    
    soundButton = [CCMenuItemImage
                   itemWithNormalImage:@"sound.png" selectedImage:@"soundpressed.png"
                   target:self selector:@selector(toggleMute)];
    CCMenuItem *sound = soundButton;
    sound.position = ccp(449, 300.5);
    
    CCMenu* menu = [CCMenu menuWithItems:replay, resume, quit, sound, nil];
    menu.position = ccp(0, 0);
    
    [layerToAdd addChild:menu];
    
    return layerToAdd;
}

- (void)unscheduleEverythingButTutorialStuff {
    [self unscheduleUpdates];
    [streak unscheduleUpdate];
    [galaxyLabel pauseSchedulerAndActions];
    [cometParticle unscheduleUpdate];
    [thrustParticle unscheduleUpdate];
    [feverModeInitialExplosionParticle unscheduleUpdate];
    [feverModeLabelParticle unscheduleUpdate];
    for (Coin* coin in coins)
        [coin.sprite pauseSchedulerAndActions];
    for (CCNode* node in predPoints)
        [node pauseSchedulerAndActions];
}

- (void)rescheduleEverythingButTutorialStuff {
    [self scheduleUpdates];
    [streak scheduleUpdate];
    [cometParticle scheduleUpdate];
    [galaxyLabel resumeSchedulerAndActions];
    [thrustParticle scheduleUpdate];
    [feverModeInitialExplosionParticle scheduleUpdate];
    [feverModeLabelParticle scheduleUpdate];
    for (Coin* coin in coins)
        [coin.sprite resumeSchedulerAndActions];
    for (CCNode* node in predPoints)
        [node resumeSchedulerAndActions];
}

-(void)pauseWithDuration:(float)a_duration message:(NSString*)a_message {
    bool isOnRegularPause = (a_duration == 0 && a_message == @"");
    if (!isOnRegularPause)
        isDoingTutStuff = true;
    pauseDuration = .1; //a_duration; //LOL of got frustrated
    pauseText = a_message;
    
    if (!pauseEnabled) {
        return;
    }
    paused = !paused;
    if (paused) {
        [Kamcord pause];
        [self unscheduleEverythingButTutorialStuff];
        
        if (isOnRegularPause) {
            [self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
            pauseLayer = [self createPauseLayer];//(CCLayer*)[CCBReader nodeGraphFromFile:@"PauseMenuLayer.ccb" owner:self];
            [gameOverScoreLabel setString:[NSString stringWithFormat:@"Score: %d",score+prevCurrentPtoPScore]];
            [pauseLayer setTag:pauseLayerTag];
            muted = ![[PlayerStats sharedInstance] isMuted];
            [self toggleMute];
            [self addChild:pauseLayer];
        }
        else {
            [self schedule:@selector(UpdateTutorial:) interval:0];
        }
    }
    else {
        [self unschedule:@selector(UpdateTutorial:)];
        [Kamcord resume];
        [self rescheduleEverythingButTutorialStuff];
        [self removeChildByTag:pauseLayerTag cleanup:NO];
    }
}

- (void) UpdateTutorial:(ccTime)dt {
    if (!isDoingTutStuff)
        return;
    
    if (tutCounter == 0) {
        pauseLabel = [CCLabelTTF labelWithString:pauseText dimensions:CGSizeMake(390, 320) hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentTop lineBreakMode:kCCLineBreakModeWordWrap fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
        pauseLabel.anchorPoint = ccp(.5, 1);
        pauseLabel.position = ccp(240, 320);
        pauseLabel.opacity = 0;
        [self addChild: pauseLabel];
        
        [pauseLabel runAction:[CCFadeIn actionWithDuration:.4]];
    }
    
    if (isDoingTutStuff)
        tutCounter += dt;
    
    if (tutCounter >= pauseDuration)
        if (!hasOpenedTut) {
            hasOpenedTut = true;
            
            continueLabel = [CCLabelTTF labelWithString:@"Tap to continue..." fontName:@"HelveticaNeue-CondensedBold" fontSize:20];
            continueLabel.anchorPoint = ccp(.5, 0);
            continueLabel.position = ccp(240, 60);
            continueLabel.opacity = 0;
            [self addChild: continueLabel];
            [continueLabel runAction:[CCFadeIn actionWithDuration:.7]];
            
            
            soundButton = [CCMenuItemImage
                           itemWithNormalImage:@"blank.png" selectedImage:@"blank.png"
                           target:self selector:@selector(continueTut)];
            CCMenuItem *sound = soundButton;
            sound.position = ccp(240, 160);
            sound.scaleX = 480;
            sound.scaleY = 320;
            
            CCMenu* menu = [CCMenu menuWithItems:sound, nil];
            menu.position = ccp(0, 0);
            
            tutLayer = [[CCLayer alloc] init];
            [tutLayer addChild:menu];
            [hudLayer addChild:tutLayer];
        }
}

-(void) continueTut {
    
    tutCounter = 0;
    hasOpenedTut = false;
    isDoingTutStuff = false;
    [pauseLabel removeFromParentAndCleanup:true];
    [continueLabel removeFromParentAndCleanup:true];
    [tutLayer removeFromParentAndCleanup:true];
    [self togglePause];
}

- (void)togglePause {
    [self pauseWithDuration:0 message:@""];
}

- (void)toggleMute {
    muted = !muted;
    if (!muted) {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:musicVolumeGameplay];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:effectsVolumeGameplay];
        [soundButton setNormalImage:[CCSprite spriteWithFile:@"sound.png"]];
        [soundButton setSelectedImage:[CCSprite spriteWithFile:@"soundpressed.png"]];
        [soundButton setDisabledImage:[CCSprite spriteWithFile:@"sound.png"]];
    } else {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
        [soundButton setNormalImage:[CCSprite spriteWithFile:@"soundmuted.png"]];
        [soundButton setSelectedImage:[CCSprite spriteWithFile:@"soundmutedpressed.png"]];
        [soundButton setDisabledImage:[CCSprite spriteWithFile:@"soundmuted.png"]];
    }
    [[PlayerStats sharedInstance] setIsMuted:muted];
}

#if !defined(MIN)
#define MIN(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __a : __b; })
#endif

#if !defined(MAX)
#define MAX(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __b : __a; })
#endif

@end
