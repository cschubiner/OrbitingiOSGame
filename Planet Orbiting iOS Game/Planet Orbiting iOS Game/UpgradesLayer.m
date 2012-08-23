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

@implementation UpgradesLayer {
    CCLayer* scrollView;
    
    float screenHeight;
    float scrollViewHeight;
    float counter;
    float currentCenter;
    float startingCenter;
    float endingCenter;
    float position;
    float velocity;
    float enterVelocity;
    CGPoint swipeEndPoint;
    CGPoint swipeBeginPoint;
    bool isTouchingScreen;
    
    
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
        
        screenHeight = 280;
        scrollView = [[CCLayer alloc] init];
        [self addChild:scrollView];
        
        CCSprite* topBar = [CCSprite spriteWithFile:@"banner.png"];
        [self addChild:topBar];
        [topBar setPosition: ccp(240, 320 - topBar.boundingBox.size.height/2)];
        
        totalStars = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",[self commaInt:[[UserWallet sharedInstance]getBalance]]] fontName:@"Marker Felt" fontSize:22];
        [self addChild: totalStars];
        [totalStars setPosition:ccp(400 - [totalStars boundingBox].size.width/2, 320 - topBar.boundingBox.size.height/2)];
        
        CCSprite* starSprite = [CCSprite spriteWithFile:@"star1.png"];
        [starSprite setScale:.2];
        [self addChild:starSprite];
        [starSprite setPosition:ccp(420, 320 - topBar.boundingBox.size.height/2)];
        
        [self initUpgradeLayer];
        
        
        
        
        currentCenter = 320-topBar.boundingBox.size.height*.85-scrollViewHeight;
        [scrollView setPosition:CGPointMake(0, currentCenter)];
        startingCenter = currentCenter;
        endingCenter = startingCenter + scrollViewHeight - screenHeight;
        if (endingCenter < 0) {
            endingCenter = 0;
            endingCenter += startingCenter;
        }
        endingCenter = startingCenter*2-endingCenter;
        
        counter = 1;
        
        isTouchingScreen = false;
        
        
        
        
        
        [self schedule:@selector(Update:) interval:0];
	}
	return self;
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
        if (item.type == 0) {
            UpgradeCell *cell = [[UpgradeCell alloc] initWithUpgradeItem:item];
            [cells addObject:cell];
        }
    }
    
    
    for (int i = 0; i < [cells count]; i++) {
        CCLayer* cell = (CCLayer*)[cells objectAtIndex:i];
        [scrollView addChild:cell];
        [cell setPosition:ccp(0, 320+60-55*i)];
        scrollViewHeight += 55;
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
                //centerToUse = [self getGoodPosition];
            }
            currentCenter = [self getGoodPosition];
            
            float dif = currentCenter - position;
            
            if (dif == 0)
                return;
            if (fabsf(dif) <= .2) {
                velocity = 0;
                position = currentCenter;
            } else {
                if (fabsf(dif) <= 8)
                    dif *= 1.8;
                velocity = dif*.045*powf(counter, .6) + 1*enterVelocity/counter;
            }
            
        } else {
            enterVelocity = 0;
            velocity*=.88;
            float counterScaler = 10/counter;
            if (counterScaler > 1)
                counterScaler= 1;
            velocity*=counterScaler;
        }
    }
    
    position += velocity;
    [scrollView setPosition:CGPointMake(scrollView.position.x, position)];
    //NSLog(@"velocity: %f, position: %f", velocity, position);
    NSLog(@"cur center: %f", currentCenter);
    
    counter += .5;
    
}



- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
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
    if (position > startingCenter || position < endingCenter)
        return true;
    else
        return false;
}

- (float)getGoodPosition {
    if (position > startingCenter)
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
