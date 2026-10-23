package io.github.jan_claeys.devops

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

/**
 * Supplies the rows of the list in a [ListWidgetProvider] before Android 12.
 * Newer versions get the rows embedded via RemoteCollectionItems.
 */
class ListWidgetService : RemoteViewsService() {
  override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
    val widget = intent.getStringExtra(EXTRA_WIDGET)
        ?.let { name -> ListWidget.entries.firstOrNull { it.name == name } }
        ?: ListWidget.TICKETS
    return Factory(applicationContext, widget)
  }

  /** A row as stored by home_widget_service.dart; [uri] is opened on a tap. */
  data class Row(val id: Long, val title: String, val meta: String, val color: Int, val uri: String)

  private class Factory(private val context: Context, private val widget: ListWidget) : RemoteViewsFactory {
    private var rows = emptyList<Row>()

    override fun onCreate() {}

    override fun onDataSetChanged() {
      rows = loadRows(context, widget)
    }

    override fun onDestroy() {}

    override fun getCount() = rows.size

    override fun getViewAt(position: Int) = rowView(context, rows[position])

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount() = 1

    override fun getItemId(position: Int) = rows[position].id

    override fun hasStableIds() = true
  }

  companion object {
    const val EXTRA_WIDGET = "io.github.jan_claeys.devops.extra.WIDGET"

    private val DEFAULT_COLOR = Color.parseColor("#607D8B")

    fun loadRows(context: Context, widget: ListWidget): List<Row> {
      val json = HomeWidgetPlugin.getData(context).getString(widget.key("items"), null) ?: "[]"
      return try {
        val array = JSONArray(json)
        (0 until array.length()).map { i ->
          val o = array.getJSONObject(i)
          val id = o.getLong("id")
          Row(
              id,
              o.optString("title"),
              // Tickets stored by an older version until the next refresh.
              o.optString("meta").ifEmpty {
                listOf("#$id", o.optString("type"), o.optString("state")).filter { it.isNotEmpty() }.joinToString(" · ")
              },
              try {
                Color.parseColor(o.optString("color"))
              } catch (_: IllegalArgumentException) {
                DEFAULT_COLOR
              },
              o.optString("uri").ifEmpty { "devops://workitem/$id" },
          )
        }
      } catch (_: Exception) {
        emptyList()
      }
    }

    fun rowView(context: Context, row: Row) =
        RemoteViews(context.packageName, R.layout.list_widget_item).apply {
          setTextViewText(R.id.meta, row.meta)
          setTextViewText(R.id.title, row.title)
          setInt(R.id.bar, "setColorFilter", row.color)
          setOnClickFillInIntent(R.id.item, Intent().setData(Uri.parse(row.uri)))
        }
  }
}
