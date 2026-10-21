package io.github.jan_claeys.devops

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundReceiver
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.DateFormat
import java.util.Date

/**
 * Home screen widget with my open work items. The data is written by
 * lib/services/home_widget_service.dart; this class only renders it.
 */
class TicketsWidgetProvider : HomeWidgetProvider() {

  override fun onReceive(context: Context, intent: Intent) {
    if (intent.action == ACTION_REFRESH) refresh(context) else super.onReceive(context, intent)
  }

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    render(context, appWidgetManager, appWidgetIds, widgetData)

    // Periodic system updates (every 30 min) fetch fresh data in the background.
    // Updates triggered by the app itself have fresh data and skip this. Without
    // any data the app has never run, so there is no background callback yet.
    val updatedAt = widgetData.getString("updatedAt", null)?.toLongOrNull()
    if (updatedAt != null && System.currentTimeMillis() - updatedAt > STALE_AFTER_MS) {
      try {
        refreshIntent(context).send()
      } catch (_: PendingIntent.CanceledException) {}
    }
  }

  private fun render(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    val refresh = refreshIntent(context)
    val openApp = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
    // Rows fill in their own devops://workitem/<id> uri, so this one must be mutable.
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

    // From Android 12 the rows travel inside the RemoteViews. Binding a
    // RemoteViewsService instead makes hosts like the lock screen blank the
    // list while they rebind on every update.
    val items = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      val tickets = TicketsWidgetService.loadTickets(context)
      RemoteViews.RemoteCollectionItems.Builder().apply {
        setHasStableIds(true)
        setViewTypeCount(1)
        for (t in tickets) addItem(t.id.toLong(), TicketsWidgetService.rowView(context, t))
      }.build()
    } else {
      null
    }

    for (id in appWidgetIds) {
      val views = RemoteViews(context.packageName, R.layout.tickets_widget).apply {
        setTextViewText(R.id.subtitle, subtitle)
        setTextViewText(R.id.error, error ?: "")
        setViewVisibility(R.id.error, if (error.isNullOrEmpty()) View.GONE else View.VISIBLE)
        setOnClickPendingIntent(R.id.refresh, refresh)
        setOnClickPendingIntent(R.id.header, openApp)
        if (items != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
          setRemoteAdapter(R.id.list, items)
        } else {
          val adapter = Intent(context, TicketsWidgetService::class.java).apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id)
            data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
          }
          @Suppress("DEPRECATION")
          setRemoteAdapter(R.id.list, adapter)
        }
        setEmptyView(R.id.list, R.id.empty)
        setPendingIntentTemplate(R.id.list, openItem)
      }
      appWidgetManager.updateAppWidget(id, views)
    }
    if (items == null) {
      @Suppress("DEPRECATION")
      appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.list)
    }
  }

  /**
   * Shows that a refresh is running and hands it to the Dart background
   * callback. home_widget's worker reports done before Dart has fetched
   * anything, after which Android may freeze the process mid-request. Keeping
   * this broadcast open until new data arrives keeps the process running.
   */
  private fun refresh(context: Context) {
    val manager = AppWidgetManager.getInstance(context)
    val ids = manager.getAppWidgetIds(ComponentName(context, TicketsWidgetProvider::class.java))
    val widgetData = HomeWidgetPlugin.getData(context)
    val before = widgetData.getString("updatedAt", null)

    val refreshing = RemoteViews(context.packageName, R.layout.tickets_widget).apply {
      setTextViewText(R.id.subtitle, context.getString(R.string.tickets_widget_refreshing))
    }
    for (id in ids) manager.partiallyUpdateAppWidget(id, refreshing)

    context.sendBroadcast(
        Intent(context, HomeWidgetBackgroundReceiver::class.java)
            .setAction(HOME_WIDGET_BACKGROUND_ACTION)
            .setData(Uri.parse(REFRESH_URI))
    )

    val pending = goAsync()
    val handler = Handler(Looper.getMainLooper())
    val deadline = SystemClock.uptimeMillis() + REFRESH_TIMEOUT_MS
    handler.post(object : Runnable {
      override fun run() {
        // The Dart side redraws the widget itself once it has stored new data.
        if (widgetData.getString("updatedAt", null) != before) return pending.finish()
        if (SystemClock.uptimeMillis() >= deadline) {
          render(context, manager, ids, widgetData)
          return pending.finish()
        }
        handler.postDelayed(this, POLL_INTERVAL_MS)
      }
    })
  }

  private fun refreshIntent(context: Context): PendingIntent = PendingIntent.getBroadcast(
      context,
      0,
      Intent(context, TicketsWidgetProvider::class.java).setAction(ACTION_REFRESH),
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
  )

  companion object {
    const val REFRESH_URI = "devops://refresh"
    private const val ACTION_REFRESH = "io.github.jan_claeys.devops.action.REFRESH_WIDGET"
    private const val HOME_WIDGET_BACKGROUND_ACTION = "es.antonborri.home_widget.action.BACKGROUND"
    private const val STALE_AFTER_MS = 25 * 60 * 1000L
    // Background broadcasts may run up to a minute before Android gives up on them.
    private const val REFRESH_TIMEOUT_MS = 45 * 1000L
    private const val POLL_INTERVAL_MS = 300L
  }
}
