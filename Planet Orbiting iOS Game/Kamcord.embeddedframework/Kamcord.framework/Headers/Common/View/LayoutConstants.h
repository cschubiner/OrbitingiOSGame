//
//  LayoutConstants.h
//
//
//  Created by Haitao Mao on 4/3/13.
//
//

#import <Foundation/Foundation.h>

@interface LayoutConstants : NSObject

+ (LayoutConstants *)layoutConstantsForView:(NSString *)viewName;
- (id)get:(NSString *)property;
@end
