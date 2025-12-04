package com.example.leet_code_widget // CHANGE THIS TO YOUR PACKAGE NAME

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

class LeetCodeWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // Get the absolute path sent by Flutter
            val imagePath = widgetData.getString("filename_heatmap", null)
            
            println("LeetCodeWidget-DEBUG: Path from SharedPrefs is: $imagePath")

            val imageFile = if (imagePath != null) File(imagePath) else null
            val fileExists = imageFile?.exists() == true

            if (fileExists) {
                val myBitmap = BitmapFactory.decodeFile(imageFile!!.absolutePath)
                views.setImageViewBitmap(R.id.widget_image, myBitmap)
                views.setViewVisibility(R.id.widget_image, View.VISIBLE)
                println("LeetCodeWidget-DEBUG: ✅ Successfully loaded image!")
            } else {
                println("LeetCodeWidget-DEBUG: ❌ File does not exist or path is null.")
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}