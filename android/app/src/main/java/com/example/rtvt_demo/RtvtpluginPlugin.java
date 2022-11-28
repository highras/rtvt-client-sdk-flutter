package com.example.rtvt_demo;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.fpnn.rtvtsdk.RTVTCenter;
import com.fpnn.rtvtsdk.RTVTClient;
import com.fpnn.rtvtsdk.RTVTPushProcessor;
import com.fpnn.rtvtsdk.RTVTStruct;
import com.fpnn.rtvtsdk.RTVTUserInterface;

import java.util.HashMap;
import java.util.logging.LogRecord;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** RtvtpluginPlugin */
public class RtvtpluginPlugin implements  FlutterPlugin ,MethodCallHandler{
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context appcontext;

  public static String CHANNEL = "rtvt_channel";  // 分析1
  public RTVTClient client = null;
  public Handler handler;


  class processdart extends RTVTPushProcessor{
    @Override
    public void recognizedResult(int streamId, int startTs, int endTs, int recTs, String srcVoiceText) {
      HashMap<String,Object> ret = new HashMap();
      ret.put("streamId",streamId);
      ret.put("startTs",startTs);
      ret.put("endTs",endTs);
      ret.put("recTs",recTs);
      ret.put("result",srcVoiceText);

//      channel.invokeMethod("rtvtRecognizeResult", ret);


      handler.post(new Runnable() {
        @Override
        public void run() {
          channel.invokeMethod("rtvtRecognizeResult", ret);
        }
      });
    }


    @Override
    public void translatedResult(int streamId, int startTs, int endTs, int recTs, String destVoiceText) {
      HashMap<String,Object> ret = new HashMap();
      ret.put("streamId",streamId);
      ret.put("startTs",startTs);
      ret.put("endTs",endTs);
      ret.put("recTs",recTs);
      ret.put("result",destVoiceText);

//      channel.invokeMethod("rtvtTranslatedResult", ret);

      handler.post(new Runnable() {
        @Override
        public void run() {
          channel.invokeMethod("rtvtTranslatedResult", ret);
        }
      });
    }
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
      channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL);
      appcontext = flutterPluginBinding.getApplicationContext();


    handler = new android.os.Handler(Looper.getMainLooper());

    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    HashMap<String,Object> ret = new HashMap();
    if (call.method.equals("rtvt_login")) {
      String key = call.argument("key");
      String endpoint = call.argument("endpoint");
      int pid = call.argument("pid");



      client = RTVTClient.CreateClient(endpoint, pid,"", new processdart(), appcontext);

      new Thread(new Runnable() {
        @Override
        public void run() {
          client.login(key, new RTVTUserInterface.IRTVTEmptyCallback() {
            @Override
            public void onResult(RTVTStruct.RTVTAnswer rtvtAnswer) {
              ret.put("code",rtvtAnswer.errorCode);
              ret.put("ex",rtvtAnswer.errorMsg);
              result.success(ret);
            }
          });
        }
      }).start();


    } else if (call.method.equals("rtvt_getStreamId")){
      String srcLanguage = call.argument("srcLanguage");
      String destLanguage = call.argument("destLanguage");
      Boolean asrResult = call.argument("asrResult");

      client.startTranslate(srcLanguage, destLanguage, asrResult, new RTVTUserInterface.IRTVTCallback<RTVTStruct.VoiceStream>() {
        @Override
        public void onResult(RTVTStruct.VoiceStream voiceStream, RTVTStruct.RTVTAnswer rtvtAnswer) {
          ret.put("code",rtvtAnswer.errorCode);
          ret.put("ex",rtvtAnswer.errorMsg);
          ret.put("streamId", voiceStream.streamId);
          result.success(ret);
        }
      });
    } else if (call.method.equals("rtvt_endWithStreamId")){
      Object streamid = call.argument("streamId");
      long streamId = Long.valueOf(String.valueOf(streamid));
      int lastSeq = call.argument("lastSeq");
      client.stopTranslate(streamId, lastSeq);
      ret.put("code",0);
      ret.put("ex","");
      result.success(ret);
    } else if (call.method.equals("rtvt_sendPcm")){
      Object streamid = call.argument("streamId");
      long streamId = Long.valueOf(String.valueOf(streamid));
      int lastSeq = call.argument("lastSeq");
      int ts = call.argument("ts");
      byte[] pcmData = call.argument("pcmData");

      client.sendVoice(streamId, lastSeq, pcmData, ts, new RTVTUserInterface.IRTVTEmptyCallback() {
        @Override
        public void onResult(RTVTStruct.RTVTAnswer rtvtAnswer) {
          ret.put("code",rtvtAnswer.errorCode);
          ret.put("ex",rtvtAnswer.errorMsg);
          result.success(ret);
        }
      });

    } else if (call.method.equals("rtvt_close")){
      client.closeRTVT();
    }

  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    appcontext = binding.getApplicationContext();
    channel.setMethodCallHandler(null);
  }
}
