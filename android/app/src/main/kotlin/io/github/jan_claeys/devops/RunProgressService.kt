package io.github.jan_claeys.devops

import android.app.Notification
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log

/**
 * Keeps the process running while pipeline runs are followed, so Dart can
 * keep polling them with the app in the background. Started from the app
 * while it is open; stops once no run is running anymore, or when the app
 * is swiped away and no one updates the notifications.
 */
class RunProgressService : Service() {

  override fun onBind(intent: Intent?): IBinder? = null

  override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    val (id, notification) = pending ?: run {
      stopSelf()
      return START_NOT_STICKY
    }
    instance = this
    show(id, notification)
    return START_NOT_STICKY
  }

  private fun show(id: Int, notification: Notification) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      startForeground(id, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
    } else {
      startForeground(id, notification)
    }
  }

  /** Android 15+ limits how long a data sync may run in the background. */
  override fun onTimeout(startId: Int, fgsType: Int) {
    finish(this)
  }

  override fun onTaskRemoved(rootIntent: Intent?) {
    RunNotifications.cancelRunning(this)
    finish(this)
  }

  override fun onDestroy() {
    if (instance === this) instance = null
    super.onDestroy()
  }

  companion object {
    private const val TAG = "RunProgressService"

    private var instance: RunProgressService? = null

    /** The notification to start in the foreground with. */
    private var pending: Pair<Int, Notification>? = null

    /** Runs in the foreground with [notification], shown with [id]. */
    fun start(context: Context, id: Int, notification: Notification) {
      pending = id to notification
      instance?.let {
        it.show(id, notification)
        return
      }
      try {
        context.startForegroundService(Intent(context, RunProgressService::class.java))
      } catch (e: IllegalStateException) {
        // Not allowed from the background: the notifications still show,
        // until Android freezes the app.
        Log.w(TAG, "Starting the foreground service failed", e)
      }
    }

    /** Stops, leaving the last notification for the caller to replace. */
    fun stop(context: Context) {
      pending = null
      instance?.let { finish(it) }
    }

    private fun finish(service: RunProgressService) {
      service.stopForeground(STOP_FOREGROUND_DETACH)
      service.stopSelf()
      if (instance === service) instance = null
    }
  }
}
