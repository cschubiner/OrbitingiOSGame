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

- (void)CreateCoin:(CGFloat)xPos yPos:(CGFloat)yPos
{
    Coin *coin = [[Coin alloc]init];
    coin.sprite = [CCSprite spriteWithSpriteFrameName:@"asteroid-hd.png"];
    coin.sprite.position = ccp(xPos, yPos);
    [coin.sprite setScale:.3];
    [cameraObjects addObject:coin];
    [coins addObject:coin];
    [spriteSheet addChild:coin.sprite];
    [coin release];
}

- (void)CreateAsteroid:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale
{
    Asteroid *asteroid = [[Asteroid alloc]init];
    asteroid.sprite = [CCSprite spriteWithSpriteFrameName:@"asteroid-hd.png"];
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
    planet.sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"planet%d-hd.png",[self RandomBetween:1 maxvalue:6]]];
    planet.sprite.position =  ccp(xPos, yPos);
    [planet.sprite setScale:scale];
    planet.mass = 1;
    planet.number = planetCounter;
    
    Zone *zone = [[Zone alloc]init];
    zone.sprite = [CCSprite spriteWithSpriteFrameName:@"zone-hd.png"];
    [zone.sprite setScale:scale*zoneScaleRelativeToPlanet];
    zone.number = planetCounter;
    zone.sprite.position = planet.sprite.position;
    
    planet.orbitRadius = zone.radius*.99;
    
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
    [self CreateCoin:600 yPos:300];
    
    [self CreatePlanetAndZone:260 yPos:258 scale:1.01f];
    [self CreatePlanetAndZone:1016 yPos:411 scale:1.13f];
    [self CreatePlanetAndZone:2451 yPos:213 scale:1.49f];
    [self CreatePlanetAndZone:2678 yPos:1506 scale:1.01f];
    [self CreatePlanetAndZone:3740 yPos:1661 scale:1.369999f];
    [self CreatePlanetAndZone:5069 yPos:2456 scale:1.01f];
    [self CreatePlanetAndZone:3639 yPos:2900 scale:1.939999f];
    [self CreatePlanetAndZone:2540 yPos:3653 scale:1.01f];
    [self CreatePlanetAndZone:2086 yPos:4001 scale:1.01f];
    [self CreatePlanetAndZone:1020 yPos:3860 scale:2.719998f];
    [self CreatePlanetAndZone:134 yPos:2772 scale:1.099999f];
    [self CreatePlanetAndZone:-612 yPos:3088 scale:1.1f];
    [self CreatePlanetAndZone:-1332 yPos:2619 scale:1.01f];
    [self CreatePlanetAndZone:-1859 yPos:3184 scale:1.01f];
    [self CreatePlanetAndZone:-2434 yPos:2621 scale:1.07f];
    [self CreatePlanetAndZone:-3378 yPos:2087 scale:1.01f];
    [self CreatePlanetAndZone:-3857 yPos:2854 scale:1.13f];
    [self CreatePlanetAndZone:-3939 yPos:3708 scale:1.069999f];
    [self CreatePlanetAndZone:-3981 yPos:4486 scale:1.01f];
    [self CreatePlanetAndZone:-4781 yPos:5096 scale:1.01f];
    [self CreatePlanetAndZone:-4958 yPos:5945 scale:1.01f];
    [self CreatePlanetAndZone:-3748 yPos:6765 scale:1.249999f];
    [self CreatePlanetAndZone:-4118 yPos:7942 scale:1.01f];
    [self CreatePlanetAndZone:-4986 yPos:8496 scale:1.07f];
    [self CreatePlanetAndZone:-4525 yPos:9011 scale:0.8899996f];
    [self CreatePlanetAndZone:-5285 yPos:9868 scale:2.749998f];
    [self CreatePlanetAndZone:-6666 yPos:11305 scale:1.01f];
    [self CreatePlanetAndZone:-6046 yPos:11939 scale:1.039999f];
    [self CreatePlanetAndZone:-5117 yPos:11975 scale:1.01f];
    [self CreatePlanetAndZone:-3849 yPos:11672 scale:1.01f];
    [self CreatePlanetAndZone:-3129 yPos:12429 scale:1.01f];
    [self CreatePlanetAndZone:-3419 yPos:13320 scale:1.01f];
    [self CreatePlanetAndZone:-4108 yPos:14088 scale:1.339999f];
    [self CreatePlanetAndZone:-3485 yPos:14725 scale:1.01f];
    [self CreatePlanetAndZone:-3458 yPos:16130 scale:1.01f];
    [self CreatePlanetAndZone:-4204 yPos:16893 scale:1.309999f];
    [self CreatePlanetAndZone:-5371 yPos:17859 scale:1.13f];
    [self CreatePlanetAndZone:-4148 yPos:18673 scale:1.16f];
    [self CreatePlanetAndZone:-2845 yPos:19257 scale:1.489999f];
    [self CreatePlanetAndZone:-1423 yPos:19415 scale:1.01f];
    [self CreatePlanetAndZone:-744 yPos:19086 scale:0.8599998f];
    [self CreatePlanetAndZone:-366 yPos:18725 scale:0.7999997f];
    [self CreatePlanetAndZone:351 yPos:18509 scale:1.01f];
    [self CreatePlanetAndZone:-88 yPos:17646 scale:1.01f];
    
    /*
    [self CreatePlanetAndZone:194 yPos:498 scale:0.5f];
    [self CreatePlanetAndZone:551 yPos:715 scale:0.74f];
    [self CreatePlanetAndZone:1099 yPos:817 scale:1.1f];
    [self CreatePlanetAndZone:1407 yPos:400 scale:0.5599999f];
    [self CreatePlanetAndZone:1858 yPos:444 scale:0.5f];
    [self CreatePlanetAndZone:2087 yPos:801 scale:0.5f];
    [self CreatePlanetAndZone:1857 yPos:1192 scale:0.5f];
    [self CreatePlanetAndZone:1549 yPos:1557 scale:1.0045f];
    [self CreatePlanetAndZone:974 yPos:1563 scale:1.028f];
    [self CreatePlanetAndZone:691 yPos:1906 scale:0.5f];
    [self CreatePlanetAndZone:847 yPos:2175 scale:0.5f];
    [self CreatePlanetAndZone:1213 yPos:2164 scale:0.5f];
    [self CreatePlanetAndZone:1549 yPos:2256 scale:0.44f];
    [self CreatePlanetAndZone:1843 yPos:2127 scale:0.5f];
    [self CreatePlanetAndZone:2120 yPos:2002 scale:0.41f];
    [self CreatePlanetAndZone:2163 yPos:1756 scale:0.5f];
    [self CreatePlanetAndZone:2385 yPos:1457 scale:0.5f];
    [self CreatePlanetAndZone:2399 yPos:1170 scale:0.5f];
    [self CreatePlanetAndZone:3341 yPos:865 scale:2.25675f];
    
    [self CreateAsteroid:386 yPos:479 scale:0.2304f];
    [self CreateAsteroid:387 yPos:408 scale:0.2304f];
    [self CreateAsteroid:268 yPos:678 scale:0.2304f];
    [self CreateAsteroid:195 yPos:716 scale:0.2304f];
    [self CreateAsteroid:791 yPos:750 scale:0.5294f];
    [self CreateAsteroid:832 yPos:506 scale:0.2304f];
    [self CreateAsteroid:839 yPos:435 scale:0.2304f];
    [self CreateAsteroid:722 yPos:998 scale:0.2764f];
    [self CreateAsteroid:694 yPos:1081 scale:0.2994f];
    [self CreateAsteroid:1291 yPos:557 scale:0.3684f];
    [self CreateAsteroid:2117 yPos:527 scale:0.3914f];
    [self CreateAsteroid:1858 yPos:676 scale:0.4144f];
    [self CreateAsteroid:2236 yPos:900 scale:0.2764f];
    [self CreateAsteroid:2242 yPos:796 scale:0.2304f];
    [self CreateAsteroid:2243 yPos:721 scale:0.2304f];
    [self CreateAsteroid:1937 yPos:808 scale:0.2304f];
    [self CreateAsteroid:1864 yPos:767 scale:0.2304f];
    [self CreateAsteroid:2102 yPos:1040 scale:0.2764f];
    [self CreateAsteroid:2173 yPos:1075 scale:0.2304f];
    [self CreateAsteroid:1931 yPos:874 scale:0.2304f];
    [self CreateAsteroid:1927 yPos:1323 scale:0.2304f];
    [self CreateAsteroid:1712 yPos:1134 scale:0.2304f];
    [self CreateAsteroid:1689 yPos:1204 scale:0.2304f];
    [self CreateAsteroid:1613 yPos:1235 scale:0.2304f];
    [self CreateAsteroid:1527 yPos:1248 scale:0.2304f];
    [self CreateAsteroid:1464 yPos:1282 scale:0.2304f];
    [self CreateAsteroid:1409 yPos:1335 scale:0.2304f];
    [self CreateAsteroid:1358 yPos:1386 scale:0.2304f];
    [self CreateAsteroid:1846 yPos:1335 scale:0.2304f];
    [self CreateAsteroid:1832 yPos:1403 scale:0.2304f];
    [self CreateAsteroid:1829 yPos:1484 scale:0.2304f];
    [self CreateAsteroid:1823 yPos:1558 scale:0.2304f];
    [self CreateAsteroid:1963 yPos:1473 scale:0.6674f];
    [self CreateAsteroid:1862 yPos:1726 scale:0.9533666f];
    [self CreateAsteroid:1595 yPos:1942 scale:1.151742f];
    [self CreateAsteroid:1692 yPos:1792 scale:0.3224f];
    [self CreateAsteroid:1312 yPos:1852 scale:0.9487666f];
    [self CreateAsteroid:1469 yPos:1814 scale:0.2304f];
    [self CreateAsteroid:1258 yPos:1275 scale:0.709375f];
    [self CreateAsteroid:1092 yPos:1285 scale:0.4144f];
    [self CreateAsteroid:952 yPos:1264 scale:0.50065f];
    [self CreateAsteroid:788 yPos:1307 scale:0.5524f];
    [self CreateAsteroid:673 yPos:1408 scale:0.5524f];
    [self CreateAsteroid:657 yPos:1559 scale:0.5524f];
    [self CreateAsteroid:675 yPos:1684 scale:0.3454f];
    [self CreateAsteroid:1022 yPos:1938 scale:1.069325f];
    [self CreateAsteroid:1265 yPos:1393 scale:0.3224f];
    [self CreateAsteroid:1169 yPos:1358 scale:0.2304f];
    [self CreateAsteroid:1140 yPos:1805 scale:0.2764f];
    [self CreateAsteroid:1408 yPos:2135 scale:0.2304f];
    [self CreateAsteroid:1033 yPos:2249 scale:0.2304f];
    [self CreateAsteroid:1397 yPos:2064 scale:0.2304f];
    [self CreateAsteroid:1313 yPos:2015 scale:0.3914f];
    [self CreateAsteroid:1804 yPos:2411 scale:1.108617f];
    [self CreateAsteroid:1919 yPos:2261 scale:0.2304f];
    [self CreateAsteroid:1977 yPos:2201 scale:0.2304f];
    [self CreateAsteroid:1796 yPos:1976 scale:0.2304f];
    [self CreateAsteroid:1881 yPos:1979 scale:0.2304f];
    [self CreateAsteroid:2116 yPos:2177 scale:0.5709917f];
    [self CreateAsteroid:1989 yPos:1887 scale:0.5849833f];
    [self CreateAsteroid:1834 yPos:1899 scale:0.3914f];
    [self CreateAsteroid:2153 yPos:1311 scale:1.164967f];
    [self CreateAsteroid:2091 yPos:1159 scale:0.2304f];
    [self CreateAsteroid:2157 yPos:1140 scale:0.2304f];
    [self CreateAsteroid:2024 yPos:1624 scale:0.3914f];
    [self CreateAsteroid:1921 yPos:1594 scale:0.2994f];
    [self CreateAsteroid:2756 yPos:829 scale:0.5524f];
    [self CreateAsteroid:2698 yPos:1056 scale:1.087533f];
    [self CreateAsteroid:2590 yPos:1203 scale:0.3914f];
    [self CreateAsteroid:2865 yPos:1171 scale:0.4834f];
    [self CreateAsteroid:2760 yPos:1201 scale:0.2304f];
    [self CreateAsteroid:2683 yPos:1210 scale:0.2304f];
    [self CreateAsteroid:2660 yPos:904 scale:0.2304f];
    [self CreateAsteroid:2793 yPos:927 scale:0.2304f];
    [self CreateAsteroid:2586 yPos:938 scale:0.2304f];
    [self CreateAsteroid:2514 yPos:1078 scale:0.2304f];
    [self CreateAsteroid:2538 yPos:1135 scale:0.2304f];
    [self CreateAsteroid:2523 yPos:996 scale:0.2304f];
    [self CreateAsteroid:2867 yPos:329 scale:0.7364f];
    [self CreateAsteroid:2694 yPos:480 scale:0.815175f];
    [self CreateAsteroid:2499 yPos:633 scale:0.9976417f];
    [self CreateAsteroid:2367 yPos:818 scale:0.6076f];
    [self CreateAsteroid:3095 yPos:217 scale:0.9397583f];
    [self CreateAsteroid:3378 yPos:156 scale:0.8086584f];
    [self CreateAsteroid:3714 yPos:194 scale:1.498275f];
    [self CreateAsteroid:4046 yPos:483 scale:1.7208f];
    [self CreateAsteroid:3876 yPos:742 scale:0.2304f];
    [self CreateAsteroid:4096 yPos:858 scale:1.04115f];
    [self CreateAsteroid:3734 yPos:433 scale:0.5524f];
    [self CreateAsteroid:4015 yPos:1098 scale:1.109767f];
    [self CreateAsteroid:3790 yPos:1379 scale:1.211925f];
    [self CreateAsteroid:3477 yPos:1523 scale:1.072967f];
    [self CreateAsteroid:3081 yPos:1535 scale:1.310442f];
    [self CreateAsteroid:2844 yPos:1391 scale:0.59265f];
    [self CreateAsteroid:2669 yPos:1385 scale:0.5754f];
    [self CreateAsteroid:2584 yPos:1510 scale:0.5064f];
    [self CreateAsteroid:2775 yPos:1526 scale:0.5984f];
    [self CreateAsteroid:2565 yPos:1638 scale:0.3224f];
    [self CreateAsteroid:2098 yPos:1542 scale:0.3684f];
    [self CreateAsteroid:2190 yPos:1469 scale:0.2534f];
    [self CreateAsteroid:2098 yPos:1472 scale:0.2304f];
    [self CreateAsteroid:2478 yPos:1789 scale:0.9627583f];
    [self CreateAsteroid:2447 yPos:2086 scale:1.573408f];
    [self CreateAsteroid:2330 yPos:1899 scale:0.2304f];
    [self CreateAsteroid:2980 yPos:1369 scale:0.2304f];
    [self CreateAsteroid:3299 yPos:1469 scale:0.2304f];
    [self CreateAsteroid:3586 yPos:1410 scale:0.2304f];
    [self CreateAsteroid:3670 yPos:1520 scale:0.2304f];
    [self CreateAsteroid:3862 yPos:1203 scale:0.2304f];
    [self CreateAsteroid:3955 yPos:1267 scale:0.2304f];
    [self CreateAsteroid:3988 yPos:726 scale:0.2304f];
    [self CreateAsteroid:4090 yPos:702 scale:0.2304f];
    [self CreateAsteroid:4253 yPos:670 scale:0.2304f];
    [self CreateAsteroid:3847 yPos:659 scale:0.2304f];
    [self CreateAsteroid:3801 yPos:550 scale:0.2304f];
    [self CreateAsteroid:3466 yPos:271 scale:0.2304f];
    [self CreateAsteroid:3266 yPos:272 scale:0.2304f];
    [self CreateAsteroid:3128 yPos:350 scale:0.2304f];
    [self CreateAsteroid:3357 yPos:319 scale:0.3914f];
    [self CreateAsteroid:3518 yPos:354 scale:0.2304f];
    [self CreateAsteroid:3610 yPos:401 scale:0.2304f];
    */
}

/* On "init," initialize the instance */
- (id) init
{
	// always call "super" init.
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        [self setGameConstants];
        self.isTouchEnabled= TRUE;
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
        spaceBackgroundParticle = [CCParticleSystemQuad particleWithFile:@"spaceParticles.plist"];
        thrustParticle = [CCParticleSystemQuad particleWithFile:@"thrustParticle.plist"];
        blackHoleParticle = [CCParticleSystemQuad particleWithFile:@"blackHoleParticle.plist"];
        [blackHoleParticle setPositionType:kCCPositionTypeGrouped];
        
        scoreLabel = [CCLabelTTF labelWithString:@"Score: " fontName:@"Marker Felt" fontSize:24];
        scoreLabel.position = ccp(400, [scoreLabel boundingBox].size.height);
        [hudLayer addChild: scoreLabel];
        
        zonesReachedLabel = [CCLabelTTF labelWithString:@"Zones Reached: " fontName:@"Marker Felt" fontSize:24];
        zonesReachedLabel.position = ccp(100, [zonesReachedLabel boundingBox].size.height);
        [hudLayer addChild: zonesReachedLabel];
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"phasenwandler_-_Longing_for_Freedom.mp3" loop:YES];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"bomb.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"SWOOSH.wav"];
        
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"spriteSheetCamera.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spriteSheetCamera.plist"];
        
        
        [self CreateLevel];
        
        player = [[Player alloc]init];        
        player.sprite = [CCSprite spriteWithSpriteFrameName:@"spaceship-hd.png"];
        [player.sprite setScale:playerSizeScale];
        [cameraObjects addObject:player];         
        cameraFocusNode = [[CCSprite alloc]init];
        
        killer = 0;
        orbitState = 0; //0= orbiting, 1= just left orbit and deciding things for state 3; 3= flying to next planet
        velSoftener = 1;
        initialAccelMag = 0;
        isOnFirstRun = true;
        timeDilationCoefficient = 1;
        gravIncreaser = 1;
        
        background = [CCSprite spriteWithFile:@"background.pvr.ccz"];
        background.position = ccp(size.width/2+31,19);
        background.scale *=1.3f;
        [self addChild:background];
        
        [self addChild:spaceBackgroundParticle];
        [self addChild:cometParticle];
        cometParticle.position = ccp([self RandomBetween:0 maxvalue:390],325);
        cometVelocity = ccp([self RandomBetween:-10 maxvalue:10]/5,-[self RandomBetween:1 maxvalue:23]/5);
        [self resetVariablesForNewGame];  
        [cameraLayer addChild:planetExplosionParticle];
        
        timeSincePlanetExplosion=400000;
        
        [self addChild:cameraLayer];
        [cameraLayer addChild:spriteSheet];
        [self addChild:hudLayer];
        [self UpdateScore];
        
        [Flurry logEvent:@"Started Game" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:score],@"Score", nil] timed:YES];
        
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

- (void)ApplyGravity:(float)dt {    
    
    for (Coin* coin in coins) {
        CGPoint p = coin.sprite.position;
        if (ccpLength(ccpSub(player.sprite.position, p)) <= coin.radius && coin.isAlive) {
            [[UserWallet sharedInstance] addCoins:1];
            coin.sprite.visible = false;
            coin.isAlive = false;
        }
    }
    
    for (Asteroid* asteroid in asteroids) {        
        CGPoint p = asteroid.sprite.position;
        if (ccpLength(ccpSub(player.sprite.position, p)) <= asteroid.radius * asteroidRadiusCollisionZone) {
            [self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number - 1];
        }
    }
    
    for (Planet* planet in planets)
    {
        if (planet.number == lastPlanetVisited.number) {          
            if (isOnFirstRun) {  
                initialVel = ccp(0, sqrtf(planet.orbitRadius*gravity));
                isOnFirstRun = false;
                player.velocity = initialVel;
            }
            
            if (orbitState == 0) {
                CGPoint a = ccpSub(player.sprite.position, planet.sprite.position);
                if (ccpLength(a) != planet.orbitRadius) {
                    //float offset = planet.orbitRadius/ccpLength(a);
                    //player.sprite.position = ccpAdd(planet.sprite.position, ccpMult(a, offset));
                    player.sprite.position = ccpAdd(player.sprite.position, ccpMult(ccpNormalize(a), (planet.orbitRadius - ccpLength(a))*howFastOrbitPositionGetsFixed));
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
            } else 
                if (orbitState == 1) 
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
                gravIncreaser += rateToIncreaseGravity;
                
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
                CCLOG(@"swipeAcc: %f, scaler: %f, increaser: %f", swipeAccuracy, scaler, gravIncreaser);
                
                //perhaps dont use scaler/swipe accuracy, and just use it in (if orbitstate=1) for determining if it's good enough. btw scaler ranges from about 1 to 3.5
                player.acceleration = ccpMult(accelToAdd, gravIncreaser*factorToIncreaseVelocityWhenExperiencingRegularGravity*freeGravityStrength*scaler/distToUse);
                
                if (initialAccelMag == 0)
                    initialAccelMag = ccpLength(player.acceleration);
                else
                    player.acceleration = ccpMult(ccpNormalize(player.acceleration), initialAccelMag);
            }
            
            if (ccpLength(ccpSub(player.sprite.position, targetPlanet.sprite.position)) <= targetPlanet.orbitRadius) {
                orbitState = 0;
            }
        }
        
        if (ccpLength(ccpSub(player.sprite.position, planet.sprite.position)) <= planet.radius * planetRadiusCollisionZone) {
            [self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number];
        }
        
        if (planet.number >lastPlanetVisited.number)
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

- (void)RespawnPlayerAtPlanetIndex:(int)planetIndex {
    [Flurry logEvent:@"Player Died" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:lastPlanetVisited.number],@"Last planet reached", nil]];
    [self JumpPlayerToPlanet:planetIndex];
}

- (void)UpdatePlayer:(float)dt {
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

- (void)resetVariablesForNewGame {
    [self JumpPlayerToPlanet:0];
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
    [cameraLayer addChild:blackHoleParticle z:3];
    
    [cameraLayer addChild:thrustParticle z:2];
    [spriteSheet addChild:player.sprite z:1];
}

- (void)JumpPlayerToPlanet:(int)planetIndex {
    timeDilationCoefficient *= factorToScaleTimeDilationByOnDeath;
    numZonesHitInARow = 0;
    //CCLOG([NSString stringWithFormat:@"thrust mag:"]);
    CGPoint dir = ccpNormalize(ccpSub(((Planet*)[planets objectAtIndex:planetIndex+1]).sprite.position,((Planet*)[planets objectAtIndex:planetIndex]).sprite.position));
    player.sprite.position = ccpAdd(((Planet*)[planets objectAtIndex:planetIndex]).sprite.position, ccpMult(dir, ((Planet*)[planets objectAtIndex:planetIndex]).orbitRadius));
    player.velocity=CGPointZero;
    player.acceleration=CGPointZero;
    orbitState = 0;
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
        if (zone.number<=lastPlanetVisited.number+1&& ccpDistance([[player sprite]position], [[zone sprite]position])<[zone radius]*.99)
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
                    [TestFlight passCheckpoint:@"Reached All Zones"];
                    [Flurry endTimedEvent:@"Started Game" withParameters:nil];
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
    [thrustParticle setEmissionRate:400];
    
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
}

- (void)endGame {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene: [MainMenuLayer scene]]];
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
        }
    }
    
    if (ccpLength(swipeVector) >= minSwipeStrength && orbitState == 0 && !playerIsTouchingScreen) {
        playerIsTouchingScreen = true;
        orbitState = 1;
        targetPlanet = [planets objectAtIndex: (lastPlanetVisited.number + 1)];
    }
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
    // before we add anything here we should talk about what will be retained vs. released vs. set to nil in certain situations
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