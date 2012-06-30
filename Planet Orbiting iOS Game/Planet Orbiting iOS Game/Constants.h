//
//  Constants.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Stanford University. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"

const float thrustStrength = .05;
const float gravitationalConstant = 10000000000;
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
const float absoluteSpeedMult = .12;

// the truely magical but well thought-out constant that makes it easy to orbit. 0 = nothing, 1 = impossible to hit a planet. values between 0 and 1 make the planet harder to hit as they get closer to 1.
const float theMagicalConstant = 10.3;

const float maxSwipeInput = 7;
const float minScaler = 0;
const float secsToScale = .3;