//
//  UIPlaceHolderTextView.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 11/25/12.
//
//

#import <UIKit/UIKit.h>

// c.f. http://stackoverflow.com/questions/1328638/placeholder-in-uitextview

@interface UIPlaceHolderTextView : UITextView
{
    NSString *placeholder;
    UIColor *placeholderColor;
    
@private
    UILabel *placeHolderLabel;
}

@property (nonatomic, retain) UILabel   * placeHolderLabel;
@property (nonatomic, retain) NSString  * placeholder;
@property (nonatomic, retain) UIColor   * placeholderColor;

- (void)textChanged:(NSNotification*)notification;

@end
