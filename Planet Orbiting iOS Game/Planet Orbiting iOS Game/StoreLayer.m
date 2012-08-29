//
//  CreditsLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/25/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "StoreLayer.h"
#import "UpgradeManager.h"
#import "UpgradeItem.h"
#import "UpgradeCell.h"
#import "UserWallet.h"
#import "CCDirector.h"
#import "MainMenuLayer.h"
#import "SimpleAudioEngine.h"
#import "DataStorage.h"

@implementation StoreLayer {
    
}

// returns a singleton scene
+ (CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StoreLayer *layer = [StoreLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene.
	return scene;
}

/* On "init," initialize the instance */
- (id)init {
	// always call "super" init.
	// Apple recommends to re-assign "self" with the "super" return value
	if ((self = [super init])) {
        self.isTouchEnabled= TRUE;
        
        
        CCSprite* topBar = [CCSprite spriteWithFile:@"banner.png"];
        [self addChild:topBar];
        [topBar setPosition: ccp(240, 320 - topBar.boundingBox.size.height/2 + 1)];
        
        NSString* stringToUse;
        stringToUse = @"STAR STORE";
        
        CCLabelTTF* pauseText = [CCLabelTTF labelWithString:stringToUse fontName:@"HelveticaNeue-CondensedBold" fontSize:31];
        [self addChild:pauseText];
        pauseText.position = ccp(240, 299);
        
        
        
        CCSprite* starSprite = [CCSprite spriteWithFile:@"staricon.png"];
        [starSprite setScale:.6];
        [self addChild:starSprite];
        [starSprite setPosition:ccp(480 - 22, 301)];
        
        CCLabelTTF* totalStars = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",[self commaInt:[[UserWallet sharedInstance]getBalance]]] fontName:@"HelveticaNeue-CondensedBold" fontSize:22];
        [self addChild: totalStars];
        [totalStars setAnchorPoint:ccp(1, .5)];
        [totalStars setPosition:ccp(480 - 40, 299)];
        
        
        
        CCMenuItem *quit = [CCMenuItemImage
                            itemWithNormalImage:@"back.png" selectedImage:@"backpressed.png"
                            target:self selector:@selector(backButtonPressed)];
        quit.position = ccp(41, 299);
        
        
        CCMenuItem *perks = [CCMenuItemImage
                             itemWithNormalImage:@"back.png" selectedImage:@"backpressed.png"
                             target:self selector:@selector(pressedPerksButton)];
        perks.position = ccp(120, 200);
        
        CCMenuItem *upgrades = [CCMenuItemImage
                             itemWithNormalImage:@"back.png" selectedImage:@"backpressed.png"
                             target:self selector:@selector(pressedUpgradesButton)];
        upgrades.position = ccp(240, 200);
        
        CCMenuItem *rocketships = [CCMenuItemImage
                             itemWithNormalImage:@"back.png" selectedImage:@"backpressed.png"
                             target:self selector:@selector(pressedRocketShipsButton)];
        rocketships.position = ccp(360, 200);
        
        CCMenuItem *rockettrails = [CCMenuItemImage
                             itemWithNormalImage:@"back.png" selectedImage:@"backpressed.png"
                             target:self selector:@selector(pressedRocketTrailsButton)];
        rockettrails.position = ccp(120, 100);
        
        CCMenuItem *powerups = [CCMenuItemImage
                             itemWithNormalImage:@"back.png" selectedImage:@"backpressed.png"
                             target:self selector:@selector(pressedPowerupsButton)];
        powerups.position = ccp(240, 100);
        
        CCMenuItem *stars = [CCMenuItemImage
                             itemWithNormalImage:@"back.png" selectedImage:@"backpressed.png"
                             target:self selector:@selector(pressedStarsButton)];
        stars.position = ccp(360, 100);
        
        
        CCMenu* menu = [CCMenu menuWithItems:quit, perks, upgrades, rocketships, rockettrails, powerups, stars, nil];
        menu.position = ccp(0, 0);
        
        [self addChild:menu];
        
        
        
        if ([((AppDelegate*)[[UIApplication sharedApplication]delegate]) getShouldPlayMenuMusic])
            [[CDAudioManager sharedManager] playBackgroundMusic:@"menumusic_new.mp3" loop:YES];
  
        
//        [self schedule:@selector(Update:) interval:0];
	}
	return self;
}

- (void)pressedPerksButton {
    [Flurry logEvent:@"Pressed Perks Button"];
    [[UpgradeManager sharedInstance] setButtonPushed:5];
    [self pressedAnUpgradeButton];
}

- (void)pressedRocketShipsButton {
    [Flurry logEvent:@"Pressed Rocketships Button"];
    [[UpgradeManager sharedInstance] setButtonPushed:1];
    [self pressedAnUpgradeButton];
}

- (void)pressedUpgradesButton {
    [Flurry logEvent:@"Pressed Upgrades Button"];
    [[UpgradeManager sharedInstance] setButtonPushed:2];
    [self pressedAnUpgradeButton];
}

- (void)pressedPowerupsButton {
    [Flurry logEvent:@"Pressed Powerups Button"];
    [[UpgradeManager sharedInstance] setButtonPushed:3];
    [self pressedAnUpgradeButton];
}

- (void)pressedStarsButton {
    [Flurry logEvent:@"Pressed Stars Button"];
    [[UpgradeManager sharedInstance] setButtonPushed:4];
    [self pressedAnUpgradeButton];
}

- (void)pressedRocketTrailsButton {
    [Flurry logEvent:@"Pressed Rocket Trails Button"];
    [[UpgradeManager sharedInstance] setButtonPushed:0];
    [self pressedAnUpgradeButton];
}

- (void)pressedAnUpgradeButton {
    
    [self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
    [[CCDirector sharedDirector] replaceScene:[UpgradesLayer scene]];//[CCTransitionCrossFade transitionWithDuration:0.5 scene:[UpgradesLayer scene]]];
}

- (void) backButtonPressed {
    [self playSound:@"doorClose2.mp3" shouldLoop:false pitch:1];
    [((AppDelegate*)[[UIApplication sharedApplication]delegate]) setShouldPlayMenuMusic:false];
    [[CCDirector sharedDirector] replaceScene:[MainMenuLayer scene]];//[CCTransitionCrossFade transitionWithDuration:0.5 scene: [MainMenuLayer scene]]];
}

- (void) Update:(ccTime)dt {
    
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