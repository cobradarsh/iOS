#import "KAKRootListController.h"
#import <objc/runtime.h>

// Minimal private API declarations to enumerate installed apps.
@interface LSApplicationProxy : NSObject
@property (nonatomic, readonly) NSString *applicationIdentifier;
@property (nonatomic, readonly) NSString *localizedName;
@property (nonatomic, readonly) NSString *applicationType; // "User" / "System"
@end

@interface LSApplicationWorkspace : NSObject
+ (instancetype)defaultWorkspace;
- (NSArray *)allApplications;
@end

@implementation KAKRootListController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"KeepAwake";
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *specifiers = [NSMutableArray array];

		// Explanatory header.
		PSSpecifier *header = [PSSpecifier emptyGroupSpecifier];
		[header setProperty:@"Turn on the apps that should keep the screen awake while open. "
		                     "This overrides auto-lock, including in Low Power Mode. "
		                     "Changes take effect the next time you open the app."
		             forKey:@"footerText"];
		[specifiers addObject:header];

		// Collect user-installed apps.
		NSMutableArray<NSDictionary *> *apps = [NSMutableArray array];
		@try {
			LSApplicationWorkspace *workspace = [objc_getClass("LSApplicationWorkspace") defaultWorkspace];
			for (LSApplicationProxy *proxy in [workspace allApplications]) {
				NSString *bundleID = proxy.applicationIdentifier;
				NSString *name = proxy.localizedName;
				NSString *type = proxy.applicationType;
				if (bundleID.length == 0 || name.length == 0) continue;
				if (![type isEqualToString:@"User"]) continue;      // skip system apps
				if ([bundleID hasPrefix:@"com.apple."]) continue;   // belt and suspenders
				[apps addObject:@{ @"name": name, @"bundleID": bundleID }];
			}
		} @catch (__unused NSException *e) {
			// If enumeration ever fails, fall back to an empty list rather than crash.
		}

		[apps sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
			return [a[@"name"] localizedCaseInsensitiveCompare:b[@"name"]];
		}];

		// One switch per app, backed by our preferences domain.
		PSSpecifier *group = [PSSpecifier emptyGroupSpecifier];
		[group setProperty:(apps.count ? @"Apps" : @"No third-party apps found") forKey:@"label"];
		[specifiers addObject:group];

		for (NSDictionary *app in apps) {
			PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:app[@"name"]
			                                                   target:self
			                                                      set:@selector(setPreferenceValue:specifier:)
			                                                      get:@selector(readPreferenceValue:)
			                                                   detail:nil
			                                                     cell:PSSwitchCell
			                                                     edit:nil];
			[spec setProperty:@"com.cobradarsh.keepawake" forKey:@"defaults"];
			[spec setProperty:[@"enabled-" stringByAppendingString:app[@"bundleID"]] forKey:@"key"];
			[spec setProperty:@NO forKey:@"default"];
			[specifiers addObject:spec];
		}

		_specifiers = [specifiers copy];
	}
	return _specifiers;
}

@end
