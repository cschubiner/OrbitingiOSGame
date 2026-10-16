#import "SSMapSession.h"
#import "LevelObjectReturner.h"
#import "AppDelegate.h"
#import "GameplayLayer.h"
#import "cocos2d.h"
#import "DataStorage.h"
#import "UpgradeManager.h"
#import "UpgradeItem.h"
#import "UserWallet.h"
#import "PlayerStats.h"

@interface SSTuningController : UITableViewController
@property(nonatomic, strong) NSMutableDictionary *values;
@end

@interface SSMapSession ()
@property(nonatomic, copy, readwrite) NSDictionary *currentMap;
@end
@interface SSFavoritesController : UITableViewController
@property(nonatomic, copy) NSArray<NSDictionary *> *maps;
@end

static NSDictionary *SSMapObject(int type, double x, double y, double scale) {
    // Binary fixed point also survives JSON without a one-ULP identity drift.
    return @{@"type":@(type), @"x":@(round(x*1024)/1024), @"y":@(round(y*1024)/1024), @"scale":@(round(scale*1024)/1024)};
}
@implementation SSMapSession
+ (instancetype)shared { static SSMapSession *s; static dispatch_once_t once; dispatch_once(&once, ^{ s=[self new]; }); return s; }
- (BOOL)procedural { return self.currentMap != nil; }
+ (NSDictionary *)generateMapWithSeed:(uint32_t)seed {
    NSDictionary *tuning=SSTuning.current;
    uint32_t state = seed ?: 1;
    NSMutableArray *galaxies=[NSMutableArray new];
    for (int galaxy=0;galaxy<10;galaxy++) {
        NSMutableArray *segments=[NSMutableArray new];
        for (int section=0;section<12;section++) {
            NSMutableArray *objects=[NSMutableArray new], *planets=[NSMutableArray new];
            double x=0,y=0;
            // Geometry coordinates are multiplied by .498 in the game, but sprite
            // sizes are not. Reserve the largest planet body + animated star + gap.
            double planetSize=round([tuning[@"planetSize"] doubleValue]*1024)/1024;
            double clearance=(54*planetSize+14.5+14.01)/.498;
            double density=[tuning[@"planetDensity"] doubleValue];
            for (int i=0;i<5;i++) {
                [planets addObject:SSMapObject(kplanet,x,y,planetSize)];
                double distance=fmax(2*clearance+64,(440+SSMapUnit(&state)*100)/density);
                double angle=(SSMapUnit(&state)-.5)*.55*[tuning[@"routeBend"] doubleValue];
                x+=cos(angle)*distance; y+=sin(angle)*distance;
            }
            for (int i=0;i<4;i++) {
                NSDictionary *a=planets[i],*b=planets[i+1];
                double ax=[a[@"x"] doubleValue],ay=[a[@"y"] doubleValue];
                double dx=[b[@"x"] doubleValue]-ax,dy=[b[@"y"] doubleValue]-ay;
                double distance=hypot(dx,dy),nx=-dy/distance,ny=dx/distance;
                // Adaptive count keeps every star outside the planet silhouette,
                // with at least 32 world points between animated stars.
                double span=distance-2*clearance;
                int capacity=1+(int)floor(span/(32/.498));
                int count=MAX(1,MIN(capacity,(int)round(3*[tuning[@"starDensity"] doubleValue])));
                for (int coin=0;coin<count;coin++) {
                    double along=count==1 ? distance*.5 : clearance+span*coin/(count-1);
                    double offset=(SSMapUnit(&state)-.5)*16;
                    [objects addObject:SSMapObject(kcoin,ax+dx*along/distance+nx*offset,ay+dy*along/distance+ny*offset,1)];
                }
                double hazards=[tuning[@"asteroidDensity"] doubleValue]*[tuning[@"difficulty"] doubleValue];
                for (int side=-1;side<=1;side+=2) for (int slot=0;slot<4;slot++) {
                    if (SSMapUnit(&state)>=fmin(1,fmax(0,hazards-slot))) continue;
                    double offset=side*(235+slot*100+SSMapUnit(&state)*90);
                    [objects addObject:SSMapObject(kasteroid,ax+dx*.5+nx*offset,ay+dy*.5+ny*offset,.875*[tuning[@"asteroidSize"] doubleValue])];
                }
                if (SSMapUnit(&state)<.25*[tuning[@"powerupFrequency"] doubleValue])
                    [objects addObject:SSMapObject(kpowerup,ax+dx*.5,ay+dy*.5,1+(SSMapNext(&state)%3))];
            }
            // The final planet is the endpoint marker, consumed by the next section.
            [objects addObjectsFromArray:planets];
            [segments addObject:objects];
        }
        [galaxies addObject:segments];
    }
    return @{@"version":@2, @"seed":@(seed ?: 1), @"galaxies":galaxies, @"tuning":tuning};
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
    for (id map in maps) if ([map isKindOfClass:NSDictionary.class] && ([map[@"version"] intValue]==1 || [map[@"version"] intValue]==2) && [map[@"galaxies"] isKindOfClass:NSArray.class] && [map[@"galaxies"] count]==10) [valid addObject:map];
    return valid;
}
- (BOOL)isCurrentMapFavorite {
    for (NSDictionary *map in self.favorites) if ([map[@"seed"] isEqual:self.currentMap[@"seed"]] && [map[@"version"] isEqual:self.currentMap[@"version"]] && [map[@"galaxies"] isEqual:self.currentMap[@"galaxies"]] && ((map[@"tuning"]==nil && self.currentMap[@"tuning"]==nil) || [map[@"tuning"] isEqual:self.currentMap[@"tuning"]])) return YES;
    return NO;
}
- (BOOL)saveCurrentMapWithScore:(NSInteger)score {
    if (!self.procedural) return NO;
    NSMutableArray *maps=[self.favorites mutableCopy];
    NSMutableDictionary *saved=[self.currentMap mutableCopy];
    saved[@"bestScore"]=@(score); saved[@"savedAt"]=@([NSDate.date timeIntervalSince1970]);
    for (NSDictionary *map in maps.copy) if ([map[@"seed"] isEqual:saved[@"seed"]] && [map[@"version"] isEqual:saved[@"version"]] && [map[@"galaxies"] isEqual:saved[@"galaxies"]] && ((map[@"tuning"]==nil && saved[@"tuning"]==nil) || [map[@"tuning"] isEqual:saved[@"tuning"]])) {
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
- (void)showOptions {
    NSString *message=SSTuning.unlocked ? @"Tuning is unlocked. Favorites keep their saved layout and settings." : @"Tuning unlocks after buying each of the seven paid products at least once on this device. Star packs are consumable; tuning purchase history is saved locally.";
    UIAlertController *menu=[UIAlertController alertControllerWithTitle:@"Options" message:message preferredStyle:UIAlertControllerStyleAlert];
    if (SSTuning.unlocked) [menu addAction:[UIAlertAction actionWithTitle:@"Tuning / Debug Menu" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){
        SSTuningController *tuner=[[SSTuningController alloc] initWithStyle:UITableViewStyleInsetGrouped];
        UINavigationController *navigation=[[UINavigationController alloc] initWithRootViewController:tuner];
        navigation.modalPresentationStyle=UIModalPresentationFullScreen;
        [self.presenter presentViewController:navigation animated:YES completion:nil];
    }]];
    [menu addAction:[UIAlertAction actionWithTitle:@"Replay Tutorial" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){
        [SSTuning replayTutorial]; [[CCDirector sharedDirector] replaceScene:[GameplayLayer scene]];
    }]];
    [menu addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil]];
    [self.presenter presentViewController:menu animated:YES completion:nil];
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

@implementation SSTuning
+ (NSArray<NSDictionary *> *)controls {
    // key, title, minimum, maximum, default. Generation controls affect new maps.
    NSArray *rows=@[
        @[@"gameSpeed",@"Game speed",@.5,@1.5,@1],
        @[@"playerSpeed",@"Player speed",@.6,@1.5,@1],
        @[@"difficulty",@"Difficulty (hazards + battery drain)",@.5,@2,@1],
        @[@"gravity",@"Gravity strength",@.4,@2,@1],
        @[@"planetSpin",@"Planet rotation (visual)",@0,@3,@0],
        @[@"cameraZoom",@"Camera zoom",@.75,@1.25,@1],
        @[@"powerupDuration",@"Powerup duration",@.5,@2,@1],
        @[@"batteryCapacity",@"Battery capacity",@.5,@2,@1],
        @[@"planetDensity",@"Planet density · new maps",@.7,@1.4,@1],
        @[@"planetSize",@"Planet size · new maps",@.7,@1.3,@1],
        @[@"asteroidDensity",@"Asteroid density · new maps",@0,@2,@1],
        @[@"asteroidSize",@"Asteroid size · new maps",@.6,@1.4,@1],
        @[@"starDensity",@"Star density · new maps",@.5,@2,@1],
        @[@"routeBend",@"Route bends · new maps",@0,@1.5,@1],
        @[@"powerupFrequency",@"Powerup frequency · new maps",@0,@2,@1]
    ];
    NSMutableArray *result=[NSMutableArray new];
    for (NSArray *r in rows) [result addObject:@{@"key":r[0],@"title":r[1],@"min":r[2],@"max":r[3],@"default":r[4]}];
    return result;
}
+ (NSDictionary *)defaults {
    NSMutableDictionary *values=[NSMutableDictionary new];
    for (NSDictionary *control in self.controls) values[control[@"key"]]=control[@"default"];
    return values;
}
+ (NSDictionary *)validated:(NSDictionary *)values {
    if (![values isKindOfClass:NSDictionary.class]) return self.defaults;
    NSMutableDictionary *result=[NSMutableDictionary new];
    for (NSDictionary *control in self.controls) {
        id raw=values[control[@"key"]];
        double v=[raw isKindOfClass:NSNumber.class] ? [raw doubleValue] : [control[@"default"] doubleValue];
        if (!isfinite(v)) v=[control[@"default"] doubleValue];
        result[control[@"key"]]=@(fmax([control[@"min"] doubleValue],fmin([control[@"max"] doubleValue],v)));
    }
    return result;
}
+ (NSDictionary *)current { return self.unlocked ? [self validated:[NSUserDefaults.standardUserDefaults dictionaryForKey:@"SSTuningValues"]] : self.defaults; }
+ (void)save:(NSDictionary *)values { if (self.unlocked) [NSUserDefaults.standardUserDefaults setObject:[self validated:values] forKey:@"SSTuningValues"]; }
+ (BOOL)localTestingUnlock {
#if COCOS2D_DEBUG
    return [NSUserDefaults.standardUserDefaults boolForKey:@"SSLocalTestingUnlock"];
#else
    return NO;
#endif
}
+ (BOOL)unlocked {
    if (self.localTestingUnlock) return YES;
    NSArray *owned=[NSUserDefaults.standardUserDefaults dictionaryForKey:@"StarStreamProgressV3"][@"purchasedProducts"];
    for (NSString *suffix in @[@"doublestars",@"pinkstars",@"stars30000",@"stars70000",@"stars120000",@"stars300000",@"stars1000000"])
        if (![owned containsObject:[@"com.cschubiner.starstream." stringByAppendingString:suffix]]) return NO;
    return YES;
}
+ (BOOL)beginTutorial {
    NSUserDefaults *d=NSUserDefaults.standardUserDefaults;
    BOOL replay=[d boolForKey:@"SSReplayTutorial"];
    BOOL seen=[d boolForKey:@"SSTutorialSeen"] || [PlayerStats.sharedInstance getPlays]>0;
    [d setBool:YES forKey:@"SSTutorialSeen"];
    [d removeObjectForKey:@"SSReplayTutorial"];
    return replay || !seen;
}
+ (void)replayTutorial { [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"SSReplayTutorial"]; }
+ (void)applyLocalTestingUnlockIfRequested {
#if COCOS2D_DEBUG
    if (![NSProcessInfo.processInfo.arguments containsObject:@"--unlock-local-testing"]) return;
    NSUserDefaults *d=NSUserDefaults.standardUserDefaults;
    if (![d boolForKey:@"SSLocalTestingUnlock"]) {
        [d setBool:YES forKey:@"SSLocalTestingUnlock"];
        for (UpgradeItem *item in [UpgradeManager.sharedInstance upgradeItems]) item.purchased=YES;
        // Credit each pack once. This changes the local save only, never StoreKit receipts.
        [UserWallet.sharedInstance addCoins:1520000];
        [DataStorage storeData];
    }
    [d setBool:YES forKey:@"SSTutorialSeen"];
    [d synchronize];
#endif
}
@end

@implementation SSTuningController
- (void)viewDidLoad {
    [super viewDidLoad]; self.title=@"Tuning"; self.values=[SSTuning.current mutableCopy];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Reset Defaults" style:UIBarButtonItemStylePlain target:self action:@selector(reset)];
    self.tableView.rowHeight=86;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Applies to your next run. Procedural maps are regenerated with these settings. Favorites keep their original layout and tuning. Star spacing stays safe even at maximum density.";
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return SSTuning.localTestingUnlock ? @"Local testing unlock · no App Store purchases were made" : @"Unlocked by your seven paid products on this device";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return SSTuning.controls.count; }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    NSDictionary *c=SSTuning.controls[path.row]; NSString *key=c[@"key"];
    UILabel *label=[UILabel new]; label.translatesAutoresizingMaskIntoConstraints=NO;
    label.font=[UIFont preferredFontForTextStyle:UIFontTextStyleBody]; label.adjustsFontForContentSizeCategory=YES;
    label.text=[NSString stringWithFormat:@"%@: %.2f×",c[@"title"],[self.values[key] doubleValue]]; label.tag=100;
    UISlider *slider=[UISlider new]; slider.translatesAutoresizingMaskIntoConstraints=NO;
    slider.minimumValue=[c[@"min"] floatValue]; slider.maximumValue=[c[@"max"] floatValue]; slider.value=[self.values[key] floatValue];
    slider.tag=path.row; slider.accessibilityLabel=c[@"title"];
    [slider addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:label]; [cell.contentView addSubview:slider];
    UILayoutGuide *m=cell.contentView.layoutMarginsGuide;
    [NSLayoutConstraint activateConstraints:@[
        [label.leadingAnchor constraintEqualToAnchor:m.leadingAnchor], [label.trailingAnchor constraintEqualToAnchor:m.trailingAnchor],
        [label.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:8],
        [slider.leadingAnchor constraintEqualToAnchor:m.leadingAnchor], [slider.trailingAnchor constraintEqualToAnchor:m.trailingAnchor],
        [slider.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:6], [slider.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-8]
    ]];
    cell.selectionStyle=UITableViewCellSelectionStyleNone; return cell;
}
- (void)changed:(UISlider *)slider {
    NSDictionary *c=SSTuning.controls[slider.tag]; self.values[c[@"key"]]=@(round(slider.value*100)/100);
    UILabel *label=[slider.superview viewWithTag:100];
    label.text=[NSString stringWithFormat:@"%@: %.2f×",c[@"title"],[self.values[c[@"key"]] doubleValue]];
}
- (void)reset { self.values=[SSTuning.defaults mutableCopy]; [self.tableView reloadData]; }
- (void)close {
    if (SSTuning.unlocked) {
        [SSTuning save:self.values];
        if (SSMapSession.shared.procedural) [SSMapSession.shared selectMap:[SSMapSession generateMapWithSeed:[SSMapSession.shared.currentMap[@"seed"] unsignedIntValue]]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskLandscape; }
@end
