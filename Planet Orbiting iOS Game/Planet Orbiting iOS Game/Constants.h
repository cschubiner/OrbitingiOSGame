//
//  Constants.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Stanford University. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"

const float thrustStrength = .01;
const float gravitationalConstant = 400000000;
const float distanceMult = 10;
const float gravitationalDistancePower = 3;
const float reverseGravitationalConstant = 190000000000;
const float reverseDistanceMult = 2.5;
const float reverseGravitationalDistancePower = 5;
//this is purely visual and doesn't effect mass.
const float planetSizeScale = .21;
//(it actualy doesnt nothing right now but normally,) this constant multiplies the velocity whenever it is super close to a planet
const float velocityDampener = 1;
//this is basically how much gravity affects you. If you reduce both this and thrustStregth, you will effectively be slowing down the speed of the game
const float absoluteSpeedMult = .3;
//the truely magical but well thought out constant that makes it easy to orbit!!!!! 0=nothing, 1=impossible to hit a planet.
const float theBestFuckingConstantEver = .11;
//the factor by which to scale theBestFuckingConstantEver for when the spaceship is moving away from the planet
const float theBestConstantComplement = 2.5;