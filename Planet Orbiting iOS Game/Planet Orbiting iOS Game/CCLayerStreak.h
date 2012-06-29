//
//  CCLayerStreak.h
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCRibbon.h"

@interface CCLayerStreak : CCNode <CCTextureProtocol>
{
	CCRibbon*	ribbon_;
	float		segThreshold_;
	float		width_;
	CGPoint     lastLocation_;
    CCNode*     target_;
}

/** Ribbon used by LayerStreak (weak reference) */
@property (nonatomic,readonly) CCRibbon *ribbon;

/** creates the a LayerStreak. The image will be loaded using the TextureMgr. */
+(id)streakWithFade:(float)fade minSeg:(float)seg image:(NSString*)path width:(float)width length:(float)length color:(ccColor4B)color target:(id)target;

/** initializes a LayerStreak. The file will be loaded using the TextureMgr. */
-(id)initWithFade:(float)fade minSeg:(float)seg image:(NSString*)path width:(float)width length:(float)length color:(ccColor4B)color target:(id)target;

-(void)update:(ccTime)delta;

@end