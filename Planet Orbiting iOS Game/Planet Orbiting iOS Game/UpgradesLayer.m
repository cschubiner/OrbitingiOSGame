//
//  GameplayLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright Clayton Schubiner 2012. All rights reserved.

#import "UpgradesLayer.h"
#import "UpgradeManager.h"
#import "UpgradeItem.h"
#import "UpgradeCell.h"
#import "UserWallet.h"
#import "CCDirector.h"
#import "MainMenuLayer.h"
#import "SimpleAudioEngine.h"
#import "DataStorage.h"

@implementation UpgradesLayer {
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
	UpgradesLayer *layer = [UpgradesLayer node];
    
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
        indexPushed = [[UpgradeManager sharedInstance] buttonPushed];
        
        [[UserWallet sharedInstance] setBalance:10000];
        
        scrollView = [[CCLayer alloc] init];
        [self addChild:scrollView];
        
        CCSprite* topBar = [CCSprite spriteWithFile:@"banner.png"];
        [self addChild:topBar];
        [topBar setPosition: ccp(240, 320 - topBar.boundingBox.size.height/2 + 1)];
        
        NSString* stringToUse;
        
        if (indexPushed == 0)
            stringToUse = @"SPACESHIP TRAILS";
        else if (indexPushed == 1)
            stringToUse = @"ROCKETSHIPS";
        else if (indexPushed == 2)
            stringToUse = @"UPGRADES";
        else if (indexPushed == 3)
            stringToUse = @"POWERUPS";
        else if (indexPushed == 4)
            stringToUse = @"STARS";
        else if (indexPushed == 5)
            stringToUse = @"PERKS";
        
        CCLabelTTF* pauseText = [CCLabelTTF labelWithString:stringToUse fontName:@"HelveticaNeue-CondensedBold" fontSize:32];
        [self addChild:pauseText];
        pauseText.position = ccp(240, 299);
        
        CCSprite* botBar = [CCSprite spriteWithFile:@"upgradeFooter.png"];
        [self addChild:botBar];
        botBar.scaleY = .5;
        [botBar setPosition: ccp(240, botBar.boundingBox.size.height/2)];
        
        CCMenuItem *quit = [CCMenuItemImage
                            itemFromNormalImage:@"back.png" selectedImage:@"backpressed.png"
                            target:self selector:@selector(backButtonPressed)];
        quit.position = ccp(60, 299);
        //quit.scale = 1.7;
        
        CCMenu* menu = [CCMenu menuWithItems:quit, nil];
        menu.position = ccp(0, 0);
        
        [self addChild:menu];
        
        CCSprite* starSprite = [CCSprite spriteWithFile:@"star1.png"];
        [starSprite setScale:.2];
        [self addChild:starSprite];
        [starSprite setPosition:ccp(480 - 10 - starSprite.boundingBox.size.width/2, 299)];
        
        totalStars = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",[self commaInt:[[UserWallet sharedInstance]getBalance]]] fontName:@"HelveticaNeue-CondensedBold" fontSize:22];
        [self addChild: totalStars];
        [totalStars setAnchorPoint:ccp(1, .5)];
        [totalStars setPosition:ccp(480 - 10 - starSprite.boundingBox.size.width - 5, 299)];
        
        [self initUpgradeLayer];
        
        
        
        [self initScrollStuff];
        
        
        
        [self schedule:@selector(Update:) interval:0];
	}
	return self;
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
    [((AppDelegate*)[[UIApplication sharedApplication]delegate]) setCameFromUpgrades:true];
    [[CCDirector sharedDirector] replaceScene:[MainMenuLayer scene]];//[CCTransitionCrossFade transitionWithDuration:0.5 scene: [MainMenuLayer scene]]];
}

- (void) initUpgradeLayer {
    scrollViewHeight = 0;
    NSMutableArray *upgradeItems = [[UpgradeManager sharedInstance] upgradeItems];
    
    upgradeIndecesHere = [[NSMutableArray alloc] init];
    cells = [[NSMutableArray alloc] init];
    
    for (UpgradeItem* item in upgradeItems) {
        if (item.type == indexPushed) {
            [upgradeIndecesHere addObject:[NSNumber numberWithInt:item.number]];
            UpgradeCell *cell = [[UpgradeCell alloc] initWithUpgradeItem:item];
            [cells addObject:cell];
            scrollViewHeight += 55;
        }
    }
    
    for (int i = 0; i < [cells count]; i++) {
        CCLayer* cell = (CCLayer*)[cells objectAtIndex:i];
        [scrollView addChild:cell];
        [cell setAnchorPoint:ccp(0, 1)];
        [cell setPosition:ccp(0, -55*i)];
    }
    
    //[self refreshUpgradeCells];
}


- (void)refreshUpgradeCells {

    [scrollView removeFromParentAndCleanup:true];
    scrollView = [[CCLayer alloc] init];
    [self addChild:scrollView];
    
    [self initUpgradeLayer];
    
    [totalStars setString:[NSString stringWithFormat:@"%@",[self commaInt:[[UserWallet sharedInstance]getBalance]]]];
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
            velocity*=.95;
            float counterScaler = 20/counter;
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
        if (position > startingCenter || position < endingCenter) {
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
        
        
        
        if (!moved && location.y < 275) {
            NSMutableArray* upgrades = [[UpgradeManager sharedInstance] upgradeItems];
            
            NSLog(@"scrollviewPos: %f, tap y value: %f", scrollView.position.y, location.y);
            float dif = scrollView.position.y - location.y;
            
            
            int totalUpgrades = [upgradeIndecesHere count];
            
            for (int i = 0; i < totalUpgrades; i++) {
                if (dif > 0 && dif < 55*(i + 1)) {
                    NSLog(@"dif: %f", dif);
                    [self tappedUpgrade:[upgrades objectAtIndex:[[upgradeIndecesHere objectAtIndex: i] intValue]]];
                    break;
                }
            }
            
        }
    }
}

- (void) tappedUpgrade:(UpgradeItem*)item {
    pushedItem = item;
    purchaseLayer = [self createPurchaseDialogWithItem:item];
    [self addChild:purchaseLayer];
    self.isTouchEnabled = false;
}

- (CCLayer*)createPurchaseDialogWithItem: (UpgradeItem*) item {
    purchaseLayer = [[CCLayer alloc] init];
    
    CCSprite* popup = [CCSprite spriteWithFile:@"missionsBG.png"];
    popup.position = ccp(240, 160);
    [purchaseLayer addChild:popup];
    
    CCLabelTTF* title = [CCLabelTTF labelWithString:item.title fontName:@"HelveticaNeue-CondensedBold" fontSize:22];
    title.position = ccp(240, 252);
    [purchaseLayer addChild:title];
    
    CCLabelTTF* label0 = [CCLabelTTF labelWithString:item.description dimensions:CGSizeMake(273, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    label0.position = ccp(240, 160);
    [purchaseLayer addChild:label0];
    
    CCMenuItem *resume;
    
    
    
    if (item.purchased) {
        
        int pushed = [[UpgradeManager sharedInstance] buttonPushed];
        if (pushed == 0 || pushed == 1 || pushed == 5) {
            resume = [CCMenuItemImage
                      itemFromNormalImage:@"equip.png" selectedImage:@"equippressed.png"
                      target:self selector:@selector(pressedEquipButton)];
        } else {
            
            resume = [CCMenuItemImage
                      itemFromNormalImage:@"purchasedisabled.png" selectedImage:@"purchasedisabled.png"
                      target:self selector:@selector(pressedDisabledButton)];
        }
        
    } else if ([[UserWallet sharedInstance] getBalance] < pushedItem.price) {
        
        resume = [CCMenuItemImage
                  itemFromNormalImage:@"purchasedisabled.png" selectedImage:@"purchasedisabled.png"
                  target:self selector:@selector(pressedDisabledButton)];
    } else {
        resume = [CCMenuItemImage
                  itemFromNormalImage:@"purchase.png" selectedImage:@"purchasepressed.png"
                  target:self selector:@selector(pressedPurchaseButton)];
    }
    
    
    resume.scale = 1.3;
    resume.position = ccp(340, 22);
    
    CCMenuItem *quit = [CCMenuItemImage
                        itemFromNormalImage:@"cancel.png" selectedImage:@"cancelpressed.png"
                        target:self selector:@selector(removePurchasePopup)];
    quit.scale = 1.3;
    quit.position = ccp(140, 22);
    
    
    CCMenu* menu = [CCMenu menuWithItems:resume, quit, nil];
    menu.position = ccp(0, 0);
    [purchaseLayer addChild:menu];
    
    return purchaseLayer;
}

- (void) removePurchasePopup {
    [purchaseLayer removeFromParentAndCleanup:true];
    self.isTouchEnabled = true;
}

- (void) pressedDisabledButton {
    
}

- (void) pressedEquipButton {
    for (int i = 0; i < [upgradeIndecesHere count]; i++) {
        [[UpgradeManager sharedInstance] setUpgradeIndex:[[upgradeIndecesHere objectAtIndex:i] intValue] equipped:false];
    }
    [[UpgradeManager sharedInstance] setUpgradeIndex:pushedItem.number purchased:true equipped:true];
    
    [DataStorage storeData];
    [self refreshUpgradeCells];
    
    [self removePurchasePopup];
}

- (void) pressedPurchaseButton {
    int curBalance = [[UserWallet sharedInstance] getBalance];
    
    
    
    [self playSound:@"purchase.wav" shouldLoop:false pitch:1];
    int newBalance = curBalance - pushedItem.price;
    [[UserWallet sharedInstance] setBalance:newBalance];
    
    int pushed = [[UpgradeManager sharedInstance] buttonPushed];
    if (pushed == 0 || pushed == 1 || pushed == 5) {
        for (int i = 0; i < [upgradeIndecesHere count]; i++) {
            [[UpgradeManager sharedInstance] setUpgradeIndex:[[upgradeIndecesHere objectAtIndex:i] intValue] equipped:false];
        }
    }
    
    [[UpgradeManager sharedInstance] setUpgradeIndex:pushedItem.number purchased:true equipped:true];
    
    [self completeObjectiveFromGroupNumber:0 itemNumber:1];
    
    [DataStorage storeData];
    [self refreshUpgradeCells];
    
    
    
    [self removePurchasePopup];

}

/*
 
 -(void)pressedPurchaseButton:(id)sender {
 
 int curBalance = [[UserWallet sharedInstance] getBalance];
 if (curBalance >= item.price) {
 
 [self playSound:@"purchase.wav" shouldLoop:false pitch:1];
 int newBalance = curBalance - item.price;
 [[UserWallet sharedInstance] setBalance:newBalance];
 
 [self completeObjectiveFromGroupNumber:0 itemNumber:1];
 [Flurry logEvent:@"Purchased Item" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:newBalance],@"Coin Balance after purchase",item.title,@"Item Title",nil]];
 
 [DataStorage storeData];
 }
 
 [self removePopupView];
 }
 */

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
