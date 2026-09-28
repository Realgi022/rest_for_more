package com.example.rest_for_more

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "rest_for_more/app_blocker"
    private val prefsName = "app_blocker"
    private val blockedPackagesKey = "blocked_packages"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> result.success(getInstalledApps())
                "getBlockedPackages" -> result.success(getBlockedPackages().toList())
                "setBlockedPackages" -> {
                    val packages = call.argument<List<String>>("packages").orEmpty()
                    setBlockedPackages(packages.toSet())
                    result.success(null)
                }
                "openAccessibilitySettings" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(null)
                }
                "isAccessibilityServiceEnabled" -> result.success(isAccessibilityServiceEnabled())
                else -> result.notImplemented()
            }
        }
    }

    private fun getInstalledApps(): List<Map<String, String>> {
        val launchIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val apps = packageManager.queryIntentActivities(launchIntent, 0)

        return apps
            .mapNotNull { resolveInfo ->
                val packageName = resolveInfo.activityInfo?.packageName ?: return@mapNotNull null
                if (packageName == this.packageName) return@mapNotNull null

                mapOf(
                    "packageName" to packageName,
                    "label" to resolveInfo.loadLabel(packageManager).toString(),
                )
            }
            .distinctBy { it["packageName"] }
            .sortedBy { it["label"]?.lowercase() }
    }

    private fun getBlockedPackages(): Set<String> {
        return getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .getStringSet(blockedPackagesKey, emptySet())
            .orEmpty()
    }

    private fun setBlockedPackages(packages: Set<String>) {
        getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .edit()
            .putStringSet(blockedPackagesKey, packages)
            .apply()
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedService = ComponentName(this, AppBlockerAccessibilityService::class.java).flattenToString()
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false

        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(enabledServices)

        return splitter.any { it.equals(expectedService, ignoreCase = true) }
    }
}
