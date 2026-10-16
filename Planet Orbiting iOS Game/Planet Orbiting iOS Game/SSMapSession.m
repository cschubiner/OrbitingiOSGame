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
// Generator version 3. Each section has a style (cruise, zigzag, sweep, asteroid gauntlet,
// asteroid field or star stream), varied planet sizes and spacing, and hazards that ramp
// from galaxy 1 to 10 toward the density of the original handmade maps. Objects are placed
// by rejection against fixed fairness rules: no star on a planet or another star, no rock
// inside an orbit zone or any hop's minimum flight corridor. Geometry units are world
// points / .498, the factor the game applies to map positions but not to sprite sizes.
typedef NS_ENUM(int, SSSectionStyle) { SSCruise, SSZigzag, SSSweep, SSGauntlet, SSField, SSStarStream };
typedef struct { double x, y, scale; } SSMapPlanet;
typedef struct { double x, y, radius; } SSMapPoint;
static const double SSMinimumCorridor = 100;
static double SSPlanetBody(double scale) { return (54*scale+14.5+14.01)/.498; } // Planet art + animated star + gap.
static double SSPlanetZone(double scale) { return 72*scale/.498; } // zone art: 84 pt x 1.7 planet scale, rounded up.
static double SSRockRadius(double scale) { return 16*scale/.498; }
static int SSMapPick(const double *weights, int count, uint32_t *state) {
    double total=0; for (int i=0;i<count;i++) total+=fmax(0,weights[i]);
    double pick=SSMapUnit(state)*total;
    for (int i=0;i<count;i++) { pick-=fmax(0,weights[i]); if (pick<0) return i; }
    return count-1;
}
static double SSDistanceToHop(double x, double y, SSMapPlanet a, SSMapPlanet b) {
    double dx=b.x-a.x, dy=b.y-a.y, t=fmax(0,fmin(1,((x-a.x)*dx+(y-a.y)*dy)/(dx*dx+dy*dy)));
    return hypot(x-a.x-t*dx,y-a.y-t*dy);
}
static void SSMapAddStar(double x, double y, const SSMapPlanet *planets, int planetCount, SSMapPoint *stars, int *starCount, const SSMapPoint *pickups, int pickupCount, NSMutableArray *objects) {
    if (*starCount>=512) return;
    for (int i=0;i<planetCount;i++) if (hypot(x-planets[i].x,y-planets[i].y)<SSPlanetBody(planets[i].scale)) return;
    for (int i=0;i<*starCount;i++) if (hypot(x-stars[i].x,y-stars[i].y)<32.02/.498) return; // 32 world points apart.
    for (int i=0;i<pickupCount;i++) if (hypot(x-pickups[i].x,y-pickups[i].y)<90) return;
    NSDictionary *star=SSMapObject(kcoin,x,y,1);
    double sx=[star[@"x"] doubleValue], sy=[star[@"y"] doubleValue]; // Check the rounded position that is saved.
    for (int i=0;i<planetCount;i++) if (hypot(sx-planets[i].x,sy-planets[i].y)<SSPlanetBody(planets[i].scale)) return;
    stars[(*starCount)++]=(SSMapPoint){sx,sy,0};
    [objects addObject:star];
}
static BOOL SSMapRockFits(double x, double y, double radius, const SSMapPlanet *planets, int planetCount, const SSMapPoint *stars, int starCount, const SSMapPoint *rocks, int rockCount, const SSMapPoint *pickups, int pickupCount) {
    for (int i=0;i<planetCount;i++) if (hypot(x-planets[i].x,y-planets[i].y)<SSPlanetZone(planets[i].scale)*1.3+radius+30) return NO;
    for (int i=0;i+1<planetCount;i++) if (SSDistanceToHop(x,y,planets[i],planets[i+1])<SSMinimumCorridor+radius) return NO;
    for (int i=0;i<starCount;i++) if (hypot(x-stars[i].x,y-stars[i].y)<radius+40) return NO;
    for (int i=0;i<rockCount;i++) if (hypot(x-rocks[i].x,y-rocks[i].y)<radius+rocks[i].radius+10) return NO;
    for (int i=0;i<pickupCount;i++) if (hypot(x-pickups[i].x,y-pickups[i].y)<radius+80) return NO;
    return YES;
}
+ (NSDictionary *)generateMapWithSeed:(uint32_t)seed {
    NSDictionary *tuning=SSTuning.current;
    uint32_t state = seed ?: 1;
    double planetSize=round([tuning[@"planetSize"] doubleValue]*1024)/1024;
    double density=[tuning[@"planetDensity"] doubleValue], bend=[tuning[@"routeBend"] doubleValue];
    double starDensity=[tuning[@"starDensity"] doubleValue], powerupFrequency=[tuning[@"powerupFrequency"] doubleValue];
    double hazard=[tuning[@"asteroidDensity"] doubleValue]*[tuning[@"difficulty"] doubleValue];
    double rockSize=[tuning[@"asteroidSize"] doubleValue];
    NSMutableArray *galaxies=[NSMutableArray new];
    for (int galaxy=0;galaxy<10;galaxy++) {
        double level=galaxy/9.0; // Difficulty ramps from the first galaxy to the tenth.
        NSMutableArray *segments=[NSMutableArray new];
        for (int section=0;section<12;section++) {
            double weights[6]={1.6-level, 1, 1, .3+1.3*level, .5+level, .9};
            SSSectionStyle style=(SSSectionStyle)SSMapPick(weights,6,&state);
            int count=5+(int)(SSMapNext(&state)%3); // 4-6 planets plus the endpoint marker.
            SSMapPlanet planets[8];
            planets[0]=(SSMapPlanet){0,0,planetSize};
            double maxHeading=fmin(80,(32+45*level)*bend)*M_PI/180, seamHeading=fmin(maxHeading,25*M_PI/180);
            double heading=0, turnSide=SSMapUnit(&state)<.5 ? -1 : 1;
            for (int i=1;i<count;i++) {
                // Interior planets vary in size; section ends match the next section's first planet.
                double s=planetSize;
                if (i<count-1) {
                    double u=SSMapUnit(&state), v=SSMapUnit(&state);
                    s*=u<.18 ? .78+.12*v : u>.8-.1*level ? 1.2+.4*v : .92+.16*v;
                    s=round(fmin(s,2)*1024)/1024;
                }
                double next;
                switch (style) {
                    case SSZigzag: next=(i%2 ? 1 : -1)*turnSide*(.55+.45*SSMapUnit(&state))*maxHeading; break;
                    case SSSweep: next=i==1 ? -turnSide*.4*maxHeading : heading+turnSide*(.25+.25*SSMapUnit(&state))*maxHeading; break;
                    case SSCruise: next=(SSMapUnit(&state)-.5)*.9*maxHeading; break;
                    default: next=heading+(SSMapUnit(&state)-.5)*1.2*maxHeading;
                }
                double limit=(i==1 || i==count-1) ? seamHeading : maxHeading; // Gentle seams between sections.
                next=fmax(-limit,fmin(limit,next));
                if (fabs(next-heading)>100*M_PI/180) next=heading+copysign(100*M_PI/180,next-heading);
                double base=(style==SSGauntlet ? 520 : style==SSZigzag ? 420 : 470)*(.82+.4*SSMapUnit(&state));
                double jump=SSMapUnit(&state);
                if (jump<.06+.12*level) base=fmin(950,base*(1.45+.3*SSMapUnit(&state))); // Occasional long jump.
                else if (jump>.82) base*=.68;                                           // Or a tight hop.
                SSMapPlanet previous=planets[i-1];
                double distance=fmax(fmax(SSPlanetBody(previous.scale)+SSPlanetBody(s)+64, SSPlanetZone(previous.scale)+SSPlanetZone(s)+90), base/density);
                // Sharp zigzags can fold the route back on itself; soften the turn until every orbit is clear.
                for (int attempt=0;attempt<4;attempt++) {
                    planets[i]=(SSMapPlanet){previous.x+cos(next)*distance, previous.y+sin(next)*distance, s};
                    BOOL clear=YES;
                    for (int j=0;j<i-1 && clear;j++)
                        clear=hypot(planets[i].x-planets[j].x,planets[i].y-planets[j].y)>=SSPlanetZone(planets[j].scale)+SSPlanetZone(s)+120;
                    if (clear) break;
                    next=attempt==2 ? 0 : next*.55;
                }
                heading=next;
            }
            SSMapPoint stars[512], rocks[256], pickups[8]; int starCount=0, rockCount=0, pickupCount=0;
            NSMutableArray *objects=[NSMutableArray new];
            for (int i=0;i<count-1;i++) {
                if (pickupCount<8 && SSMapUnit(&state)<fmin(.9,.14*powerupFrequency)) {
                    SSMapPlanet a=planets[i], b=planets[i+1];
                    pickups[pickupCount++]=(SSMapPoint){(a.x+b.x)/2,(a.y+b.y)/2,0};
                    [objects addObject:SSMapObject(kpowerup,(a.x+b.x)/2,(a.y+b.y)/2,1+(SSMapNext(&state)%3))];
                }
            }
            for (int i=0;i<count-1;i++) {
                SSMapPlanet a=planets[i], b=planets[i+1];
                double length=hypot(b.x-a.x,b.y-a.y), ux=(b.x-a.x)/length, uy=(b.y-a.y)/length, nx=-uy, ny=ux;
                double ta=SSPlanetBody(a.scale)/length, tb=1-SSPlanetBody(b.scale)/length;
                int n=MAX(1,(int)round((5+3.5*level)*starDensity*(style==SSStarStream ? 2.2 : 1)));
                double u=SSMapUnit(&state), side=SSMapUnit(&state)<.5 ? -1 : 1;
                int pattern=style==SSStarStream ? (u<.5 ? 1 : 2) : u<.4 ? 0 : u<.7 ? 1 : u<.85 ? 2 : 3;
                if (pattern==3 && i+1>=count-1) pattern=1; // Rings only around interior planets.
                if (pattern==3) {
                    // A partial ring around the next planet, collected while settling into orbit.
                    double radius=fmax(SSPlanetBody(b.scale)+24,SSPlanetZone(b.scale)*1.05);
                    double start=atan2(a.y-b.y,a.x-b.x), sweep=(2+1.4*SSMapUnit(&state))*side;
                    int ringStars=MAX(3,(int)round(fabs(sweep)*radius/80*fmin(1.5,starDensity)));
                    for (int k=0;k<ringStars;k++) {
                        double angle=start+sweep*(k+.5)/ringStars;
                        SSMapAddStar(b.x+cos(angle)*radius,b.y+sin(angle)*radius,planets,count,stars,&starCount,pickups,pickupCount,objects);
                    }
                } else for (int k=0;k<n;k++) {
                    double t=ta+(tb-ta)*(k+.5)/n, f=(t-ta)/(tb-ta), offset=(SSMapUnit(&state)-.5)*16;
                    if (pattern==1) offset+=side*(.12+.16*u)*length*sin(M_PI*f);        // Bowed arc.
                    else if (pattern==2) offset+=side*(45+35*u)*sin(3*M_PI*f);          // Wave.
                    SSMapAddStar(a.x+ux*t*length+nx*offset,a.y+uy*t*length+ny*offset,planets,count,stars,&starCount,pickups,pickupCount,objects);
                }
                if (SSMapUnit(&state)<.15+.15*level) {
                    // A risky detour cluster off the route.
                    double cx=a.x+ux*length/2+nx*side*(170+60*SSMapUnit(&state)), cy=a.y+uy*length/2+ny*side*(170+60*SSMapUnit(&state));
                    double cluster[5][2]={{0,0},{70,0},{-70,0},{0,70},{0,-70}};
                    for (int k=0;k<5;k++) SSMapAddStar(cx+cluster[k][0],cy+cluster[k][1],planets,count,stars,&starCount,pickups,pickupCount,objects);
                }
            }
            double multiplier[6]={.5,.8,.8,2,1.6,.6};
            double corridor=fmax(SSMinimumCorridor,170-65*level)*(style==SSGauntlet ? .85 : 1);
            corridor=fmax(SSMinimumCorridor,corridor);
            for (int i=0;i<count-1;i++) {
                SSMapPlanet a=planets[i], b=planets[i+1];
                double length=hypot(b.x-a.x,b.y-a.y), ux=(b.x-a.x)/length, uy=(b.y-a.y)/length, nx=-uy, ny=ux;
                int n=MIN(60,(int)round(hazard*(3.5+7*level)*multiplier[style]*(.7+.6*SSMapUnit(&state))));
                for (int k=0;k<n;k++) for (int attempt=0;attempt<6;attempt++) {
                    double scale=.875*rockSize*(.75+.45*SSMapUnit(&state)), extra=0;
                    if (SSMapUnit(&state)<.06+.1*level) { scale*=2+1.2*SSMapUnit(&state); extra=120; } // Boulder, kept wide.
                    double radius=SSRockRadius(scale), t=.15+.7*SSMapUnit(&state);
                    double side=style==SSGauntlet ? (k%2 ? 1 : -1) : (SSMapUnit(&state)<.5 ? -1 : 1), spread=SSMapUnit(&state);
                    double offset=corridor+radius+extra+(style==SSGauntlet ? 35*spread : style==SSField ? 300*spread*spread : 160*spread);
                    double x=a.x+ux*t*length+nx*side*offset, y=a.y+uy*t*length+ny*side*offset;
                    if (!SSMapRockFits(x,y,radius,planets,count,stars,starCount,rocks,rockCount,pickups,pickupCount) || rockCount>=256) continue;
                    rocks[rockCount++]=(SSMapPoint){x,y,radius};
                    [objects addObject:SSMapObject(kasteroid,x,y,scale)];
                    break;
                }
            }
            // The final planet is the endpoint marker, consumed by the next section.
            for (int i=0;i<count;i++) [objects addObject:SSMapObject(kplanet,planets[i].x,planets[i].y,planets[i].scale)];
            [segments addObject:objects];
        }
        [galaxies addObject:segments];
    }
    return @{@"version":@3, @"seed":@(seed ?: 1), @"galaxies":galaxies, @"tuning":tuning};
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
    for (id map in maps) if ([map isKindOfClass:NSDictionary.class] && ([map[@"version"] intValue]>=1 && [map[@"version"] intValue]<=3) && [map[@"galaxies"] isKindOfClass:NSArray.class] && [map[@"galaxies"] count]==10) [valid addObject:map];
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
        NSDictionary *before=SSTuning.current;
        [SSTuning save:self.values];
        // Favorites replay their saved layout and tuning; only an unsaved route is rebuilt,
        // and only when the settings actually changed.
        SSMapSession *session=SSMapSession.shared;
        if (session.procedural && ![SSTuning.current isEqual:before] && !session.isCurrentMapFavorite)
            [session selectMap:[SSMapSession generateMapWithSeed:[session.currentMap[@"seed"] unsignedIntValue]]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskLandscape; }
@end
