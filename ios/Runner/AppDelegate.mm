#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <Flutter/Flutter.h>
#import "RtvtHandler.h"

@interface AppDelegate()


@end
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
   [GeneratedPluginRegistrant registerWithRegistry:self];
    

    FlutterViewController<FlutterBinaryMessenger> *vc = (FlutterViewController<FlutterBinaryMessenger> *)self.window.rootViewController;
    [RtvtHandler sharedManager:vc.binaryMessenger];
    

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
