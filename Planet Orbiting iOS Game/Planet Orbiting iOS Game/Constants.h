//
//  Constants.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Clayton Schubiner. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"


const float generalScale = .498;

//how long the comet takes to respawn after it dies in seconds
const float cometRespawnTimer = 1;
const float cometMinYSpeed = 2;
const float cometMaxYSpeed = 5;

const float musicVolumeGameplay = 1;
const float effectsVolumeGameplay = 1;
//max length of player name
const int maxNameLength = 10;

//multiply all scores by this number to make users feel better!
const float generalScoreMultiplier = .543210;

//changes how zoomed in the camera in. higher numbers mean more zoom (everything looks bigger)
const float zoomMultiplier = .85*.95f*1.06f;
//changes how quickly the camera zooms in and out
const float cameraZoomSpeed = .025*.3*1.6;
//changes how quickly the camera changes position
const float cameraMovementSpeed = .06;

const float streakWidthOnRetinaDisplay = 20;
const float streakWidthWITHOUTRetinaDisplay = streakWidthOnRetinaDisplay/2.0;

//how quickly the loading label that provides helper text moves along the screen. higher numbers make it move slower.
const float loadingHelperLabelMoveTime = 9.1;
const float loadingTimeDilationAsPlayerIsGoingToFirstPlanet = .68*1.1;

//For optimization, whenever more segments than this are present, the oldest one will be deleted
const int numberOfSegmentsAtATime = 3;
//This is the general direction the planet segments head in in degrees from 0. 
const float defaultDirectionPlanetSegmentsGoIn= 33.3910034413;
//this is the variance of the direction all planet segments go in. it changes everytime you run the game (press play)
const float directionPlanetSegmentsGoInVariance = 20;
//The maximum number of degrees that the segment of planets can be rotated from the direction (directionPlanetSegmentsGoIn)
const float segmentRotationVariation = 20;//30;

const float playerSizeScale = 1;

const float anglesBeforeTheQuarterSphereToTurnLineGreenInDegrees = 55;
const float anglesAFTERTheQuarterSphereToTurnLineBlueInDegrees = -45;

const float durationOfPostExplosionScreenShake = .40f;
const float postExplosionShakeXMagnitude = 4;
const float postExplosionShakeYMagnitude = 3;

//this changes the color the streak is when the player is moving at different speeds
const GLubyte slowStreakColor[] = {0,255,153,255};
const GLubyte slowParticleColor[] = {0,41,255,255};
const GLubyte fastStreakColor[] = {255,255,255,255};
const GLubyte fastParticleColor[] = {255,255,255,255};

// this is purely visual and doesn't affect mass.
const float planetSizeScale = .5;

//this is the time in seconds it takes before the player appears again and starts blinking and moving towards where he should spawn
const float delayTimeAfterPlayerExplodes = 1.7f;
//increase this number to increase the rate at which the player blinks as he is spawning
const float respawnBlinkFrequency = 2.5f;

// the zone scale is the planet scale * this number. BE SURE TO REDUCE factorToPlaceGravFieldS (both of them) if you increase this
const float zoneScaleRelativeToPlanet = 1.7;

//the gravitational force. increase this to force the orbiting velocity to increase
const float gravity = .45;

//radius percentage at which you will collide with a planet
const float planetRadiusCollisionZone = .8;

//percent of the planet orbiting radius that you will respawn at
const float respawnOrbitRadius = .88;

// this is purely visual and doesn't affect mass.
const float asteroidSizeScale = .36*.64f;

//radius percentage at which you will collide with a asteroid
const float asteroidRadiusCollisionZone = 1;

const float powerupRadiusCollisionZone = 1.2;
const float powerupScaleSize = 1;

const int distanceBetweenGalaxies = 3200;
const float cameraScaleWhenTransitioningBetweenGalaxies = .4;
const float howMuchSlowerTheBatteryRunsOutWhenYouAreTravelingBetweenGalaxies = .5;

//the asteroid's minimum velocity
const float minAstVel = 0;

//the asteroid's maximum velocity
const float maxAstVel = .4;

//gravity strength when in orbit state 3
const float freeGravityStrength = .6;
const float multiplyGravityThisManyTimesOnPerfectSwipe = 2;
const float increaseGravStrengthByThisMuchEveryUpdate = .02;

//the rate at which gravity increases per update while in orbit state 2/3
//const float rateToIncreaseGravity = .015;

//percentage to multiply swipe vector by to get the velocity vector you add to the player's velocity
const float swipeStrength = .03;

//the minimum swipe magnitude that will count as a swipe
const float minSwipeStrength = 30;

//how many updates pass while the player isn't in a zone until tie go will did
const float deathAfterThisLong = 55*1.35f*1.1f*1.5f*1*2*.9*2*2;

//SPEED!!!!-------------------------------------------------------------------------------------------------

const float initialTimeDilation = .8*.89;

//increase to make timeDilationFactor decrease more rapidly
const float timeDilationReduceRate = .0005;

//1 means you lose no speed when you die, 0 means you lose it all
const float factorToScaleTimeDilationByOnDeath = .835;

//increase to increase timeDilationFactor by a larger amount everytime you get to a new zone
const float timeDilationIncreaseRate = .047*.8*1.5*.98;

const float timeDilationFeverModeMultiplier = 1.05;

//the smallest the time dilation factor can go
//THIS IS NOW IN UPGRADE VALUES const float absoluteMinTimeDilation = .85;

//the highest the time dilation factor can go. this should probZ just be infinity. bitches will has c slow down if they're going too fast
const float absoluteMaxTimeDilation = initialTimeDilation*1.7;

//----------------------------------------------------------------------------------------------------------

//after this many updates, your velocity will go from what it was when you entered to perfect tangential orbital velocity
const float updatesToMakeOrbitVelocityPerfect = 60;

//if this is 1, you will always be at a perfect orbit distance, the smaller it goes the longer it takes to get to that perfect radius (but the smoother it looks)
const float howFastOrbitPositionGetsFixed = .05;

const float factorToPlaceGravFieldWhenCrossingOverTheMiddle = .84;

const float factorToPlaceGravFieldWhenStayingOutside = .7;

const float zoneCollisionFactor = 1.01;

//THIS IS NOW IN UPGRADE VALUES const float negativeLightStartingScore = 9000;

const int howMuchCoinsAddToScore = 45;

const float coinAnimationDelay = .02;

const int minPlanetsInARowForFeverMode = 5;

const float maxTimeInOrbitThatCountsAsGoodSwipe = .85;