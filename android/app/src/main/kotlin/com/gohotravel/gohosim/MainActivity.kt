package com.gohotravel.gohosim

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.euicc.EuiccManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.gohotravel.gohosim/esim"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "checkEsimSupport") {
                    result.success(checkEsimSupport())
                } else {
                    result.notImplemented()
                }
            }
    }

    /**
     * Returns a map with two keys:
     *   "hasHardware" - true if device has FEATURE_TELEPHONY_EUICC (hardware present)
     *   "isEnabled"   - true if EuiccManager.isEnabled() (feature currently active)
     *   "apiSupported" - true if Android 9+ (API 28+)
     */
    private fun checkEsimSupport(): Map<String, Boolean> {
        // API 28 minimum for EuiccManager
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            return mapOf("apiSupported" to false, "hasHardware" to false, "isEnabled" to false)
        }

        val hasHardware = packageManager.hasSystemFeature(PackageManager.FEATURE_TELEPHONY_EUICC)

        val isEnabled = try {
            val euiccManager = getSystemService(Context.EUICC_SERVICE) as? EuiccManager
            euiccManager?.isEnabled == true
        } catch (e: Exception) {
            false
        }

        return mapOf(
            "apiSupported" to true,
            "hasHardware" to hasHardware,
            "isEnabled" to isEnabled,
        )
    }
}
