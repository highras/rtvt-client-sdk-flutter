import 'dart:convert';
import 'dart:ffi';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
// import 'package:crypto/crypto.dart';

mixin RtvtDelegate {

  void rtvtRecognizeResult(
      int streamId, String result, int startTs, int endTs, int recTs);

  void rtvtTranslatedResult(
      int streamId, String result, int startTs, int endTs, int recTs);

  void rtvtTmpRecognizeResult(
      int streamId, String result, int startTs, int endTs, int recTs);

  //code = 0  success
  void rtvtReloginResult(
      int code, String ex);

}

class RtvtController {

  final MethodChannel channel = const MethodChannel('rtvt_channel');
  RtvtController._privateConstructor();
  static final RtvtController singleton = RtvtController._privateConstructor();
  factory RtvtController() {
    return singleton;
  }
  late RtvtDelegate delegate;


  Future<dynamic> _handleNativeMethodCall(MethodCall call) async {
    // do some processing
    Map result = call.arguments;
    if (call.method == "rtvtRecognizeResult") {
      delegate.rtvtRecognizeResult(result["streamId"], result["result"],
          result["startTs"], result["endTs"], result["recTs"]);
    } else if (call.method == "rtvtTranslatedResult") {
      delegate.rtvtTranslatedResult(result["streamId"], result["result"],
          result["startTs"], result["endTs"], result["recTs"]);
    } else if (call.method == "rtvtTmpRecognizeResult") {
      delegate.rtvtTmpRecognizeResult(result["streamId"], result["result"],
          result["startTs"], result["endTs"], result["recTs"]);
    } else if (call.method == "rtvtReloginResult") {
      delegate.rtvtReloginResult(result["code"], result["ex"]);
    }

  }

  /**
   *rtvt登陆
   * @param key  控制台获取的项目key
   * @param pid  控制台获取的项目id
   * @param delegate 回调类
   */
  void rtvtLogin(
      String key,
      String endpoint,
      int pid,
      RtvtDelegate delegate,
      void Function() success,
      void Function(int errorCode, String errorEx) fail) async {
        
    if (key.isEmpty || endpoint.isEmpty || pid <= 0) {
      fail(100000, "rtvt login error , parameters is invalid");
      return;
    }

    this.delegate = delegate;
    channel.setMethodCallHandler(_handleNativeMethodCall);

    // int ts = DateTime.now().second;
    // String message = pid.toString()  + ":" + ts.toString();
    // List<int> messageBytes = utf8.encode(message);
    // Uint8List key = base64.decode(projectKey);
    // Hmac hmac = new Hmac(sha256, key);
    // Digest digest = hmac.convert(messageBytes);
    // String base64Mac = base64.encode(digest.bytes);

      Map result = await singleton.channel.invokeMethod("rtvt_login",
          {"key": key, "endpoint": endpoint, "pid": pid});

      if (result["code"] == 0) {
        success();
      } else {
        fail(result["code"], result["ex"]);
      }
  }

  /**
   *开始实时翻译语音流(需要先login成功)
   * @param srcLanguage 源语言(必传)
   * @param destLanguage 翻译的目标语言 (如果不需要翻译 可空)
   * @param srcAltLanguage 备选语言列表(可空 如果传了备选语言 会有3秒自动语种识别 第一句返回的识别和翻译时长会变大）
   * @param asrResult 是否需要语音识别的结果。如果设置为true 识别结果通过recognizedResult回调
   * @param asrTempResult 是否需要临时识别结果 如果设置为true 临时识别结果通过recognizedTempResult回调(临时识别结果 用于长句快速的返回)
   * @param transResult 是否需要翻译结果 如果设置为true 翻译结果通过translatedResult回调
   * @param userId  后台显示便于查询 （业务端可以和返回的streamid绑定）
   */
  void startTranslate(
      bool asrResult,
      bool transResult,
      bool asrTempResult,
      String userId,
      String srcLanguage,
      String destLanguage,
      List<String> srcAltLanguage,
      void Function(int streamId) success,
      void Function(int errorCode, String errorEx) fail) async {

      Map result = await singleton.channel.invokeMethod("rtvt_getStreamId", {
        "asrResult": asrResult,
        "transResult": transResult,
        "asrTempResult": asrTempResult,
        "userId": userId,
        "srcLanguage": srcLanguage,
        "destLanguage": destLanguage,
        "srcAltLanguage": srcAltLanguage
      });

      if (result["code"] == 0) {
        success(result["streamId"]);
      } else {
        fail(result["code"], result["ex"]);
      }
  }

  void stopTranslate(
      int streamId,
      int lastSeq,
      void Function() success,
      void Function(int errorCode, String errorEx) fail) async {

      Map result = await singleton.channel.invokeMethod(
          "rtvt_endWithStreamId", {"streamId": streamId, "lastSeq": lastSeq});

      if (result["code"] == 0) {
        success();
      } else {
        fail(result["code"], result["ex"]);
      }

  }

  void sendPcmData(
      int streamId,
      Uint8List pcmData,
      int lastSeq,
      int ts,
      void Function() success,
      void Function(int errorCode, String errorEx) fail) async {

      Map result = await singleton.channel.invokeMethod("rtvt_sendPcm", {
        "streamId": streamId,
        "pcmData": pcmData,
        "lastSeq": lastSeq,
        "ts": ts
      });

      if (result["code"] == 0) {
        success();
      } else {
        fail(result["code"], result["ex"]);
      }

  }

  void close() {
      singleton.channel.invokeMethod("rtvt_close", "");
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
