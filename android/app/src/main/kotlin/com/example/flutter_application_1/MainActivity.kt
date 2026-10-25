package id.nama_kamu.lelap

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "lelap/screen"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasPermission" -> result.success(hasUsagePermission())
                    "openSettings" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    "getScreenEvents" -> {
                        val start = call.argument<Long>("start")!!
                        val end = call.argument<Long>("end")!!
                        result.success(getScreenEvents(start, end))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasUsagePermission(): Boolean {
        val ops = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = ops.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(), packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    // mengembalikan list [waktuMs, tipe]; tipe 1 = layar menyala, 0 = layar mati
    private fun getScreenEvents(start: Long, end: Long): List<List<Long>> {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usm.queryEvents(start, end)
        val e = UsageEvents.Event()
        val out = mutableListOf<List<Long>>()
        while (events.hasNextEvent()) {
            events.getNextEvent(e)
            if (e.eventType == UsageEvents.Event.SCREEN_INTERACTIVE)
                out.add(listOf(e.timeStamp, 1L))
            if (e.eventType == UsageEvents.Event.SCREEN_NON_INTERACTIVE)
                out.add(listOf(e.timeStamp, 0L))
        }
        return out
    }
}