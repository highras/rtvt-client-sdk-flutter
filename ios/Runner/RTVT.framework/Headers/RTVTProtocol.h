//
//  RTMProtocol.h
//  Rtm
//
//  Created by zsl on 2019/12/16.
//  Copyright © 2019 FunPlus. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class RTVTClient,RTVTAnswer,FPNError,RTVTMessage;
@protocol RTVTProtocol <NSObject>



-(void)translatedResultWithStreamId:(int64_t)streamId
                            startTs:(int64_t)startTs
                              endTs:(int64_t)endTs
                             result:(NSString * _Nullable)result
                              recTs:(int64_t)recTs;

-(void)recognizedResultWithStreamId:(int64_t)streamId
                            startTs:(int64_t)startTs
                              endTs:(int64_t)endTs
                             result:(NSString * _Nullable)result
                              recTs:(int64_t)recTs;

-(void)recognizedTmpResultWithStreamId:(int64_t)streamId
                               startTs:(int64_t)startTs
                                 endTs:(int64_t)endTs
                                result:(NSString * _Nullable)result
                                 recTs:(int64_t)recTs;


//重连只有在登录成功过1次后才会有效
//重连将要开始  根据返回值是否进行重连
-(BOOL)rtvtReloginWillStart:(RTVTClient *)client reloginCount:(int)reloginCount;
//重连结果
-(void)rtvtReloginCompleted:(RTVTClient *)client reloginCount:(int)reloginCount reloginResult:(BOOL)reloginResult error:(FPNError*)error;
//关闭连接  
-(void)rtvtConnectClose:(RTVTClient *)client;


@end

NS_ASSUME_NONNULL_END

