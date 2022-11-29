import 'dart:ffi';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

mixin RtvtDelegate {
  void rtvtRecognizeResult(
      int streamId, String result, int startTs, int endTs, int recTs);

  void rtvtTranslatedResult(
      int streamId, String result, int startTs, int endTs, int recTs);
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
    // print(call.method);
    Map result = call.arguments;
    if (call.method == "rtvtRecognizeResult") {
      delegate.rtvtRecognizeResult(result["streamId"], result["result"],
          result["startTs"], result["endTs"], result["recTs"]);
    } else if (call.method == "rtvtTranslatedResult") {
      delegate.rtvtTranslatedResult(result["streamId"], result["result"],
          result["startTs"], result["endTs"], result["recTs"]);
    }
  }


  void login(
      String key,
      String endpoint,
      int pid,
      RtvtDelegate delegate,
      void Function() success,
      void Function(int errorCode, String errorEx) fail) async {
    if (key.isEmpty || endpoint.isEmpty || pid == 0) {
      fail(00000, "rtvt login error , parameters is fail");
      return;
    }

    this.delegate = delegate;
    channel.setMethodCallHandler(_handleNativeMethodCall);

      Map result = await singleton.channel.invokeMethod("rtvt_login",
          {"key": key, "endpoint": endpoint, "pid": pid});

      if (result["code"] == 0) {
        success();
      } else {
        fail(result["code"], result["ex"]);
      }
  }

  void getStreamId(
      bool asrResult,
      String srcLanguage,
      String destLanguage,
      void Function(int streamId) success,
      void Function(int errorCode, String errorEx) fail) async {

      Map result = await singleton.channel.invokeMethod("rtvt_getStreamId", {
        "asrResult": asrResult,
        "srcLanguage": srcLanguage,
        "destLanguage": destLanguage
      });

      if (result["code"] == 0) {
        success(result["streamId"]);
      } else {
        fail(result["code"], result["ex"]);
      }
  }

  void endTranslateWithStreamId(
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
