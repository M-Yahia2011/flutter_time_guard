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
    private lateinit var receiver: BroadcastReceiver
    private var isAppInForeground = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "time_change_listener")
        // Observe lifecycle
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)

        context = binding.applicationContext

        // Create BroadcastReceiver inside plugin
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val action = intent?.action ?: return
                if (action == Intent.ACTION_TIME_CHANGED ||
                    action == Intent.ACTION_TIMEZONE_CHANGED ||
                    action == Intent.ACTION_DATE_CHANGED) {
                    Log.d("FlutterTimeGuardPlugin", "Time change detected: $action")

                // Return if app is in foreground to prevent automatic changes from triggering the callback
                    if (isAppInForeground) return

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

    // Lifecycle callbacks
    override fun onStart(owner: LifecycleOwner) {
        isAppInForeground = true
    }

    override fun onStop(owner: LifecycleOwner) {
        isAppInForeground = false
    }
}

/*
--------------------------------------------------------------------------------------------------
| Fn                       | Purpose                                                             |
| ------------------------ | --------------------------------------------------------------------|
| * IntentFilter (outside) | Tells Android what events the app wants to listen to                |
| * onReceive (inside)     | Lets me decide what to do when i get one of those events (callback) |
 */