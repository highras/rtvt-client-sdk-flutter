package com.example.rtvt_demo;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Base64;

import androidx.annotation.NonNull;

import com.fpnn.rtvtsdk.RTVTClient;
import com.fpnn.rtvtsdk.RTVTPushProcessor;
import com.fpnn.rtvtsdk.RTVTStruct;
import com.fpnn.rtvtsdk.RTVTUserInterface;

import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.util.HashMap;
import java.util.List;
import java.util.logging.LogRecord;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

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
  public Handler handler;


  private  RTVTClient client = null;
  private  DartRTVTPushProcessor dartRTVTPushProcessor = new DartRTVTPushProcessor();
  class DartRTVTPushProcessor extends RTVTPushProcessor{
    @Override
    public void recognizedResult(long streamId, long startTs, long endTs, long recTs, String language,String srcVoiceText,long taskId) {
      HashMap<String,Object> ret = new HashMap();
      ret.put("streamId",streamId);
      ret.put("startTs",startTs);
      ret.put("endTs",endTs);
      ret.put("recTs",recTs);
      ret.put("result",srcVoiceText);


      handler.post(new Runnable() {
        @Override
        public void run() {
          channel.invokeMethod("rtvtRecognizeResult", ret);
        }
      });
    }

    @Override
    public void recognizedTempResult(long streamId, long startTs, long endTs, long recTs, String language,String srcVoiceText,long taskId) {
      HashMap<String,Object> ret = new HashMap();
      ret.put("streamId",streamId);
      ret.put("startTs",startTs);
      ret.put("endTs",endTs);
      ret.put("recTs",recTs);
      ret.put("result",srcVoiceText);

      handler.post(new Runnable() {
        @Override
        public void run() {
          channel.invokeMethod("rtvtTmpRecognizeResult", ret);
        }
      });
    }

    @Override
    public void translatedResult(long streamId, long startTs, long endTs, long recTs, String language,String destVoiceText,long taskId) {
      HashMap<String,Object> ret = new HashMap();
      ret.put("streamId",streamId);
      ret.put("startTs",startTs);
      ret.put("endTs",endTs);
      ret.put("recTs",recTs);
      ret.put("result",destVoiceText);

      handler.post(new Runnable() {
        @Override
        public void run() {
          channel.invokeMethod("rtvtTranslatedResult", ret);
        }
      });
    }

    @Override
    public void reloginCompleted(boolean successful, RTVTStruct.RTVTAnswer answer, int reloginCount) {
//      Log.i("rtvt","rtvt reloginCompleted:" + answer.getErrInfo());
      HashMap<String,Object> ret = new HashMap();
      ret.put("code",answer.errorCode);
      ret.put("ex",answer.errorMsg);
      handler.post(new Runnable() {
        @Override
        public void run() {
          channel.invokeMethod("rtvtReloginResult", ret);
        }
      });
    }
  }

  long wantLong(Object obj) {
    long value = -1;
    if (obj instanceof Integer)
      value = ((Integer) obj).longValue();
    else if (obj instanceof Long)
      value = (Long) obj;
    else if (obj instanceof BigInteger)
      value = ((BigInteger) obj).longValue();
    else if (obj instanceof Short)
      value = ((Short) obj).longValue();
    else if (obj instanceof Byte)
      value = ((Byte) obj).longValue();
    else
      value = Long.valueOf(String.valueOf(obj));
    return value;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
      channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL);
      appcontext = flutterPluginBinding.getApplicationContext();


    handler = new android.os.Handler(Looper.getMainLooper());

    channel.setMethodCallHandler(this);
  }

  public static String genHMACToken(long pid, long ts, String key){
    String token = pid  + ":" + ts;
    String realKey = "";
    try {
      realKey =new String( Base64.decode(key, Base64.NO_WRAP), "UTF_8");
    } catch (UnsupportedEncodingException e) {
      e.printStackTrace();
    }
    String retVal = "";
    try {
      Mac mac = Mac.getInstance("HmacSHA256");
      SecretKeySpec secret = new SecretKeySpec(realKey.getBytes("UTF-8"), mac.getAlgorithm());
      mac.init(secret);

      byte[] digest = mac.doFinal(token.getBytes());
      retVal= Base64.encodeToString(digest, Base64.NO_WRAP);

    } catch (Exception e) {
      System.out.println(e.getMessage());
    }
    return  retVal;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    HashMap<String,Object> ret = new HashMap();
    if (call.method.equals("rtvt_login")) {
      String key = call.argument("key");
      String endpoint = call.argument("endpoint");
      int pid = call.argument("pid");

      if (client == null)
        client = RTVTClient.CreateClient(endpoint, pid, dartRTVTPushProcessor, appcontext);

      long ts = System.currentTimeMillis()/1000;
      String realToken = genHMACToken(pid, ts, key);

      client.login(realToken, ts, new RTVTUserInterface.IRTVTEmptyCallback() {
        @Override
        public void onError(RTVTStruct.RTVTAnswer rtvtAnswer) {
          ret.put("code",rtvtAnswer.errorCode);
          ret.put("ex",rtvtAnswer.errorMsg);
          result.success(ret);
        }
        @Override
        public void onSuccess() {
          ret.put("code",0);
          result.success(ret);
        }
      });
    } else if (call.method.equals("rtvt_getStreamId")){
      String srcLanguage = call.argument("srcLanguage");
      String destLanguage = call.argument("destLanguage");
      Boolean asrResult = call.argument("asrResult");
      Boolean asrTempResult = call.argument("asrTempResult");
      Boolean transResult = call.argument("transResult");
      List<String> srcAltLanguage = call.argument("srcAltLanguage");
      String userId = call.argument("userId");

      if (srcLanguage == null || srcLanguage.isEmpty()){
        ret.put("code",100000);
        ret.put("ex","srcLanguage is empty");
        result.success(ret);
      }

      client.startTranslate(srcLanguage, destLanguage, srcAltLanguage, asrResult, asrTempResult, transResult, false,"",userId, new RTVTUserInterface.IRTVTCallback<RTVTStruct.VoiceStream>() {
        @Override
        public void onError(RTVTStruct.RTVTAnswer rtvtAnswer) {
          ret.put("code",rtvtAnswer.errorCode);
          ret.put("ex",rtvtAnswer.errorMsg);
          result.success(ret);
        }

        @Override
        public void onSuccess(RTVTStruct.VoiceStream voiceStream) {
          ret.put("code", 0);
          ret.put("streamId", voiceStream.streamId);
          result.success(ret);
        }
      });
    } else if (call.method.equals("rtvt_endWithStreamId")){
      long streamId = wantLong(call.argument("streamId"));
      client.stopTranslate(streamId);
      ret.put("code",0);
      result.success(ret);
    } else if (call.method.equals("rtvt_sendPcm")){
      long streamId = wantLong(call.argument("streamId"));
      long lastSeq = wantLong(call.argument("lastSeq"));
      long ts = wantLong(call.argument("ts"));
      byte[] pcmData = call.argument("pcmData");

      client.sendVoice(streamId, lastSeq, pcmData, ts, new RTVTUserInterface.IRTVTEmptyCallback() {
        @Override
        public void onError(RTVTStruct.RTVTAnswer rtvtAnswer) {
          ret.put("code",rtvtAnswer.errorCode);
          ret.put("ex",rtvtAnswer.errorMsg);
          result.success(ret);
        }

        @Override
        public void onSuccess() {
          ret.put("code", 0);
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
