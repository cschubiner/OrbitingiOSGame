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

#define pauseLayerTag       100
#define gameOverLayerTag    200

const float musicVolumeGameplay = 1;
const float effectsVolumeGameplay = 1;

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
    CCMenu *pauseMenu;
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
    coin.sprite = [CCSprite spriteWithSpriteFrameName:@"0.png"];
    coin.sprite.position = ccp(xPos, yPos);
    [coin.sprite setScale:scale*.8];
    coin.whichSegmentThisObjectIsOriginallyFrom = originalSegmentNumber;
    coin.segmentNumber = makingSegmentNumber;
    coin.number = coins.count;
    coin.whichGalaxyThisObjectBelongsTo  = currentGalaxy.number;
    [coin.sprite runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:coinAnimation restoreOriginalFrame:NO]]];
    
    coin.plusLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"coin_label_font.fnt" ];
    [hudLayer addChild: coin.plusLabel];
    
    [coins addObject:coin];
    [spriteSheet addChild:coin.sprite];
    //[spriteSheet addChild:coin.sprite];
    //[spriteSheet reorderChild:coin.sprite z:5];
    [coin release];
    //NSLog(@"ended coin");
    
}

- (void)CreatePowerup:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale type:(int)type {
    //NSLog(@"started powerup");
    
    Powerup *powerup = [[Powerup alloc]initWithType:type];
    
    powerup.coinSprite.position = ccp(xPos, yPos);
    powerup.coinSprite.scale = scale;
    
    [powerup.glowSprite setVisible:false];
    powerup.glowSprite.scale = 1;
    
    [powerup.hudSprite setVisible:false];
    powerup.hudSprite.position = ccp(30, 290);
    powerup.hudSprite.scale = .4;
    
    [powerups addObject:powerup];
    
    [spriteSheet addChild:powerup.coinSprite];
    [spriteSheet addChild:powerup.glowSprite];
    [hudLayer addChild:powerup.hudSprite];
    
    NSLog(@"galaxy114powerup");
    [spriteSheet reorderChild:powerup.glowSprite z:2.5];
    
    [powerup release];
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
    [asteroid release];
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
    [zone release];
    [planet release];
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
    segmentsSpawnedFlurry++;
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
    
    for (int i = 0 ; i < [chosenSegment count]; i++) {
        LevelObjectReturner * returner = [chosenSegment objectAtIndex:i];
        CGPoint newPos = ccpRotateByAngle(ccp(returner.pos.x+(indicatorPos).x,returner.pos.y+(indicatorPos).y), indicatorPos, rotationOfSegment);
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
    
    if (isInTutorialMode) {
        [self CreatePlanetAndZone:288 yPos:364 scale:1];
        [self CreatePlanetAndZone:934 yPos:352 scale:1];
        
        [self CreatePlanetAndZone:288+2000 yPos:364 scale:1];
        [self CreatePlanetAndZone:934+2000 yPos:352 scale:1];
        [self CreateAsteroid:610+2000 yPos:460 scale:1.33552];
        
        
        [self CreatePlanetAndZone:288+4000 yPos:364 scale:1];
        [self CreatePlanetAndZone:934+4000 yPos:352 scale:1];
        [self CreateAsteroid:604+4000 yPos:239 scale:1.26652];
        return;
    }
    if (levelNumber == 1) {
        [self CreatePlanetAndZone:288 yPos:364 scale:1];
        [self CreatePlanetAndZone:934 yPos:352 scale:1];
        
        [self CreatePlanetAndZone:288+2000 yPos:364 scale:1];
        [self CreatePlanetAndZone:934+2000 yPos:352 scale:1];
        [self CreateAsteroid:610+2000 yPos:460 scale:1.33552];
        
        
        [self CreatePlanetAndZone:288+4000 yPos:364 scale:1];
        [self CreatePlanetAndZone:934+4000 yPos:352 scale:1];
        [self CreateAsteroid:604+4000 yPos:239 scale:1.26652];
        return;
    }
    if (levelNumber == 2) {
        [self CreatePlanetAndZone:-288 yPos:364 scale:1];
        [self CreatePlanetAndZone:-934 yPos:352 scale:1];
        
        [self CreatePlanetAndZone:-288-2000 yPos:364 scale:1];
        [self CreatePlanetAndZone:-934-2000 yPos:352 scale:1];
        [self CreateAsteroid:-610-2000 yPos:460 scale:1.33552];
        
        
        [self CreatePlanetAndZone:-288-4000 yPos:364 scale:1];
        [self CreatePlanetAndZone:-934-4000 yPos:352 scale:1];
        [self CreateAsteroid:-604-4000 yPos:239 scale:1.26652];
        return;
    }
    
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
    [galaxy setPercentTimeToAddUponGalaxyCompletion:.77777];
    
    galaxy = [galaxies objectAtIndex:1];
    [galaxy setName:@"Galaxy 2"];
    [galaxy setNumberOfDifferentPlanetsDrawn:3];
    [galaxy setOptimalPlanetsInThisGalaxy:21];
    [galaxy setPercentTimeToAddUponGalaxyCompletion:.488888];
    
    galaxy = [galaxies objectAtIndex:2];
    [galaxy setName:@"Galaxy 3"];
    [galaxy setNumberOfDifferentPlanetsDrawn:3];
    [galaxy setOptimalPlanetsInThisGalaxy:21];
    [galaxy setPercentTimeToAddUponGalaxyCompletion:.4];
    
    galaxy = [galaxies objectAtIndex:3];
    [galaxy setName:@"Galaxy 4"];
    [galaxy setNumberOfDifferentPlanetsDrawn:1];
    [galaxy setOptimalPlanetsInThisGalaxy:24];
    [galaxy setPercentTimeToAddUponGalaxyCompletion:.3];
    
    galaxy = [galaxies objectAtIndex:4];
    [galaxy setName:@"Galaxy 5"];
    [galaxy setNumberOfDifferentPlanetsDrawn:1];
    [galaxy setOptimalPlanetsInThisGalaxy:24];
    
}

- (void)initUpgradedVariables {
    [[UpgradeValues sharedInstance] setCoinMagnetDuration:500 + 100*[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:0] level]];
    
    [[UpgradeValues sharedInstance] setAsteroidImmunityDuration:500 + 100*[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:1] level]];
    
    [[UpgradeValues sharedInstance] setAbsoluteMinTimeDilation:.8 + .05*[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:2] level]];
    
    if ([[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:3] level] >= 1)
        [[UpgradeValues sharedInstance] setHasDoubleCoins:true];
    else
        [[UpgradeValues sharedInstance] setHasDoubleCoins:false];
    
    [[UpgradeValues sharedInstance] setMaxBatteryTime:60 + 3*[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:4] level]];
}

/* On "init," initialize the instance */
- (id)init {
	// always call "super" init.
	// Apple recommends to re-assign "self" with the "super" return value
	if ((self = [super init])) {
        startingCoins = [[UserWallet sharedInstance] getBalance];
        size = [[CCDirector sharedDirector] winSize];
        self.isTouchEnabled= TRUE;
        [((AppDelegate*)[[UIApplication sharedApplication]delegate]) setGalaxyCounter:0];
        isInTutorialMode = [((AppDelegate*)[[UIApplication sharedApplication]delegate]) getIsInTutorialMode];
        isInTutorialMode = false;
        levelNumber = [((AppDelegate*)[[UIApplication sharedApplication]delegate])getChosenLevelNumber];
        [self initUpgradedVariables];
        
        planetCounter = 0;
        planets = [[NSMutableArray alloc] init];
        asteroids = [[NSMutableArray alloc] init];
        zones = [[NSMutableArray alloc] init];
        powerups = [[NSMutableArray alloc] init];
        coins = [[NSMutableArray alloc] init];
        
        
        hudLayer = [[CCLayer alloc] init];
        cameraLayer = [[CCLayer alloc] init];
        [cameraLayer setAnchorPoint:CGPointZero];
        
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
        
        CCMenuItem  *pauseButton = [CCMenuItemImage
                                    itemFromNormalImage:@"pauseButton7.png" selectedImage:@"pauseButton7.png"
                                    target:self selector:@selector(togglePause)];
        pauseButton.position = ccp(457, 298);
        pauseMenu = [CCMenu menuWithItems:pauseButton, nil];
        pauseMenu.position = CGPointZero;
        
        if (!isInTutorialMode) {
            scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"score_label_font.fnt"];
            scoreLabel.position = ccp(480-[scoreLabel boundingBox].size.width/2-10, 15);
            [hudLayer addChild: scoreLabel];
            
            CCSprite* starSprite = [CCSprite spriteWithFile:@"star1.png"];
            [starSprite setScale:.15];
            [hudLayer addChild:starSprite];
            [starSprite setPosition:ccp(74, 16)];
            
            coinsLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"star_label_font.fnt"];
            coinsLabel.position = ccp(74 - [coinsLabel boundingBox].size.width/2 - 15, 15);
            [hudLayer addChild: coinsLabel];
        }
        else {
            tutImage1 = [CCSprite spriteWithFile:@"screen1.png"];
            tutImage2 = [CCSprite spriteWithFile:@"screen2.png"];
            tutImage3 = [CCSprite spriteWithFile:@"screen3.png"];
        }
        
        powerupLabel = [CCLabelTTF labelWithString:@" " fontName:@"Marker Felt" fontSize:44];
        powerupLabel.position = ccp(-[powerupLabel boundingBox].size.width/2, 160);
        [hudLayer addChild: powerupLabel];
        
        [self playSound:@"a_song.mp3" shouldLoop:YES pitch:1];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"bomb.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"SWOOSH.WAV"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"buttonpress.mp3"];
        
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"generalSpritesheet.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"generalSpritesheet.plist"];
        
        coinAnimationFrames = [[NSMutableArray alloc]init];
        for (int i = 0; i <= 29; ++i) {
            [coinAnimationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%d.png", i]]];
        }
        coinAnimation = [[CCAnimation alloc ]initWithFrames:coinAnimationFrames delay:coinAnimationDelay];
        
        [self CreateGalaxies];
        currentGalaxy = [galaxies objectAtIndex:0];
        nextGalaxy = [galaxies objectAtIndex:1];
        [self setGalaxyProperties];
        indicatorPos = CGPointZero;
        for (int j = 0 ; j < numberOfSegmentsAtATime; j++) {
            [self CreateSegment];
        }
        
        player = [[Player alloc]init];
        [player retain];
        player.sprite = [CCSprite spriteWithSpriteFrameName:@"playercute.png"];
        player.alive=true;
        [player.sprite setScale:playerSizeScale];
        player.segmentNumber = -10;
        // player.sprite.position = ccpAdd([self GetPositionForJumpingPlayerToPlanet:0],ccpMult(ccpForAngle(CC_DEGREES_TO_RADIANS(directionPlanetSegmentsGoIn)), -distanceBetweenGalaxies*8));
        player.sprite.position = [self GetPositionForJumpingPlayerToPlanet:0];
        cameraDistToUse = 1005.14;
        [cameraLayer setScale:.43608];
        [cameraLayer setPosition:ccp(98.4779,67.6401)];
        cameraLastFocusPosition = ccp(325.808,213.3);
        [cameraFocusNode setPosition:ccp(142.078,93.0159)];
        galaxyLabel = [[CCLabelTTF alloc]initWithString:currentGalaxy.name fontName:@"Marker Felt" fontSize:24];
        [galaxyLabel setAnchorPoint:ccp(.5f,.5f)];
        [galaxyLabel setPosition:ccp(240,45)];
        
        id fadeAction = [CCFadeIn actionWithDuration:.8];
        id action2 = [CCSequence actions:[CCSpawn actions:fadeAction,[CCScaleTo actionWithDuration:.3 scale:1], nil], nil] ;
        id repeatAction = [CCRepeat actionWithAction:[CCSequence actions:[CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.8 scale:1.0f]],[CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.8 scale:1]], nil] times:2];
        galaxyLabelAction = [CCSequence actions:action2,repeatAction, [CCFadeOut actionWithDuration:.8],nil];
        [galaxyLabelAction retain];
        [galaxyLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.1], galaxyLabelAction,nil]];
        justDisplayedGalaxyLabel = true;
        
        [hudLayer addChild:galaxyLabel];
        
        float streakWidth = streakWidthWITHOUTRetinaDisplay;
        if ([((AppDelegate*)[[UIApplication sharedApplication]delegate]) getIsRetinaDisplay])
            streakWidth = streakWidthOnRetinaDisplay;
        streak=[CCLayerStreak streakWithFade:2 minSeg:3 image:@"streak2.png" width:streakWidth length:32 color:// ccc4(153,102,0, 255)  //orange
                //ccc4(255,255,255, 255) // white
                // ccc4(255,255,0,255) // yellow
                //  ccc4(0,0,255,255) // blue
                ccc4(0,255,153,255) // blue green
                // ccc4(0,255,0,255) // green
                                      target:player.sprite];
        
        cameraFocusNode = [[CCSprite alloc]init];
        killer = 0;
        orbitState = 0; // 0 = orbiting, 1 = just left orbit and deciding things for state 3; 3 = flying to next planet
        velSoftener = 1;
        initialAccelMag = 0;
        isOnFirstRun = true;
        timeDilationCoefficient = 1;
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
        currentNumOfCoinLabels = 0;
        currentCoinLabel = 0;
        
        background = [CCSprite spriteWithFile:@"background0.pvr.ccz"];
        background2 = [CCSprite spriteWithFile:@"background1.pvr.ccz"];
        [background setPosition:ccp(size.width/2+14,size.height/5+2)];
        [background2 setPosition:ccp(size.width/2+14,size.height/5+2)];
        [background2 retain];
        [background retain];
        [self addChild:background];
        
        [self addChild:cometParticle];
        cometParticle.position = ccp([self RandomBetween:0 maxvalue:390],325);
        cometVelocity = ccp([self RandomBetween:-10 maxvalue:10]/5,-[self RandomBetween:1 maxvalue:23]/5);
        [self resetVariablesForNewGame];
        
        light = [[Light alloc] init];
        
        light.sprite = [CCSprite spriteWithFile:@"OneByOne.png"];
        [light.sprite setColor:ccc3(0, 0, 0)]; //this makes the light black!
        [[light sprite]retain];
        
        light.scoreVelocity = initialLightScoreVelocity;
        //  glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        light.hasPutOnLight = false;
        
        
        
        [cameraLayer addChild:currentGalaxy.spriteSheet];
        [cameraLayer addChild:spriteSheet];
        
        lastPlanetVisited = [planets objectAtIndex:0];
        layerHudSlider = (CCLayer*)[CCBReader nodeGraphFromFile:@"hudLayer.ccb" owner:self];
        float durationForScaling = .7;
        float delayTime = .7;
        id scaleBiggerAction = [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:durationForScaling scale:1.183]];
        id scaleSmallerAction = [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:durationForScaling scale:.858]];
        id sequenceAction = [CCRepeatForever actionWithAction:[CCSequence actions:scaleBiggerAction,[CCDelayTime actionWithDuration:.2],scaleSmallerAction,[CCDelayTime actionWithDuration:delayTime], nil]];
        batteryGlowScaleAction = [CCSpeed actionWithAction:sequenceAction speed:1];
        [batteryGlowSprite runAction:batteryGlowScaleAction];
        
        [self addChild:cameraLayer];
        [self addChild:hudLayer];
        if (!isInTutorialMode&&levelNumber == 0)
            [self addChild:layerHudSlider];
        [self addChild:pauseMenu];
        [self UpdateScore];
        
        [Flurry logEvent:@"Played Game" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:(int)isInTutorialMode],@"isInTutorialMode",nil]  timed:YES];
        [self schedule:@selector(Update:) interval:0]; // this makes the update loop loop!!!!
        [Kamcord startRecording];
	}
	return self;
}

- (void)UpdateCamera:(float)dt {
    if (player.alive) {
        player.velocity = ccpAdd(player.velocity, player.acceleration);
        player.sprite.position = ccpAdd(ccpMult(player.velocity, 60*dt*timeDilationCoefficient*asteroidSlower), player.sprite.position);
    }
    
    if (isnan(player.sprite.position.x)) {
        player.velocity = CGPointZero;
        player.sprite.position = [self GetPositionForJumpingPlayerToPlanet:lastPlanetVisited.number];
        player.acceleration = CGPointZero;
    }
    
    // camera code follows -----------------------------
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
    
    if ([cameraLayer scale]<.1) {
        //NSLog(@"cameraLayer scale should be bigger this this, we prob has an error");
        [cameraLayer setScale:.1];
    }
    
    if (!isInTutorialMode) {
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
    
    currentCoinLabel += ([[UpgradeValues sharedInstance] hasDoubleCoins] ? 2 : 1);
    [coin.plusLabel setString:[NSString stringWithFormat:@"+%d", currentCoinLabel]];
    currentNumOfCoinLabels++;
    [coin.plusLabel setScale:.7];
    
    id setCoinTargetting = [CCCallBlock actionWithBlock:(^{
        [coin setIsTargettingScoreLabel:true];
    })];
    
    id tintScoreYellow = [CCCallBlock actionWithBlock:(^{
        id tintAction = [CCTintTo actionWithDuration:.05 red:255 green:255 blue:0];
        [scoreLabel runAction:[CCSequence actions:tintAction,
                               [CCDelayTime actionWithDuration:.4],
                               [CCTintTo actionWithDuration:.4 red:255 green:255 blue:255],
                               nil]];
    })];
    
    [coin.plusLabel runAction:[CCSequence actions:
                               [CCScaleTo actionWithDuration:.2 scale:2*coin.plusLabel.scale],
                               [CCScaleTo actionWithDuration:.1 scale:1*coin.plusLabel.scale],
                               [CCDelayTime actionWithDuration:.4],
                               setCoinTargetting,
                               [CCSpawn actions:[CCFadeOut actionWithDuration:.4],[CCMoveTo actionWithDuration:.3 position:scoreLabel.position],tintScoreYellow,nil],
                               [CCHide action],
                               [CCCallFunc actionWithTarget:self selector:@selector(coinDone)],
                               nil]];
    
    id scaleAction = [CCScaleTo actionWithDuration:.1 scale:.2*coin.sprite.scale];
    [coin.sprite runAction:[CCSequence actions:[CCSpawn actions:scaleAction,[CCRotateBy actionWithDuration:.1 angle:360], nil],[CCHide action], nil]];
    coin.isAlive = false;
    if (timeSinceGotLastCoin<.4){
        lastCoinPitch +=.3;
    }
    else lastCoinPitch = 0;
    timeSinceGotLastCoin = 0;
    if (lastCoinSoundID!=0)
        [[SimpleAudioEngine sharedEngine]stopEffect:lastCoinSoundID];
    lastCoinSoundID = [self playSound:@"buttonpress.mp3" shouldLoop:false pitch:1.1+lastCoinPitch];
}

- (void)coinDone {
    currentNumOfCoinLabels--;
    if (currentNumOfCoinLabels <= 0) {
        currentCoinLabel = 0;
    }
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
    
    for (Coin* coin in coins) {
        
        CGPoint p = coin.sprite.position;
        CGPoint coinPosOnHud = [cameraLayer convertToWorldSpace:coin.sprite.position];
        if (coin.isTargettingScoreLabel==false)
            coin.plusLabel.position = ccp(coinPosOnHud.x, coinPosOnHud.y + 20);
        
        coin.velocity = ccpMult(ccpNormalize(ccpSub(player.sprite.position, p)), coin.speed);
        if (coin.isAlive)
            coin.sprite.position = ccpAdd(coin.sprite.position, coin.velocity);
        
        if (ccpLength(ccpSub(player.sprite.position, p)) <= coin.radius + player.sprite.height/1.5 && coin.isAlive) {
            [self UserTouchedCoin:coin dt:dt];
        }
    }
    
    //bool isHittingAsteroid = false;
    for (Asteroid* asteroid in asteroids) {
        CGPoint p = asteroid.sprite.position;
        if (player.alive && ccpLength(ccpSub(player.sprite.position, p)) <= asteroid.radius * asteroidRadiusCollisionZone && orbitState == 3) {
            //isHittingAsteroid = true;
            if (!(player.currentPowerup.type == 1)) {
                [self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number];
            }
        }
    }
    
    /*if (!(player.currentPowerup.type == 1)) {
     if (isHittingAsteroid)
     asteroidSlower -= .1;
     else
     asteroidSlower += .01;
     asteroidSlower = clampf(asteroidSlower, .13, 1);
     }*/
    
    for (Powerup* powerup in powerups) {
        CGPoint p = powerup.coinSprite.position;
        if (player.alive && ccpLength(ccpSub(player.sprite.position, p)) <= powerup.coinSprite.width * .5 * powerupRadiusCollisionZone) {
            if (powerup.coinSprite.visible) {
                [powerup.coinSprite setVisible:false];
                if (player.currentPowerup != nil) {
                    [player.currentPowerup.glowSprite setVisible:false];
                    [player.currentPowerup.hudSprite setVisible:false];
                }
                paused = true;
                isDisplayingPowerupAnimation = true;
                powerupPos = 0;
                powerupVel = 0;
                player.currentPowerup = powerup;
                [player.currentPowerup.glowSprite setVisible:true];
                //[player.currentPowerup.hudSprite setVisible:true];
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
            //[player.currentPowerup.hudSprite setVisible:false];
            [player.currentPowerup.glowSprite setVisible:false];
            
        }
        if (!player.currentPowerup.glowSprite.visible) {
            updatesWithBlinking++;
        }
        
        if (updatesWithBlinking >= clampf(8*updatesLeft/100, 3, 99999999)) {
            updatesWithBlinking = 0;
            //[player.currentPowerup.hudSprite setVisible:true];
            [player.currentPowerup.glowSprite setVisible:true];
        }
        
        if (powerupCounter >= player.currentPowerup.duration) {
            //[player.currentPowerup.hudSprite setVisible:false];
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
                    
                }
                else {
                    player.velocity = ccpAdd(ccpMult(player.velocity, (1-velSoftener)*1), ccpMult(dir3, velSoftener*ccpLength(initialVel)));
                }
                
                CGPoint direction = ccpNormalize(ccpSub(planet.sprite.position, player.sprite.position));
                player.acceleration = ccpMult(direction, gravity);
            }
            else
                if (orbitState == 1)
                {
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
                    CGPoint vel = CGPointZero;
                    if (ccpLength(ccpSub(ccpAdd(player.sprite.position, vectorToCheck), left)) <= ccpLength(ccpSub(ccpAdd(player.sprite.position, vectorToCheck), right))) { //closer to the left
                        float distToUse2 = factorToPlaceGravFieldWhenCrossingOverTheMiddle; //crossing over the middle
                        if (ccpLength(ccpSub(player.sprite.position, spot1)) < ccpLength(ccpSub(player.sprite.position, spot2)))
                            distToUse2 = factorToPlaceGravFieldWhenStayingOutside; //staying outside
                        spotGoingTo = ccpAdd(ccpMult(dir2, targetPlanet.orbitRadius*distToUse2), targetPlanet.sprite.position);
                        newAng = ccpToAngle(ccpSub(left, player.sprite.position));
                        vel = ccpSub(left, player.sprite.position);
                    }
                    else {
                        float distToUse2 = factorToPlaceGravFieldWhenCrossingOverTheMiddle; //crossing over the middle
                        if (ccpLength(ccpSub(player.sprite.position, spot1)) > ccpLength(ccpSub(player.sprite.position, spot2)))
                            distToUse2 = factorToPlaceGravFieldWhenStayingOutside; //staying outside
                        spotGoingTo = ccpAdd(ccpMult(dir3, targetPlanet.orbitRadius*distToUse2), targetPlanet.sprite.position);
                        newAng = ccpToAngle(ccpSub(right, player.sprite.position));
                        vel = ccpSub(right, player.sprite.position);
                    }
                    
                    float curAng = ccpToAngle(player.velocity);
                    swipeAccuracy = fabsf(CC_RADIANS_TO_DEGREES(curAng) - CC_RADIANS_TO_DEGREES(newAng));;
                    
                    if (swipeAccuracy > 180)
                        swipeAccuracy = 360 - swipeAccuracy;
                    
                    orbitState = 3;
                    initialAccelMag = 0;
                    
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
                
                player.acceleration = ccpMult(accelToAdd, gravIncreaser*freeGravityStrength*scaler*asteroidSlower*60*dt);
                
                if (initialAccelMag == 0)
                    initialAccelMag = ccpLength(player.acceleration);
                else
                    player.acceleration = ccpMult(ccpNormalize(player.acceleration), initialAccelMag);
            }
            
            if (ccpLength(ccpSub(player.sprite.position, targetPlanet.sprite.position)) <= targetPlanet.orbitRadius) {
                orbitState = 0;
            }
        }
        
        if (ccpLength(ccpSub(player.sprite.position, planet.sprite.position)) <= planet.radius * planetRadiusCollisionZone && planet.number >= lastPlanetVisited.number) {
            [self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number];
        }
        
        if (dangerLevel >= 1) {
            dangerLevel = 0;
            [self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number];
        }
        
        if (planet.number >lastPlanetVisited.number+2)
            break;
    }
}

- (void)KillIfEnoughTimeHasPassed {
    killer++;
    if (orbitState == 0 || orbitState == 2)
        killer = 0;
    if (killer > deathAfterThisLong)
        [self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number];
}

// FIX you don't really need planetIndex passed in because it's just going to spawn at the position of the last thrust point anyway
- (void)RespawnPlayerAtPlanetIndex:(int)planetIndex {
    timeDilationCoefficient *= factorToScaleTimeDilationByOnDeath;
    numZonesHitInARow = 0;
    orbitState = 0;
    
    [playerExplosionParticle resetSystem];
    [playerExplosionParticle setPosition:player.sprite.position];
    [playerExplosionParticle setPositionType:kCCPositionTypeGrouped];
    [playerExplosionParticle setVisible:true];
    
    CGPoint curPlanetPos = lastPlanetVisited.sprite.position;
    CGPoint nextPlanetPos = [[[planets objectAtIndex:(lastPlanetVisited.number+1)] sprite] position];
    CGPoint pToGoTo = ccpAdd(curPlanetPos, ccpMult(ccpNormalize(ccpSub(nextPlanetPos, curPlanetPos)), lastPlanetVisited.orbitRadius));
    id moveAction = [CCMoveTo actionWithDuration:.2 position:pToGoTo];
    id blink = [CCBlink actionWithDuration:delayTimeAfterPlayerExplodes-.2 blinks:(delayTimeAfterPlayerExplodes-.2)*respawnBlinkFrequency];
    id movingSpawnActions = [CCSpawn actions:moveAction, [CCRotateTo actionWithDuration:.2 angle:player.rotationAtLastThrust+180], nil];
    player.moveAction = [CCSequence actions:[CCHide action],movingSpawnActions,blink, [CCShow action], nil];
    
    [player.sprite runAction:player.moveAction];
    [thrustParticle stopSystem];
    streak.visible = false;
    player.alive = false;
    player.velocity=ccp(0,.05);
    player.acceleration=CGPointZero;
    
    [Flurry logEvent:@"Player Died" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:lastPlanetVisited.whichSegmentThisObjectIsOriginallyFrom],@"Segment Player Died On",[NSNumber numberWithInt:numZonesHitInARow],@"Pre-death combo",[NSNumber numberWithFloat:totalSecondsAlive],@"Time Alive",[NSNumber numberWithInt: [[UserWallet sharedInstance] getBalance]],@"Total Coins", nil]];
    
    totalSecondsAlive = 0;
    
}

- (void)UpdatePlayer:(float)dt {
    if (player.alive) {
        [self ApplyGravity:dt];
        //CCLOG(@"state: %d", orbitState);
        timeDilationCoefficient -= timeDilationReduceRate;
        
        timeDilationCoefficient = clampf(timeDilationCoefficient, [[UpgradeValues sharedInstance] absoluteMinTimeDilation], absoluteMaxTimeDilation);
        
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
        [streak runAction:[CCSequence actions:[CCDelayTime actionWithDuration:timeToHideStreakAfterRespawn],[CCShow action], nil]];
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
    [cameraLayer addChild:streak z:1];
    [spriteSheet addChild:player.sprite z:3];
}

- (CGPoint)GetPositionForJumpingPlayerToPlanet:(int)planetIndex {
    //CCLOG([NSString stringWithFormat:@"thrust mag:"]);
    CGPoint dir = ccpNormalize(ccpSub(((Planet*)[planets objectAtIndex:planetIndex+1]).sprite.position,((Planet*)[planets objectAtIndex:planetIndex]).sprite.position));
    return ccpAdd(((Planet*)[planets objectAtIndex:planetIndex]).sprite.position, ccpMult(dir, ((Planet*)[planets objectAtIndex:planetIndex]).orbitRadius*respawnOrbitRadius));
}

- (void)DisposeAllContentsOfArray:(NSMutableArray*)array shouldRemoveFromArray:(bool)shouldRemove{
    
    for (int i = 0 ; i < [array count]; i++) {
        CameraObject * object = [array objectAtIndex:i];
        object.segmentNumber--;
        if (object.segmentNumber == -1 ) {
            if ([[spriteSheet children]containsObject:object.sprite])
                [spriteSheet removeChild:object.sprite cleanup:YES];
            if ([[currentGalaxy.spriteSheet children]containsObject:object.sprite])
                [currentGalaxy.spriteSheet removeChild:object.sprite cleanup:YES];
            if (shouldRemove) {
                [array removeObject:object];
                i--;
            }
        }
    }
    for (int i = 0 ; i < [array count]; i++)
        ((CameraObject*)[array objectAtIndex:i]).number = i;
}

- (void)UpdateGalaxies {
    //NSLog(@"galaxy0");
    
    if (lastPlanetVisited.number==0) {
        cameraShouldFocusOnPlayer = false;
    }
    else {
        //NSLog(@"galaxy");
        
        Planet * nextPlanet;
        if (lastPlanetVisited.number+1<[planets count])
            nextPlanet= [planets objectAtIndex:(lastPlanetVisited.number+1)];
        else nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number-1)];
        //NSLog(@"galaxy11");
        
        if (
            //nextPlanet.whichGalaxyThisObjectBelongsTo > lastPlanetVisited.whichGalaxyThisObjectBelongsTo||
            targetPlanet.whichGalaxyThisObjectBelongsTo>lastPlanetVisited.whichGalaxyThisObjectBelongsTo) {
            cameraShouldFocusOnPlayer=true;
            //NSLog(@"galaxy112");
            
            float firsttoplayer = ccpToAngle(ccpSub(lastPlanetVisited.sprite.position, player.sprite.position));
            float planetAngle = ccpToAngle(ccpSub(lastPlanetVisited.sprite.position, nextPlanet.sprite.position));
            float firstToPlayerAngle = firsttoplayer-planetAngle;
            float firstToPlayerDistance = ccpDistance(lastPlanetVisited.sprite.position, player.sprite.position)*cosf(firstToPlayerAngle);
            float firsttonextDistance = ccpDistance(lastPlanetVisited.sprite.position, nextPlanet.sprite.position);
            //NSLog(@"galaxy113");
            float percentofthewaytonext = firstToPlayerDistance/firsttonextDistance;
            percentofthewaytonext*=1.18;
            if (percentofthewaytonext>1) percentofthewaytonext = 1;
            if ([[self children]containsObject:background]) {
                if ([[self children]containsObject:background2]==false) {
                    NSLog(@"galaxy114");
                    [self reorderChild:background z:-5];
                    [background2 setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"background%d.pvr.ccz",targetPlanet.whichGalaxyThisObjectBelongsTo]]];
                    //NSLog(@"galaxy115");
                    [self addChild:background2 z:-6];
                    //NSLog(@"galaxy116");
                }
            }
            //NSLog(@"galaxy1");
            if ([[self children]containsObject:background2]) {
                [background2 setOpacity:255];
                [background setOpacity:lerpf(255, 0, percentofthewaytonext)];
            }
            else [background setOpacity:255];
            if (percentofthewaytonext>=1&&[[self children]containsObject:background2]) {
                [background setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"background%d.pvr.ccz",targetPlanet.whichGalaxyThisObjectBelongsTo]]];
                [background setOpacity:255];
                if (![[self children]containsObject:background])
                    [self addChild:background];
                [self removeChild:background2 cleanup:YES];
            }
            //NSLog(@"galaxy3");
            if (percentofthewaytonext>.85&&justDisplayedGalaxyLabel==false&&(int)galaxyLabel.opacity<=0)
            {
                if ([[cameraLayer children]containsObject:currentGalaxy.spriteSheet]==false) {
                    Galaxy * lastGalaxy = [galaxies objectAtIndex:currentGalaxy.number-1];
                    if ([[cameraLayer children]containsObject:lastGalaxy.spriteSheet]) {
                        [cameraLayer removeChild:lastGalaxy.spriteSheet cleanup:YES];
                        //[[lastGalaxy spriteSheet]release];
                    }
                    [cameraLayer addChild:currentGalaxy.spriteSheet z:3];
                    NSLog(@"galaxy1155");
                    [cameraLayer reorderChild:spriteSheet z:4];
                }
                //NSLog(@"galaxy4");
                
                Galaxy * lastGalaxy = [galaxies objectAtIndex:currentGalaxy.number-1];
                timeToAddToTimer = lastGalaxy.percentTimeToAddUponGalaxyCompletion*[[UpgradeValues sharedInstance] maxBatteryTime];
                if (timeToAddToTimer+light.timeLeft > [[UpgradeValues sharedInstance] maxBatteryTime])
                    timeToAddToTimer = [[UpgradeValues sharedInstance] maxBatteryTime] - light.timeLeft;
                
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
            [background setOpacity:255];
        }
    }
    //NSLog(@"galaxy5");
    if ((int)galaxyLabel.opacity <=0&&justDisplayedGalaxyLabel==false&&[[hudLayer children]containsObject:galaxyLabel])
        [hudLayer removeChild:galaxyLabel cleanup:NO];
    if ((int)[background opacity]<=0&&[[self children]containsObject:background])
        [self removeChild:background cleanup:NO];
    if ((int)[background2 opacity]<=0&&[[self children]containsObject:background2])
        [self removeChild:background2 cleanup:NO];
    
    if (levelNumber !=0) {
        if (planetsHitFlurry >= [planets count]) {
            [self GameOver];
        }
    }
    else if (lastPlanetVisited.segmentNumber == numberOfSegmentsAtATime-1&&isInTutorialMode==false) {
        //CCLOG(@"Planet Count: %d",[planets count]);
        [self DisposeAllContentsOfArray:planets shouldRemoveFromArray:true];
        [self DisposeAllContentsOfArray:zones shouldRemoveFromArray:true];
        [self DisposeAllContentsOfArray:asteroids shouldRemoveFromArray:true];
        [self DisposeAllContentsOfArray:coins shouldRemoveFromArray:true];
        //NSLog(@"galaxy6");
        makingSegmentNumber--;
        
        if ([self CreateSegment]==false) {
            justDisplayedGalaxyLabel = false;
            planetsHitSinceNewGalaxy=0;
            if (currentGalaxy.number+1<[galaxies count]) {
                currentGalaxy = nextGalaxy;
                if (currentGalaxy.number+1<[galaxies count])
                    nextGalaxy = [galaxies objectAtIndex:currentGalaxy.number+1];
                Planet*lastPlanetOfThisGalaxy = [planets objectAtIndex:planets.count-1];
                [self CreateCoinArrowAtPosition:ccpAdd(lastPlanetOfThisGalaxy.sprite.position, ccpMult(ccpForAngle(CC_DEGREES_TO_RADIANS(directionPlanetSegmentsGoIn)), lastPlanetOfThisGalaxy.orbitRadius*2.1)) withAngle:directionPlanetSegmentsGoIn];
                indicatorPos = ccpAdd(indicatorPos, ccpMult(ccpForAngle(CC_DEGREES_TO_RADIANS(directionPlanetSegmentsGoIn)), distanceBetweenGalaxies));
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
            if (!zone.hasPlayerHitThisZone)
            {
                if (i == 0);
                else if ([[zones objectAtIndex:i - 1]hasPlayerHitThisZone]) {
                    lastPlanetVisited = [planets objectAtIndex:zone.number];
                    updatesSinceLastPlanet = 0;
                }
                
                [zone.sprite setColor:ccc3(255, 80, 180)];
                zone.hasPlayerHitThisZone = true;
                zonesReached++;
                planetsHitSinceNewGalaxy++;
                score+=currentPtoPscore;
                currentPtoPscore=0;
                prevCurrentPtoPScore=0;
                numZonesHitInARow++;
                timeDilationCoefficient += timeDilationIncreaseRate;
                planetsHitFlurry++;
                /*  if (zonesReached>=[zones count]) {
                 [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationPortrait];
                 [TestFlight passCheckpoint:@"Reached All Zones"];
                 [Flurry endTimedEvent:@"Played Game" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:score],@"Score", nil]];
                 [Flurry logEvent:@"Player Died" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:lastPlanetVisited.whichSegmentThisObjectIsOriginallyFrom],@"Segment Player Died On",[NSNumber numberWithInt:numZonesHitInARow],@"Pre-death combo",[NSNumber numberWithFloat:totalSecondsAlive],@"Time Alive",[NSNumber numberWithInt: [[UserWallet sharedInstance] getBalance]],@"Total Coins", nil]];
                 }*/
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
    scoreLabel.position = ccp(480-[scoreLabel boundingBox].size.width/2-10, 15);
    
    int numCoins = [[UserWallet sharedInstance] getBalance];
    int coinsDiff = numCoins - startingCoins;
    [coinsLabel setString:[NSString stringWithFormat:@"%i",coinsDiff]];
    coinsLabel.position = ccp(74 - [coinsLabel boundingBox].size.width/2 - 15, 15);
}

- (void)UpdateParticles:(ccTime)dt {
    [thrustParticle setPosition:player.sprite.position];
    [thrustParticle setAngle:180+CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity))];
    // [thrustParticle setEmissionRate:ccpLengthSQ(player.velocity)*ccpLength(player.velocity)/2.2f];
    float speedPercent = (timeDilationCoefficient-[[UpgradeValues sharedInstance] absoluteMinTimeDilation])/(absoluteMaxTimeDilation-[[UpgradeValues sharedInstance] absoluteMinTimeDilation]);
    [thrustParticle setEndColor:ccc4FFromccc4B(
                                               ccc4(lerpf(slowParticleColor[0], fastParticleColor[0], speedPercent),
                                                    lerpf(slowParticleColor[1], fastParticleColor[1], speedPercent),
                                                    lerpf(slowParticleColor[2], fastParticleColor[2], speedPercent),
                                                    lerpf(slowParticleColor[3], fastParticleColor[3], speedPercent)))];
    [streak setColor:ccc4(lerpf(slowStreakColor[0], fastStreakColor[0], speedPercent),
                          lerpf(slowStreakColor[1], fastStreakColor[1], speedPercent),
                          lerpf(slowStreakColor[2], fastStreakColor[2], speedPercent),
                          lerpf(slowStreakColor[3], fastStreakColor[3], speedPercent))];
    
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

- (void)GameOver {
    if (!isGameOver) { // this line ensures that it only runs once
        isGameOver = true;
        if ([[self children]containsObject:layerHudSlider])
            [self removeChild:layerHudSlider cleanup:YES];
        [Kamcord stopRecording];
        pauseLayer = (CCLayer*)[CCBReader nodeGraphFromFile:@"GameOverLayer.ccb" owner:self];
        
        [Flurry endTimedEvent:@"Played Game" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:score],@"Score", nil]];
        [Flurry logEvent:@"Game over" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:score],@"Score", [NSNumber numberWithInt:planetsHitFlurry],@"Planets traveled to",[NSNumber numberWithInt:segmentsSpawnedFlurry],@"Segments spawned", [NSNumber numberWithInt:(int)isInTutorialMode],@"isInTutorialMode",nil]];
        [pauseLayer setTag:gameOverLayerTag];
        [self addChild:pauseLayer];
        int finalScore = score + prevCurrentPtoPScore;
        [gameOverScoreLabel setString:[NSString stringWithFormat:@"Score: %d",finalScore]];
        
        if ([[PlayerStats sharedInstance] isHighScore:finalScore]) {
            int plays = [[PlayerStats sharedInstance] getPlays];
            NSString *playsString = [NSString stringWithFormat:@"%d", plays];
            [[PlayerStats sharedInstance] addScore:finalScore withName:playsString];
        }
        
        scoreAlreadySaved = YES;
        [DataStorage storeData];
    }
}

- (void)UpdateLight:(float)dt{
    
    light.timeLeft -= dt;
    float timerAddSpeed = 10;
    timeToAddToTimer-= timerAddSpeed * dt;
    if (timeToAddToTimer>0) {
        light.timeLeft += timerAddSpeed * dt;
        [batteryGlowSprite setColor:ccc3(0, 255, 0)];
    }
    else [batteryGlowSprite setColor:ccc3(255, 0, 0)];
    
    light.scoreVelocity += amountToIncreaseLightScoreVelocityEachUpdate*60*dt;
    
    float percentDead = 1-light.timeLeft/[[UpgradeValues sharedInstance] maxBatteryTime];
    if (!isInTutorialMode&&levelNumber==0) {
        [batteryDecreaserSprite setScaleX:lerpf(0, 66, percentDead)];
    }
    
    [batteryGlowScaleAction setSpeed:lerpf(1, 3.6, percentDead)];
    
    //    CCLOG(@"DIST: %f, VEL: %f, LIGHSCORE: %f", light.distanceFromPlayer, light.scoreVelocity, light.score);
    if (light.timeLeft <= 0) {
        if (!light.hasPutOnLight) {
            light.hasPutOnLight = true;
            [light.sprite setOpacity:0];
            light.sprite.position = ccp(-240, 160);
            [light.sprite setTextureRect:CGRectMake(0, 0, 480, 320)];
            NSLog(@"galaxy114light");
            if (light.sprite)
                [hudLayer reorderChild:light.sprite z:-1];
            [light.sprite setOpacity:0];
        }
    }
    
    if (light.hasPutOnLight) {
        light.sprite.position = ccp(light.sprite.position.x+48, light.sprite.position.y);
        [light.sprite setOpacity:clampf((light.sprite.position.x+240)*255/480, 0, 255)];
    }
    
    if (light.sprite.position.x >= 240
        ||batteryDecreaserSprite.scaleX>67)//failsafe -- this condition should never have to trigger game over. fix this alex b!!
    {
        //[light.sprite setTextureRect:CGRectMake(0, 0, 0, 0)];
        [self GameOver];
    }
    
    if (!isInTutorialMode)
        light.score += light.scoreVelocity;
}

- (void)UpdateCoins {
    for (Coin* coin in coins) {
        
        CGPoint p = coin.sprite.position;
        
        if (player.currentPowerup.type == 2) {
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
        powerupVel = 15;
    else if (powerupPos <= 430)
        powerupVel = 2.3;
    else
        powerupVel = 18;
    
    if (powerupPos > 480 + [powerupLabel boundingBox].size.width) {
        paused = false;
        isDisplayingPowerupAnimation = false;
    }
    
    powerupPos += powerupVel*60*dt;
    [powerupLabel setString:player.currentPowerup.title];
    powerupLabel.position = ccp(-[powerupLabel boundingBox].size.width/2 + powerupPos, 160);
    
}

- (void) Update:(ccTime)dt {
    //NSLog(@"start");
    if (!paused&&isGameOver==false) {
        totalGameTime+=dt;
        totalSecondsAlive+=dt;
        timeSinceGotLastCoin+=dt;
        
        if (player.alive) {
            [self UpdateGalaxies];
            //NSLog(@"start2");

            [self UpdatePlanets];
            //NSLog(@"start1");
        }
        [self UpdateCoins];
        //NSLog(@"start3");
        [self UpdatePlayer: dt];
        //NSLog(@"start4");
        [self UpdateScore];
        //NSLog(@"start5");
        [self UpdateCamera:dt];
        //NSLog(@"start6");
        [self UpdateParticles:dt];
        //NSLog(@"start7");
        if (levelNumber==0) {
            [self UpdateLight:dt];
            //NSLog(@"start7");
        }
        updatesSinceLastPlanet++;
    } else if (isDisplayingPowerupAnimation)
        [self updatePowerupAnimation: dt];
    
    // if ([[self children]containsObject:background]&&[[self children]containsObject:background2])
    //    //NSLog(@"both backgrounds are on the screen! this should only happen when transitioning between galaxies.");
    
    if (isInTutorialMode)
        [self UpdateTutorial];
    if (!paused&&[((AppDelegate*)[[UIApplication sharedApplication]delegate])getWasJustBackgrounded])
    {
        [((AppDelegate*)[[UIApplication sharedApplication]delegate])setWasJustBackgrounded:false];
        [self togglePause];
    }
    player.currentPowerup.glowSprite.position = player.sprite.position;
}

- (void)endGame {
    if (!didEndGameAlready) {
        didEndGameAlready = true;
        [Flurry logEvent:@"Game ended" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:score],@"Score", [NSNumber numberWithInt:planetsHitFlurry],@"Planets traveled to",[NSNumber numberWithInt:segmentsSpawnedFlurry],@"Segments spawned", [NSNumber numberWithInt:(int)isInTutorialMode],@"isInTutorialMode", nil]];
        
        int finalScore = score + prevCurrentPtoPScore;
        if (!isInTutorialMode && !scoreAlreadySaved) {
            if ([[PlayerStats sharedInstance] isHighScore:finalScore]) {
                int plays = [[PlayerStats sharedInstance] getPlays];
                NSString *playsString = [NSString stringWithFormat:@"%d", plays];
                [[PlayerStats sharedInstance] addScore:finalScore withName:playsString];
            }
        }
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene: [MainMenuLayer scene]]];
    }
}

- (void)launchSurvey {
    [Flurry logEvent:@"Launched survey from gameplaylayer"];
    NSURL *url = [NSURL URLWithString:@"http://www.surveymonkey.com/s/PBD9L5H"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)UpdateTutorial {
    
}

- (void)restartGame {
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
            [self togglePause];
        }
        
        //else if (orbitState == 0) {
        [player setThrustBeginPoint:location];
        //playerIsTouchingScreen=true;
        //}
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
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
    
    if (ccpLength(swipeVector) >= minSwipeStrength && orbitState == 0 && !playerIsTouchingScreen) {
        playerIsTouchingScreen = true;
        if (!isInTutorialMode) {
            [self JustSwiped];
        }
    }
    
    // CCLOG(@"num: %f, newAng: %f", ccpLength(swipeVector), minSwipeStrength);
    // if (ccpLength(swipeVector) >= minSwipeStrength && tutorialAdvanceMode == 2 && isInTutorialMode) {
    //    [self AdvanceTutorial];
    // }
}

- (void)JustSwiped {
    orbitState = 1;
    targetPlanet = [planets objectAtIndex: (lastPlanetVisited.number + 1)];
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
    [Kamcord stopRecording];
    [Kamcord showView];
}

- (void)togglePause {
    paused = !paused;
    if (paused) {
        [Kamcord pause];
        pauseLayer = (CCLayer*)[CCBReader nodeGraphFromFile:@"PauseMenuLayer.ccb" owner:self];
        int finalScore = score + prevCurrentPtoPScore;
        [gameOverScoreLabel setString:[NSString stringWithFormat:@"Score: %d",finalScore]];
        [pauseLayer setTag:pauseLayerTag];
        [self addChild:pauseLayer];
    } else {
        [Kamcord resume];
        [self removeChildByTag:pauseLayerTag cleanup:NO];
    }
}

- (void)toggleMute {
    muted = !muted;
    if (!muted) {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:musicVolumeGameplay];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:effectsVolumeGameplay];
    } else {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
    }
}

- (void)dealloc {
    // before we add anything here, we should talk about what will be retained vs. released vs. set to nil in certain situations
    //LOL
    /*(for (int i = 0 ; i < [segments count]; i++){
     NSArray *chosenSegment = [segments objectAtIndex:i];
     for (int j = 0 ; j < [chosenSegment count];j++) {
     [[chosenSegment objectAtIndex:j] release];
     }
     }*/
    [super dealloc];
}



#if !defined(MIN)
#define MIN(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __a : __b; })
#endif

#if !defined(MAX)
#define MAX(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __b : __a; })
#endif

@end
