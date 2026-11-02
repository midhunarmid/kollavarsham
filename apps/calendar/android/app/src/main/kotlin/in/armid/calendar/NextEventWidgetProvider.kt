package `in`.armid.calendar

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/** Next pirannal widget: the next personal event and its countdown. */
class NextEventWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val day = widgetDayKey()
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_next_event)
            views.setTextViewText(
                R.id.widget_title,
                widgetData.getString("next.$day.title", null)
                    ?: context.getString(R.string.widget_open_app))
            views.setTextViewText(
                R.id.widget_when, widgetData.getString("next.$day.when", null) ?: "")
            views.setOnClickPendingIntent(R.id.widget_root, openRoute(context, "/people"))
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
