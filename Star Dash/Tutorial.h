//
//  GameplayLayer.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Clayton Schubiner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Tutorial : CCLayer {
    NSMutableArray* images;
    int currentImageIndex;
    CCLabelTTF *continueLabel;
    
    float opacTimer;
    bool justTouchedScreen;
    bool canTouchScreen;
    int opacChangingState;
    int readingTimer;
}

+ (CCScene *) scene;

@end
