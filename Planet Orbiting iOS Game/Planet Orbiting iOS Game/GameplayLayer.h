//
//  GameplayLayer.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Player.h"
#import "Planet.h"

@interface GameplayLayer : CCLayer {
    
    Player *player;
    NSMutableArray *planets;
    NSMutableArray *zones;
    NSMutableArray *predPoints;
    NSMutableArray *cameraObjects;
    CGFloat lastPlanetXPos;
    CGFloat lastPlanetYPos;
    CCLabelTTF *scoreLabel;
    CCLabelTTF *zonesReachedLabel;
    CGSize size;
    CCLayer *hudLayer;
    CCLayer *cameraLayer;
    CCNode * cameraFocusNode;
    CGPoint cameraLastFocusPosition;
    Planet * lastPlanetVisited;
    // where the player is on the screen (240,160 is center of screen)
    CGPoint cameraFocusPosition;
    CGPoint cameraPositionToFocus;
    bool justReachedNewPlanet;
    ccTime totalGameTime;
    float timeSinceCometLeftScreen;
    float timeSincePlanetExplosion;
    bool planetJustExploded;
    bool playerIsTouchingScreen;
    
    bool isOnFirstRun;
    bool isOrbiting;
    bool isInAZone;
    CGPoint lastAcceleration;
    
    CCParticleSystemQuad * thrustParticle;
    CCParticleSystemQuad * planetExplosionParticle;
    CCParticleSystemQuad * spaceBackgroundParticle;
    CCParticleSystemQuad * cometParticle;
    CGPoint cometVelocity;
    
    float lastAngle2minusptopangle;
    
    // is multiplied by the absoluteSpeedMult to cause time dilation
    float timeDilationCoefficient;
    
    // number of zones gone through without screwing up
    int numZonesHitInARow;
}

+ (CCScene *) scene;

- (int)RandomBetween:(int)minvalue maxvalue:(int)maxvalue;

double lerpd(double a, double b, double t);
float lerpf(float a, float b, float t);

@end
