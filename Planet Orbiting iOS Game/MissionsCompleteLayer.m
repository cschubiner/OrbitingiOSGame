//
//  CreditsLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/25/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "MissionsCompleteLayer.h"
#import "UpgradeManager.h"
#import "UpgradeItem.h"
#import "UpgradeCell.h"
#import "UserWallet.h"
#import "CCDirector.h"
#import "MainMenuLayer.h"
#import "SimpleAudioEngine.h"
#import "DataStorage.h"

@implementation MissionsCompleteLayer {
    
    CCLayer* missionCompletionScreen;
    CCLayer* mPopup;
    int starIntForAnimation;
    bool shouldPlayCoinSound;
    float coinPitch;
    int coinPitchCounter;
}

// returns a singleton scene
+ (CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MissionsCompleteLayer *layer = [MissionsCompleteLayer node];
    
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
        
        
        
        missionCompletionScreen = [[CCLayer alloc] init];
        
        if ([[ObjectiveManager sharedInstance] currentObjectiveGroupNumber]>=1)
            for (int i = 0 ; i < 3; i++)
        [[iRate sharedInstance] logEvent:YES];
        
        //CCSprite* dark = [CCSprite spriteWithFile:@"black.png"];
        //[missionCompletionScreen addChild:dark];
        //[dark setZOrder:-11];
        //dark.position = ccp(240, 160);
        //dark.opacity = 230;
        
        CCSprite* ray0 = [CCSprite spriteWithFile:@"sunray.png"];
        [missionCompletionScreen addChild:ray0];
        ray0.position = ccp(240, 160-19);
        [ray0 setVisible:false];
        
        CCSprite* ray1 = [CCSprite spriteWithFile:@"sunray.png"];
        [missionCompletionScreen addChild:ray1];
        ray1.position = ccp(240, 160-19);
        [ray1 setVisible:false];
        
        mPopup = [[CCLayer alloc] init];
        
        CCSprite* bg = [CCSprite spriteWithFile: @"popup.png"];
        [mPopup addChild:bg];
        bg.position = ccp(240, 160);
        
        CCLabelTTF* missionLabel = [CCLabelTTF labelWithString:@"CURRENT MISSIONS" fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
        //[mPopup addChild:missionLabel];
        missionLabel.position = ccp(240, 246);
        
        CCSprite* missionLabelSprite = [self.class labelWithString:@"CURRENT MISSIONS" fontName:@"HelveticaNeue-CondensedBold" fontSize:24 color:ccWHITE strokeSize:1.1 stokeColor:ccBLACK];
        [mPopup addChild:missionLabelSprite];
        missionLabelSprite.position = ccp(240, 246);
        
        NSMutableArray* objectivesAtThisLevel = [[ObjectiveManager sharedInstance] getObjectivesFromGroupNumber:[[ObjectiveManager sharedInstance] currentObjectiveGroupNumber]];
        
        ObjectiveGroup* currentGroup = [[[ObjectiveManager sharedInstance] objectiveGroups] objectAtIndex:[[ObjectiveManager sharedInstance] currentObjectiveGroupNumber]];
        
        
        //CCSprite* ind0 = [CCSprite spriteWithFile:([((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:0]) completed]) ? @"missioncomplete.png" : @"yousuck.png"];
        //CCSprite* ind1 = [CCSprite spriteWithFile:([((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:1]) completed]) ? @"missioncomplete.png" : @"yousuck.png"];
        //CCSprite* ind2 = [CCSprite spriteWithFile:([((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:2]) completed]) ? @"missioncomplete.png" : @"yousuck.png"];
        CCSprite* ind0 = [CCSprite spriteWithFile:@"yousuck.png"];
        CCSprite* ind1 = [CCSprite spriteWithFile:@"yousuck.png"];
        CCSprite* ind2 = [CCSprite spriteWithFile:@"yousuck.png"];
        [mPopup addChild:ind0];
        [mPopup addChild:ind1];
        [mPopup addChild:ind2];
        ind0.position = ccp(108, 211);
        ind1.position = ccp(108, 161);
        ind2.position = ccp(108, 112);
        
        CCLabelTTF* label0 = [CCLabelTTF labelWithString:[((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:0]) text] dimensions:CGSizeMake(263, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
        CCLabelTTF* label1 = [CCLabelTTF labelWithString:[((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:1]) text] dimensions:CGSizeMake(263, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
        CCLabelTTF* label2 = [CCLabelTTF labelWithString:[((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:2]) text] dimensions:CGSizeMake(263, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
        [mPopup addChild:label0];
        [mPopup addChild:label1];
        [mPopup addChild:label2];
        label0.position = ccp(label0.boundingBox.size.width/2 + 134, 211);
        label1.position = ccp(label1.boundingBox.size.width/2 + 134, 161);
        label2.position = ccp(label2.boundingBox.size.width/2 + 134, 112);
        
        
        
        NSString* footerString = [NSString stringWithFormat:@"COMPLETE TO EARN %@", [self commaInt:currentGroup.starReward]];
        
        CCLabelTTF* footer = [CCLabelTTF labelWithString:footerString fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
        [mPopup addChild:footer];
        footer.position = ccp(240, 74);
        
        CCSprite* starSprite0 = [CCSprite spriteWithFile:@"staricon.png"];
        [mPopup addChild:starSprite0];
        starSprite0.scale = .42;
        starSprite0.position = ccpAdd(footer.position, ccp(footer.boundingBox.size.width/2 + 12, 2));
        
        
        
        [missionCompletionScreen addChild:mPopup];
        mPopup.position = ccp(-480, -19);
        
        CCParticleSystemQuad* checkExplosion = [CCParticleSystemQuad particleWithFile:@"checkmarkExplosionParticle.plist"];
        [missionCompletionScreen addChild:checkExplosion];
        [checkExplosion stopSystem];
        
        CCParticleSystemQuad* starExplosion = [CCParticleSystemQuad particleWithFile:@"starStashParticle.plist"];
        [missionCompletionScreen addChild:starExplosion];
        [starExplosion stopSystem];
        
        shouldPlayCoinSound = true;
        coinPitch = .8;
        coinPitchCounter = 0;
        
        CCLayer* starsLayer = [[CCLayer alloc] init];
        [missionCompletionScreen addChild:starsLayer];
        starsLayer.position = ccp(240, 320 + 30);
        [starsLayer setAnchorPoint:ccp(0, 0)];
        
        starIntForAnimation = [[UserWallet sharedInstance] getBalance];
        CCLabelTTF* starCountLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", [self commaInt:starIntForAnimation]] fontName:@"HelveticaNeue-CondensedBold" fontSize:54];
        starCountLabel.color = ccYELLOW;
        [starsLayer addChild:starCountLabel];
        starCountLabel.position = ccp(-20, 0);//ccp(240, 320 + starCountLabel.boundingBox.size.height);
        
        CCSprite* starSprite = [CCSprite spriteWithFile:@"staricon.png"];
        [starsLayer addChild:starSprite];
        starSprite.position = ccp(starCountLabel.boundingBox.size.width/2 - 20 + 20, 4);
        
        
        int finalScore = [[UserWallet sharedInstance] getBalance] + [[ObjectiveManager sharedInstance] getStarRewardFromGroupNumber:[[ObjectiveManager sharedInstance] currentObjectiveGroupNumber]];
        
        int rateOfScoreIncrease = (finalScore-[[UserWallet sharedInstance] getBalance]) / 100;
        
        id changeChecks = [CCSequence actions:
                           
                           [CCCallBlock actionWithBlock:(^{
        })],
                           
                           [CCDelayTime actionWithDuration:.1],
                           
                           [CCCallBlock actionWithBlock:(^{
            [self playSound:@"doorClose2.mp3" shouldLoop:false pitch:1];
            [checkExplosion setPosition:ccpSub(ind0.position, ccp(0, ind0.boundingBox.size.height/2))];
            [checkExplosion resetSystem];
            [ind0 setTexture:[[CCTextureCache sharedTextureCache] addImage:@"missioncomplete.png"]];
        })],
                           
                           [CCDelayTime actionWithDuration:.7],
                           
                           [CCCallBlock actionWithBlock:(^{
            [self playSound:@"doorClose2.mp3" shouldLoop:false pitch:1];
            [checkExplosion setPosition:ccpSub(ind1.position, ccp(0, ind1.boundingBox.size.height/2))];
            [checkExplosion resetSystem];
            [ind1 setTexture:[[CCTextureCache sharedTextureCache] addImage:@"missioncomplete.png"]];
        })],
                           
                           [CCDelayTime actionWithDuration:.7],
                           
                           [CCCallBlock actionWithBlock:(^{
            [self playSound:@"doorClose2.mp3" shouldLoop:false pitch:1];
            [checkExplosion setPosition:ccpSub(ind2.position, ccp(0, ind2.boundingBox.size.height/2))];
            [checkExplosion resetSystem];
            [ind2 setTexture:[[CCTextureCache sharedTextureCache] addImage:@"missioncomplete.png"]];
        })],
                           
                           [CCDelayTime actionWithDuration:.4],
                           
                           [CCCallBlock actionWithBlock:(^{
            [starsLayer runAction:[CCEaseBounceInOut actionWithAction:[CCMoveTo actionWithDuration:.7 position:ccp(240, 284)]]];
        })],
                           
                           [CCDelayTime actionWithDuration:.4],
                           
                           [CCCallBlock actionWithBlock:(^{
            /*while (starInt < [[UserWallet sharedInstance] getBalance] + [[ObjectiveManager sharedInstance] getStarRewardFromGroupNumber:[[ObjectiveManager sharedInstance] currentObjectiveGroupNumber]]) {
             [starCountLabel setString:[NSString stringWithFormat:@"%@", [self commaInt:starInt]]];
             }*/
            
            
            
            id increaseNumber = [CCCallBlock actionWithBlock:(^{
                if (shouldPlayCoinSound)
                    [self playSound:@"buttonpress.mp3" shouldLoop:false pitch:coinPitch];
                [self addToStarInt: [self RandomBetween:rateOfScoreIncrease-1 maxvalue:rateOfScoreIncrease+1]];
                [starCountLabel setString:[NSString stringWithFormat:@"%@",[self commaInt:starIntForAnimation]]];
                [starSprite setPosition:ccp(starCountLabel.boundingBox.size.width/2 - 20 + 20, 4)];
            })];
            id setNumber = [CCCallBlock actionWithBlock:(^{
                [starCountLabel setString:[NSString stringWithFormat:@"%@", [self commaInt:finalScore]]];
            })];
            id displayParticles = [CCCallBlock actionWithBlock:(^{
                [self playSound:@"levelup.mp3" shouldLoop:false pitch:1];
                [starExplosion setPosition:starsLayer.position];
                [starExplosion resetSystem];
                [[UserWallet sharedInstance] setBalance:finalScore];
                
                [starsLayer runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                                                                         [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.4 scale:1.2]],
                                                                         [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.4 scale:1]],
                                                                         nil]
                                       ]];
                
                
                
                [ray0 setRotation:.5];
                [ray0 setZOrder:-1];
                [ray0 setScale:4];
                [ray0 setOpacity:150];
                [ray0 setVisible:true];
                [ray0 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:.01666667 angle:.5]]];
                
                [ray1 setZOrder:-1];
                [ray1 setScale:4];
                [ray1 setOpacity:150];
                [ray1 setVisible:true];
                [ray1 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:.01666667 angle:-.5]]];
            })];
            
            
            
            
            
            
            [starCountLabel runAction:[CCSequence actions:[CCRepeat actionWithAction:[CCSequence actions:increaseNumber,
                                                                                      [CCDelayTime actionWithDuration:.0166667],
                                                                                      nil] times:(finalScore-[[UserWallet sharedInstance] getBalance])/rateOfScoreIncrease],setNumber,displayParticles,
                                       
                                       [CCDelayTime actionWithDuration:.8],
                                       
                                       
                                       
                                       [CCCallBlock actionWithBlock:(^{
                [mPopup runAction:[CCEaseSineIn actionWithAction:[CCMoveTo actionWithDuration:.7 position:ccp(480, -19)]]];
                [[ObjectiveManager sharedInstance] setCurrentObjectiveGroupNumber: [[ObjectiveManager sharedInstance] currentObjectiveGroupNumber] + 1];
            })],
                                       
                                       [CCDelayTime actionWithDuration:.5],
                                       
                                       [CCCallBlock actionWithBlock:(^{
                [self createNewPopup];
                [missionCompletionScreen addChild:mPopup];
                [mPopup runAction:[CCEaseElasticInOut actionWithAction:[CCMoveTo actionWithDuration:1.1 position:ccp(0, -19)]]];
            })],
                                       
                                       [CCDelayTime actionWithDuration:.35],
                                       
                                       [CCCallBlock actionWithBlock:(^{
                
                [self playSound:@"popupSwoosh.mp3" shouldLoop:false pitch:1];
            })],
                                       
                                       [CCDelayTime actionWithDuration:1-.35],
                                       /*
                                        [CCCallBlock actionWithBlock:(^{
                                        [ray0 setRotation:.5];
                                        [ray0 setZOrder:-1];
                                        [ray0 setScale:4];
                                        [ray0 setOpacity:150];
                                        [ray0 setVisible:true];
                                        [ray0 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:.01666667 angle:.5]]];
                                        
                                        [ray1 setZOrder:-1];
                                        [ray1 setScale:4];
                                        [ray1 setOpacity:150];
                                        [ray1 setVisible:true];
                                        [ray1 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:.01666667 angle:-.5]]];
                                        
                                        })],
                                        
                                        
                                        [CCDelayTime actionWithDuration:.5],*/
                                       
                                       
                                       
                                       [CCCallBlock actionWithBlock:(^{
                [DataStorage storeData];
                CCMenuItem *quit = [CCMenuItemImage
                                    itemWithNormalImage:@"done.png" selectedImage:@"donepressed.png"
                                    target:self selector:@selector(pushedContinueButton)];
                quit.position = ccp(336, -quit.boundingBox.size.height);
                [quit runAction:[CCEaseBounceInOut actionWithAction:[CCMoveTo actionWithDuration:.7 position:ccp(336, 20)]]];
                
                
                CCMenu* menu = [CCMenu menuWithItems:quit, nil];
                menu.position = ccp(0, 0);
                [missionCompletionScreen addChild:menu];
            })],
                                       
                                       
                                       nil]];
            
            
            
        })],
                           
                           
                           
                           nil];
        
        //id stuffAfterExplosion = [CCSequence actions:
        
        
        
        
        [mPopup runAction: [CCSequence actions:
                            [CCEaseElasticInOut actionWithAction:[CCMoveTo actionWithDuration:1.1 position:ccp(0, -19)]],
                            
                            changeChecks,
                            nil]];
        
        [mPopup runAction: [CCSequence actions:
                            
                            [CCDelayTime actionWithDuration:.35],
                            
                            [CCCallBlock actionWithBlock:(^{
            
            [self playSound:@"popupSwoosh.mp3" shouldLoop:false pitch:1];
        })],
                            
                            [CCDelayTime actionWithDuration:.6-.35],
                            
                            [CCCallBlock actionWithBlock:(^{
            
            //[self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
        })],
                            nil]];
        
        
        
        /*
         id moveLoadingLabelToStartPosition = [CCCallBlock actionWithBlock:(^{
         [loadingHelperTextLabel setPosition:startPosition];
         })];
         
         id repeatScrollingLeftAction = [CCCallBlock actionWithBlock:(^{
         [loadingHelperTextLabel runAction: [CCRepeatForever actionWithAction:[CCSequence actions:
         [CCMoveTo actionWithDuration:loadingHelperLabelMoveTime*loadingHelperTextLabel.boundingBox.size.width/529.313538 position:ccp(-loadingHelperTextLabel.boundingBox.size.width-20,loadingHelperTextLabel.position.y)],
         moveLoadingLabelToStartPosition,
         nil]]];
         })];
         */
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        if (IS_IPHONE_5)
            missionCompletionScreen.position = ccpAdd(missionCompletionScreen.position, ccp(HALF_IPHONE_5_ADDITIONAL_WIDTH,0));
        [self addChild:missionCompletionScreen];        
        
        
	}
	return self;
}


-(void)createNewPopup {
    mPopup = [[ObjectiveManager sharedInstance] createMissionPopupWithX:false withDark:false];
    
    mPopup.position = ccp(-480, -19);
}

- (void) addToStarInt:(int)whatToAdd {
    starIntForAnimation += whatToAdd;
    coinPitchCounter++;
    if (coinPitchCounter >= 11) {
        coinPitchCounter = 0;
        coinPitch += .12;
        shouldPlayCoinSound = true;
    } else {
        shouldPlayCoinSound = false;
    }
}



- (void) pushedContinueButton {
    [missionCompletionScreen removeFromParentAndCleanup:true];
    [[CCDirector sharedDirector] popScene];
}


- (NSString*)commaInt:(int)num {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:[NSNumber numberWithInteger:num]];
}


- (int)RandomBetween:(int)minvalue maxvalue:(int)maxvalue  {
    int randomNumber = minvalue+  arc4random() % (1+maxvalue-minvalue);
    return randomNumber;
}


- (ALuint)playSound:(NSString*)soundFile shouldLoop:(bool)shouldLoop pitch:(float)pitch{
    //[Kamcord playSound:soundFile loop:shouldLoop];
    if (shouldLoop)
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:soundFile loop:YES];
    else
        return [[SimpleAudioEngine sharedEngine]playEffect:soundFile pitch:pitch pan:0 gain:1];
    return 0;
}

@end