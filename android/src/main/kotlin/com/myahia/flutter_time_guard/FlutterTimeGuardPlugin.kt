package com.myahia.flutter_time_guard

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

class FlutterTimeGuardPlugin : FlutterPlugin {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var receiver: BroadcastReceiver

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "time_change_listener")

        // Create BroadcastReceiver inside plugin
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val action = intent?.action ?: return
                if (action == Intent.ACTION_TIME_CHANGED ||
                    action == Intent.ACTION_TIMEZONE_CHANGED ||
                    action == Intent.ACTION_DATE_CHANGED) {
                    Log.d("FlutterTimeGuardPlugin", "Time change detected: $action")
                    channel.invokeMethod("onTimeChanged", null)
                }
            }
        }

        // Register receiver with intent filter
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_TIME_CHANGED)
            addAction(Intent.ACTION_TIMEZONE_CHANGED)
            addAction(Intent.ACTION_DATE_CHANGED)
        }
        context.registerReceiver(receiver, filter)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context.unregisterReceiver(receiver)
        channel.setMethodCallHandler(null)
    }
}
