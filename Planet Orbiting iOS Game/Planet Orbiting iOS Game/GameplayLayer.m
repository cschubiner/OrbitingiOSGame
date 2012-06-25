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

const float thrustStrength = .015;
const float distanceMult = 2;
const float gravitationalConstant = 1000;

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
        

        
        
        
        Planet* planet = [[Planet alloc]init];
        planet.sprite = [CCSprite spriteWithFile:@"PlanetMichael.png"];
        planet.sprite.position =  ccp( 100 , size.height/2 );     
        planet.mass = 1;
        [cameraObjects addObject:planet];
        [planets addObject:planet];
        [self addChild:planet.sprite];        
        [planet release];
        
        Planet* planet2 = [[Planet alloc]init];
        planet2.sprite = [CCSprite spriteWithFile:@"PlanetMichael.png"];
        planet2.sprite.position =  ccp( 400  , size.height/2 );      
        planet2.mass = 1;    
        [cameraObjects addObject:planet2];
        [planets addObject:planet2];
        [self addChild:planet2.sprite];        
        [planet2 release];
        
        
        Planet* planet3 = [[Planet alloc]init];
        planet3.sprite = [CCSprite spriteWithFile:@"PlanetMichael.png"];
        planet3.sprite.position =  ccp( 400  , 500 );      
        planet3.mass = 1;    
        [cameraObjects addObject:planet3];
        [planets addObject:planet3];
        [self addChild:planet3.sprite];        
        [planet3 release];
        
        
        
        Planet* planet4 = [[Planet alloc]init];
        planet4.sprite = [CCSprite spriteWithFile:@"PlanetMichael.png"];
        planet4.sprite.position =  ccp( 300  , 700 );      
        planet4.mass = 1;    
        [cameraObjects addObject:planet4];
        [planets addObject:planet4];
        [self addChild:planet4.sprite];        
        [planet4 release];
        
        
        Planet* planet5 = [[Planet alloc]init];
        planet5.sprite = [CCSprite spriteWithFile:@"PlanetMichael.png"];
        planet5.sprite.position =  ccp( 500  , 950 );      
        planet5.mass = 1;    
        [cameraObjects addObject:planet5];
        [planets addObject:planet5];
        [self addChild:planet5.sprite];        
        [planet5 release];
        
        
        
        
        
        player = [[Player alloc]init];        
        player.sprite = [CCSprite spriteWithFile:@"planet2.png"];
        player.sprite.position = ccp( size.width/2, size.height/2);
        player.velocity = ccp(0, 0);
        player.mass = 1;
        player.thrustJustOccurred = false;        
        [cameraObjects addObject:player];
        [self addChild:player.sprite];
        
        
        
        
        
        [self schedule:@selector(Update:) interval:0]; //this makes the update loop loop1!!!
	}
	return self;
}

- (void)UpdateCameraObjects {
    for (CameraObject *object in cameraObjects) {
        
        object.velocity = ccpAdd(object.velocity, object.acceleration);
        object.sprite.position = ccpAdd(object.velocity, object.sprite.position);
        object.sprite.position = ccpSub(object.sprite.position, player.velocity);
    }
}

- (float)LengthOf:(CGPoint)p1 {
    return sqrt(pow(p1.x, 2) + pow(p1.y, 2));
}

- (void)UpdatePlayer {
    
    
    CGPoint acclerationToAdd;
    for (Planet* planet in planets)
    {
        CGPoint direction;
        direction = ccpNormalize(ccpSub(planet.sprite.position, player.sprite.position));
        float distanceBetweenSquared = pow(distanceMult*[self LengthOf:ccpSub(planet.sprite.position, player.sprite.position)], 2);
        float gravityMultiplier = (gravitationalConstant * planet.mass * player.mass) /distanceBetweenSquared;
        planet.forceExertingOnPlayer = ccp(direction.x * gravityMultiplier, direction.y * gravityMultiplier);
        acclerationToAdd = ccpAdd(acclerationToAdd, planet.forceExertingOnPlayer);
    }
    player.acceleration = acclerationToAdd;

    
    if (player.thrustJustOccurred)
    {
        
        CGPoint thrustVelocity = ccpAdd(ccp(-player.thrustBeginPoint.x,-player.thrustBeginPoint.y), player.thrustEndPoint);
        
        thrustVelocity = ccp( thrustVelocity.x* thrustStrength,thrustVelocity.y*thrustStrength);
        
        player.velocity = ccpAdd(player.velocity, thrustVelocity);
        player.thrustJustOccurred=false;
    }
}

- (void)UpdatePlanets {
    for (Planet* planet in planets)
    {
        //        planet.velocity = ccp(-1, -1);
        //planet.velocity = ccpNormalize(ccp(player.sprite.position.x - planet.sprite.position.x, player.sprite.position.y - planet.sprite.position.y));

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
@end
