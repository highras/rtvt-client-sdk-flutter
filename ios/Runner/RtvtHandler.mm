//
//  RtvtHandler.m
//  Runner
//
//  Created by 张世良 on 2022/11/10.
//

#import "RtvtHandler.h"
@interface RtvtHandler()<RTVTProtocol>

@property(nonatomic,weak)NSObject <FlutterBinaryMessenger> * messenger;
@property(nonatomic,strong)FlutterMethodChannel *methodChannel;
@property(nonatomic,strong)RTVTClient * client;

@end
@implementation RtvtHandler

+ (instancetype)sharedManager:(NSObject<FlutterBinaryMessenger>*)messenger{
    static RtvtHandler *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [RtvtHandler new];
        _sharedManager.messenger = messenger;
        [_sharedManager _setChannel];
    });

    return _sharedManager;
}

-(void)_setChannel{
    
    
    self.methodChannel = [FlutterMethodChannel methodChannelWithName:@"rtvt_channel" binaryMessenger:self.messenger];
    __weak typeof(self) weakSelf = self;
    [self.methodChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        __strong typeof(self) strongSelf = weakSelf;
        NSString *method = call.method;
//        NSLog(@"Channel methodmethodmethod  ===== %@",method);
        
        if ([method isEqualToString:@"rtvt_login"]) {
            [strongSelf _login:call.arguments call:result];
        }else if ([method isEqualToString:@"rtvt_getStreamId"]) {
            [strongSelf _getStreamId:call.arguments call:result];
        }else if ([method isEqualToString:@"rtvt_endWithStreamId"]) {
            [strongSelf _endWithStreamId:call.arguments call:result];
        }else if ([method isEqualToString:@"rtvt_sendPcm"]) {
            [strongSelf _sendPcm:call.arguments call:result];
        }else if ([method isEqualToString:@"rtvt_close"]) {
            [strongSelf _close];
        }
        
    }];
    
}

-(void)_login:(NSDictionary*)dic call:(FlutterResult)result{
    
//    NSLog(@"%s  %@",__FUNCTION__,dic);
    NSString * endpoint = [dic objectForKey:@"endpoint"];
    NSString * key = [dic objectForKey:@"key"];
    int64_t pid = [[dic objectForKey:@"pid"] longLongValue];
    int64_t uid = [[dic objectForKey:@"uid"] longLongValue];
    
    if (self.client.userId != uid || self.client.projectId != pid) {
        
        self.client.delegate = nil;
        [self.client closeConnect];
        
    }
        
    self.client = [RTVTClient clientWithEndpoint:endpoint
                                       projectId:pid
                                          userId:uid
                                        delegate:self];
    
    [self.client loginWithKey:key success:^{

        result(@{@"code":@(0)});

    } connectFail:^(FPNError * _Nullable error) {
    
        result(@{@"code":@(error.code),@"ex":error.ex});
        
    }];
        
    
}


-(void)_getStreamId:(NSDictionary*)dic call:(FlutterResult)result{
    
//    NSLog(@"%s  %@",__FUNCTION__,dic);
    BOOL asrResult = [[dic objectForKey:@"asrResult"] boolValue];
    NSString * srcLanguage = [dic objectForKey:@"srcLanguage"];
    NSString * destLanguage = [dic objectForKey:@"destLanguage"];
    
    [self.client starStreamTranslateWithAsrResult:asrResult
                                      srcLanguage:srcLanguage
                                     destLanguage:destLanguage
                                          success:^(int64_t streamId) {
        
        result(@{@"code":@(0),@"streamId":@(streamId)});
        
    } fail:^(FPNError * _Nullable error) {
        
        result(@{@"code":@(error.code),@"ex":error.ex});
        
    }];
    
}


-(void)_endWithStreamId:(NSDictionary*)dic call:(FlutterResult)result{
    
//    NSLog(@"%s  %@",__FUNCTION__,dic);
    int64_t streamId = [[dic objectForKey:@"streamId"] longLongValue];
    int64_t lastSeq = [[dic objectForKey:@"lastSeq"]longLongValue];
    
    [self.client endTranslateWithStreamId:streamId
                                  lastSeq:lastSeq
                                  success:^{
        
   
        result(@{@"code":@(0)});
        
    } fail:^(FPNError * _Nullable error) {
        
        result(@{@"code":@(error.code),@"ex":error.ex});
        
    }];
}


-(void)_sendPcm:(NSDictionary*)dic call:(FlutterResult)result{

//    NSLog(@"%s  %@",__FUNCTION__,dic);
    FlutterStandardTypedData * tData = [dic objectForKey:@"pcmData"];
    int64_t streamId = [[dic objectForKey:@"streamId"] longLongValue];
    int64_t lastSeq = [[dic objectForKey:@"lastSeq"]longLongValue];
    int ts = [[dic objectForKey:@"ts"] intValue];
    [self.client sendVoiceWithStreamId:streamId
                             voiceData:tData.data
                                   seq:lastSeq
                                    ts:ts
                               success:^{
        
        result(@{@"code":@(0),@"errorEx":@""});

    } fail:^(FPNError * _Nullable error) {
 
        result(@{@"code":@(error.code),@"errorEx":error.ex});

    }];
    
}


-(void)_close{
    
//    NSLog(@"%s",__FUNCTION__);
    [self.client closeConnect];
    
}


-(void)translatedResultWithStreamId:(int64_t)streamId startTs:(int)startTs endTs:(int)endTs result:(NSString *)result recTs:(int)recTs{
//    NSLog(@"translatedResultWithStreamIdtranslatedResultWithStreamId  %@",result);
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        NSMutableDictionary * arguments = [NSMutableDictionary dictionary];
        [arguments setValue:@(streamId) forKey:@"streamId"];
        [arguments setValue:@(startTs) forKey:@"startTs"];
        [arguments setValue:@(endTs) forKey:@"endTs"];
        [arguments setValue:result forKey:@"result"];
        [arguments setValue:@(recTs) forKey:@"recTs"];

        [self.methodChannel invokeMethod:@"rtvtTranslatedResult" arguments:arguments];

//    });
}
-(void)recognizedResultWithStreamId:(int64_t)streamId startTs:(int)startTs endTs:(int)endTs result:(NSString *)result recTs:(int)recTs{
//    NSLog(@"recognizedResultWithStreamId  %@",result);
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary * arguments = [NSMutableDictionary dictionary];
        [arguments setValue:@(streamId) forKey:@"streamId"];
        [arguments setValue:@(startTs) forKey:@"startTs"];
        [arguments setValue:@(endTs) forKey:@"endTs"];
        [arguments setValue:result forKey:@"result"];
        [arguments setValue:@(recTs) forKey:@"recTs"];
        
        [self.methodChannel invokeMethod:@"rtvtRecognizeResult" arguments:arguments];
        
//    });
}

//-(BOOL)rtvtReloginWillStart:(RTVTClient *)client reloginCount:(int)reloginCount{
//    return YES;
//}
//-(void)rtvtReloginCompleted:(RTVTClient *)client reloginCount:(int)reloginCount reloginResult:(BOOL)reloginResult error:(FPNError*)error{
//
//}
//-(void)rtvtConnectClose:(RTVTClient *)client{
//
//}
@end

