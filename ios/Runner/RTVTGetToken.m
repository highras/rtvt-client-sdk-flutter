//
//  GeyTokenTest.m
//  SdkTest
//
//  Created by zsl on 2022/11/23.
//  Copyright © 2022 FunPlus. All rights reserved.
//

#import "RTVTGetToken.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation RTVTGetToken

+ (NSString *)md5:(NSString*)string {
    
    if(string == nil || [string length] == 0){
        return nil;
    }
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}
+ (NSData *)hmacSHA256WithSecret:(NSString *)secret content:(NSString *)content{
    
    const char *cKey  = [secret cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [content cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
//    NSLog(@"HMAC  %@",HMAC);
//    NSMutableString *hexString = [NSMutableString string];
//    for (int i=0; i<sizeof(cHMAC); i++){
//        [hexString appendFormat:@"%02x", cHMAC[i]];
//    }
    return HMAC;
}
+ (NSString *)base64DecodingString:(NSString*)key {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:key options:0];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
+(NSDictionary*)getToken:(NSString*)key pid:(NSString*)pid{
    
    NSString * secert = [RTVTGetToken base64DecodingString:key];
    NSString * time = [NSString stringWithFormat:@"%@",[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]];
    NSString * source_step1 = [NSString stringWithFormat:@"%@:%@",pid,time];
    NSData * h256Data_step2 = [RTVTGetToken hmacSHA256WithSecret:secert content:source_step1];
    NSString * base64Result = [h256Data_step2 base64EncodedStringWithOptions:0];
    return @{@"ts":time,@"token":base64Result};
    
}

@end
