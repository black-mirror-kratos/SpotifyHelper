//
//  MenubarController.m
//  SpotifyHelper
//
//  Created by Pawan on 08/12/16.
//  Copyright © 2016 Pawan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MenubarController.h"
#import "StatusItemView.h"
#import "Header.h"
#import "SpotifyScriptEngine.h"
#import "QuartzCore/QuartzCore.h"

#define STATUS_ITEM_VIEW_WIDTH 200.0

@implementation MenubarController

@synthesize statusItemView = _statusItemView;

#pragma mark -

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.spotifyScriptEngine = [[SpotifyScriptEngine alloc]init];
        self.updateUIRequest = NO;
        // Install status item into the menu bar
        NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:STATUS_ITEM_VIEW_WIDTH];
        statusItem.title = @"pawan";
        statusItem.toolTip = @"sdvsfvdf";
        _statusItemView = [[StatusItemView alloc] initWithStatusItem:statusItem];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:12], NSFontAttributeName, nil];
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:@"" attributes: attributes];
        NSSize textSize = [text size];
        self.textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 5, textSize.width, textSize.height)];
        [self.textField setStringValue:@""];
        [self.textField setBezeled:NO];
        [self.textField setDrawsBackground:NO];
        [self.textField setEditable:NO];
        [self.textField setSelectable:NO];
//        self.textField.font = [NSFont fontWithName:@"Helvetica" size:11];
        
        [self.textField setAnimations:@{@"frameOrigin": [self originAnimation]}];
    
        self.skipForwardButton = [[NSButton alloc]initWithFrame:NSMakeRect(0, 0, 20, 25)];
        self.skipBackwardButton = [[NSButton alloc]initWithFrame:NSMakeRect(0, 0, 20, 25)];
        
        self.skipForwardButton.attributedTitle = @">";
//        NSColor *color = [NSColor colorWithSRGBRed:0.3569 green:0.8392 blue:0.3725 alpha:1.0];
        NSColor *color = [NSColor blackColor];
        NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[self.skipForwardButton attributedTitle]];
        NSRange titleRange = NSMakeRange(0, [colorTitle length]);
        [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
        self.skipForwardButton.attributedTitle = colorTitle;
        
        self.skipBackwardButton.attributedTitle = @"<";
        colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[self.skipBackwardButton attributedTitle]];
        titleRange = NSMakeRange(0, [colorTitle length]);
        [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
        self.skipBackwardButton.attributedTitle = colorTitle;
        
        self.skipForwardButton.action = @selector(skipForwardButtonClicked);
        self.skipBackwardButton.action = @selector(skipBackwardButtonClicked);
        self.skipForwardButton.target = self;
        self.skipBackwardButton.target = self;
//        self.skipBackwardButton.bordered = NO;
//        self.skipForwardButton.bordered = NO;
        self.skipForwardButton.ignoresMultiClick = YES;
        self.skipBackwardButton.ignoresMultiClick = YES;
        self.skipForwardButton.enabled = NO;
        self.skipBackwardButton.enabled = NO;
        self.progressBar = [[NSProgressIndicator alloc]initWithFrame:NSMakeRect(0, 0, 0, 2)];
        [self.progressBar setStyle: NSProgressIndicatorBarStyle];
        self.progressBar.minValue = 0.0;
//        self.progressBar.maxValue = 5.0;
        [self.progressBar setIndeterminate:NO];
        //self.progressBar.doubleValue = 4.0;
        // Height does not change height of the actual indicator
        self.playPauseSign = [[NSTextField alloc]initWithFrame:NSMakeRect(0, 0, 15, 25)];
        self.playPauseSign.stringValue = @"♪";
        self.playPauseSign.editable = NO;
        self.playPauseSign.bezeled = NO;
        self.playPauseSign.drawsBackground = YES;
        self.playPauseSign.backgroundColor = [NSColor clearColor];
        self.playPauseSign.selectable = NO;
        self.playPauseSign.font = [NSFont fontWithName:@"Helvetica Neue" size:7];
        
        [self.playPauseSign setAnimations:@{@"frameOrigin": [self originAnimationMusicNoteSign]}];
        
//        CAKeyframeAnimation *keyFrameAnim = [CAKeyframeAnimation animation];
//        keyFrameAnim.calculationMode = kCAAnimationPaced;
//        keyFrameAnim.repeatCount = 2;
//        keyFrameAnim.duration = 10.0;
//        keyFrameAnim.autoreverses = YES;
//        keyFrameAnim.values = @[[NSValue valueWithPoint:NSMakePoint(0, 0)],
//                                [NSValue valueWithPoint:NSMakePoint(self.statusItem.length-10, -10)],
//                                [NSValue valueWithPoint:NSMakePoint(self.statusItem.length-10, 0)],
//                                [NSValue valueWithPoint:NSMakePoint(0, -10)],
//                                [NSValue valueWithPoint:NSMakePoint(0, 0)]];
//        [self.playPauseSign setAnimations:@{@"frameOrigin": keyFrameAnim}];
    
        self.isOverPrevButton = NO;
        
        [_statusItemView addSubview:self.textField];
        [_statusItemView addSubview:self.skipBackwardButton];
        [_statusItemView addSubview:self.skipForwardButton];
        [_statusItemView addSubview:self.progressBar];
        [_statusItemView addSubview:self.playPauseSign];
        self.skipForwardButton.hidden = YES;
        self.skipBackwardButton.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MouseEntered:)
                                                 name:MouseEnteredInView
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MouseExited:)
                                                 name:MouseExitedFromView
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(VaryControlAlpha:)
                                                 name:VaryNavigationControlAlpha
                                               object:nil];
    
    self.numberOfUpdatesRequiredToOverrideBackwardButton = SKIPBACKBUTTONSTICKINESS;
    
    self.statusItemView.myViewController = self;
    
    self.heartBeat = 0;
    
    return self;
}

-(CABasicAnimation *)originAnimation{
    CABasicAnimation * originAnim = [CABasicAnimation animation];
    CAMediaTimingFunction * timingFunc = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [originAnim setTimingFunction:timingFunc];
    [originAnim setDuration:0.3f];
    return originAnim;
}
-(CABasicAnimation *)originAnimationMusicNoteSign{
    CABasicAnimation * originAnim = [CABasicAnimation animation];
    CAMediaTimingFunction * timingFunc = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [originAnim setTimingFunction:timingFunc];
    [originAnim setDuration:1.0f];
    return originAnim;
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
    self.numberOfUpdatesRequiredToOverrideBackwardButton = 0;
}


- (IBAction) MouseEntered:(id)sender
{
    self.isOverPrevButton = NO;
    //[self.statusItemView.popover close];
    //[self updateMenubar:YES];
    NSLog(@"notification happened MouseEntered");

    [self updateMenubar:NO];
}

-(void)resetThings
{
    self.skipBackwardButton.enabled = NO;
    self.skipForwardButton.enabled = NO;
    self.isOverPrevButton = NO;
    //[self.statusItemView.popover close];
    [self updateMenubar:YES];
}

- (IBAction) MouseExited:(id)sender
{
    [self.mouseHoverDelayTimer invalidate];
    NSLog(@"notification happened MouseExited");
    self.skipBackwardButton.hidden = YES;
    self.skipForwardButton.hidden = YES;
    self.textField.alphaValue = 1.0;
//    if(self.updateUIRequest){
//        //[self.UIUpdateTimer invalidate];
//        [self updateMenubar:self.textField.stringValue];
//        self.updateUIRequest = NO;
//    }
    [self resetThings];
}

- (void)dealloc
{
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}


- (NSStatusItem *)statusItem
{
    return self.statusItemView.statusItem;
}

- (void)VaryControlAlpha:(id)sender {
    NSLog(@"notification happened VaryControlAlpha :  %f,%f",self.statusItemView.alphaForwardButton, self.statusItemView.alphaPreviousButton);
    if(self.statusItemView.alphaForwardButton > 0.6)
    {
        self.skipForwardButton.alphaValue = 1.0;
        self.skipForwardButton.enabled = YES;
        self.skipForwardButton.hidden = NO;
    }
    else{
        self.skipForwardButton.alphaValue = 0.0;
//        self.skipForwardButton.alphaValue = self.statusItemView.alphaForwardButton/2;
        self.skipForwardButton.enabled = NO;
    }
    if(self.statusItemView.alphaPreviousButton > 0.6)
    {
        self.skipBackwardButton.alphaValue = 1.0;
        self.skipBackwardButton.enabled = YES;
        self.skipBackwardButton.hidden = NO;
        if(!self.isOverPrevButton)[self updateMenubar:NO];
        self.isOverPrevButton = YES;
    }
    else{
        self.skipBackwardButton.alphaValue = 0.0;
//        self.skipBackwardButton.alphaValue = self.statusItemView.alphaPreviousButton/2;
        self.skipBackwardButton.enabled = NO;
        if(self.isOverPrevButton) [self updateMenubar:NO];
        self.isOverPrevButton = NO;
        
    }
}

-(void)updateMenubar:(NSString*) string
            ultimate:(BOOL) ultimate
{
    string = self.trackname;
    if(string == nil) return;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:12], NSFontAttributeName, nil];
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:string attributes: attributes];
    NSSize textSize = [text size];
//    if(self.skipBackwardButton.enabled)
//    {
//        self.numberOfUpdatesRequiredToOverrideBackwardButton++;
//    }
    
    if(textSize.width > 200)
    {
        if(self.skipBackwardButton.enabled && self.numberOfUpdatesRequiredToOverrideBackwardButton < SKIPBACKBUTTONSTICKINESS)
        {
            [[self.textField animator] setFrame:NSMakeRect(20, 5, textSize.width + 100, textSize.height)];
        }
        else if(self.skipBackwardButton.enabled && !ultimate)
        {
            [[self.textField animator] setFrame:NSMakeRect(20, 5, textSize.width + 100, textSize.height)];
//            self.textField.frame = NSMakeRect(20, 5, textSize.width + 100, textSize.height);
        }
        else
        {
            [[self.textField animator] setFrame:NSMakeRect(0, 5, textSize.width + 100, textSize.height)];
//            self.textField.frame = NSMakeRect(0, 5, textSize.width + 100, textSize.height);
            self.statusItem.length = 200;
            self.numberOfUpdatesRequiredToOverrideBackwardButton = 0;
            //self.skipBackwardButton.hidden = YES;
            //self.skipBackwardButton.enabled = NO;
        }
//        self.playPauseSign.frame = NSMakeRect(self.statusItem.length - 7, -3, 15, 25);
        
    }
    else if(textSize.width < 60)
    {
        if(self.skipBackwardButton.enabled && self.numberOfUpdatesRequiredToOverrideBackwardButton < SKIPBACKBUTTONSTICKINESS)
        {
            [[self.textField animator] setFrame:NSMakeRect(MAX(20,30 - textSize.width/2), 5, self.statusItem.length + 100, textSize.height)];
        }
        else if(self.skipBackwardButton.enabled && !ultimate)
        {
//            self.statusItem.length = self.statusItem.length + 20;
            [[self.textField animator] setFrame:NSMakeRect(MAX(20,30 - textSize.width/2), 5, self.statusItem.length + 100, textSize.height)];
//            self.textField.frame = NSMakeRect(MAX(20,30 - textSize.width/2), 5, self.statusItem.length + 100, textSize.height);
        }
        else{
            [[self.textField animator] setFrame:NSMakeRect(30 - textSize.width/2, 5, textSize.width + 100 + 3, textSize.height)];
//            self.textField.frame = NSMakeRect(30 - textSize.width/2, 5, textSize.width + 100 + 3, textSize.height);
            self.statusItem.length = 65;
            self.numberOfUpdatesRequiredToOverrideBackwardButton = 0;
            //self.skipBackwardButton.hidden = YES;
            //self.skipBackwardButton.enabled = NO;
        }
//        self.playPauseSign.frame = NSMakeRect(self.textField.frame.origin.x + self.textField.frame.size.width - 100, -3, 15, 25);
        
    }
    else
    {
        if(self.skipBackwardButton.enabled && self.numberOfUpdatesRequiredToOverrideBackwardButton < SKIPBACKBUTTONSTICKINESS)
        {
            [[self.textField animator] setFrame:NSMakeRect(20, 5, textSize.width + 100, textSize.height)];
        }
        else if(self.skipBackwardButton.enabled && !ultimate)
        {
//            self.statusItem.length = self.statusItem.length + 20;
            [[self.textField animator] setFrame:NSMakeRect(20, 5, textSize.width + 100, textSize.height)];
//            self.textField.frame = NSMakeRect(20, 5, textSize.width + 100, textSize.height);
        }
        else
        {
            [[self.textField animator] setFrame:NSMakeRect(0, 5, textSize.width + 100, textSize.height)];
//            self.textField.frame = NSMakeRect(0, 5, textSize.width + 100, textSize.height);
            self.statusItem.length = textSize.width + 10;
            self.numberOfUpdatesRequiredToOverrideBackwardButton = 0;
            //self.skipBackwardButton.hidden = YES;
            //self.skipBackwardButton.enabled = NO;
        }
//        self.playPauseSign.frame = NSMakeRect(self.textField.frame.origin.x + self.textField.frame.size.width - 100 + 6, -3, 15, 25);
        
    }
    
    
    if(self.statusItemView.mouseInside && self.heartBeat > MAXKEEPALIVEHEARTBEAT)
    {
        if(self.playPauseSign.font.pointSize == 10)
        {
            self.playPauseSign.font = [NSFont fontWithName:@"Helvetica Neue" size:7];
            [[self.playPauseSign animator] setFrame:NSMakeRect(self.statusItemView.mouseLastLocation.x, 0, 15, 25)];
        }
        else{
            self.playPauseSign.font = [NSFont fontWithName:@"Helvetica Neue" size:10];
            [[self.playPauseSign animator] setFrame:NSMakeRect(self.statusItemView.mouseLastLocation.x, 0, 15, 25)];
        }
        
    }
    else if((!self.statusItemView.mouseInside && (self.playPauseSign.frame.origin.x != 0 || self.playPauseSign.frame.origin.y != 0)) || self.heartBeat > MAXKEEPALIVEHEARTBEAT)
    {
        self.playPauseSign.font = [NSFont fontWithName:@"Helvetica Neue" size:7];
        [[self.playPauseSign animator] setFrame:NSMakeRect(0, 0, 15, 25)];
    }
    
//    [[self.playPauseSign animator] setFrame:NSMakeRect(0, 0, 15, 25)];
//    [self.playPauseSign setAnimations:nil];
//    self.playPauseSign.frame = NSMakeRect(0, 0, 15, 25);
    [[self.skipForwardButton animator] setFrame:NSMakeRect(self.statusItem.length - 20, 0, 20, 25)];
//    self.skipForwardButton.frame = NSMakeRect(self.statusItem.length - 20, 0, 20, 25);
    [[self.progressBar animator] setFrame:NSMakeRect(0, 0, self.statusItem.length, 2)];
//    self.progressBar.frame = NSMakeRect(0, 0, self.statusItem.length, 2);
    [[self.progressBar animator] setMaxValue:self.statusItem.length];
//    self.progressBar.maxValue = self.statusItem.length;
    [[self.textField animator] setStringValue:string];
//    self.textField.stringValue = string;
    
}

//-(void)checkIfUINeedsUpdate
//{
//    if(!self.skipBackwardButton.enabled)
//    {
//        if(self.updateUIRequest){
//            //[self.UIUpdateTimer invalidate];
//            [self updateMenubar:NO];
//            self.updateUIRequest = NO;
//        }
//    }
//}
-(void)updateMenubar:(BOOL) ultimate
{
    //NSString* string = [self.spotifyScriptEngine getResult:@"get name of current track"];
    [self updateMenubar:@"whatever" ultimate:ultimate];
}
@end
