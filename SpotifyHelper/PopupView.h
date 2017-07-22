//
//  PopupView.h
//  SpotifyHelper
//
//  Created by Pawan on 06/12/16.
//  Copyright © 2016 Pawan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SpotifyHelper.h"

@interface PopupView : NSView
@property SpotifyScriptEngine* spotifyScriptEngine;
@property (strong) NSMutableDictionary *twoFingersTouches;
@property (strong) NSImage* art;
@end
