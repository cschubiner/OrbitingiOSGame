//
//  RangeSlider.h
//  cocos2d-ios
//
//  Created by Chris Perciballi on 3/9/13.
//
//

#import <UIKit/UIKit.h>

@interface RangeSlider : UIControl {
    float minimumValue;
    float maximumValue;
    float minimumRange;
    float selectedMinimumValue;
    float selectedMaximumValue;
}

@property(nonatomic) float minimumValue;
@property(nonatomic) float maximumValue;
@property(nonatomic) float minimumRange;
@property(nonatomic) float selectedMinimumValue;
@property(nonatomic) float selectedMaximumValue;

- (id)initWithFrame:(CGRect)frame;

@end
