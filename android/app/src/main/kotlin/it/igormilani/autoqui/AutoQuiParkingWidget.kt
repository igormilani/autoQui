package it.igormilani.autoqui

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews

class AutoQuiParkingWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { id ->
            updateWidget(context, appWidgetManager, id)
        }
    }

    companion object {
        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, AutoQuiParkingWidget::class.java)
            manager.getAppWidgetIds(component).forEach { id ->
                updateWidget(context, manager, id)
            }
        }

        private fun updateWidget(
            context: Context,
            manager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.autoqui_parking_widget)
            val parking = ParkingPrefs.parking(context)

            if (parking == null) {
                views.setTextViewText(R.id.widget_status, "Nessuna auto salvata")
                views.setOnClickPendingIntent(R.id.widget_route_button, openAppIntent(context))
            } else {
                val (lat, lng) = parking
                views.setTextViewText(
                    R.id.widget_status,
                    "Auto salvata: %.5f, %.5f".format(lat, lng)
                )
                views.setOnClickPendingIntent(
                    R.id.widget_route_button,
                    routeIntent(context, lat, lng)
                )
            }

            views.setOnClickPendingIntent(R.id.widget_open_button, openAppIntent(context))
            manager.updateAppWidget(appWidgetId, views)
        }

        private fun openAppIntent(context: Context): PendingIntent {
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            return PendingIntent.getActivity(
                context,
                40,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        private fun routeIntent(context: Context, lat: Double, lng: Double): PendingIntent {
            val intent = Intent(
                Intent.ACTION_VIEW,
                Uri.parse("google.navigation:q=$lat,$lng&mode=w")
            )
            return PendingIntent.getActivity(
                context,
                41,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }
    }
}
