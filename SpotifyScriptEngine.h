//
//  SpotifyScriptEngine.h
//  SpotifyHelper
//
//  Created by Pawan on 08/12/16.
//  Copyright © 2016 Pawan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpotifyScriptEngine : NSObject

-(NSString *)getResult:(NSString *)arg;
- (NSString *)getResultTriggeredByTimer:(NSString *)arg;
- (void)issueCommand:(NSString *)arg;
- (void)reallyIssueCommand:(NSString *)arg;
@property NSAppleScript* script;
@property NSAppleEventDescriptor* returnDescriptor;
@property int mainThreadWaitLimit;

//- (NSString *)getResult:(NSString *)arg;
@end
