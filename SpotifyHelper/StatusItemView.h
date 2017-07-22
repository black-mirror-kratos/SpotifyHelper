//
//  StatusItemView.h
//  SpotifyHelper
//
//  Created by Pawan on 08/12/16.
//  Copyright © 2016 Pawan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Header.h"
#import "SpotifyScriptEngine.h"
#import "PopupView.h"
#import "MenubarController.h"

@interface StatusItemView : NSView{
@private
}
@property SpotifyScriptEngine* spotifyScriptEngine;

- (id)initWithStatusItem:(NSStatusItem *)statusItem;
-(void)quit;

@property MenubarController *myViewController;

@property (strong) NSImage* art;
@property (strong) NSPopover* popover;
@property (strong) NSMutableDictionary *twoFingersTouches;
@property (nonatomic) BOOL excitedStateForward;
@property (nonatomic) BOOL excitedStateReverse;
@property (nonatomic) BOOL dragStarted;
@property (nonatomic) double dragStartedAt;
@property (nonatomic) double currentPressure;
@property (nonatomic) BOOL pressurizationEnabled;
@property (nonatomic) BOOL pressurized;
@property (nonatomic) BOOL longInteractionEnabled;
@property (nonatomic) BOOL paused;
@property (nonatomic) int reallyWannaDrag;
@property (nonatomic) int reallyWannaMove;
@property (nonatomic) double alphaForwardButton;
@property (nonatomic) double alphaPreviousButton;
@property (nonatomic) BOOL swipingThroughEnabled;
@property (nonatomic) BOOL mouseInside;
@property (nonatomic) NSPoint mouseLastLocation;
@property (nonatomic) PopupView* v;

@property (nonatomic, strong, readonly) NSStatusItem *statusItem;

@property (nonatomic, strong) NSTimer* popupTimer;

@end
