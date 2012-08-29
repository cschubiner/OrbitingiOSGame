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


const float musicVolumeGameplay = 1;
const float effectsVolumeGameplay = 1;
const int maxNameLength = 8;

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
    
    int feverModePlanetHitsInARow;
    float timeInOrbit;
    CCLabelTTF* feverLabel;
    CCLayer* loadedPauseLayer;
    NSString *blankAvoiderName;
    BOOL isKeyboardShowing;
    
    BOOL pauseEnabled;
    int asteroidsCrashedInto;
    int asteroidsDestroyedWithArmor;
    int numTimesSwiped;
    int numTimesDied;
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
    [coin.sprite setScale:scale*.8];
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
    [spriteSheet addChild:coin.sprite];
    //[spriteSheet addChild:coin.sprite];
    //[spriteSheet reorderChild:coin.sprite z:5];
    //NSLog(@"ended coin");
    
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
    
    [spriteSheet addChild:powerup.sprite];
    [spriteSheet addChild:powerup.glowSprite];
    
    //NSLog(@"galaxy114powerup");
    [spriteSheet reorderChild:powerup.glowSprite z:2.5];
    
    //NSLog(@"ended powerup");
    
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
    asteroid.sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"asteroid%d.png",[self RandomBetween:1 maxvalue:3]]];
    asteroid.sprite.position = ccp(xPos, yPos);
    [asteroid.sprite setScale:scale];
    asteroid.whichSegmentThisObjectIsOriginallyFrom = originalSegmentNumber;
    asteroid.segmentNumber = makingSegmentNumber;
    asteroid.number = asteroids.count;
    asteroid.whichGalaxyThisObjectBelongsTo = currentGalaxy.number;
    [asteroids addObject:asteroid];
    [spriteSheet addChild:asteroid.sprite];
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
    
    [currentGalaxy.spriteSheet addChild:planet.sprite];
    [currentGalaxy.spriteSheet addChild:zone.sprite];
    planetCounter++;
    //NSLog(@"ended planet and zone");
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
        CGPoint positionForCoin = [self getPositionBasedOnOrigin:position offset:coinPosArray[i] andAngle:angle];
        [self CreateCoin:positionForCoin.x yPos:positionForCoin.y scale:1];
    }
}

- (bool)CreateSegment
{
    float rotationOfSegment = CC_DEGREES_TO_RADIANS([self RandomBetween:-segmentRotationVariation+directionPlanetSegmentsGoIn maxvalue:segmentRotationVariation+directionPlanetSegmentsGoIn]);
    Galaxy *galaxy = currentGalaxy;
    originalSegmentNumber = [self RandomBetween:0 maxvalue:[[galaxy segments ]count]-1];
    NSArray *chosenSegment = [[galaxy segments] objectAtIndex:originalSegmentNumber];
    
    int planetsInSegment = 0;
    for (int i = 0 ; i < [chosenSegment count]; i++) {
        LevelObjectReturner * returner = [chosenSegment objectAtIndex:i];
        if (returner.type == kplanet)
            planetsInSegment++;
    }
    
    int futurePlanetCount = planetsHitSinceNewGalaxy + planetsInSegment;
    if (abs(currentGalaxy.optimalPlanetsInThisGalaxy-planetsHitSinceNewGalaxy)<abs(currentGalaxy.optimalPlanetsInThisGalaxy-futurePlanetCount))
        return false;
    
    segmentsSpawnedFlurry++;

    int levelFlipper;
    if ([self RandomBetween:0 maxvalue:100]>50) {
        levelFlipper = -1; //flip segment
    }
    else levelFlipper = 1; //don't flip segment
    
    for (int i = 0 ; i < [chosenSegment count]; i++) {
        LevelObjectReturner * returner = [chosenSegment objectAtIndex:i];
        CGPoint newPos = ccpRotateByAngle(ccp(returner.pos.x+(indicatorPos).x,levelFlipper*returner.pos.y+(indicatorPos).y), indicatorPos, rotationOfSegment);
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
    galaxies = [[NSArray alloc]initWithObjects:
#include "LevelsFromLevelCreator"
                nil];
}

- (void)setGalaxyProperties {
    Galaxy* galaxy;
    galaxy = [galaxies objectAtIndex:0];
    [galaxy setName:@"Galaxy 1"];
    [galaxy setNumberOfDifferentPlanetsDrawn:7];
    [galaxy setOptimalPlanetsInThisGalaxy:17];
    [galaxy setPercentTimeToAddUponGalaxyCompletion:.56];
    [galaxy setGalaxyColor: ccc3(45*.5, 53*.5, 147*.5)]; //a dark blue
    
    galaxy = [galaxies objectAtIndex:1];
    [galaxy setName:@"Galaxy 2"];
    [galaxy setNumberOfDifferentPlanetsDrawn:3];
    [galaxy setOptimalPlanetsInThisGalaxy:21];
    [galaxy setPercentTimeToAddUponGalaxyCompletion:.408888];
    [galaxy setGalaxyColor: ccc3(0, 103, 3)];
    
    galaxy = [galaxies objectAtIndex:2];
    [galaxy setName:@"Galaxy 3"];
    [galaxy setNumberOfDifferentPlanetsDrawn:3];
    [galaxy setOptimalPlanetsInThisGalaxy:26];
    [galaxy setPercentTimeToAddUponGalaxyCompletion:.375];
    [galaxy setGalaxyColor: ccc3(114, 0, 115)];
    
    galaxy = [galaxies objectAtIndex:3];
    [galaxy setName:@"Galaxy 4"];
    [galaxy setNumberOfDifferentPlanetsDrawn:1];
    [galaxy setOptimalPlanetsInThisGalaxy:33];
    [galaxy setPercentTimeToAddUponGalaxyCompletion:.321];
    [galaxy setGalaxyColor: ccc3(0, 130, 115)];
    
    galaxy = [galaxies objectAtIndex:4];
    [galaxy setName:@"Galaxy 5"];
    [galaxy setNumberOfDifferentPlanetsDrawn:1];
    [galaxy setOptimalPlanetsInThisGalaxy:36];
    [galaxy setPercentTimeToAddUponGalaxyCompletion:.31];
    [galaxy setGalaxyColor: ccc3(154, 86, 0)];
    
    galaxy = [galaxies objectAtIndex:5];
    [galaxy setName:@"Galaxy 6"];
    [galaxy setNumberOfDifferentPlanetsDrawn:2];
    [galaxy setOptimalPlanetsInThisGalaxy:40];
    [galaxy setPercentTimeToAddUponGalaxyCompletion:.28];
    [galaxy setGalaxyColor: ccc3(42, 112, 199)];
    
    galaxy = [galaxies objectAtIndex:6];
    [galaxy setName:@"Galaxy 7"];
    [galaxy setNumberOfDifferentPlanetsDrawn:3];
    [galaxy setOptimalPlanetsInThisGalaxy:43];
    [galaxy setPercentTimeToAddUponGalaxyCompletion:.3];
    [galaxy setGalaxyColor: ccc3(161,163,42)];
    
    // for (Galaxy* galaxy in galaxies)
    // [galaxy setOptimalPlanetsInThisGalaxy:11];
}

- (void)initUpgradedVariables {
    [[UpgradeValues sharedInstance] setCoinMagnetDuration:400 + 50*[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:0] equipped]];
    
    [[UpgradeValues sharedInstance] setAsteroidImmunityDuration:400 + 50*[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:1] equipped]];
    
    [[UpgradeValues sharedInstance] setAbsoluteMinTimeDilation:.9 + .037*[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:2] equipped]];
    
    [[UpgradeValues sharedInstance] setHasDoubleCoins:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:3] equipped]];
    
    [[UpgradeValues sharedInstance] setMaxBatteryTime:60 + 5*[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:4] equipped]];
    
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
    [self schedule:@selector(Update:) interval:0];// this makes the update loop loop!!!!
    //[Kamcord startRecording];
}

- (void)loadEverything {
    [((AppDelegate*)[[UIApplication sharedApplication]delegate]) setGalaxyCounter:0];
    //isInTutorialMode = [((AppDelegate*)[[UIApplication sharedApplication]delegate]) getIsInTutorialMode];
    [self initUpgradedVariables];
    loadedPauseLayer = [self createPauseLayer];
    
    directionPlanetSegmentsGoIn = [self randomValueBetween:defaultDirectionPlanetSegmentsGoIn-directionPlanetSegmentsGoInVariance andValue:defaultDirectionPlanetSegmentsGoIn+directionPlanetSegmentsGoInVariance];
    
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
    
    [self playSound:@"kick_shock.mp3" shouldLoop:YES pitch:1];
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
    player.sprite = [CCSprite spriteWithSpriteFrameName:@"playercute.png"];
    player.alive=true;
    [player.sprite setScale:playerSizeScale];
    player.segmentNumber = -10;
    player.sprite.position = ccpAdd([self GetPositionForJumpingPlayerToPlanet:0],ccpMult(ccpForAngle(CC_DEGREES_TO_RADIANS(defaultDirectionPlanetSegmentsGoIn)), -3200*100));
    // player.sprite.position = [self GetPositionForJumpingPlayerToPlanet:0];
    if ([[UpgradeValues sharedInstance] hasGreenShip]) {
        player.sprite.color = ccGREEN;
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
    /* streak=[CCLayerStreak streakWithFade:2 minSeg:3 image:@"streak2.png" width:streakWidth length:32 color:// ccc4(153,102,0, 255)  //orange
     //ccc4(255,255,255, 255) // white
     // ccc4(255,255,0,255) // yellow
     //  ccc4(0,0,255,255) // blue
     ccc4(0,255,153,255) // blue green
     // ccc4(0,255,0,255) // green
     target:player.sprite];*/
    
    streak = [CCMotionStreak streakWithFade:2 minSeg:3 width:streakWidth color:ccc3(0, 255, 153) textureFilename:@"streak2.png"];
    
    cameraFocusNode = [[CCSprite alloc]init];
    killer = 0;
    orbitState = 0; // 0 = orbiting, 1 = just left orbit and deciding things for state 3; 3 = flying to next planet
    velSoftener = 1;
    initialAccelMag = 0;
    isOnFirstRun = true;
    timeDilationCoefficient = [[UpgradeValues sharedInstance] absoluteMinTimeDilation];
    dangerLevel = 0;
    swipeVector = ccp(0, -1);
    gravIncreaser = 1;
    updatesSinceLastPlanet = 0;
    asteroidSlower = 1;
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
    
    light.scoreVelocity = initialLightScoreVelocity;
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
                                     @"Asteroids kill you; be sure to avoid them!",
                                     @"Swipe in the direction you want to move!",
                                     @"Complete missions to increase your score multiplier and earn more stars.",
                                     @"Purchase upgrades by tapping \"Upgrades\" on the main menu.",
                                     @"Have suggestions? Submit feedback by tapping \"Survey\" on the main menu.",
                                     @"Star Dash generates levels randomly to give you a unique experience every time you play!",
                                     @"Orbit planets as few times as possible to get the highest possible score.",
                                     @"Your time is limited; keep on eye on the battery in the lower-left corner of the screen.",
                                     @"Your battery recharges as you move between galaxies",
                                     @"Each galaxy brings new challenges for you to conquer!",
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
        
        id loadingLabelSetOneZero = [CCCallBlock actionWithBlock:(^{
            [loadingLabel setString:@"loading."];
        })];
        id loadingLabelSetTwoZeroes = [CCCallBlock actionWithBlock:(^{
            [loadingLabel setString:@"loading.."];
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
                                  delayBetweenLoadingLabelsAction, nil]]];
        
        
        [self scheduleOnce:@selector(loadEverything) delay:1.2];
        // [self loadEverything];
	}
	return self;
}

- (void)UpdateCamera:(float)dt {
    if (player.alive) {
        player.velocity = ccpAdd(player.velocity, player.acceleration);
        if (player.currentPowerup.type == kheadStart)
            player.velocity = ccpMult(player.velocity, 1.4);
        else if (player.currentPowerup.type == kautopilot)
            player.velocity = ccpMult(player.velocity, 1.1);
        
        player.sprite.position = ccpAdd(ccpMult(player.velocity, 60*dt*timeDilationCoefficient*asteroidSlower), player.sprite.position);
    }
    
    if (isnan(player.sprite.position.x)) {
        player.velocity = CGPointZero;
        player.sprite.position = [self GetPositionForJumpingPlayerToPlanet:lastPlanetVisited.number];
        player.acceleration = CGPointZero;
    }
    
    //camera code follows -----------------------------
    Planet * nextPlanet;
    if (lastPlanetVisited.number +1 < [planets count])
        nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number+1)];
    else     nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number-1)];
    
    float firsttoplayer = ccpToAngle(ccpSub(lastPlanetVisited.sprite.position, player.sprite.position));
    float planetAngle = ccpToAngle(ccpSub(lastPlanetVisited.sprite.position, nextPlanet.sprite.position));
    float firstToPlayerAngle = firsttoplayer-planetAngle;
    float firstToPlayerDistance = ccpDistance(lastPlanetVisited.sprite.position, player.sprite.position)*cosf(firstToPlayerAngle);
    float firsttonextDistance = ccpDistance(lastPlanetVisited.sprite.position, nextPlanet.sprite.position);
    float percentofthewaytonext = firstToPlayerDistance/firsttonextDistance;
    if (orbitState == 0 || nextPlanet.number + 1 >= [planets count])
        percentofthewaytonext*=.4f;
    
    Planet * planet1 = lastPlanetVisited;
    Planet * planet2 = nextPlanet;
    
    CGPoint sub = ccpSub(planet2.sprite.position, planet1.sprite.position);
    CGPoint mult = ccpMult(sub, percentofthewaytonext);
    CGPoint focusPointOne = ccpAdd(mult ,planet1.sprite.position);
    planet1 = [planets objectAtIndex:MIN([planets count]-1, lastPlanetVisited.number+2)];
    planet2 = [planets objectAtIndex:MIN([planets count]-1, lastPlanetVisited.number+3)];
    if (planet2.whichGalaxyThisObjectBelongsTo != lastPlanetVisited.whichGalaxyThisObjectBelongsTo)
        percentofthewaytonext *=.4f;
    CGPoint focusPointTwo = ccpAdd(ccpMult(ccpSub(planet2.sprite.position, planet1.sprite.position), percentofthewaytonext) ,planet1.sprite.position);
    
    // if (planet2.whichGalaxyThisObjectBelongsTo != lastPlanetVisited.whichGalaxyThisObjectBelongsTo)
    //      focusPointTwo = nextPlanet.sprite.position;
    float extraScaleFactor = 0;
    if (planet2.whichGalaxyThisObjectBelongsTo != lastPlanetVisited.whichGalaxyThisObjectBelongsTo)
        extraScaleFactor = 16;
    
    
    CGPoint focusPosition = ccpMult(ccpAdd(ccpMult(focusPointOne,extraScaleFactor+ cameraScaleFocusedOnFocusPosOne), focusPointTwo), 1.0f/(extraScaleFactor+ cameraScaleFocusedOnFocusPosOne+1.0f));
    cameraDistToUse= lerpf(cameraDistToUse,ccpDistance(focusPointOne, focusPointTwo),cameraZoomSpeed);
    
    float horizontalScale = 294.388933833*pow(cameraDistToUse,-.94226344467);
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
    
    if ([cameraLayer scale]<.3) {
        // NSLog(@"\n\n\nALERT: cameraLayer scale should be bigger this this, we prob has an error");
        [cameraLayer setScale:.3];
    }
    
        float scale = zoomMultiplier*horizontalScale*scalerToUse;
        if (cameraShouldFocusOnPlayer&&false) {
            focusPosition = player.sprite.position;
            scale = cameraScaleWhenTransitioningBetweenGalaxies;
        }
        if (planet2.whichGalaxyThisObjectBelongsTo != lastPlanetVisited.whichGalaxyThisObjectBelongsTo&&scale<.3)
            scale=.3;
        cameraLastFocusPosition = ccpLerp(cameraLastFocusPosition, focusPosition, cameraMovementSpeed);
        [self scaleLayer:cameraLayer scaleToZoomTo:lerpf([cameraLayer scale], scale, cameraZoomSpeed) scaleCenter:cameraLastFocusPosition];
        [cameraLayer runAction: [CCFollow actionWithTarget:cameraFocusNode]];
}

- (void) scaleLayer:(CCLayer*)layerToScale scaleToZoomTo:(CGFloat) newScale scaleCenter:(CGPoint) scaleCenter {
    // Get the original center point.
    CGPoint oldCenterPoint = ccp(scaleCenter.x * layerToScale.scale, scaleCenter.y * layerToScale.scale);
    // Set the scale.
    layerToScale.scale = newScale;
    // Get the new center point.
    CGPoint newCenterPoint = ccp(scaleCenter.x * layerToScale.scale, scaleCenter.y * layerToScale.scale);
    cameraFocusNode.position = newCenterPoint;
    // Then calculate the delta.
    CGPoint centerPointDelta  = ccpSub(oldCenterPoint, newCenterPoint);
    // Now adjust layer by the delta.
    layerToScale.position = ccpAdd(layerToScale.position, centerPointDelta);
}

- (void)UserTouchedCoin: (Coin*)coin dt:(float)dt{
    
    [[UserWallet sharedInstance] addCoins: ([[UpgradeValues sharedInstance] hasDoubleCoins] ? 2 : 1) ];
    score += howMuchCoinsAddToScore*([[UpgradeValues sharedInstance] hasDoubleCoins] ? 2 : 1);
    
    CGPoint coinPosOnHud = [cameraLayer convertToWorldSpace:coin.sprite.position];
    coin.movingSprite.position = ccp(coinPosOnHud.x+4, coinPosOnHud.y-4);
    
    
    [coin.movingSprite runAction:[CCSequence actions:
                                  [CCSpawn actions:[CCAnimate actionWithAnimation:coinAnimation],
                                   [CCSequence actions:[CCMoveTo actionWithDuration:.28 position:coinsLabel.position],[CCHide action],nil], nil],
                                  [CCHide action],
                                  [CCCallFunc actionWithTarget:self selector:@selector(coinDone)],
                                  nil]];
    
    //id scaleAction = [CCScaleTo actionWithDuration:.1 scale:.2*coin.sprite.scale];
    // [coin.sprite runAction:[CCSequence actions:[CCSpawn actions:scaleAction,[CCRotateBy actionWithDuration:.1 angle:360], nil],[CCHide action], nil]];
    [coin.sprite setVisible:false];
    [cameraLayer removeChild:coin.sprite cleanup:YES];
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
    //[Kamcord playSound:soundFile loop:shouldLoop];
    if (shouldLoop)
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:soundFile loop:YES];
    else
        return [[SimpleAudioEngine sharedEngine]playEffect:soundFile pitch:pitch pan:0 gain:1];
    return 0;
}

- (void)ApplyGravity:(float)dt {
    
    for (Coin* coin in coins) {
        
        CGPoint p = coin.sprite.position;
        coin.velocity = ccpMult(ccpNormalize(ccpSub(player.sprite.position, p)), coin.speed);
        if (coin.isAlive)
            coin.sprite.position = ccpAdd(coin.sprite.position, coin.velocity);
        
        if (ccpLength(ccpSub(player.sprite.position, p)) <= coin.radius + player.sprite.height/1.5 && coin.isAlive) {
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
    
    /*if (!(player.currentPowerup.type == kasteroidImmunity)) {
     if (isHittingAsteroid)
     asteroidSlower -= .1;
     else
     asteroidSlower += .01;
     asteroidSlower = clampf(asteroidSlower, .13, 1);
     }*/
    
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
                }
            }
        }
    
    if (player.currentPowerup != nil) {
        
        int updatesLeft = player.currentPowerup.duration - powerupCounter;
        float blinkAfterThisManyUpdates = updatesLeft*.12;
        
        if (player.currentPowerup.glowSprite.visible) {
            updatesWithoutBlinking++;
        }
        
        if (updatesWithoutBlinking >= blinkAfterThisManyUpdates && updatesLeft <= 300) {
            updatesWithoutBlinking = 0;
            [player.currentPowerup.glowSprite setVisible:false];
            
        }
        if (!player.currentPowerup.glowSprite.visible) {
            updatesWithBlinking++;
        }
        
        if (updatesWithBlinking >= clampf(8*updatesLeft/100, 3, 99999999)) {
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
                initialVel = ccp(0, sqrtf(planet.orbitRadius*gravity));
                isOnFirstRun = false;
                player.velocity = initialVel;
            }
            
            if (orbitState == 0) {
                if (!loading_playerHasReachedFirstPlanet) {
                    
                    dangerLevel = 0;
                    
                    CGPoint a = ccpSub(player.sprite.position, planet.sprite.position);
                    
                    player.sprite.position = ccpAdd(player.sprite.position, ccpMult(ccpNormalize(a), (planet.orbitRadius*.0 - ccpLength(a))*howFastOrbitPositionGetsFixed*timeDilationCoefficient*60*dt/[[UpgradeValues sharedInstance] absoluteMinTimeDilation]));
                    
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
                        feverModePlanetHitsInARow = 0;
                        [feverLabel setString:[NSString stringWithFormat:@""]];
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
                    
                    float howMuchOfSwipeVectorToUse = .35;
                    CGPoint vectorToCheck = ccpAdd(ccpMult(ccpNormalize(swipeVector), howMuchOfSwipeVectorToUse), ccpMult(ccpNormalize(player.velocity), 1-howMuchOfSwipeVectorToUse));
                    
                    float newAng = 0;
                    //CGPoint vel = CGPointZero;
                    if (ccpLength(ccpSub(ccpAdd(player.sprite.position, vectorToCheck), left)) <= ccpLength(ccpSub(ccpAdd(player.sprite.position, vectorToCheck), right))) { //closer to the left
                        float distToUse2 = factorToPlaceGravFieldWhenCrossingOverTheMiddle; //crossing over the middle
                        if (ccpLength(ccpSub(player.sprite.position, spot1)) < ccpLength(ccpSub(player.sprite.position, spot2)))
                            distToUse2 = factorToPlaceGravFieldWhenStayingOutside; //staying outside
                        spotGoingTo = ccpAdd(ccpMult(dir2, targetPlanet.orbitRadius*distToUse2), targetPlanet.sprite.position);
                        newAng = ccpToAngle(ccpSub(left, player.sprite.position));
                        //vel = ccpSub(left, player.sprite.position);
                    }
                    else {
                        float distToUse2 = factorToPlaceGravFieldWhenCrossingOverTheMiddle; //crossing over the middle
                        if (ccpLength(ccpSub(player.sprite.position, spot1)) > ccpLength(ccpSub(player.sprite.position, spot2)))
                            distToUse2 = factorToPlaceGravFieldWhenStayingOutside; //staying outside
                        spotGoingTo = ccpAdd(ccpMult(dir3, targetPlanet.orbitRadius*distToUse2), targetPlanet.sprite.position);
                        newAng = ccpToAngle(ccpSub(right, player.sprite.position));
                        //vel = ccpSub(right, player.sprite.position);
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
                        feverModePlanetHitsInARow = 0;
                    
                    timeInOrbit = 0;
                    
                    if (feverModePlanetHitsInARow >= minPlanetsInARowForFeverMode)
                        [feverLabel setString:[NSString stringWithFormat:@"%d Combo!", feverModePlanetHitsInARow]];
                    else
                        [feverLabel setString:[NSString stringWithFormat:@""]];
                    
                    
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
                        dangerLevel += .02;
                    }
                }
                
                CGPoint accelToAdd = CGPointZero;
                CGPoint direction = ccpNormalize(ccpSub(spotGoingTo, player.sprite.position));
                accelToAdd = ccpAdd(accelToAdd, ccpMult(direction, gravity));
                
                player.velocity = ccpMult(ccpNormalize(player.velocity), ccpLength(initialVel));
                
                float scaler = multiplyGravityThisManyTimesOnPerfectSwipe - swipeAccuracy * multiplyGravityThisManyTimesOnPerfectSwipe / 180;
                scaler = clampf(scaler, 0, 99999999);
                
                player.acceleration = ccpMult(accelToAdd, [[UpgradeValues sharedInstance] absoluteMinTimeDilation]*1.11*gravIncreaser*freeGravityStrength*scaler*asteroidSlower*60*dt);
                if (player.currentPowerup.type == kheadStart)
                    player.acceleration = ccpMult(player.acceleration, 9);
                else if (player.currentPowerup.type == kautopilot)
                    player.acceleration = ccpMult(player.acceleration, 2);
                
                if (initialAccelMag == 0)
                    initialAccelMag = ccpLength(player.acceleration);
                else
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

// FIX you don't really need planetIndex passed in because it's just going to spawn at the position of the last thrust point anyway
- (void)RespawnPlayerAtPlanetIndex:(int)planetIndex asteroidHit:(Asteroid*)asteroidHit {
    numTimesDied++;
    feverModePlanetHitsInARow = 0;
    [feverLabel setString:[NSString stringWithFormat:@""]];
    
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
    id moveAction = [CCMoveTo actionWithDuration:.2 position:pToGoTo];
    id blink = [CCBlink actionWithDuration:delayTimeAfterPlayerExplodes-.2 blinks:(delayTimeAfterPlayerExplodes-.2)*respawnBlinkFrequency];
    id movingSpawnActions = [CCSpawn actions:moveAction, [CCRotateTo actionWithDuration:.2 angle:player.rotationAtLastThrust], nil];
    player.moveAction = [CCSequence actions:[CCHide action],movingSpawnActions,blink, [CCShow action], nil];
    
    [player.sprite runAction:player.moveAction];
    [thrustParticle stopSystem];
    streak.visible = false;
    player.alive = false;
    
    CGPoint vel = ccpSub(pToGoTo, curPlanetPos);
    if (wasGoingClockwise)
        vel = CGPointApplyAffineTransform(vel, CGAffineTransformMakeRotation(-M_PI/2));
    else
        vel = CGPointApplyAffineTransform(vel, CGAffineTransformMakeRotation(M_PI/2));
    
    
    player.velocity = ccpMult(ccpNormalize(vel), 9);//ccp(0, .05);
    player.acceleration=CGPointZero;
    
    [Flurry logEvent:@"Player Died" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Galaxy %d-%d",currentGalaxy.number+1,lastPlanetVisited.whichSegmentThisObjectIsOriginallyFrom+1],@"Location of death",[NSNumber numberWithInt:currentGalaxy.number],@"Galaxy",[NSNumber numberWithInt:numZonesHitInARow],@"Pre-death combo", nil]];
    
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
    [cameraLayer addChild:thrustParticle z:2];
    [cameraLayer addChild:thrustBurstParticle z:2];
    [cameraLayer addChild:streak z:1];
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
    Galaxy * lastGalaxy = nil;
    if (currentGalaxy.number>0)
        lastGalaxy = [galaxies objectAtIndex:currentGalaxy.number-1];
    for (int i = 0 ; i < [array count]; i++) {
        CameraObject * object = [array objectAtIndex:i];
        object.segmentNumber--;
        if (object.segmentNumber == -1 ) {
            if ([[spriteSheet children]containsObject:object.sprite])
                [spriteSheet removeChild:object.sprite cleanup:YES];
            if (lastGalaxy)
                if ([[lastGalaxy.spriteSheet children]containsObject:object.sprite])
                    [lastGalaxy.spriteSheet removeChild:object.sprite cleanup:YES];
            if ([[currentGalaxy.spriteSheet children]containsObject:object.sprite])
                [currentGalaxy.spriteSheet removeChild:object.sprite cleanup:YES];
            
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
        
        if (
            //nextPlanet.whichGalaxyThisObjectBelongsTo > lastPlanetVisited.whichGalaxyThisObjectBelongsTo||
            targetPlanet.whichGalaxyThisObjectBelongsTo>lastPlanetVisited.whichGalaxyThisObjectBelongsTo || loading_playerHasReachedFirstPlanet==false) {
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
            
            ccColor3B lastColor = thisGalaxy.galaxyColor;
            ccColor3B nextColor = nextGalaxy2.galaxyColor;
            
            [backgroundClouds setColor:ccc3(lerpf(lastColor.r, nextColor.r, percentofthewaytonext),
                                            lerpf(lastColor.g, nextColor.g, percentofthewaytonext),
                                            lerpf(lastColor.b, nextColor.b, percentofthewaytonext))];
            
            if (percentofthewaytonext>.85&&justDisplayedGalaxyLabel==false&&(int)galaxyLabel.opacity<=0)
            {
                if ([[cameraLayer children]containsObject:currentGalaxy.spriteSheet]==false) {
                    Galaxy * lastGalaxy = [galaxies objectAtIndex:currentGalaxy.number-1];
                   
                    
                    if ([[cameraLayer children]containsObject:lastGalaxy.spriteSheet]) {
                        [cameraLayer removeChild:lastGalaxy.spriteSheet cleanup:YES];
                        }
                    
                    [cameraLayer addChild:currentGalaxy.spriteSheet z:3];
                    //NSLog(@"galaxy1155");
                    [cameraLayer reorderChild:spriteSheet z:4];
                    [cameraLayer reorderChild:streak z:4];
                    [cameraLayer reorderChild:thrustParticle z:4];
                    [cameraLayer reorderChild:thrustBurstParticle z:4];
                    
                }
                //NSLog(@"galaxy4");
                
                [self CheckMissionsGalaxyChange];
                
                
                flurrySegmentsVisitedSinceGalaxyJump = 0;
                Galaxy * lastGalaxy = [galaxies objectAtIndex:currentGalaxy.number-1];
                timeToAddToTimer = lastGalaxy.percentTimeToAddUponGalaxyCompletion*[[UpgradeValues sharedInstance] maxBatteryTime];
                if (timeToAddToTimer+light.timeLeft > [[UpgradeValues sharedInstance] maxBatteryTime])
                    timeToAddToTimer = [[UpgradeValues sharedInstance] maxBatteryTime] - light.timeLeft;
                
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
            cameraShouldFocusOnPlayer=false;
            //[background setOpacity:255];
        }
    }
    //NSLog(@"galaxy5");
    if ((int)galaxyLabel.opacity <=0&&justDisplayedGalaxyLabel==false&&[[hudLayer children]containsObject:galaxyLabel])
        [hudLayer removeChild:galaxyLabel cleanup:NO];
    
    if (lastPlanetVisited.segmentNumber == numberOfSegmentsAtATime-1) {
        //CCLOG(@"Planet Count: %d",[planets count]);
        [self DisposeAllContentsOfArray:planets shouldRemoveFromArray:true];
        [self DisposeAllContentsOfArray:zones shouldRemoveFromArray:true];
        [self DisposeAllContentsOfArray:asteroids shouldRemoveFromArray:true];
        [self DisposeAllContentsOfArray:coins shouldRemoveFromArray:true];
       // [self DisposeAllContentsOfArray:powerups shouldRemoveFromArray:YES];
      
        [self RenumberCamObjectArray:planets];
        [self RenumberCamObjectArray:zones];
        [self RenumberCamObjectArray:asteroids];
      //  [self RenumberCamObjectArray:powerups];
        [self RenumberCamObjectArray:coins];
        
        //NSLog(@"galaxy6");
        if (currentGalaxy.number>0) {
            Galaxy * lastGalaxy = [galaxies objectAtIndex:currentGalaxy.number-1];
            [lastGalaxy.spriteSheet removeAllChildrenWithCleanup:YES];
            [lastGalaxy.spriteSheet removeFromParentAndCleanup:YES];
            [[CCTextureCache sharedTextureCache] removeUnusedTextures];
        }
        
        makingSegmentNumber--;
        if ([self CreateSegment]==false) {
            justDisplayedGalaxyLabel = false;
            
            [self CreatePlanetAndZone:indicatorPos.x yPos:indicatorPos.y scale:1];
            
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
        //CCLOG(@"Planet Count: %d",[planets count]);
    }
}

- (void)UpdatePlanets {
    // Zone-to-Player collision detection follows-------------
    player.isInZone = false;
    
    int zoneCount = zones.count;
    for (int i = MAX(lastPlanetVisited.number-1,0); i < zoneCount;i++)
    {
        Zone * zone = [zones objectAtIndex:i];
        if (zone.number<lastPlanetVisited.number-2)
            continue;
        if (zone.number>lastPlanetVisited.number+1)
            break;
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
    [streak setPosition:player.sprite.position];
    
    [thrustParticle setPosition:player.sprite.position];
    [thrustParticle setAngle:180+CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity))];
    if (feverModePlanetHitsInARow >= minPlanetsInARowForFeverMode)
        [thrustParticle setEmissionRate:400];
    else
        [thrustParticle setEmissionRate:20];
    
    
    // [thrustParticle setEmissionRate:ccpLengthSQ(player.velocity)*ccpLength(player.velocity)/2.2f];
    float speedPercent = (timeDilationCoefficient-[[UpgradeValues sharedInstance] absoluteMinTimeDilation])/(absoluteMaxTimeDilation-[[UpgradeValues sharedInstance] absoluteMinTimeDilation]);
    [thrustParticle setEndColor:ccc4FFromccc4B(
                                               ccc4(lerpf(slowParticleColor[0], fastParticleColor[0], speedPercent),
                                                    lerpf(slowParticleColor[1], fastParticleColor[1], speedPercent),
                                                    lerpf(slowParticleColor[2], fastParticleColor[2], speedPercent),
                                                    lerpf(slowParticleColor[3], fastParticleColor[3], speedPercent)))];
    [streak setColor:ccc3(lerpf(slowStreakColor[0], fastStreakColor[0], speedPercent),
                          lerpf(slowStreakColor[1], fastStreakColor[1], speedPercent),
                          lerpf(slowStreakColor[2], fastStreakColor[2], speedPercent))];
    
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

- (void)nameDidChange {
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
        // [Kamcord stopRecording];
        
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
    
    //finalScore = 69669;
    //numCoinsDisplayed = 69;
    
    int rateOfScoreIncrease = finalScore / 640;
    
    NSDictionary *dictForFlurry = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:finalScore],@"Highscore Value", [NSNumber numberWithInt:planetsHitFlurry],@"Planets traveled to",[NSNumber numberWithInt:segmentsSpawnedFlurry],@"Segments spawned",[NSString stringWithFormat:@"Galaxy %d-%d",currentGalaxy.number+1,lastPlanetVisited.whichSegmentThisObjectIsOriginallyFrom+1],@"Location of death",[NSString stringWithFormat:@"%d galaxies and %d segments",currentGalaxy.number+1,flurrySegmentsVisitedSinceGalaxyJump],@"How far player went",[NSNumber numberWithInt:[[PlayerStats sharedInstance] getPlays]],@"Number of total plays",[[PlayerStats sharedInstance] recentName],@"Player Name",nil];
    
    if (isHighScore) {
        [Flurry logEvent:@"Got a top 10 highscore" withParameters:dictForFlurry];
    }
    
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
    
    
    [Flurry logEvent:@"Opened Store" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[UserWallet sharedInstance] getBalance]],@"Coin Balance" ,nil]];
    
    [self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
    [[CCDirector sharedDirector] replaceScene:[StoreLayer scene]];
    
    
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
    light.scoreVelocity += amountToIncreaseLightScoreVelocityEachUpdate*60*dt;
    
    float percentDead = 1-light.timeLeft/[[UpgradeValues sharedInstance] maxBatteryTime];
        [batteryDecreaserSprite setScaleX:lerpf(0, 66, percentDead)];
    
    if (percentDead<.5)
        [batteryInnerSprite setColor:ccc3(lerpf(0, 255, percentDead*2), 255, 0)];
    else [batteryInnerSprite setColor:ccc3(255, lerpf(255, 0, percentDead    *2-1), 0)];
    
    [batteryGlowScaleAction setSpeed:lerpf(1, 3.6, percentDead)];
    
    //    CCLOG(@"DIST: %f, VEL: %f, LIGHSCORE: %f", light.distanceFromPlayer, light.scoreVelocity, light.score);
    if (light.timeLeft <= 0) {
        if (!light.hasPutOnLight) {
            light.hasPutOnLight = true;
            [light.sprite setOpacity:0];
            light.sprite.position = ccp(-240, 160);
            [light.sprite setTextureRect:CGRectMake(0, 0, 480, 320)];
            //NSLog(@"galaxy114light");
            if (light.sprite)
                [hudLayer reorderChild:light.sprite z:-1];
            [light.sprite setOpacity:0];
        }
    }
    
    if (light.hasPutOnLight) {
        light.sprite.position = ccp(light.sprite.position.x+48, light.sprite.position.y);
        [light.sprite setOpacity:clampf((light.sprite.position.x+240)*255/480, 0, 255)];
    }
    
    //NSLog(@"galaxy114lightXX");
    if (light.sprite)
        //    if ([[hudLayer children]containsObject:light.sprite])
        if (light.sprite.position.x >= 240
            ||batteryDecreaserSprite.scaleX>67)//failsafe -- this condition should never have to trigger game over. fix this alex b!!
        {
            //[light.sprite setTextureRect:CGRectMake(0, 0, 0, 0)];
            [self GameOver];
        }
    //NSLog(@"galaxy114lightXX11");
    
    
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
    
    if (powerupPos > 480 + [powerupLabel boundingBox].size.width) {
        paused = false;
        isDisplayingPowerupAnimation = false;
    }
    
    powerupPos += powerupVel*60*dt;
    [powerupLabel setString:player.currentPowerup.title];
    powerupLabel.position = ccp(-[powerupLabel boundingBox].size.width/2 + powerupPos, 160);
    
}

- (void)UpdateBackgroundStars:(float)dt{
    for (CCSprite * star in backgroundStars) {
        //  CGPoint camLayerVelocity = ccpSub(cameraFocusNode.position, cameraLayerLastPosition);
        float angle = ccpToAngle(player.velocity);
        if (angle>=0 && angle <=90)
            star.position = ccpAdd(star.position,  ccpMult(player.velocity, -1*cameraLayer.scale*.1*60*dt));
        
        
        if (star.position.x<0-star.width/2 || star.position.y <0-star.height/2) { //if star is off-screen
            star.position = ccp([self RandomBetween:star.width/2 maxvalue:480*1.8],[self RandomBetween:320+star.height/2 maxvalue:320+5*star.height/2]);
        }
    }
}

-(void)scheduleUpdates {
    //NSLog(@"start4");
    [self schedule:@selector(UpdateScore) interval:1.0/25.0f];
    [self schedule:@selector(UpdateParticles:) interval:1.0/50.0f];
    [self schedule:@selector(UpdateBackgroundStars:) interval:1.0/24.0f];
    [self schedule:@selector(UpdateLight:) interval:1.0/10.0f];
//    [self UpdateScore];
    //NSLog(@"start6");
  //  [self UpdateParticles:dt];
    //[self UpdateBackgroundStars];
    
    //NSLog(@"start7");
//    [self UpdateLight:dt];
}

- (void) CheckMissions {
    
    NSLog(@"died: %i", numTimesDied);
    
    if (numCoinsDisplayed >= 10)
        [self completeObjectiveFromGroupNumber:0 itemNumber:0];
    
    if (score >= 5000)
        [self completeObjectiveFromGroupNumber:0 itemNumber:1];
    
    
    
    if (player.currentPowerup != nil)
        [self completeObjectiveFromGroupNumber:1 itemNumber:0];
    
    if (asteroidsCrashedInto >= 2)
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
    
}

- (void) CheckEndGameMissions {
    
    if (score >= 12000 && score <= 13000)
        [self completeObjectiveFromGroupNumber:2 itemNumber:2];
    
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
        
        /*  if (!isInTutorialMode && !scoreAlreadySaved) {
         if ([[PlayerStats sharedInstance] isHighScore:finalScore]) {
         [[PlayerStats sharedInstance] addScore:finalScore withName:@"fix fix fix"];
         }
         }*/
        //NSLog(@"6");
        [self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
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

- (void)restartGame {
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
    [thrustBurstParticle setPosition:player.sprite.position];
    [thrustBurstParticle setAngle:180+CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity))];
    [thrustBurstParticle resetSystem];
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

-(void)showRecording {
    muted = false;
    [self toggleMute];
    //[Kamcord stopRecording];
    //[Kamcord showView];
}

-(CCLayer*)createPauseLayer {
    CCLayer* layerToAdd = [[CCLayer alloc] init];
    [layerToAdd addChild:[[ObjectiveManager sharedInstance] createMissionPopupWithX:false withDark:true]];
    
    CCSprite* banner = [CCSprite spriteWithFile:@"banner.png"];
    banner.position = ccp(240, 298);
    [layerToAdd addChild:banner];
    
    CCLabelTTF* pauseText = [CCLabelTTF labelWithString:@"GAME PAUSED" fontName:@"HelveticaNeue-CondensedBold" fontSize:38];
    [layerToAdd addChild:pauseText];
    pauseText.position = ccp(240, 301);
    
    CCMenuItem *replay = [CCMenuItemImage
                          itemWithNormalImage:@"retry.png" selectedImage:@"retrypressed.png"
                          target:self selector:@selector(restartGame)];
    replay.position = ccp(240, 20);
    
    CCMenuItem *resume = [CCMenuItemImage
                          itemWithNormalImage:@"resume.png" selectedImage:@"resumepressed.png"
                          target:self selector:@selector(togglePause)];
    resume.position = ccp(360, 20);
    
    CCMenuItem *quit = [CCMenuItemImage
                        itemWithNormalImage:@"quit.png" selectedImage:@"quitpressed.png"
                        target:self selector:@selector(endGame)];
    quit.position = ccp(120, 20);
    
    soundButton = [CCMenuItemImage
                   itemWithNormalImage:@"sound.png" selectedImage:@"soundpressed.png"
                   target:self selector:@selector(toggleMute)];
    CCMenuItem *sound = soundButton;
    sound.position = ccp(449, 301);
    
    CCMenu* menu = [CCMenu menuWithItems:replay, resume, quit, sound, nil];
    menu.position = ccp(0, 0);
    
    
    [layerToAdd addChild:menu];
    
    
    return layerToAdd;
}

- (void)togglePause {
    if (!pauseEnabled) {
        return;
    }
    [self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
    paused = !paused;
    if (paused) {
        //[Kamcord pause];
        
        
        
        pauseLayer = [self createPauseLayer];//(CCLayer*)[CCBReader nodeGraphFromFile:@"PauseMenuLayer.ccb" owner:self];
        [gameOverScoreLabel setString:[NSString stringWithFormat:@"Score: %d",score+prevCurrentPtoPScore]];
        [pauseLayer setTag:pauseLayerTag];
        muted = ![[PlayerStats sharedInstance] isMuted];
        [self toggleMute];
        [self addChild:pauseLayer];
    } else {
        //[Kamcord resume];
        [self removeChildByTag:pauseLayerTag cleanup:NO];
    }
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
