//
//  Constants.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Stanford University. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"

//this is x in the equation timeDilationCoefficient = x^(numZonesHitInARow);
const float timeDilationPowerFactor = 1.06;

//changes how zoomed in the camera in. higher numbers mean more zoom (everything looks bigger)
const float zoomMultiplier = .72f;
const float anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees = 65;
const float anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees = -10;
const float durationOfPostExplosionScreenShake = .47f;

// this is purely visual and doesn't affect mass.
const float planetSizeScale = .42;

// the zone scale is the planet scale * this number
const float zoneScaleRelativeToPlanet = 1.8;

//the gravitational force. increase this to force the the orbiting velocity to increase
const float gravity = .4;

//the radius at which you will orbit. make sure it is small enough to put you in the planet's zone
const float distToSpawn = 100;

//radius percentage at which you will collide with a planet
const float planetRadiusCollisionZone = .95;

// this is purely visual and doesn't affect mass.
const float asteroidSizeScale = .30;

//radius percentage at which you will collide with a asteroid
const float asteroidRadiusCollisionZone = .8;

//the asteroid's velocity
const float asteroidVelocity = .4;

//the amount the asteroid velocity will vary from asteroid to asteroid (it could go up or down by this amount)
const float asteroidVelVar = .2;

//initial percentage of gravity felt immediately after you swipe in a non-green zone
const float initialPercentageOfGravityAfterSwipe = .3;

//the rate at which gravity decreases. increase the number to increase the rate of decrease
const float rateToDecreaseGravity = .01;

//percentage to multiply swipe vector by to get the velocity vector you add to the player's velocity
const float swipeStrength = .03;

//the minimum velocity you can have when isExperienceGravity is true
const float minimumVelocity = .3;