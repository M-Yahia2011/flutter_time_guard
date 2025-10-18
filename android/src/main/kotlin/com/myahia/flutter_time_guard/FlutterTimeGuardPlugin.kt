package com.myahia.flutter_time_guard

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
class FlutterTimeGuardPlugin : FlutterPlugin, DefaultLifecycleObserver {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var timeChangeReceiver: BroadcastReceiver
    private lateinit var screenStateReceiver: BroadcastReceiver
    private var isAppInBackground = false
    private var isScreenOn = true

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "time_change_listener")
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "reset" -> {
                    Log.d("FlutterTimeGuardPlugin", "Reset invoked from Flutter side")
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        context = binding.applicationContext

        ProcessLifecycleOwner.get().lifecycle.addObserver(this)

        // Time change receiver
        timeChangeReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val action = intent?.action ?: return
                if (action == Intent.ACTION_TIME_CHANGED ||
                    action == Intent.ACTION_TIMEZONE_CHANGED ||
                    action == Intent.ACTION_DATE_CHANGED) {

                    Log.d("FlutterTimeGuardPlugin", "Time change detected: $action")

                    if (shouldNotify()) {
                        channel.invokeMethod("onTimeChanged", null)
                    }
                   
                }
            }
        }

        val timeChangeFilter = IntentFilter().apply {
            addAction(Intent.ACTION_TIME_CHANGED)
            addAction(Intent.ACTION_TIMEZONE_CHANGED)
            addAction(Intent.ACTION_DATE_CHANGED)
        }
        context.registerReceiver(timeChangeReceiver, timeChangeFilter)

        // Screen state receiver
        screenStateReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val action = intent?.action ?: return
                isScreenOn = action == Intent.ACTION_SCREEN_ON
                Log.d("FlutterTimeGuardPlugin", "Screen state changed: ${if (isScreenOn) "ON" else "OFF"}")
            }
        }

        val screenFilter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_SCREEN_OFF)
        }
        context.registerReceiver(screenStateReceiver, screenFilter)
    }

    override fun onStart(owner: LifecycleOwner) {
        isAppInBackground = false
    }

    override fun onStop(owner: LifecycleOwner) {
        isAppInBackground = true
    }
    private fun shouldNotify(): Boolean {
        return isAppInBackground &&  isScreenOn
    }
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context.unregisterReceiver(timeChangeReceiver)
        context.unregisterReceiver(screenStateReceiver)
        ProcessLifecycleOwner.get().lifecycle.removeObserver(this)
        channel.setMethodCallHandler(null)
    }

}

/*
--------------------------------------------------------------------------------------------------
| Fn                       | Purpose                                                             |
| ------------------------ | --------------------------------------------------------------------|
| * IntentFilter (outside) | Tells Android what events the app wants to listen to                |
| * onReceive (inside)     | Lets me decide what to do when i get one of those events (callback) |
 */
