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
    int prevScore;
    int initialScoreConstant;
    float orbitRadius;
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

- (void)CreatePlanetAndZone:(CGFloat)xPos yPos:(CGFloat)yPos
{
    Planet *planet = [[Planet alloc]init];
    planet.sprite = [CCSprite spriteWithFile:@"planet.png"];
    planet.sprite.position =  ccp( xPos , yPos );     
    [planet.sprite setScale:planetSizeScale];
    planet.mass = 1;
    planet.number = planetCounter;
    [cameraObjects addObject:planet];
    [planets addObject:planet];
    [planet release];
    
    Zone *zone = [[Zone alloc]init];
    zone.sprite = [CCSprite spriteWithFile:@"zone.png"];
    [zone.sprite setScale:planetSizeScale*zoneScaleRelativeToPlanet];  
    orbitRadius = zone.radius*.98; 
    zone.number = planetCounter;
    zone.sprite.position = planet.sprite.position;
    [cameraObjects addObject:zone];
    [zones addObject:zone];
    [zone release];
    
    
    if (planetCounter > 1) {
        Planet* previousPlanet = [planets objectAtIndex: planetCounter - 1];
        Asteroid *asteroid = [[Asteroid alloc]init];
        asteroid.sprite = [CCSprite spriteWithFile:@"asteroid.png"];
        CGPoint a = ccpMult(ccpAdd(planet.sprite.position, previousPlanet.sprite.position), .5);
        
        asteroid.velMult = clampf([self randomValueBetween:(minAstVel) andValue:(maxAstVel)], .00001, maxAstVel);
        float hi = [self randomValueBetween:-1 andValue:1];
        CGPoint sub = ccpSub(planet.sprite.position, previousPlanet.sprite.position);
        CGPoint dir = ccpNormalize(CGPointApplyAffineTransform(sub, CGAffineTransformMakeRotation(M_PI/2)));     
        
        asteroid.sprite.position = ccpAdd(a, ccpMult(dir, orbitRadius*hi));
        asteroid.p1 = ccpAdd(a, ccpMult(dir, orbitRadius));
        asteroid.p2 = ccpAdd(a, ccpMult(dir, orbitRadius*-1));
        asteroid.velocity = ccpNormalize(ccpSub(asteroid.p1, asteroid.p2));
        
        [asteroid.sprite setScale:asteroidSizeScale];
        asteroid.number = planetCounter - 1;
        [cameraObjects addObject:asteroid];
        [asteroids addObject:asteroid];
        [asteroid release];
    }
    
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
        
        scoreLabel = [CCLabelTTF labelWithString:@"Score: " fontName:@"Marker Felt" fontSize:24];
        scoreLabel.position = ccp(400, [scoreLabel boundingBox].size.height);
        [hudLayer addChild: scoreLabel];
        
        zonesReachedLabel = [CCLabelTTF labelWithString:@"Zones Reached: " fontName:@"Marker Felt" fontSize:24];
        zonesReachedLabel.position = ccp(100, [zonesReachedLabel boundingBox].size.height);
        [hudLayer addChild: zonesReachedLabel];
        
        [self CreatePlanetAndZone:143 yPos:144];
        [self CreatePlanetAndZone:514 yPos:154];
        [self CreatePlanetAndZone:782 yPos:415];
        [self CreatePlanetAndZone:1041 yPos:677];
        [self CreatePlanetAndZone:958 yPos:1034];
        [self CreatePlanetAndZone:611 yPos:1142];
        [self CreatePlanetAndZone:259 yPos:994];
        [self CreatePlanetAndZone:27 yPos:712];
        [self CreatePlanetAndZone:-347 yPos:702];
        [self CreatePlanetAndZone:-729 yPos:696];
        [self CreatePlanetAndZone:-1020 yPos:947];
        [self CreatePlanetAndZone:-1302 yPos:1215];
        [self CreatePlanetAndZone:-1360 yPos:1567];
        [self CreatePlanetAndZone:-1292 yPos:1917];
        [self CreatePlanetAndZone:-1146 yPos:2242];
        [self CreatePlanetAndZone:-984 yPos:2583];
        [self CreatePlanetAndZone:-851 yPos:2942];
        [self CreatePlanetAndZone:-486 yPos:3018];
        [self CreatePlanetAndZone:-116 yPos:2929];
        [self CreatePlanetAndZone:137 yPos:2638];
        [self CreatePlanetAndZone:315 yPos:2326];
        [self CreatePlanetAndZone:566 yPos:2046];
        [self CreatePlanetAndZone:870 yPos:2186];
        [self CreatePlanetAndZone:1171 yPos:2018];
        [self CreatePlanetAndZone:1025 yPos:1733];
        [self CreatePlanetAndZone:1262 yPos:1463];
        [self CreatePlanetAndZone:1587 yPos:1367];
        [self CreatePlanetAndZone:1808 yPos:1625];
        [self CreatePlanetAndZone:1740 yPos:1958];
        [self CreatePlanetAndZone:1578 yPos:2300];
        [self CreatePlanetAndZone:1363 yPos:2601];
        [self CreatePlanetAndZone:1513 yPos:2935];
        [self CreatePlanetAndZone:1754 yPos:3214];
        [self CreatePlanetAndZone:2075 yPos:3408];
        [self CreatePlanetAndZone:2376 yPos:3200];
        [self CreatePlanetAndZone:2373 yPos:2850];
        [self CreatePlanetAndZone:2080 yPos:2624];
        [self CreatePlanetAndZone:2073 yPos:2295];
        [self CreatePlanetAndZone:2273 yPos:2015];
        [self CreatePlanetAndZone:2418 yPos:1710];
        [self CreatePlanetAndZone:2765 yPos:1597];
        [self CreatePlanetAndZone:3057 yPos:1800];
        [self CreatePlanetAndZone:2900 yPos:2093];
        [self CreatePlanetAndZone:2734 yPos:2402];
        [self CreatePlanetAndZone:3009 yPos:2630];
        [self CreatePlanetAndZone:3361 yPos:2548];
        [self CreatePlanetAndZone:3471 yPos:2215];
        [self CreatePlanetAndZone:3524 yPos:1869];
        [self CreatePlanetAndZone:3525 yPos:1494];
        [self CreatePlanetAndZone:3239 yPos:1275];
        [self CreatePlanetAndZone:3047 yPos:992];
        [self CreatePlanetAndZone:3155 yPos:663];
        [self CreatePlanetAndZone:3402 yPos:390];
        [self CreatePlanetAndZone:3745 yPos:298];
        [self CreatePlanetAndZone:4088 yPos:409];
        [self CreatePlanetAndZone:4340 yPos:688];
        [self CreatePlanetAndZone:4376 yPos:1060];
        [self CreatePlanetAndZone:4169 yPos:1394];
        [self CreatePlanetAndZone:4021 yPos:1709];
        [self CreatePlanetAndZone:4326 yPos:1916];
        [self CreatePlanetAndZone:4698 yPos:1924];
        [self CreatePlanetAndZone:4978 yPos:1692];
        [self CreatePlanetAndZone:5085 yPos:1351];
        [self CreatePlanetAndZone:5002 yPos:1014];
        [self CreatePlanetAndZone:5372 yPos:987];
        [self CreatePlanetAndZone:5637 yPos:1205];
        [self CreatePlanetAndZone:5822 yPos:916];
        [self CreatePlanetAndZone:6043 yPos:1233];
        [self CreatePlanetAndZone:6245 yPos:940];
        [self CreatePlanetAndZone:6441 yPos:1247];
        [self CreatePlanetAndZone:6623 yPos:941];
        [self CreatePlanetAndZone:6814 yPos:1245];
        [self CreatePlanetAndZone:6993 yPos:946];
        [self CreatePlanetAndZone:7218 yPos:1266];
        [self CreatePlanetAndZone:7386 yPos:935];
        [self CreatePlanetAndZone:7577 yPos:1259];
        [self CreatePlanetAndZone:7763 yPos:977];
        [self CreatePlanetAndZone:7935 yPos:1274];
        [self CreatePlanetAndZone:8140 yPos:980];
        [self CreatePlanetAndZone:8303 yPos:1282];
        [self CreatePlanetAndZone:8584 yPos:1077];
        [self CreatePlanetAndZone:8865 yPos:1305];
        [self CreatePlanetAndZone:8786 yPos:1649];
        [self CreatePlanetAndZone:8472 yPos:1817];
        [self CreatePlanetAndZone:8128 yPos:1735];
        [self CreatePlanetAndZone:7779 yPos:1854];
        [self CreatePlanetAndZone:7646 yPos:2169];
        [self CreatePlanetAndZone:7939 yPos:2387];
        [self CreatePlanetAndZone:8263 yPos:2466];
        [self CreatePlanetAndZone:8607 yPos:2459];
        [self CreatePlanetAndZone:8946 yPos:2450];
        [self CreatePlanetAndZone:9257 yPos:2638];
        [self CreatePlanetAndZone:9383 yPos:2959];
        [self CreatePlanetAndZone:9261 yPos:3271];
        [self CreatePlanetAndZone:8917 yPos:3386];
        [self CreatePlanetAndZone:8578 yPos:3250];
        [self CreatePlanetAndZone:8338 yPos:2979];
        [self CreatePlanetAndZone:8018 yPos:2821];
        [self CreatePlanetAndZone:7637 yPos:2781];
        [self CreatePlanetAndZone:7307 yPos:2930];
        [self CreatePlanetAndZone:7079 yPos:3201];
        [self CreatePlanetAndZone:7093 yPos:3528];
        [self CreatePlanetAndZone:7343 yPos:3763];
        [self CreatePlanetAndZone:7673 yPos:3745];
        [self CreatePlanetAndZone:7993 yPos:3827];
        [self CreatePlanetAndZone:8261 yPos:4059];
        
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
        
        [self addChild:spaceBackgroundParticle];
        [self addChild:cometParticle];
        cometParticle.position = ccp([self RandomBetween:0 maxvalue:390],325);
        cometVelocity = ccp([self RandomBetween:-10 maxvalue:10]/5,-[self RandomBetween:1 maxvalue:23]/5);
        [self resetVariablesForNewGame];  
        [cameraLayer addChild:planetExplosionParticle];
        
        timeSincePlanetExplosion=400000;
        
        [self addChild:cameraLayer];
        [self addChild:hudLayer];
        [self UpdateScore:true];
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
    if (lastPlanetVisited.number +1 < [planets count])
        nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number+1)];
    else     nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number-1)];
    
    CGPoint focusPosition;
    Planet* planetForZoom = nextPlanet;
    if (player.isInZone) {
    focusPosition= ccpMidpoint(lastPlanetVisited.sprite.position, nextPlanet.sprite.position);
    focusPosition = ccpLerp(focusPosition, ccpMidpoint(focusPosition, player.sprite.position), .25f) ;
    }
    else {
        focusPosition = ccpMidpoint(player.sprite.position, nextPlanet.sprite.position);
        if (nextPlanet.number +1 < [planets count]) {
            Planet* nextNextPlanet = [planets objectAtIndex:(nextPlanet.number+1)];
            planetForZoom=nextNextPlanet;
            focusPosition = ccpMidpoint(player.sprite.position, nextNextPlanet.sprite.position);
        }
    }
    CGFloat distanceBetweenPlanets = ccpDistance(lastPlanetVisited.sprite.position, planetForZoom.sprite.position);
    float scale =zoomMultiplier*(-0.0011304347826086958*distanceBetweenPlanets+1.218695652173913);
    if (planetForZoom!=nextPlanet)
        scale*=extraOutsideOfZoneZoom;

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
            CGPoint initialVel = ccp(0, sqrtf(orbitRadius*gravity));
            if (isOnFirstRun) {
                isOnFirstRun = false;
                player.velocity = initialVel;
            }
            
            
            if (isOrbiting) {
                
                CGPoint a = ccpSub(player.sprite.position, planet.sprite.position);
                
                if (ccpLength(a) != orbitRadius) {
                    float offset = orbitRadius/ccpLength(a);
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
                    player.acceleration = CGPointZero;
                    //set velocity
                    //player.velocity = ccpMult(swipeVector, .55);
                    CGPoint d = ccpSub(targetPlanet.sprite.position, player.sprite.position);
                    
                    CGPoint dir2 = ccpNormalize(CGPointApplyAffineTransform(d, CGAffineTransformMakeRotation(M_PI/2)));
                    CGPoint dir3 = ccpNormalize(CGPointApplyAffineTransform(d, CGAffineTransformMakeRotation(-M_PI/2)));            
                    
                    
                    CGPoint left = ccpAdd(ccpMult(dir2, orbitRadius), targetPlanet.sprite.position);
                    
                    CGPoint right = ccpAdd(ccpMult(dir3, orbitRadius), targetPlanet.sprite.position);
                    
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
                    CGPoint accelToAdd = ccpMult(direction, gravity);
                    
                    direction = ccpNormalize(ccpSub(targetPlanet.sprite.position, player.sprite.position));
                    accelToAdd = ccpAdd(accelToAdd, ccpMult(direction, gravity));
                    
                    player.acceleration = ccpMult(accelToAdd, initialPercentageOfGravityAfterSwipe * clampf(gravityReducer, 0, 1));
                    
                }
                
                if (ccpLength(ccpSub(player.sprite.position, targetPlanet.sprite.position)) <= orbitRadius) {
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
    if (player.isInZone)
        killer = 0;    
    if (killer > deathAfterThisLong)
        [self JumpPlayerToPlanet:lastPlanetVisited.number];
}

- (void)UpdatePlayer:(float)dt {
    [self ApplyGravity:dt];
    gravityReducer -= rateToDecreaseGravity;
    
    [self KillIfEnoughTimeHasPassed];
    
    // if player is off-screen
    if (![self IsPositionOnScreen:[self GetPlayerPositionOnScreen]]) { 
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
        if (takeoffAngleToNextPlanet-lastAngle2minusptopangle<0) {
            if ((takeoffAngleToNextPlanet<=-270+anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees&&takeoffAngleToNextPlanet>=-360+anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees)||
                (takeoffAngleToNextPlanet>=0-anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees && takeoffAngleToNextPlanet <= 90+anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees)) {
                player.sprite.color = ccc3(0, 255, 0);
                isGreen = true;
            }
            
        } else if ((takeoffAngleToNextPlanet>=270-anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees&&takeoffAngleToNextPlanet<=360+anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees)||
                   (takeoffAngleToNextPlanet >=-90-anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees && takeoffAngleToNextPlanet <=0+anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees)) {
            player.sprite.color = ccc3(0, 255, 0);
            isGreen = true;
        } else {
            if (!playerIsTouchingScreen) {
            } else {
            }
        }
        lastAngle2minusptopangle = takeoffAngleToNextPlanet;
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
    prevScore=0;
    
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
    
    [cameraLayer addChild:thrustParticle];
    [cameraLayer removeChild:player.sprite cleanup:YES];
    [cameraLayer addChild:player.sprite];
}

- (void)JumpPlayerToPlanet:(int)planetIndex {
    timeDilationCoefficient = 1;
    numZonesHitInARow = 0;
    //CCLOG([NSString stringWithFormat:@"thrust mag:"]);
    CGPoint dir = ccpNormalize(ccpSub(((Planet*)[planets objectAtIndex:planetIndex+1]).sprite.position,((Planet*)[planets objectAtIndex:planetIndex]).sprite.position));
    player.sprite.position = ccpAdd(((Planet*)[planets objectAtIndex:planetIndex]).sprite.position, ccpMult(dir, orbitRadius));
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
                
                numZonesHitInARow++;
                timeDilationCoefficient= ((timeDilationLimit-1)*pow(numZonesHitInARow,timeDilationSteepness)/pow((numZonesHitInARow+1),timeDilationSteepness))+1;
                
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
                zone.hasExploded=true;
                timeSincePlanetExplosion=0;
                planetJustExploded=true;
            }
        }
    } // end collision detection code-----------------
}

/* Your score goes up as you move along the vector between the first and last planet. Your score will also never go down, as the user doesn't like to see his score go down. The initialScoreConstant will be set only when firstTimeRunning == true. initialScoreConstant is what ensures your score starts at zero, and not some negative number.*/
- (void)UpdateScore:(bool)firstTimeRunning {
    CGPoint firstToLastPlanet = ccpSub(((Planet*)[planets objectAtIndex:[planets count]-1]).sprite.position, ((Planet*)[planets objectAtIndex:0]).sprite.position);
    CGPoint firstToPlayerPos = ccpSub(((Planet*)[planets objectAtIndex:0]).sprite.position, player.sprite.position);
    CGPoint diff = ccpAdd(firstToLastPlanet, firstToPlayerPos);
    if (firstTimeRunning)
        initialScoreConstant = -(int)((float)ccpLength(firstToLastPlanet)-ccpLength(diff));
    prevScore = score;
    int newScore= (int)((float)ccpLength(firstToLastPlanet)-ccpLength(diff)+initialScoreConstant);
    if (newScore>prevScore)
        score = newScore;
    [scoreLabel setString:[NSString stringWithFormat:@"Score: %d",score]];
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

- (void) Update:(ccTime)dt {
    if (zonesReached<[planets count])
        totalGameTime+=dt;
    [self UpdatePlanets];    
    [self UpdatePlayer: dt];
    [self UpdateScore:false];
    [self UpdateCamera:dt];
    [self UpdateParticles:dt];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        
        if (location.x <= size.width/6 && location.y >= 4*size.height/5) {
            [self resetVariablesForNewGame];
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

- (void) scaleLayer:(CCLayer *) yourLayer newScale:(CGFloat) newScale scaleCenter:(CGPoint) scaleCenter {
    // scaleCenter is the point to zoom to
    // If you are doing a pinch zoom, this should be the center of your pinch
    
    // Get the original center point
    CGPoint oldCenterPoint = ccp(scaleCenter.x * yourLayer.scale, scaleCenter.y * yourLayer.scale); 
    
    // Set the scale
    yourLayer.scale = newScale;
    
    // Get the new center point
    CGPoint newCenterPoint = ccp(scaleCenter.x * yourLayer.scale, scaleCenter.y * yourLayer.scale); 
    
    // Then calculate the delta
    CGPoint centerPointDelta  = ccpSub(oldCenterPoint, newCenterPoint);
    
    // Now adjust your layer by the delta
    yourLayer.position = ccpAdd(yourLayer.position, centerPointDelta);
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

- (bool)IsPositionOnScreen:(CGPoint)position{
    return CGRectContainsPoint(CGRectMake(0, 0, size.width, size.height), position);
}

#if !defined(MIN)
#define MIN(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __a : __b; })
#endif

#if !defined(MAX)
#define MAX(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __b : __a; })
#endif

@end