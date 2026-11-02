#import <UIKit/UIKit.h>

// Preferences domain shared with the Settings bundle.
static NSString *const kPrefsDomain = @"com.cobradarsh.keepawake";

// Is "keep awake" enabled for the app this dylib is loaded into?
static BOOL isCurrentAppEnabled(void) {
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	if (bundleID.length == 0) return NO;

	NSString *key = [@"enabled-" stringByAppendingString:bundleID];

	// Read the freshest on-disk value (works on rootless/RootHide: the plist
	// lives under the jailbreak root, but cfprefsd resolves it by domain).
	CFPreferencesAppSynchronize((__bridge CFStringRef)kPrefsDomain);
	Boolean valid = false;
	Boolean value = CFPreferencesGetAppBooleanValue((__bridge CFStringRef)key,
	                                                 (__bridge CFStringRef)kPrefsDomain,
	                                                 &valid);
	return valid ? (BOOL)value : NO;
}

static void applyKeepAwake(BOOL appIsActive) {
	UIApplication *app = [UIApplication sharedApplication];
	if (!app) return;
	// Disable the idle timer only while the app is active AND enabled.
	// idleTimerDisabled overrides auto-lock, Low Power Mode included.
	BOOL shouldStayAwake = appIsActive && isCurrentAppEnabled();
	if (app.idleTimerDisabled != shouldStayAwake) {
		app.idleTimerDisabled = shouldStayAwake;
	}
}

%ctor {
	@autoreleasepool {
		// This dylib is injected into every UIKit app. Never touch SpringBoard
		// itself — it is never a toggle target and we don't want to alter it.
		NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
		if ([bundleID isEqualToString:@"com.apple.springboard"]) return;

		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

		// App came to the foreground -> turn keep-awake on if enabled.
		[nc addObserverForName:UIApplicationDidBecomeActiveNotification
		                object:nil
		                 queue:[NSOperationQueue mainQueue]
		            usingBlock:^(NSNotification *note) { applyKeepAwake(YES); }];

		// App left the foreground -> always restore normal auto-lock behavior.
		[nc addObserverForName:UIApplicationWillResignActiveNotification
		                object:nil
		                 queue:[NSOperationQueue mainQueue]
		            usingBlock:^(NSNotification *note) { applyKeepAwake(NO); }];
	}
}
