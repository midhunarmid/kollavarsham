package `in`.armid.calendar

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** The device's date as the key the app writes widget text under. */
internal fun widgetDayKey(): String = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())

/** Opens [route] in the app (Flutter deep linking reads the path). */
internal fun openRoute(context: Context, route: String) =
    HomeWidgetLaunchIntent.getActivity(
        context, MainActivity::class.java, Uri.parse("kollavarsham://app$route"))

/**
 * Today widget: the Malayalam date, weekday, star and tithi, and the day's
 * festivals. The app writes a week of text ahead; Android redraws the widget
 * hourly, so it moves to the next day's text soon after midnight.
 */
class TodayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val day = widgetDayKey()
        fun text(field: String) = widgetData.getString("today.$day.$field", null)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_today)
            views.setTextViewText(
                R.id.widget_date, text("date") ?: context.getString(R.string.widget_open_app))
            views.setTextViewText(
                R.id.widget_weekday,
                listOfNotNull(text("weekday"), text("gregorian")).joinToString(" · "))
            views.setTextViewText(R.id.widget_star, text("star") ?: "")
            val festival = text("festival").orEmpty()
            views.setTextViewText(R.id.widget_festival, festival)
            views.setViewVisibility(
                R.id.widget_festival, if (festival.isEmpty()) View.GONE else View.VISIBLE)
            views.setOnClickPendingIntent(R.id.widget_root, openRoute(context, "/today"))
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
