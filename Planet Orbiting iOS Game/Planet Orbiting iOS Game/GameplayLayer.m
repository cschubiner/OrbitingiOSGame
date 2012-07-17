//
//  GameplayLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright Stanford University 2012. All rights reserved.

#import "GameplayLayer.h"
#import "CameraObject.h"
#import "Player.h"
#import "Planet.h"
#import "Asteroid.h"
#import "Zone.h"
#import "Constants.h"

@implementation GameplayLayer {
    int planetCounter;
    int score;
    int zonesReached;
    int prevCurrentPtoPScore;
    int initialScoreConstant;
    //float orbitRadius;
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

- (void)CreatePlanetAndZone:(CGFloat)xPos yPos:(CGFloat)yPos scale:(float)scale
{
    Planet *planet = [[Planet alloc]init];
    planet.sprite = [CCSprite spriteWithFile:@"Planet2.png"];
    planet.sprite.position =  ccp( xPos , yPos );     
    [planet.sprite setScale:scale];
    planet.mass = 1;
    planet.number = planetCounter;
    
    Zone *zone = [[Zone alloc]init];
    zone.sprite = [CCSprite spriteWithFile:@"zone.png"];
    [zone.sprite setScale:scale*zoneScaleRelativeToPlanet];
    zone.number = planetCounter;
    zone.sprite.position = planet.sprite.position;
    
    planet.orbitRadius = zone.radius*.98;
    
    if (planetCounter > 1) {
        Planet* previousPlanet = [planets objectAtIndex: planetCounter - 1];
        Asteroid *asteroid = [[Asteroid alloc]init];
        asteroid.sprite = [CCSprite spriteWithFile:@"asteroid.png"];
        CGPoint a = ccpMult(ccpAdd(planet.sprite.position, previousPlanet.sprite.position), .5);
        
        asteroid.velMult = clampf([self randomValueBetween:(minAstVel) andValue:(maxAstVel)], .00001, maxAstVel);
        float hi = [self randomValueBetween:-1 andValue:1];
        CGPoint sub = ccpSub(planet.sprite.position, previousPlanet.sprite.position);
        CGPoint dir = ccpNormalize(CGPointApplyAffineTransform(sub, CGAffineTransformMakeRotation(M_PI/2)));     
        
        asteroid.sprite.position = ccpAdd(a, ccpMult(dir, planet.orbitRadius*hi));
        asteroid.p1 = ccpAdd(a, ccpMult(dir, planet.orbitRadius));
        asteroid.p2 = ccpAdd(a, ccpMult(dir, planet.orbitRadius*-1));
        asteroid.velocity = ccpNormalize(ccpSub(asteroid.p1, asteroid.p2));
        
        [asteroid.sprite setScale:asteroidSizeScale];
        asteroid.number = planetCounter - 1;
        [cameraObjects addObject:asteroid];
        [asteroids addObject:asteroid];
        [asteroid release];
    }
    
    
    
    [cameraObjects addObject:planet];
    [planets addObject:planet];
    [planet release];
    
    [cameraObjects addObject:zone];
    [zones addObject:zone];
    [zone release];
    
    planetCounter++;
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
        
        
[self CreatePlanetAndZone:247 yPos:522 scale:0.49325f];
[self CreatePlanetAndZone:833 yPos:747 scale:0.51f];
[self CreatePlanetAndZone:1302 yPos:1239 scale:0.42f];
[self CreatePlanetAndZone:943 yPos:1611 scale:0.27f];
[self CreatePlanetAndZone:647 yPos:1427 scale:0.21f];
[self CreatePlanetAndZone:264 yPos:1574 scale:0.21f];
[self CreatePlanetAndZone:64 yPos:2110 scale:0.7199998f];
[self CreatePlanetAndZone:289 yPos:2718 scale:0.36f];
[self CreatePlanetAndZone:649 yPos:2946 scale:0.21f];
[self CreatePlanetAndZone:861 yPos:2736 scale:0.21f];
[self CreatePlanetAndZone:898 yPos:2475 scale:0.18f];
[self CreatePlanetAndZone:794 yPos:2226 scale:0.18f];
[self CreatePlanetAndZone:1066 yPos:2104 scale:0.177f];
[self CreatePlanetAndZone:1302 yPos:2210 scale:0.147f];
[self CreatePlanetAndZone:1449 yPos:2467 scale:0.21f];
[self CreatePlanetAndZone:1445 yPos:2820 scale:0.21f];
[self CreatePlanetAndZone:1683 yPos:3047 scale:0.21f];
[self CreatePlanetAndZone:2009 yPos:2919 scale:0.21f];
[self CreatePlanetAndZone:2310 yPos:2601 scale:0.45f];
[self CreatePlanetAndZone:2951 yPos:2856 scale:0.5100001f];
[self CreatePlanetAndZone:4084 yPos:3343 scale:1.14f];
[self CreatePlanetAndZone:4058 yPos:5171 scale:1.309f];
[self CreatePlanetAndZone:4542 yPos:6211 scale:1.02f];
[self CreatePlanetAndZone:5372 yPos:6763 scale:0.8099999f];
[self CreatePlanetAndZone:6227 yPos:7017 scale:0.51f];
[self CreatePlanetAndZone:6967 yPos:6732 scale:0.51f];
[self CreatePlanetAndZone:7373 yPos:7145 scale:0.42f];
[self CreatePlanetAndZone:7100 yPos:7557 scale:0.389f];
[self CreatePlanetAndZone:6632 yPos:7703 scale:0.357f];
[self CreatePlanetAndZone:6281 yPos:8037 scale:0.27f];
[self CreatePlanetAndZone:6582 yPos:8368 scale:0.36f];
[self CreatePlanetAndZone:6206 yPos:8419 scale:0.21f];
[self CreatePlanetAndZone:6177 yPos:8749 scale:0.3f];
[self CreatePlanetAndZone:6508 yPos:9023 scale:0.3f];
[self CreatePlanetAndZone:6504 yPos:9358 scale:0.3f];
[self CreatePlanetAndZone:6504 yPos:9692 scale:0.27f];
[self CreatePlanetAndZone:6204 yPos:9693 scale:0.3f];
[self CreatePlanetAndZone:7135 yPos:9694 scale:0.3f];
[self CreatePlanetAndZone:7353 yPos:9999 scale:0.3f];
[self CreatePlanetAndZone:7651 yPos:10429 scale:0.50175f];
[self CreatePlanetAndZone:6936 yPos:10721 scale:0.9899999f];
[self CreatePlanetAndZone:3925 yPos:12527 scale:6.388251f];
[self CreatePlanetAndZone:3925 yPos:16035 scale:1.3985f];
[self CreatePlanetAndZone:4921 yPos:16759 scale:0.84f];
[self CreatePlanetAndZone:5533 yPos:17327 scale:0.57f];
[self CreatePlanetAndZone:5827 yPos:17883 scale:0.5100001f];
[self CreatePlanetAndZone:5370 yPos:18410 scale:0.6299999f];
[self CreatePlanetAndZone:4793 yPos:18681 scale:0.39f];
[self CreatePlanetAndZone:4370 yPos:18738 scale:0.24f];
[self CreatePlanetAndZone:4249 yPos:18440 scale:0.21f];
[self CreatePlanetAndZone:3944 yPos:18462 scale:0.21f];
[self CreatePlanetAndZone:3798 yPos:18692 scale:0.21f];
[self CreatePlanetAndZone:3917 yPos:18922 scale:0.21f];
[self CreatePlanetAndZone:4106 yPos:19130 scale:0.21f];
[self CreatePlanetAndZone:4422 yPos:19195 scale:0.21f];
[self CreatePlanetAndZone:4779 yPos:19441 scale:0.4962499f];
[self CreatePlanetAndZone:5265 yPos:19086 scale:0.39f];

/*
[self CreateAsteroid:1146 yPos:961 scale:0.2304f];
[self CreateAsteroid:1089 yPos:1017 scale:0.2304f];
[self CreateAsteroid:1027 yPos:1072 scale:0.2304f];
[self CreateAsteroid:1167 yPos:1526 scale:0.2304f];
[self CreateAsteroid:1218 yPos:1568 scale:0.2304f];
[self CreateAsteroid:945 yPos:1362 scale:0.2304f];
[self CreateAsteroid:1002 yPos:1401 scale:0.2304f];
[self CreateAsteroid:416 yPos:1427 scale:0.2304f];
[self CreateAsteroid:111 yPos:1749 scale:0.2304f];
[self CreateAsteroid:177 yPos:1782 scale:0.2304f];
[self CreateAsteroid:254 yPos:1806 scale:0.2304f];
[self CreateAsteroid:440 yPos:2069 scale:0.2304f];
[self CreateAsteroid:426 yPos:2146 scale:0.2304f];
[self CreateAsteroid:-238 yPos:1901 scale:0.2304f];
[self CreateAsteroid:-279 yPos:1968 scale:0.2304f];
[self CreateAsteroid:-306 yPos:2046 scale:0.2304f];
[self CreateAsteroid:-307 yPos:2125 scale:0.2304f];
[self CreateAsteroid:-294 yPos:2204 scale:0.2304f];
[self CreateAsteroid:-271 yPos:2278 scale:0.2304f];
[self CreateAsteroid:134 yPos:2451 scale:0.2304f];
[self CreateAsteroid:214 yPos:2425 scale:0.2304f];
[self CreateAsteroid:1534 yPos:2643 scale:0.2304f];
[self CreateAsteroid:1356 yPos:2650 scale:0.2304f];
[self CreateAsteroid:1540 yPos:2907 scale:0.2304f];
[self CreateAsteroid:1595 yPos:2953 scale:0.2304f];
[self CreateAsteroid:1937 yPos:2705 scale:0.2304f];
[self CreateAsteroid:2076 yPos:2775 scale:0.2304f];
[self CreateAsteroid:2128 yPos:2811 scale:0.2304f];
[self CreateAsteroid:2268 yPos:2933 scale:0.2304f];
[self CreateAsteroid:2707 yPos:2486 scale:0.2304f];
[self CreateAsteroid:2689 yPos:2555 scale:0.2304f];
[self CreateAsteroid:2572 yPos:2840 scale:0.2304f];
[self CreateAsteroid:2548 yPos:2901 scale:0.2304f];
[self CreateAsteroid:2523 yPos:2970 scale:0.2304f];
[self CreateAsteroid:2736 yPos:2412 scale:0.2304f];
[self CreateAsteroid:3410 yPos:3016 scale:1.604267f];
[self CreateAsteroid:4277 yPos:3966 scale:0.9809666f];
[self CreateAsteroid:3884 yPos:3995 scale:1.274408f];
[self CreateAsteroid:4082 yPos:4381 scale:1.775617f];
[self CreateAsteroid:4366 yPos:4551 scale:0.7134f];
[self CreateAsteroid:3733 yPos:4557 scale:0.686375f];
[self CreateAsteroid:4777 yPos:6816 scale:1.421225f];
[self CreateAsteroid:6440 yPos:6604 scale:1.243933f];
[self CreateAsteroid:6712 yPos:7103 scale:1.179533f];
[self CreateAsteroid:7180 yPos:6957 scale:0.6444f];
[self CreateAsteroid:7117 yPos:7091 scale:0.36828f];
[self CreateAsteroid:7121 yPos:7192 scale:0.4144f];
[self CreateAsteroid:7614 yPos:7259 scale:0.4374f];
[self CreateAsteroid:7523 yPos:7343 scale:0.3914f];
[self CreateAsteroid:7413 yPos:7392 scale:0.4604f];
[self CreateAsteroid:6530 yPos:8102 scale:0.5389833f];
[self CreateAsteroid:6121 yPos:8206 scale:0.4834f];
[self CreateAsteroid:6267 yPos:8291 scale:0.3454f];
[self CreateAsteroid:6523 yPos:8605 scale:0.6031917f];
[self CreateAsteroid:6814 yPos:8348 scale:0.4604f];
[self CreateAsteroid:6058 yPos:8394 scale:0.2304f];
[self CreateAsteroid:6042 yPos:8463 scale:0.2994f];
[self CreateAsteroid:6193 yPos:8564 scale:0.2994f];
[self CreateAsteroid:6337 yPos:8893 scale:0.3914f];
[self CreateAsteroid:6696 yPos:9190 scale:0.2304f];
[self CreateAsteroid:6639 yPos:9194 scale:0.2304f];
[self CreateAsteroid:6387 yPos:9189 scale:0.2304f];
[self CreateAsteroid:6319 yPos:9187 scale:0.2304f];
[self CreateAsteroid:6507 yPos:9532 scale:0.2764f];
[self CreateAsteroid:6205 yPos:9522 scale:0.2304f];
[self CreateAsteroid:6104 yPos:9538 scale:0.2994f];
[self CreateAsteroid:6010 yPos:9625 scale:0.3914f];
[self CreateAsteroid:6003 yPos:9734 scale:0.4144f];
[self CreateAsteroid:6061 yPos:9819 scale:0.2994f];
[self CreateAsteroid:6150 yPos:9864 scale:0.2534f];
[self CreateAsteroid:6248 yPos:9864 scale:0.2764f];
[self CreateAsteroid:7136 yPos:9526 scale:0.2534f];
[self CreateAsteroid:7220 yPos:9540 scale:0.2304f];
[self CreateAsteroid:7279 yPos:9597 scale:0.2304f];
[self CreateAsteroid:7309 yPos:9658 scale:0.2304f];
[self CreateAsteroid:7306 yPos:9716 scale:0.2304f];
[self CreateAsteroid:7078 yPos:9864 scale:0.3224f];
[self CreateAsteroid:7548 yPos:10133 scale:0.2304f];
[self CreateAsteroid:7482 yPos:10182 scale:0.2304f];
[self CreateAsteroid:7393 yPos:10385 scale:0.2304f];
[self CreateAsteroid:7388 yPos:10461 scale:0.2304f];
[self CreateAsteroid:7393 yPos:10543 scale:0.3684f];
[self CreateAsteroid:7450 yPos:10607 scale:0.2764f];
[self CreateAsteroid:7514 yPos:10659 scale:0.2994f];
[self CreateAsteroid:7295 yPos:10410 scale:0.2534f];
[self CreateAsteroid:7421 yPos:10683 scale:0.2994f];
[self CreateAsteroid:7328 yPos:10466 scale:0.1844f];
[self CreateAsteroid:7425 yPos:10214 scale:0.2304f];
[self CreateAsteroid:4524 yPos:16492 scale:0.6674f];
[self CreateAsteroid:3900 yPos:16925 scale:1.092325f];
[self CreateAsteroid:5221 yPos:16009 scale:1.530858f];
[self CreateAsteroid:5255 yPos:17102 scale:0.7837417f];
[self CreateAsteroid:5692 yPos:17618 scale:0.4144f];
[self CreateAsteroid:5834 yPos:18271 scale:1.4126f];
[self CreateAsteroid:4092 yPos:18691 scale:1.185283f];
[self CreateAsteroid:4094 yPos:18140 scale:1.573792f];
[self CreateAsteroid:4728 yPos:18205 scale:2.262258f];
[self CreateAsteroid:3522 yPos:18341 scale:2.025358f];
[self CreateAsteroid:3402 yPos:18937 scale:2.205333f];
[self CreateAsteroid:4285 yPos:18962 scale:0.9779f];
[self CreateAsteroid:3781 yPos:19382 scale:2.061967f];
[self CreateAsteroid:4650 yPos:18987 scale:1.1757f];
[self CreateAsteroid:4234 yPos:19316 scale:0.5579584f];
[self CreateAsteroid:4431 yPos:19372 scale:0.48328f];
[self CreateAsteroid:4447 yPos:19516 scale:0.4812917f];
[self CreateAsteroid:4250 yPos:19459 scale:0.5064f];
[self CreateAsteroid:4361 yPos:19446 scale:0.2304f];
[self CreateAsteroid:4330 yPos:19386 scale:0.16128f];
[self CreateAsteroid:4501 yPos:19441 scale:0.2304f];
[self CreateAsteroid:5165 yPos:19263 scale:0.2304f];
[self CreateAsteroid:5241 yPos:19287 scale:0.2304f];
[self CreateAsteroid:5331 yPos:19281 scale:0.2304f];
[self CreateAsteroid:5404 yPos:19245 scale:0.2304f];
[self CreateAsteroid:5458 yPos:19182 scale:0.2304f];
[self CreateAsteroid:5485 yPos:19110 scale:0.2304f];
[self CreateAsteroid:5481 yPos:19035 scale:0.2304f];
[self CreateAsteroid:5581 yPos:18829 scale:1.261758f];
[self CreateAsteroid:5443 yPos:18968 scale:0.2304f];
[self CreateAsteroid:5385 yPos:18917 scale:0.2304f];
[self CreateAsteroid:5309 yPos:18881 scale:0.2304f];
[self CreateAsteroid:5234 yPos:18881 scale:0.2304f];
[self CreateAsteroid:5148 yPos:18904 scale:0.2304f];
[self CreateAsteroid:5082 yPos:18953 scale:0.2304f];
[self CreateAsteroid:5149 yPos:19396 scale:0.6904f];
[self CreateAsteroid:5066 yPos:19518 scale:0.4604f];
[self CreateAsteroid:5417 yPos:19453 scale:1.057442f];
[self CreateAsteroid:5141 yPos:19664 scale:0.8705667f];
[self CreateAsteroid:4853 yPos:19795 scale:1.114175f];
[self CreateAsteroid:4570 yPos:19737 scale:0.7818251f];
[self CreateAsteroid:4707 yPos:19687 scale:0.2304f];
[self CreateAsteroid:4570 yPos:19603 scale:0.2304f];
[self CreateAsteroid:4286 yPos:19679 scale:1.207133f];
[self CreateAsteroid:4101 yPos:19523 scale:0.5294f];
[self CreateAsteroid:5335 yPos:18776 scale:0.4962416f];
[self CreateAsteroid:5206 yPos:18798 scale:0.4604f];
[self CreateAsteroid:5071 yPos:18841 scale:0.3961917f];
[self CreateAsteroid:5013 yPos:18904 scale:0.2304f];
[self CreateAsteroid:5012 yPos:18976 scale:0.2304f];
*/

        
        
        player = [[Player alloc]init];        
        player.sprite = [CCSprite spriteWithFile:@"spaceship.png"];
        [player.sprite setScale:1.2];
        //player.sprite.position = ccp(size.width/2, size.height/2);  
        [cameraObjects addObject:player]; 
        
        cameraFocusNode = [[CCSprite alloc]init];
        
        killer = 0;
        isOnFirstRun = true;
        isOrbiting = true;
        justSwiped = false;
        justBadSwiped = false;
        isExperiencingGravity = false;
        gravityReducer = 1;
        timeDilationCoefficient = 1;
        
        background = [CCSprite spriteWithFile:@"Background1.png"];
        background.position = ccp(background.width/2+10,background.height/2+8);
        background.scale *=1.5f;
        [self addChild:background];
        
        [self addChild:spaceBackgroundParticle];
        [self addChild:cometParticle];
        cometParticle.position = ccp([self RandomBetween:0 maxvalue:390],325);
        cometVelocity = ccp([self RandomBetween:-10 maxvalue:10]/5,-[self RandomBetween:1 maxvalue:23]/5);
        [self resetVariablesForNewGame];  
        [cameraLayer addChild:planetExplosionParticle];
        
        timeSincePlanetExplosion=400000;
        
        [self addChild:cameraLayer];
        [self addChild:hudLayer];
        [self UpdateScore];
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
    }
    
    //camera code follows -----------------------------
    Planet * nextPlanet;
    float distToUse;
    if (lastPlanetVisited.number +1 < [planets count])
        nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number+1)];
    else     nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number-1)];
    
    CGPoint focusPosition;
    Planet* planetForZoom = nextPlanet;
    if (player.isInZone || nextPlanet.number + 1 >= [planets count]) {
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
    
    
    //float scale = zoomMultiplier*(-0.0011304347826086958*distToUse+1.218695652173913);
    //if (planetForZoom!=nextPlanet)
    //    scale*=extraOutsideOfZoneZoom;
    
    float horizontalScale = 294.388933833*pow(distToUse,-.94226344467);
    
    float newAng = 5;
    
    newAng = CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(planetForZoom.sprite.position, focusPosition)));
    
    if (newAng > 270)
        newAng = 360 - newAng;
    if (newAng > 180)
        newAng = newAng - 180;
    if (newAng > 90)
        newAng = 180 - newAng;
    
    //float numerator = 2.40353315418*pow(10,2)+-1.97479367386*pow(10,0)*newAng+2.90416672790*pow(10,-1)*pow(newAng,2)+5.52394514351*pow(10,-2)*pow(newAng,3)+-1.24122580858*pow(10,-2)*pow(newAng,4)+9.07122901758*pow(10,-4)*pow(newAng,5)+-3.13674627681*pow(10,-5)*pow(newAng,6)+5.05890458148*pow(10,-7)*pow(newAng,7)+-2.02095577071*pow(10,-9)*pow(newAng,8)+-2.36509752385*pow(10,-011)*pow(newAng,9)+-5.15090770069*pow(10,-13)*pow(newAng,10)+1.83492501187*pow(10,-14)*pow(newAng,11)+-1.18756307791*pow(10,-16)*pow(newAng,12)+-1.11404850297*pow(10,-18)*pow(newAng,13)+2.39723610522*pow(10,-20)*pow(newAng,14)+-1.61808057124*pow(10,-22)*pow(newAng,15)+-8.05435811652*pow(10,-25)*pow(newAng,16)+2.79703263481*pow(10,-26)*pow(newAng,17)+-2.23685797421*pow(10,-28)*pow(newAng,18)+6.15416673330*pow(10,-31)*pow(newAng,19);
    
    // scale = 400/distToUse;
    
    
    NSMutableArray *vals = [[NSMutableArray alloc] init];
    [vals addObject: [NSNumber numberWithFloat:240]];
    [vals addObject: [NSNumber numberWithFloat:240.5]];
    [vals addObject: [NSNumber numberWithFloat:243]];
    [vals addObject: [NSNumber numberWithFloat:246.5]];
    [vals addObject: [NSNumber numberWithFloat:252]];
    [vals addObject: [NSNumber numberWithFloat:262]];
    [vals addObject: [NSNumber numberWithFloat:273]];
    [vals addObject: [NSNumber numberWithFloat:287]];
    [vals addObject: [NSNumber numberWithFloat:254]];
    [vals addObject: [NSNumber numberWithFloat:231]];
    [vals addObject: [NSNumber numberWithFloat:212]];
    [vals addObject: [NSNumber numberWithFloat:197]];
    [vals addObject: [NSNumber numberWithFloat:185]];
    [vals addObject: [NSNumber numberWithFloat:177]];
    [vals addObject: [NSNumber numberWithFloat:170]];
    [vals addObject: [NSNumber numberWithFloat:165]];
    [vals addObject: [NSNumber numberWithFloat:162]];
    [vals addObject: [NSNumber numberWithFloat:160.5]];
    [vals addObject: [NSNumber numberWithFloat:160]];
    
    
    int indexToUse = (int)clampf((newAng/5 + 0.5), 0, 18);
    
    float numerator = [[vals objectAtIndex:indexToUse] floatValue];
    
    //CCLOG(@"ang: %f, ind: %i, num: %f", newAng, index, numerator);
    
    float scalerToUse = numerator/260;
    
    CCLOG(@"scaler: %f", scalerToUse);
    
    float scale = zoomMultiplier*horizontalScale*scalerToUse;
    
    cameraFocusNode.position = ccpLerp(cameraFocusNode.position, focusPosition, cameraMovementSpeed);
    focusPosition =ccpLerp(cameraLastFocusPosition, focusPosition, cameraMovementSpeed);
    [self ZoomLayer:cameraLayer withScale:lerpf([cameraLayer scale], scale, cameraZoomSpeed) toPosition: focusPosition];
    id followAction = [CCFollow actionWithTarget:cameraFocusNode];
    [cameraLayer runAction: followAction];
    cameraLastFocusPosition=focusPosition;
}

- (void)ApplyGravity:(float)dt {
    
    for (Asteroid* asteroid in asteroids) {
        asteroid.updatesSinceVelChange++;
        
        CGPoint p = asteroid.sprite.position;
        CGPoint one = asteroid.p1;
        CGPoint two = asteroid.p2;
        float dif = ccpLength(ccpSub(one, two));
        
        CGPoint pointToUse = two;
        if (ccpLength(ccpSub(p, one)) < ccpLength(ccpSub(p, two))) 
            pointToUse = one;
        
        asteroid.velocity = ccpMult(ccpNormalize(asteroid.velocity), asteroid.velMult*pow(ccpLength(ccpSub(p, pointToUse)), .3));
        
        if ((ccpLength(ccpSub(p, one)) >= dif || ccpLength(ccpSub(p, two)) >= dif) && asteroid.updatesSinceVelChange >= 15) {
            asteroid.updatesSinceVelChange = 0;
            asteroid.velocity = ccpMult(asteroid.velocity, -1);
        }
        
        if (asteroid.number = lastPlanetVisited.number) {
            if (ccpLength(ccpSub(player.sprite.position, asteroid.sprite.position)) <= asteroid.radius * asteroidRadiusCollisionZone) {
                [self JumpPlayerToPlanet:lastPlanetVisited.number - 1];
            }
        }
    }
    
    for (Planet* planet in planets)
    {
        if (planet.number == lastPlanetVisited.number) {            
            CGPoint initialVel = ccp(0, sqrtf(planet.orbitRadius*gravity));
            if (isOnFirstRun) {
                isOnFirstRun = false;
                player.velocity = initialVel;
            }
            
            if (isOrbiting) {
                CGPoint a = ccpSub(player.sprite.position, planet.sprite.position);
                if (ccpLength(a) != planet.orbitRadius) {
                    float offset = planet.orbitRadius/ccpLength(a);
                    player.sprite.position = ccpAdd(planet.sprite.position, ccpMult(a, offset)); 
                }
                
                CGPoint dir2 = ccpNormalize(CGPointApplyAffineTransform(a, CGAffineTransformMakeRotation(M_PI/2)));
                CGPoint dir3 = ccpNormalize(CGPointApplyAffineTransform(a, CGAffineTransformMakeRotation(-M_PI/2)));            
                if (ccpLength(ccpSub(ccpAdd(a, dir2), ccpAdd(a, player.velocity))) < ccpLength(ccpSub(ccpAdd(a, dir3), ccpAdd(a, player.velocity)))) { //up is closer
                    player.velocity = ccpMult(dir2, ccpLength(initialVel));
                }
                else {
                    player.velocity = ccpMult(dir3, ccpLength(initialVel));
                }
                
                CGPoint direction = ccpNormalize(ccpSub(planet.sprite.position, player.sprite.position));
                player.acceleration = ccpMult(direction, gravity);
            }
            else {
                if (justSwiped) {
                    justSwiped = false;
                    [[SimpleAudioEngine sharedEngine]playEffect:@"SWOOSH.WAV"];
                    player.acceleration = CGPointZero;
                    //set velocity
                    //player.velocity = ccpMult(swipeVector, .55);
                    CGPoint d = ccpSub(targetPlanet.sprite.position, player.sprite.position);
                    
                    CGPoint dir2 = ccpNormalize(CGPointApplyAffineTransform(d, CGAffineTransformMakeRotation(M_PI/2)));
                    CGPoint dir3 = ccpNormalize(CGPointApplyAffineTransform(d, CGAffineTransformMakeRotation(-M_PI/2)));            
                    
                    
                    CGPoint left = ccpAdd(ccpMult(dir2, targetPlanet.orbitRadius), targetPlanet.sprite.position);
                    
                    CGPoint right = ccpAdd(ccpMult(dir3, targetPlanet.orbitRadius), targetPlanet.sprite.position);
                    
                    CGPoint vel = CGPointZero;
                    if (ccpLength(ccpSub(ccpAdd(player.sprite.position, swipeVector), left)) <= ccpLength(ccpSub(ccpAdd(player.sprite.position, swipeVector), right))) { //closer to the left
                        vel = ccpSub(left, player.sprite.position);
                    } else {
                        vel = ccpSub(right, player.sprite.position);
                    }
                    
                    player.velocity = ccpMult(ccpNormalize(vel), ccpLength(player.velocity));
                    
                } else if (justBadSwiped) {
                    justBadSwiped = false;
                    isExperiencingGravity = true;
                    gravityReducer = 1;
                    player.velocity = ccpAdd(player.velocity, ccpMult(swipeVector, swipeStrength));
                }
                if (isExperiencingGravity) {
                    
                    if (ccpLength(ccpSub(player.sprite.position, planet.sprite.position)) <= planet.radius * planetRadiusCollisionZone) {
                        [self JumpPlayerToPlanet:lastPlanetVisited.number];
                    }
                    
                    
                    CGPoint direction = ccpNormalize(ccpSub(planet.sprite.position, player.sprite.position));
                    CGPoint accelToAdd = ccpMult(direction, gravity*planet.sprite.scale);
                    
                    direction = ccpNormalize(ccpSub(targetPlanet.sprite.position, player.sprite.position));
                    accelToAdd = ccpAdd(accelToAdd, ccpMult(direction, gravity*targetPlanet.sprite.scale));
                    
                    player.acceleration = ccpMult(accelToAdd, initialPercentageOfGravityAfterSwipe * clampf(gravityReducer, 0, 1));
                    
                }
                
                if (ccpLength(ccpSub(player.sprite.position, targetPlanet.sprite.position)) <= targetPlanet.orbitRadius) {
                    isOrbiting = true;
                    isExperiencingGravity = false;
                }
                
            }
        }
        if (planet.number >lastPlanetVisited.number)
            break;
    }
}

- (void)KillIfEnoughTimeHasPassed {
    killer++;    
    if (!isExperiencingGravity)
        killer = 0;    
    if (killer > deathAfterThisLong)
        [self JumpPlayerToPlanet:lastPlanetVisited.number];
}

- (void)UpdatePlayer:(float)dt {
    [self ApplyGravity:dt];
    gravityReducer -= rateToDecreaseGravity;
    timeDilationCoefficient -= timeDilationReduceRate;
    
    timeDilationCoefficient = clampf(timeDilationCoefficient, absoluteMinTimeDilation, absoluteMaxTimeDilation);
    
    //CCLOG(@"thrust mag: %f", timeDilationCoefficient);
    
    [self KillIfEnoughTimeHasPassed];
    
    // if player is off-screen
    if (![self IsNonConvertedPositionOnScreen:[self GetPlayerPositionOnScreen]]) { 
        [self JumpPlayerToPlanet:lastPlanetVisited.number];
    }
    
    
    Planet * nextPlanet;
    if (lastPlanetVisited.number +1 < [planets count]) {
        nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number+1)];
    } else {
        nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number-1)];
    }
    
    isGreen = false;
    if (player.isInZone) { //may want to keep on calculating lastAngle... not sure.
        float takeoffAngleToNextPlanet=CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(nextPlanet.sprite.position, lastPlanetVisited.sprite.position)))-CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(player.sprite.position, lastPlanetVisited.sprite.position)));
        
        // if you are going CCW
        if (takeoffAngleToNextPlanet-lastTakeoffAngleToNextPlanet<0) {
            if ((takeoffAngleToNextPlanet<=-270+anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees&&takeoffAngleToNextPlanet>=-360+anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees)||
                (takeoffAngleToNextPlanet>=0-anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees && takeoffAngleToNextPlanet <= 90+anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees)) {
                player.sprite.color = ccc3(0, 255, 0);
                isGreen = true;
            }
            
        } else if ((takeoffAngleToNextPlanet>=270-anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees&&takeoffAngleToNextPlanet<=360+anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees)||
                   (takeoffAngleToNextPlanet >=-90-anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees && takeoffAngleToNextPlanet <=0+anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees)) {
            player.sprite.color = ccc3(0, 255, 0);
            isGreen = true;
        }
        lastTakeoffAngleToNextPlanet = takeoffAngleToNextPlanet;
    } else {
    }
    if (!isGreen)
        player.sprite.color = ccc3(255, 255, 255);
}

- (void)resetVariablesForNewGame {
    [self JumpPlayerToPlanet:0];
    [cameraLayer removeChild:thrustParticle cleanup:NO];
    
    score=0;
    zonesReached=0;
    totalGameTime = 0 ;
    lastPlanetVisited = [planets objectAtIndex:0];
    timeSinceCometLeftScreen=0;
    timeSincePlanetExplosion=40000; //some arbitrarily high number
    prevCurrentPtoPScore=0;
    
    //this is where the player is on screen (240,160 is center of screen)
    cameraFocusPosition = CGPointMake( 240, 160);
    [player setVelocity:ccp(0,0)];
    justReachedNewPlanet = true;
    
    for (Zone* zone in zones) {        
        [cameraLayer removeChild:zone.sprite cleanup:YES];
        zone.hasPlayerHitThisZone = false;
        zone.hasExploded=false;
        [zone.sprite setColor:ccc3(255, 255, 255)];
    }
    
    for (Planet* planet in planets) {        
        planet.alive=false;
        [cameraLayer removeChild:planet.sprite cleanup:YES];
    }
    
    
    for (Asteroid* asteroid in asteroids) {        
        [cameraLayer removeChild:asteroid.sprite cleanup:YES];
        asteroid.alive = true;
    }
    
    for (int i = 0 ; i < 4; i++){
        Planet * planet = [planets objectAtIndex:i];
        Asteroid * asteroid = [asteroids objectAtIndex:i];
        Zone * zone = [zones objectAtIndex:i];
        [cameraLayer addChild:zone.sprite];
        [cameraLayer addChild:planet.sprite];
        [cameraLayer addChild:asteroid.sprite];
        planet.alive = true;
    }
    
    blackHoleParticle.position=ccp(-400,-400);
    [cameraLayer removeChild:blackHoleParticle cleanup:NO];
    [cameraLayer addChild:blackHoleParticle z:3];
    
    [cameraLayer addChild:thrustParticle z:2];
    [cameraLayer removeChild:player.sprite cleanup:YES];
    [cameraLayer addChild:player.sprite z:1];
}

- (void)JumpPlayerToPlanet:(int)planetIndex {
    //timeDilationCoefficient = 1;
    numZonesHitInARow = 0;
    //CCLOG([NSString stringWithFormat:@"thrust mag:"]);
    CGPoint dir = ccpNormalize(ccpSub(((Planet*)[planets objectAtIndex:planetIndex+1]).sprite.position,((Planet*)[planets objectAtIndex:planetIndex]).sprite.position));
    player.sprite.position = ccpAdd(((Planet*)[planets objectAtIndex:planetIndex]).sprite.position, ccpMult(dir, ((Planet*)[planets objectAtIndex:planetIndex]).orbitRadius));
    player.velocity=CGPointZero;
    player.acceleration=CGPointZero;
    isExperiencingGravity = false;
    isOrbiting = true;
    isInAZone = true;
}

- (void)UpdatePlanets {    
    // Zone-to-Player collision detection follows-------------
    player.isInZone = false;
    isInAZone = false;
    
    int zoneCount = zones.count;
    for (int i = MAX(lastPlanetVisited.number-1,0); i < zoneCount;i++)
    {
        Zone * zone = [zones objectAtIndex:i];
        if (zone.number<lastPlanetVisited.number-2)
            continue;
        if (zone.number>lastPlanetVisited.number+1)
            break;
        if (ccpDistance([[player sprite]position], [[zone sprite]position])<[zone radius]*.99)
            isInAZone = true;
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
                
                if (zonesReached+3<zoneCount){
                    [cameraLayer addChild:((Zone*)[zones objectAtIndex:zonesReached+3]).sprite];
                    [cameraLayer addChild:((Planet*)[planets objectAtIndex:zonesReached+3]).sprite];
                    if (zonesReached+5<zoneCount)
                        [cameraLayer addChild:((Asteroid*)[asteroids objectAtIndex:zonesReached+3]).sprite];
                    [cameraLayer reorderChild:player.sprite z:0];
                }
                score+=currentPtoPscore;
                currentPtoPscore=0;
                prevCurrentPtoPScore=0;
                numZonesHitInARow++;
                timeDilationCoefficient += timeDilationIncreaseRate;
                
            }
        }
        else if (i<[zones count]-1&&((Zone*)[zones objectAtIndex:i+1]).hasPlayerHitThisZone) { //if player has hit the next zone and it hasn't exploded yet
            if (zone.hasPlayerHitThisZone&&!zone.hasExploded){
                Planet * planet = [planets objectAtIndex:zone.number];
                [cameraLayer removeChild:planet.sprite cleanup:NO];
                [cameraLayer removeChild:zone.sprite cleanup:YES];
                if (zone.number>2)
                    [cameraLayer removeChild:((Asteroid*)[asteroids objectAtIndex:zone.number-3]).sprite cleanup:YES];
                planet.alive = false;
                [planetExplosionParticle setPosition:zone.sprite.position];
                [planetExplosionParticle resetSystem];
                [[SimpleAudioEngine sharedEngine]playEffect:@"bomb.wav"];
                zone.hasExploded=true;
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
    CCScene* scene = [CCBReader sceneWithNodeGraphFromFile:@"example.ccb"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene: scene]];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        
        if (location.x <= size.width/6 && location.y >= 4*size.height/5) {
            [self endGame];
        }
        else if (player.isInZone) {
            [player setThrustBeginPoint:location];
            playerIsTouchingScreen=true;
        }
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (player.isInZone) {
        CGPoint location;
        for (UITouch *touch in touches) {
            location = [touch locationInView:[touch view]];
            location = [[CCDirector sharedDirector] convertToGL:location];
        }
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {    
    playerIsTouchingScreen = false;
    if (player.isInZone) {
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInView:[touch view]];
            location = [[CCDirector sharedDirector] convertToGL:location];
            [player setThrustEndPoint:location];
            swipeVector = ccpAdd(ccp(-player.thrustBeginPoint.x,-player.thrustBeginPoint.y), player.thrustEndPoint);
        }
    }
    if (ccpLength(swipeVector) >= minSwipeStrength)
        if (isOrbiting) {
            if (isGreen) {
                justSwiped = true;
                isOrbiting = false;
                targetPlanet = [planets objectAtIndex: (lastPlanetVisited.number + 1)];
            } else {
                justBadSwiped = true;
                isOrbiting = false;
                targetPlanet = [planets objectAtIndex: (lastPlanetVisited.number + 1)];
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


#if !defined(MIN)
#define MIN(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __a : __b; })
#endif

#if !defined(MAX)
#define MAX(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __b : __a; })
#endif

@end