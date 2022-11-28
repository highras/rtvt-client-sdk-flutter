package com.example.rtvt_demo;
import android.app.Activity;
import android.os.Bundle;

import java.util.logging.Handler;

import io.flutter.*;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugins.*;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        //插件实例的注册...
        flutterEngine.getPlugins().add(new RtvtpluginPlugin());

        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}
