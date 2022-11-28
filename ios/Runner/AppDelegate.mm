#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <Flutter/Flutter.h>
#import "RtvtHandler.h"

@interface AppDelegate()

@property (nonatomic, strong) FlutterEngine *flutterEngine;
@property (nonatomic, strong) FlutterMethodChannel *methodChannel;

@end
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [GeneratedPluginRegistrant registerWithRegistry:self];
    

    FlutterViewController<FlutterBinaryMessenger> *vc = (FlutterViewController<FlutterBinaryMessenger> *)self.window.rootViewController;
    [RtvtHandler sharedManager:vc.binaryMessenger];
    

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

//- (void)sendOnChannel:(NSString*)channel message:(NSData* _Nullable)message{
//    NSLog(@"%s",__FUNCTION__);
//}
//
///**
// * Sends a binary message to the Flutter side on the specified channel, expecting
// * an asynchronous reply.
// *
// * @param channel The channel name.
// * @param message The message.
// * @param callback A callback for receiving a reply.
// */
//- (void)sendOnChannel:(NSString*)channel
//              message:(NSData* _Nullable)message
//          binaryReply:(FlutterBinaryReply _Nullable)callback{
//    NSLog(@"%s",__FUNCTION__);
//}
//
///**
// * Registers a message handler for incoming binary messages from the Flutter side
// * on the specified channel.
// *
// * Replaces any existing handler. Use a `nil` handler for unregistering the
// * existing handler.
// *
// * @param channel The channel name.
// * @param handler The message handler.
// * @return An identifier that represents the connection that was just created to the channel.
// */
//- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(NSString*)channel
//                                          binaryMessageHandler:(FlutterBinaryMessageHandler _Nullable)handler{
//
//    NSLog(@"%s",__FUNCTION__);
//    return 1;
//}
//
///**
// * Clears out a channel's message handler if that handler is still the one that
// * was created as a result of
// * `setMessageHandlerOnChannel:binaryMessageHandler:`.
// *
// * @param connection The result from `setMessageHandlerOnChannel:binaryMessageHandler:`.
// */
//-(void)cleanUpConnection:(FlutterBinaryMessengerConnection)connection{
//    NSLog(@"%s",__FUNCTION__);
//}

- (FlutterEngine *)flutterEngine {
    if (!_flutterEngine) {
        FlutterEngine *flutterEngine = [[FlutterEngine alloc] initWithName:@"andy"];
        // FlutterEngine 需要 run 起来, 有可能失败.
        // 所以只有 run 成功的时候才赋值.
        if ([flutterEngine run]) {
            NSLog(@"([flutterEngine run])([flutterEngine run])");
            _flutterEngine = flutterEngine;
        }
    }
    return _flutterEngine;
}
@end
