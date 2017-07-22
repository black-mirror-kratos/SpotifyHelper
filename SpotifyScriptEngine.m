//
//  SpotifyScriptEngine.m
//  SpotifyHelper
//
//  Created by Pawan on 08/12/16.
//  Copyright © 2016 Pawan. All rights reserved.
//

#import "SpotifyScriptEngine.h"
#import "Header.h"

//static BOOL lock = NO;
static dispatch_queue_t customSerialQueue;
static BOOL lock;

@implementation SpotifyScriptEngine

//+ (NSString *)getResult:(NSString *)arg{
//    SpotifyScriptEngine *engine = [[SpotifyScriptEngine alloc]init];
//    return [engine getResult:arg];
//
//}

-(instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.mainThreadWaitLimit = 0;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken,^{
            customSerialQueue = dispatch_queue_create("custom", 0);
        });
        
    }
    
    lock = NO;
    return self;
}

- (NSString *)getResult:(NSString *)arg{
    
    NSString* res;
    
    // Can't use dispatch_sync(customSerialQueue, because causes deadlick on main thread
    
    while(lock && ![NSThread isMainThread]){
        
    }
        lock = YES;
                       NSString *command = @"tell application \"Spotify\" to ";
                       command = [command stringByAppendingString:arg];
                       self.script = [[NSAppleScript alloc]initWithSource:command];
                       NSAppleEventDescriptor* returnDescriptor = [self.script executeAndReturnError: NULL];
                       res = [returnDescriptor stringValue];
        lock = NO;
    
//                   });
    return res;
}

- (NSString *)getResultTriggeredByTimer:(NSString *)arg{
    // Copy of getResult method that takes care of case where main thread from timer refreshfast,  comes after a thread
    
    NSString* res;
    
    // Can't use dispatch_sync(customSerialQueue, because causes deadlick on main thread
    
    while(lock && [NSThread isMainThread]){
        return @"ignore";
    }
    lock = YES;
    NSString *command = @"tell application \"Spotify\" to ";
    command = [command stringByAppendingString:arg];
    self.script = [[NSAppleScript alloc]initWithSource:command];
    NSAppleEventDescriptor* returnDescriptor = [self.script executeAndReturnError: NULL];
    res = [returnDescriptor stringValue];
    lock = NO;
    return res;
}


- (void)issueCommand:(NSString *)arg{
    
    while(lock && ![NSThread isMainThread]){
        
    }
    
    // previous track requires two previous track command
    
    if([arg isEqualToString:@"previous track"])
    {
        float pos;
        pos = [[self getResult:@"player position"] floatValue];
        if(pos > 2.0)
        {
            [self reallyIssueCommandTwice:arg];
        }
        else{
            [self reallyIssueCommand:arg];
        }
    }
    else
    {
        [self reallyIssueCommand:arg];
    }
}

- (void)reallyIssueCommand:(NSString *)arg{
    
    // SerialQueue to serialize issued commands so they don't clash
    
    dispatch_async(customSerialQueue,
                   ^{
                       lock = YES;
                       NSString *command = @"tell application \"Spotify\" to ";
                       command = [command stringByAppendingString:arg];
                       NSAppleScript* script = [[NSAppleScript alloc]initWithSource:command];
                       [script executeAndReturnError: NULL];
                       lock = NO;
                   });
}

- (void)reallyIssueCommandTwice:(NSString *)arg{

    // Copy of reallyIssueCommand with command issued twice
    
    dispatch_async(customSerialQueue,
                   ^{
                       lock = YES;
                       NSString *command = @"tell application \"Spotify\" to ";
                       command = [command stringByAppendingString:arg];
                       NSAppleScript* script = [[NSAppleScript alloc]initWithSource:command];
                       [script executeAndReturnError: NULL];
                       [script executeAndReturnError: NULL];
                       lock = NO;
                   });
}

@end
