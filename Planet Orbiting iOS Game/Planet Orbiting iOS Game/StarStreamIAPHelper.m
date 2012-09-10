//
//  InAppRageIAPHelper.m
//  InAppRage
//
//  Created by Ray Wenderlich on 2/28/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "StarStreamIAPHelper.h"

@implementation StarStreamIAPHelper

static StarStreamIAPHelper * _sharedHelper;

+ (StarStreamIAPHelper *) sharedHelper {
    
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[StarStreamIAPHelper alloc] init];
    return _sharedHelper;
    
}

- (id)init {
    
    NSSet *productIdentifiers = [NSSet setWithObjects:
        @"1000000stars",
                                 @"120000stars",
                                 @"300000stars",
                                 @"30000stars",
                                 @"70000stars",
                                 @"doublestars",
                                 @"pinkstars",
        //        @"com.raywenderlich.inapprage.itunesconnectrage",
        nil];
    
    if ((self = [super initWithProductIdentifiers:productIdentifiers])) {                
        
    }
    return self;
    
}

@end
