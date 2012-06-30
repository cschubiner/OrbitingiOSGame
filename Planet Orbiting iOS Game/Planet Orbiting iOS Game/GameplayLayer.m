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
    planet.ID = planetCounter;
    [cameraObjects addObject:planet];
    [planets addObject:planet];
    [cameraLayer addChild:planet.sprite];        
    [planet release];
    lastPlanetXPos = xPos;
    lastPlanetYPos = yPos;
    
    Zone *zone = [[Zone alloc]init];
    zone.sprite = [CCSprite spriteWithFile:@"zone.png"];
    [zone.sprite setScale:planetSizeScale*zoneScaleRelativeToPlanet];   
    zone.ID = planetCounter;
    zone.sprite.position = planet.sprite.position;
    [cameraObjects addObject:zone];
    [zones addObject:zone];
    [cameraLayer addChild:zone.sprite];        
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
        zones = [[NSMutableArray alloc]init];
        hudLayer = [[CCLayer alloc]init];
        cameraLayer = [[CCLayer alloc]init];
        
        scoreLabel = [CCLabelTTF labelWithString:@"Score: " fontName:@"Marker Felt" fontSize:24];
        scoreLabel.position = ccp(400, [scoreLabel boundingBox].size.height);
        [hudLayer addChild: scoreLabel];
        
        zonesReachedLabel = [CCLabelTTF labelWithString:@"Zones Reached: " fontName:@"Marker Felt" fontSize:24];
        zonesReachedLabel.position = ccp(100, [zonesReachedLabel boundingBox].size.height);
        [hudLayer addChild: zonesReachedLabel];
        
        [self CreatePlanetAndZone:100*1.5 yPos:size.width/2];
        [self CreatePlanetAndZone:lastPlanetXPos+300*1.5 yPos:lastPlanetYPos];
        [self CreatePlanetAndZone:lastPlanetXPos+200*1.5 yPos:lastPlanetYPos+100*1.5];
        [self CreatePlanetAndZone:lastPlanetXPos+180*1.5 yPos:lastPlanetYPos+120*1.5];
        [self CreatePlanetAndZone:lastPlanetXPos+30*1.5 yPos:lastPlanetYPos+230*1.5];
        [self CreatePlanetAndZone:lastPlanetXPos-150*1.5 yPos:lastPlanetYPos+160*1.5];
        
        player = [[Player alloc]init];        
        player.sprite = [CCSprite spriteWithFile:@"planet2.png"];
        [player.sprite setScale:1.3];
        player.sprite.position = ccp(size.width/2, size.height/2);
        player.velocity = CGPointZero;
        player.streak = [CCLayerStreak streakWithFade:2 minSeg:3 image:@"streak.png" width:16 length:32 color:ccc4(0,0,255, 255) target:player.sprite];
        [cameraLayer addChild:player.streak];

        player.thrustJustOccurred = false;        
        [cameraObjects addObject:player];
        [cameraLayer addChild:player.sprite];
        
        arrow = [[Arrow alloc] init];
        arrow.velocity = player.velocity;
        arrow.acceleration = player.acceleration;
        arrow.sprite = [CCSprite spriteWithFile:@"arrowBest.png"];
        arrow.sprite.visible = NO;
        [cameraObjects addObject:arrow];
        [cameraLayer addChild:arrow.sprite];
        
        CCSprite *background = [CCSprite spriteWithFile:@"space_background.png"];
        [self addChild: background]; 
        background.position = ccp(0,0);
        
        id followAction = [CCFollow actionWithTarget:player.sprite];
        [cameraLayer runAction: followAction];
        
        [self JumpPlayerToPlanet:0];    
        
        [self addChild:cameraLayer];
        [self addChild:hudLayer];
        [self UpdateScore:true];
        [self schedule:@selector(Update:) interval:0]; //this makes the update loop loop!!!!
        
        
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
    CGPoint acclerationToAdd;
    for (Planet* planet in planets)
    {
        CGPoint direction;
        direction = ccpNormalize(ccpSub(planet.sprite.position, player.sprite.position));
        float distanceBetweenToAPower = pow(distanceMult*ccpLength(ccpSub(planet.sprite.position, player.sprite.position)), gravitationalDistancePower);
        float gravityMultiplier = (gravitationalConstant * planet.mass * player.mass) /distanceBetweenToAPower;
        planet.forceExertingOnPlayer = ccp(direction.x * gravityMultiplier, direction.y * gravityMultiplier);
        acclerationToAdd = ccpAdd(acclerationToAdd, planet.forceExertingOnPlayer);
        
        
        CGPoint reverseForceOnPlayer;
        CGPoint reverseDirection;
        reverseDirection = ccpNormalize(ccpSub(player.sprite.position, planet.sprite.position));
        float reverseDistanceBetweenToAPower = pow(reverseDistanceMult*ccpLength(ccpSub(planet.sprite.position, player.sprite.position)), reverseGravitationalDistancePower);
        float reverseGravityMultiplier = (reverseGravitationalConstant * planet.mass * player.mass) /reverseDistanceBetweenToAPower;
        reverseForceOnPlayer = ccp(reverseDirection.x * reverseGravityMultiplier, reverseDirection.y * reverseGravityMultiplier);
        acclerationToAdd = ccpAdd(acclerationToAdd, reverseForceOnPlayer);
        
        
        if (ccpLength(ccpSub(planet.sprite.position,player.sprite.position)) <= planet.radius*2) {   
            CGPoint l = planet.sprite.position;
            CGPoint p = player.sprite.position;
            CGPoint v = player.velocity;
            CGPoint a = ccpSub(p, l);
            CGPoint b = ccpSub(ccpAdd(p, v), l);
            float distIn = ccpLength(a)-ccpLength(b);
            CGPoint dir = ccpNormalize(b);
            CGPoint dampenerToAdd;
            //if (ccpLength(a) > ccpLength(b)) {
            //    dampenerToAdd = ccp(dir.x * distIn * theBestFuckingConstantEver, dir.y * distIn * theBestFuckingConstantEver);
            //}
            //else {
                dampenerToAdd = ccp(dir.x * distIn * theBestFuckingConstantEver / (1*ccpLength(ccpSub(planet.sprite.position, player.sprite.position))), dir.y * distIn * theBestFuckingConstantEver / (1*ccpLength(ccpSub(planet.sprite.position, player.sprite.position))));
            //}
            
            player.velocity = ccpAdd(player.velocity, dampenerToAdd);
        }
    }
    player.acceleration = ccp(acclerationToAdd.x * absoluteSpeedMult, acclerationToAdd.y * absoluteSpeedMult);
    
    // set the player's velocity when the user just swiped the screen (when player.thrustJustOccurred==true).*/
    if (player.thrustJustOccurred) {
        CGPoint thrustVelocity = ccpAdd(ccp(-player.thrustBeginPoint.x,-player.thrustBeginPoint.y), player.thrustEndPoint);
        thrustVelocity = ccp( thrustVelocity.x* thrustStrength,thrustVelocity.y*thrustStrength);
        //NSLog([NSString stringWithFormat:@"thrust mag: %f",ccpLength(thrustVelocity)]);
        player.velocity = ccpAdd(player.velocity, thrustVelocity);
        player.thrustJustOccurred=false;
    }
}

- (void)CenterCameraAtPlayer {
    for (CameraObject *object in cameraObjects) {
        object.sprite.position = ccpSub(object.sprite.position, ccpSub(player.sprite.position,cameraFocusPosition));
    }
}

- (void)resetVariablesForNewGame {
    score=0;
    zonesReached=0;
    prevScore=0;
    
    //this is where the player is on screen (240,160 is center of screen)
    cameraFocusPosition = CGPointMake( 240, 160);
    [player setVelocity:ccp(0,0)];
    for (Zone* zone in zones)
    {        
        [cameraLayer removeChild:zone.sprite cleanup:YES];
        [cameraLayer addChild:zone.sprite];
        zone.hasPlayerHitThisZone = false;
    }
}

- (void)JumpPlayerToPlanet:(int)planetIndex {
    player.sprite.position = ccpAdd(((Planet*)[planets objectAtIndex:planetIndex]).sprite.position, ccp(130,0));
    [self resetVariablesForNewGame];
    [self CenterCameraAtPlayer];
}

- (void)UpdatePlanets {
    
    // Planet-to-Player collision detection follows-------------
    for (Planet* planet in planets)
    {
        if (ccpDistance([[player sprite]position], [[planet sprite]position])<[planet radius])
        {
            //i disagree from a philosophical standpoint with the idea of dying
            //[self JumpPlayerToPlanet:0];
        }
    } // end collision detection code-----------------
    
    // Zone-to-Player collision detection follows-------------
    int i = 0;
    for (Zone* zone in zones)
    {
        if (ccpDistance([[player sprite]position], [[zone sprite]position])<[zone radius])
        {
            if (!zone.hasPlayerHitThisZone)
            {
                if (i == 0)
                {
                    [cameraLayer removeChild:zone.sprite cleanup:YES];
                    zone.hasPlayerHitThisZone = true;    
                    zonesReached ++;
                }
                else if ([[zones objectAtIndex:i - 1]hasPlayerHitThisZone])
                {
                    [cameraLayer removeChild:zone.sprite cleanup:YES];
                    zone.hasPlayerHitThisZone = true;  
                    zonesReached++;
                }
            }
        }
        i += 1;
    } // end collision detection code-----------------
}

/*
    Your score goes up as you move along the vector between the first and last planet. Your score will also never go down, as the user doesn't like to see his score go down. The initialScoreConstant will be set only when firstTimeRunning == true. initialScoreConstant is what ensures your score starts at zero, and not some negative number.
*/
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
    [zonesReachedLabel setString:[NSString stringWithFormat:@"Zones Reached: %d",zonesReached]];
}

- (void) UpdateArrow {
    arrow.velocity = player.velocity;
    arrow.acceleration = player.acceleration;
    arrow.sprite.position = player.sprite.position;
}

- (void) Update:(ccTime)dt {
    [self UpdatePlanets];    
    [self UpdatePlayer];
    [self UpdateArrow];
    [self UpdateScore:false];
    [self UpdateCameraObjects];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        if (location.x <= size.width/4 && location.y <= size.height/4)
            [self JumpPlayerToPlanet:0];
        else
            [player setThrustBeginPoint:location];
        [arrow setSwipeOrigin:location];
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    arrow.sprite.visible = YES;

    UITouch *touch = [touches anyObject];

    CGPoint origin = arrow.swipeOrigin;
    CGPoint ending = [touch locationInView:[touch view]];
    
    CGPoint startPoint = [[CCDirector sharedDirector] convertToGL:origin];
    CGPoint endPoint = [[CCDirector sharedDirector] convertToGL:ending];

    CGPoint vector = ccpSub(endPoint, startPoint);
    CGFloat length = ccpDistance(origin, ending);
    CGFloat angle = CC_RADIANS_TO_DEGREES(-ccpToAngle(vector));
    
    CGFloat maxLength = MAX(self.boundingBox.size.width, self.boundingBox.size.height)/1.75;
    
    CGFloat power = length / maxLength;
    
    CGFloat newOpacity = 255 * pow(power, 0.8);
    if (newOpacity > 255) {
        newOpacity = 255;
    }
    arrow.sprite.opacity = newOpacity;
    
    //The boundingBox is the size of the rectangle's sprite NOT accounting for scaling.
    //To find the actual, scaled width of a sprite, use [sprite width]. 
    //[arrow.sprite setScaleX:length/[arrow.sprite boundingBox].size.width];
    //[arrow.sprite setScaleY:.2];
    arrow.sprite.rotation = angle;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        [player setThrustEndPoint:location];
        player.thrustJustOccurred = true;
        arrow.sprite.visible = NO;
    }
}


- (int)RandomBetween:(int)minvalue maxvalue:(int)maxvalue  {
    int randomNumber = minvalue+  arc4random() % (1+maxvalue-minvalue);
    return randomNumber;
}

@end