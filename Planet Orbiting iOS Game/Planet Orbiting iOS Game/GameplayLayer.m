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

@implementation GameplayLayer {
    int planetCounter;
    int score;
    int zonesReached;
    int prevCurrentPtoPScore;
    int initialScoreConstant;
    float killer;
    int startingCoins;
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

- (void)setGameConstants {
    // ask director the the window size
    size = [[CCDirector sharedDirector] winSize];
}

- (void)CreateCoin:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale {
    Coin *coin = [[Coin alloc]init];
    coin.sprite = [CCSprite spriteWithSpriteFrameName:@"coin.png"];
    coin.sprite.position = ccp(xPos, yPos);
    [coin.sprite setScale:scale];
    [cameraObjects addObject:coin];
    [coins addObject:coin];
    [spriteSheet addChild:coin.sprite];
    [coin release];
}

- (void)CreateAsteroid:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale {
    Asteroid *asteroid = [[Asteroid alloc]init];
    asteroid.sprite = [CCSprite spriteWithSpriteFrameName:@"asteroid.png"];
    asteroid.sprite.position = ccp(xPos, yPos);
    [asteroid.sprite setScale:scale];
    [cameraObjects addObject:asteroid];
    [asteroids addObject:asteroid];
    [spriteSheet addChild:asteroid.sprite];
    [asteroid release];
}

- (void)CreatePlanetAndZone:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale {
    Planet *planet = [[Planet alloc]init];
    planet.sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"planet%d.png",[self RandomBetween:1 maxvalue:7]]];
    planet.sprite.position =  ccp(xPos, yPos);
    [planet.sprite setScale:scale];
    planet.mass = 1;
    planet.number = planetCounter;
    
    Zone *zone = [[Zone alloc]init];
    zone.sprite = [CCSprite spriteWithSpriteFrameName:@"zone.png"];
    [zone.sprite setScale:scale*zoneScaleRelativeToPlanet];
    zone.number = planetCounter;
    zone.sprite.position = planet.sprite.position;
    
    planet.orbitRadius = zone.radius*zoneCollisionFactor;
    
    [cameraObjects addObject:planet];
    [planets addObject:planet];
    
    [cameraObjects addObject:zone];
    [zones addObject:zone];
    
    [spriteSheet addChild:planet.sprite];
    [spriteSheet addChild:zone.sprite];
    [zone release];
    [planet release];
    planetCounter++;
}

- (void)CreateLevel // paste level creation code here
{
    if (isInTutorialMode) {
        [self CreatePlanetAndZone:163 yPos:159 scale:1];
        [self CreatePlanetAndZone:714 yPos:387 scale:1];
        [self CreatePlanetAndZone:914 yPos:387 scale:1];
        [self CreatePlanetAndZone:1114 yPos:387 scale:1];
        [self CreatePlanetAndZone:1314 yPos:387 scale:1];
        return;
    }
    
    NSArray *segments = [NSArray arrayWithObjects:
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
                          [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1986,-249) scale:1.539999],
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
                         
                         [NSArray arrayWithObjects: [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(195,199) scale:0.87552],
                          [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(192,16) scale:0.87552],
                          [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(565,368) scale:1.61152],
                          [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(968,349) scale:0.87552],
                          [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1035,418) scale:0.87552],
                          [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1067,495) scale:0.87552],
                          [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(1073,570) scale:0.87552],
                          [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(836,831) scale:0.87552],
                          [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(652,967) scale:0.87552],
                          [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(669,1048) scale:0.87552],
                          [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(693,1131) scale:0.87552],
                          [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(764,1062) scale:0.87552],
                          [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(876,904) scale:0.87552],
                          [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(709,1617) scale:0.87552],
                          [[LevelObjectReturner alloc]initWithType:kasteroid  position:ccp(807,1653) scale:0.87552],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(177,-62) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(242,-37) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(308,-4) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(367,23) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(139,116) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(218,85) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(292,55) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(401,372) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(442,424) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(480,487) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(510,541) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(631,195) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(692,244) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(741,287) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(793,328) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(623,815) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(669,860) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(728,909) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(943,1055) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(889,1019) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(832,985) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(784,953) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(986,752) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(991,827) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(994,896) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(998,966) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1001,1086) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(999,1029) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(798,1392) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(728,1389) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(662,1389) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(600,1389) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(631,1723) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(687,1748) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(745,1779) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(805,1809) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1149,1848) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1210,1830) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1283,1810) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1347,1805) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1089,1590) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1161,1570) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1227,1558) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1299,1542) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1272,1603) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1248,1652) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1214,1703) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1169,1775) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1137,1637) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1182,1673) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1262,1735) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kcoin  position:ccp(1312,1763) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(0,0) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(440,187) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(762,581) scale:1.54],
                          [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(882,1222) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(525,1546) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(986,1740) scale:1],
                          [[LevelObjectReturner alloc]initWithType:kplanet  position:ccp(1463,1652) scale:1],
                          nil],
                         nil];
    
    CGPoint indicatorPos = CGPointZero;
    for (int j = 0 ; j < numberOfSegmentsAtATime; j++) {
        float rotationOfSegment = CC_DEGREES_TO_RADIANS([self RandomBetween:-segmentRotationVariation+directionPlanetSegmentsGoIn maxvalue:segmentRotationVariation+directionPlanetSegmentsGoIn]);
        NSArray *chosenSegment = [segments objectAtIndex:[self RandomBetween:0 maxvalue:[segments count]-1]];
        for (int i = 0 ; i < [chosenSegment count]; i++) {
            LevelObjectReturner * returner = [chosenSegment objectAtIndex:i];
            CGPoint newPos = ccpRotateByAngle(ccp(returner.pos.x+indicatorPos.x,returner.pos.y+indicatorPos.y), indicatorPos, rotationOfSegment);
            if (i==[chosenSegment count]-1) {
                indicatorPos = newPos;
                break;
            }
            
            if (returner.type == kplanet) {
                [self CreatePlanetAndZone:newPos.x yPos:newPos.y scale:returner.scale];
            }
            if (returner.type == kcoin)
                [self CreateCoin:newPos.x yPos:newPos.y scale:returner.scale];
            if (returner.type == kasteroid)
                [self CreateAsteroid:newPos.x yPos:newPos.y scale:returner.scale];
        }
    }
    for (int i = 0 ; i < [segments count]-1; i++){
        NSArray *chosenSegment = [segments objectAtIndex:i];
        for (int j = 0 ; j < [chosenSegment count]-1;j++) {
            [[chosenSegment objectAtIndex:j] release];
        }
    }
}

/* On "init," initialize the instance */
- (id) init {
	// always call "super" init.
	// Apple recommends to re-assign "self" with the "super" return value
	if((self = [super init])) {
        startingCoins = [[UserWallet sharedInstance] getBalance];
        [self setGameConstants];
        self.isTouchEnabled= TRUE;
        
        isInTutorialMode = [((AppDelegate*)[[UIApplication sharedApplication]delegate]) getIsInTutorialMode];
        if ([[PlayerStats sharedInstance] getPlays] == 1) {
            isInTutorialMode = YES;
        } else {
            isInTutorialMode = NO;
        }
        
        planetCounter = 0;
        cameraObjects = [[NSMutableArray alloc] init];
        planets = [[NSMutableArray alloc] init];
        asteroids = [[NSMutableArray alloc] init];
        zones = [[NSMutableArray alloc] init];
        coins = [[NSMutableArray alloc] init];
        hudLayer = [[CCLayer alloc] init];
        cameraLayer = [[CCLayer alloc] init];
        
        cometParticle = [CCParticleSystemQuad particleWithFile:@"cometParticle.plist"];
        planetExplosionParticle = [CCParticleSystemQuad particleWithFile:@"planetExplosion.plist"];
        [planetExplosionParticle stopSystem];
      //  [cameraLayer addChild:planetExplosionParticle];
        playerExplosionParticle = [CCParticleSystemQuad particleWithFile:@"playerExplosionParticle.plist"];
      //  [cameraLayer addChild:playerExplosionParticle];
        [playerExplosionParticle setVisible:false];
        [playerExplosionParticle stopSystem];
        spaceBackgroundParticle = [CCParticleSystemQuad particleWithFile:@"spaceParticles.plist"];
        thrustParticle = [CCParticleSystemQuad particleWithFile:@"thrustParticle3.plist"];
        blackHoleParticle = [CCParticleSystemQuad particleWithFile:@"blackHoleParticle.plist"];
        [blackHoleParticle setPositionType:kCCPositionTypeGrouped];
        
        
        if (!isInTutorialMode) {
            scoreLabel = [CCLabelTTF labelWithString:@"Score: " fontName:@"Marker Felt" fontSize:24];
            scoreLabel.position = ccp(400, [scoreLabel boundingBox].size.height);
            [hudLayer addChild: scoreLabel];
            
            coinsLabel = [CCLabelTTF labelWithString:@"Coins: " fontName:@"Marker Felt" fontSize:24];
            coinsLabel.position = ccp(70, [coinsLabel boundingBox].size.height);
            [hudLayer addChild: coinsLabel];
        } else {
            tutorialState = 0;
            tutorialFader = 0;
            tutorialAdvanceMode = 1;
            
            tutorialLabel1 = [CCLabelTTF labelWithString:@" " fontName:@"Marker Felt" fontSize:24];
            tutorialLabel1.position = ccp(240, 320-[tutorialLabel1 boundingBox].size.height/2);
            [hudLayer addChild: tutorialLabel1];
            
            tutorialLabel2 = [CCLabelTTF labelWithString:@" " fontName:@"Marker Felt" fontSize:24];
            tutorialLabel2.position = ccp(240, 320-[tutorialLabel2 boundingBox].size.height*1.5);
            [hudLayer addChild: tutorialLabel2];
            
            tutorialLabel3 = [CCLabelTTF labelWithString:@" " fontName:@"Marker Felt" fontSize:24];
            tutorialLabel3.position = ccp(240, 320-[tutorialLabel3 boundingBox].size.height*2.5);
            [hudLayer addChild: tutorialLabel3];
            
            tutorialLabel0 = [CCLabelTTF labelWithString:@" " fontName:@"Marker Felt" fontSize:20];
            tutorialLabel0.position = ccp(400, [tutorialLabel0 boundingBox].size.height);
            [hudLayer addChild: tutorialLabel0];
        }
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"phasenwandler_-_Longing_for_Freedom.mp3" loop:YES];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"bomb.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"SWOOSH.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"buttonpress.mp3"];
        
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"spriteSheetCamera.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spriteSheetCamera.plist"];
        
        
        
        [self CreateLevel];
        
        player = [[Player alloc]init];        
        player.sprite = [CCSprite spriteWithSpriteFrameName:@"spaceship-hd.png"];
        player.alive=true;
        [player.sprite setScale:playerSizeScale];
        [cameraObjects addObject:player];         
        
        streak=[CCLayerStreak streakWithFade:2 minSeg:3 image:@"streak.png" width:31 length:32 color:// ccc4(153,102,0, 255)  //orange
                ccc4(255,255,255, 255) // white
                // ccc4(255,255,0,255) // yellow
                // ccc4(0,0,255,0) // blue
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
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444]; // add this line at the very beginning
        background = [CCSprite spriteWithFile:@"background.pvr.ccz"];
        background.position = ccp(size.width/2+31,19);
        background.scale *=1.3f;
        [self addChild:background];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888]; // add this line at the very beginning
        
    //    [self addChild:spaceBackgroundParticle];
      //  [self addChild:cometParticle];
        cometParticle.position = ccp([self RandomBetween:0 maxvalue:390],325);
        cometVelocity = ccp([self RandomBetween:-10 maxvalue:10]/5,-[self RandomBetween:1 maxvalue:23]/5);
        [self resetVariablesForNewGame];  
        timeSincePlanetExplosion=400000;
        
        hand = [CCSprite spriteWithFile:@"edit(84759).png"];
        hand.position = ccp(-1000, -1000);
        
        [self addChild:cameraLayer];
        [cameraLayer addChild:spriteSheet];
        [hudLayer addChild:hand];
        [self addChild:hudLayer];
        [self UpdateScore];
        
        [Flurry logEvent:@"Played Game" withParameters:nil timed:YES];
        
        [self schedule:@selector(Update:) interval:0]; // this makes the update loop loop!!!!        
	}
	return self;
}

- (void)ZoomLayer:(CCLayer*)layer withScale:(CGFloat)scale toPosition:(CGPoint)position{
    [layer setScale:scale];
    cameraFocusNode.position = ccp(scale*position.x,scale*position.y);
    [cameraFocusNode setPosition:ccpAdd(cameraFocusNode.position, ccp(-((-.5+.5*scale)*size.width),(-(-.5+.5*scale)*size.height)))];
}

- (void)UpdateCamera:(float)dt {
    for (CameraObject *object in cameraObjects) { 
        if (object.alive) {
            object.velocity = ccpAdd(object.velocity, object.acceleration);
            object.sprite.position = ccpAdd(ccpMult(object.velocity, 60*dt*timeDilationCoefficient), object.sprite.position);
            
            /* if (object.isBeingDrawn == FALSE)
             if (object.hasExploded==FALSE&&CGRectIntersectsRect([object rectOnScreen:cameraLayer], CGRectMake(0, 0, size.width, size.height))) {
             object.sprite.visible=true;
             object.isBeingDrawn = true;
             }
             else {
             object.visible = false;
             object.isBeingDrawn = false;
             } */
        }
    }
    // camera code follows -----------------------------
    Planet * nextPlanet;
    float distToUse;
    if (lastPlanetVisited.number +1 < [planets count])
        nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number+1)];
    else     nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number-1)];
    
    CGPoint focusPosition;
    Planet* planetForZoom = nextPlanet;
    if (orbitState == 0 || nextPlanet.number + 1 >= [planets count]) {
        focusPosition= ccpMidpoint(lastPlanetVisited.sprite.position, nextPlanet.sprite.position);
        focusPosition = ccpLerp(focusPosition, ccpMidpoint(focusPosition, player.sprite.position), .25f) ;
        distToUse = ccpDistance(lastPlanetVisited.sprite.position, planetForZoom.sprite.position) + ((Zone*)[zones objectAtIndex:lastPlanetVisited.number]).radius + ((Zone*)[zones objectAtIndex:planetForZoom.number]).radius;
    }
    else {
        focusPosition = ccpMidpoint(player.sprite.position, nextPlanet.sprite.position);
        Planet* nextNextPlanet = [planets objectAtIndex:(nextPlanet.number+1)];
        planetForZoom=nextNextPlanet;
        focusPosition = ccpMidpoint(player.sprite.position, nextNextPlanet.sprite.position);
        distToUse = ccpDistance(player.sprite.position, nextNextPlanet.sprite.position) +player.radius + ((Zone*)[zones objectAtIndex:planetForZoom.number]).radius;
    }
    
    float horizontalScale = 294.388933833*pow(distToUse,-.94226344467);
    
    float newAng = CC_RADIANS_TO_DEGREES(fabs(ccpToAngle(ccpSub(planetForZoom.sprite.position, focusPosition))));
    if (newAng > 270)
        newAng = 360 - newAng;
    if (newAng > 180)
        newAng = newAng - 180;
    if (newAng > 90)
        newAng = 180 - newAng;
    
    //float vals [] = {240,240.5,243,246.5,252,262,273,287,254,231,212,197,185,177,170,165,162,160.5,160};
    
    //int indexToUse = (int)clampf((newAng/5 + 0.5), 0, 18);
    //float numerator = vals[indexToUse];
    
    
    
    //0 to 35: 240-(3.1/10)x+(4.6/100)x^2
    //35 to 90: 499-8.1x+(4.9/100)x^2
    
    float numerator;
    
    if (newAng < 35)
        numerator = 240-(3.1/10)*newAng+(4.6/100)*powf(newAng, 2);
    else
        numerator = 499-8.1*newAng + (4.9/100)*powf(newAng, 2);
    
    float scalerToUse = numerator/240;
    
    //CCLOG(@"num: %f, newAng: %f", numerator, newAng);
    
    float scale = zoomMultiplier*horizontalScale*scalerToUse;
    
    cameraFocusNode.position = ccpLerp(cameraFocusNode.position, focusPosition, cameraMovementSpeed);
    focusPosition =ccpLerp(cameraLastFocusPosition, focusPosition, cameraMovementSpeed);
    [self ZoomLayer:cameraLayer withScale:lerpf([cameraLayer scale], scale, cameraZoomSpeed) toPosition: focusPosition];
    id followAction = [CCFollow actionWithTarget:cameraFocusNode];
    [cameraLayer runAction: followAction];
    cameraLastFocusPosition=focusPosition;
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
                    
                    float distToUse = factorToPlaceGravFieldWhenCrossingOverTheMiddle; //crossing over the middle
                    if (ccpLength(ccpSub(player.sprite.position, spot1)) < ccpLength(ccpSub(player.sprite.position, spot2)))
                        distToUse = factorToPlaceGravFieldWhenStayingOutside; //staying outside
                    
                    spotGoingTo = ccpAdd(ccpMult(dir2, targetPlanet.orbitRadius*distToUse), targetPlanet.sprite.position);
                    newAng = ccpToAngle(ccpSub(left, player.sprite.position));
                    vel = ccpSub(left, player.sprite.position);
                } else {
                    
                    float distToUse = factorToPlaceGravFieldWhenCrossingOverTheMiddle; //crossing over the middle
                    if (ccpLength(ccpSub(player.sprite.position, spot1)) > ccpLength(ccpSub(player.sprite.position, spot2)))
                        distToUse = factorToPlaceGravFieldWhenStayingOutside; //staying outside
                    
                    spotGoingTo = ccpAdd(ccpMult(dir3, targetPlanet.orbitRadius*distToUse), targetPlanet.sprite.position);
                    newAng = ccpToAngle(ccpSub(right, player.sprite.position));
                    vel = ccpSub(right, player.sprite.position);
                }
                
                float curAng = ccpToAngle(player.velocity);
                
                swipeAccuracy = fabsf(CC_RADIANS_TO_DEGREES(curAng) - CC_RADIANS_TO_DEGREES(newAng));;
                
                if (swipeAccuracy > 180)
                    swipeAccuracy = 360 - swipeAccuracy;
                
                CCLOG(@"cur: %f", swipeAccuracy);
                
                
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
                
                //perhaps dont use scaler/swipe accuracy, and just use it in (if orbitstate=1) for determining if it's good enough. btw scaler ranges from about 1to 3.5 (now 0 to 2.5)
                
                
                player.acceleration = ccpMult(accelToAdd, gravIncreaser*freeGravityStrength*scaler);
                CCLOG(@"swipeAcc: %f", ccpLength(player.acceleration));
                
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
            //[self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number];
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

//FIX you don't really need planetIndex passed in because it's just going to spawn at the position of the last thrust point anyway
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
    player.velocity=CGPointZero;
    player.acceleration=CGPointZero;
    
    [Flurry logEvent:@"Player Died" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:lastPlanetVisited.number],@"Last planet reached",[NSNumber numberWithInt:numZonesHitInARow],@"Pre-death combo", nil]];
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
    player.sprite.position = [self GetPositionForJumpingPlayerToPlanet:0];
    [cameraLayer removeChild:thrustParticle cleanup:NO];
    
    CGPoint focusPosition= ccpMidpoint(((Planet*)[planets objectAtIndex:0]).sprite.position, ((Planet*)[planets objectAtIndex:1]).sprite.position);
    focusPosition = ccpLerp(focusPosition, ccpMidpoint(focusPosition, player.sprite.position), .25f) ;
    [cameraLayer setPosition:focusPosition];
    
    score=0;
    zonesReached=0;
    totalGameTime = 0 ;
    lastPlanetVisited = [planets objectAtIndex:0];
    timeSinceCometLeftScreen=0;
    timeSincePlanetExplosion=40000; //some arbitrarily high number
    prevCurrentPtoPScore=0;
    
    //this is where the player is on screen (240,160 is center of screen)
    [player setVelocity:ccp(0,0)];
    justReachedNewPlanet = true;
    
    blackHoleParticle.position=ccp(-400,-400);
    [cameraLayer removeChild:blackHoleParticle cleanup:NO];
   // [cameraLayer addChild:blackHoleParticle z:1];
    
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
                }
                
                [zone.sprite setColor:ccc3(255, 80, 180)];
                zone.hasPlayerHitThisZone = true;  
                zonesReached++;
                score+=currentPtoPscore;
                currentPtoPscore=0;
                prevCurrentPtoPScore=0;
                numZonesHitInARow++;
                timeDilationCoefficient += timeDilationIncreaseRate;
                
                if (zonesReached>=[zones count]) {
                    [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationPortrait];
                    [TestFlight passCheckpoint:@"Reached All Zones"];
                    [Flurry endTimedEvent:@"Played Game" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:score],@"Score", nil]];
                }
            }
        }
        else if (i<[zones count]-1&&((Zone*)[zones objectAtIndex:i+1]).hasPlayerHitThisZone) { //if player has hit the next zone and it hasn't exploded yet
            if (zone.hasPlayerHitThisZone&&!zone.hasExploded){
                Planet * planet = [planets objectAtIndex:zone.number];
                planet.alive = false;
                [planetExplosionParticle setPosition:zone.sprite.position];
                [planetExplosionParticle resetSystem];
                [[SimpleAudioEngine sharedEngine]playEffect:@"bomb.wav"];
                zone.hasExploded=true;
                planet.hasExploded=true;
                zone.isBeingDrawn=FALSE;
                [spriteSheet removeChild:planet.sprite cleanup:YES];
                [spriteSheet removeChild:zone.sprite cleanup:YES];
                planet.isBeingDrawn=FALSE;
                timeSincePlanetExplosion=0;
                planetJustExploded=true;
            }
        }
    } // end collision detection code-----------------
}

/* Your score goes up as you move along the vector between the current and next planet. Your score will also never go down, as the user doesn't like to see his score go down.*/
- (void)UpdateScore {
    Planet * nextPlanet;
    if (lastPlanetVisited.number +1 < [planets count])
        nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number+1)];
    else     nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number-1)];
    
    float firstToPlayerAngle = ccpAngle(lastPlanetVisited.sprite.position, player.sprite.position)-ccpAngle(lastPlanetVisited.sprite.position, nextPlanet.sprite.position);
    float firstToPlayerDistance = ccpDistance(lastPlanetVisited.sprite.position, player.sprite.position);    
    
    prevCurrentPtoPScore = currentPtoPscore;
    int newScore = ((int)((float)firstToPlayerDistance*cosf(firstToPlayerAngle)));
    if (newScore > prevCurrentPtoPScore)
        currentPtoPscore = newScore;
    [scoreLabel setString:[NSString stringWithFormat:@"Score: %d",score+currentPtoPscore]];
    int numCoins = [[UserWallet sharedInstance] getBalance];
    int coinsDiff = numCoins - startingCoins;
    [coinsLabel setString:[NSString stringWithFormat:@"Coins: %i",coinsDiff]];
}

- (void)UpdateParticles:(ccTime)dt {
    [thrustParticle setPosition:player.sprite.position];
    [thrustParticle setAngle:180+CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity))];
    [thrustParticle setEmissionRate:ccpLengthSQ(player.velocity)*ccpLength(player.velocity)/2.2f];
    
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
    
    if (planetJustExploded) {
        timeSincePlanetExplosion+=dt;
        if (timeSincePlanetExplosion<= durationOfPostExplosionScreenShake) {
            [self setPosition:ccp([self RandomBetween:-postExplosionShakeXMagnitude maxvalue:postExplosionShakeXMagnitude],[self RandomBetween:-postExplosionShakeYMagnitude maxvalue:postExplosionShakeYMagnitude])];
        } else {
            planetJustExploded =false;
        }
    }
    else [self setPosition:CGPointZero];
}

- (void)UpdateBlackhole {
    [blackHoleParticle setPosition:ccpLerp(blackHoleParticle.position, player.sprite.position, .009f*blackHoleSpeedFactor)];
    if (ccpDistance(player.sprite.position, blackHoleParticle.position)<blackHoleParticle.startRadius*blackHoleCollisionRadiusFactor)
    {
        //[self endGame];
    }
}

- (void) Update:(ccTime)dt {
    if (!isTutPaused) {
        if (zonesReached<[planets count])
            totalGameTime+=dt;
        if (player.alive)
            [self UpdatePlanets];
        [self UpdatePlayer: dt];
        [self UpdateScore];
        [self UpdateCamera:dt];
        [self UpdateParticles:dt];
        [self UpdateBlackhole];
    }
    if (isInTutorialMode)
        [self UpdateTutorial];
}

- (void)endGame {
    [DataStorage storeData];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene: [MainMenuLayer scene]]];
}

- (void)UpdateTutorial {
    hand.scale = .5;
    
    
    
    int tutorialCounter = 0;
    tutorialFader+= 4;
    tutorialFader = clampf(tutorialFader, 0, 255);
    [tutorialLabel1 setOpacity:tutorialFader];
    [tutorialLabel2 setOpacity:tutorialFader];
    [tutorialLabel3 setOpacity:tutorialFader];
    [tutorialLabel0 setOpacity:clampf(((sinf(totalGameTime*5)+1)/2)*300, 0, 255)];
        
    if (tutorialState == tutorialCounter++) {

        [tutorialLabel1 setString:[NSString stringWithFormat:@"Welcome to Star Dash!"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"Tap to begin the tutorial..."]];
        [tutorialLabel0 setString:[NSString stringWithFormat:@"Tap to continue..."]];
        
    } else if (tutorialState == tutorialCounter++) {
        
        [tutorialLabel1 setString:[NSString stringWithFormat:@"The objective of the game is to swipe to get the"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"rocket ship to the next planet. Tap to see when"]];
        [tutorialLabel3 setString:[NSString stringWithFormat:@"the best time to swipe is..."]];
        [tutorialLabel0 setString:[NSString stringWithFormat:@"Tap to continue..."]];
        
    } else if (tutorialState == tutorialCounter++) {
        
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Getting in position..."]];
        tutorialAdvanceMode = 0;
        
        float ang = CC_RADIANS_TO_DEGREES(ccpToAngle(player.velocity));
        
        // CCLOG(@"ang: %f", ang);
        
        if (ang > 0 && ang < 10) {
            [self AdvanceTutorial];
        }
    } else if (tutorialState == tutorialCounter++) {
        isTutPaused = true;
        tutorialAdvanceMode = 2;
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Right now is when you'd want to swipe."]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"Swipe towards the next planet to continue..."]];
        
        [self updateHandFrom:ccp(230, 20) to:ccp(450, 150) fadeInUpdates:20 moveUpdates:50 fadeOutUpdates:20];
        
        
    } else if (tutorialState == tutorialCounter++) {
        isTutPaused = false;
        
        [tutorialLabel1 setString:[NSString stringWithFormat:@"SUCK A FAT CHODE BITCH"]];
        tutorialAdvanceMode = 0;
        
        if (orbitState == 0) {
            [self AdvanceTutorial];
        }
    } else if (tutorialState == tutorialCounter++) {
        
        [tutorialLabel1 setString:[NSString stringWithFormat:@"Success!!! You made it!"]];
        [tutorialLabel0 setString:[NSString stringWithFormat:@"Tap to continue..."]];
        
    } else if (tutorialState == tutorialCounter++) {
        [self startGame];
        tutorialState++;
    }
}

- (void)updateHandFrom:(CGPoint)pos1 to:(CGPoint)pos2 fadeInUpdates:(int)fadeInUpdates moveUpdates:(int)moveUpdates fadeOutUpdates:(int)fadeOutUpdates {
    
    if (handCounter == 0)
        hand.position = pos1;
    else if (handCounter <= fadeInUpdates)
        hand.opacity += 255/fadeInUpdates;
    else if (handCounter <= fadeInUpdates + moveUpdates) {
        CGPoint vec = ccpSub(pos2, pos1);
        hand.position = ccpAdd(pos1, ccpMult(vec, (handCounter-fadeInUpdates)/moveUpdates));
    } else if (handCounter <= fadeInUpdates + moveUpdates + fadeOutUpdates)
        hand.opacity -= 255/fadeOutUpdates;
    else
        handCounter = -1;
        
    

    //hand.opacity = 100;
    
    handCounter++;
}

- (void)startGame {
    if ([[PlayerStats sharedInstance] getPlays] == 1) {
        [[PlayerStats sharedInstance] addPlay];
    }
    [DataStorage storeData];
    CCLOG(@"number of plays ever: %i", [[PlayerStats sharedInstance] getPlays]);
	MainMenuLayer *layer = [MainMenuLayer node];
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(-480,-320)];
    id ease = [CCEaseOut actionWithAction:action rate:2];
    [layer runAction: ease];
    
    [((AppDelegate*)[[UIApplication sharedApplication]delegate])setIsInTutorialMode:FALSE];
    
    [[UIApplication sharedApplication]setStatusBarOrientation:[[UIApplication sharedApplication]statusBarOrientation]];
    
    CCLOG(@"GameplayLayerScene launched, game starting");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        
        if (location.x <= size.width/6 && location.y >= 4*size.height/5) {
            [self endGame];
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
            [self JustSwiped];
            [self AdvanceTutorial];
        }
    }
    
    //CCLOG(@"num: %f, newAng: %f", ccpLength(swipeVector), minSwipeStrength);
    //if (ccpLength(swipeVector) >= minSwipeStrength && tutorialAdvanceMode == 2 && isInTutorialMode) {
    //    [self AdvanceTutorial];
    //}
}

- (void)JustSwiped {
    orbitState = 1;
    targetPlanet = [planets objectAtIndex: (lastPlanetVisited.number + 1)];
}

- (void)AdvanceTutorial {
    tutorialAdvanceMode = 1;
    hand.position = ccp(-1000, 1000);
    hand.opacity = 0;
    handCounter = 0;
    tutorialFader = 0;
    tutorialState++;
    [tutorialLabel1 setString:[NSString stringWithFormat:@""]];
    [tutorialLabel2 setString:[NSString stringWithFormat:@""]];
    [tutorialLabel3 setString:[NSString stringWithFormat:@""]];
    [tutorialLabel0 setString:[NSString stringWithFormat:@""]];
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


/**
 - (void)dealloc {
 // before we add anything here, we should talk about what will be retained vs. released vs. set to nil in certain situations
 [super dealloc];
 }
 **/


#if !defined(MIN)
#define MIN(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __a : __b; })
#endif

#if !defined(MAX)
#define MAX(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __b : __a; })
#endif

@end