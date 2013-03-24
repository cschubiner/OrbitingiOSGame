//
//  PreShareView.h
//  cocos2d-ios
//
//  Created by Chris Perciballi on 12/8/12.
//
//

#import <UIKit/UIKit.h>
@class KCVideo;

@interface KCThumbnailView : UIView

- (id)initWithWidth:(int)width
             height:(int)height
     viewController:(UIViewController *) viewController
          withVideo:(KCVideo *)activeVideo;

@end
