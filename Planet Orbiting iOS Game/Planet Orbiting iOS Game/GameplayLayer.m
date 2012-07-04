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
#import "Zone.h"
#import "Constants.h"
#import "CCLayerStreak.h"

@implementation GameplayLayer {
    int planetCounter;
    int score;
    int zonesReached;
    int prevScore;
    int initialScoreConstant;
}

typedef struct 
{
    CGPoint velocity;
    CGPoint acceleration;
    CGPoint position;
} VelocityAccelerationPositionStruct;

+ (CCScene *) scene
{
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
    planet.sprite = [CCSprite spriteWithFile:@"PlanetMichael.png"];
    planet.sprite.position =  ccp( xPos , yPos );     
    [planet.sprite setScale:planetSizeScale];
    planet.mass = 1;
    planet.number = planetCounter;
    [cameraObjects addObject:planet];
    [planets addObject:planet];
    [cameraLayer addChild:planet.sprite];        
    [planet release];
    lastPlanetXPos = xPos;
    lastPlanetYPos = yPos;
    
    Zone *zone = [[Zone alloc]init];
    zone.sprite = [CCSprite spriteWithFile:@"zone.png"];
    [zone.sprite setScale:planetSizeScale*zoneScaleRelativeToPlanet];   
    zone.number = planetCounter;
    zone.sprite.position = planet.sprite.position;
    [cameraObjects addObject:zone];
    [zones addObject:zone];
    [cameraLayer addChild:zone.sprite];        
    [zone release];
    
    planetCounter++;
}

- (void)CreatePredPoints
{
    for (int i = 0; i < 15; i++){
        
        PredPoint *predPoint = [[PredPoint alloc]init];
        predPoint.sprite = [CCSprite spriteWithFile:@"point.png"];
        [predPoint.sprite setScale: .4];
        [ [predPoint sprite]setOpacity:((double)(15-i/1.5)/(double)15)*255 ];
        [predPoints addObject:predPoint];
        [cameraLayer addChild:predPoint.sprite];        
        [predPoint release];
    }
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
        zones = [[NSMutableArray alloc]init];
        predPoints = [[NSMutableArray alloc]init];
        hudLayer = [[CCLayer alloc]init];
        cameraLayer = [[CCLayer alloc]init];
        gravityReturner = [[GravityReturnClass alloc]init];
        
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
        [self CreatePlanetAndZone:10 yPos:309];
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
        [self CreatePlanetAndZone:0 yPos:867];
        
        player = [[Player alloc]init];        
        player.sprite = [CCSprite spriteWithFile:@"spaceship.png"];
        [player.sprite setScale:0.6];
        player.sprite.position = ccp(size.width/2, size.height/2);
        player.velocity = CGPointZero;
        player.thrustJustOccurred = false;        
        [cameraObjects addObject:player]; 
        
        [cameraLayer addChild:thrustParticle];
        [self CreatePredPoints]; 
        [cameraLayer addChild:player.sprite];  
        
        cameraFocusNode = [[CCSprite alloc]init];
        
        [self addChild:spaceBackgroundParticle];
        [self addChild:cometParticle];
        cometParticle.position = ccp([self RandomBetween:0 maxvalue:390],325);
        cometVelocity = ccp([self RandomBetween:-10 maxvalue:10]/5,-[self RandomBetween:1 maxvalue:23]/5);
        [self resetVariablesForNewGame];  
        [cameraLayer addChild:planetExplosionParticle];
        
        timeSincePlanetExplosion=400000;
        scaler = 1;
        
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
        object.sprite.position = ccpAdd(object.velocity, object.sprite.position);
    }
    
    Planet * nextPlanet;
    if (lastPlanetVisited.number +1 < [planets count])
        nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number+1)];
    else     nextPlanet = [planets objectAtIndex:(lastPlanetVisited.number-1)];
    
    
    CGPoint focusPosition = ccpMidpoint(lastPlanetVisited.sprite.position, nextPlanet.sprite.position);
    //   focusPosition = ccpMidpoint(focusPosition, player.sprite.position);
    cameraFocusNode.position = ccpLerp(cameraFocusNode.position, focusPosition, .06f);
    CGFloat distanceBetweenPlanets = ccpDistance(lastPlanetVisited.sprite.position, nextPlanet.sprite.position);
    float scale = -0.0011304347826086958*distanceBetweenPlanets+1.218695652173913;
    scale*=.8*.9;
    focusPosition =ccpLerp(cameraLastFocusPosition, focusPosition, .06f);
    [self ZoomLayer:cameraLayer withScale:scale toPosition: focusPosition];
    id followAction = [CCFollow actionWithTarget:cameraFocusNode];
    [cameraLayer runAction: followAction]; 
    cameraLastFocusPosition=focusPosition;
}



- (void)ApplyGravity:(float)dt pos:(CGPoint)position velocity:(CGPoint)velocity acceleration:(CGPoint)acceleration {
    
    CGPoint acclerationToAdd=CGPointZero;
    for (Planet* planet in planets)
    {
        if (planet.alive) {
            CGPoint direction;
            direction = ccpNormalize(ccpSub(planet.sprite.position, position));
            float distanceBetweenToAPower = pow(distanceMult*ccpLength(ccpSub(planet.sprite.position, position)), gravitationalDistancePower);
            float gravityMultiplier = (gravitationalConstant * planet.mass * player.mass) /distanceBetweenToAPower;
            planet.forceExertingOnPlayer = ccp(direction.x * gravityMultiplier, direction.y * gravityMultiplier);
            acclerationToAdd = ccpAdd(acclerationToAdd, planet.forceExertingOnPlayer);
            if (ccpLength(acclerationToAdd)>10)
            {
                //   NSLog(@"1 dubtif q  happening. planet num: %d",planet.ID);
            }
            
            CGPoint reverseForceOnPlayer;
            CGPoint reverseDirection;
            reverseDirection = ccpNormalize(ccpSub(position, planet.sprite.position));
            float reverseDistanceBetweenToAPower = pow(reverseDistanceMult*ccpLength(ccpSub(planet.sprite.position, position)), reverseGravitationalDistancePower);
            float reverseGravityMultiplier = (reverseGravitationalConstant * planet.mass * player.mass) /reverseDistanceBetweenToAPower;
            reverseForceOnPlayer = ccp(reverseDirection.x * reverseGravityMultiplier, reverseDirection.y * reverseGravityMultiplier);
            acclerationToAdd = ccpAdd(acclerationToAdd, reverseForceOnPlayer);
            if (acclerationToAdd.y>20)
            {
                //  NSLog(@"2 dubtif q  happening. planet num: %d",planet.ID);
            }
            if (ccpLength(ccpSub(planet.sprite.position,position)) <= planet.radius*2) {   
                CGPoint l = planet.sprite.position;
                CGPoint p = position;
                CGPoint v = velocity;
                CGPoint a = ccpSub(p, l);
                CGPoint b = ccpSub(ccpAdd(p, v), l);
                float distIn = ccpLength(a)-ccpLength(b);
                CGPoint dir = ccpNormalize(b);
                
                CGPoint dampenerToAdd;
                
                if (ccpLength(velocity) >= 9)
                    velocity = ccpMult(velocity, 1);
                
                
                
                bool condition1 = ccpLength(ccpSub(planet.sprite.position,position)) <= planet.radius*autoOrbitRadius;
                bool condition2 = ccpLength(velocity) <= autoOrbitMaxVelocity;
                if (condition1 && condition2) {
                    //NSLog([NSString stringWithFormat: @"JOK %f", ccpLength(velocity)]);
                    
                    CGPoint dir2 = ccpNormalize(CGPointApplyAffineTransform(a, CGAffineTransformMakeRotation(M_PI/2)));
                    CGPoint dir3 = ccpNormalize(CGPointApplyAffineTransform(a, CGAffineTransformMakeRotation(-M_PI/2)));
                    
                    if (ccpLength(ccpSub(ccpAdd(a, dir2), ccpAdd(a, v))) < ccpLength(ccpSub(ccpAdd(a, dir3), ccpAdd(a, v)))) { //up is closer
                        velocity = ccpAdd(velocity, ccpMult(dir2, autoOrbitEase));
                    }
                    else {
                        velocity = ccpAdd(velocity, ccpMult(dir3, autoOrbitEase));
                    }
                }
                
                dampenerToAdd = ccp(dir.x * distIn * theMagicalConstant / ccpLength(ccpSub(planet.sprite.position, position)), dir.y * distIn * theMagicalConstant / ccpLength(ccpSub(planet.sprite.position, position)));
                
                if (ccpLength(a) < ccpLength(b)) {
                    dampenerToAdd = ccp(dampenerToAdd.x * scaler, dampenerToAdd.y * scaler);
                }
                
                velocity = ccpAdd(velocity, dampenerToAdd);
            }
        }
    }
    scaler += dt * (1/(1-initScaler))*powf((1/secsToScale), 2);
    scaler = clampf(scaler, 0, 1);
    //NSLog([NSString stringWithFormat: @"scaler= %f", scaler]);
    acceleration = ccp(acclerationToAdd.x * absoluteSpeedMult * scaler, acclerationToAdd.y * absoluteSpeedMult * scaler);
    
    gravityReturner.position = position;
    gravityReturner.acceleration = acceleration;
    gravityReturner.velocity= velocity;
    
}

- (void)UpdatePlayer:(float)dt {
    [self ApplyGravity:dt pos:player.sprite.position velocity:player.velocity acceleration:player.acceleration]; 
    player.sprite.position = gravityReturner.position;
    player.velocity = gravityReturner.velocity;
    player.acceleration = gravityReturner.acceleration;
    
    PredPoint *firstPredPoint = [predPoints objectAtIndex:0];
    firstPredPoint.sprite.position = player.sprite.position;
    firstPredPoint.velocity = ccpAdd(player.velocity,futureThrustVelocity);
    firstPredPoint.acceleration = player.acceleration;
    
    int i = 0;
    for (PredPoint* predPoint in predPoints) {                
        if (i > 0) {
            predPoint.sprite.position = ((PredPoint*)[predPoints objectAtIndex:i - 1]).sprite.position;
            predPoint.velocity = ((PredPoint*)[predPoints objectAtIndex:i - 1]).velocity;
            predPoint.acceleration = ((PredPoint*)[predPoints objectAtIndex:i - 1]).acceleration;  
        }
        
        for (int j = 0; j < 4; j++) {
            [self ApplyGravity:dt pos:predPoint.sprite.position velocity:predPoint.velocity acceleration:predPoint.acceleration];
            
            predPoint.sprite.position = gravityReturner.position;
            predPoint.velocity = gravityReturner.velocity;
            predPoint.acceleration = gravityReturner.acceleration;     
            predPoint.velocity = ccpAdd(predPoint.velocity, predPoint.acceleration);
            predPoint.sprite.position = ccpAdd(predPoint.sprite.position, predPoint.velocity);
            predPoint.sprite.rotation = 180+-CC_RADIANS_TO_DEGREES(ccpToAngle(predPoint.velocity));
            
        }
        i++;
    }

    // set the player's velocity when the user just swiped the screen (when player.thrustJustOccurred==true).*/
    if (player.thrustJustOccurred) {
        CGPoint thrustVelocity = ccpAdd(ccp(-player.thrustBeginPoint.x,-player.thrustBeginPoint.y), player.thrustEndPoint);
        thrustVelocity = ccp( thrustVelocity.x* thrustStrength,thrustVelocity.y*thrustStrength);
        //NSLog([NSString stringWithFormat:@"thrust mag: %f",ccpLength(thrustVelocity)]);
        player.velocity = ccpAdd(player.velocity, thrustVelocity);
        
        thrustMag = clampf(ccpLength(thrustVelocity), 0, maxSwipeInput);
        initScaler = minScaler + (1 - minScaler) * ((maxSwipeInput - thrustMag)/maxSwipeInput);
        scaler = initScaler;
        
        player.thrustJustOccurred=false;
    }
    
    if (![self IsPositionOnScreen:[self GetPlayerPositionOnScreen]])//if player is off-screen
    {
        [self JumpPlayerToPlanet:lastPlanetVisited.number];
    }
}

- (void)resetVariablesForNewGame {
    [self JumpPlayerToPlanet:0];
    score=0;
    zonesReached=0;
    totalGameTime = 0 ;
    lastPlanetVisited = [planets objectAtIndex:0];
    timeSinceCometLeftScreen=0;
    timeSincePlanetExplosion=40000;
    prevScore=0;
    
    //this is where the player is on screen (240,160 is center of screen)
    cameraFocusPosition = CGPointMake( 240, 160);
    [player setVelocity:ccp(0,0)];
    justReachedNewPlanet = true;
    
    for (Zone* zone in zones)
    {        
        [cameraLayer removeChild:zone.sprite cleanup:YES];
        [cameraLayer addChild:zone.sprite];
        zone.hasPlayerHitThisZone = false;
        zone.hasExploded=false;
    }
    for (Planet* planet in planets)
    {        
        [cameraLayer removeChild:planet.sprite cleanup:YES];
        [cameraLayer addChild:planet.sprite];
        planet.alive = true;
    }
}

- (void)JumpPlayerToPlanet:(int)planetIndex {
    player.sprite.position = ccpAdd(((Planet*)[planets objectAtIndex:planetIndex]).sprite.position, ccp(130,0));
    player.velocity=CGPointZero;
    player.acceleration=CGPointZero;
    cameraFocusNode.position = ccpAdd(player.sprite.position, ccp(100,0));
    cameraLastFocusPosition = cameraFocusNode.position;
    cameraPositionToFocus = cameraFocusNode.position;
}

- (void)UpdatePlanets {    
    // Zone-to-Player collision detection follows-------------
    player.isInZone = false;
    int i = 0;
    for (Zone* zone in zones)
    {
        float distanceBetweenPlayerAndZone = ccpDistance([[player sprite]position], [[zone sprite]position]);
        if (distanceBetweenPlayerAndZone<[zone radius]*.99)
        {
            player.isInZone = true;
            if (!zone.hasPlayerHitThisZone)
            {
                if (i == 0);
                else if ([[zones objectAtIndex:i - 1]hasPlayerHitThisZone])
                    lastPlanetVisited = [planets objectAtIndex:zone.number];
                [cameraLayer removeChild:zone.sprite cleanup:YES];
                zone.hasPlayerHitThisZone = true;  
                zonesReached++;
                
            }
        }
        else if (distanceBetweenPlayerAndZone>[zone radius]*1.21f){
            if (zone.hasPlayerHitThisZone&&!zone.hasExploded){
                Planet * planet = [planets objectAtIndex:zone.number];
                [cameraLayer removeChild:planet.sprite cleanup:NO];
                planet.alive = false;
                [planetExplosionParticle setPosition:zone.sprite.position];
                [planetExplosionParticle resetSystem];
                zone.hasExploded=true;
                timeSincePlanetExplosion=0;
                planetJustExploded=true;
            }
        }
        
        i += 1;
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
        }
        else {
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
        else if (player.isInZone)
            [player setThrustBeginPoint:location];
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (player.isInZone) {
    CGPoint location;
    for (UITouch *touch in touches) {
        location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
    }
    
    futureThrustVelocity = ccpAdd(ccp(-player.thrustBeginPoint.x,-player.thrustBeginPoint.y), location);
    futureThrustVelocity = ccp( futureThrustVelocity.x* thrustStrength,futureThrustVelocity.y*thrustStrength);
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (player.isInZone) {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        [player setThrustEndPoint:location];
        player.thrustJustOccurred = true;
    }
    futureThrustVelocity=CGPointZero;
    }
}

- (void) scaleLayer:(CCLayer *) yourLayer newScale:(CGFloat) newScale scaleCenter:(CGPoint) scaleCenter {
    // scaleCenter is the point to zoom to.. 
    // If you are doing a pinch zoom, this should be the center of your pinch.
    
    // Get the original center point.
    CGPoint oldCenterPoint = ccp(scaleCenter.x * yourLayer.scale, scaleCenter.y * yourLayer.scale); 
    
    // Set the scale.
    yourLayer.scale = newScale;
    
    // Get the new center point.
    CGPoint newCenterPoint = ccp(scaleCenter.x * yourLayer.scale, scaleCenter.y * yourLayer.scale); 
    
    // Then calculate the delta.
    CGPoint centerPointDelta  = ccpSub(oldCenterPoint, newCenterPoint);
    
    // Now adjust your layer by the delta.
    yourLayer.position = ccpAdd(yourLayer.position, centerPointDelta);
}


double lerpd(double a, double b, double t)
{
    return a + (b - a) * t;
}

float lerpf(float a, float b, float t)
{
    return a + (b - a) * t;
}

- (int)RandomBetween:(int)minvalue maxvalue:(int)maxvalue  {
    int randomNumber = minvalue+  arc4random() % (1+maxvalue-minvalue);
    return randomNumber;
}

-(CGPoint)GetPlayerPositionOnScreen {
    return [cameraLayer convertToWorldSpace:player.sprite.position];
}

-(bool)IsPositionOnScreen:(CGPoint)position{
    return CGRectContainsPoint(CGRectMake(0, 0, size.width, size.height), position);
}
@end