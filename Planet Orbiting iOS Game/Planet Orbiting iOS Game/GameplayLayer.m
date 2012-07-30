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
    [coin release];
}

- (void)CreateAsteroid:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale {
    Asteroid *asteroid = [[Asteroid alloc]init];
    asteroid.sprite = [CCSprite spriteWithSpriteFrameName:@"asteroid.png"];
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
    planet.sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"planet%d.png",[self RandomBetween:1 maxvalue:6]]];
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
        [self CreatePlanetAndZone:493 yPos:394 scale:1];
        [self CreatePlanetAndZone:1059 yPos:685 scale:1];
        [self CreatePlanetAndZone:1666 yPos:670 scale:1];
        [self CreatePlanetAndZone:2042 yPos:1008 scale:1];
        [self CreatePlanetAndZone:2640 yPos:663 scale:1.629999];
        [self CreatePlanetAndZone:3460 yPos:355 scale:1];
        [self CreatePlanetAndZone:3718 yPos:927 scale:1];
        [self CreatePlanetAndZone:4271 yPos:953 scale:1];
        [self CreatePlanetAndZone:5299 yPos:948 scale:1];
        [self CreatePlanetAndZone:5999 yPos:948 scale:1];
        [self CreatePlanetAndZone:6799 yPos:948 scale:1];
        [self CreatePlanetAndZone:7599 yPos:948 scale:1];
        [self CreatePlanetAndZone:8399 yPos:948 scale:2];
        [self CreatePlanetAndZone:8999 yPos:948 scale:1];
        [self CreatePlanetAndZone:9599 yPos:948 scale:1];
        [self CreatePlanetAndZone:10399 yPos:948 scale:1];
        [self CreatePlanetAndZone:11399 yPos:948 scale:1];
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
                
                [NSArray arrayWithObjects: [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(712,158) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(658,17) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(678,90) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(345,210) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(425,294) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(518,361) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1393,59) scale:1.26652],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(144,-119) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(197,-118) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(249,-117) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(305,-118) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(283,-54) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(233,-55) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(177,-58) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(178,-6) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(231,-2) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(279,-1) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(277,53) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(227,51) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(171,50) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(148,106) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(205,106) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(259,107) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(314,108) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(651,322) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(664,375) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(700,429) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(748,461) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(812,467) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(888,447) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(936,401) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(961,334) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(978,252) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(993,190) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1017,99) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1038,40) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1078,-5) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1133,-22) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1191,-31) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1247,-19) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(460,9) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(810,309) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1176,137) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1609,-83) scale:1],
                 nil],
                
                [NSArray arrayWithObjects:[[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(500,0) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1000,0) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1200,300) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1500,0) scale:1],
                 nil],
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
                [NSArray arrayWithObjects: [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1492,-190) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1454,-75) scale:1.61152],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1247,-315) scale:1.91052],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1183,-199) scale:0.99052],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1290,-43) scale:1.10552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1416,-351) scale:1.19752],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(745,-399) scale:1.38152],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2217,-327) scale:1.63452],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(23,-217) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(95,-179) scale:0.66852],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(157,-135) scale:0.69152],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(231,-81) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(266,20) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(325,3) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(354,-50) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(-96,-182) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(-93,-237) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(-53,-288) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(667,-180) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(665,-238) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(616,-180) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(720,-183) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(669,-122) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1211,-109) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1261,-138) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1270,-201) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1300,-154) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1326,-112) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1368,-139) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1342,-187) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1317,-231) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1360,-254) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1388,-208) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1417,-161) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1440,-242) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2184,-436) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2232,-435) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2189,-223) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2238,-225) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(289,-335) scale:1.27],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1004,-22) scale:1.03],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1792,-328) scale:1.51],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(2660,-323) scale:1.39],
                 nil],
                [NSArray arrayWithObjects: [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(283,2) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(284,-62) scale:0.78352],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(283,64) scale:0.78352],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(864,35) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(796,190) scale:1.45052],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2287,76) scale:1.12852],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2283,157) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2257,222) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2386,606) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2533,588) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2682,546) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2230,-145) scale:1.17452],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2264,-73) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2287,-3) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2055,593) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(2231,613) scale:0.87552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1333,-9) scale:1.08252],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(3314,309) scale:1.10552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(3311,174) scale:1.17452],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(3305,-3) scale:1.10552],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(3305,-137) scale:1.03652],
                 [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(607,275) scale:0.78352],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(136,-146) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(225,-148) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(324,-148) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(430,-152) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(136,149) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(230,149) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(312,149) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(397,148) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(684,240) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(853,100) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1380,214) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1423,183) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1424,235) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1514,194) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1508,244) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1549,223) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(483,240) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(504,300) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(532,343) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(564,383) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(607,420) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(906,-73) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(955,-49) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(852,-96) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(996,-11) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1042,36) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1085,78) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1123,121) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1156,164) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1188,206) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1213,251) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(650,449) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(696,479) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(740,505) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(786,527) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(831,544) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3308,87) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3282,244) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3340,243) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3270,-72) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3333,-72) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1783,-166) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1861,-249) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1826,-211) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2197,399) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2249,396) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2303,388) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2350,381) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2395,371) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2433,367) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2485,355) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2528,347) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2576,333) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2622,319) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2672,304) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2714,289) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2766,267) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2811,249) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2855,232) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2154,398) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2111,396) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2064,393) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2016,387) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1968,379) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1921,369) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1881,352) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1841,323) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1807,288) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1775,252) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3664,305) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3701,260) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2078,-347) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2129,-357) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2178,-358) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2221,-358) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2270,-354) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2320,-348) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2037,-340) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1997,-329) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1951,-311) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1908,-286) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2450,-338) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2364,-347) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2408,-342) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2839,-79) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2804,-110) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2766,-139) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2731,-167) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2694,-194) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2651,-223) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2616,-249) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2583,-279) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2540,-303) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2496,-323) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3071,-303) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3122,-307) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3177,-312) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3230,-313) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3281,-313) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3333,-310) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3383,-309) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3436,-300) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3485,-288) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3026,-290) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2974,-266) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2924,-230) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2889,-191) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3211,399) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3253,403) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3295,404) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3349,404) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3394,400) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3445,394) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3485,384) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3541,371) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3590,352) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3626,331) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3167,394) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3120,386) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3074,366) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3035,344) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2993,318) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2951,291) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(2912,264) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3532,-261) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3567,-227) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(3604,-199) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(567,9) scale:1.09],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1083,439) scale:1.33],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1884,95) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(2921,69) scale:1],
                 [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(3698,59) scale:1],
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
            tutorialAdvanceMode = 1;
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
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"a_song.mp3" loop:YES];
        float tester99 = [[SimpleAudioEngine sharedEngine] backgroundMusicVolume];
        CCLOG(@"volume is %f", tester99);
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"bomb.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"SWOOSH.wav"];
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
        handCounter2 = 0;
        updatesSinceLastPlanet = 0;
        tutorialPauseTimer = 0;
        updatesToAdvanceTutorial = 0;
        tutorialIsTryingToAdvance = false;
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444]; // add this line at the very beginning
        background = [CCSprite spriteWithFile:@"background.pvr.ccz"];
        background.position = ccp(size.width/2+31,19);
        background.scale *=1.3f;
        [self addChild:background];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888]; // add this line at the very beginning
        
        [self addChild:cometParticle];
        cometParticle.position = ccp([self RandomBetween:0 maxvalue:390],325);
        cometVelocity = ccp([self RandomBetween:-10 maxvalue:10]/5,-[self RandomBetween:1 maxvalue:23]/5);
        [self resetVariablesForNewGame];
        
        hand = [CCSprite spriteWithFile:@"edit(84759).png"];
        hand.position = ccp(-1000, -1000);
        hand2 = [CCSprite spriteWithFile:@"edit(84759).png"];
        hand2.position = ccp(-1000, -1000);
        
        
        light = [[Light alloc] init];
        light.score = -negativeLightStartingScore;
        light.scoreVelocity = initialLightScoreVelocity;
        glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        light.hasPutOnLight = false;

        
        [cameraLayer addChild:spriteSheet];
        [hudLayer addChild:hand];
        [hudLayer addChild:hand2];
        
        cameraDistToUse = 1005.14;
        [cameraLayer setScale:.43608];
        [cameraLayer setPosition:ccp(98.4779,67.6401)];
        cameraLastFocusPosition = ccp(325.808,213.3);
        [cameraFocusNode setPosition:ccp(142.078,93.0159)];
        
        lastPlanetVisited = [planets objectAtIndex:0];
        [self addChild:cameraLayer];
        [self addChild:hudLayer];
        [self addChild:pauseMenu];
        [self UpdateScore];

        [Flurry logEvent:@"Played Game" withParameters:nil timed:YES];
        [self schedule:@selector(Update:) interval:0]; // this makes the update loop loop!!!!        
	}
	return self;
}

- (void)UpdateCamera:(float)dt {
    if (player.alive) {
        player.velocity = ccpAdd(player.velocity, player.acceleration);
        player.sprite.position = ccpAdd(ccpMult(player.velocity, 60*dt*timeDilationCoefficient), player.sprite.position);
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
    planet1 = [planets objectAtIndex:lastPlanetVisited.number+2];    
    planet2 = [planets objectAtIndex:lastPlanetVisited.number+3];
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
        NSLog(@"cameraLayer scale should be bigger this this, we prob has an error");
        [cameraLayer setScale:.1];
    }
    
    float scale = zoomMultiplier*horizontalScale*scalerToUse;
    cameraLastFocusPosition = ccpLerp(cameraLastFocusPosition, focusPosition, cameraMovementSpeed);
    [self scaleLayer:cameraLayer scaleToZoomTo:lerpf([cameraLayer scale], scale, cameraZoomSpeed) scaleCenter:cameraLastFocusPosition];
    id followAction = [CCFollow actionWithTarget:cameraFocusNode];
    [cameraLayer runAction: followAction];
    
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
    coin.sprite.visible = false;
    coin.isAlive = false;
    [[SimpleAudioEngine sharedEngine]playEffect:@"buttonpress.mp3"];
}

- (void)ApplyGravity:(float)dt {
    
    //
    //[[PowerupManager sharedInstance] numMagnet]; //get how many there are
    //[[PowerupManager sharedInstance] subtractMagnet]; //numImmunity
    
    
    for (Coin* coin in coins) {
        CGPoint p = coin.sprite.position;
        if (ccpLength(ccpSub(player.sprite.position, p)) <= coin.radius + player.sprite.height/1.3 && coin.isAlive) {
            [self UserTouchedCoin:coin];
        }
    }
    
    for (Asteroid* asteroid in asteroids) {        
        CGPoint p = asteroid.sprite.position;
        if (player.alive && ccpLength(ccpSub(player.sprite.position, p)) <= asteroid.radius * asteroidRadiusCollisionZone && orbitState == 3) {
            [self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number];
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
                //if in position
                //justSwiped = false;
                [[SimpleAudioEngine sharedEngine]playEffect:@"SWOOSH.WAV"];
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
                
                player.acceleration = ccpMult(accelToAdd, gravIncreaser*freeGravityStrength*scaler);
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
                
                /*  if (zonesReached>=[zones count]) {
                 [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationPortrait];
                 [TestFlight passCheckpoint:@"Reached All Zones"];
                 [Flurry endTimedEvent:@"Played Game" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:score],@"Score", nil]];
                 }*/
            }
        }
    } // end collision detection code-----------------
    
    if (lastPlanetVisited.segmentNumber == numberOfSegmentsAtATime-1&&isInTutorialMode==false) {
        CCLOG(@"Planet Count: %d",[planets count]);
        
        [self DisposeAllContentsOfArray:planets shouldRemoveFromArray:true];
        [self DisposeAllContentsOfArray:zones shouldRemoveFromArray:true];
        [self DisposeAllContentsOfArray:asteroids shouldRemoveFromArray:true];
        [self DisposeAllContentsOfArray:coins shouldRemoveFromArray:true];
        
        makingSegmentNumber--;
        [self CreateSegment];
        
        CCLOG(@"Planet Count: %d",[planets count]);
    }
}

/* Your score goes up as you move along the vector between the current and next planet. Your score will also never go down, as the user doesn't like to see his score go down.*/
- (void)UpdateScore {
    /*Planet * nextPlanet;
    if (lastPlanetVisited.number +1 < [planets count])
        nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number+1)];
    else     nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number-1)];
    
    float firstToPlayerAngle = ccpAngle(lastPlanetVisited.sprite.position, player.sprite.position)-ccpAngle(lastPlanetVisited.sprite.position, nextPlanet.sprite.position);
    float firstToPlayerDistance = ccpDistance(lastPlanetVisited.sprite.position, player.sprite.position);    
    
    prevCurrentPtoPScore = currentPtoPscore;
    int newScore = ((int)((float)firstToPlayerDistance*cosf(firstToPlayerAngle)));
    if (newScore > prevCurrentPtoPScore)
        currentPtoPscore = newScore;
    [scoreLabel setString:[NSString stringWithFormat:@"Score: %d",score+currentPtoPscore]];*/
    
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
        pauseLayer = (CCLayer*)[CCBReader nodeGraphFromFile:@"GameOverLayer.ccb" owner:self];
        [pauseLayer setTag:gameOverLayerTag];
        [self addChild:pauseLayer];
            int finalScore = score + prevCurrentPtoPScore;
        [[PlayerStats sharedInstance] addScore:finalScore];
        scoreAlreadySaved = YES;
        [DataStorage storeData];
    }
}

- (void)UpdateLight {
    light.distanceFromPlayer = score - light.score;
    
    if (light.distanceFromPlayer > negativeLightStartingScore)
        light.score = score-negativeLightStartingScore;
    
    
    light.scoreVelocity += amountToIncreaseLightScoreVelocityEachUpdate;
    
    CCLOG(@"DIST: %f, VEL: %f, LIGHSCORE: %f", light.distanceFromPlayer, light.scoreVelocity, light.score);
    
    /*if (distance <= 100) {
     [light.sprite setTextureRect:CGRectMake(0, 0, 0, 0)];        
     [self GameOver];
     } else*/ if (light.distanceFromPlayer <= 1000) {
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
     } else if (light.distanceFromPlayer <= 3000) {
         [background setOpacity:clampf(((light.distanceFromPlayer)/2500)*255, 0, 255)];
     }
    
    if (light.hasPutOnLight) {
        light.sprite.position = ccp(light.sprite.position.x+480/10, light.sprite.position.y);
        [light.sprite setOpacity:clampf((light.sprite.position.x+240)*255/480, 0, 255)];
    }
    if (light.sprite.position.x > 240) {
        //[light.sprite setTextureRect:CGRectMake(0, 0, 0, 0)];        
        [self GameOver];
    }
    
    
    
    //[light.sprite setTextureRect:CGRectMake(0, 0, 480, 320)];
    
    //if (distance <= maxDistance ) {
    //float percentOfMax = distance / maxDistance;
    //GLubyte red   = lerpf(0, 255, percentOfMax);
    //GLubyte green = lerpf(88, 255, percentOfMax);
    //[background setColor:ccc3(red, green, 255)];
    //[background setColor:ccBLUE];
    //}
    //else [background setColor:ccWHITE];
    // [background setTextureRect:<#(CGRect)#>];
    
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
            [self UpdateLight];
            updatesSinceLastPlanet++;
            
        }
    }
    if (isInTutorialMode)
        [self UpdateTutorial];
}

- (void)endGame {
    if (!didEndGameAlready) {
        didEndGameAlready = true;
        int finalScore = score + prevCurrentPtoPScore;
        if (!isInTutorialMode && !scoreAlreadySaved) {
            [[PlayerStats sharedInstance] addScore:finalScore];
        }
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene: [MainMenuLayer scene]]];
    }
}

- (void)UpdateTutorial {
    hand.scale = .5;
    hand2.scale = .5;
    tutorialPauseTimer++;
    int tutorialCounter = 0;
    tutorialFader+= 4;
    tutorialFader = clampf(tutorialFader, 0, 255);
    [tutorialLabel1 setOpacity:tutorialFader];
    [tutorialLabel2 setOpacity:tutorialFader];
    [tutorialLabel3 setOpacity:tutorialFader];
    
    if (tutorialAdvanceMode == 1)
        [tutorialLabel0 setOpacity:clampf(((sinf(totalGameTime*5)+1)/2)*300, 0, 255)];
    else
        [tutorialLabel0 setOpacity:0];

    
    if (tutorialState == tutorialCounter++) { //tap
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Welcome to Star Dash!"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"Tap to begin the tutorial..."]];
        
    } else if (tutorialState == tutorialCounter++) { //tap
        updatesToAdvanceTutorial = 70;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"It's simple - just jump from"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"planet to planet."]];
        
    } else if (tutorialState == tutorialCounter++) { //tap
        updatesToAdvanceTutorial = 20;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Tap to see when a good time"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"to swipe is."]];
        
    } else if (tutorialState == tutorialCounter++) { //good angle
        //[tutorialLabel1 setString:[NSString stringWithFormat:@"Getting into position..."]];
        tutorialAdvanceMode = 0;
        float ang = CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity));
        if (!(ang > -90 && ang < 0)) {
            shouldDisplayWaiting = true;
        }
        if (shouldDisplayWaiting)
            [tutorialLabel1 setString:[NSString stringWithFormat:@"Getting into position..."]];
        
        if (ang > 0 && ang < 10) {
            [self AdvanceTutorial];
        }
        
    } else if (tutorialState == tutorialCounter++) { //swipe
        isTutPaused = true;
        tutorialAdvanceMode = 2;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"About now is when you'd want to"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"swipe. Swipe towards the next"]];
        [tutorialLabel3 setString:[NSString stringWithFormat:@"planet to continue..."]];
        [self updateHandFrom:ccp(230, 20) to:ccp(450, 150) fadeInUpdates:20 moveUpdates:50 fadeOutUpdates:20 goneUpdates:30];
    } else if (tutorialState == tutorialCounter++) { //hit the next zone
        tutorialAdvanceMode = 0;
        if (orbitState == 0) {
            if (lastPlanetVisited.number == tutorialPlanetIndex + 1)
                [self AdvanceTutorial];
            else
                tutorialState--;
        }
        
    } else if (tutorialState == tutorialCounter++) { //tap
        updatesToAdvanceTutorial = 30;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Nice job!"]];
        
        // CCLOG(@"ang: %f", ang);
    } else if (tutorialState == tutorialCounter++) { //good angle
        tutorialAdvanceMode = 0;
        float ang = CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity));
        if (!(ang > -100 && ang < -10)) {
            shouldDisplayWaiting = true;
        }
        if (shouldDisplayWaiting)
            [tutorialLabel1 setString:[NSString stringWithFormat:@"Getting into position..."]];
        if (ang > -10 && ang < 0) {
            [self AdvanceTutorial];
        }
        
    } else if (tutorialState == tutorialCounter++) { //swipe
        isTutPaused = true;
        tutorialAdvanceMode = 2;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Swipe again for more practice."]];
        [self updateHandFrom:ccp(150, 50) to:ccp(350, 50) fadeInUpdates:20 moveUpdates:45 fadeOutUpdates:20 goneUpdates:30];
        
    } else if (tutorialState == tutorialCounter++) { //hit the next zone
        tutorialAdvanceMode = 0;
        if (orbitState == 0) {
            if (lastPlanetVisited.number == tutorialPlanetIndex + 1)
                [self AdvanceTutorial];
            else
                tutorialState--;
        }
        
    } else if (tutorialState == tutorialCounter++) { //tap
        updatesToAdvanceTutorial = 30;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Well done."]];
        
    } else if (tutorialState == tutorialCounter++) { //good angle
        float ang = CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity));
        if (!(ang > -60 && ang < 30)) {
            shouldDisplayWaiting = true;
        }
        if (shouldDisplayWaiting)
            [tutorialLabel1 setString:[NSString stringWithFormat:@"Getting into position..."]];
        if (ang > 30 && ang < 40) {
            [self AdvanceTutorial];
        }
        
    } else if (tutorialState == tutorialCounter++) { //swipe
        isTutPaused = true;
        tutorialAdvanceMode = 2;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"This next planet is a bit higher."]];
        [self updateHandFrom:ccp(250, 50) to:ccp(400, 200) fadeInUpdates:20 moveUpdates:55 fadeOutUpdates:20 goneUpdates:30];
        
    } else if (tutorialState == tutorialCounter++) { //hit the next zone
        if (orbitState == 0) {
            if (lastPlanetVisited.number == tutorialPlanetIndex + 1)
                [self AdvanceTutorial];
            else
                tutorialState--;
        }
        
    } else if (tutorialState == tutorialCounter++) { //tap
        updatesToAdvanceTutorial = 30;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Nice swipe!"]];
        
    } else if (tutorialState == tutorialCounter++) { //swipe
        tutorialAdvanceMode = 2;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Try one on your own now - just"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"swipe when you're ready."]];
        
    } else if (tutorialState == tutorialCounter++) { //hit the next zone
        tutorialAdvanceMode = 0;
        if (orbitState == 0) {
            if (lastPlanetVisited.number == tutorialPlanetIndex + 1)
                [self AdvanceTutorial];
            else
                tutorialState--;
        }
        
    } else if (tutorialState == tutorialCounter++) { //swipe
        tutorialAdvanceMode = 2;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Good one! Try a few more times"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"to get a feel for it."]];
        
    } else if (tutorialState == tutorialCounter++) { //hit the next zone
        tutorialAdvanceMode = 0;
        if (orbitState == 0) {
            if (lastPlanetVisited.number == tutorialPlanetIndex + 1)
                [self AdvanceTutorial];
            else
                tutorialState--;
        }
        
    } else if (tutorialState == tutorialCounter++) { //swipe
        tutorialAdvanceMode = 2;
        
    } else if (tutorialState == tutorialCounter++) { //hit the next zone
        tutorialAdvanceMode = 0;
        if (orbitState == 0) {
            if (lastPlanetVisited.number == tutorialPlanetIndex + 1)
                [self AdvanceTutorial];
            else
                tutorialState--;
        }
        
    } else if (tutorialState == tutorialCounter++) { //swipe
        tutorialAdvanceMode = 2;
        
    } else if (tutorialState == tutorialCounter++) { //hit the next zone
        tutorialAdvanceMode = 0;
        if (orbitState == 0) {
            if (lastPlanetVisited.number == tutorialPlanetIndex + 1)
                [self AdvanceTutorial];
            else
                tutorialState--;
        }
        
    } else if (tutorialState == tutorialCounter++) { //tap
        updatesToAdvanceTutorial = 30;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"You're getting the hang of this!"]];
        
    } else if (tutorialState == tutorialCounter++) { //tap
        updatesToAdvanceTutorial = 180;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"The direction you swipe determines"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"your flight path towards the next"]];
        [tutorialLabel3 setString:[NSString stringWithFormat:@"planet."]];
        
    } else if (tutorialState == tutorialCounter++) { //good angle
        tutorialAdvanceMode = 0;
        float ang = CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity));
        if (!(ang > -90 && ang < 0)) {
            shouldDisplayWaiting = true;
        }
        if (shouldDisplayWaiting)
            [tutorialLabel1 setString:[NSString stringWithFormat:@"Getting into position..."]];
        
        if (ang > 0 && ang < 10) {
            [self AdvanceTutorial];
        }
        
    } else if (tutorialState == tutorialCounter++) { //swipe
        isTutPaused = true;
        tutorialAdvanceMode = 2;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Swipe towards one side or the other"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"of the next planet to determine your"]];
        [tutorialLabel3 setString:[NSString stringWithFormat:@"orbit direction."]];
        [self updateHandFrom:ccp(180, 140) to:ccp(400, 240) fadeInUpdates:20 moveUpdates:70 fadeOutUpdates:20 goneUpdates:30];
        [self updateHand2From:ccp(180, 140) to:ccp(400, 40) fadeInUpdates:20 moveUpdates:70 fadeOutUpdates:20 goneUpdates:30];
        
    } else if (tutorialState == tutorialCounter++) { //hit the next zone
        tutorialAdvanceMode = 0;
        if (orbitState == 0) {
            if (lastPlanetVisited.number == tutorialPlanetIndex + 1)
                [self AdvanceTutorial];
            else
                tutorialState--;
        }
        
    } else if (tutorialState == tutorialCounter++) { //tap
        updatesToAdvanceTutorial = 120;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Notice how you flew to the side of the"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"planet that you swiped towards?"]];
        
    } else if (tutorialState == tutorialCounter++) { //good angle
        //[tutorialLabel1 setString:[NSString stringWithFormat:@"Getting into position..."]];
        tutorialAdvanceMode = 0;
        float ang = CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity));
        if (!(ang > -90 && ang < 0)) {
            shouldDisplayWaiting = true;
        }
        if (shouldDisplayWaiting)
            [tutorialLabel1 setString:[NSString stringWithFormat:@"Getting into position..."]];
        
        if (ang > 0 && ang < 10) {
            [self AdvanceTutorial];
        }
        
    } else if (tutorialState == tutorialCounter++) { //swipe
        isTutPaused = true;
        tutorialAdvanceMode = 2;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Try going the other way this time."]];
        [self updateHandFrom:ccp(180, 140) to:ccp(400, 240) fadeInUpdates:20 moveUpdates:70 fadeOutUpdates:20 goneUpdates:30];
        [self updateHand2From:ccp(180, 140) to:ccp(400, 40) fadeInUpdates:20 moveUpdates:70 fadeOutUpdates:20 goneUpdates:30];
        
    } else if (tutorialState == tutorialCounter++) { //hit the next zone
        if (orbitState == 0) {
            if (lastPlanetVisited.number == tutorialPlanetIndex + 1)
                [self AdvanceTutorial];
            else
                tutorialState--;
        }
        
    } else if (tutorialState == tutorialCounter++) { //swipe
        tutorialAdvanceMode = 2;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"There you go! Try going in different"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"directions a few more times to get"]];
        [tutorialLabel3 setString:[NSString stringWithFormat:@"a feel for it."]];
        
    } else if (tutorialState == tutorialCounter++) { //hit the next zone
        tutorialAdvanceMode = 0;
        if (orbitState == 0) {
            if (lastPlanetVisited.number == tutorialPlanetIndex + 1)
                [self AdvanceTutorial];
            else
                tutorialState--;
        }
        
    } else if (tutorialState == tutorialCounter++) { //swipe
        tutorialAdvanceMode = 2;
        
    } else if (tutorialState == tutorialCounter++) { //hit the next zone
        tutorialAdvanceMode = 0;
        if (orbitState == 0) {
            if (lastPlanetVisited.number == tutorialPlanetIndex + 1)
                [self AdvanceTutorial];
            else
                tutorialState--;
        }
        
    } else if (tutorialState == tutorialCounter++) { //swipe
        tutorialAdvanceMode = 2;
        
    } else if (tutorialState == tutorialCounter++) { //hit the next zone
        tutorialAdvanceMode = 0;
        if (orbitState == 0) {
            if (lastPlanetVisited.number == tutorialPlanetIndex + 1)
                [self AdvanceTutorial];
            else
                tutorialState--;
        }
        
    } else if (tutorialState == tutorialCounter++) { //swipe
        tutorialAdvanceMode = 2;
        
    } else if (tutorialState == tutorialCounter++) { //hit the next zone
        tutorialAdvanceMode = 0;
        if (orbitState == 0) {
            if (lastPlanetVisited.number == tutorialPlanetIndex + 1)
                [self AdvanceTutorial];
            else
                tutorialState--;
        }
        
    } else if (tutorialState == tutorialCounter++) { //tap
        updatesToAdvanceTutorial = 120;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"You've got it! But now we'll have"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"to start worrying about asteroids."]];

        
        
        
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
    
    if (tutorialAdvanceMode == 1)
        [tutorialLabel0 setString:[NSString stringWithFormat:@"Tap to continue...                                    Tap to continue..."]];
    else
        [tutorialLabel0 setString:[NSString stringWithFormat:@" "]];
    
    if (tutorialPauseTimer < updatesToAdvanceTutorial)
        [tutorialLabel0 setString:[NSString stringWithFormat:@" "]];
        
}

- (void)updateHandFrom:(CGPoint)pos1 to:(CGPoint)pos2 fadeInUpdates:(int)fadeInUpdates moveUpdates:(int)moveUpdates fadeOutUpdates:(int)fadeOutUpdates goneUpdates:(int)goneUpdates {
    
    if (handCounter == 0)
        hand.position = pos1;
    else if (handCounter <= fadeInUpdates)
        hand.opacity += 255/fadeInUpdates;
    else if (handCounter <= fadeInUpdates + moveUpdates) {
        CGPoint vec = ccpSub(pos2, pos1);
        hand.position = ccpAdd(pos1, ccpMult(vec, (handCounter-fadeInUpdates)/moveUpdates));
    } else if (handCounter <= fadeInUpdates + moveUpdates + fadeOutUpdates)
        hand.opacity -= 255/fadeOutUpdates;
    else if (handCounter > fadeInUpdates + moveUpdates + fadeOutUpdates + goneUpdates)
        handCounter = -1;
    
    // hand.opacity = 100;
    
    handCounter++;
}

- (void)updateHand2From:(CGPoint)pos1 to:(CGPoint)pos2 fadeInUpdates:(int)fadeInUpdates moveUpdates:(int)moveUpdates fadeOutUpdates:(int)fadeOutUpdates goneUpdates:(int)goneUpdates {
    
    if (handCounter2 == 0)
        hand2.position = pos1;
    else if (handCounter2 <= fadeInUpdates)
        hand2.opacity += 255/fadeInUpdates;
    else if (handCounter2 <= fadeInUpdates + moveUpdates) {
        CGPoint vec = ccpSub(pos2, pos1);
        hand2.position = ccpAdd(pos1, ccpMult(vec, (handCounter2-fadeInUpdates)/moveUpdates));
    } else if (handCounter2 <= fadeInUpdates + moveUpdates + fadeOutUpdates)
        hand2.opacity -= 255/fadeOutUpdates;
    else if (handCounter2 > fadeInUpdates + moveUpdates + fadeOutUpdates + goneUpdates)
        handCounter2 = -1;
    
    // hand2.opacity = 100;
    
    handCounter2++;
}

- (void)restartGame {
    scoreAlreadySaved = NO;
    if ([[PlayerStats sharedInstance] getPlays] == 1) {
        [[PlayerStats sharedInstance] addPlay];
    }
    //[DataStorage storeData];
    CCLOG(@"number of plays ever: %i", [[PlayerStats sharedInstance] getPlays]);
    [((AppDelegate*)[[UIApplication sharedApplication]delegate])setIsInTutorialMode:FALSE];
    
    [[UIApplication sharedApplication]setStatusBarOrientation:[[UIApplication sharedApplication]statusBarOrientation]];
    
    CCLOG(@"GameplayLayerScene launched, game starting");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        
        if (location.x >= 7 * size.width/8 && location.y >= 5*size.height/6) {
            [self togglePause];
        }
        
        else if (orbitState == 0) {
            [player setThrustBeginPoint:location];
            //playerIsTouchingScreen=true;
        }
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
    if (tutorialPauseTimer >= updatesToAdvanceTutorial) {
        shouldDisplayWaiting = false;
        tutorialAdvanceMode = 1;
        isTutPaused = false;
        updatesToAdvanceTutorial = 0;
        tutorialPauseTimer = 0;
        hand.position = ccp(-1000, 1000);
        hand.opacity = 0;
        handCounter = 0;
        hand2.position = ccp(-1000, 1000);
        hand2.opacity = 0;
        handCounter2 = 0;
        tutorialFader = 0;
        tutorialState++;
        [tutorialLabel1 setString:[NSString stringWithFormat:@""]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@""]];
        [tutorialLabel3 setString:[NSString stringWithFormat:@""]];
        [tutorialLabel0 setString:[NSString stringWithFormat:@""]];
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {    
    playerIsTouchingScreen = false;
    
    if (isInTutorialMode && tutorialAdvanceMode == 1) {
        [self AdvanceTutorial];
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

-(float) randomValueBetween:(float)low andValue:(float)high {
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

- (void)togglePause {
    paused = !paused;
    if (paused) {
        pauseLayer = (CCLayer*)[CCBReader nodeGraphFromFile:@"PauseMenuLayer.ccb" owner:self];
        [pauseLayer setTag:pauseLayerTag];
        [self addChild:pauseLayer];
    } else {
        [self removeChildByTag:pauseLayerTag cleanup:NO];
    }
}

- (void)toggleMute {
    muted = !muted;
    if (muted) {
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
