import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'RtvtController.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'RTVT'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with RtvtDelegate {
  @override
  void rtvtRecognizeResult(
      int streamId, String result, int startTs, int endTs, int recTs) {
    print("rtvtRecognizeResult ${result}");
  }

  @override
  void rtvtTranslatedResult(
      int streamId, String result, int startTs, int endTs, int recTs) {
    print("rtvtTranslatedResult ${result}");
    setState(() {
      hintString = result;
    });
  }

  RtvtController controller = RtvtController();
  Future<ByteData> byteData = rootBundle.load('langFiles/zh.pcm');
  ByteData pcmData = ByteData(0);
  Timer timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
    timer.cancel();
  });
  int _streamId = 0;
  String hintString = "";
  //登录
  void _login() {
    setState(() {
      hintString = "登录中...";
    });

    controller.login("qwerty", "rtvt.ilivedata.com:14001", 90008000, this,
        () {
      setState(() {
        hintString = "登录成功123";
      });
    },  (errorCode, errorEx) {
      print("登录失败 ,errorCode:${errorCode}  ====   ex:${errorEx}");
      setState(() {
        hintString = "登录失败";
      });
    });
  }

  //拉取streamId
  void _getStreamId() {
    if (_streamId == 0) {
      setState(() {
        hintString = "拉取streamId...";
      });

      controller.getStreamId(true, "zh", "en", (streamId) {
        print("_getStreamId  ${streamId}");
        _streamId = streamId;
        setState(() {
          hintString = "拉取streamId成功";
        });
      }, (errorCode, errorEx) {
        print("获取streamId失败 ,errorCode:${errorCode}  ====   ex:${errorEx}");
        setState(() {
          hintString = "拉取streamId失败";
        });
      });
    }
  }

  //开始发送 方便演示采取了读取文件发送 数据要求pcm 16bit 16000 单声道 每次320采样点
  void _startWithStreamId() {
    if (_streamId != 0) {
      setState(() {
        hintString = "开始翻译...";
      });

      byteData.then((ByteData value) {
        pcmData = value;
      });

      int start = 0;
      int seq = 1;

      timer = Timer.periodic(Duration(milliseconds: 20), (timer) {
        Uint8List frameData = Uint8List.view(pcmData.buffer, start, 640);
        controller.sendPcmData(
            _streamId, frameData, seq, 0, () {}, (errorCode, errorEx) {});

        start = start + 640;
        seq = seq + 1;

        if (start + 640 >= pcmData.lengthInBytes) {
          timer.cancel();
          setState(() {
            hintString = "翻译结束";
          });
        } else {
          // setState(() {

          //    hintString = translateString;
          //    print("tr :$translateString");
          //    print("hr :$hintString");

          // });
        }
      });
    }
  }

//结束
  void _endStreamId() {
    if (timer.isActive) {
      timer.cancel();
    }
    // controller.close();
    _streamId = 0;
    setState(() {
      hintString = "已关闭链接";
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(child: Text("1点击登录"), onPressed: _login),
            TextButton(child: Text("2获取streamId"), onPressed: _getStreamId),
            TextButton(child: Text("3开始发送"), onPressed: _startWithStreamId),
            TextButton(child: Text("4结束翻译"), onPressed: _endStreamId),
            Text('$hintString')
          ],
        ),
      ),
    );
  }
}
