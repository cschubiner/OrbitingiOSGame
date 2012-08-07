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
    Coin *coin = [[Coin alloc]init];
    coin.sprite = [CCSprite spriteWithFile:@"star1.png"];
    coin.sprite.position = ccp(xPos, yPos);
    [coin.sprite setScale:scale*.4];
    coin.whichSegmentThisObjectIsOriginallyFrom = originalSegmentNumber;
    coin.segmentNumber = makingSegmentNumber;
    coin.number = coins.count;
    coin.whichGalaxyThisObjectBelongsTo  = currentGalaxy.number;
    [coins addObject:coin];
    [cameraLayer addChild:coin.sprite];
    //[spriteSheet addChild:coin.sprite];
    //[spriteSheet reorderChild:coin.sprite z:5];
    [coin release];
}

- (void)CreatePowerup:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale type:(int)type {
    Powerup *powerup = [[Powerup alloc]initWithType:type];
    
    powerup.coinSprite.position = ccp(xPos, yPos);
    powerup.coinSprite.scale = scale*8;
    
    [powerup.visualSprite setVisible:false];
    powerup.visualSprite.scale = 1.6;
    
    [powerup.hudSprite setVisible:false];
    powerup.hudSprite.position = ccp(30, 290);
    powerup.hudSprite.scale = .4;
    
    [powerups addObject:powerup];
    
    [spriteSheet addChild:powerup.coinSprite];
    [spriteSheet addChild:powerup.visualSprite];
    [hudLayer addChild:powerup.hudSprite];
    
    [spriteSheet reorderChild:powerup.visualSprite z:2.5];
    
    [powerup release];
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
  //  [self setGlow];
    Asteroid *asteroid = [[Asteroid alloc]init];
    asteroid.sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"asteroid%d.png",[self RandomBetween:1 maxvalue:2]]];
    asteroid.sprite.position = ccp(xPos, yPos);
    [asteroid.sprite setScale:scale];
    asteroid.whichSegmentThisObjectIsOriginallyFrom = originalSegmentNumber;
    asteroid.segmentNumber = makingSegmentNumber;
    asteroid.number = asteroids.count;
    asteroid.whichGalaxyThisObjectBelongsTo = currentGalaxy.number;
    [asteroids addObject:asteroid];
    [spriteSheet addChild:asteroid.sprite];
    [asteroid release];
}

- (void)CreatePlanetAndZone:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale {
    Planet *planet = [[Planet alloc]init];
    planet.sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"planet%d-%d.png",[self RandomBetween:1 maxvalue:currentGalaxy.numberOfDifferentPlanetsDrawn],currentGalaxy.number]];
    planet.sprite.position = ccp(xPos, yPos);
    planet.sprite.rotation = [self randomValueBetween:-180 andValue:180];
    [planet.sprite setScale:scale];
    planet.mass = 1;
    planet.segmentNumber = makingSegmentNumber;
    planet.whichSegmentThisObjectIsOriginallyFrom = originalSegmentNumber;
    Zone *zone = [[Zone alloc]init];
    zone.sprite = [CCSprite spriteWithSpriteFrameName:@"zone.png"];
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
    
    [spriteSheet addChild:planet.sprite];
    [spriteSheet addChild:zone.sprite];
    [zone release];
    [planet release];
    planetCounter++;
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
    if (abs(optimalPlanetsPerGalaxy-planetsHitSinceNewGalaxy)<abs(optimalPlanetsPerGalaxy-futurePlanetCount))
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
    }
    makingSegmentNumber++;
    return true;
}

- (void)CreateGalaxies // paste level creation code here
{
    
    [self CreatePowerup:700 yPos:500 scale:.3 type:2];
    
    [self CreatePowerup:1400 yPos:1000 scale:.3 type:1];
    
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
                //galaxy 1
                [[Galaxy alloc]initWithSegments:
                 [NSArray arrayWithObjects:
                  // Craig's 1-SpeedOne
                  [NSArray arrayWithObjects: [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1262,-252) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1778,418) scale:1.08252],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1317,467) scale:0.96752],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(479,406) scale:1.22052],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1034,38) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1110,61) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1179,81) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1671,103) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1752,92) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1843,78) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1056,88) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1131,115) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1810,135) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1702,42) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(232,-33) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(277,-32) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(234,18) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(275,19) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(230,-85) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(275,-84) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(234,66) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(277,68) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(644,23) scale:1.749999],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1437,137) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(2129,37) scale:1],
                   nil],
                  
                  nil]],
                
                
                //galaxy 2
                [[Galaxy alloc]initWithSegments:
                 [NSArray arrayWithObjects:
                  //coin trail happy
                  [NSArray arrayWithObjects: [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(224,-138) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(760,78) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1182,10) scale:1.19752],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1683,-77) scale:0.76052],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1708,-28) scale:0.48384],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(593,91) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(618,42) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(643,-4) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(668,-51) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(694,-98) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(724,-147) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(556,127) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1130,-202) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1175,-171) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1215,-136) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1252,-101) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1277,-56) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(757,-180) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(794,-209) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(834,-233) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(882,-250) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(935,-261) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(983,-260) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1027,-252) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1075,-236) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(479,6) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(952,-132) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1428,-29) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1948,-107) scale:1],
                   nil],
                  // Craig's 2-Simple1
                  [NSArray arrayWithObjects: [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(294,-224) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(373,-187) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(303,-159) scale:0.66852],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1655,-73) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(838,213) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2287,-43) scale:1.19752],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(583,-101) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(583,-47) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(585,8) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(588,57) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(552,30) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(548,-24) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(545,-78) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1335,14) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1385,22) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1359,66) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1119,126) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1171,132) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1146,83) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1512,177) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1564,181) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1542,126) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2098,13) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2147,0) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2186,-49) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2207,0) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2352,-100) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2371,-45) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2405,-87) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2449,-103) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(755,-8) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1826,109) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(2787,-127) scale:1],
                   nil],
                  
                  
                  nil]],
                //galaxy 3
                [[Galaxy alloc]initWithSegments:
                 [NSArray arrayWithObjects:
                  // Craig's 3-CrossStraightCross
                  [NSArray arrayWithObjects: [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(368,-195) scale:1.10552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(316,214) scale:1.01352],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(423,184) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1392,75) scale:1.15152],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1368,146) scale:0.69152],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1301,106) scale:0.48384],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1299,153) scale:0.71452],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2291,-66) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2326,-3) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2428,239) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2434,303) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(369,74) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(367,19) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(367,-36) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(366,-94) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1414,-52) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1469,-30) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1427,1) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1249,200) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1304,210) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1267,247) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2364,185) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2431,165) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2310,66) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2384,43) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2340,126) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2411,101) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(858,-53) scale:1.21],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1839,246) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(2902,57) scale:1],
                   nil],
                  
                  // Craig's 3-FourCrosses
                  [NSArray arrayWithObjects: [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(568,-11) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(622,-106) scale:1.19752],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(453,252) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(388,387) scale:1.28952],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1533,209) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1486,283) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1303,563) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1252,631) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1875,142) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1947,199) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2166,379) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2235,438) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(3018,-170) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(3011,-73) scale:1.17452],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(3005,198) scale:1.17452],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(3005,282) scale:0.94452],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(415,91) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(456,105) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(498,123) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(538,135) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1315,395) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1357,417) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1399,439) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1396,394) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1357,367) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1357,368) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1318,439) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1355,461) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2034,269) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2091,268) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2066,319) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2949,109) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3061,15) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2948,16) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3059,110) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3003,62) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(900,230) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1752,551) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(2427,67) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(3526,56) scale:1],
                   nil],
                  
                  //Clay Level
                  [NSArray arrayWithObjects: [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(688,-64) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(740,4) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(763,87) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(751,173) scale:1.22052],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(519,466) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(574,559) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(659,616) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(772,637) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1454,422) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1537,367) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1443,525) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1354,593) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1210,616) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1301,195) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1346,105) scale:0.87552],
                   [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1809,269) scale:1.24352],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(147,-115) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(171,-71) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(183,-16) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(175,49) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(144,98) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(212,102) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(243,48) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(239,-22) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(230,-87) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(219,-138) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(347,-143) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(280,-142) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(304,-93) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(289,-23) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(292,49) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(296,109) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(444,207) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(485,254) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(535,300) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(575,346) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(931,512) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(994,511) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1052,509) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(616,397) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(652,441) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(705,486) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(770,510) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(856,513) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1224,512) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1301,503) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1348,439) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1111,511) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1170,519) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1372,373) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1381,316) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1393,246) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1415,170) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1442,104) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1705,27) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1755,72) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1802,112) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1843,161) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1889,201) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1772,16) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1946,13) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1828,17) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1888,11) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(468,9) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(779,380) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1226,378) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1575,147) scale:1],
                   [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(2041,147) scale:1],
                   nil],
                  
                  
                  
                  nil]],
                //galaxy 4
                [[Galaxy alloc]initWithSegments:
                 [NSArray arrayWithObjects:
                  
                  
                  
                  nil]],
                //galaxy 5
                [[Galaxy alloc]initWithSegments:
                 [NSArray arrayWithObjects:
                  
                  
                  
                  nil]],
                //galaxy 6
                [[Galaxy alloc]initWithSegments:
                 [NSArray arrayWithObjects:
                  
                  
                  
                  nil]],
                //galaxy 7
                [[Galaxy alloc]initWithSegments:
                 [NSArray arrayWithObjects:
                  
                  
                  
                  nil]],
                
                
                
                nil];
    
}

- (void)setGalaxyProperties {
    Galaxy* galaxy;
    galaxy = [galaxies objectAtIndex:0];
    [galaxy setName:@"Galaxy 1 - The Solar System"];
    [galaxy setNumberOfDifferentPlanetsDrawn:3];
    
    galaxy = [galaxies objectAtIndex:1];
    [galaxy setName:@"Galaxy 2 - Grasslands"];
    [galaxy setNumberOfDifferentPlanetsDrawn:3];
    
    galaxy = [galaxies objectAtIndex:2];
    [galaxy setName:@"Galaxy 3 - Girly Galaxy"];
    [galaxy setNumberOfDifferentPlanetsDrawn:3];
}

- (void)initUpgradedVariables {
    [[UpgradeValues sharedInstance] setAsteroidImmunityDuration:100 + 100];
    [[UpgradeValues sharedInstance] setCoinMagnetDuration:100 + 100*5];
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
        coinSprites = [[NSMutableArray alloc] init];
        CCTexture2D* tex1 = [[CCTextureCache sharedTextureCache] addImage:@"star1.png"];
        CCTexture2D* tex2 = [[CCTextureCache sharedTextureCache] addImage:@"star2.png"];
        CCTexture2D* tex3 = [[CCTextureCache sharedTextureCache] addImage:@"star3.png"];
        CCTexture2D* tex4 = [[CCTextureCache sharedTextureCache] addImage:@"star4.png"];
        CCTexture2D* tex5 = [[CCTextureCache sharedTextureCache] addImage:@"star5.png"];
        CCTexture2D* tex6 = [[CCTextureCache sharedTextureCache] addImage:@"star6.png"];
        CCTexture2D* tex7 = [[CCTextureCache sharedTextureCache] addImage:@"star7.png"];
        CCTexture2D* tex8 = [[CCTextureCache sharedTextureCache] addImage:@"star8.png"];
        CCTexture2D* tex9 = [[CCTextureCache sharedTextureCache] addImage:@"star9.png"];
        CCTexture2D* tex10 = [[CCTextureCache sharedTextureCache] addImage:@"star10.png"];
        CCTexture2D* tex11 = [[CCTextureCache sharedTextureCache] addImage:@"star11.png"];
        CCTexture2D* tex12 = [[CCTextureCache sharedTextureCache] addImage:@"star12.png"];
        [coinSprites addObject:tex1];
        [coinSprites addObject:tex2];
        [coinSprites addObject:tex3];
        [coinSprites addObject:tex4];
        [coinSprites addObject:tex5];
        [coinSprites addObject:tex6];
        [coinSprites addObject:tex7];
        [coinSprites addObject:tex8];
        [coinSprites addObject:tex9];
        [coinSprites addObject:tex10];
        [coinSprites addObject:tex11];
        [coinSprites addObject:tex12];
        
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
            scoreLabel = [CCLabelTTF labelWithString:@"Score: " fontName:@"Marker Felt" fontSize:20];
            scoreLabel.position = ccp(420, [scoreLabel boundingBox].size.height);
            [hudLayer addChild: scoreLabel];
            
            coinsLabel = [CCLabelTTF labelWithString:@"Coins: " fontName:@"Marker Felt" fontSize:20];
            coinsLabel.position = ccp(50, [coinsLabel boundingBox].size.height);
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
        
        [self playSound:@"a_song.mp3" shouldLoop:YES];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"bomb.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"SWOOSH.WAV"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"buttonpress.mp3"];
        
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"spriteSheet.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spriteSheet.plist"];
        
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
        player.sprite = [CCSprite spriteWithSpriteFrameName:@"spaceship-hd.png"];
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
        id action2 = [CCSequence actions:[CCSpawn actions:fadeAction,[CCScaleTo actionWithDuration:.3 scale:1.06], nil], nil] ;
        id repeatAction = [CCRepeat actionWithAction:[CCSequence actions:[CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.8 scale:1.0f]],[CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.8 scale:1.06f]], nil] times:2];
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
        coinAnimator = 0;
        coinAnimator2 = 0;
        powerupPos = 0;
        powerupVel = 0;
        
        background = [CCSprite spriteWithFile:@"background0.pvr.ccz"];
        background2 = [CCSprite spriteWithFile:@"background1.pvr.ccz"];
        //     background.position = ccp(size.width/2+61,14);
        background.position = ccp(size.width/4*1.5*1.3,15);
        background.scale *=1.98f;
        //      background2.position = ccp(size.width/2+61,14);
        background2.position = ccp(size.width/4*1.5*1.3,15);
        
        background2.scale *=1.98f;
        [background2 retain];
        [background retain];
        [self addChild:background];
        
        [self addChild:cometParticle];
        cometParticle.position = ccp([self RandomBetween:0 maxvalue:390],325);
        cometVelocity = ccp([self RandomBetween:-10 maxvalue:10]/5,-[self RandomBetween:1 maxvalue:23]/5);
        [self resetVariablesForNewGame];
        
        light = [[Light alloc] init];
        light.score = -negativeLightStartingScore;
        light.scoreVelocity = initialLightScoreVelocity;
        //  glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        light.hasPutOnLight = false;
        
        [cameraLayer addChild:spriteSheet];
        
        lastPlanetVisited = [planets objectAtIndex:0];
        layerHudSlider = (CCLayer*)[CCBReader nodeGraphFromFile:@"hudLayer.ccb" owner:self];
        
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

- (void)UserTouchedCoin: (Coin*)coin {
    [[UserWallet sharedInstance] addCoins:1];
    score += howMuchCoinsAddToScore;
    coin.sprite.visible = false;
    coin.isAlive = false;
    [self playSound:@"buttonpress.mp3" shouldLoop:false];
}

- (void)playSound:(NSString*)soundFile shouldLoop:(bool)shouldLoop {
    [Kamcord playSound:soundFile loop:shouldLoop];
    if (shouldLoop)
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:soundFile loop:YES];
    else
        [[SimpleAudioEngine sharedEngine]playEffect:soundFile];
}

- (void)ApplyGravity:(float)dt {
    
    for (Coin* coin in coins) {
        
        CGPoint p = coin.sprite.position;
        
        coin.velocity = ccpMult(ccpNormalize(ccpSub(player.sprite.position, p)), coin.speed);
        coin.sprite.position = ccpAdd(coin.sprite.position, coin.velocity);
        
        if (ccpLength(ccpSub(player.sprite.position, p)) <= coin.radius + player.sprite.height/1.3 && coin.isAlive) {
            [self UserTouchedCoin:coin];
        }
    }
    
    bool isHittingAsteroid = false;
    for (Asteroid* asteroid in asteroids) {
        CGPoint p = asteroid.sprite.position;
        if (player.alive && ccpLength(ccpSub(player.sprite.position, p)) <= asteroid.radius * asteroidRadiusCollisionZone && orbitState == 3) {
            isHittingAsteroid = true;
        }
    }
    
    if (!(player.currentPowerup.type == 1)) {
        if (isHittingAsteroid)
            asteroidSlower -= .1;
        else
            asteroidSlower += .01;
        asteroidSlower = clampf(asteroidSlower, .13, 1);
    }
    
    
    
    for (Powerup* powerup in powerups) {
        CGPoint p = powerup.coinSprite.position;
        if (player.alive && ccpLength(ccpSub(player.sprite.position, p)) <= powerup.coinSprite.width * .5 * powerupRadiusCollisionZone) {
            if (powerup.coinSprite.visible) {
                [powerup.coinSprite setVisible:false];
                if (player.currentPowerup != nil) {
                    [player.currentPowerup.visualSprite setVisible:false];
                    [player.currentPowerup.hudSprite setVisible:false];
                }
                paused = true;
                isDisplayingPowerupAnimation = true;
                powerupPos = 0;
                powerupVel = 0;
                player.currentPowerup = powerup;
                [player.currentPowerup.visualSprite setVisible:true];
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
        
        if (player.currentPowerup.visualSprite.visible) {
            updatesWithoutBlinking++;
        }
        
        if (updatesWithoutBlinking >= blinkAfterThisManyUpdates && updatesLeft <= 300) {
            updatesWithoutBlinking = 0;
            //[player.currentPowerup.hudSprite setVisible:false];
            [player.currentPowerup.visualSprite setVisible:false];
            
        }
        if (!player.currentPowerup.visualSprite.visible) {
            updatesWithBlinking++;
        }
        
        if (updatesWithBlinking >= clampf(8*updatesLeft/100, 3, 99999999)) {
            updatesWithBlinking = 0;
            //[player.currentPowerup.hudSprite setVisible:true];
            [player.currentPowerup.visualSprite setVisible:true];
        }
        
        if (powerupCounter >= player.currentPowerup.duration) {
            //[player.currentPowerup.hudSprite setVisible:false];
            [player.currentPowerup.visualSprite setVisible:false];
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
                    player.sprite.position = ccpAdd(player.sprite.position, ccpMult(ccpNormalize(a), (planet.orbitRadius - ccpLength(a))*howFastOrbitPositionGetsFixed*timeDilationCoefficient*60*dt/absoluteMinTimeDilation));
                }
                
                velSoftener += 1/updatesToMakeOrbitVelocityPerfect;
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
                    [self playSound:@"SWOOSH.WAV" shouldLoop:false];
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
                gravIncreaser += increaseGravStrengthByThisMuchEveryUpdate;
                
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
        
        timeDilationCoefficient = clampf(timeDilationCoefficient, absoluteMinTimeDilation, absoluteMaxTimeDilation);
        
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
        
        bool isGoingCounterClockwise;
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
        [playerSpawnedParticle setVisible:true];
        
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
    if (lastPlanetVisited.number==0) {
        cameraShouldFocusOnPlayer = false;
    }
    else {
        Planet * nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number+1)];
        
        if (
            //nextPlanet.whichGalaxyThisObjectBelongsTo > lastPlanetVisited.whichGalaxyThisObjectBelongsTo||
            targetPlanet.whichGalaxyThisObjectBelongsTo>lastPlanetVisited.whichGalaxyThisObjectBelongsTo) {
            cameraShouldFocusOnPlayer=true;
            float firsttoplayer = ccpToAngle(ccpSub(lastPlanetVisited.sprite.position, player.sprite.position));
            float planetAngle = ccpToAngle(ccpSub(lastPlanetVisited.sprite.position, nextPlanet.sprite.position));
            float firstToPlayerAngle = firsttoplayer-planetAngle;
            float firstToPlayerDistance = ccpDistance(lastPlanetVisited.sprite.position, player.sprite.position)*cosf(firstToPlayerAngle);
            float firsttonextDistance = ccpDistance(lastPlanetVisited.sprite.position, nextPlanet.sprite.position);
            float percentofthewaytonext = firstToPlayerDistance/firsttonextDistance;
            percentofthewaytonext*=1.18;
            if (percentofthewaytonext>1) percentofthewaytonext = 1;
            if ([[self children]containsObject:background]) {
                if ([[self children]containsObject:background2]==false) {
                    [self reorderChild:background z:-5];
                    [background2 setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"background%d.pvr.ccz",targetPlanet.whichGalaxyThisObjectBelongsTo]]];
                    [self addChild:background2 z:-6];
                }
            }
            if ([[self children]containsObject:background2]) {
                if ([[self children]containsObject:background]==false) {
                    [self reorderChild:background2 z:-5];
                    [background setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"background%d.pvr.ccz",targetPlanet.whichGalaxyThisObjectBelongsTo]]];
                    [self addChild:background z:-6];
                }
            }
            if (background.zOrder<background2.zOrder)
            {
                [background setOpacity:255];
                [background2 setOpacity:lerpf(255, 0, percentofthewaytonext)];
            }
            else {
                [background2 setOpacity:255];
                [background setOpacity:lerpf(255, 0, percentofthewaytonext)];
            }
            if (percentofthewaytonext>.85&&justDisplayedGalaxyLabel==false&&(int)galaxyLabel.opacity<=0)
            {
                if ([[hudLayer children]containsObject:galaxyLabel]==false)
                    [hudLayer addChild:galaxyLabel];
                [galaxyLabel setOpacity:1];
                [galaxyLabel setString:[currentGalaxy name]];
                [galaxyLabel stopAllActions];
                [galaxyLabel runAction:galaxyLabelAction];
                justDisplayedGalaxyLabel= true;
            }
        }
        else
            cameraShouldFocusOnPlayer=false;
    }
    
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
        
        makingSegmentNumber--;
        
        if ([self CreateSegment]==false) {
            justDisplayedGalaxyLabel = false;
            planetsHitSinceNewGalaxy=0;
            currentGalaxy = nextGalaxy;
            nextGalaxy = [galaxies objectAtIndex:currentGalaxy.number+1];
            Planet*lastPlanetOfThisGalaxy = [planets objectAtIndex:planets.count-1];
            [self CreateCoinArrowAtPosition:ccpAdd(lastPlanetOfThisGalaxy.sprite.position, ccpMult(ccpForAngle(CC_DEGREES_TO_RADIANS(directionPlanetSegmentsGoIn)), lastPlanetOfThisGalaxy.orbitRadius*2.1)) withAngle:directionPlanetSegmentsGoIn];
            indicatorPos = ccpAdd(indicatorPos, ccpMult(ccpForAngle(CC_DEGREES_TO_RADIANS(directionPlanetSegmentsGoIn)), distanceBetweenGalaxies));
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
    [scoreLabel setString:[NSString stringWithFormat:@"Score: %d",score]];
    
    int numCoins = [[UserWallet sharedInstance] getBalance];
    int coinsDiff = numCoins - startingCoins;
    [coinsLabel setString:[NSString stringWithFormat:@"Coins: %i",coinsDiff]];
}

- (void)UpdateParticles:(ccTime)dt {
    [thrustParticle setPosition:player.sprite.position];
    [thrustParticle setAngle:180+CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity))];
    // [thrustParticle setEmissionRate:ccpLengthSQ(player.velocity)*ccpLength(player.velocity)/2.2f];
    float speedPercent = (timeDilationCoefficient-absoluteMinTimeDilation)/(absoluteMaxTimeDilation-absoluteMinTimeDilation);
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
    if (!isGameOver) { //this ensures it only runs once
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
        [[PlayerStats sharedInstance] addScore:finalScore];
        scoreAlreadySaved = YES;
        [DataStorage storeData];
        if ([[PlayerStats sharedInstance] getPlays] == 10) {
            [Flurry logEvent:@"forced user to launch survey on gameplaylayer"];
            [self launchSurvey];
        }
    }
}

- (void)UpdateLight {
    light.distanceFromPlayer = score - light.score;
    
    if (light.distanceFromPlayer > negativeLightStartingScore)
        light.score = score - negativeLightStartingScore;
    
    
    light.scoreVelocity += amountToIncreaseLightScoreVelocityEachUpdate;
    if (!isInTutorialMode&&levelNumber==0)
        [slidingSelector setPosition:ccp(slidingSelector.position.x,lerpf(50.453,269.848,1-light.distanceFromPlayer/negativeLightStartingScore))];
    
    //    CCLOG(@"DIST: %f, VEL: %f, LIGHSCORE: %f", light.distanceFromPlayer, light.scoreVelocity, light.score);
    
    
    /*if (distance <= 100) {
     [light.sprite setTextureRect:CGRectMake(0, 0, 0, 0)];
     [self GameOver];
     } else*/ if (light.distanceFromPlayer <= 0) {
         /*if (!light.hasPutOnLight) {
          light.hasPutOnLight = true;
          light.sprite = [CCSprite spriteWithFile:@"OneByOne.png"];
          [light.sprite setOpacity:0];
          light.sprite.position = ccp(240, 160);
          [light.sprite setTextureRect:CGRectMake(0, 0, 480, 320)];
          [hudLayer reorderChild:light.sprite z:-1];
          }
          [light.sprite setOpacity:clampf(((600-distance)/500)*255, 0, 255)];*/
         if (!light.hasPutOnLight) {
             light.hasPutOnLight = true;
             light.sprite = [CCSprite spriteWithFile:@"OneByOne.png"];
             [light.sprite setOpacity:0];
             light.sprite.position = ccp(-240, 160);
             [light.sprite setTextureRect:CGRectMake(0, 0, 480, 320)];
             [hudLayer reorderChild:light.sprite z:-1];
             [light.sprite setOpacity:0];
         }
     }
    
    if (light.hasPutOnLight) {
        light.sprite.position = ccp(light.sprite.position.x+480/10, light.sprite.position.y);
        [light.sprite setOpacity:clampf((light.sprite.position.x+240)*255/480, 0, 255)];
    }
    if (light.sprite.position.x >= 240) {
        //[light.sprite setTextureRect:CGRectMake(0, 0, 0, 0)];
        [self GameOver];
    }
    
    if (!isInTutorialMode)
        light.score += light.scoreVelocity;
}

- (void)UpdateCoinAnimations {
    coinAnimator2++;
    if (coinAnimator2 >= 1) { //how many updates to display each image
        coinAnimator2 = 0;
        coinAnimator++;
    }
    
    if (coinAnimator >= [coinSprites count]) {
        coinAnimator = 0;
    }
    
    for (Coin* coin in coins) {
        
        CCTexture2D* tx = [coinSprites objectAtIndex:coinAnimator];
        [coin.sprite setTexture:tx];
        
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
    
    if (!paused&&isGameOver==false) {
        if (zonesReached<[planets count]) {
            totalGameTime+=dt;
            totalSecondsAlive+=dt;
        }
        
        if (player.alive) {
            [self UpdatePlanets];
            [self UpdateGalaxies];
        }
        [self UpdateCoinAnimations];
        [self UpdatePlayer: dt];
        [self UpdateScore];
        [self UpdateCamera:dt];
        [self UpdateParticles:dt];
        if (levelNumber==0)
            [self UpdateLight];
        updatesSinceLastPlanet++;
    } else if (isDisplayingPowerupAnimation)
        [self updatePowerupAnimation: dt];
    
    if (isInTutorialMode)
        [self UpdateTutorial];
    if (!paused&&[((AppDelegate*)[[UIApplication sharedApplication]delegate])getWasJustBackgrounded])
    {
        [((AppDelegate*)[[UIApplication sharedApplication]delegate])setWasJustBackgrounded:false];
        [self togglePause];
    }
    player.currentPowerup.visualSprite.position = player.sprite.position;
}

- (void)endGame {
    if (!didEndGameAlready) {
        didEndGameAlready = true;
        [Flurry logEvent:@"Game ended" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:score],@"Score", [NSNumber numberWithInt:planetsHitFlurry],@"Planets traveled to",[NSNumber numberWithInt:segmentsSpawnedFlurry],@"Segments spawned", [NSNumber numberWithInt:(int)isInTutorialMode],@"isInTutorialMode", nil]];
        
        int finalScore = score + prevCurrentPtoPScore;
        if (!isInTutorialMode && !scoreAlreadySaved) {
            [[PlayerStats sharedInstance] addScore:finalScore];
        }
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene: [MainMenuLayer scene]]];
        if ([[PlayerStats sharedInstance] getPlays] == 10) {
            [Flurry logEvent:@"forced user to launch survey on gameplaylayer"];
            [self launchSurvey];
        }
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
    //[DataStorage storeData];
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
