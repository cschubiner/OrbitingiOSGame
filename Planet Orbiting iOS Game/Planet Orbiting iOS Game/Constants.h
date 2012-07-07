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
const float thrustStrength = .17;
const float gravitationalConstant = 11000000000;
const float distanceMult = 10;
const float gravitationalDistancePower = 3;
const float reverseGravitationalConstant = 12500000000000;
const float reverseDistanceMult = 3;
const float reverseGravitationalDistancePower = 5;

// this is purely visual and doesn't affect mass.
const float planetSizeScale = .42;

// the zone scale is the planet scale * this number
const float zoneScaleRelativeToPlanet = 1.8;

// it actualy does nothing right now but normally this constant multiplies the velocity whenever it is super close to a planet
const float velocityDampener = 1;

// this is basically how much gravity affects you. If you reduce both this and thrustStregth, you will effectively be slowing down the speed of the game
const float absoluteSpeedMult = .35;

const float speedOfGame = .17;

// the truely magical but well thought-out constant that makes it easy to orbit. 0 = nothing, 1 = impossible to hit a planet. values between 0 and 1 make the planet harder to hit as they get closer to 1.
const float theMagicalConstant = 10;
//the rate at which you are radially slowed down (scaled by scaler)
const float theMagicalConstantReverse = .5;

const float maxSwipeInput = 6;
const float minScaler = 0;
const float secsToScale = .3;


const int totalPredictingLines = 8;
const int numberSpacingBetweenLines = 4;
const float scaleForLines = 1.1;


//the planet radius multiplier at which to start auto orbiting
const float autoOrbitRadius = 1.95;

//0=no auto orbit, the higher the number the higher the rate at which your velocity will increase during auto orbit
const float autoOrbitEase = 2.5;
//how quickly you are tangentially slowed down to get to the point of autoOrbitMaxVelocity (scaled by scaler
const float autoOrbitSlowerEase = 1.5;

//auto orbit will not boost you past this speed
const float autoOrbitMaxVelocity = 20;


const float planetRadiusCollisionZone = .93;

