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
#import "Powerups.h"

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

- (void)CreateSegment
{
    segmentsSpawnedFlurry++;
    float rotationOfSegment = CC_DEGREES_TO_RADIANS([self RandomBetween:-segmentRotationVariation+directionPlanetSegmentsGoIn maxvalue:segmentRotationVariation+directionPlanetSegmentsGoIn]);
    originalSegmentNumber = [self RandomBetween:0 maxvalue:[segments count]-1];
    NSArray *chosenSegment = [segments objectAtIndex:originalSegmentNumber];
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
}

- (void)CreateLevel // paste level creation code here
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
    
    segments = [[NSArray alloc ]initWithObjects:
                [NSArray arrayWithObjects: [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(188,219) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(151,289) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1260,34) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1162,11) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1563,-163) scale:1.45052],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1792,72) scale:1.33552],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(137,136) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(225,107) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(322,75) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(690,209) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(766,162) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(857,110) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(761,-81) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(687,-39) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(585,26) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(474,210) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(961,-70) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1447,112) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1986,-249) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(2498,139) scale:1],
                 nil],
                
                
                [NSArray arrayWithObjects:[[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(500,0) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1000,0) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1200,300) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1500,0) scale:1],
                 nil],// Craig's 1-SpeedOne
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
                // Craig's 2-HappyTrail
                [NSArray arrayWithObjects: [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1440,-228) scale:1.12852],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1494,-311) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(837,-282) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1116,108) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1184,22) scale:1.42752],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(334,-132) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(345,97) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(294,-39) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(339,-40) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(340,14) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(296,14) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(388,-41) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(388,11) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(668,-158) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(729,-161) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(789,-161) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(858,-158) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(609,-130) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(565,-83) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(933,-156) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1002,-157) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1064,-162) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1127,-166) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1190,-181) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1243,-204) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1291,-247) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1318,-305) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1351,-358) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1409,-412) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1470,-441) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1536,-449) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1595,-444) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1660,-426) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1711,-393) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1756,-347) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1780,-298) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1810,-252) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1850,-219) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1939,132) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1985,133) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1965,179) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(343,163) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(330,-200) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(708,4) scale:1.18],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1180,-342) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1724,-98) scale:1.27],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(2168,356) scale:1],
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
                
                // Craig's 4-Basic1
                [NSArray arrayWithObjects: [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(187,-130) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(250,-53) scale:1.15152],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(852,34) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(698,-172) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1201,-22) scale:0.99052],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1366,-455) scale:1.84152],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1996,-173) scale:0.48384],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1979,-107) scale:1.24352],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1670,247) scale:1.24352],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(489,442) scale:0.92152],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1929,325) scale:0.50752],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(83,-164) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(128,-205) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(186,-214) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(240,-207) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(309,-186) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(748,-114) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(786,-65) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(819,-21) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(979,-346) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1033,-355) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1083,-343) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1423,-96) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1467,-47) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1520,-13) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1581,7) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1651,9) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1714,-11) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1144,-312) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1201,-275) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1257,-240) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1311,-200) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1363,-153) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(557,149) scale:1.39],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1032,-212) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1621,-218) scale:1.599999],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(2083,160) scale:1],
                 nil],
                // Craig's 4-CancelCoinSign
                [NSArray arrayWithObjects: [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(91,-217) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(190,-221) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(316,-223) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(100,210) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(242,211) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(373,212) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(800,-375) scale:0.80652],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(865,-342) scale:0.80652],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(931,-309) scale:0.82952],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1959,-1121) scale:1.49652],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2106,-1127) scale:1.49652],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2257,-1136) scale:1.45052],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1725,-1423) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1932,-1432) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2148,-1435) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2398,-1430) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1770,-824) scale:1.24352],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1956,-832) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2141,-855) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2338,-881) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(3134,-1074) scale:1.15152],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2731,-732) scale:1.19752],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(240,-29) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(241,29) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(297,32) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(292,-29) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(335,60) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(372,102) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(416,139) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(332,-54) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(372,-88) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(417,-119) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(339,-1) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(384,44) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(386,-36) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(991,-282) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(961,-249) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1002,-326) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(740,-366) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(746,-417) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(781,-437) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1006,-239) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1035,-290) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(711,-398) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(743,-463) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(705,-445) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1048,-246) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1091,-765) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1183,-881) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1287,-995) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1391,-1115) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1313,-616) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1411,-690) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1506,-780) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1615,-870) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1326,-856) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1372,-830) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1373,-893) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1413,-863) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1413,-935) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1448,-897) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1745,-1303) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2066,-1300) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2214,-1301) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2259,-1300) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2303,-1296) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2404,-1291) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2454,-1287) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2502,-1277) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1699,-1303) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1717,-937) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2495,-982) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2442,-982) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2389,-982) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2296,-978) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2250,-973) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2207,-965) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2124,-953) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1924,-940) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1881,-940) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1801,-940) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1761,-939) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2084,-947) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2046,-942) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1964,-941) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1658,-1306) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1854,-1303) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1897,-1306) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1937,-1308) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2104,-1302) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2029,-1302) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(206,0) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2904,-795) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2858,-815) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2835,-859) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2854,-915) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2903,-937) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2952,-932) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2986,-894) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2983,-841) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2948,-808) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2893,-859) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2934,-885) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2785,-1132) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2830,-1134) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2811,-1091) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3010,-685) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3053,-685) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3031,-640) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(602,7) scale:1.45],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1167,-639) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1678,-1116) scale:1.3],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(2520,-1125) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(3276,-673) scale:1],
                 nil],
                
                // Craig's 5-TripletCoins
                [NSArray arrayWithObjects: [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(-15,227) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(270,-41) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(270,48) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(84,229) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1091,595) scale:1.38152],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(942,527) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1101,215) scale:1.24352],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(942,263) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1515,197) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1579,126) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1647,54) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1713,-27) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1775,-94) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2244,-134) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2485,-428) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(173,136) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(214,170) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(251,200) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(194,-116) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(252,-117) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(313,-112) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(-140,192) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(-108,243) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(-69,278) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(-14,295) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(372,-82) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(908,455) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(905,403) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(905,350) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(965,455) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(965,400) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(965,347) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1454,-42) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1509,-38) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1481,9) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1701,157) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1742,104) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1756,160) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2628,-351) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2697,-352) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2760,-331) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2256,-389) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2336,-371) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2481,-345) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2411,-359) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2340,-268) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2405,-285) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2458,-299) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2512,-313) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2558,-340) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2189,-402) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2124,-415) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2064,-428) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2008,-439) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2067,-152) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2131,-182) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2183,-205) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2241,-229) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2290,-250) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(531,396) scale:1.42],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1383,401) scale:1.24],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1944,-277) scale:1.15],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(2673,-207) scale:1],
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
                
                
                nil];
    
    indicatorPos = CGPointZero;
    for (int j = 0 ; j < numberOfSegmentsAtATime; j++) {
        [self CreateSegment];
    }
    
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
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444]; // add this line at the very beginning
        background = [CCSprite spriteWithFile:@"background.pvr.ccz"];
        background.position = ccp(size.width/2+61,14);
        background.scale *=1.28f;
      //  [background setAnchorPoint:CGPointZero];
       // [background setPosition:CGPointZero];
      //  [background setPosition:ccp(size.width/2,size.height/2)];
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
            //[self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number];
            isHittingAsteroid = true;
        }
    }
    
    if (![[Powerups sharedInstance] hasAsteroidImmunity]) {
        if (isHittingAsteroid)
            asteroidSlower -= .09;
        else
            asteroidSlower += .01;
        asteroidSlower = clampf(asteroidSlower, .15, 1);
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
        [self CreateSegment];
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

- (bool)IsNonConvertedPositionOnScreen:(CGPoint)position{
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
    for (int i = 0 ; i < [segments count]; i++){
        NSArray *chosenSegment = [segments objectAtIndex:i];
        for (int j = 0 ; j < [chosenSegment count];j++) {
            [[chosenSegment objectAtIndex:j] release];
        }
    }
    [super dealloc];
}



#if !defined(MIN)
#define MIN(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __a : __b; })
#endif

#if !defined(MAX)
#define MAX(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __b : __a; })
#endif

@end
