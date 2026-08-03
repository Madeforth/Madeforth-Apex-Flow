package com.apexflow.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class EmergencyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.emergency_widget).apply {
                val bloodType = widgetData.getString("blood_type", "—")
                val emergencyName = widgetData.getString("emergency_name", "—")
                val emergencyPhone = widgetData.getString("emergency_phone", "—")

                setTextViewText(R.id.blood_type, bloodType)
                setTextViewText(R.id.emergency_name, emergencyName)
                setTextViewText(R.id.emergency_phone, emergencyPhone)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
