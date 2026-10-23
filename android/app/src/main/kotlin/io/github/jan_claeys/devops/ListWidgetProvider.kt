package io.github.jan_claeys.devops

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import androidx.annotation.StringRes
import es.antonborri.home_widget.HomeWidgetBackgroundReceiver
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.DateFormat
import java.util.Date

/**
 * The home screen widgets, each a list of rows. Their data is written by
 * lib/services/home_widget_service.dart (HomeWidgetKind); these only render it.
 */
enum class ListWidget(
    val provider: Class<out ListWidgetProvider>,
    /** Name of the HomeWidgetKind in Dart. */
    private val dartName: String,
    /** Prefix of the stored keys; the tickets widget predates the others. */
    private val keyPrefix: String,
    @StringRes val label: Int,
    @StringRes val empty: Int,
    /** Subtitle with the count, such as "3 open". */
    @StringRes val count: Int,
) {
  TICKETS(TicketsWidgetProvider::class.java, "tickets", "",
      R.string.tickets_widget_label, R.string.tickets_widget_empty, R.string.tickets_widget_open_count),
  PULL_REQUESTS(PullRequestsWidgetProvider::class.java, "pullRequests", "pullRequests.",
      R.string.pull_requests_widget_label, R.string.pull_requests_widget_empty, R.string.pull_requests_widget_count),
  PIPELINES(PipelinesWidgetProvider::class.java, "pipelines", "pipelines.",
      R.string.pipelines_widget_label, R.string.pipelines_widget_empty, R.string.pipelines_widget_count);

  fun key(name: String) = keyPrefix + name

  /** Handed to the Dart background callback to refresh this widget. */
  val refreshUri: String get() = "devops://refresh/$dartName"

  fun ids(context: Context): IntArray =
      AppWidgetManager.getInstance(context).getAppWidgetIds(ComponentName(context, provider))
}

/** My open work items. */
class TicketsWidgetProvider : ListWidgetProvider(ListWidget.TICKETS)

/** Pull requests waiting for my review. */
class PullRequestsWidgetProvider : ListWidgetProvider(ListWidget.PULL_REQUESTS)

/** The latest run of each pipeline on each branch. */
class PipelinesWidgetProvider : ListWidgetProvider(ListWidget.PIPELINES)

abstract class ListWidgetProvider(private val widget: ListWidget) : HomeWidgetProvider() {

  override fun onReceive(context: Context, intent: Intent) {
    if (intent.action == ACTION_REFRESH) refresh(context) else super.onReceive(context, intent)
  }

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    render(context, widget, appWidgetManager, appWidgetIds, widgetData)

    // Periodic system updates (every 30 min) fetch fresh data in the background.
    // Updates triggered by the app itself have fresh data and skip this. Without
    // any data the app has never run, so there is no background callback yet.
    // A widget added after the app ran asks once for its first data.
    val updatedAt = widgetData.getString(widget.key("updatedAt"), null)?.toLongOrNull()
    val appHasRun = ListWidget.entries.any { widgetData.contains(it.key("updatedAt")) }
    val stale = if (updatedAt == null) appHasRun else System.currentTimeMillis() - updatedAt > STALE_AFTER_MS
    if (stale) {
      try {
        refreshIntent(context, widget).send()
      } catch (_: PendingIntent.CanceledException) {}
    }
  }

  /**
   * Shows that a refresh is running and hands it to the Dart background
   * callback. home_widget's worker reports done before Dart has fetched
   * anything, after which Android may freeze the process mid-request.
   * [ListWidgetRefreshWorker] keeps the process running until new data
   * arrives. Holding this broadcast open with goAsync() instead caused
   * background ANRs: Android delivers the background broadcast below only
   * after this one finishes, so the wait always ran into the deadline.
   */
  private fun refresh(context: Context) {
    val manager = AppWidgetManager.getInstance(context)
    val refreshing = RemoteViews(context.packageName, R.layout.list_widget).apply {
      setTextViewText(R.id.subtitle, context.getString(R.string.widget_refreshing))
    }
    for (id in widget.ids(context)) manager.partiallyUpdateAppWidget(id, refreshing)

    ListWidgetRefreshWorker.enqueue(
        context, widget, HomeWidgetPlugin.getData(context).getString(widget.key("updatedAt"), null))

    context.sendBroadcast(
        Intent(context, HomeWidgetBackgroundReceiver::class.java)
            .setAction(HOME_WIDGET_BACKGROUND_ACTION)
            .setData(Uri.parse(widget.refreshUri))
    )
  }

  companion object {
    private const val ACTION_REFRESH = "io.github.jan_claeys.devops.action.REFRESH_WIDGET"
    private const val HOME_WIDGET_BACKGROUND_ACTION = "es.antonborri.home_widget.action.BACKGROUND"
    private const val STALE_AFTER_MS = 25 * 60 * 1000L

    fun render(
        context: Context,
        widget: ListWidget,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
      val refresh = refreshIntent(context, widget)
      val openApp = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
      // Rows fill in their own devops:// uri, so this one must be mutable.
      var templateFlags = PendingIntent.FLAG_UPDATE_CURRENT
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) templateFlags = templateFlags or PendingIntent.FLAG_MUTABLE
      val openItem = PendingIntent.getActivity(
          context,
          1,
          Intent(context, MainActivity::class.java).setAction(HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION),
          templateFlags,
      )

      val project = widgetData.getString(widget.key("project"), null)
      val count = widgetData.getInt(widget.key("count"), 0)
      val error = widgetData.getString(widget.key("error"), null)
      val updatedAt = widgetData.getString(widget.key("updatedAt"), null)?.toLongOrNull()

      val subtitle = when {
        updatedAt == null -> context.getString(R.string.widget_not_loaded)
        project == null -> ""
        else -> "$project · ${context.getString(widget.count, count)} · ${DateFormat.getTimeInstance(DateFormat.SHORT).format(Date(updatedAt))}"
      }

      // From Android 12 the rows travel inside the RemoteViews. Binding a
      // RemoteViewsService instead makes hosts like the lock screen blank the
      // list while they rebind on every update.
      val items = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        val rows = ListWidgetService.loadRows(context, widget)
        RemoteViews.RemoteCollectionItems.Builder().apply {
          setHasStableIds(true)
          setViewTypeCount(1)
          for (row in rows) addItem(row.id, ListWidgetService.rowView(context, row))
        }.build()
      } else {
        null
      }

      for (id in appWidgetIds) {
        val views = RemoteViews(context.packageName, R.layout.list_widget).apply {
          setTextViewText(R.id.title, context.getString(widget.label))
          setTextViewText(R.id.subtitle, subtitle)
          setTextViewText(R.id.empty, context.getString(widget.empty))
          setTextViewText(R.id.error, error ?: "")
          setViewVisibility(R.id.error, if (error.isNullOrEmpty()) View.GONE else View.VISIBLE)
          setOnClickPendingIntent(R.id.refresh, refresh)
          setOnClickPendingIntent(R.id.header, openApp)
          if (items != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            setRemoteAdapter(R.id.list, items)
          } else {
            val adapter = Intent(context, ListWidgetService::class.java).apply {
              putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id)
              putExtra(ListWidgetService.EXTRA_WIDGET, widget.name)
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

    private fun refreshIntent(context: Context, widget: ListWidget): PendingIntent = PendingIntent.getBroadcast(
        context,
        0,
        Intent(context, widget.provider).setAction(ACTION_REFRESH),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
  }
}
