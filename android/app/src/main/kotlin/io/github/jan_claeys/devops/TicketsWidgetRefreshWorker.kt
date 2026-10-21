package io.github.jan_claeys.devops

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.os.SystemClock
import androidx.work.CoroutineWorker
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import es.antonborri.home_widget.HomeWidgetPlugin
import kotlinx.coroutines.delay

/**
 * Keeps the process running while the Dart background callback refreshes
 * [TicketsWidgetProvider], so Android does not freeze it mid-request. The
 * Dart side redraws the widget itself once it has stored new data; if none
 * arrives in time, this redraws it to clear the "refreshing" state.
 */
class TicketsWidgetRefreshWorker(context: Context, params: WorkerParameters) :
    CoroutineWorker(context, params) {

  override suspend fun doWork(): Result {
    val widgetData = HomeWidgetPlugin.getData(applicationContext)
    val before = inputData.getString(BEFORE_KEY)
    val deadline = SystemClock.uptimeMillis() + REFRESH_TIMEOUT_MS
    while (SystemClock.uptimeMillis() < deadline) {
      if (widgetData.getString("updatedAt", null) != before) return Result.success()
      delay(POLL_INTERVAL_MS)
    }
    val manager = AppWidgetManager.getInstance(applicationContext)
    val ids = manager.getAppWidgetIds(ComponentName(applicationContext, TicketsWidgetProvider::class.java))
    TicketsWidgetProvider.render(applicationContext, manager, ids, widgetData)
    return Result.success()
  }

  companion object {
    private const val UNIQUE_WORK_NAME = "tickets_widget_refresh"
    private const val BEFORE_KEY = "before"
    private const val REFRESH_TIMEOUT_MS = 60 * 1000L
    private const val POLL_INTERVAL_MS = 300L

    /** Waits for widget data newer than [before], the current updatedAt. */
    fun enqueue(context: Context, before: String?) {
      val request = OneTimeWorkRequestBuilder<TicketsWidgetRefreshWorker>()
          .setInputData(Data.Builder().putString(BEFORE_KEY, before).build())
          .build()
      // An earlier refresh that is still waiting finishes with the same new data.
      WorkManager.getInstance(context).enqueueUniqueWork(UNIQUE_WORK_NAME, ExistingWorkPolicy.KEEP, request)
    }
  }
}
