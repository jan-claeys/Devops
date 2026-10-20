package com.aucxis.devops_tickets

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.DateFormat
import java.util.Date

/**
 * Home screen widget with my open work items. The data is written by
 * lib/services/home_widget_service.dart; this class only renders it.
 */
class TicketsWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    val refresh = HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse(REFRESH_URI))
    val openApp = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
    // Rows fill in their own devopstickets://workitem/<id> uri, so this one must be mutable.
    var templateFlags = PendingIntent.FLAG_UPDATE_CURRENT
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) templateFlags = templateFlags or PendingIntent.FLAG_MUTABLE
    val openItem = PendingIntent.getActivity(
        context,
        1,
        Intent(context, MainActivity::class.java).setAction(HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION),
        templateFlags,
    )

    val project = widgetData.getString("project", null)
    val count = widgetData.getInt("count", 0)
    val error = widgetData.getString("error", null)
    val updatedAt = widgetData.getString("updatedAt", null)?.toLongOrNull()

    val subtitle = when {
      updatedAt == null -> context.getString(R.string.tickets_widget_not_loaded)
      project == null -> ""
      else -> "$project · ${context.getString(R.string.tickets_widget_open_count, count)} · ${DateFormat.getTimeInstance(DateFormat.SHORT).format(Date(updatedAt))}"
    }

    for (id in appWidgetIds) {
      val adapter = Intent(context, TicketsWidgetService::class.java).apply {
        putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id)
        data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
      }
      val views = RemoteViews(context.packageName, R.layout.tickets_widget).apply {
        setTextViewText(R.id.subtitle, subtitle)
        setTextViewText(R.id.error, error ?: "")
        setViewVisibility(R.id.error, if (error.isNullOrEmpty()) View.GONE else View.VISIBLE)
        setOnClickPendingIntent(R.id.refresh, refresh)
        setOnClickPendingIntent(R.id.header, openApp)
        @Suppress("DEPRECATION")
        setRemoteAdapter(R.id.list, adapter)
        setEmptyView(R.id.list, R.id.empty)
        setPendingIntentTemplate(R.id.list, openItem)
      }
      appWidgetManager.updateAppWidget(id, views)
    }
    @Suppress("DEPRECATION")
    appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.list)

    // Periodic system updates (every 30 min) fetch fresh data in the background.
    // Updates triggered by the app itself have fresh data and skip this. Without
    // any data the app has never run, so there is no background callback yet.
    if (updatedAt != null && System.currentTimeMillis() - updatedAt > STALE_AFTER_MS) {
      try {
        refresh.send()
      } catch (_: PendingIntent.CanceledException) {}
    }
  }

  companion object {
    const val REFRESH_URI = "devopstickets://refresh"
    private const val STALE_AFTER_MS = 25 * 60 * 1000L
  }
}
