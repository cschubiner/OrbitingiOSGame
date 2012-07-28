//
//  CCLayerStreak.m
//

#import "CCLayerStreak.h"

@implementation CCLayerStreak

@synthesize ribbon=ribbon_;

+(id)streakWithFade:(float)fade minSeg:(float)seg image:(NSString*)path width:(float)width length:(float)length color:(ccColor4B)color target:(id)target
{
	return [[[self alloc] initWithFade:(float)fade minSeg:seg image:path width:width length:length color:color target:target] autorelease];
}

-(id)initWithFade:(float)fade minSeg:(float)seg image:(NSString*)path width:(float)width length:(float)length color:(ccColor4B)color target:(id)target
{
	if( (self=[super init])) {
		segThreshold_ = seg;
		width_ = width;
		lastLocation_ = CGPointZero;
        target_ = target;
		ribbon_ = [CCRibbon ribbonWithWidth:width_ image:path length:length color:color fade:fade];
		[self addChild:ribbon_];
        
		// update ribbon position
		[self scheduleUpdate];
	}
	return self;
}

-(void)update:(ccTime)delta
{
    CGPoint location = target_.position;
	float len = sqrtf(powf(lastLocation_.x - location.x, 2) + powf(lastLocation_.y - location.y, 2));
	if (len > segThreshold_)
	{
		[ribbon_ addPointAt:location width:width_];
		lastLocation_ = location;
	}
	[ribbon_ update:delta];
}

-(void)setColor:(ccColor4B)colorToSet {
    [ribbon_ setColor:colorToSet];
}

-(ccColor4B)getColor {
    return [ribbon_ color];
}

-(void)dealloc
{
	[super dealloc];
}

-(void) setTexture:(CCTexture2D*) texture
{
	[ribbon_ setTexture: texture];
}

-(CCTexture2D*) texture
{
	return [ribbon_ texture];
}

-(ccBlendFunc) blendFunc
{
	return [ribbon_ blendFunc];
}

-(void) setBlendFunc:(ccBlendFunc)blendFunc
{
	[ribbon_ setBlendFunc:blendFunc];
}

@end