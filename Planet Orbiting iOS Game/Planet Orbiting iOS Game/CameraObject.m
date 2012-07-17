//
//  CameraObject.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Stanford University. All rights reserved.
//

#import "CameraObject.h"

@implementation CameraObject

@synthesize sprite,alive,number,acceleration,velocity,isBeingDrawn;

-(id)init {
    if (self=[super init]) {
        isBeingDrawn = false;
    }
    return self;
}

-(CGPoint)position{
    //don't do object.position, do object.SPRITE!!!.position. 
    //this method intentionally crashes to punish you for your error
    CGPoint * hi =NULL;
    return *hi;
}

-(void)setPosition:(CGPoint)position{
    //don't do [object setPosition], do object.SPRITE!!!.position. 
    //this method intentionally crashes to punish you for your error
    int * hi =NULL;
    int jok = *hi;
    jok++;
}

-(CGPoint)getPositionOnScreen:(CCLayer*)layerObjectIsOn{
    return [layerObjectIsOn convertToWorldSpace:self.sprite.position];
}

- (float)radius {
    radius = MAX([[self sprite] height],[[self sprite] width])/2;
    return radius;
}

-(CGRect)rect{
    return CGRectMake([[self sprite]position].x-[[self sprite]width]/2, 
                      [[self sprite]position].y-[[self sprite]height]/2, [[self sprite]width], [[self sprite]height]);
}

-(CGRect)rectOnScreen:(CCLayer*)layerObjectIsOn{
    CGPoint onscreen = [layerObjectIsOn convertToWorldSpace:self.sprite.position];
    return CGRectMake(onscreen.x-[[self sprite]width]/2, 
                      onscreen.y-[[self sprite]height]/2, [[self sprite]width], [[self sprite]height]);
}

@end