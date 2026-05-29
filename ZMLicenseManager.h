#import <Foundation/Foundation.h>

typedef void (^ZMLicenseCallback)(BOOL success, NSString *message);

@interface ZMLicenseManager : NSObject

// The license key embedded at build time — replace before compiling
+ (NSString *)licenseKey;

// Validates the key with the API server and registers this device
// Calls callback on the main thread
+ (void)validateWithCallback:(ZMLicenseCallback)callback;

@end
