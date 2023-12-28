//
//  RtvtHandler.h
//  Runner
//
//  Created by zsl on 2022/11/10.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <RTVT/RTVT.h>
NS_ASSUME_NONNULL_BEGIN

@interface RtvtHandler : NSObject

+ (instancetype)sharedManager:(NSObject<FlutterBinaryMessenger>*)messenger;

@end

NS_ASSUME_NONNULL_END
