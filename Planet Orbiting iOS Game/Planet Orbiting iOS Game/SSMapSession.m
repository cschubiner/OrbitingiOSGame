#import "SSMapSession.h"
#import "LevelObjectReturner.h"
#import "AppDelegate.h"
#import "GameplayLayer.h"
#import "cocos2d.h"

@interface SSMapSession ()
@property(nonatomic, copy, readwrite) NSDictionary *currentMap;
@end
@interface SSFavoritesController : UITableViewController
@property(nonatomic, copy) NSArray<NSDictionary *> *maps;
@end

static NSDictionary *SSMapObject(int type, double x, double y, double scale) {
    return @{@"type":@(type), @"x":@(x), @"y":@(y), @"scale":@(scale)};
}
@implementation SSMapSession
+ (instancetype)shared { static SSMapSession *s; static dispatch_once_t once; dispatch_once(&once, ^{ s=[self new]; }); return s; }
- (BOOL)procedural { return self.currentMap != nil; }
+ (NSDictionary *)generateMapWithSeed:(uint32_t)seed {
    uint32_t state = seed ?: 1;
    NSMutableArray *galaxies=[NSMutableArray new];
    for (int galaxy=0;galaxy<10;galaxy++) {
        NSMutableArray *segments=[NSMutableArray new];
        for (int section=0;section<12;section++) {
            NSMutableArray *objects=[NSMutableArray new], *planets=[NSMutableArray new];
            double x=0,y=0;
            // Median authored spacing is 488 points at scale 1. Keep both unchanged.
            for (int i=0;i<5;i++) {
                [planets addObject:SSMapObject(kplanet,x,y,1)];
                double distance=440+SSMapUnit(&state)*100;
                double angle=(SSMapUnit(&state)-.5)*.55;
                x+=cos(angle)*distance; y+=sin(angle)*distance;
            }
            for (int i=0;i<4;i++) {
                NSDictionary *a=planets[i],*b=planets[i+1];
                double ax=[a[@"x"] doubleValue],ay=[a[@"y"] doubleValue];
                double dx=[b[@"x"] doubleValue]-ax,dy=[b[@"y"] doubleValue]-ay;
                double distance=hypot(dx,dy),nx=-dy/distance,ny=dx/distance;
                // Stars mark the flight corridor. Asteroids stay outside its 140-point half-width.
                for (int coin=1;coin<=5;coin++) {
                    double t=coin/6.0, offset=(SSMapUnit(&state)-.5)*45;
                    [objects addObject:SSMapObject(kcoin,ax+dx*t+nx*offset,ay+dy*t+ny*offset,1)];
                }
                for (int side=-1;side<=1;side+=2) {
                    double offset=side*(235+SSMapUnit(&state)*90);
                    [objects addObject:SSMapObject(kasteroid,ax+dx*.5+nx*offset,ay+dy*.5+ny*offset,.875)];
                }
                if ((section+i)%4==0) [objects addObject:SSMapObject(kpowerup,ax+dx*.6,ay+dy*.6,1+(SSMapNext(&state)%3))];
            }
            // The final planet is the endpoint marker, consumed by the next section.
            [objects addObjectsFromArray:planets];
            [segments addObject:objects];
        }
        [galaxies addObject:segments];
    }
    return @{@"version":@1, @"seed":@(seed ?: 1), @"galaxies":galaxies};
}
+ (NSArray<LevelObjectReturner *> *)objectsForSegment:(NSArray<NSDictionary *> *)segment {
    NSMutableArray *objects=[NSMutableArray new];
    for (NSDictionary *o in segment) [objects addObject:[[LevelObjectReturner alloc] initWithType:[o[@"type"] intValue] position:CGPointMake([o[@"x"] doubleValue],[o[@"y"] doubleValue]) scale:[o[@"scale"] floatValue]]];
    return objects;
}
- (void)selectClassic { self.currentMap=nil; }
- (void)selectNewMap { self.currentMap=[SSMapSession generateMapWithSeed:arc4random_uniform(UINT32_MAX-1)+1]; }
- (void)selectMap:(NSDictionary *)map { self.currentMap=map; }
- (NSURL *)favoritesURL {
    NSURL *dir=[NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
    [NSFileManager.defaultManager createDirectoryAtURL:dir withIntermediateDirectories:YES attributes:nil error:nil];
    return [dir URLByAppendingPathComponent:@"StarStreamFavoriteMaps.json"];
}
- (NSArray<NSDictionary *> *)favorites {
    NSData *data=[NSData dataWithContentsOfURL:self.favoritesURL];
    id maps=data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
    if (![maps isKindOfClass:NSArray.class]) return @[];
    NSMutableArray *valid=[NSMutableArray new];
    for (id map in maps) if ([map isKindOfClass:NSDictionary.class] && [map[@"version"] intValue]==1 && [map[@"galaxies"] isKindOfClass:NSArray.class] && [map[@"galaxies"] count]==10) [valid addObject:map];
    return valid;
}
- (BOOL)isCurrentMapFavorite {
    for (NSDictionary *map in self.favorites) if ([map[@"seed"] isEqual:self.currentMap[@"seed"]] && [map[@"version"] isEqual:self.currentMap[@"version"]]) return YES;
    return NO;
}
- (BOOL)saveCurrentMapWithScore:(NSInteger)score {
    if (!self.procedural) return NO;
    NSMutableArray *maps=[self.favorites mutableCopy];
    NSMutableDictionary *saved=[self.currentMap mutableCopy];
    saved[@"bestScore"]=@(score); saved[@"savedAt"]=@([NSDate.date timeIntervalSince1970]);
    for (NSDictionary *map in maps.copy) if ([map[@"seed"] isEqual:saved[@"seed"]] && [map[@"version"] isEqual:saved[@"version"]]) {
        saved[@"bestScore"]=@(MAX(score,[map[@"bestScore"] integerValue]));
        saved[@"savedAt"]=map[@"savedAt"];
        [maps removeObject:map];
    }
    [maps insertObject:saved atIndex:0];
    NSData *data=[NSJSONSerialization dataWithJSONObject:maps options:0 error:nil];
    return data && [data writeToURL:self.favoritesURL options:NSDataWritingAtomic error:nil];
}
- (UIViewController *)presenter { return UIApplication.sharedApplication.keyWindow.rootViewController; }
- (void)showMapChooser {
    UIAlertController *chooser=[UIAlertController alertControllerWithTitle:@"Choose a map" message:@"Classic uses the original handmade sections. Procedural creates a new route you can save and replay." preferredStyle:UIAlertControllerStyleAlert];
    [chooser addAction:[UIAlertAction actionWithTitle:@"Classic" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){ [self selectClassic]; }]];
    [chooser addAction:[UIAlertAction actionWithTitle:@"New Procedural Map" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){ [self selectNewMap]; }]];
    [chooser addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self.presenter presentViewController:chooser animated:YES completion:nil];
}
- (void)showFavorites {
    SSFavoritesController *list=[[SSFavoritesController alloc] initWithStyle:UITableViewStyleInsetGrouped];
    list.maps=self.favorites;
    UINavigationController *navigation=[[UINavigationController alloc] initWithRootViewController:list];
    navigation.modalPresentationStyle=UIModalPresentationFullScreen;
    [self.presenter presentViewController:navigation animated:YES completion:nil];
}
@end
@implementation SSFavoritesController
- (void)viewDidLoad {
    [super viewDidLoad]; self.title=@"Favorite Maps";
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
    if (!self.maps.count) {
        UILabel *empty=[UILabel new]; empty.text=@"Your favorite routes will appear here.\nPlay a procedural map, then tap Save Map after your run.";
        empty.numberOfLines=0; empty.textAlignment=NSTextAlignmentCenter;
        self.tableView.backgroundView=empty;
    }
}
- (void)close { [self dismissViewControllerAnimated:YES completion:nil]; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return self.maps.count; }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    NSDictionary *map=self.maps[path.row];
    cell.textLabel.text=[NSString stringWithFormat:@"Orbit %@",map[@"seed"]];
    cell.detailTextLabel.text=[NSString stringWithFormat:@"Best score: %@ · Tap to replay this exact map", map[@"bestScore"] ?: @0];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator; return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    [SSMapSession.shared selectMap:self.maps[path.row]];
    [self dismissViewControllerAnimated:YES completion:^{ [[CCDirector sharedDirector] replaceScene:[GameplayLayer scene]]; }];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskLandscape; }
@end
