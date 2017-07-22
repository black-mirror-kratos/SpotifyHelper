//
//  AppDelegate.h
//  SpotifyHelper
//
//  Created by Pawan on 04/09/16.
//  Copyright © 2016 Pawan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MenubarController.h"
#import "Header.h"
#import "SpotifyScriptEngine.h"

@interface SpotifyHelper : NSObject <NSApplicationDelegate>
@property SpotifyScriptEngine* spotifyScriptEngine;
@property (weak) IBOutlet NSMenu *dockMenu;

@property (nonatomic, strong) MenubarController *menubarController;
@property (strong) NSImage* art;

//@property int microphoneValidInput;
@property NSString* prevVolume;
@property BOOL microphoneInputValid;
@property int reallyPlayingSomethingElse;
@property int reallyWannaPlayAgain;
@property float avgSoundIntensity;
@property int currentSoundIntensityCount;
@property int absoluteSoundIntensityCount;
@property BOOL enableAvg;
@property float upperMargin;
@property float lastOneToDiscard;
@property int discardingLimit;
@property NSMutableArray *array;
@property BOOL silentModeEnabled;

@property BOOL noiseTriggerDone;

@end

