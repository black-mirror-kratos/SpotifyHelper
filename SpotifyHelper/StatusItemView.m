//
//  StatusItemView.m
//  SpotifyHelper
//
//  Created by Pawan on 08/12/16.
//  Copyright © 2016 Pawan. All rights reserved.
//

#import "StatusItemView.h"
#import "PopupViewController.h"
#import "PopupView.h"

#import "SpotifyScriptEngine.h"

#import "QuartzCore/QuartzCore.h"

@interface StatusItemView ()
@property (strong) NSTrackingArea *trackingArea;
@end

@implementation StatusItemView

@synthesize trackingArea = _trackingArea;

@synthesize statusItem = _statusItem;


- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];
    
    if (self != nil) {
        self.spotifyScriptEngine = [[SpotifyScriptEngine alloc]init];
        _statusItem = statusItem;
        _statusItem.view = self;
        
        
        [self.window setIgnoresMouseEvents:NO];
        [self.window setAcceptsMouseMovedEvents:YES];
        [self setAcceptsTouchEvents:YES];
        self.excitedStateForward = NO;
        self.excitedStateReverse = NO;
        self.pressurized = NO;
        self.longInteractionEnabled = NO;
        self.pressurizationEnabled = YES;
        self.reallyWannaDrag = 0;
        self.reallyWannaMove = 0;
        self.swipingThroughEnabled = 0;
        self.mouseInside = NO;

    }
    return self;
}

-(void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    [self updateTrackingAreas];
}


- (void)updateTrackingAreas {
    NSLog(@"updateTrackingAreas");
    if (self.trackingArea)
        [self removeTrackingArea:self.trackingArea];
    
    [super updateTrackingAreas];
    
    NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingInVisibleRect | NSTrackingActiveAlways;
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:CGRectZero
                                                     options:options
                                                       owner:self
                                                    userInfo:nil];
    [self addTrackingArea:self.trackingArea];
    
}

-(void)resetThings
{
    self.dragStarted = NO;
    [self.popupTimer invalidate];
    self.pressurized = NO;
    self.pressurizationEnabled = YES;
    self.longInteractionEnabled = NO;
    self.excitedStateForward = NO;
    self.excitedStateReverse = NO;
    self.reallyWannaDrag = 0;
    self.reallyWannaMove = 0;
}


//-------------------------------------------- Handle Mouse Click Events --------------------------------------------------------------

- (void)mouseDown:(NSEvent *)theEvent {
    [self resetThings];
    //	NSLog(@"visibleRect: %@", NSStringFromRect([self visibleRect]));
    NSLog(@"mouse down");
    NSPoint mousePointerLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    self.dragStarted = YES;
    self.dragStartedAt = mousePointerLocation.x;
    
    NSLog(@"%d, %d", self.pressurized, self.pressurizationEnabled);
    
    if(!self.pressurized && self.pressurizationEnabled)
    {
        self.popupTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer *timer){
            //self.pressurized = YES;
            self.longInteractionEnabled = YES;
            [self.popover setContentSize:NSMakeSize(300, 300)];
            [self.popover showRelativeToRect: self.bounds
                                               ofView: self
                                        preferredEdge: NSMinYEdge];

            [self.popover.contentViewController.view setNeedsDisplay:YES];
            //[self.popover close];
        }];
    }
    
    self.myViewController.textField.frame = NSMakeRect(self.myViewController.textField.frame.origin.x, self.myViewController.textField.frame.origin.y, self.myViewController.textField.frame.size.width - 1, self.myViewController.textField.frame.size.height - 1);
    
}

- (void)mouseUp:(NSEvent *)theEvent {
    //	NSLog(@"visibleRect: %@", NSStringFromRect([self visibleRect]));
    NSLog(@"mouse up");
    self.pressurizationEnabled = YES;
    NSPoint mousePointerLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if(mousePointerLocation.x - self.dragStartedAt > 10)
    {
        [self.spotifyScriptEngine issueCommand:@"next track"];
        self.myViewController.trackname = @"pawan";
        [self.myViewController updateMenubar:NO];
        NSLog(@"next track");
    }
    else if(self.dragStartedAt -  mousePointerLocation.x > 10)
    {
        [self.spotifyScriptEngine issueCommand:@"previous track"];
        NSLog(@"previous track");
    }
    else
    {
        if(!self.longInteractionEnabled)
        {
            if(mousePointerLocation.x < 15)
            {
                [self performSelector:@selector(skipBackwardButtonClicked)];
            }
            else if(mousePointerLocation.x > self.window.frame.size.width - 15)
            {
                [self performSelector:@selector(skipForwardButtonClicked)];
            }
            else
            {
                [self.spotifyScriptEngine issueCommand:@"playpause"];
            }
        }
        else
        {
            self.longInteractionEnabled = NO;
        }
    }
    [self.popover close];
//    if(self.pressurized && self.pressurizationEnabled)
//    {
//        [self.popover setContentSize:NSMakeSize(200, 200)];
//        [self.popover.contentViewController.view setNeedsDisplay:YES];
//        [self.popover showRelativeToRect: self.bounds
//                                  ofView: self
//                           preferredEdge: NSMinYEdge];
//        self.pressurized = NO;
//    }
    
    [self resetThings];
    
    self.myViewController.textField.frame = NSMakeRect(self.myViewController.textField.frame.origin.x, self.myViewController.textField.frame.origin.y, self.myViewController.textField.frame.size.width + 1, self.myViewController.textField.frame.size.height + 1);
    
}
-(void)skipForwardButtonClicked
{
    [self.spotifyScriptEngine issueCommand:@"next track"];
    NSLog(@"go forward");
}

-(void)skipBackwardButtonClicked
{
    [self.spotifyScriptEngine issueCommand:@"previous track"];
    NSLog(@"go back");
}


- (void)rightMouseDown:(NSEvent *)theEvent {
    NSLog(@"right mouse clicked");
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    
    [[theMenu addItemWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@""]setTarget:self];
    
    NSString* shuffle;
    if([[self.spotifyScriptEngine getResult:@"shuffling"] isEqualToString:@"true"])
    {
        shuffle = [NSString stringWithFormat:@"Shuffle: ON"];
    }
    else{
        shuffle = [NSString stringWithFormat:@"Shuffle: OFF"];
    }
    [[theMenu addItemWithTitle:shuffle action:@selector(shuffleToggle) keyEquivalent:@""]setTarget:self];
    
    NSString* repeat;
    if([[self.spotifyScriptEngine getResult:@"repeating"] isEqualToString:@"true"])
    {
        repeat = [NSString stringWithFormat:@"Repeat: ON"];
    }
    else{
        repeat = [NSString stringWithFormat:@"Repeat: OFF"];
    }
    [[theMenu addItemWithTitle:repeat action:@selector(repeatToggle) keyEquivalent:@""]setTarget:self];
    
    NSString* swipingThrough;
    if(self.swipingThroughEnabled)
    {
        swipingThrough = [NSString stringWithFormat:@"Swiping: Enabled"];
    }
    else{
        swipingThrough = [NSString stringWithFormat:@"Swiping: Locked"];
    }
    [[theMenu addItemWithTitle:swipingThrough action:@selector(swipingThroughToggle) keyEquivalent:@""]setTarget:self];
//
//    [NSMenu popUpContextMenu:theMenu withEvent:theEvent forView:self];
    [theMenu popUpMenuPositioningItem:nil atLocation:NSMakePoint(0 + 2, 0 - 5) inView:self];
    
//    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
//    
//    [[theMenu addItemWithTitle:@"Beep" action:@selector(beep) keyEquivalent:@""] setTarget:self];
//    [[theMenu addItemWithTitle:@"Honk" action:@selector(honk) keyEquivalent:@""] setTarget:self];
//    
//    [theMenu popUpMenuPositioningItem:nil atLocation:NSMakePoint(self.bounds.size.width-8, self.bounds.size.height-1) inView:self];
}

-(void)beep
{
    
}
-(void)honk
{
    
}
-(void)quit
{
    [NSApp terminate:self];
}

-(void)shuffleToggle
{
    if([[self.spotifyScriptEngine getResult:@"shuffling"] isEqualToString:@"true"])
    {
        [self.spotifyScriptEngine issueCommand:@"set shuffling to false"];
    }
    else{
        [self.spotifyScriptEngine issueCommand:@"set shuffling to true"];
    }
}
-(void)repeatToggle
{
    if([[self.spotifyScriptEngine getResult:@"repeating"] isEqualToString:@"true"])
    {
        [self.spotifyScriptEngine issueCommand:@"set repeating to false"];
    }
    else{
        [self.spotifyScriptEngine issueCommand:@"set repeating to true"];
    }
}
-(void)swipingThroughToggle
{
    if(self.swipingThroughEnabled)
    {
        self.swipingThroughEnabled = NO;
    }
    else{
        self.swipingThroughEnabled = YES;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSLog(@"mouseDragged:");
    self.reallyWannaDrag++;
    if(self.reallyWannaDrag == MINIMUMDRAGEVENTNEEDED)
    {
        self.pressurizationEnabled = NO;
        self.reallyWannaDrag = 0;
    }
    
}

//-------------------------------------------- Handle mouse movement Events --------------------------------------------------------------

- (void)mouseEntered:(NSEvent *)theEvent {

    self.longInteractionEnabled = YES;
//    [self.popover setContentSize:NSMakeSize(300, 300)];
//    [self.popover showRelativeToRect: self.bounds
//                              ofView: self
//                       preferredEdge: NSMinYEdge];
//
//    [self.popover.contentViewController.view setNeedsDisplay:YES];

    self.mouseInside = YES;
    NSLog(@"mouseEntered:");
    NSPoint mousePointerLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSLog(@"%f",self.window.frame.size.width);
    NSLog(@"%f,%f",mousePointerLocation.x,mousePointerLocation.y);
    self.paused = [[self.spotifyScriptEngine getResult:@"player state"] isEqualToString:@"kPSp"];
    
    if(mousePointerLocation.x < 10.0 && !self.excitedStateForward && !self.paused && self.swipingThroughEnabled)
    {
        self.excitedStateForward = YES;
        [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer *timer){
            self.excitedStateForward = NO;
        }];
    }
    if(mousePointerLocation.x > self.window.frame.size.width - 10.0 && !self.excitedStateReverse && !self.paused && self.swipingThroughEnabled)
    {
        self.excitedStateReverse = YES;
        [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer *timer){
            self.excitedStateReverse = NO;
        }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MouseEnteredInView object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AliveSignal object:nil];
    
    NSPoint location = mousePointerLocation;
    location.x = MAX(0, location.x);
    location.x = MIN(self.myViewController.statusItem.length - 10, location.x);
    if(self.myViewController.playPauseSign.frame.size.height == 25)
    {
        [[self.myViewController.playPauseSign animator] setFrame:NSMakeRect(location.x, 0, 15, 24)];
    }
    else{
        [[self.myViewController.playPauseSign animator] setFrame:NSMakeRect(location.x, 0, 15, 25)];
    }
    self.myViewController.playPauseSign.font = [NSFont fontWithName:@"Helvetica Neue" size:10];
    
}

- (void)mouseExited:(NSEvent *)theEvent {
    [self.popupTimer invalidate];
    NSLog(@"mouseExited:");
    NSPoint mousePointerLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSLog(@"%f,%f",mousePointerLocation.x,mousePointerLocation.y);
    
    if(mousePointerLocation.x > self.window.frame.size.width - 10.0 && self.excitedStateForward && !self.dragStarted && self.swipingThroughEnabled)
    {
        [self.spotifyScriptEngine issueCommand:@"next track"];
        NSLog(@"next track");
        self.excitedStateForward = NO;
    }
    if(mousePointerLocation.x < 10.0 && self.excitedStateReverse && !self.dragStarted && self.swipingThroughEnabled)
    {
        [self.spotifyScriptEngine issueCommand:@"previous track"];
        NSLog(@"previous track");
        self.excitedStateReverse = NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MouseExitedFromView object:nil];
    //[self.popover close];
    self.mouseInside = NO;
    
    NSPoint location = mousePointerLocation;
    location.x = MAX(0, location.x);
    location.x = MIN(self.myViewController.statusItem.length - 10, location.x);
    if(self.myViewController.playPauseSign.frame.size.height == 25)
    {
        [[self.myViewController.playPauseSign animator] setFrame:NSMakeRect(location.x, 0, 15, 24)];
    }
    else{
        [[self.myViewController.playPauseSign animator] setFrame:NSMakeRect(location.x, 0, 15, 25)];
    }
    self.myViewController.playPauseSign.font = [NSFont fontWithName:@"Helvetica Neue" size:10];
    
}

- (void)mouseMoved:(NSEvent *)theEvent {
    
    self.myViewController.heartBeat = 0;
    NSPoint mousePointerLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    self.mouseLastLocation = mousePointerLocation;
    self.reallyWannaMove++;
    if(self.reallyWannaMove > 2 && self.mouseInside)
    {
        self.reallyWannaMove = 0;
        NSLog(@"mouseMoved:");
        NSPoint mousePointerLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        
        self.alphaForwardButton = MAX(mousePointerLocation.x-(self.window.frame.size.width/2),0)/(self.window.frame.size.width/2);
        self.alphaPreviousButton = MAX((self.window.frame.size.width/2)-mousePointerLocation.x, 0)/(self.window.frame.size.width/2);
        [[NSNotificationCenter defaultCenter] postNotificationName:VaryNavigationControlAlpha object:nil];
    }
}

//-------------------------------------------- Handle Touch and Pressure Events --------------------------------------------------------------

- (void)pressureChangeWithEvent:(NSEvent *)event{
    [super pressureChangeWithEvent:event]; //pass this up the responder chain.
    self.currentPressure = event.pressure + event.stage;    //get current pressure.
    [self setNeedsDisplay:YES];
    NSLog(@"%f", self.currentPressure);
    [self.popupTimer invalidate];
    if(self.currentPressure > 2.0 && self.pressurizationEnabled)
    {
        self.pressurized = YES;
        self.longInteractionEnabled = YES;
        [self.popover showRelativeToRect: self.bounds
                                  ofView: self
                           preferredEdge: NSMinYEdge];
        [self.popover setContentSize:NSMakeSize(100 * self.currentPressure, 100 * self.currentPressure)];
        [self.popover.contentViewController.view setNeedsDisplay:YES];
    }
    else if(self.currentPressure < 2.0 && self.pressurized && self.pressurizationEnabled)
    {
        [self.popover close];
        self.pressurized = NO;
    }
    
}

-(void)swipeWithEvent:(NSEvent *)event
{
    
}

- (void)touchesBeganWithEvent:(NSEvent *)event{
    if(event.type == NSEventTypeGesture){
        NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:self];
        if(touches.count == 2){
            self.twoFingersTouches = [[NSMutableDictionary alloc] init];
            
            for (NSTouch *touch in touches) {
                [self.twoFingersTouches setObject:touch forKey:touch.identity];
            }
        }
    }
}


- (void)touchesMovedWithEvent:(NSEvent*)event {
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseEnded inView:self];
    if(touches.count > 0){
        NSMutableDictionary *beginTouches = [self.twoFingersTouches copy];
        self.twoFingersTouches = nil;
        
        NSMutableArray *magnitudesX = [[NSMutableArray alloc] init];
        NSMutableArray *magnitudesY = [[NSMutableArray alloc] init];
        
        for (NSTouch *touch in touches)
        {
            NSTouch *beginTouch = [beginTouches objectForKey:touch.identity];
            
            if (!beginTouch) continue;
            
            float magnitudeX = touch.normalizedPosition.x - beginTouch.normalizedPosition.x;
            float magnitudeY = touch.normalizedPosition.y - beginTouch.normalizedPosition.y;
            [magnitudesX addObject:[NSNumber numberWithFloat:magnitudeX]];
            [magnitudesY addObject:[NSNumber numberWithFloat:magnitudeY]];
        }
        
        float sumX = 0;
        float sumY = 0;
        
        for (NSNumber *magnitude in magnitudesX)
            sumX += [magnitude floatValue];
        
        for (NSNumber *magnitude in magnitudesY)
            sumY += [magnitude floatValue];
        
        // See if absolute sum is long enough to be considered a complete gesture
        float absoluteSumX = fabsf(sumX);
        float absoluteSumY = fabsf(sumY);
        
        // Handle the actual swipe
        // This might need to be > (i am using flipped coordinates)
        if (absoluteSumX > kSwipeMinimumLength && absoluteSumX > absoluteSumY)
        {
            if (sumX > 0){
                [self.spotifyScriptEngine issueCommand:@"next track"];
                NSLog(@"go forward");
            }else{
                [self.spotifyScriptEngine issueCommand:@"previous track"];
                NSLog(@"go back");
            }
        }
        
        if (absoluteSumY > kSwipeMinimumLength && absoluteSumY > absoluteSumX)
        {
            if (sumY > 0){
                [self.spotifyScriptEngine issueCommand:@"set sound volume to 100"];
                NSLog(@"go up");
            }else{
                [self.spotifyScriptEngine issueCommand:@"set sound volume to 50"];
                NSLog(@"go down");
            }
        }
    }
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

@end
