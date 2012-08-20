//
//  ObjectiveItem.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/18/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

//#import "ObjectiveItem.h"
#import "ObjectiveHeader.h"

@implementation ObjectiveItem

@synthesize text, completed;

-(id)initWithText:(NSString*)a_text {
    if (self = [super init]) {
        self.text = a_text;
        self.completed = false;
    }
    return self;
}

-(id)initWithText:(NSString*)a_text isCompleted:(bool)a_completed {
    self = [self initWithText:a_text];
    self.completed = a_completed;
    return self;
}

-(bool)complete {
    if (self.completed)
        return false;
    else {
        self.completed = true;
        return true;
    }
}

@end