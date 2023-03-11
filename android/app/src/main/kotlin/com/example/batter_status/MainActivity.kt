package com.example.batter_status
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "plugin/battery"
    private val EVENT_CHANNEL = "plugin/batteryEvent"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()
                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }

        val batteryLevelStreamHandler = BatteryLevelStreamHandler()
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(batteryLevelStreamHandler)
    }

    private fun getBatteryLevel(): Int {
        var batteryLevel = -1
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(BATTERY_SERVICE) as? BatteryManager
            batteryLevel = batteryManager?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY) ?: -1
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
            val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
            batteryLevel = if (level != -1 && scale != -1) {
                (level * 100) / scale
            } else {
                -1
            }
        }
        return batteryLevel
    }

    inner class BatteryLevelStreamHandler : EventChannel.StreamHandler {
        private var batteryLevelReceiver: BatteryLevelReceiver? = null

        override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
            batteryLevelReceiver = BatteryLevelReceiver(eventSink)
            val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
            registerReceiver(batteryLevelReceiver, intentFilter)
        }

        override fun onCancel(arguments: Any?) {
            unregisterReceiver(batteryLevelReceiver)
            batteryLevelReceiver = null
        }
    }

    inner class BatteryLevelReceiver(private val eventSink: EventChannel.EventSink?) : android.content.BroadcastReceiver() {
        override fun onReceive(context: android.content.Context?, intent: android.content.Intent?) {
            val batteryLevel = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
            val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
            val level = if (batteryLevel != -1 && scale != -1) {
                (batteryLevel * 100) / scale
            } else {
                -1
            }
            eventSink?.success(level)
        }
    }
}
