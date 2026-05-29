/*
 * Zombi Mod — SERFCN Licensed Tweak
 * Panel: ZOMBI MOD
 *
 * Key format: ZOMBI-DAY-xxxxxxxxxxxxxxxx
 * Generated from: https://YOUR-REPLIT-DOMAIN.replit.app
 *
 * API: https://6845e6a2-c0db-45b7-9ce3-21b490fade36-00-1tr2yzhluebrj.worf.replit.dev/api
 *
 * HOW IT WORKS:
 * 1. The license key is hardcoded in ZMLicenseManager.m (ZM_LICENSE_KEY)
 * 2. When the floating "Z" button is tapped, it calls the API to validate
 * 3. If key is valid → ZOMBI MOD menu opens
 * 4. If key is invalid → "KEY INCORRECT" alert shown (no key entry prompt)
 *
 * BEFORE BUILDING:
 *   1. Set ZM_LICENSE_KEY in ZMLicenseManager.m
 *   2. Set ZM_API_BASE in ZMLicenseManager.m to your Replit app URL
 *   3. Set BUNDLE_FILTER in Makefile to the target game's bundle ID
 */

#import <UIKit/UIKit.h>
#import "ZMFloatingButton.h"
#import "ZMMenuController.h"

%hook UIApplication

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [[ZMFloatingButton sharedButton] show];
    });

    return result;
}

%end
