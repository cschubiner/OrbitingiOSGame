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

const float thrustStrength = .004;
const float gravitationalConstant = 3900000;
const float distanceMult = 3;
const float gravitationalDistancePower = 3;
const float reverseGravitationalConstant = 100000000000;
const float reverseDistanceMult = 2.5;
const float reverseGravitationalDistancePower = 5;
const float thrustVelocNormalizerOffset = 1;
const float planetSizeScale = 1.9;
const float velocityDampener = 1;
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
    [planet setMass:pow(planetSizeScale,2)];
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
        
        cameraObjects = [[NSMutableArray alloc]init];
        planets = [[NSMutableArray alloc]init];
        
        
        

        
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
        
        CGPoint reverseDirection;
        reverseDirection = ccpNormalize(ccpSub(player.sprite.position, planet.sprite.position));
        float reverseDistanceBetweenToAPower = pow(reverseDistanceMult*ccpLength(ccpSub(planet.sprite.position, player.sprite.position)), reverseGravitationalDistancePower);
        float reverseGravityMultiplier = (reverseGravitationalConstant * planet.mass * player.mass) /reverseDistanceBetweenToAPower;
        planet.forceExertingOnPlayer = ccp(reverseDirection.x * reverseGravityMultiplier, reverseDirection.y * reverseGravityMultiplier);
        acclerationToAdd = ccpAdd(acclerationToAdd, planet.forceExertingOnPlayer);
    }
    player.acceleration = acclerationToAdd;
    player.velocity = ccp(player.velocity.x * velocityDampener, player.velocity.y * velocityDampener);
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
        player.thrustBeginPoint = location;
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        [player setThrustEndPoint:location];
        
        CGPoint thrustVelocity = ccpAdd(ccp(-player.thrustBeginPoint.x,-player.thrustBeginPoint.y), player.thrustEndPoint);
        thrustVelocity = ccp( thrustVelocity.x* thrustStrength / (ccpLength(player.velocity)+thrustVelocNormalizerOffset),thrustVelocity.y*thrustStrength / (ccpLength(player.velocity)+thrustVelocNormalizerOffset));
        player.velocity = ccpAdd(player.velocity, thrustVelocity);
    }
}

- (int)RandomBetween:(int)minvalue maxvalue:(int)maxvalue  {
    int randomNumber = minvalue+  arc4random() % (1+maxvalue-minvalue);
    return randomNumber;
}
@end
