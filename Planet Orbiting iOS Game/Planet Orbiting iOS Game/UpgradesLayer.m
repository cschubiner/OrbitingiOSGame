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
        
        CCLabelTTF* pauseText = [CCLabelTTF labelWithString:stringToUse fontName:@"HelveticaNeue-CondensedBold" fontSize:38];
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

- (void) initUpgradeLayer {
    scrollViewHeight = 0;
    NSMutableArray *upgradeItems = [[UpgradeManager sharedInstance] upgradeItems];
    
    cells = [[NSMutableArray alloc] init];
    
    for (UpgradeItem* item in upgradeItems) {
        if (item.type == indexPushed) {
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
    
    [self refreshUpgradeCells];
}


- (void)refreshUpgradeCells {
    //NSMutableArray *upgradeItems = [[UpgradeManager sharedInstance] upgradeItems];
    for (int i = 0; i < [cells count]; i++) {
        //UpgradeCell *cell = [cells objectAtIndex:i];
        //UpgradeItem *item = [upgradeItems objectAtIndex:i];
    }
    
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
    NSLog(@"velocity: %f, position: %f", velocity, position);
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










@end
