//
//  MainMenuLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright Clayton Schubiner 2012. All rights reserved.
//

#import "MainMenuLayer.h"
#import "GameplayLayer.h"
#import "Tutorial.h"
#import "StoreItem.h"
#import "StoreManager.h"
#import "UserWallet.h"
#import "PowerupManager.h"
#import "DataStorage.h"
#import "PlayerStats.h"
#import "UpgradeItem.h"
#import "UpgradeManager.h"
#import "UpgradeCell.h"

#define tutorialLayerTag    1001
#define levelLayerTag       1002
#define upgradeAlertTag     1003

const float musicVolumeMainMenu = 1;
const float effectsVolumeMainMenu = 1;

// HelloWorldLayer implementation
@implementation MainMenuLayer {
    StoreManager *storeManager;
    BOOL muted;
    CCLayer *upgradeLayer;
    CGPoint swipeBeginPoint;
    CGPoint swipeEndPoint;
    CGPoint startingUpgradeLayerPos;
    float upgradeLayerHeight;
    NSMutableArray* cells;
    bool didFingerMove;
    int lastIndexTapped;
    CCLabelTTF* totalStars;
}

// returns a singleton scene
+ (CCScene *)scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuLayer *layer = [MainMenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//- (CCLayer*)createCellWithTitle:(NSString*)title spriteName:(NSString*)spriteName readableCost:(NSString*)readableCost {

- (void) initUpgradeLayer {
    upgradeLayer = [[CCLayer alloc] init];
    startingUpgradeLayerPos = ccp(960, 640);
    [upgradeLayer setPosition:startingUpgradeLayerPos];
    //[upgradeLayer setContentSize:CGSizeMake(480, 10)];
    
    NSMutableArray *upgradeItems = [[UpgradeManager sharedInstance] upgradeItems];

    cells = [[NSMutableArray alloc] init];
    
    for (UpgradeItem* item in upgradeItems) {
        UpgradeCell *cell = [[UpgradeCell alloc] initWithUpgradeItem:item];
        [cells addObject:cell];
    }
    
    upgradeLayerHeight = 0;
    for (int i = 0; i < [cells count]; i++) {
        CCLayer* cell = (CCLayer*)[cells objectAtIndex:i];
        [upgradeLayer addChild:cell];
        [cell setPosition:ccp(0, -80*i - 55)];
        upgradeLayerHeight += 80;
    }
    
    [self refreshUpgradeCells];
}

- (void)refreshUpgradeCells {
    NSMutableArray *upgradeItems = [[UpgradeManager sharedInstance] upgradeItems];
    for (int i = 0; i < [cells count]; i++) {
        UpgradeCell *cell = [cells objectAtIndex:i];
        UpgradeItem *item = [upgradeItems objectAtIndex:i];
        
        if ([item.prices count] == 1) {
            if (item.level == 0)
                [cell.levelLabel setString:@"Inactive"];
            else
                [cell.levelLabel setString:@"Active"];
            
            [cell.levelLabel setPosition:ccp(90 + [cell.levelLabel boundingBox].size.width/2, -58)];
        } else {
            [cell.levelLabel setString:[NSString stringWithFormat:@"Level %d", item.level]];
        }
        if (item.level == [item.prices count])
            [cell.levelLabel setColor:ccGREEN];
        
        if ((item.level < [item.prices count])) {
            [cell.priceLabel setString:[self commaInt:[[item.prices objectAtIndex:item.level] intValue]]];
        }  else {
            
            if (cell.coinSprite)
                [cell.coinSprite setVisible:false];
            
            if (cell.priceLabel)
                [cell.priceLabel setString:@""];
        }
    }
    
    [totalStars setString:[NSString stringWithFormat:@"%@",[self commaInt:[[UserWallet sharedInstance]getBalance]]]];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        swipeBeginPoint = location;
        didFingerMove = false;
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        swipeEndPoint = location;
        didFingerMove = true;
        CGPoint swipeVector = ccpSub(swipeEndPoint, swipeBeginPoint);
        [upgradeLayer setPosition:CGPointMake(upgradeLayer.position.x, ccpAdd(upgradeLayer.position, swipeVector).y)];
        swipeBeginPoint = swipeEndPoint;
        if (upgradeLayer.position.y < startingUpgradeLayerPos.y)
            [upgradeLayer setPosition:startingUpgradeLayerPos];
        if (upgradeLayer.position.y > startingUpgradeLayerPos.y + upgradeLayerHeight - (320 - 55))
            [upgradeLayer setPosition:ccp(upgradeLayer.position.x, startingUpgradeLayerPos.y + upgradeLayerHeight - (320 - 55))];
        
        //CCLOG(@"pos: %f, maxPerhaps; %f", upgradeLayer.position.y, startingUpgradeLayerPos.y + upgradeLayerHeight);
        //CCLOG(@"startingPos: %f, height; %f", startingUpgradeLayerPos.y, upgradeLayerHeight);
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        if (!didFingerMove) {
            
            //for (CCLayer* laya in cells) {
                //CGRect newRect = CGRectMake(upgradeLayer.boundingBox.origin.x + 960, upgradeLayer.boundingBox.origin.x + 680, upgradeLayer.boundingBox.size.width, upgradeLayer.boundingBox.size.height);
            //CCLOG(@"boundingBox: %@", upgradeLayer.boundingBox);
            //CCLOG(@"touch location: %@", location);
            //CCLOG(@"layer position: %@", layer.position);
            
            int i = 0;
            for (CCLayer* laya in cells) {
                CGRect box = laya.boundingBox;
                
                box = CGRectMake(box.origin.x + upgradeLayer.boundingBox.origin.x, box.origin.y + upgradeLayer.boundingBox.origin.y, box.size.width, box.size.height);
                
                CGPoint point = ccp(location.x + layer.position.x + 960*2, location.y + layer.position.y + 320*3 - 160*1.5);
                
                
                //CCLOG(@"cell y: %f, height: %f", box.origin.y, box.size.height);
                //CCLOG(@"point y: %f", point.y);
                
                if (CGRectContainsPoint(box, point) && point.y < 720-55) {
                    
                    //if (CGRectContainsPoint(upgradeLayer.boundingBox, ccp(location.x + layer.position.x + 960*2, location.y + layer.position.y + 320*3))) {
                    
                    lastIndexTapped = i;
                    
                    NSMutableArray *upgradeItems = [[UpgradeManager sharedInstance] upgradeItems];
                    UpgradeItem *item = [upgradeItems objectAtIndex:lastIndexTapped];
                    
                    if (item.level < [item.prices count]) {
                        UIAlertView* alertview2 = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:item.title, lastIndexTapped] message:item.description delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Purchase", nil];
                        [alertview2 setTag:upgradeAlertTag];
                        [alertview2 show];
                    }
                    
                }
                i++;
            }
        }
    }
}

// on "init" you need to initialize your instance
- (id)init {
	if (self = [super init]) {
        
        self.isTouchEnabled = true;
        
        [self initUpgradeLayer];
        
        layer = (CCLayer*)[CCBReader nodeGraphFromFile:@"MainMenuScrolling.ccb" owner:self];
        [layer addChild:upgradeLayer];
        
        CCSprite* upgradeTopBar = [CCSprite spriteWithFile:@"upgradesHeader.png"];
        [layer addChild:upgradeTopBar];
        [upgradeTopBar setPosition:ccp(960 + upgradeTopBar.width/2, 640-upgradeTopBar.height/2)];
        

        //CCMenuItemImage* backButton = [[CCMenuItemImage alloc] initFromNormalImage:@"upgrade.png" selectedImage:@"upgrade.png" disabledImage:@"upgrade.png" target:self selector:@selector(pressedBackButton:)];
        
        CCMenuItem *back = [CCMenuItemImage 
                                    itemFromNormalImage:@"upgrade.png" selectedImage:@"upgrade.png" 
                                    target:self selector:@selector(pressedBackButton:)];

        back.rotation = -90;
        back.scale = .5;
        back.position = ccp(720 + 28, 480 - 28);
        
        CCMenu *menu = [CCMenu menuWithItems:back, nil];
        
        [layer addChild:menu];
        
        
        
        CCLabelBMFont* hello4 = [[CCLabelBMFont alloc] initWithString:@"Upgrades" fntFile:@"betaFont2.fnt"];
        [hello4 setScale:.8];
        hello4.position = ccp(1200, 640-30);
        [layer addChild:hello4];
        
        
        CCSprite* starSprite = [CCSprite spriteWithFile:@"star1.png"];
        [starSprite setScale:.2];
        [layer addChild:starSprite];
        [starSprite setPosition:ccp(1200 - 480/2 + 480-starSprite.width/2-8, 640-29)];
        
        
        totalStars = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",[self commaInt:[[UserWallet sharedInstance]getBalance]]] fontName:@"Marker Felt" fontSize:22];
        [layer addChild: totalStars];
        [totalStars setPosition:ccp(1200 - 480/2 + 480 - 40 - [totalStars boundingBox].size.width/2, 640-30)];
        
        NSMutableArray *highScores = [[PlayerStats sharedInstance] getScores];
        
        int highScore1Int;
        int highScore2Int;
        int highScore3Int;
        int highScore4Int;
        int highScore5Int;
        int highScore6Int;
        int highScore7Int;
        int highScore8Int;
        int highScore9Int;
        int highScore10Int;
        
        if (highScores && [highScores count] > 0) {
            highScore1Int = [[highScores objectAtIndex:0] intValue];
        }
        if (highScores && [highScores count] > 1) {
            highScore2Int = [[highScores objectAtIndex:1] intValue];
        }
        if (highScores && [highScores count] > 2) {
            highScore3Int = [[highScores objectAtIndex:2] intValue];
        }
        if (highScores && [highScores count] > 3) {
            highScore4Int = [[highScores objectAtIndex:3] intValue];
        }
        if (highScores && [highScores count] > 4) {
            highScore5Int = [[highScores objectAtIndex:4] intValue];
        }
        if (highScores && [highScores count] > 5) {
            highScore6Int = [[highScores objectAtIndex:5] intValue];
        }
        if (highScores && [highScores count] > 6) {
            highScore7Int = [[highScores objectAtIndex:6] intValue];
        }
        if (highScores && [highScores count] > 7) {
            highScore8Int = [[highScores objectAtIndex:7] intValue];
        }
        if (highScores && [highScores count] > 8) {
            highScore9Int = [[highScores objectAtIndex:8] intValue];
        }
        if (highScores && [highScores count] > 9) {
            highScore10Int = [[highScores objectAtIndex:9] intValue];
        }
        
        if (highScore1Int != 0) {
            [highScore1Label setString:[NSString stringWithFormat:@"%i  CRAIG", highScore1Int]];
        }
        if (highScore2Int != 0) {
            [highScore2Label setString:[NSString stringWithFormat:@"%i  MICHAEL", highScore2Int]];
        }
        if (highScore3Int != 0) {
            [highScore3Label setString:[NSString stringWithFormat:@"%i  JEFF", highScore3Int]];
        }
        if (highScore4Int != 0) {
            [highScore4Label setString:[NSString stringWithFormat:@"%i  CLAY", highScore4Int]];
        }
        if (highScore5Int != 0) {
            [highScore5Label setString:[NSString stringWithFormat:@"%i  ALEX", highScore5Int]];
        }
        if (highScore6Int != 0) {
            [highScore6Label setString:[NSString stringWithFormat:@"%i  CLAY", highScore6Int]];
        }
        if (highScore7Int != 0) {
            [highScore7Label setString:[NSString stringWithFormat:@"%i  CLAY", highScore7Int]];
        }
        if (highScore8Int != 0) {
            [highScore8Label setString:[NSString stringWithFormat:@"%i  JEFF", highScore8Int]];
        }
        if (highScore9Int != 0) {
            [highScore9Label setString:[NSString stringWithFormat:@"%i", highScore9Int]];
        }
        if (highScore10Int != 0) {
            [highScore10Label setString:[NSString stringWithFormat:@"%i", highScore10Int]];
        }
        
        [layer setPosition:ccp(-480, -320)];
        [self addChild:layer];
        
        [[CDAudioManager sharedManager] playBackgroundMusic:@"menumusic_new.mp3" loop:YES];
        
        storeManager = [[StoreManager alloc] init];
        
        StoreItem *magnet = [[StoreItem alloc] init];
        magnet.itemID = 0;
        magnet.title = @"Magnet";
        magnet.price = 20;
        magnet.description = @"Pull coins toward you as you fly.";
        
        StoreItem *immunity = [[StoreItem alloc] init];
        immunity.itemID = 1;
        immunity.title = @"Immunity";
        immunity.price = 50;
        immunity.description = @"Become temporarily invincible to asteroids.";
        
        [storeManager.storeItems addObject:magnet];
        [storeManager.storeItems addObject:immunity];
	}
	return self;
}

- (void)magnetButtonPressed {
    int currCoins = [[UserWallet sharedInstance] getBalance];
    CCLOG(@"magnetButtonPressed");
    [storeManager purchaseItemWithID:0];
    int newCoins = [[UserWallet sharedInstance] getBalance];
    if (currCoins - newCoins == [[storeManager.storeItems objectAtIndex:0] price]) {
        [[PowerupManager sharedInstance] addMagnet];
    }
}

- (void)immunityButtonPressed {
    int currCoins = [[UserWallet sharedInstance] getBalance];
    CCLOG(@"immunityButtonPressed");
    [storeManager purchaseItemWithID:1];
    int newCoins = [[UserWallet sharedInstance] getBalance];
    if (currCoins - newCoins == [[storeManager.storeItems objectAtIndex:1] price]) {
        [[PowerupManager sharedInstance] addImmunity];
    }
}

// this is called (magically?) by cocosbuilder when the start button is pressed
- (void)startGame:(id)sender {
    [[PlayerStats sharedInstance] addPlay];
    CCLOG(@"number of plays ever: %i", [[PlayerStats sharedInstance] getPlays]);
    [((AppDelegate*)[[UIApplication sharedApplication]delegate])setChosenLevelNumber:0];

    if ([[PlayerStats sharedInstance] getPlays] == 1) {
        [((AppDelegate*)[[UIApplication sharedApplication]delegate])setIsInTutorialMode:TRUE];
    }
    else [((AppDelegate*)[[UIApplication sharedApplication]delegate])setIsInTutorialMode:FALSE];

    CCLOG(@"GameplayLayerScene launched, game starting");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

- (void)pressedBackButton:(id)sender {
    [Flurry logEvent:@"Went back to menu from store"];
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(-480,-320)];
    id ease = [CCEaseInOut actionWithAction:action rate:2];
    [layer runAction: ease];
}

- (void)pressedStoreButton:(id)sender {
    [Flurry logEvent:@"Opened Store"];
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(-960,-320)];
    id ease = [CCEaseSineInOut actionWithAction:action]; //does this "CCEaseSineInOut" look better than the above "CCEaseInOut"???
    [layer runAction: ease];
}

- (void)pressedScoresButton:(id)sender {
    [Flurry logEvent:@"Opened High Scores"];
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(0,-320)];
    id ease = [CCEaseSineInOut actionWithAction:action];
    [layer runAction: ease];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == upgradeAlertTag) {
        if (buttonIndex == 1) {
            NSMutableArray *upgradeItems = [[UpgradeManager sharedInstance] upgradeItems];
            UpgradeItem *item = [upgradeItems objectAtIndex:lastIndexTapped];
            
            int curBalance = [[UserWallet sharedInstance] getBalance];
            if (curBalance >= [[item.prices objectAtIndex:item.level] intValue]) {
                
                [[UserWallet sharedInstance] setBalance:curBalance - [[item.prices objectAtIndex:item.level] intValue]];
                [item setLevel:[item level] + 1];
                [self refreshUpgradeCells];
                [DataStorage storeData];
            }
            //UIAlertView* alertview3 = [[UIAlertView alloc] initWithTitle:@"Congratz yo" message:@"You bought something" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            //[alertview3 show];

        }
    } else {
        if (buttonIndex == 1) {
            NSURL *url = [NSURL URLWithString:@"http://www.surveymonkey.com/s/PBD9L5H"];
            [[UIApplication sharedApplication] openURL:url];
            [Flurry logEvent:@"Launched survey from main menu"];
        }
    }
    
}

- (void)pressedLevelsButton: (id) sender {
    [Flurry logEvent:@"Pressed Levels Button"];
    CCLOG(@"levels layer launched");
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(0,0)];
    id ease = [CCEaseSineInOut actionWithAction:action];
    [layer runAction: ease];
    
}

-(void)moveLevelsLayerRight {
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(layer.position.x-480,0)];
    id ease = [CCEaseSineInOut actionWithAction:action];
    [layer runAction: ease];
}

-(void)moveLevelsLayerLeft {
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(layer.position.x+480,0)];
    id ease = [CCEaseSineInOut actionWithAction:action];
    [layer runAction: ease];
}

- (void)startLevelNumber:(int)levelNum {
    [((AppDelegate*)[[UIApplication sharedApplication]delegate])setChosenLevelNumber:levelNum];
    NSLog(@"started level %d",levelNum);
    [Flurry logEvent:[NSString stringWithFormat:@"Started Level %d",levelNum]];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

-(void)startLevel1{
    [self startLevelNumber:1];
}
-(void)startLevel2{
    [self startLevelNumber:2];
}



- (void)pressedSendFeedback: (id) sender {
    [Flurry logEvent:@"Pressed Survey Button on main menu"];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Entering survey"
                          message: @"Thanks for taking the time to answer our survey! Any input is helpful. \n-Clay, Alex, Jeff, Michael, and Craig."
                          delegate: self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Continue",nil];
    [alert show];
    [alert release];
   
}

- (void)pressedTutorialButton: (id) sender {
    [Flurry logEvent:@"Pressed Tutorial Button"];
    [((AppDelegate*)[[UIApplication sharedApplication]delegate])setIsInTutorialMode:TRUE];
    CCLOG(@"tutorial scene launched, game starting");
    
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[Tutorial scene]]];
    
    //tutorialLayer = (CCLayer*)[CCBReader nodeGraphFromFile:@"TutorialLayer.ccb" owner:self];
    //[tutorialLayer setTag:tutorialLayerTag];
    //[self addChild:tutorialLayer];
    
    // [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

- (void)removeTutorialLayer {
    [self removeChildByTag:tutorialLayerTag cleanup:NO];
}

- (void)toggleMute {
    muted = !muted;
    if (!muted) {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:musicVolumeMainMenu];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:effectsVolumeMainMenu];
    } else {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
    }
}

- (NSString*)commaInt:(int)num {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:[NSNumber numberWithInteger:num]];
}

- (void)dealloc {
	[super dealloc];
}

@end