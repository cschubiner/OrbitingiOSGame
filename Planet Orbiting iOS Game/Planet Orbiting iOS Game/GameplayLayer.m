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
    lastPlanetXPos = xPos;
    lastPlanetYPos = yPos;
    
    
    
    if (planetCounter > 1) {
        Planet* previousPlanet = [planets objectAtIndex: planetCounter - 1];
        
        
        Asteroid *asteroid = [[Asteroid alloc]init];
        asteroid.sprite = [CCSprite spriteWithFile:@"asteroid.png"];
        CGPoint a = ccpMult(ccpAdd(planet.sprite.position, previousPlanet.sprite.position), .5);
        
        asteroid.velMult = asteroidVelocity * [self randomValueBetween:(1-asteroidVelVar) andValue:(1+asteroidVelVar)];
        //int hi = [self RandomBetween:-1 maxvalue:1];
        float hi2 = [self randomValueBetween:-1 andValue:1];
        CGPoint sub = ccpSub(planet.sprite.position, previousPlanet.sprite.position);
        CGPoint dir = ccpNormalize(CGPointApplyAffineTransform(sub, CGAffineTransformMakeRotation(M_PI/2)));     
        
        asteroid.sprite.position = ccpAdd(a, ccpMult(dir, distToSpawn*hi2));
        asteroid.p1 = ccpAdd(a, ccpMult(dir, distToSpawn));
        asteroid.p2 = ccpAdd(a, ccpMult(dir, distToSpawn*-1));
        asteroid.velocity = ccpNormalize(ccpSub(asteroid.p1, asteroid.p2));
        //asteroid.sprite.position = a;
        
        
        [asteroid.sprite setScale:asteroidSizeScale];
        asteroid.number = planetCounter - 1;
        [cameraObjects addObject:asteroid];
        [asteroids addObject:asteroid];
        [asteroid release];
        
    }
    
    
    
    
    Zone *zone = [[Zone alloc]init];
    zone.sprite = [CCSprite spriteWithFile:@"zone.png"];
    [zone.sprite setScale:planetSizeScale*zoneScaleRelativeToPlanet];   
    zone.number = planetCounter;
    zone.sprite.position = planet.sprite.position;
    [cameraObjects addObject:zone];
    [zones addObject:zone];
    [zone release];
    
    planetCounter++;
}

/*
 On "init," initialize the instance
 */
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
        
        
        
        [self CreatePlanetAndZone:0 yPos:-39];
        [self CreatePlanetAndZone:365 yPos:-36];
        [self CreatePlanetAndZone:676 yPos:182];
        [self CreatePlanetAndZone:973 yPos:489];
        [self CreatePlanetAndZone:1320 yPos:432];
        [self CreatePlanetAndZone:1185 yPos:103];
        [self CreatePlanetAndZone:1563 yPos:-30];
        [self CreatePlanetAndZone:1919 yPos:235];
        [self CreatePlanetAndZone:1919 yPos:639];
        [self CreatePlanetAndZone:1672 yPos:989];
        [self CreatePlanetAndZone:1287 yPos:894];
        [self CreatePlanetAndZone:948 yPos:1040];
        [self CreatePlanetAndZone:590 yPos:836];
        [self CreatePlanetAndZone:380 yPos:528];
        [self CreatePlanetAndZone:0 yPos:574];
        [self CreatePlanetAndZone:64 yPos:903];
        [self CreatePlanetAndZone:356 yPos:1070];
        
        
        
        /*
        [self CreatePlanetAndZone:10 yPos:59];
        [self CreatePlanetAndZone:150 yPos:309];
        [self CreatePlanetAndZone:314 yPos:539];
        [self CreatePlanetAndZone:682 yPos:485];
        [self CreatePlanetAndZone:889 yPos:228];
        [self CreatePlanetAndZone:1115 yPos:101];
        [self CreatePlanetAndZone:1383 yPos:6];
        [self CreatePlanetAndZone:1683 yPos:119];
        [self CreatePlanetAndZone:1847 yPos:380];
        [self CreatePlanetAndZone:1761 yPos:702];
        [self CreatePlanetAndZone:1558 yPos:886];
        [self CreatePlanetAndZone:1303 yPos:998];
        [self CreatePlanetAndZone:1000 yPos:1040];
        [self CreatePlanetAndZone:688 yPos:1040];
        [self CreatePlanetAndZone:436 yPos:963];
        [self CreatePlanetAndZone:199 yPos:1020];
        [self CreatePlanetAndZone:0 yPos:867];*/
        
       
         
        player = [[Player alloc]init];        
        player.sprite = [CCSprite spriteWithFile:@"spaceship.png"];
        [player.sprite setScale:1.2];
        //player.sprite.position = ccp(size.width/2, size.height/2);  
        [cameraObjects addObject:player]; 
        
        cameraFocusNode = [[CCSprite alloc]init];
        
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
    
    Planet * nextPlanet;
    if (lastPlanetVisited.number +1 < [planets count])
        nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number+1)];
    else     nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number-1)];
    
    
    CGPoint focusPosition = ccpMidpoint(lastPlanetVisited.sprite.position, nextPlanet.sprite.position);
    focusPosition = ccpLerp(focusPosition, ccpMidpoint(focusPosition, player.sprite.position), .25f) ;
    cameraFocusNode.position = ccpLerp(cameraFocusNode.position, focusPosition, .06f);
    CGFloat distanceBetweenPlanets = ccpDistance(lastPlanetVisited.sprite.position, nextPlanet.sprite.position);
    float scale =zoomMultiplier*(-0.0011304347826086958*distanceBetweenPlanets+1.218695652173913);
    focusPosition =ccpLerp(cameraLastFocusPosition, focusPosition, .06f);
    [self ZoomLayer:cameraLayer withScale:scale toPosition: focusPosition];
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
        
        
        if (ccpLength(ccpSub(p, one)) < ccpLength(ccpSub(p, two))) {
            asteroid.velocity = ccpMult(ccpNormalize(asteroid.velocity), asteroid.velMult*pow(ccpLength(ccpSub(p, one)), .3));
        } else {
            asteroid.velocity = ccpMult(ccpNormalize(asteroid.velocity), asteroid.velMult*pow(ccpLength(ccpSub(p, two)), .3));
        }
        
        //asteroid.velocity = ccpNormalize(ccpSub(one, two));
        if ((ccpLength(ccpSub(p, one)) >= dif || ccpLength(ccpSub(p, two)) >= dif) && asteroid.updatesSinceVelChange >= 5) {
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
        //if (planet.number == lastPlanetVisited.number + 1)
          //  isOrbiting = true;
        if (planet.number == lastPlanetVisited.number) {
            // if (CGRectContainsRect(CGRectMake(0, 0, size.width, size.height), CGRectMake([cameraLayer convertToWorldSpace:zone.sprite.position].x-zone.sprite.width/2, [cameraLayer convertToWorldSpace:zone.sprite.position].y-zone.sprite.height/2, zone.sprite.width, zone.sprite.height)))
            //if ([self IsPositionOnScreen:[cameraLayer convertToWorldSpace:planet.sprite.position]])
            //{
              //  if (planet.alive) {
            
            
            CGPoint initialVel = ccp(0, sqrtf(distToSpawn*gravity));
            if (isOnFirstRun) {
                isOnFirstRun = false;
                player.velocity = initialVel;
            }
            
            
            if (isOrbiting) {
                
                CGPoint a = ccpSub(player.sprite.position, planet.sprite.position);
                
                if (ccpLength(a) != distToSpawn) {
                    float offset = distToSpawn/ccpLength(a);
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
                
                
                
                /*float distanceBetweenToAPower = pow(distanceMult*ccpLength(ccpSub(planet.sprite.position, player.sprite.position)), gravitationalDistancePower);
                 float gravityMultiplier = (gravitationalConstant * planet.mass * player.mass) /distanceBetweenToAPower;
                 planet.forceExertingOnPlayer = ccp(direction.x * gravityMultiplier, direction.y * gravityMultiplier);
                 accelerationToAdd = ccpAdd(accelerationToAdd, planet.forceExertingOnPlayer);*/
                
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
                    
                    
                    CGPoint left = ccpAdd(ccpMult(dir2, distToSpawn), targetPlanet.sprite.position);
                    
                    CGPoint right = ccpAdd(ccpMult(dir3, distToSpawn), targetPlanet.sprite.position);
                    
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
                    
                    if (ccpLength(player.velocity) <= minimumVelocity) {
                        player.velocity = ccpMult(player.velocity, 1.1);
                    }
                    
                    if (ccpLength(ccpSub(player.sprite.position, planet.sprite.position)) <= planet.radius * planetRadiusCollisionZone) {
                        [self JumpPlayerToPlanet:lastPlanetVisited.number];
                    }
                    
                    
                    CGPoint direction = ccpNormalize(ccpSub(planet.sprite.position, player.sprite.position));
                    CGPoint accelToAdd = ccpMult(direction, gravity);
                    
                    direction = ccpNormalize(ccpSub(targetPlanet.sprite.position, player.sprite.position));
                    accelToAdd = ccpAdd(accelToAdd, ccpMult(direction, gravity));
                    
                    player.acceleration = ccpMult(accelToAdd, initialPercentageOfGravityAfterSwipe * clampf(gravityReducer, 0, 1));
                    
                }
                
                if (ccpLength(ccpSub(player.sprite.position, targetPlanet.sprite.position)) <= distToSpawn) {
                    isOrbiting = true;
                    isExperiencingGravity = false;
                }
                
                
            }
            // }
            //}
        }
    }
    
    //player.acceleration = ccpMult(acclerationToAdd, timeDilationCoefficient);    

    
}

- (void)UpdatePlayer:(float)dt {
    [self ApplyGravity:dt];

    gravityReducer -= rateToDecreaseGravity;
    
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
        [cameraLayer addChild:zone.sprite];
        zone.hasPlayerHitThisZone = false;
        zone.hasExploded=false;
        [zone.sprite setColor:ccc3(255, 255, 255)];
    }
    
    for (Planet* planet in planets) {        
        [cameraLayer removeChild:planet.sprite cleanup:YES];
        [cameraLayer addChild:planet.sprite];
        planet.alive = true;
    }
    
    for (Asteroid* asteroid in asteroids) {        
        [cameraLayer removeChild:asteroid.sprite cleanup:YES];
        [cameraLayer addChild:asteroid.sprite];
        asteroid.alive = true;
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
    player.sprite.position = ccpAdd(((Planet*)[planets objectAtIndex:planetIndex]).sprite.position, ccpMult(dir, distToSpawn));
    player.velocity=CGPointZero;
    player.acceleration=CGPointZero;
    isExperiencingGravity = false;
    isOrbiting = true;
    isInAZone = true;
}

- (void)UpdatePlanets {    
    // Zone-to-Player collision detection follows-------------
    player.isInZone = true;
    isInAZone = false;
    int i = 0;
    for (Zone* zone in zones)
    {
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
                    //isOrbiting = true;
                }
                
                [zone.sprite setColor:ccc3(255, 80, 180)];
                zone.hasPlayerHitThisZone = true;  
                zonesReached++;
                numZonesHitInARow++;
            }
        }
        else if (i<[zones count]-1&&((Zone*)[zones objectAtIndex:i+1]).hasPlayerHitThisZone) { //if player has hit the next zone and it hasn't exploded yet
            if (zone.hasPlayerHitThisZone&&!zone.hasExploded){
                Planet * planet = [planets objectAtIndex:zone.number];
                [cameraLayer removeChild:planet.sprite cleanup:NO];
                [cameraLayer removeChild:zone.sprite cleanup:YES];
                planet.alive = false;
                [planetExplosionParticle setPosition:zone.sprite.position];
                [planetExplosionParticle resetSystem];
                zone.hasExploded=true;
                timeSincePlanetExplosion=0;
                planetJustExploded=true;
            }
        }
        i++;
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
        if (timeSinceCometLeftScreen>4) {
            [cometParticle resetSystem];
            cometParticle.position = ccp([self RandomBetween:0 maxvalue:480],325);
            cometVelocity = ccp([self RandomBetween:-10 maxvalue:10]/5,-[self RandomBetween:5 maxvalue:23]/5);
            timeSinceCometLeftScreen=0;
            [cometParticle setAngle:180+CC_RADIANS_TO_DEGREES(ccpToAngle(cometVelocity))];
        }
    }
    [cometParticle setPosition:ccpAdd(cometParticle.position, cometVelocity)];
    
    if (planetJustExploded) {
        timeSincePlanetExplosion+=dt;
        if (timeSincePlanetExplosion<= durationOfPostExplosionScreenShake) {
            [self setPosition:ccp([self RandomBetween:-6 maxvalue:6],[self RandomBetween:-5 maxvalue:5])];
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
    timeDilationCoefficient= pow(timeDilationPowerFactor,numZonesHitInARow);
    //CCLOG(@"combos: %d time dilation: %f",numZonesHitInARow,timeDilationCoefficient);
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
    if (isExperiencingGravity == false) {
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
    
    playerIsTouchingScreen = false;
    if (player.isInZone) {
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInView:[touch view]];
            location = [[CCDirector sharedDirector] convertToGL:location];
            [player setThrustEndPoint:location];
            swipeVector = ccpAdd(ccp(-player.thrustBeginPoint.x,-player.thrustBeginPoint.y), player.thrustEndPoint);
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

@end