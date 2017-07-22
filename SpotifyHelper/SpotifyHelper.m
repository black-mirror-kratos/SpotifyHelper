//
//  AppDelegate.m
//  SpotifyHelper
//
//  Created by Pawan on 04/09/16.
//  Copyright © 2016 Pawan. All rights reserved.
//

#import "SpotifyHelper.h"
#import "MySript.h"
#import "PopupViewController.h"
#import "PopupView.h"
#import "StatusItemView.h"
#import <AVFoundation/AVFoundation.h>

#define REFRESHINTERVALFORMENU 1;

@interface SpotifyHelper ()

@property (weak) IBOutlet NSWindow *window;
//@property (strong, nonatomic) NSStatusItem *statusItem;
@property (assign, nonatomic) NSString *state;
@property (assign, nonatomic) NSTimer *timer;

@end

@implementation SpotifyHelper

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.spotifyScriptEngine = [[SpotifyScriptEngine alloc]init];
    [self startRefreshingTitile];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startRefreshingTitile)
                                                 name:AliveSignal
                                               object:nil];
    
}

-(void)startRefreshingTitile
{
    
    if(![[self.spotifyScriptEngine getResult:@"running"] isEqualToString:@"true"])
    {
        if(![[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:@"com.spotify.client" options:NSWorkspaceLaunchAsync | NSWorkspaceLaunchAndHide additionalEventParamDescriptor:nil launchIdentifier:nil])
        {
            NSLog(@"Path Finder failed to launch");
        }
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:REFRESHSLOWDELAY target:self selector:@selector(refreshSlow) userInfo:nil repeats:YES];
    }
    else{
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:REFRESHFASTDELAY target:self selector:@selector(refreshFast) userInfo:nil repeats:YES];
    }
}

-(void)refreshFast{
    
    self.menubarController.heartBeat++;
    
    self.menubarController.numberOfUpdatesRequiredToOverrideBackwardButton++;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.menubarController = [[MenubarController alloc] init];
        
        // setup popover
        self.menubarController.statusItemView.popover = [[NSPopover alloc]init];
        PopupViewController* vc = [[PopupViewController alloc] init];
        self.menubarController.statusItemView.v = [[PopupView alloc]init];
        vc.view = self.menubarController.statusItemView.v;
        self.menubarController.statusItemView.popover.contentViewController = vc;
        [self.menubarController.statusItemView.popover setBehavior: NSPopoverBehaviorTransient];
        self.menubarController.statusItemView.popover.animates = NO;
        [self.menubarController.statusItemView.popover setContentSize:NSMakeSize(200, 200)];
    });
    
    NSString *Query = [self.spotifyScriptEngine getResultTriggeredByTimer:@"running"];
    if([Query isEqualToString:@"ignore"]) return;
    BOOL isRunning = [Query isEqualToString:@"true"];
    if (!isRunning){
        [self.timer invalidate];
        //self.timer = nil;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:REFRESHSLOWDELAY target:self selector:@selector(refreshSlow) userInfo:nil repeats:YES];
        
    }
    else {
        //NSLog(@"in");
        Query = [self.spotifyScriptEngine getResultTriggeredByTimer:@"get name of current track"];
        if([Query isEqualToString:@"ignore"]) return;
        NSString* trackName = Query;
        
        if(trackName == nil) trackName = @"Spotify";
        
        Query = [self.spotifyScriptEngine getResultTriggeredByTimer:@"duration of current track"];
        if([Query isEqualToString:@"ignore"]) return;
        double trackDuration = [Query doubleValue];
        
        Query = [self.spotifyScriptEngine getResultTriggeredByTimer:@"player position"];
        if([Query isEqualToString:@"ignore"]) return;
        double currentTime = [Query floatValue];
        
        double percentage = (currentTime/trackDuration)*1000;
        self.menubarController.progressBar.doubleValue = percentage * self.menubarController.progressBar.maxValue;
        //[self.menubarController.progressBar displayIfNeeded];
        
        NSString *Query = [self.spotifyScriptEngine getResultTriggeredByTimer:@"player state"];
        if([Query isEqualToString:@"ignore"]) return;
        BOOL isPaused = [Query isEqualToString:@"kPSp"];
        
        if(isPaused)
        {
            self.menubarController.playPauseSign.hidden = YES;
        }
        else
        {
            self.menubarController.playPauseSign.hidden = NO;
        }
        
        
        if(trackName != nil && ![trackName isEqualToString:self.menubarController.trackname])
        {
            self.menubarController.trackname = trackName;
            
//            if([self running]) self.menubarController.textField.stringValue = trackName;
//            if([self running]) self.menubarController.statusItem.toolTip = [self.spotifyScriptEngine getResult:@"get artist of current track"];
            
            [self getArtWork];
            
//            static dispatch_once_t onceToken;
//            dispatch_once(&onceToken, ^{
//                [self.menubarController updateMenubar:YES];
//            });
        }
        [self.menubarController updateMenubar:NO];
    }
}

-(void)getArtWork
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString* urlstring = [self.spotifyScriptEngine getResult:@"get artwork url of current track"];
                       NSString* urlstringWithHttps = [urlstring stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
                       NSURL *url = [NSURL URLWithString: urlstringWithHttps];
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
                       //    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
                       NSURLResponse *response = nil;
                       NSError *error = nil;
                       NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                       
                       dispatch_sync(dispatch_get_main_queue(), ^{
                           //If self.image is atomic (not declared with nonatomic)
                           // you could have set it directly above
                           NSImage* image = [[NSImage alloc] initWithData:responseData];
                           self.art = image;
                           self.menubarController.statusItemView.v.art = self.art;
                           [self.menubarController.statusItemView.v setNeedsDisplay:YES];
                           //This needs to be set here now that the image is downloaded
                           // and you are back on the main thread
                           
                       });
                   });
}

-(void)refreshSlow{
    
    self.menubarController.playPauseSign.hidden = YES;
    //NSLog(@"slow");
    if ([[self.spotifyScriptEngine getResult:@"running"] isEqualToString:@"true"]){
        [self.timer invalidate];
        //self.timer = nil;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:REFRESHFASTDELAY target:self selector:@selector(refreshFast) userInfo:nil repeats:YES];
    }
}

-(BOOL)running{
    if ([[self.spotifyScriptEngine getResult:@"running"] isEqualToString:@"false"]){
        return NO;
    }
    else{
        return YES;
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
    // Commented because doesn't work with sandbox
//    [[[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.spotify.client"] objectAtIndex:0] terminate];
}

//- (NSMenu *)applicationDockMenu:(NSApplication *)sender
//{
//    return self.dockMenu;
//}
@end
