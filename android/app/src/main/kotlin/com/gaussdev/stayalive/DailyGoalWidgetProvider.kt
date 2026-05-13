package com.example.stay_alive

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider

class DailyGoalWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            val views = RemoteViews(context.packageName, R.layout.daily_goal_widget)
            val data = HomeWidgetPlugin.getData(context)
            val completed = data.getInt("daily_goal_completed", 0)
            val target = data.getInt("daily_goal_target", 0)
            val percentage = data.getInt("daily_goal_percentage", 0)
            val date = data.getString("daily_goal_date", "Today") ?: "Today"
            val streak = data.getInt("daily_goal_streak", 0)
            val level = data.getInt("daily_goal_level", 1)

            views.setTextViewText(R.id.daily_goal_title, "Daily Goal")
            views.setTextViewText(R.id.daily_goal_date, date)
            views.setTextViewText(R.id.daily_goal_counts, "$completed / $target servings")
            views.setTextViewText(R.id.daily_goal_percent, "$percentage%")
            views.setTextViewText(R.id.daily_goal_meta, "🔥 $streak day streak • Lv $level")
            views.setProgressBar(R.id.daily_goal_progress, 100, percentage, false)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
