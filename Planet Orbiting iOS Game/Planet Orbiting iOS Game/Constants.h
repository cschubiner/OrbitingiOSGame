//
//  Constants.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Stanford University. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"

//how long the comet takes to respawn after it dies in seconds
const float cometRespawnTimer = 1;
const float cometMinYSpeed = 2;
const float cometMaxYSpeed = 5;

//as this goes up, the steepness goes DOWN
const float timeDilationSteepness = 8;
//the max factor by which the player's speed will be multiplied
const float timeDilationLimit = 2.5;

//changes how zoomed in the camera in. higher numbers mean more zoom (everything looks bigger)
const float zoomMultiplier = .72f;

const float anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees = 55;
const float anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees = -35;

const float durationOfPostExplosionScreenShake = .40f;
const float postExplosionShakeXMagnitude = 4;
const float postExplosionShakeYMagnitude = 3;

// this is purely visual and doesn't affect mass.
const float planetSizeScale = .5;

// the zone scale is the planet scale * this number
const float zoneScaleRelativeToPlanet = 1.5;

//the gravitational force. increase this to force the orbiting velocity to increase
const float gravity = .45;

//radius percentage at which you will collide with a planet
const float planetRadiusCollisionZone = .96;

// this is purely visual and doesn't affect mass.
const float asteroidSizeScale = .36;

//radius percentage at which you will collide with a asteroid
const float asteroidRadiusCollisionZone = .82;

//the asteroid's minimum velocity
const float minAstVel = 0;

//the asteroid's maximum velocity
const float maxAstVel = .4;

//initial percentage of gravity felt immediately after you swipe in a non-green zone
const float initialPercentageOfGravityAfterSwipe = .3;

//the rate at which gravity decreases. increase the number to increase the rate of decrease
const float rateToDecreaseGravity = .01;

//percentage to multiply swipe vector by to get the velocity vector you add to the player's velocity
const float swipeStrength = .03;

//the minimum velocity you can have when isExperienceGravity is true
const float minimumVelocity = .3;

//the minimum velocity you can have when isExperienceGravity is true
const float minSwipeStrength = 20;