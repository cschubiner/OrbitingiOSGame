//
//  GameplayLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Stanford University. All rights reserved.
//

#import "GameplayLayer.h"
#import "CameraObject.h"
#import "Player.h"
#import "Planet.h"
#import "Constants.h"

CGFloat lastPlanetXPos = 0;
CGFloat lastPlanetYPos = 0;

@implementation GameplayLayer

+(CCScene *) scene
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


- (void)CreatePlanet:(CGFloat)xPos yPos:(CGFloat)yPos
{
    Planet *planet;
    planet = [[Planet alloc]init];
    planet.sprite = [CCSprite spriteWithFile:@"PlanetMichael.png"];
    planet.sprite.position =  ccp( xPos , yPos );     
    [planet.sprite setScale:planetSizeScale];
    planet.mass = 1;
    planet.ID = planetCounter;
    planetCounter += 1;
    [cameraObjects addObject:planet];
    [planets addObject:planet];
    [self addChild:planet.sprite];        
    [planet release];
    lastPlanetXPos = xPos;
    lastPlanetYPos = yPos;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        [self setGameConstants];
        self.isTouchEnabled= TRUE;
        planetCounter = 0;
        cameraObjects = [[NSMutableArray alloc]init];
        planets = [[NSMutableArray alloc]init];
        
        
        label = [CCLabelTTF labelWithString:@"HILOLZ" fontName:@"Marker Felt" fontSize:24];
        label.position = ccp(200, 300);
        [self addChild: label];
        
        label2 = [CCLabelTTF labelWithString:@"HILOLZ" fontName:@"Marker Felt" fontSize:24];
        label2.position = ccp(200, 270);
        [self addChild: label2];        
        
        label3 = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
        label3.position = ccp(200, 240);
        [self addChild: label3];  
        
        label4 = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
        label4.position = ccp(50, 50);
        [self addChild: label4];
        
        
        [self CreatePlanet:100 yPos:size.width/2];
        [self CreatePlanet:lastPlanetXPos+300 yPos:lastPlanetYPos];
        [self CreatePlanet:lastPlanetXPos+200 yPos:lastPlanetYPos+100];
        [self CreatePlanet:lastPlanetXPos+180 yPos:lastPlanetYPos+120];
        [self CreatePlanet:lastPlanetXPos+30 yPos:lastPlanetYPos+230];
        [self CreatePlanet:lastPlanetXPos-150 yPos:lastPlanetYPos+160];
        
        player = [[Player alloc]init];        
        player.sprite = [CCSprite spriteWithFile:@"planet2.png"];
        [player.sprite setScale:1.3];
        player.sprite.position = ccp( size.width/2, size.height/2);
        player.velocity = ccp(0, 0);
        player.thrustJustOccurred = false;        
        [cameraObjects addObject:player];
        [self addChild:player.sprite];
        
        [self JumpPlayerToPlanet:0];    
        
        [self schedule:@selector(Update:) interval:0]; //this makes the update loop loop1!!!
	}
	return self;
}

- (void)UpdateCameraObjects {
    for (CameraObject *object in cameraObjects) {
        
        
        object.velocity = ccpAdd(object.velocity, object.acceleration);
        object.sprite.position = ccpAdd(object.velocity, object.sprite.position);
        object.sprite.position = ccpSub(object.sprite.position, player.velocity); // moves "camera" to follow player
        // e.g. if we want the player to "move" right, everything else will just move to the left and the "camera" will thus follow the player
    }
}


- (void)UpdatePlayer {
    CGPoint acclerationToAdd;
    for (Planet* planet in planets)
    {
        CGPoint direction;
        direction = ccpNormalize(ccpSub(planet.sprite.position, player.sprite.position));
        float distanceBetweenToAPower = pow(distanceMult*ccpLength(ccpSub(planet.sprite.position, player.sprite.position)), gravitationalDistancePower);
        float gravityMultiplier = (gravitationalConstant * planet.mass * player.mass) /distanceBetweenToAPower;
        planet.forceExertingOnPlayer = ccp(direction.x * gravityMultiplier, direction.y * gravityMultiplier);
        acclerationToAdd = ccpAdd(acclerationToAdd, planet.forceExertingOnPlayer);
        
        
        //[label setString: [NSString stringWithFormat: @"%f", planet.ID]];
        
        CGPoint reverseForceOnPlayer;
        CGPoint reverseDirection;
        reverseDirection = ccpNormalize(ccpSub(player.sprite.position, planet.sprite.position));
        float reverseDistanceBetweenToAPower = pow(reverseDistanceMult*ccpLength(ccpSub(planet.sprite.position, player.sprite.position)), reverseGravitationalDistancePower);
        float reverseGravityMultiplier = (reverseGravitationalConstant * planet.mass * player.mass) /reverseDistanceBetweenToAPower;
        reverseForceOnPlayer = ccp(reverseDirection.x * reverseGravityMultiplier, reverseDirection.y * reverseGravityMultiplier);
        acclerationToAdd = ccpAdd(acclerationToAdd, reverseForceOnPlayer);
        
        
        
        if (ccpLength(planet.forceExertingOnPlayer) <= ccpLength(reverseForceOnPlayer)) {   
            
            
            
            CGPoint l = planet.sprite.position;
            CGPoint p = player.sprite.position;
            CGPoint v = player.velocity;
            CGPoint a = ccpSub(p, l);
            CGPoint b = ccpSub(ccpAdd(p, v), l);
            
            float distIn = ccpLength(a)-ccpLength(b);
            
            
            CGPoint dir = ccpNormalize(b);
            CGPoint dampenerToAdd;
            if (ccpLength(a) > ccpLength(b)) {
                dampenerToAdd = ccp(dir.x * distIn * theBestFuckingConstantEver, dir.y *    distIn * theBestFuckingConstantEver);
            }
            else {
                dampenerToAdd = ccp(dir.x * distIn * theBestFuckingConstantEver * theBestConstantComplement, dir.y *    distIn * theBestFuckingConstantEver * theBestConstantComplement);
            }
            
            player.velocity = ccpAdd(player.velocity, dampenerToAdd);
            
            //dont delete this asap of might experiment with it furthur in the future
            //[label4 setString: [NSString stringWithFormat: @"%f", distIn]];
            //player.velocity = ccp(player.velocity.x * (1-(distIn/4)) * velocityDampener, player.velocity.y * (1-(distIn/4)) * velocityDampener);
            
            
        }
        
        
        /*
         if (ccpLength(planet.forceExertingOnPlayer) <= ccpLength(reverseForceOnPlayer)) {
         [label3 setString: [NSString stringWithFormat: @"ja"]];
         
         player.velocity = ccp(player.velocity.x * .8, player.velocity.y * .8);
         }
         else {
         [label3 setString: [NSString stringWithFormat: @""]];
         }*/
    }
    player.acceleration = ccp(acclerationToAdd.x * absoluteSpeedMult, acclerationToAdd.y * absoluteSpeedMult);
    
    if (player.thrustJustOccurred)
    {
        CGPoint thrustVelocity = ccpAdd(ccp(-player.thrustBeginPoint.x,-player.thrustBeginPoint.y), player.thrustEndPoint);
        thrustVelocity = ccp( thrustVelocity.x* thrustStrength,thrustVelocity.y*thrustStrength);
        player.velocity = ccpAdd(player.velocity, thrustVelocity);
        player.thrustJustOccurred=false;
    }
}

-(void)CenterCameraAtPlayer {
    for (CameraObject *object in cameraObjects) {
        object.sprite.position = ccpSub(object.sprite.position, ccpSub(player.sprite.position,ccp( size.width/2, size.height/2)));
    }
}

- (void)JumpPlayerToPlanet:(int)planetIndex {
    player.sprite.position = ccpAdd(((Planet*)[planets objectAtIndex:planetIndex]).sprite.position, ccp(130,0));
    
    [player setVelocity:ccp(0,0)];
    [self CenterCameraAtPlayer];
}

- (void)UpdatePlanets {
    for (Planet* planet in planets)
    {
        /* //RECTANGULAR PLAYER DISTANCE CALCULATOR
         if (ccpDistance(ccp([[player sprite]width]/2+[player sprite].position.x,[[player sprite]height]/2+[player sprite].position.y),planet.       sprite.position)<[planet radius]       ||
         ccpDistance(ccp([[player sprite]width]/2+[player sprite].position.x,-[[player sprite]height]/2+[player sprite].position.y),planet.sprite.position)<[planet radius]   ||
         ccpDistance(ccp(-[[player sprite]width]/2+[player sprite].position.x,[[player sprite]height]/2+[player sprite].position.y),planet.sprite.position)<[planet radius]   ||
         ccpDistance(ccp(-[[player sprite]width]/2+[player sprite].position.x,-[[player sprite]height]/2+[player sprite].position.y),planet.sprite.position)<[planet radius])*/
        if (ccpDistance([[player sprite]position], [[planet sprite]position])<[planet radius])
        {
            [self JumpPlayerToPlanet:0];
        }
        
        
    }
}

- (void) Update:(ccTime)dt {
    
    
    [self UpdatePlanets];    
    [self UpdatePlayer];
    [self UpdateCameraObjects];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        [player setThrustBeginPoint:location];
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        [player setThrustEndPoint:location];
        player.thrustJustOccurred = true;
    }
}


- (int)RandomBetween:(int)minvalue maxvalue:(int)maxvalue  {
    int randomNumber = minvalue+  arc4random() % (1+maxvalue-minvalue);
    return randomNumber;
}

/*
 BELOW IS CONSTANT VELOCITY ADDING CODE
 -(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
 {
 for (UITouch *touch in touches)
 {
 CGPoint location = [touch locationInView:[touch view]];
 location = [[CCDirector sharedDirector] convertToGL:location];
 player.thrustBeginPoint = location;
 }
 }
 
 -(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
 {
 for (UITouch *touch in touches)
 {
 CGPoint location = [touch locationInView:[touch view]];
 location = [[CCDirector sharedDirector] convertToGL:location];
 [player setThrustEndPoint:location]; //this sets the end point. love, alex mark
 
 CGPoint thrustVelocity = ccpAdd(ccp(-player.thrustBeginPoint.x,-player.thrustBeginPoint.y), player.thrustEndPoint);
 thrustVelocity = ccp( thrustVelocity.x* thrustStrength, thrustVelocity.y*thrustStrength);
 player.velocity = ccpAdd(player.velocity, thrustVelocity);
 }
 }*/
@end