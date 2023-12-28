



 
// 1.在TARGETS->Build Settings->Other Linker Flags （选中ALL视图）中添加-ObjC，字母O和C大写，符号“-”请勿忽略
//2.静态库中采用Objective-C++实现，因此需要您保证您工程中至少有一个.mm后缀的源文件(您可以将任意一个.m后缀的文件改名为.mm)
// 3.添加库libresolv.9.tbd



#import <RTVT/FPNNTCPClient.h>
#import <RTVT/FPNNUDPClient.h>
#import <RTVT/FPNNAnswer.h>
#import <RTVT/FPNNQuest.h>
#import <RTVT/FPNError.h>
#import <RTVT/RTVTClient.h>
#import <RTVT/RTVTAnswer.h>
