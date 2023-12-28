### flutter-rtvt-sdk 使用文档
- [版本支持](#版本支持)
- [集成依赖](#集成依赖)
- [接口说明](#接口说明)

### 版本支持
- Flutter 2.10.5 或更高版本
- Dart 2.14.0 或更高版本
- 根据你的目标平台，准备对应的开发和运行环境：

| 目标平台 | 环境要求 |
| --- | --- |
| Android   | 支持Android版本 5.0 及以上  |
| iOS   | 支持iOS版本 10 及以上  |


### 集成依赖
1. 打开 pubspec.yaml 文件，添加以下依赖：
```yaml  {.line-numbers}
environment:
  sdk: ">=2.12.0 <3.0.0"
# 依赖项
dependencies:
  flutter:
    sdk: flutter
  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.2
```

2.iOS 平台需要在 XCode 中做如下处理：
- 在 **TARGETS->Build Settings->Other Linker Flags** （选中 "**ALL**" 视图）中添加 "**-ObjC**"，字母 “**O**” 和 "**C**" 大写，符号 “**-**” 请勿忽略。
- 静态库中采用 **Objective-C++** 实现，因此需要您保证您工程中至少有一个 **.mm** 后缀的源文件(您可以将任意一个**.m**后缀的文件改名为**.mm**)。
- 添加库 **libresolv.9.tbd**。


###  接口说明
#### 登录
```dart {.line-numbers}
/**
 * @param token 项目token
 * @param endpoint 接入点地址
 * @param pid 项目id
 * @param RtvtDelegate 推送的回调对象
 * @param success 登录成功回调
 * @param fail 登录失败回调
*/
void rtvtLogin(String token, String endpoint, int pid, RtvtDelegate delegate,
void Function() success,
void Function(int errorCode, String errorEx) fail)
```

#### 开始翻译
```dart {.line-numbers}
/**
* @param asrResult 是否需要识别结果
* @param asrTempResult 是否需要临时识别结果
* @param transResult 是否需要翻译结果
* @param srcLanguage 源语言，必传
* @param destLanguage 目标语言，必传，可传空字符串
* @param srcAltLanguage 备选语言列表，可选
* @param userId 用户ID，业务根据需要自行填写，可选
* @param success 成功回调
* @param fail 失败回调
*/
void startTranslate(bool asrResult, bool asrTempResult, bool transResult, String srcLanguage, String destLanguage, List[String] srcAltLanguage, String userId,
void Function(int streamId) success,
void Function(int errorCode, String errorEx) fail)
```
#### 结束翻译
```dart {.line-numbers}
/**
* @param streamId 流id
* @param lastSeq 最后一个语音序号
* @param success 成功回调
* @param fail 失败回调
*/
void stopTranslate(int streamId, int lastSeq, void Function() success, void Function(int errorCode, String errorEx) fail)
```
#### 发送语音片段
```dart {.line-numbers}
/**
* @param streamId 流id
* @param pcmData 音频数据，要求pcm数据采样率为16k，单声道，每次固定640byte
* @param seq 语音片段序号
* @param ts 发送的时间戳
* @param success 成功回调
* @param fail 失败回调
*/
void sendPcmData(int streamId, Uint8List pcmData, int seq, int ts, void Function() success, void Function(int errorCode, String errorEx) fail)
```

#### 关闭语音翻译
```dart {.line-numbers}
void close()
```
#### 回调类
```dart {.line-numbers}
mixin RtvtDelegate {
  /**
  * @param streamId 流id
  * @param result 回调识别内容
  * @param startTs 开始时间戳
  * @param endTs 结束时间戳
  * @param recTs 识别的服务器时间戳
  */
  void rtvtRecognizeResult(
      int streamId, String result, int startTs, int endTs, int recTs);

  /**
  * @param streamId 流id
  * @param result 回调翻译内容
  * @param startTs 开始时间戳
  * @param endTs 结束时间戳
  * @param recTs 识别的服务器时间戳
  */
  void rtvtTranslatedResult(
      int streamId, String result, int startTs, int endTs, int recTs);

  /**
  * @param streamId 流id
  * @param result 回调临时识别内容
  * @param startTs 开始时间戳
  * @param endTs 结束时间戳
  * @param recTs 识别的服务器时间戳
  */
  void rtvtTmpRecognizeResult(
      int streamId, String result, int startTs, int endTs, int recTs);

  /**
  * @param code 0代表重连成功。成功后需要重新调用startTranslate。
  */
  void rtvtReloginResult(int code, String ex);
}
```
