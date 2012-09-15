//
//  CreditsLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/25/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "HighScoresLayer.h"
#import "UpgradeManager.h"
#import "UpgradeItem.h"
#import "UpgradeCell.h"
#import "UserWallet.h"
#import "CCDirector.h"
#import "MainMenuLayer.h"
#import "DDGameKitHelper.h"
#import "SimpleAudioEngine.h"
#import "DataStorage.h"
#import "PlayerStats.h"

@implementation HighScoresLayer {
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
	HighScoresLayer *layer = [HighScoresLayer node];
    
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
        
        CCParticleSystemQuad * starParticle = [CCParticleSystemQuad particleWithFile:@"starParticleMenu.plist"];
        [self addChild:starParticle];
        
        CCSprite* topBar = [CCSprite spriteWithFile:@"banner.png"];
        [self addChild:topBar];
        [topBar setPosition: ccp(240, 320 - topBar.boundingBox.size.height/2 + 2)];
        
        NSString* stringToUse;
        stringToUse = @"HIGH SCORES";
        
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
        
        CCMenuItem *gameCenter = [CCMenuItemImage
                                  itemWithNormalImage:@"back.png" selectedImage:@"backpressed.png"
                                  target:self selector:@selector(gameCenterButtonPressed)];
        gameCenter.position = ccp(480-41, 300.5);
        //quit.scale = 1.7;
        
        CCMenu* menu = [CCMenu menuWithItems:quit, gameCenter, nil];
        menu.position = ccp(0, 0);
        
        [self addChild:menu];
        [self initHighScore];
        [self initScrollStuff];
        
        [self schedule:@selector(Update:) interval:0];
	}
	return self;
}

- (void)gameCenterButtonPressed {
    [self playSound:@"doorClose2.mp3" shouldLoop:false pitch:1];
    [Flurry logEvent:@"Opened gamecenter leaderboards"];
    [[DDGameKitHelper sharedGameKitHelper]showLeaderboard];
}

- (void)initHighScore {
    NSMutableArray *highScores = [[PlayerStats sharedInstance] getScores];
    
    int highScore0Int = 0;
    int highScore1Int = 0;
    int highScore2Int = 0;
    int highScore3Int = 0;
    int highScore4Int = 0;
    int highScore5Int = 0;
    int highScore6Int = 0;
    int highScore7Int = 0;
    int highScore8Int = 0;
    int highScore9Int = 0;
    int highScore10Int = 0;
    int highScore11Int = 0;
    int highScore12Int = 0;
    int highScore13Int = 0;
    int highScore14Int = 0;
    int highScore15Int = 0;
    int highScore16Int = 0;
    int highScore17Int = 0;
    int highScore18Int = 0;
    int highScore19Int = 0;
    
    if (highScores && [highScores count] > 0) {
        highScore0Int = [[highScores objectAtIndex:0] intValue];
    }
    if (highScores && [highScores count] > 1) {
        highScore1Int = [[highScores objectAtIndex:1] intValue];
    }
    if (highScores && [highScores count] > 2) {
        highScore2Int = [[highScores objectAtIndex:2] intValue];
    }
    if (highScores && [highScores count] > 3) {
        highScore3Int = [[highScores objectAtIndex:3] intValue];
    }
    if (highScores && [highScores count] > 4) {
        highScore4Int = [[highScores objectAtIndex:4] intValue];
    }
    if (highScores && [highScores count] > 5) {
        highScore5Int = [[highScores objectAtIndex:5] intValue];
    }
    if (highScores && [highScores count] > 6) {
        highScore6Int = [[highScores objectAtIndex:6] intValue];
    }
    if (highScores && [highScores count] > 7) {
        highScore7Int = [[highScores objectAtIndex:7] intValue];
    }
    if (highScores && [highScores count] > 8) {
        highScore8Int = [[highScores objectAtIndex:8] intValue];
    }
    if (highScores && [highScores count] > 9) {
        highScore9Int = [[highScores objectAtIndex:9] intValue];
    }
    if (highScores && [highScores count] > 10) {
        highScore10Int = [[highScores objectAtIndex:10] intValue];
    }
    if (highScores && [highScores count] > 11) {
        highScore11Int = [[highScores objectAtIndex:11] intValue];
    }
    if (highScores && [highScores count] > 12) {
        highScore12Int = [[highScores objectAtIndex:12] intValue];
    }
    if (highScores && [highScores count] > 13) {
        highScore13Int = [[highScores objectAtIndex:13] intValue];
    }
    if (highScores && [highScores count] > 14) {
        highScore14Int = [[highScores objectAtIndex:14] intValue];
    }
    if (highScores && [highScores count] > 15) {
        highScore15Int = [[highScores objectAtIndex:15] intValue];
    }
    if (highScores && [highScores count] > 16) {
        highScore16Int = [[highScores objectAtIndex:16] intValue];
    }
    if (highScores && [highScores count] > 17) {
        highScore17Int = [[highScores objectAtIndex:17] intValue];
    }
    if (highScores && [highScores count] > 18) {
        highScore18Int = [[highScores objectAtIndex:18] intValue];
    }
    if (highScores && [highScores count] > 19) {
        highScore19Int = [[highScores objectAtIndex:19] intValue];
    }
    
    CCLabelTTF *highScore0;
    CCLabelTTF *highScore1;
    CCLabelTTF *highScore2;
    CCLabelTTF *highScore3;
    CCLabelTTF *highScore4;
    CCLabelTTF *highScore5;
    CCLabelTTF *highScore6;
    CCLabelTTF *highScore7;
    CCLabelTTF *highScore8;
    CCLabelTTF *highScore9;
    CCLabelTTF *highScore10;
    CCLabelTTF *highScore11;
    CCLabelTTF *highScore12;
    CCLabelTTF *highScore13;
    CCLabelTTF *highScore14;
    CCLabelTTF *highScore15;
    CCLabelTTF *highScore16;
    CCLabelTTF *highScore17;
    CCLabelTTF *highScore18;
    CCLabelTTF *highScore19;
    
    CCLabelTTF *lowestText;
    
    if (highScore0Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore0Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore0 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore0];
        [highScore0 setAnchorPoint:ccp(.5, 1)];
        highScore0.position = ccp(240, -5);
        lowestText = highScore0;
    }
    if (highScore1Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore1Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore1 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore1];
        [highScore1 setAnchorPoint:ccp(.5, 1)];
        highScore1.position = ccp(240, highScore0.position.y - highScore0.boundingBox.size.height - 10);
        lowestText = highScore1;
    }
    if (highScore2Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore2Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore2 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore2];
        [highScore2 setAnchorPoint:ccp(.5, 1)];
        highScore2.position = ccp(240, highScore1.position.y - highScore1.boundingBox.size.height - 10);
        lowestText = highScore2;
    }
    if (highScore3Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore3Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore3 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore3];
        [highScore3 setAnchorPoint:ccp(.5, 1)];
        highScore3.position = ccp(240, highScore2.position.y - highScore2.boundingBox.size.height - 10);
        lowestText = highScore3;
    }
    if (highScore4Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore4Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore4 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore4];
        [highScore4 setAnchorPoint:ccp(.5, 1)];
        highScore4.position = ccp(240, highScore3.position.y - highScore3.boundingBox.size.height - 10);
        lowestText = highScore4;
    }
    if (highScore5Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore5Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore5 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore5];
        [highScore5 setAnchorPoint:ccp(.5, 1)];
        highScore5.position = ccp(240, highScore4.position.y - highScore4.boundingBox.size.height - 10);
        lowestText = highScore5;
    }
    if (highScore6Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore6Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore6 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore6];
        [highScore6 setAnchorPoint:ccp(.5, 1)];
        highScore6.position = ccp(240, highScore5.position.y - highScore5.boundingBox.size.height - 10);
        lowestText = highScore6;
    }
    if (highScore7Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore7Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore7 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore7];
        [highScore7 setAnchorPoint:ccp(.5, 1)];
        highScore7.position = ccp(240, highScore6.position.y - highScore6.boundingBox.size.height - 10);
        lowestText = highScore7;
    }
    if (highScore8Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore8Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore8 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore8];
        [highScore8 setAnchorPoint:ccp(.5, 1)];
        highScore8.position = ccp(240, highScore7.position.y - highScore7.boundingBox.size.height - 10);
        lowestText = highScore8;
    }
    if (highScore9Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore9Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore9 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore9];
        [highScore9 setAnchorPoint:ccp(.5, 1)];
        highScore9.position = ccp(240, highScore8.position.y - highScore8.boundingBox.size.height - 10);
        lowestText = highScore9;
    }
    if (highScore10Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore10Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore10 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore10];
        [highScore10 setAnchorPoint:ccp(.5, 1)];
        highScore10.position = ccp(240, highScore9.position.y - highScore9.boundingBox.size.height - 10);
        lowestText = highScore10;
    }
    if (highScore11Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore11Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore11 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore11];
        [highScore11 setAnchorPoint:ccp(.5, 1)];
        highScore11.position = ccp(240, highScore10.position.y - highScore10.boundingBox.size.height - 10);
        lowestText = highScore11;
    }
    if (highScore12Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore12Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore12 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore12];
        [highScore12 setAnchorPoint:ccp(.5, 1)];
        highScore12.position = ccp(240, highScore11.position.y - highScore11.boundingBox.size.height - 10);
        lowestText = highScore12;
    }
    if (highScore13Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore13Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore13 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore13];
        [highScore13 setAnchorPoint:ccp(.5, 1)];
        highScore13.position = ccp(240, highScore12.position.y - highScore12.boundingBox.size.height - 10);
        lowestText = highScore13;
    }
    if (highScore14Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore14Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore14 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore14];
        [highScore14 setAnchorPoint:ccp(.5, 1)];
        highScore14.position = ccp(240, highScore13.position.y - highScore13.boundingBox.size.height - 10);
        lowestText = highScore14;
    }
    if (highScore15Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore15Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore15 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore15];
        [highScore15 setAnchorPoint:ccp(.5, 1)];
        highScore15.position = ccp(240, highScore14.position.y - highScore14.boundingBox.size.height - 10);
        lowestText = highScore15;
    }
    if (highScore16Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore16Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore16 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore16];
        [highScore16 setAnchorPoint:ccp(.5, 1)];
        highScore16.position = ccp(240, highScore15.position.y - highScore15.boundingBox.size.height - 10);
        lowestText = highScore16;
    }
    if (highScore17Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore17Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore17 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore17];
        [highScore17 setAnchorPoint:ccp(.5, 1)];
        highScore17.position = ccp(240, highScore16.position.y - highScore16.boundingBox.size.height - 10);
        lowestText = highScore17;
    }
    if (highScore18Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore18Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore18 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore18];
        [highScore18 setAnchorPoint:ccp(.5, 1)];
        highScore18.position = ccp(240, highScore17.position.y - highScore17.boundingBox.size.height - 10);
        lowestText = highScore18;
    }
    if (highScore19Int != 0) {
        NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore19Int];
        NSString *displayLine = [NSString stringWithFormat:@"%@  %@", scoreInt, [[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        highScore19 = [CCLabelTTF labelWithString:displayLine fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        [scrollView addChild:highScore19];
        [highScore19 setAnchorPoint:ccp(.5, 1)];
        highScore19.position = ccp(240, highScore18.position.y - highScore18.boundingBox.size.height - 10);
        lowestText = highScore19;
    }
    
    scrollViewHeight = -lowestText.position.y + lowestText.boundingBox.size.height + 20;
}

- (void)initScrollStuff {
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
    //[Kamcord playSound:soundFile loop:shouldLoop];
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