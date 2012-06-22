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

static float thrustStrength = .015;

@implementation GameplayLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameplayLayer *layer = [GameplayLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void)setGameConstants
{
    size = [[CCDirector sharedDirector] winSize];
    
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        self.isTouchEnabled= TRUE;
        // ask director the the window size
        cameraObjects = [[NSMutableArray alloc]init];
        player = [[Player alloc]init];
        [self setGameConstants];
        
        player.sprite = [CCSprite spriteWithFile:@"spaceship.png"];
        player.sprite.position =  ccp( size.width /2 , size.height/2 );
        player.thrustJustOccurred = false;
        
        [cameraObjects addObject:player];
        [self addChild:player.sprite];
        
        Planet* planet = [[Planet alloc]init];
        //alex b, do some stuff to load the planet's sprite (planet2.png)
        //set planet's position
        //OMG TRY TO DO IT WITHOUT COPYING AND PASTING--- what a nice exercise!!

        [cameraObjects addObject:planet];
        [planet release];
        
        

        
        [self schedule:@selector(Update:) interval:0]; //this makes the update loop loop1!!!
	}
	return self;
}

- (void)UpdateCameraObjects {
    for (CameraObject *object in cameraObjects) {
        object.velocity = ccpAdd(object.velocity, object.acceleration);
        object.sprite.position = ccpAdd(object.velocity, object.sprite.position);
    }
}

- (void)UpdatePlayer {
    if (player.thrustJustOccurred)
    {
        CGPoint thrustVelocity = ccpAdd(ccp(-player.thrustBeginPoint.x,-player.thrustBeginPoint.y), player.thrustEndPoint);
        
        thrustVelocity = ccp( thrustVelocity.x* thrustStrength,thrustVelocity.y*thrustStrength);
        
        
        player.velocity = ccpAdd(player.velocity, thrustVelocity);
        player.thrustJustOccurred=false;
    }
}

- (void) Update:(ccTime)dt {
    
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
    int randomNumber =                minvalue+  arc4random() % (1+maxvalue-minvalue);
    return randomNumber;
}
@end
