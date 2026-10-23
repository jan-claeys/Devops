package io.github.jan_claeys.devops

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Build
import es.antonborri.home_widget.HomeWidgetLaunchIntent

/**
 * Notifications that follow the progress of pipeline runs. Dart
 * (lib/services/run_notifications.dart) polls Azure DevOps while the app is
 * open and hands over every run it follows on each poll; this only shows them.
 *
 * On Android 16 a running run is a Live Update: promoted to the top of the
 * shade and shown as a chip in the status bar.
 */
object RunNotifications {
  private const val CHANNEL_ID = "pipeline_runs"

  /** Removes a running run that Dart stopped updating, e.g. when the app was killed. */
  private const val RUNNING_TIMEOUT_MS = 5 * 60 * 1000L

  /** Notification.EXTRA_REQUEST_PROMOTED_ONGOING, public only from API 36.1. */
  private const val EXTRA_REQUEST_PROMOTED_ONGOING = "android.requestPromotedOngoing"

  /**
   * Shows [running] as ongoing notifications and [finished], the runs that
   * were running before, as results; removes the other running ones. Each
   * run is a map with key, title, text, uri, color, and progress (0-100, -1
   * when unknown) and startTime (ms) for a running one or failed for a
   * finished one.
   */
  fun update(context: Context, running: List<Map<String, Any?>>, finished: List<Map<String, Any?>>, channelName: String) {
    val manager = context.getSystemService(NotificationManager::class.java)
    manager.createNotificationChannel(
        NotificationChannel(CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_DEFAULT).apply {
          setShowBadge(false)
        })
    // Without notifications, following runs in the background is no use.
    if (!manager.areNotificationsEnabled()) {
      RunProgressService.stop(context)
      return
    }
    val ongoing = running.map { id(it) to buildRunning(context, it) }
    val results = finished.map { id(it) to buildFinished(context, it) }
    // The foreground service first lets go of a run that stopped running,
    // as its notification can't be replaced or removed before.
    if (ongoing.isEmpty()) {
      RunProgressService.stop(context)
    } else {
      RunProgressService.start(context, ongoing.first().first, ongoing.first().second)
    }
    val keep = (ongoing + results).map { it.first }.toSet()
    // Results stay until the user dismisses them.
    for (active in manager.activeNotifications) {
      if (isRunning(active.notification) && active.id !in keep) manager.cancel(active.id)
    }
    for ((id, notification) in ongoing + results) manager.notify(id, notification)
  }

  /** Removes the notifications of runs that are still running: no one updates them anymore. */
  fun cancelRunning(context: Context) {
    val manager = context.getSystemService(NotificationManager::class.java)
    for (active in manager.activeNotifications) {
      if (isRunning(active.notification)) manager.cancel(active.id)
    }
  }

  private fun isRunning(notification: Notification) =
      notification.channelId == CHANNEL_ID && (notification.flags and Notification.FLAG_ONGOING_EVENT) != 0

  private fun id(run: Map<String, Any?>) = (run["key"] as String).hashCode()

  private fun builder(context: Context, run: Map<String, Any?>) =
      Notification.Builder(context, CHANNEL_ID)
          .setContentTitle(run["title"] as String)
          .setContentText(run["text"] as String)
          .setColor(Color.parseColor(run["color"] as String))
          .setContentIntent(open(context, run))
          .setOnlyAlertOnce(true)

  private fun buildRunning(context: Context, run: Map<String, Any?>): Notification {
    val progress = (run["progress"] as Number).toInt()
    val startTime = (run["startTime"] as Number?)?.toLong()
    val builder = builder(context, run)
        .setSmallIcon(R.drawable.ic_stat_run)
        .setOngoing(true)
        .setCategory(Notification.CATEGORY_PROGRESS)
        .setTimeoutAfter(RUNNING_TIMEOUT_MS)
    // The time it has been running, which the status bar chip shows when
    // the progress is unknown.
    if (startTime != null) builder.setWhen(startTime).setShowWhen(true).setUsesChronometer(true)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.BAKLAVA) {
      val color = Color.parseColor(run["color"] as String)
      builder.setStyle(
          Notification.ProgressStyle()
              .setProgressSegments(listOf(Notification.ProgressStyle.Segment(100).setColor(color)))
              .setProgress(progress.coerceAtLeast(0))
              .setProgressIndeterminate(progress < 0))
      if (progress >= 0) builder.setShortCriticalText("$progress%")
      builder.extras.putBoolean(EXTRA_REQUEST_PROMOTED_ONGOING, true)
    } else {
      builder.setProgress(100, progress.coerceAtLeast(0), progress < 0)
    }
    return builder.build()
  }

  private fun buildFinished(context: Context, run: Map<String, Any?>) =
      builder(context, run)
          .setSmallIcon(if (run["failed"] == true) R.drawable.ic_stat_run_failed else R.drawable.ic_stat_run_done)
          .setAutoCancel(true)
          .build()

  /** Opens the run, as a tap on a home screen widget row does. */
  private fun open(context: Context, run: Map<String, Any?>): PendingIntent = PendingIntent.getActivity(
      context,
      id(run),
      Intent(context, MainActivity::class.java)
          .setAction(HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION)
          .setData(Uri.parse(run["uri"] as String)),
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
}
