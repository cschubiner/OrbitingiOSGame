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

//0 -> 1 == gravity completely dissapears -> gravity doesn't goes away at all
const float gravityDamepener = 1;