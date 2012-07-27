//
//  Constants.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Clayton Schubiner. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"

//how long the comet takes to respawn after it dies in seconds
const float cometRespawnTimer = 1;
const float cometMinYSpeed = 2;
const float cometMaxYSpeed = 5;

//changes how zoomed in the camera in. higher numbers mean more zoom (everything looks bigger)
const float zoomMultiplier = .85;
//changes how quickly the camera zooms in and out
const float cameraZoomSpeed = .05;
//changes how quickly the camera changes position
const float cameraMovementSpeed = .07;

//For optimization, whenever more segments than this are present, the oldest one will be deleted
const int numberOfSegmentsAtATime = 3;
//This is the general direction the planet segments head in in degrees from 0. 
const float directionPlanetSegmentsGoIn= 33.3910034413;
//The maximum number of degrees that the segment of planets can be rotated from the direction (see above)
const float segmentRotationVariation = 30;

//how quickly the player's spaceship rotates when the direction of his velocity changes
const float playerRotationSpeed = .39f;
const float playerSizeScale = 1.5;

const float anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees = 55;
const float anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees = -35;

const float durationOfPostExplosionScreenShake = .40f;
const float postExplosionShakeXMagnitude = 4;
const float postExplosionShakeYMagnitude = 3;

// this is purely visual and doesn't affect mass.
const float planetSizeScale = .5;

//this is the time in seconds it takes before the player appears again and starts blinking and moving towards where he should spawn
const float delayTimeAfterPlayerExplodes = .8f;
//the time in seconds it takes the player to move towards his respawn point AFTER the delay time is over.
const float respawnMoveTime = 1.4f;
//increase this number to increase the rate at which the player blinks as he is spawning
const float respawnBlinkFrequency = 2.5f;

// the zone scale is the planet scale * this number. BE SURE TO REDUCE factorToPlaceGravFieldS (both of them) if you increase this
const float zoneScaleRelativeToPlanet = 1.7;

//the gravitational force. increase this to force the orbiting velocity to increase
const float gravity = .45;

//radius percentage at which you will collide with a planet
const float planetRadiusCollisionZone = .96;

// this is purely visual and doesn't affect mass.
const float asteroidSizeScale = .36*.64f;

//radius percentage at which you will collide with a asteroid
const float asteroidRadiusCollisionZone = .82;

//the asteroid's minimum velocity
const float minAstVel = 0;

//the asteroid's maximum velocity
const float maxAstVel = .4;

//gravity strength when in orbit state 3
const float freeGravityStrength = .7;
const float multiplyGravityThisManyTimesOnPerfectSwipe = 2;
const float increaseGravStrengthByThisMuchEveryUpdate = .02;

//the rate at which gravity increases per update while in orbit state 2/3
//const float rateToIncreaseGravity = .015;

//percentage to multiply swipe vector by to get the velocity vector you add to the player's velocity
const float swipeStrength = .03;

//the minimum swipe magnitude that will count as a swipe
const float minSwipeStrength = 30;

//how many updates pass while the player isn't in a zone until tie go will did
const float deathAfterThisLong = 55*1.35f*1.1f*1.5f*1*2*.9;

//the percent of the black hole's radius that triggers a collision
const float blackHoleCollisionRadiusFactor = .2f;
const float blackHoleSpeedFactor = 1.85;

//increase to make timeDilationFactor decrease more rapidly
const float timeDilationReduceRate = .002;

//1 means you lose no speed when you die, 0 means you lose it all
const float factorToScaleTimeDilationByOnDeath = .8;

//increase to increase timeDilationFactor by a larger amount everytime you get to a new zone
const float timeDilationIncreaseRate = .15;

//the smallest the time dilation factor can go
const float absoluteMinTimeDilation = .85;

//the highest the time dilation factor can go. this should probZ just be infinity. bitches will has c slow down if they're going too fast
const float absoluteMaxTimeDilation = 1.7;

//0 = impossible/needs to match angle exactly, a higher number means your swipe timing can be off by that many degrees
//const float requiredAngleAccuracy = 0; //30

//after this many updates, your velocity will go from what it was when you entered to perfect tangential orbital velocity
const float updatesToMakeOrbitVelocityPerfect = 60;

//if this is 1, you will always be at a perfect orbit distance, the smaller it goes the longer it takes to get to that perfect radius (but the smoother it looks)
const float howFastOrbitPositionGetsFixed = .05;

const float factorToPlaceGravFieldWhenCrossingOverTheMiddle = .84;

const float factorToPlaceGravFieldWhenStayingOutside = .63;

const float zoneCollisionFactor = 1.01;
