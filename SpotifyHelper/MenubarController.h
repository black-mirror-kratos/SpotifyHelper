//
//  MenubarController.h
//  SpotifyHelper
//
//  Created by Pawan on 08/12/16.
//  Copyright © 2016 Pawan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SpotifyScriptEngine.h"

#pragma mark -

@class StatusItemView;

@interface MenubarController : NSViewController {
@private
    StatusItemView *_statusItemView;
}
@property (nonatomic) int heartBeat;
@property SpotifyScriptEngine* spotifyScriptEngine;
@property (nonatomic, strong) NSString* trackname;
@property (nonatomic) NSTextField *textField;
@property (nonatomic) NSButton *skipForwardButton;
@property (nonatomic) NSButton *skipBackwardButton;
@property (nonatomic) NSProgressIndicator *progressBar;
@property (nonatomic) NSTextField *playPauseSign;
@property (nonatomic, strong, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong, readonly) StatusItemView *statusItemView;
@property (nonatomic, strong) NSTimer* mouseHoverDelayTimer;
@property (nonatomic) BOOL updateUIRequest;
@property (nonatomic) NSTimer* UIUpdateTimer;
@property (nonatomic) BOOL isOverPrevButton;
@property int numberOfUpdatesRequiredToOverrideBackwardButton;
-(void)updateMenubar:(NSString*) string
            ultimate:(BOOL) ultimate;
-(void)updateMenubar:(BOOL) ultimate;
-(void)skipForwardButtonClicked;
-(void)skipBackwardButtonClicked;

@end
