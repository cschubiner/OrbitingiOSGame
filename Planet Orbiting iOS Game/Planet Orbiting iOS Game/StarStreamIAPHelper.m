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
        @"1000000stars1880",
                                 @"120000stars1880",
                                 @"300000stars1880",
                                 @"30000stars1880",
                                 @"70000stars1880",
                                 @"doublestars1880",
                                 @"pinkstars1880",
        //        @"com.raywenderlich.inapprage.itunesconnectrage",
        nil];
    
    if ((self = [super initWithProductIdentifiers:productIdentifiers])) {                
        
    }
    return self;
    
}

@end
