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
    coin.sprite = [CCSprite spriteWithSpriteFrameName:@"coin.png"];
    coin.sprite.position = ccp(xPos, yPos);
    [coin.sprite setScale:scale];
    coin.whichSegmentThisObjectIsOriginallyFrom = originalSegmentNumber;
    coin.segmentNumber = makingSegmentNumber;
    coin.number = coins.count;
    [coins addObject:coin];
    [spriteSheet addChild:coin.sprite];
    [spriteSheet reorderChild:coin.sprite z:5];
    [coin release];
}

- (void)CreatePowerup:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale {
    Powerup *powerup = [[Powerup alloc]init];
    powerup.sprite = [CCSprite spriteWithFile:@"upgradecoin.png"];
    powerup.sprite.position = ccp(xPos, yPos);
    [powerup.sprite setScale:scale];
    [powerups addObject:powerup];
    [cameraLayer addChild:powerup.sprite];
    [powerup release];
}

- (void)CreateAsteroid:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale {
    Asteroid *asteroid = [[Asteroid alloc]init];
    asteroid.sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"asteroid%d.png",[self RandomBetween:1 maxvalue:2]]];
    asteroid.sprite.position = ccp(xPos, yPos);
    [asteroid.sprite setScale:scale];
    asteroid.whichSegmentThisObjectIsOriginallyFrom = originalSegmentNumber;
    asteroid.segmentNumber = makingSegmentNumber;
    asteroid.number = asteroids.count;
    [asteroids addObject:asteroid];
    [spriteSheet addChild:asteroid.sprite];
    [asteroid release];
}

- (void)CreatePlanetAndZone:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale {
    Planet *planet = [[Planet alloc]init];
    planet.sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"planet%d.png",[self RandomBetween:1 maxvalue:8]]];
    planet.sprite.position =  ccp(xPos, yPos);
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
    
    planet.number = [planets count];
    zone.number = [zones count];
    [planets addObject:planet];
    [zones addObject:zone];
    
    [spriteSheet addChild:planet.sprite];
    [spriteSheet addChild:zone.sprite];
    // [zone release];
    // [planet release];
    planetCounter++;
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

- (void)CreateLevel // paste level creation code here
{
    
    [self CreatePowerup:1000 yPos:700 scale:.2];
    
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

/* On "init," initialize the instance */
- (id)init {
	// always call "super" init.
	// Apple recommends to re-assign "self" with the "super" return value
	if ((self = [super init])) {
        startingCoins = [[UserWallet sharedInstance] getBalance];
        size = [[CCDirector sharedDirector] winSize];
        self.isTouchEnabled= TRUE;
        
        isInTutorialMode = [((AppDelegate*)[[UIApplication sharedApplication]delegate]) getIsInTutorialMode];
        isInTutorialMode = false;
        levelNumber = [((AppDelegate*)[[UIApplication sharedApplication]delegate])getChosenLevelNumber];
        
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
        //  [cameraLayer addChild:planetExplosionParticle];
        playerExplosionParticle = [CCParticleSystemQuad particleWithFile:@"playerExplosionParticle.plist"];
        [cameraLayer addChild:playerExplosionParticle];
        [playerExplosionParticle setVisible:false];
        [playerExplosionParticle stopSystem];
        thrustParticle = [CCParticleSystemQuad particleWithFile:@"thrustParticle3.plist"];
        
        CCMenuItem  *pauseButton = [CCMenuItemImage 
                                    itemFromNormalImage:@"pauseButton7.png" selectedImage:@"pauseButton7.png" 
                                    target:self selector:@selector(togglePause)];
        pauseButton.position = ccp(457, 298);
        pauseMenu = [CCMenu menuWithItems:pauseButton, nil];
        pauseMenu.position = CGPointZero;
        
        if (!isInTutorialMode) {
            scoreLabel = [CCLabelTTF labelWithString:@"Score: " fontName:@"Marker Felt" fontSize:24];
            scoreLabel.position = ccp(400, [scoreLabel boundingBox].size.height);
            [hudLayer addChild: scoreLabel];
            
            coinsLabel = [CCLabelTTF labelWithString:@"Coins: " fontName:@"Marker Felt" fontSize:24];
            coinsLabel.position = ccp(70, [coinsLabel boundingBox].size.height);
            [hudLayer addChild: coinsLabel];
        } 
        else {
            tutorialState = 0;
            tutorialFader = 0;
            tutorialAdvanceMode = 0;
            shouldDisplayWaiting = false;
            
            tutorialLabel1 = [CCLabelTTF labelWithString:@" " fontName:@"Marker Felt" fontSize:24];
            tutorialLabel1.position = ccp(240, 320-[tutorialLabel1 boundingBox].size.height*.6);
            [hudLayer addChild: tutorialLabel1];
            
            tutorialLabel2 = [CCLabelTTF labelWithString:@" " fontName:@"Marker Felt" fontSize:24];
            tutorialLabel2.position = ccp(240, 320-[tutorialLabel2 boundingBox].size.height*1.6);
            [hudLayer addChild: tutorialLabel2];
            
            tutorialLabel3 = [CCLabelTTF labelWithString:@" " fontName:@"Marker Felt" fontSize:24];
            tutorialLabel3.position = ccp(240, 320-[tutorialLabel3 boundingBox].size.height*2.6);
            [hudLayer addChild: tutorialLabel3];
            
            tutorialLabel0 = [CCLabelTTF labelWithString:@" " fontName:@"Marker Felt" fontSize:21];
            tutorialLabel0.position = ccp(240, [tutorialLabel0 boundingBox].size.height*.7);
            [hudLayer addChild: tutorialLabel0];
        }
        
        [self playSound:@"a_song.mp3" shouldLoop:YES];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"bomb.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"SWOOSH.WAV"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"buttonpress.mp3"];
        
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"spriteSheet.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spriteSheet.plist"];
        
        [self CreateLevel];
        currentGalaxy = [galaxies objectAtIndex:0];
        nextGalaxy = [galaxies objectAtIndex:1];
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
        player.sprite.position = [self GetPositionForJumpingPlayerToPlanet:0];
        
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
        isTutPaused = false;
        swipeVector = ccp(0, -1);
        gravIncreaser = 1;
        handCounter = 0;
        updatesSinceLastPlanet = 0;
        tutorialPauseTimer = 0;
        updatesToAdvanceTutorial = 0;
        tutorialIsTryingToAdvance = false;
        asteroidSlower = 1;
        powerupCounter = 0;
        updatesWithoutBlinking = 0;
        updatesWithBlinking = 999;
        
        asteroidImmunityHUD = [CCSprite spriteWithFile:@"asteroidhudicon.png"];
        [hudLayer addChild:asteroidImmunityHUD];
        asteroidImmunityHUD.position = ccp(30, 290);
        asteroidImmunityHUD.scale = .4;
        asteroidGlow = [CCSprite spriteWithFile:@"asteroidglowupgrade.png"];
        [cameraLayer addChild:asteroidGlow];
        asteroidGlow.scale = 1.5;
        [cameraLayer reorderChild:asteroidGlow z:2.5];

        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444]; // add this line at the very beginning
        background = [CCSprite spriteWithFile:@"background.pvr.ccz"];
        background.position = ccp(size.width/2+61,14);
        background.scale *=1.28f;
        [self addChild:background];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888]; // add this line at the very beginning
        
        [self addChild:cometParticle];
        cometParticle.position = ccp([self RandomBetween:0 maxvalue:390],325);
        cometVelocity = ccp([self RandomBetween:-10 maxvalue:10]/5,-[self RandomBetween:1 maxvalue:23]/5);
        [self resetVariablesForNewGame];
        
        hand = [CCSprite spriteWithFile:@"edit(84759).png"];
        hand.position = ccp(-1000, -1000);
        
        
        light = [[Light alloc] init];
        light.score = -negativeLightStartingScore;
        light.scoreVelocity = initialLightScoreVelocity;
        glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        light.hasPutOnLight = false;
        
        
        [cameraLayer addChild:spriteSheet];
        [hudLayer addChild:hand];
        
        cameraDistToUse = 1005.14;
        [cameraLayer setScale:.43608];
        [cameraLayer setPosition:ccp(98.4779,67.6401)];
        cameraLastFocusPosition = ccp(325.808,213.3);
        [cameraFocusNode setPosition:ccp(142.078,93.0159)];
        
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
    float firstToPlayerDistance = 0;
    firstToPlayerDistance = ccpDistance(lastPlanetVisited.sprite.position, player.sprite.position)*cosf(firstToPlayerAngle);  
    //  if (orbitState == 0 || nextPlanet.number + 1 >= [planets count]) 
    //    firstToPlayerDistance = lerpf(firstToPlayerDistance,0,cameraMovementSpeed);//MIN(firstToPlayerDistance,0);
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
    CGPoint focusPointTwo = ccpAdd(ccpMult(ccpSub(planet2.sprite.position, planet1.sprite.position), percentofthewaytonext) ,planet1.sprite.position);
    //CGPoint focusPosition = ccpMult(ccpAdd(focusPointOne, ccpSub(focusPointTwo, focusPointOne)), .5f);
    CGPoint focusPosition = ccpMult(ccpAdd(ccpMult(focusPointOne, cameraScaleFocusedOnFocusPosOne), focusPointTwo), 1.0f/(cameraScaleFocusedOnFocusPosOne+1.0f));
    // cameraDistToUse = lerpf(cameraDistToUse, ccpDistance(focusPointOne, focusPointTwo)+ ((Zone*)[zones objectAtIndex:lastPlanetVisited.number]).radius + ((Zone*)[zones objectAtIndex:planet1.number]).radius,cameraZoomSpeed);
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
        cameraLastFocusPosition = ccpLerp(cameraLastFocusPosition, focusPosition, cameraMovementSpeed);
        [self scaleLayer:cameraLayer scaleToZoomTo:lerpf([cameraLayer scale], scale, cameraZoomSpeed) scaleCenter:cameraLastFocusPosition];
        id followAction = [CCFollow actionWithTarget:cameraFocusNode];
        [cameraLayer runAction: followAction];
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
    
    if (player.hasAsteroidImmunity) {
        [asteroidGlow setVisible:true];
        
        int updatesLeft = asteroidImmunityDurationInUpdates - powerupCounter;
        float blinkAfterThisManyUpdates = updatesLeft*.12;
        
        if (asteroidImmunityHUD.visible) {
            updatesWithoutBlinking++;
        }
        
        if (updatesWithoutBlinking >= blinkAfterThisManyUpdates && updatesLeft <= 300) {
            updatesWithoutBlinking = 0;
            [asteroidImmunityHUD setVisible:false];
            
        }
        if (!asteroidImmunityHUD.visible) {
            updatesWithBlinking++;
        }
        
        if (updatesWithBlinking >= clampf(8*updatesLeft/100, 3, 99999999)) {
            updatesWithBlinking = 0;
            [asteroidImmunityHUD setVisible:true];
        }
        
        
        if (powerupCounter >= asteroidImmunityDurationInUpdates)
            player.hasAsteroidImmunity = false;
    } else {
        [asteroidGlow setVisible:false];
        [asteroidImmunityHUD setVisible:false];
        if (isHittingAsteroid)
            asteroidSlower -= .09;
        else
            asteroidSlower += .01;
        asteroidSlower = clampf(asteroidSlower, .15, 1);
    }
    
    
    powerupCounter++;
    
    
    for (Powerup* powerup in powerups) {
        CGPoint p = powerup.sprite.position;
        if (player.alive && ccpLength(ccpSub(player.sprite.position, p)) <= powerup.radius * powerupRadiusCollisionZone) {
            //[self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number];
            [cameraLayer removeChild:powerup.sprite cleanup:true];
            [powerups removeObject:powerup];
            player.hasAsteroidImmunity = true;
            powerupCounter = 0;
        }
    }
    
    
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
                    //float offset = planet.orbitRadius/ccpLength(a);
                    //player.sprite.position = ccpAdd(planet.sprite.position, ccpMult(a, offset));
                    player.sprite.position = ccpAdd(player.sprite.position, ccpMult(ccpNormalize(a), (planet.orbitRadius - ccpLength(a))*howFastOrbitPositionGetsFixed*timeDilationCoefficient/absoluteMinTimeDilation));
                }
                
                velSoftener += 1/updatesToMakeOrbitVelocityPerfect;
                //velSoftener = 1;
                velSoftener = clampf(velSoftener, 0, 1);                
                
                //CCLOG(@"cur: %f", velSoftener);
                
                CGPoint dir2 = ccpNormalize(CGPointApplyAffineTransform(a, CGAffineTransformMakeRotation(M_PI/2)));
                CGPoint dir3 = ccpNormalize(CGPointApplyAffineTransform(a, CGAffineTransformMakeRotation(-M_PI/2)));            
                if (ccpLength(ccpSub(ccpAdd(a, dir2), ccpAdd(a, player.velocity))) < ccpLength(ccpSub(ccpAdd(a, dir3), ccpAdd(a, player.velocity)))) { //up is closer
                    //player.velocity = ccpMult(dir2, ccpLength(initialVel));
                    player.velocity = ccpAdd(ccpMult(player.velocity, (1-velSoftener)*1), ccpMult(dir2, velSoftener*ccpLength(initialVel))); 
                    
                    //as velSoftener goes from 0 -> 1, player.velocity -> dir2
                }
                else {
                    //player.velocity = ccpMult(dir3, ccpLength(initialVel));
                    player.velocity = ccpAdd(ccpMult(player.velocity, (1-velSoftener)*1), ccpMult(dir3, velSoftener*ccpLength(initialVel)));
                }
                
                
                CGPoint direction = ccpNormalize(ccpSub(planet.sprite.position, player.sprite.position));
                player.acceleration = ccpMult(direction, gravity);
            } else if (orbitState == 1) 
            {
                velSoftener = 0;
                gravIncreaser = 1;
                [self playSound:@"SWOOSH.WAV" shouldLoop:false];
                player.acceleration = CGPointZero;
                //set velocity
                //player.velocity = ccpMult(swipeVector, .55);
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
                
                float newAng = 0;
                CGPoint vel = CGPointZero;
                if (ccpLength(ccpSub(ccpAdd(player.sprite.position, swipeVector), left)) <= ccpLength(ccpSub(ccpAdd(player.sprite.position, swipeVector), right))) { //closer to the left
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
                
                // CCLOG(@"cur: %f", swipeAccuracy);
                
                
                //HERE: TO USE!!!!!: if swipe accuracy is greater than a certain amount, t did a poor swipe and should q punished severely!!!!!
                
                //if (swipeAccuracy <= requiredAngleAccuracy) {
                //orbitState = 2;
                //player.velocity = ccpMult(ccpNormalize(vel), ccpLength(player.velocity));
                //} else {
                orbitState = 3;
                initialAccelMag = 0;
                //player.velocity = ccpAdd(player.velocity, ccpMult(swipeVector, swipeStrength));
                //}
                
                //player.velocity = ccpMult(ccpNormalize(vel), ccpLength(player.velocity));
                //end if in position
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
                        //CCLOG(@"Added to DangerLevel: %f", dangerLevel);
                    }
                }
                
                /*
                 if (ccpLength(ccpSub(player.sprite.position, planet.sprite.position)) > ccpLength(ccpSub(planet.sprite.position, targetPlanet.sprite.position)))
                 if (ccpLength(ccpSub(ccpAdd(player.sprite.position, player.velocity), targetPlanet.sprite.position)) < ccpLength(ccpSub(planet.sprite.position, targetPlanet.sprite.position)))
                 CCLOG(@"DIFFERNCE Q: %f", ccpLength(ccpSub(player.sprite.position, planet.sprite.position)) - ccpLength(ccpSub(planet.sprite.position, targetPlanet.sprite.position)));
                 */
                
                //dangerLevel += .01;
                //CCLOG(@"danger level: %f", dangerLevel);
                
                //CGPoint direction = ccpNormalize(ccpSub(planet.sprite.position, player.sprite.position));
                //CGPoint accelToAdd = ccpMult(direction, gravity/**planet.sprite.scale*/);
                CGPoint accelToAdd = CGPointZero;
                CGPoint direction = ccpNormalize(ccpSub(spotGoingTo, player.sprite.position));
                accelToAdd = ccpAdd(accelToAdd, ccpMult(direction, gravity/**targetPlanet.sprite.scale*/));
                
                //use 'dif' in method above but rename to 'accuracy' or something
                
                //B = G + (G(90-x)*factorToScaleGravityForPerfectSwipe)/90
                //B = G * clampf((G(angleToStartCreatingGravity-x)*factorToScaleGravityForPerfectSwipe)/angleToStartCreatingGravity, 0, factorToScaleGravityForPerfectSwipe)
                
                
                player.velocity = ccpMult(ccpNormalize(player.velocity), ccpLength(initialVel));
                
                float scaler = multiplyGravityThisManyTimesOnPerfectSwipe - swipeAccuracy * multiplyGravityThisManyTimesOnPerfectSwipe / 180;
                scaler = clampf(scaler, 0, 99999999);
                
                //CCLOG(@"swipeAcc: %f, scaler: %f", swipeAccuracy, scaler);
                
                //perhaps dont use scaler/swipe accuracy, and just use it in (if orbitstate==1) for determining if it's good enough. btw scaler ranges from about 1to 3.5 (now 0 to 2.5)
                
                player.acceleration = ccpMult(accelToAdd, gravIncreaser*freeGravityStrength*scaler*asteroidSlower);
                //  CCLOG(@"swipeAcc: %f", ccpLength(player.acceleration));
                
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
    
    float moveDuration = respawnMoveTime;
    CGPoint curPlanetPos = lastPlanetVisited.sprite.position;
    CGPoint nextPlanetPos = [[[planets objectAtIndex:(lastPlanetVisited.number+1)] sprite] position];
    CGPoint pToGoTo = ccpAdd(curPlanetPos, ccpMult(ccpNormalize(ccpSub(nextPlanetPos, curPlanetPos)), lastPlanetVisited.orbitRadius));
    id moveAction = [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:moveDuration position:pToGoTo]];
    id delay = [ CCDelayTime actionWithDuration:delayTimeAfterPlayerExplodes];
    
    id movingSpawnActions = [CCSpawn actions:moveAction,[CCBlink actionWithDuration:moveDuration-.05f blinks:moveDuration*respawnBlinkFrequency], [CCRotateTo actionWithDuration:moveDuration-.1f angle:player.rotationAtLastThrust+180], nil];
    player.moveAction = [CCSequence actions:[CCHide action],delay,movingSpawnActions, [CCShow action], nil];
    
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
        [streak runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.8f],[CCShow action], nil]];
        [thrustParticle resetSystem];
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
    
    //this is where the player is on screen (240,160 is center of screen)
    [player setVelocity:ccp(0,0)];
    justReachedNewPlanet = true;
    
    [thrustParticle setPositionType:kCCPositionTypeRelative];
    [cameraLayer addChild:thrustParticle z:2];
    [cameraLayer addChild:streak z:1];
    [spriteSheet addChild:player.sprite z:3];
}

- (CGPoint)GetPositionForJumpingPlayerToPlanet:(int)planetIndex {
    //CCLOG([NSString stringWithFormat:@"thrust mag:"]);
    CGPoint dir = ccpNormalize(ccpSub(((Planet*)[planets objectAtIndex:planetIndex+1]).sprite.position,((Planet*)[planets objectAtIndex:planetIndex]).sprite.position));
    return ccpAdd(((Planet*)[planets objectAtIndex:planetIndex]).sprite.position, ccpMult(dir, ((Planet*)[planets objectAtIndex:planetIndex]).orbitRadius));
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
            planetsHitSinceNewGalaxy=0;
            currentGalaxy = nextGalaxy;
            nextGalaxy = [galaxies objectAtIndex:currentGalaxy.number+1];
            indicatorPos = ccpAdd(indicatorPos, ccpMult(ccpForAngle(CC_DEGREES_TO_RADIANS(directionPlanetSegmentsGoIn)), 1000));
            [self CreateSegment];
        }
        //CCLOG(@"Planet Count: %d",[planets count]);
    }
}

/* Your score goes up as you move along the vector between the current and next planet. Your score will also never go down, as the user doesn't like to see his score go down.*/
- (void)UpdateScore {
    tempScore = ccpDistance(CGPointZero, player.sprite.position);
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

- (void) Update:(ccTime)dt {
    if (!isTutPaused) {
        if (!paused&&isGameOver==false) {
            if (zonesReached<[planets count]) {
                totalGameTime+=dt;
                totalSecondsAlive+=dt;
            }
            
            if (player.alive)
                [self UpdatePlanets];
            [self UpdatePlayer: dt];
            [self UpdateScore];
            [self UpdateCamera:dt];
            [self UpdateParticles:dt];
            if (levelNumber==0)
            [self UpdateLight];
            updatesSinceLastPlanet++;
        }
    }
    if (isInTutorialMode)
        [self UpdateTutorial];
    if (!paused&&[((AppDelegate*)[[UIApplication sharedApplication]delegate])getWasJustBackgrounded])
    {
        [((AppDelegate*)[[UIApplication sharedApplication]delegate])setWasJustBackgrounded:false];
        [self togglePause];
    }
    asteroidGlow.position = player.sprite.position;
    if (!player.alive)
        [asteroidGlow setVisible:false];
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
    
    hand.scale = .5;
    tutorialPauseTimer++;
    int tutorialCounter = 0;
    tutorialFader+= 4;
    tutorialFader = clampf(tutorialFader, 0, 255);
    [tutorialLabel1 setOpacity:255];
    [tutorialLabel2 setOpacity:255];
    [tutorialLabel3 setOpacity:255];
    
    
    [tutorialLabel0 setOpacity:clampf(((sinf(totalGameTime*5)+1)/2)*300, 0, 255)];
    
    //CCLOG(@"countuh: %d", tutorialState);
    
    float scale = .4;
    
    if (tutorialState == tutorialCounter++) { //good angle
        updatesToAdvanceTutorial = 0;//300;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Swipe to fly to the next planet."]];
        
        [self updateHandFrom:ccp(100, 40) to:ccp(380, 40) fadeInUpdates:20 moveUpdates:50 fadeOutUpdates:20 goneUpdates:20];
        
        
        
        float ang = CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity));
        
        
        if (ang > 0 && ang < 10) {
            [self AdvanceTutorial];
        }
        
        
        CGPoint cameraLastFocusPosition2 = ccp(611, 400);
        [self scaleLayer:cameraLayer scaleToZoomTo:scale scaleCenter:cameraLastFocusPosition2];
        id followAction = [CCFollow actionWithTarget:cameraFocusNode];
        [cameraLayer runAction: followAction];
        
        
        
    } else if (tutorialState == tutorialCounter++) {
        [self updateHandFrom:ccp(100, 40) to:ccp(380, 40) fadeInUpdates:20 moveUpdates:50 fadeOutUpdates:20 goneUpdates:20];
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Swipe to fly to the next planet."]];
        
        swipeVector = ccp(0, -1);
        
        lastPlanetVisited = [planets objectAtIndex:0];
        [self JustSwiped];
        [self AdvanceTutorial];
        
    } else if (tutorialState == tutorialCounter++) { //hit the next zone
        [self updateHandFrom:ccp(100, 40) to:ccp(380, 40) fadeInUpdates:20 moveUpdates:50 fadeOutUpdates:20 goneUpdates:20];
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Swipe to fly to the next planet."]];
        if (orbitState == 0) {
            lastPlanetVisited = [planets objectAtIndex:0];
            //            player.sprite.position = ccp(400, 364);
            [self RespawnPlayerAtPlanetIndex:0];
            tutorialState-=2;
        }
        
    } else if (tutorialState == tutorialCounter++) { //good angle
        updatesToAdvanceTutorial = 300;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"test"]];
        
        [self updateHandFrom:ccp(100, 40) to:ccp(380, 40) fadeInUpdates:20 moveUpdates:50 fadeOutUpdates:20 goneUpdates:20];
        
        
        
        float ang = CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity));
        
        
        if (ang > 0 && ang < 10) {
            [self AdvanceTutorial];
        }
        
        CGPoint cameraLastFocusPosition2 = ccp(611+2000, 400);
        [self scaleLayer:cameraLayer scaleToZoomTo:scale scaleCenter:cameraLastFocusPosition2];
        id followAction = [CCFollow actionWithTarget:cameraFocusNode];
        [cameraLayer runAction: followAction];
    } else if (tutorialState == tutorialCounter++) {
        [self updateHandFrom:ccp(100, 40) to:ccp(380, 40) fadeInUpdates:20 moveUpdates:50 fadeOutUpdates:20 goneUpdates:20];
        [tutorialLabel1 setString:[NSString stringWithFormat:@"test."]];
        
        swipeVector = ccp(0, 1);
        
        lastPlanetVisited = [planets objectAtIndex:2];
        [self JustSwiped];
        [self AdvanceTutorial];
    } else if (tutorialState == tutorialCounter++) { //hit the next zone
        [self updateHandFrom:ccp(100, 40) to:ccp(380, 40) fadeInUpdates:20 moveUpdates:50 fadeOutUpdates:20 goneUpdates:20];
        [tutorialLabel1 setString:[NSString stringWithFormat:@"test."]];
        if (orbitState == 0) {
            lastPlanetVisited = [planets objectAtIndex:2];
            //            player.sprite.position = ccp(400, 364);
            [self RespawnPlayerAtPlanetIndex:2];
            tutorialState-=2;
        }
        
        float hi = 5;
        hi++;
        
        
    } else if (tutorialState == tutorialCounter++) { //tap
        updatesToAdvanceTutorial = 100;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Tap to see when a good time"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"to swipe is."]];
        
        
        
        
        CGPoint cameraLastFocusPosition2 = ccp(611+4000, 400);
        [self scaleLayer:cameraLayer scaleToZoomTo:scale scaleCenter:cameraLastFocusPosition2];
        id followAction = [CCFollow actionWithTarget:cameraFocusNode];
        [cameraLayer runAction: followAction];
        
        
        
        
        
    } else if (tutorialState == tutorialCounter++) { //tap
        updatesToAdvanceTutorial = 120;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Now you're ready to play!"]];
        
    } else if (tutorialState == tutorialCounter++) { //end the game
        if ([[PlayerStats sharedInstance] getPlays]>1)
        {
            [[PlayerStats sharedInstance] addPlay];
            [self endGame];
        }
        else
            [self restartGame];
        tutorialState++;
        
    }
    
    if (tutorialPauseTimer < updatesToAdvanceTutorial)
        [tutorialLabel0 setString:[NSString stringWithFormat:@" "]];
    else
        [tutorialLabel0 setString:[NSString stringWithFormat:@"Tap to continue...                                    Tap to continue..."]];
}

- (void)updateHandFrom:(CGPoint)pos1 to:(CGPoint)pos2 fadeInUpdates:(int)fadeInUpdates moveUpdates:(int)moveUpdates fadeOutUpdates:(int)fadeOutUpdates goneUpdates:(int)goneUpdates {
    
    
    
    if (handCounter == 0)
        hand.position = pos1;
    else if (handCounter <= fadeInUpdates) {
        hand.opacity += 255/fadeInUpdates;
    }
    else if (handCounter <= fadeInUpdates + moveUpdates) {
        CGPoint vec = ccpSub(pos2, pos1);
        hand.position = ccpAdd(pos1, ccpMult(vec, (handCounter-fadeInUpdates)/moveUpdates));
    } else if (handCounter <= fadeInUpdates + moveUpdates + fadeOutUpdates) {
        if (hand.opacity < 20)
            hand.opacity = 0;
        else
            hand.opacity -= 255/fadeOutUpdates;
        
    }
    else if (handCounter > fadeInUpdates + moveUpdates + fadeOutUpdates + goneUpdates) {
        handCounter = -1;
        hand.opacity = 0;
    }
    
    if (hand.position.x == pos2.x&&handCounter > fadeInUpdates + moveUpdates + fadeOutUpdates)
        hand.opacity = 0 ; 
    
    
    //CCLOG(@"opac: %f", (float)hand.opacity);
    
    // hand.opacity = 100;
    
    handCounter++;
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
        } else if (tutorialAdvanceMode == 2) {
            tutorialPlanetIndex = lastPlanetVisited.number;
            [self JustSwiped];
            [self AdvanceTutorial];
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

- (void)AdvanceTutorial {
    //    if (tutorialPauseTimer >= updatesToAdvanceTutorial) {
    shouldDisplayWaiting = false;
    tutorialFader = 0;
    tutorialState++;
    //    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {    
    playerIsTouchingScreen = false;
    
    if (isInTutorialMode) {
        if (tutorialPauseTimer >= updatesToAdvanceTutorial) {
            //[self AdvanceTutorial];            
            tutorialPauseTimer = 0;
            
            if (tutorialState == 0 || tutorialState == 1 || tutorialState == 2) {
                lastPlanetVisited = [planets objectAtIndex:2];
                //            player.sprite.position = ccp(400, 364);
                [self RespawnPlayerAtPlanetIndex:2];
                tutorialState = 3;
            } else if (tutorialState == 3 || tutorialState == 4 || tutorialState == 5) {
                tutorialState = 6;
            }
        }
        
    }
    
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
