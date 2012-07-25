//
//  DataStorage.h
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/24/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataStorage : NSObject

+ (void)storeData;
+ (void)fetchData;

@end