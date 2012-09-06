//
//  CreditsLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/25/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "CreditsLayer.h"
#import "UpgradeManager.h"
#import "UpgradeItem.h"
#import "UpgradeCell.h"
#import "UserWallet.h"
#import "CCDirector.h"
#import "MainMenuLayer.h"
#import "SimpleAudioEngine.h"
#import "DataStorage.h"

@implementation CreditsLayer {
    CCLayer* scrollView;
    
    float screenHeight;
    float scrollViewHeight;
    float counter;
    float currentCenter;
    float centerGoingTo;
    float startingCenter;
    float endingCenter;
    float position;
    float velocity;
    float enterVelocity;
    CGPoint swipeEndPoint;
    CGPoint swipeBeginPoint;
    bool isTouchingScreen;
    bool wasTouchingScreen;
    int indexPushed;
    bool moved;
    
    CCLayer* purchaseLayer;
    UpgradeItem* pushedItem;
    
    NSMutableArray* upgradeIndecesHere;
    NSMutableArray* cells;
    CCLabelTTF* totalStars;
}

// returns a singleton scene
+ (CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CreditsLayer *layer = [CreditsLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene.
	return scene;
}

+(CCSprite*)labelWithString:(NSString *)string fontName:(NSString *)fontName fontSize:(CGFloat)fontSize color:(ccColor3B)color strokeSize:(CGFloat)strokeSize stokeColor:(ccColor3B)strokeColor {
    
	CCLabelTTF *label = [CCLabelTTF labelWithString:string fontName:fontName fontSize:fontSize];
    
	CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:label.texture.contentSize.width + strokeSize*2  height:label.texture.contentSize.height+strokeSize*2];
    
	[label setFlipY:YES];
	[label setColor:strokeColor];
	ccBlendFunc originalBlendFunc = [label blendFunc];
	[label setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
    
	CGPoint bottomLeft = ccp(label.texture.contentSize.width * label.anchorPoint.x + strokeSize, label.texture.contentSize.height * label.anchorPoint.y + strokeSize);
	CGPoint position = ccpSub([label position], ccp(-label.contentSize.width / 2.0f, -label.contentSize.height / 2.0f));
    
	[rt begin];
    
	for (int i=0; i<360; i++) // you should optimize that for your needs
	{
		[label setPosition:ccp(bottomLeft.x + sin(CC_DEGREES_TO_RADIANS(i))*strokeSize, bottomLeft.y + cos(CC_DEGREES_TO_RADIANS(i))*strokeSize)];
		[label visit];
	}
    
	[label setPosition:bottomLeft];
	[label setBlendFunc:originalBlendFunc];
	[label setColor:color];
	[label visit];
    
	[rt end];
    
	[rt setPosition:position];
    
	return [CCSprite spriteWithTexture:rt.sprite.texture];
    
}


/* On "init," initialize the instance */
- (id)init {
	// always call "super" init.
	// Apple recommends to re-assign "self" with the "super" return value
	if ((self = [super init])) {
        self.isTouchEnabled= TRUE;
        
        scrollView = [[CCLayer alloc] init];
        [self addChild:scrollView];
        
        CCSprite* topBar = [CCSprite spriteWithFile:@"banner.png"];
        [self addChild:topBar];
        [topBar setPosition: ccp(240, 320 - topBar.boundingBox.size.height/2 + 3)];
        
        NSString* stringToUse;
        stringToUse = @"CREDITS";
        
        CCLabelTTF* pauseText = [CCLabelTTF labelWithString:stringToUse fontName:@"HelveticaNeue-CondensedBold" fontSize:31];
        //[self addChild:pauseText];
        pauseText.position = ccp(240, 300.5);
        
        
        CCSprite* topSpriteLabel = [self.class labelWithString:stringToUse fontName:@"HelveticaNeue-CondensedBold" fontSize:30 color:ccWHITE strokeSize:1.1 stokeColor: ccBLACK];
        [self addChild:topSpriteLabel];
        topSpriteLabel.position = ccp(240, 300.5);
        
        
        CCSprite* botBar = [CCSprite spriteWithFile:@"upgradeFooter.png"];
        [self addChild:botBar];
        botBar.scaleY = .5;
        [botBar setPosition: ccp(240, botBar.boundingBox.size.height/2)];
        
        CCMenuItem *quit = [CCMenuItemImage
                            itemWithNormalImage:@"back.png" selectedImage:@"backpressed.png"
                            target:self selector:@selector(backButtonPressed)];
        quit.position = ccp(41, 300.5);
        //quit.scale = 1.7;
        
        CCMenu* menu = [CCMenu menuWithItems:quit, nil];
        menu.position = ccp(0, 0);
        
        [self addChild:menu];
        
        
        [self initCredits];
        
        
        [self initScrollStuff];
        
        
        
        [self schedule:@selector(Update:) interval:0];
	}
	return self;
}

- (void) initCredits {
    CCLabelTTF* credits0 = [CCLabelTTF labelWithString:@"- DESIGN & LEAD PROGRAMMING -" fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
    [scrollView addChild:credits0];
    [credits0 setAnchorPoint:ccp(.5, 1)];
    credits0.position = ccp(240, -5);
    
    CCLabelTTF* credits1 = [CCLabelTTF labelWithString:@"ALEX BLICKENSTAFF\nCLAY SCHUBINER" fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    [scrollView addChild:credits1];
    [credits1 setAnchorPoint:ccp(.5, 1)];
    credits1.position = ccp(240, credits0.position.y - credits0.boundingBox.size.height - 10);
    
    CCLabelTTF* credits4 = [CCLabelTTF labelWithString:@"- ADDITIONAL PROGRAMMING -" fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
    [scrollView addChild:credits4];
    [credits4 setAnchorPoint:ccp(.5, 1)];
    credits4.position = ccp(240, credits1.position.y - credits1.boundingBox.size.height - 35);
    
    CCLabelTTF* credits5 = [CCLabelTTF labelWithString:@"JEFF GRIMES" fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    [scrollView addChild:credits5];
    [credits5 setAnchorPoint:ccp(.5, 1)];
    credits5.position = ccp(240, credits4.position.y - credits4.boundingBox.size.height - 10);
    
    
    CCLabelTTF* credits6 = [CCLabelTTF labelWithString:@"- ART -" fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
    [scrollView addChild:credits6];
    [credits6 setAnchorPoint:ccp(.5, 1)];
    credits6.position = ccp(240, credits5.position.y - credits5.boundingBox.size.height - 35);
    
    CCLabelTTF* credits7 = [CCLabelTTF labelWithString:@"MICHAEL ARBEED" fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    [scrollView addChild:credits7];
    [credits7 setAnchorPoint:ccp(.5, 1)];
    credits7.position = ccp(240, credits6.position.y - credits6.boundingBox.size.height - 10);
    
    
    CCLabelTTF* credits8 = [CCLabelTTF labelWithString:@"- LEVEL DESIGN -" fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
     [scrollView addChild:credits8];
     [credits8 setAnchorPoint:ccp(.5, 1)];
     credits8.position = ccp(240, credits7.position.y - credits7.boundingBox.size.height - 35);
     
     CCLabelTTF* credits9 = [CCLabelTTF labelWithString:@"CRAIG COLLINS" fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
     [scrollView addChild:credits9];
     [credits9 setAnchorPoint:ccp(.5, 1)];
     credits9.position = ccp(240, credits8.position.y - credits8.boundingBox.size.height - 10);
    
    scrollViewHeight = -credits9.position.y + credits9.boundingBox.size.height + 20;
}

-(void) initScrollStuff {
    screenHeight = 275;
    startingCenter = screenHeight;//320-40;//-scrollViewHeight;
    //endingCenter = startingCenter - scrollViewHeight + screenHeight;
    currentCenter = startingCenter;
    position = currentCenter;
    [scrollView setAnchorPoint:ccp(0, 1)];
    [scrollView setPosition:CGPointMake(0, position)];
    if (scrollViewHeight <= screenHeight) {
        endingCenter = startingCenter;
    } else {
        endingCenter = startingCenter + (scrollViewHeight - screenHeight);
    }
    //endingCenter = startingCenter*2-endingCenter;
    enterVelocity = 0;
    velocity = 0;
    
    counter = 1;
    
    isTouchingScreen = false;
    wasTouchingScreen = false;
}

- (void) backButtonPressed {
    [self playSound:@"doorClose2.mp3" shouldLoop:false pitch:1];
    
    [((AppDelegate*)[[UIApplication sharedApplication]delegate]) setShouldPlayMenuMusic:false];
    
    [[CCDirector sharedDirector] replaceScene:[MainMenuLayer scene]];//[CCTransitionCrossFade transitionWithDuration:0.5 scene: [MainMenuLayer scene]]];
}

- (void) Update:(ccTime)dt {
    if (!isTouchingScreen) {
        if ([self isOutOfBounds]) {
            if (enterVelocity == 0) {
                enterVelocity = velocity;
                counter = 1;
                currentCenter = [self getGoodPosition];
                centerGoingTo = currentCenter;
            }
            
            float dif1 = currentCenter - position;
            
            if (fabsf(dif1) <= 20) {
                if (dif1 < 0)
                    centerGoingTo -= .2;
                else
                    centerGoingTo += .2;
            } else {
                centerGoingTo = currentCenter;
            }
            
            float dif2 = centerGoingTo - position;
            if (dif1 == 0)
                return;
            if (fabsf(dif1) <= .2) {
                velocity = 0;
                position = currentCenter;
            } else {
                //if (fabsf(dif) <= 8)
                //    dif *= 1.8;
                velocity = dif2*.02*counter + 1*enterVelocity/counter;
            }
            
        } else {
            enterVelocity = 0;
            velocity*=.96;
            float counterScaler = 30/counter;
            if (counterScaler > 1)
                counterScaler= 1;
            velocity*=counterScaler;
        }
    }
    
    position += velocity;
    [scrollView setPosition:CGPointMake(scrollView.position.x, position)];
    //NSLog(@"velocity: %f, position: %f", velocity, position);
    //NSLog(@"cur center: %f, height: %f, startingCenter: %f, endingCenter: %f", currentCenter, scrollViewHeight, startingCenter, endingCenter);
    
    
    
    
    if (isTouchingScreen && wasTouchingScreen) {
        velocity = 0;
    }
    
    if (isTouchingScreen)
        wasTouchingScreen = true;
    
    
    counter += .5;
    
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    wasTouchingScreen = false;
    moved = true;
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        swipeEndPoint = location;
        
        velocity = swipeEndPoint.y - swipeBeginPoint.y;
        if (position < startingCenter || position > endingCenter) {
            velocity *= .5;
        }
        
        swipeBeginPoint = swipeEndPoint;
    }
}

- (bool)isOutOfBounds {
    if (position < startingCenter || position > endingCenter)
        return true;
    else
        return false;
}

- (float)getGoodPosition {
    if (position < startingCenter)
        return startingCenter;
    else
        return endingCenter;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    isTouchingScreen = true;
    velocity = 0;
    enterVelocity = 0;
    moved = false;
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        swipeBeginPoint = location;
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    isTouchingScreen = false;
    counter = 1;
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        swipeBeginPoint = location;
    }
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    isTouchingScreen = false;
    counter = 1;
}

- (NSString*)commaInt:(int)num {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:[NSNumber numberWithInteger:num]];
}



- (ALuint)playSound:(NSString*)soundFile shouldLoop:(bool)shouldLoop pitch:(float)pitch{
    [Kamcord playSound:soundFile loop:shouldLoop];
    if (shouldLoop)
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:soundFile loop:YES];
    else
        return [[SimpleAudioEngine sharedEngine]playEffect:soundFile pitch:pitch pan:0 gain:1];
    return 0;
}



-(void)completeObjectiveFromGroupNumber:(int)a_groupNumber itemNumber:(int)a_itemNumber {
    [[ObjectiveManager sharedInstance] completeObjectiveFromGroupNumber:a_groupNumber itemNumber:a_itemNumber view:self];
}






@end