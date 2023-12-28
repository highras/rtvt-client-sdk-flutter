//
//  RtvtHandler.m
//  Runner
//
//  Created by zsl on 2022/11/10.
//

#import "RtvtHandler.h"
#import "RTVTGetToken.h"
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
    

    NSString * endpoint = [dic objectForKey:@"endpoint"];
    int64_t pid = [[dic objectForKey:@"pid"] longLongValue];
    NSString * key = [dic objectForKey:@"key"];
    if(endpoint == nil || pid == 0 || key == nil){
        result(@{@"code":@(100000),@"ex":@"rtvt login error. Invalid parameter (endpoint == nil || pid == 0 || key == nil)"});
        return;
    }
    NSDictionary * tokenDic = [RTVTGetToken getToken:key pid:[NSString stringWithFormat:@"%lld",pid]];
    
    //换另一个项目ID
    if (self.client.projectId != pid) {
        
        self.client.delegate = nil;
        [self.client closeConnect];
        
    }
        
    self.client = [RTVTClient clientWithEndpoint:endpoint
                                       projectId:pid
                                        delegate:self];
    
    [self.client loginWithToken:[tokenDic valueForKey:@"token"]
                             ts:[[tokenDic valueForKey:@"ts"] longLongValue]
                      success:^{

        result(@{@"code":@(0)});
        NSLog(@"rtvt login success");

    } connectFail:^(FPNError * _Nullable error) {

        result(@{@"code":@(error.code),@"ex":error.ex});
        NSLog(@"rtvt login fail %@",error);

    }];
    
            
    
}


-(void)_getStreamId:(NSDictionary*)dic call:(FlutterResult)result{
    

    BOOL asrResult = [[dic objectForKey:@"asrResult"] boolValue];
    BOOL transResult = [[dic objectForKey:@"transResult"] boolValue];
    BOOL asrTempResult = [[dic objectForKey:@"asrTempResult"] boolValue];
    NSString * userId = [dic objectForKey:@"userId"];
    NSString * srcLanguage = [dic objectForKey:@"srcLanguage"];
    NSString * destLanguage = [dic objectForKey:@"destLanguage"];
    NSArray * srcAltLanguage = [dic objectForKey:@"srcAltLanguage"];
    
    if (srcLanguage == nil || destLanguage == nil) {
        result(@{@"code":@(100000),@"ex":@"rtvt _getStreamId error. Invalid parameter (srcLanguage == nil || destLanguage == nil)"});
        return;
        
    }
    
    [self.client starStreamTranslateWithAsrResult:asrResult
                                      transResult:transResult
                                    asrTempResult:asrTempResult
                                           userId:userId
                                      srcLanguage:srcLanguage
                                     destLanguage:destLanguage
                                   srcAltLanguage:srcAltLanguage
                                          success:^(int64_t streamId) {
        
        result(@{@"code":@(0),@"streamId":@(streamId)});
        NSLog(@"rtvt _getStreamId success");
        
        
    } fail:^(FPNError * _Nullable error) {
        
        
        result(@{@"code":@(error.code),@"ex":error.ex});
        NSLog(@"rtvt _getStreamId fail %@",error);
        
    }];
}


-(void)_endWithStreamId:(NSDictionary*)dic call:(FlutterResult)result{
    
//    NSLog(@"%s  %@",__FUNCTION__,dic);
    int64_t streamId = [[dic objectForKey:@"streamId"] longLongValue];
    int64_t lastSeq = [[dic objectForKey:@"lastSeq"]longLongValue];
    
    if (streamId == 0) {
        result(@{@"code":@(100000),@"ex":@"rtvt _endWithStreamId error. Invalid parameter (streamId == 0)"});
        return;
        
    }
    
    [self.client endTranslateWithStreamId:streamId
                                  lastSeq:lastSeq
                                  success:^{
        
   
        result(@{@"code":@(0)});
        NSLog(@"rtvt _endWithStreamId success");
        
    } fail:^(FPNError * _Nullable error) {
        
        result(@{@"code":@(error.code),@"ex":error.ex});
        NSLog(@"rtvt _endWithStreamId fail %@",error);
        
    }];
}


-(void)_sendPcm:(NSDictionary*)dic call:(FlutterResult)result{


    FlutterStandardTypedData * tData = [dic objectForKey:@"pcmData"];
    int64_t streamId = [[dic objectForKey:@"streamId"] longLongValue];
    int64_t lastSeq = [[dic objectForKey:@"lastSeq"]longLongValue];
    int64_t ts = [[dic objectForKey:@"ts"] longLongValue];
    
    if (tData.data == nil || streamId == 0) {
        
        result(@{@"code":@(0),@"ex":@"rtvt _sendPcm fail. Invalid parameter (tData.data == nil || streamId == 0)"});
        return;
        
    }
    
    [self.client sendVoiceWithStreamId:streamId
                             voiceData:tData.data
                                   seq:lastSeq
                                    ts:ts
                               success:^{
        
        result(@{@"code":@(0)});

    } fail:^(FPNError * _Nullable error) {
 
        result(@{@"code":@(error.code),@"ex":error.ex});

    }];
    
}


-(void)_close{
    
    NSLog(@"%s",__FUNCTION__);
    [self.client closeConnect];
    
}

-(void)translatedResultWithStreamId:(int64_t)streamId
                            startTs:(int64_t)startTs
                              endTs:(int64_t)endTs
                             result:(NSString * _Nullable)result
                              recTs:(int64_t)recTs{

    
    NSMutableDictionary * arguments = [NSMutableDictionary dictionary];
    [arguments setValue:@(streamId) forKey:@"streamId"];
    [arguments setValue:@(startTs) forKey:@"startTs"];
    [arguments setValue:@(endTs) forKey:@"endTs"];
    [arguments setValue:result forKey:@"result"];
    [arguments setValue:@(recTs) forKey:@"recTs"];

    [self.methodChannel invokeMethod:@"rtvtTranslatedResult" arguments:arguments];
    
}




-(void)recognizedResultWithStreamId:(int64_t)streamId
                            startTs:(int64_t)startTs
                              endTs:(int64_t)endTs
                             result:(NSString * _Nullable)result
                              recTs:(int64_t)recTs{
    
    NSMutableDictionary * arguments = [NSMutableDictionary dictionary];
    [arguments setValue:@(streamId) forKey:@"streamId"];
    [arguments setValue:@(startTs) forKey:@"startTs"];
    [arguments setValue:@(endTs) forKey:@"endTs"];
    [arguments setValue:result forKey:@"result"];
    [arguments setValue:@(recTs) forKey:@"recTs"];
    
    [self.methodChannel invokeMethod:@"rtvtRecognizeResult" arguments:arguments];
    
}



-(void)recognizedTmpResultWithStreamId:(int64_t)streamId
                               startTs:(int64_t)startTs
                                 endTs:(int64_t)endTs
                                result:(NSString * _Nullable)result
                                 recTs:(int64_t)recTs{
    
    NSMutableDictionary * arguments = [NSMutableDictionary dictionary];
    [arguments setValue:@(streamId) forKey:@"streamId"];
    [arguments setValue:@(startTs) forKey:@"startTs"];
    [arguments setValue:@(endTs) forKey:@"endTs"];
    [arguments setValue:result forKey:@"result"];
    [arguments setValue:@(recTs) forKey:@"recTs"];
    
    [self.methodChannel invokeMethod:@"rtvtTmpRecognizeResult" arguments:arguments];
}


//重连将要开始  根据返回值是否进行重连
-(BOOL)rtvtReloginWillStart:(RTVTClient *)client reloginCount:(int)reloginCount{
    
    NSLog(@"%s ",__FUNCTION__);
    
    return YES;
    
}
//重连结果
-(void)rtvtReloginCompleted:(RTVTClient *)client reloginCount:(int)reloginCount reloginResult:(BOOL)reloginResult error:(FPNError*)error{
    
    
    NSLog(@"%s %d %d %@",__FUNCTION__,reloginResult,error.code,error.ex);
    
    NSMutableDictionary * arguments = [NSMutableDictionary dictionary];
    [arguments setValue:@(error.code) forKey:@"code"];
    if (reloginResult == YES) {
        
        [arguments setValue:@"" forKey:@"ex"];
        
    }else{
    
        [arguments setValue:error.ex forKey:@"ex"];
        
    }
    
    [self.methodChannel invokeMethod:@"rtvtReloginResult" arguments:arguments];
    
}
//关闭连接
-(void)rtvtConnectClose:(RTVTClient *)client{
    
    NSLog(@"%s ",__FUNCTION__);
    
}
@end

