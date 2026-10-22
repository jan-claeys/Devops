package io.github.jan_claeys.devops

import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Hands Azure DevOps links to Dart (lib/services/links.dart): links opened
 * with the app and text shared to it. Widget taps go through home_widget
 * instead.
 */
class MainActivity : FlutterActivity() {
  private var channel: MethodChannel? = null
  private var initialLink: String? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    initialLink = linkFrom(intent)
    channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
      setMethodCallHandler { call, result ->
        when (call.method) {
          "initialLink" -> {
            result.success(initialLink)
            initialLink = null
          }
          "openInBrowser" -> result.success(openInBrowser(call.arguments as String))
          else -> result.notImplemented()
        }
      }
    }
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    linkFrom(intent)?.let { channel?.invokeMethod("link", it) }
  }

  /**
   * Opens [url] in the browser, never in this app: once the user lets it
   * open Azure DevOps links, a plain ACTION_VIEW would come back here.
   */
  private fun openInBrowser(url: String): Boolean {
    val view = Intent(Intent.ACTION_VIEW, Uri.parse(url)).addCategory(Intent.CATEGORY_BROWSABLE)
    // The default browser opens any other web link; without one, Android
    // resolves to its chooser ("android").
    val browser = packageManager
        .resolveActivity(
            Intent(Intent.ACTION_VIEW, Uri.parse("https://example.com/")),
            PackageManager.MATCH_DEFAULT_ONLY)
        ?.activityInfo?.packageName
    val intent = if (browser != null && browser != "android" && browser != packageName) {
      view.setPackage(browser)
    } else {
      Intent.createChooser(view, null)
          .putExtra(Intent.EXTRA_EXCLUDE_COMPONENTS, arrayOf(ComponentName(this, MainActivity::class.java)))
    }
    return try {
      startActivity(intent)
      true
    } catch (_: ActivityNotFoundException) {
      false
    }
  }

  private fun linkFrom(intent: Intent?): String? {
    // Reopened from the recent apps, the app gets the intent it once started with.
    if (intent == null || (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0) return null
    return when (intent.action) {
      Intent.ACTION_VIEW -> intent.dataString?.takeIf { it.startsWith("http") }
      Intent.ACTION_SEND -> intent.getStringExtra(Intent.EXTRA_TEXT)
      else -> null
    }
  }

  private companion object {
    const val CHANNEL = "devops/links"
  }
}
