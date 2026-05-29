#import "ZMLicenseManager.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

// ============================================================
// IMPORTANT: Replace this key with the one from your dashboard
// ============================================================
#define ZM_LICENSE_KEY @"ZOMBI-DAY-REPLACEME"
// ============================================================

// API server URL
#define ZM_API_BASE @"https://dynamic-link-library--nelinelikd.replit.app/api"

static NSString *getUDID(void) {
    // On jailbroken devices, UDID can be retrieved from IOKit
    // Fallback: use identifierForVendor (unique per app install)
    NSString *udid = [UIDevice currentDevice].identifierForVendor.UUIDString;
    return udid ?: @"UNKNOWN-DEVICE";
}

static NSString *getDeviceModel(void) {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

@implementation ZMLicenseManager

+ (NSString *)licenseKey {
    return ZM_LICENSE_KEY;
}

+ (void)validateWithCallback:(ZMLicenseCallback)callback {
    NSString *key = ZM_LICENSE_KEY;
    NSString *udid = getUDID();
    NSString *model = getDeviceModel();

    NSString *urlStr = [NSString stringWithFormat:@"%@/client/login", ZM_API_BASE];
    NSURL *url = [NSURL URLWithString:urlStr];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.timeoutInterval = 8.0;

    NSDictionary *body = @{
        @"key": key,
        @"udid": udid,
        @"device_model": model,
        @"app_version": @"1.0",
        @"language": @"en"
    };

    NSError *jsonError = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonError];
    if (jsonError || !bodyData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) callback(NO, @"KEY INCORRECT");
        });
        return;
    }
    request.HTTPBody = bodyData;

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 8.0;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !data) {
                if (callback) callback(NO, @"KEY INCORRECT");
                return;
            }

            NSError *parseError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (parseError || !json) {
                if (callback) callback(NO, @"KEY INCORRECT");
                return;
            }

            BOOL success = [json[@"success"] boolValue];
            NSString *message = json[@"message"] ?: @"KEY INCORRECT";

            if (success) {
                if (callback) callback(YES, @"Access Granted");
            } else {
                // Map all server error messages to "KEY INCORRECT"
                if (callback) callback(NO, @"KEY INCORRECT");
            }
        });
    }];
    [task resume];
}

@end
