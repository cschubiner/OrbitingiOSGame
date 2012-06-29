//
//  CameraObject.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Stanford University. All rights reserved.
//

#import "CameraObject.h"


@implementation CameraObject
@synthesize sprite,alive,ID,acceleration,velocity;

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
@end
