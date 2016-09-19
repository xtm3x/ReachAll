#import "SBReachabilityManager.h"
#import <UIKit/UIKit.h>
#include <objc/runtime.h>
#import <libactivator/libactivator.h>

NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.xtm3x.reachall~prefs.plist"];

BOOL enabled;
BOOL offset;
CGFloat off;

static void loadPreferences()
{
    enabled = [dict objectForKey:@"enabled"] ? [[dict objectForKey:@"enabled"] boolValue] : TRUE;
    offset = [[dict objectForKey:@"offset"] boolValue];
    off = [[dict objectForKey:@"off"] floatValue];
}

@interface ReachTest : NSObject <LAListener, UIAlertViewDelegate> {
@private
        id _av;
}

+ (id)sharedInstance;

@end

@implementation ReachTest

+ (id)sharedInstance {
        static id sharedInstance = nil;
        static dispatch_once_t token = 0;
        dispatch_once(&token, ^{
                sharedInstance = [self new];
        });
        return sharedInstance;
}

+ (void)load {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        // Register our listener
        if (LASharedActivator.isRunningInsideSpringBoard) {
                [LASharedActivator registerListener:[self sharedInstance] forName:@"com.xtm3x.reachtest"];
        }
        [pool release];
}

- (void)dealloc {
        [_av release];
        if (LASharedActivator.runningInsideSpringBoard) {
                [LASharedActivator unregisterListenerWithName:@"com.xtm3x.reachtest"];
        }
        [super dealloc];
}

// LAListener protocol methods

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
        [[%c(SBReachabilityManager) sharedInstance] _handleReachabilityActivated];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
        // Called when event is escalated to a higher event
        // (short-hold sleep button becomes long-hold shutdown menu, etc)
        [[%c(SBReachabilityManager) sharedInstance] _handleReachabilityDeactivated];
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event {
        // Called when some other listener received an event; we should cleanup
        [[%c(SBReachabilityManager) sharedInstance] _handleReachabilityDeactivated];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event {
        // Called when the home button is pressed.
        // If (and only if) we are showing UI, we should dismiss it and call setHandled:
        [[%c(SBReachabilityManager) sharedInstance] _handleReachabilityDeactivated];
}

// Metadata
// Group name
- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
        return @"";
}
// Listener name
- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
        return @"ReachAll";
}
// Listener description
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
        return @"Invoke Reachability";
}
/* Group assignment filtering
- (NSArray *)activator:(LAActivator *)activator requiresExclusiveAssignmentGroupsForListenerName:(NSString *)listenerName {
        return [NSArray array];
}*/


@end

%hook SBReachabilitySettings
-(BOOL)allowOnAllDevices {
    loadPreferences();
	if(enabled) {
		return TRUE;
	}
	else {
		return %orig;
	}
}
-(CGFloat)yOffsetFactor {
    loadPreferences();
    if(enabled) {
        if(offset) {
            return off;
        }
        else {
            return %orig;
        }
    }
    else {
        return %orig;
    }
}
%end