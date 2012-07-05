//
//  Constants.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Stanford University. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"

const float durationOfPostExplosionScreenShake = .62f;
const float thrustStrength = .035;
const float gravitationalConstant = 14000000000;
const float distanceMult = 10;
const float gravitationalDistancePower = 3;
const float reverseGravitationalConstant = 12000000000000;
const float reverseDistanceMult = 3;
const float reverseGravitationalDistancePower = 5;

// this is purely visual and doesn't affect mass.
const float planetSizeScale = .21;

// the zone scale is the planet scale * this number
const float zoneScaleRelativeToPlanet = 1.8;

// it actualy does nothing right now but normally this constant multiplies the velocity whenever it is super close to a planet
const float velocityDampener = 1;

// this is basically how much gravity affects you. If you reduce both this and thrustStregth, you will effectively be slowing down the speed of the game
const float absoluteSpeedMult = .01;

// the truely magical but well thought-out constant that makes it easy to orbit. 0 = nothing, 1 = impossible to hit a planet. values between 0 and 1 make the planet harder to hit as they get closer to 1.
const float theMagicalConstant = 10.3;

const float maxSwipeInput = 6;
const float minScaler = 0;



const int totalPredictingLines = 15;
const int numberSpacingBetweenLines = 5;
const float scaleForLines = .5;

const float secsToScale = .8;

//the planet radius multiplier at which to start auto orbiting
const float autoOrbitRadius = 1.1;
//0=no auto orbit, the higher the number the higher the rate at which your velocity will increase during auto orbit
const float autoOrbitEase = .5;
//auto orbit will not boost you past this speed
const float autoOrbitMaxVelocity = 9;
