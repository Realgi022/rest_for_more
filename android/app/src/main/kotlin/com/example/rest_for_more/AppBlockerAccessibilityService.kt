package com.example.rest_for_more

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class AppBlockerAccessibilityService : AccessibilityService() {
    private val prefsName = "app_blocker"
    private val blockedPackagesKey = "blocked_packages"

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val foregroundPackage = event.packageName?.toString() ?: return
        if (foregroundPackage == packageName) return

        val blockedPackages = getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .getStringSet(blockedPackagesKey, emptySet())
            .orEmpty()

        if (!blockedPackages.contains(foregroundPackage)) return

        val blockIntent = Intent(this, BlockedAppActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra(BlockedAppActivity.EXTRA_BLOCKED_PACKAGE, foregroundPackage)
        }
        startActivity(blockIntent)
    }

    override fun onInterrupt() = Unit
}
