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
    planet.sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"planet2.png"]];//@"planet%d.png",[self RandomBetween:1 maxvalue:7]]];
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
    [self CreatePlanetAndZone:157 yPos:113 scale:1];
    [self CreatePlanetAndZone:585 yPos:335 scale:1];
    [self CreatePlanetAndZone:238 yPos:629 scale:1];
    [self CreatePlanetAndZone:632 yPos:856 scale:1];
    [self CreatePlanetAndZone:894 yPos:1098 scale:1];
    [self CreatePlanetAndZone:1346 yPos:852 scale:1];
    [self CreatePlanetAndZone:1513 yPos:1222 scale:1];
    [self CreatePlanetAndZone:1133 yPos:1501 scale:1];
    
    
    [self CreateAsteroid:382 yPos:177 scale:0.5528];
    [self CreateAsteroid:366 yPos:220 scale:0.4608];
    [self CreateAsteroid:1533 yPos:988 scale:0.4608];
    [self CreateAsteroid:1582 yPos:1015 scale:0.4608];
    [self CreateAsteroid:1555 yPos:943 scale:0.4608];
    [self CreateAsteroid:1542 yPos:1044 scale:0.4608];
    
    
    [self CreateCoin:343 yPos:100 scale:0.36];
    [self CreateCoin:397 yPos:119 scale:0.36];
    [self CreateCoin:453 yPos:144 scale:0.36];
    [self CreateCoin:514 yPos:173 scale:0.36];
    [self CreateCoin:506 yPos:505 scale:0.36];
    [self CreateCoin:414 yPos:495 scale:0.36];
    [self CreateCoin:303 yPos:459 scale:0.36];
    [self CreateCoin:420 yPos:413 scale:0.36];
    [self CreateCoin:421 yPos:565 scale:0.36];
    [self CreateCoin:475 yPos:683 scale:0.36];
    [self CreateCoin:430 yPos:733 scale:0.36];
    [self CreateCoin:429 yPos:734 scale:0.36];
    [self CreateCoin:391 yPos:798 scale:0.36];
    [self CreateCoin:364 yPos:833 scale:0.36];
    [self CreateCoin:1019 yPos:1033 scale:0.36];
    [self CreateCoin:1031 yPos:1092 scale:0.36];
    [self CreateCoin:1011 yPos:1173 scale:0.36];
    [self CreateCoin:958 yPos:1226 scale:0.36];
    [self CreateCoin:879 yPos:1241 scale:0.36];
    [self CreateCoin:792 yPos:1199 scale:0.36];
    [self CreateCoin:763 yPos:1133 scale:0.36];
    [self CreateCoin:767 yPos:1043 scale:0.36];
    [self CreateCoin:837 yPos:969 scale:0.36];
    [self CreateCoin:948 yPos:908 scale:0.36];
    [self CreateCoin:1044 yPos:858 scale:0.36];
    [self CreateCoin:1145 yPos:799 scale:0.36];
    [self CreateCoin:810 yPos:838 scale:0.36];
    [self CreateCoin:870 yPos:873 scale:0.36];
    
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
        thrustParticle = [CCParticleSystemQuad particleWithFile:@"thrustParticle2.plist"];
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
        if (ccpLength(ccpSub(player.sprite.position, p)) <= coin.radius + player.sprite.height/1.5 && coin.isAlive) {
            [[UserWallet sharedInstance] addCoins:1];
            coin.sprite.visible = false;
            coin.isAlive = false;
        }
    }
    
    for (Asteroid* asteroid in asteroids) {        
        CGPoint p = asteroid.sprite.position;
        if (ccpLength(ccpSub(player.sprite.position, p)) <= asteroid.radius * asteroidRadiusCollisionZone && orbitState == 3) {
            [self RespawnPlayerAtPlanetIndex:lastPlanetVisited.number - 1];
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
                gravIncreaser += rateToIncreaseGravity;
                
                if (ccpLength(ccpSub(player.sprite.position, planet.sprite.position)) > ccpLength(ccpSub(planet.sprite.position, targetPlanet.sprite.position)))
                    if (ccpLength(ccpSub(ccpAdd(player.sprite.position, player.velocity), targetPlanet.sprite.position)) < ccpLength(ccpSub(planet.sprite.position, targetPlanet.sprite.position)))
                        CCLOG(@"DIFFERNCE Q: %f", ccpLength(ccpSub(player.sprite.position, planet.sprite.position)) - ccpLength(ccpSub(planet.sprite.position, targetPlanet.sprite.position)));
                
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

- (void)RespawnPlayerAtPlanetIndex:(int)planetIndex {
    [Flurry logEvent:@"Player Died" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:lastPlanetVisited.number],@"Last planet reached",[NSNumber numberWithInt:numZonesHitInARow],@"Pre-death combo", nil]];
    [self JumpPlayerToPlanet:planetIndex];
}

- (void)UpdatePlayer:(float)dt {
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
    
    [thrustParticle setPositionType:kCCPositionTypeRelative];
    [cameraLayer addChild:thrustParticle z:2];
    [cameraLayer addChild:streak z:0];
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