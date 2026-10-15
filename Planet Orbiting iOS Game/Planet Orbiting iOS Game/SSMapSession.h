#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class LevelObjectReturner;

@interface SSMapSession : NSObject
+ (instancetype)shared;
@property(nonatomic, copy, readonly) NSDictionary *currentMap;
@property(nonatomic, readonly) BOOL procedural;
+ (NSDictionary *)generateMapWithSeed:(uint32_t)seed;
+ (NSArray<LevelObjectReturner *> *)objectsForSegment:(NSArray<NSDictionary *> *)segment;
- (void)selectClassic;
- (void)selectNewMap;
- (void)selectMap:(NSDictionary *)map;
- (NSArray<NSDictionary *> *)favorites;
- (BOOL)saveCurrentMapWithScore:(NSInteger)score;
- (BOOL)isCurrentMapFavorite;
- (void)showMapChooser;
- (void)showFavorites;
@end

// Stable integer PRNG, independent of rendering, particles, timing and device size.
static inline uint32_t SSMapNext(uint32_t *state) {
    uint32_t x = *state ?: 0x6d2b79f5u;
    x ^= x << 13; x ^= x >> 17; x ^= x << 5;
    return *state = x;
}
static inline double SSMapUnit(uint32_t *state) { return SSMapNext(state) / 4294967296.0; }
