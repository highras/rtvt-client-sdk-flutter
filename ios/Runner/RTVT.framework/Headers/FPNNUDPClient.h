//
//  FPNNUDPClient.h
//  Rtm
//
//  Created by zsl on 2021/8/9.
//  Copyright © 2021 FunPlus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPNNCallBackDefinition.h"
NS_ASSUME_NONNULL_BEGIN

@class FPNNQuest,FPNNAnswer,FPNNCallBackHandler;

@interface FPNNUDPClient : NSObject

@property (nonatomic,copy)FPNNConnectionSuccessCallBack connectionSuccessCallBack;
@property (nonatomic,copy)FPNNConnectionCloseCallBack connectionCloseCallBack;
@property (nonatomic,copy)FPNNListenAndReplyCallBack listenAndReplyCallBack;
@property (nonatomic,readonly,strong)NSString *  _Nullable pid;
+ (instancetype _Nullable)clientWithEndpoint:(NSString * _Nonnull)endpoint pid:(NSString *)pid;

- (BOOL)sendUdpQuest:(FPNNQuest * _Nonnull)quest
          timeout:(int)timeout
          success:(FPNNAnswerSuccessCallBack)successCallback
             fail:(FPNNAnswerFailCallBack)failCallback;

- (void)closeConnect;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
