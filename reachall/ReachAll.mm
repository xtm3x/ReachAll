#import <Preferences/Preferences.h>
#import <SpringBoard/SpringBoard.h>

@interface ReachAllListController: PSListController {
}
@end

@implementation ReachAllListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"ReachAll" target:self] retain];
	}
	return _specifiers;
}
- (void)twitter {

    NSString * _user = @"xTM3x";

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:_user]]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:_user]]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:_user]]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:_user]]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:_user]]];
    }
}

-(void)web {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://blog.tm3dev.appspot.com"]];
}
- (void)respring {
    NSLog(@"Give me a second...");
    system("launchctl kickstart -k system/com.apple.cfprefsd.xpc.daemon");
    NSLog(@"Thanks for the second!");
    system("killall -9 backboardd");
}
@end

// vim:ft=objc
