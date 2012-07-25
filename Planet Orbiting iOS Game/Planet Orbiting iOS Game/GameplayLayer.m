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

- (void)setGameConstants
{
    // ask director the the window size
    size = [[CCDirector sharedDirector] winSize];
}

- (void)CreateCoin:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale
{
    Coin *coin = [[Coin alloc]init];
    coin.sprite = [CCSprite spriteWithSpriteFrameName:@"coin.png"];
    coin.sprite.position = ccp(xPos, yPos);
    [coin.sprite setScale:scale];
    [cameraObjects addObject:coin];
    [coins addObject:coin];
    [spriteSheet addChild:coin.sprite];
    [coin release];
}

- (void)CreateAsteroid:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale
{
    Asteroid *asteroid = [[Asteroid alloc]init];
    asteroid.sprite = [CCSprite spriteWithSpriteFrameName:@"asteroid.png"];
    asteroid.sprite.position = ccp(xPos, yPos);
    [asteroid.sprite setScale:scale];
    [cameraObjects addObject:asteroid];
    [asteroids addObject:asteroid];
    [spriteSheet addChild:asteroid.sprite];
    [asteroid release];
}

- (void)CreatePlanetAndZone:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale
{
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
    if (!isInTutorialMode) {
        [self CreatePlanetAndZone:163 yPos:159 scale:1];
        [self CreatePlanetAndZone:514 yPos:387 scale:1];
        [self CreatePlanetAndZone:879 yPos:624 scale:1];
        [self CreatePlanetAndZone:1401 yPos:574 scale:1];
        [self CreatePlanetAndZone:1385 yPos:173 scale:1];
        [self CreatePlanetAndZone:958 yPos:-42 scale:1];
        [self CreatePlanetAndZone:464 yPos:-369 scale:1.599999];
        [self CreatePlanetAndZone:-120 yPos:-937 scale:2.559999];
        [self CreatePlanetAndZone:806 yPos:-1149 scale:1.3];
        [self CreatePlanetAndZone:1316 yPos:-862 scale:1];
        [self CreatePlanetAndZone:1375 yPos:-438 scale:1];
        [self CreatePlanetAndZone:1755 yPos:-539 scale:1];
        [self CreatePlanetAndZone:2156 yPos:-310 scale:1];
        [self CreatePlanetAndZone:2507 yPos:12 scale:1];
        
        
        [self CreateAsteroid:1115 yPos:451 scale:0.87552];
        [self CreateAsteroid:1118 yPos:520 scale:0.87552];
        [self CreateAsteroid:1140 yPos:708 scale:0.87552];
        [self CreateAsteroid:1139 yPos:782 scale:0.87552];
        [self CreateAsteroid:1551 yPos:364 scale:0.87552];
        [self CreateAsteroid:1635 yPos:296 scale:0.87552];
        [self CreateAsteroid:1654 yPos:212 scale:0.87552];
        [self CreateAsteroid:1643 yPos:123 scale:0.87552];
        [self CreateAsteroid:1612 yPos:33 scale:0.87552];
        [self CreateAsteroid:1539 yPos:-38 scale:0.87552];
        [self CreateAsteroid:1413 yPos:-65 scale:0.87552];
        [self CreateAsteroid:692 yPos:-204 scale:0.87552];
        [self CreateAsteroid:785 yPos:-159 scale:0.87552];
        [self CreateAsteroid:157 yPos:-312 scale:0.87552];
        [self CreateAsteroid:59 yPos:-356 scale:0.87552];
        [self CreateAsteroid:-31 yPos:-406 scale:0.96752];
        [self CreateAsteroid:-131 yPos:-460 scale:0.96752];
        [self CreateAsteroid:346 yPos:-703 scale:0.87552];
        [self CreateAsteroid:375 yPos:-792 scale:0.87552];
        [self CreateAsteroid:473 yPos:-683 scale:1.35852];
        [self CreateAsteroid:432 yPos:-1107 scale:0.87552];
        [self CreateAsteroid:333 yPos:-1088 scale:0.87552];
        [self CreateAsteroid:523 yPos:-1130 scale:0.87552];
        [self CreateAsteroid:1083 yPos:-902 scale:0.87552];
        [self CreateAsteroid:1091 yPos:-821 scale:0.87552];
        [self CreateAsteroid:978 yPos:-910 scale:0.87552];
        [self CreateAsteroid:978 yPos:-837 scale:0.87552];
        [self CreateAsteroid:883 yPos:-884 scale:0.87552];
        [self CreateAsteroid:871 yPos:-813 scale:0.87552];
        [self CreateAsteroid:1030 yPos:-1070 scale:0.87552];
        [self CreateAsteroid:1208 yPos:-660 scale:0.96752];
        [self CreateAsteroid:1124 yPos:-717 scale:0.87552];
        [self CreateAsteroid:1460 yPos:-638 scale:1.05952];
        [self CreateAsteroid:1098 yPos:-573 scale:1.31252];
        [self CreateAsteroid:1070 yPos:-448 scale:1.28952];
        
        
        [self CreateCoin:380 yPos:160 scale:0.332*2];
        [self CreateCoin:410 yPos:178 scale:0.332*2];
        [self CreateCoin:458 yPos:212 scale:0.332*2];
        [self CreateCoin:350 yPos:262 scale:0.332*2];
        [self CreateCoin:251 yPos:320 scale:0.332*2];
        [self CreateCoin:304 yPos:352 scale:0.332*2];
        [self CreateCoin:345 yPos:378 scale:0.332*2];
        [self CreateCoin:684 yPos:428 scale:0.332*2];
        [self CreateCoin:688 yPos:496 scale:0.332*2];
        [self CreateCoin:701 yPos:561 scale:0.332*2];
        [self CreateCoin:760 yPos:477 scale:0.332*2];
        [self CreateCoin:610 yPos:530 scale:0.332*2];
        [self CreateCoin:1064 yPos:581 scale:0.424*2];
        [self CreateCoin:1068 yPos:644 scale:0.447*2];
        [self CreateCoin:1126 yPos:581 scale:0.447*2];
        [self CreateCoin:1136 yPos:643 scale:0.447*2];
        [self CreateCoin:1197 yPos:639 scale:0.447*2];
        [self CreateCoin:1194 yPos:576 scale:0.447*2];
        [self CreateCoin:1278 yPos:499 scale:0.378*2];
        [self CreateCoin:1326 yPos:455 scale:0.378*2];
        [self CreateCoin:1389 yPos:432 scale:0.378*2];
        [self CreateCoin:1461 yPos:450 scale:0.378*2];
        [self CreateCoin:1514 yPos:490 scale:0.378*2];
        [self CreateCoin:1539 yPos:555 scale:0.378*2];
        [self CreateCoin:1530 yPos:621 scale:0.378*2];
        [self CreateCoin:1505 yPos:669 scale:0.378*2];
        [self CreateCoin:1450 yPos:703 scale:0.378*2];
        [self CreateCoin:1376 yPos:710 scale:0.378*2];
        [self CreateCoin:1314 yPos:686 scale:0.378*2];
        [self CreateCoin:1271 yPos:636 scale:0.378*2];
        [self CreateCoin:1262 yPos:570 scale:0.378*2];
        [self CreateCoin:1074 yPos:150 scale:0.654*2];
        [self CreateCoin:1165 yPos:191 scale:0.677*2];
        [self CreateCoin:1182 yPos:-42 scale:0.677*2];
        [self CreateCoin:1267 yPos:-19 scale:0.677*2];
        [self CreateCoin:899 yPos:-224 scale:0.562*2];
        [self CreateCoin:832 yPos:-284 scale:0.562*2];
        [self CreateCoin:760 yPos:-348 scale:0.562*2];
        [self CreateCoin:761 yPos:-27 scale:0.562*2];
        [self CreateCoin:652 yPos:-64 scale:0.562*2];
        [self CreateCoin:561 yPos:-96 scale:0.562*2];
        [self CreateCoin:607 yPos:-974 scale:0.562*2];
        [self CreateCoin:522 yPos:-956 scale:0.562*2];
        [self CreateCoin:427 yPos:-929 scale:0.562*2];
        [self CreateCoin:343 yPos:-904 scale:0.562*2];
        [self CreateCoin:148 yPos:-1299 scale:0.562*2];
        [self CreateCoin:244 yPos:-1296 scale:0.562*2];
        [self CreateCoin:348 yPos:-1287 scale:0.562*2];
        [self CreateCoin:447 yPos:-1292 scale:0.562*2];
        [self CreateCoin:527 yPos:-1295 scale:0.562*2];
        [self CreateCoin:619 yPos:-1295 scale:0.562*2];
        [self CreateCoin:1060 yPos:-1173 scale:0.562*2];
        [self CreateCoin:1142 yPos:-1126 scale:0.562*2];
        [self CreateCoin:1217 yPos:-1072 scale:0.562*2];
        [self CreateCoin:1380 yPos:-1026 scale:0.447*2];
        [self CreateCoin:1442 yPos:-980 scale:0.447*2];
        [self CreateCoin:1480 yPos:-921 scale:0.447*2];
        [self CreateCoin:1500 yPos:-855 scale:0.447*2];
        [self CreateCoin:1492 yPos:-789 scale:0.447*2];
        [self CreateCoin:1452 yPos:-731 scale:0.447*2];
        [self CreateCoin:1368 yPos:-663 scale:0.447*2];
        [self CreateCoin:1298 yPos:-599 scale:0.447*2];
        [self CreateCoin:1232 yPos:-561 scale:0.447*2];
        [self CreateCoin:1201 yPos:-491 scale:0.447*2];
        [self CreateCoin:1197 yPos:-414 scale:0.447*2];
        [self CreateCoin:1224 yPos:-340 scale:0.447*2];
        [self CreateCoin:1275 yPos:-288 scale:0.447*2];
        [self CreateCoin:1342 yPos:-255 scale:0.447*2];
        [self CreateCoin:1412 yPos:-263 scale:0.447*2];
        [self CreateCoin:1482 yPos:-295 scale:0.447*2];
        [self CreateCoin:1561 yPos:-420 scale:0.447*2];
        [self CreateCoin:1578 yPos:-519 scale:0.447*2];
        [self CreateCoin:1948 yPos:-583 scale:0.447*2];
        [self CreateCoin:2012 yPos:-545 scale:0.447*2];
        [self CreateCoin:2085 yPos:-500 scale:0.447*2];
        [self CreateCoin:2328 yPos:-195 scale:0.447*2];
        [self CreateCoin:2356 yPos:-68 scale:0.447*2];
        [self CreateCoin:2342 yPos:-132 scale:0.447*2];
    } else {
        [self CreatePlanetAndZone:163 yPos:159 scale:1];
        [self CreatePlanetAndZone:914 yPos:387 scale:1];
        [self CreatePlanetAndZone:1679 yPos:624 scale:1];
    }
    
}

/* On "init," initialize the instance */
- (id) init
{
	// always call "super" init.
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        [self setGameConstants];
        self.isTouchEnabled= TRUE;
        isInTutorialMode = [((AppDelegate*)[[UIApplication sharedApplication]delegate])getIsInTutorialMode];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444]; // add this line at the very beginning
        planetCounter = 0;
        cameraObjects = [[NSMutableArray alloc]init];
        planets = [[NSMutableArray alloc]init];
        asteroids = [[NSMutableArray alloc]init];
        zones = [[NSMutableArray alloc]init];
        coins = [[NSMutableArray alloc]init];
        hudLayer = [[CCLayer alloc]init];
        cameraLayer = [[CCLayer alloc]init];
        
        cometParticle = [CCParticleSystemQuad particleWithFile:@"cometParticle.plist"];
        planetExplosionParticle = [CCParticleSystemQuad particleWithFile:@"planetExplosion.plist"];
        [planetExplosionParticle stopSystem];
        [cameraLayer addChild:planetExplosionParticle];
        playerExplosionParticle = [CCParticleSystemQuad particleWithFile:@"playerExplosionParticle.plist"];
        [cameraLayer addChild:playerExplosionParticle];
        [playerExplosionParticle setVisible:false];
        [playerExplosionParticle stopSystem];
        spaceBackgroundParticle = [CCParticleSystemQuad particleWithFile:@"spaceParticles.plist"];
        thrustParticle = [CCParticleSystemQuad particleWithFile:@"thrustParticle2.plist"];
        blackHoleParticle = [CCParticleSystemQuad particleWithFile:@"blackHoleParticle.plist"];
        [blackHoleParticle setPositionType:kCCPositionTypeGrouped];
        
        
        if (!isInTutorialMode) {
        scoreLabel = [CCLabelTTF labelWithString:@"Score: " fontName:@"Marker Felt" fontSize:24];
        scoreLabel.position = ccp(400, [scoreLabel boundingBox].size.height);
        [hudLayer addChild: scoreLabel];
        
        zonesReachedLabel = [CCLabelTTF labelWithString:@"Zones Reached: " fontName:@"Marker Felt" fontSize:24];
        zonesReachedLabel.position = ccp(100, [zonesReachedLabel boundingBox].size.height);
        [hudLayer addChild: zonesReachedLabel];
        }
        else {
            tutorialState = 0;
            tutorialFader = 0;
            
            tutorialLabel1 = [CCLabelTTF labelWithString:@" " fontName:@"Marker Felt" fontSize:24];
            tutorialLabel1.position = ccp(240, 320-[tutorialLabel1 boundingBox].size.height/2);
            [hudLayer addChild: tutorialLabel1];
            
            tutorialLabel2 = [CCLabelTTF labelWithString:@" " fontName:@"Marker Felt" fontSize:24];
            tutorialLabel2.position = ccp(240, 320-[tutorialLabel2 boundingBox].size.height*1.5);
            [hudLayer addChild: tutorialLabel2];
            
            tutorialLabel3 = [CCLabelTTF labelWithString:@" " fontName:@"Marker Felt" fontSize:24];
            tutorialLabel3.position = ccp(240, 320-[tutorialLabel3 boundingBox].size.height*2.5);
            [hudLayer addChild: tutorialLabel3];
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
        
        streak=[CCLayerStreak streakWithFade:2 minSeg:3 image:@"streak.png" width:31 length:32 color://ccc4(153,102,0, 255)  //orange
                ccc4(255,255,255, 255) //white
                // ccc4(255,255,0,255) //yellow
                // ccc4(0,0,255,0) //blue
                                      target:player.sprite];
        
        cameraFocusNode = [[CCSprite alloc]init];
        
        killer = 0;
        orbitState = 0; //0= orbiting, 1= just left orbit and deciding things for state 3; 3= flying to next planet
        velSoftener = 1;
        initialAccelMag = 0;
        isOnFirstRun = true;
        timeDilationCoefficient = 1;
        gravIncreaser = 1;
        dangerLevel = 0;
        
        background = [CCSprite spriteWithFile:@"background.pvr.ccz"];
        background.position = ccp(size.width/2+31,19);
        background.scale *=1.3f;
        [self addChild:background];
        
        [self addChild:spaceBackgroundParticle];
        [self addChild:cometParticle];
        cometParticle.position = ccp([self RandomBetween:0 maxvalue:390],325);
        cometVelocity = ccp([self RandomBetween:-10 maxvalue:10]/5,-[self RandomBetween:1 maxvalue:23]/5);
        [self resetVariablesForNewGame];  
        timeSincePlanetExplosion=400000;
        
        [self addChild:cameraLayer];
        [cameraLayer addChild:spriteSheet];
        [self addChild:hudLayer];
        [self UpdateScore];
        
        [Flurry logEvent:@"Played Game" withParameters:nil timed:YES];
        
        [self schedule:@selector(Update:) interval:0]; //this makes the update loop loop!!!!        
	}
	return self;
}

-(void)ZoomLayer:(CCLayer*)layer withScale:(CGFloat)scale toPosition:(CGPoint)position{
    [layer setScale:scale];
    cameraFocusNode.position = ccp(scale*position.x,scale*position.y);
    [cameraFocusNode setPosition:ccpAdd(cameraFocusNode.position, ccp(-((-.5+.5*scale)*size.width),(-(-.5+.5*scale)*size.height)))];
}

- (void)UpdateCamera:(float)dt {
    for (CameraObject *object in cameraObjects) { 
        if (object.alive) {
            object.velocity = ccpAdd(object.velocity, object.acceleration);
            object.sprite.position = ccpAdd(ccpMult(object.velocity, 60*dt*timeDilationCoefficient), object.sprite.position);
            
            /*     if (object.isBeingDrawn == FALSE)
             if (object.hasExploded==FALSE&&CGRectIntersectsRect([object rectOnScreen:cameraLayer], CGRectMake(0, 0, size.width, size.height))) {
             object.sprite.visible=true;
             object.isBeingDrawn = true;
             }
             else {
             object.visible = false;
             object.isBeingDrawn = false;
             }*/
        }
    }
    //camera code follows -----------------------------
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
                
                //CCLOG(@"cur: %f", swipeAccuracy);
                
                
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
                //gravIncreaser += rateToIncreaseGravity;
                
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
                
                
                player.velocity = ccpMult(ccpNormalize(player.velocity), ccpLength(initialVel)*factorToIncreaseVelocityWhenExperiencingRegularGravity);
                
                float scaler = (180/60) - swipeAccuracy / 60 + .5;
                
                float distToUse = ccpLength(ccpSub(player.sprite.position, spotGoingTo));
                //CCLOG(@"swipeAcc: %f, scaler: %f, increaser: %f", swipeAccuracy, scaler, gravIncreaser);
                
                //perhaps dont use scaler/swipe accuracy, and just use it in (if orbitstate=1) for determining if it's good enough. btw scaler ranges from about 1 to 3.5 (now 0 to 2.5)
                player.acceleration = ccpMult(accelToAdd, gravIncreaser*factorToIncreaseVelocityWhenExperiencingRegularGravity*freeGravityStrength*scaler/distToUse - 1);
                
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
    id moveAction = [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:moveDuration position:player.positionAtLastThrust]];
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
        
        CCLOG(@"thrust mag: %f", timeDilationCoefficient);
        
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
    [cameraLayer addChild:blackHoleParticle z:1];
    
    [thrustParticle setPositionType:kCCPositionTypeRelative];
    [cameraLayer addChild:thrustParticle z:2];
    [cameraLayer addChild:streak z:0];
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
    int newScore= ((int)((float)firstToPlayerDistance*cosf(firstToPlayerAngle)));
    if (newScore>prevCurrentPtoPScore)
        currentPtoPscore = newScore;
    [scoreLabel setString:[NSString stringWithFormat:@"Score: %d",score+currentPtoPscore]];
    [zonesReachedLabel setString:[NSString stringWithFormat:@"Zones: %d Time: %1.0fs",zonesReached,totalGameTime]];
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
    if (zonesReached<[planets count])
        totalGameTime+=dt;
    [self UpdatePlanets];    
    [self UpdatePlayer: dt];
    [self UpdateScore];
    [self UpdateCamera:dt];
    [self UpdateParticles:dt];
    [self UpdateBlackhole];
    if (isInTutorialMode)
        [self UpdateTutorial];
}

- (void)endGame {
    [DataStorage storeData];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene: [MainMenuLayer scene]]];
}

- (void)UpdateTutorial {
    tutorialFader+= 3;
    tutorialFader = clampf(tutorialFader, 0, 255);
    [tutorialLabel1 setOpacity:tutorialFader];
    [tutorialLabel2 setOpacity:tutorialFader];
    [tutorialLabel3 setOpacity:tutorialFader];
    if (tutorialState == 0) {
        
        [tutorialLabel1 setString:[NSString stringWithFormat:@"weclome you fucking whore"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"tap to continue the tutorial..."]];
        
    } else if (tutorialState == 1) {
        
        [tutorialLabel1 setString:[NSString stringWithFormat:@"this game is called star dash"]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@"swipe to go to the next planet"]];
        [tutorialLabel3 setString:[NSString stringWithFormat:@"where you swipe matters"]];
        
    } else if (tutorialState == 2) {
        
        [tutorialLabel1 setString:[NSString stringWithFormat:@"glhf"]];
        
    } else if (tutorialState == 3) {
        
        //[self endGame];
        
        [self startGame];
        
        tutorialState++;
        
    }
}

- (void)startGame {
    int plays = [[PlayerStats sharedInstance] totalPlays];
    [[PlayerStats sharedInstance] setTotalPlays:plays + 1];
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
            orbitState = 1;
            targetPlanet = [planets objectAtIndex: (lastPlanetVisited.number + 1)];
        }
        
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {    
    playerIsTouchingScreen = false;
    
    if (isInTutorialMode) {
        tutorialFader = 0;
        tutorialState++;
        [tutorialLabel1 setString:[NSString stringWithFormat:@""]];
        [tutorialLabel2 setString:[NSString stringWithFormat:@""]];
        [tutorialLabel3 setString:[NSString stringWithFormat:@""]];
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