//
//  KCWatchView.h
//  cocos2d-ios
//
//  Created by Haitao Mao on 3/6/13.
//
//


#import "KCUiAssetMap.h"
#import "VideoTableViewController.h"
#import "KCViewController.h"


@interface KCWatchView : KCViewController

@property (nonatomic, retain) KCVideo * video;
@property (nonatomic, retain) KCUiAssetMap * assetMap;
@property (nonatomic, retain) VideoTableViewController * mainSubView;

@property (nonatomic, assign) BOOL myVideosOnly;
@property (nonatomic, retain) UIButton * popularButtonSel;
@property (nonatomic, retain) UIButton * myVideosButtonSel;
@property (nonatomic, retain) UIButton * popularButtonDesel;
@property (nonatomic, retain) UIButton * myVideosButtonDesel;

@property (nonatomic, retain) UIBarButtonItem * doneButtonItem;

- (id)initWithMyVideosModeEnabled:(BOOL)myVideosModeEnabled
                         assetMap:(KCUiAssetMap *)assetMap
                            video:(KCVideo *)video;
- (void)setToolbarProperty:(UIBarButtonItem *)doneButtonItem;
- (void)dismissView;
- (void)playMovie:(VideoEntity *)video row:(NSInteger)row;
- (void)playLocalMovie:(KCVideo *)video;
@end
