package io.github.jan_claeys.devops

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

/** Supplies the rows of the ticket list in [TicketsWidgetProvider]. */
class TicketsWidgetService : RemoteViewsService() {
  override fun onGetViewFactory(intent: Intent): RemoteViewsFactory = Factory(applicationContext)

  private data class Ticket(val id: Int, val title: String, val state: String, val type: String)

  private class Factory(private val context: Context) : RemoteViewsFactory {
    private var tickets = emptyList<Ticket>()

    override fun onCreate() {}

    override fun onDataSetChanged() {
      val json = HomeWidgetPlugin.getData(context).getString("items", null) ?: "[]"
      tickets = try {
        val array = JSONArray(json)
        (0 until array.length()).map { i ->
          val o = array.getJSONObject(i)
          Ticket(o.getInt("id"), o.optString("title"), o.optString("state"), o.optString("type"))
        }
      } catch (_: Exception) {
        emptyList()
      }
    }

    override fun onDestroy() {}

    override fun getCount() = tickets.size

    override fun getViewAt(position: Int): RemoteViews {
      val t = tickets[position]
      return RemoteViews(context.packageName, R.layout.tickets_widget_item).apply {
        setTextViewText(R.id.meta, listOf("#${t.id}", t.type, t.state).filter { it.isNotEmpty() }.joinToString(" · "))
        setTextViewText(R.id.title, t.title)
        setInt(R.id.type_bar, "setColorFilter", typeColor(t.type))
        setOnClickFillInIntent(R.id.item, Intent().setData(Uri.parse("devops://workitem/${t.id}")))
      }
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount() = 1

    override fun getItemId(position: Int) = tickets[position].id.toLong()

    override fun hasStableIds() = true

    /** Same colours as WorkItemTypeStyle in lib/widgets/work_item_visuals.dart. */
    private fun typeColor(type: String): Int = Color.parseColor(
        when (type.lowercase()) {
          "bug" -> "#CC293D"
          "task" -> "#F2CB1D"
          "user story", "product backlog item", "requirement" -> "#009CCC"
          "feature" -> "#773B93"
          "epic" -> "#FF7B00"
          "issue", "impediment" -> "#B4009E"
          "test case" -> "#004B50"
          else -> "#607D8B"
        }
    )
  }
}
