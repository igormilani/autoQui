package it.igormilani.autoqui

import android.Manifest
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.ActivityTransition
import com.google.android.gms.location.ActivityTransitionResult
import com.google.android.gms.location.DetectedActivity
import com.google.android.gms.location.LocationServices

class ParkingTransitionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val result = ActivityTransitionResult.extractResult(intent) ?: return

        result.transitionEvents.forEach { event ->
            if (event.transitionType != ActivityTransition.ACTIVITY_TRANSITION_ENTER) {
                return@forEach
            }

            when (event.activityType) {
                DetectedActivity.IN_VEHICLE -> {
                    ParkingPrefs.markInVehicle(context, System.currentTimeMillis())
                }
                DetectedActivity.ON_FOOT,
                DetectedActivity.WALKING -> {
                    handlePossibleParking(context)
                }
                else -> Unit
            }
        }
    }

    private fun handlePossibleParking(context: Context) {
        if (!ParkingPrefs.automaticDetectionEnabled(context) ||
            ParkingPrefs.recentlyIgnored(context) ||
            !ParkingPrefs.canCreateParkingCandidate(context, System.currentTimeMillis()) ||
            !hasLocationPermission(context)
        ) {
            return
        }

        LocationServices.getFusedLocationProviderClient(context)
            .lastLocation
            .addOnSuccessListener { location ->
                if (location == null) {
                    return@addOnSuccessListener
                }

                ParkingPrefs.saveCandidate(
                    context,
                    location.latitude,
                    location.longitude,
                    System.currentTimeMillis()
                )
                showParkingNotification(context)
            }
    }

    private fun showParkingNotification(context: Context) {
        if (!ParkingPrefs.notificationsEnabled(context)) {
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        val saveIntent = Intent(context, ParkingNotificationActionReceiver::class.java)
            .setAction(ParkingNotificationActionReceiver.ACTION_SAVE)
        val ignoreIntent = Intent(context, ParkingNotificationActionReceiver::class.java)
            .setAction(ParkingNotificationActionReceiver.ACTION_IGNORE)

        val savePendingIntent = PendingIntent.getBroadcast(
            context,
            20,
            saveIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val ignorePendingIntent = PendingIntent.getBroadcast(
            context,
            21,
            ignoreIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(
            context,
            ParkingDetectionService.CHANNEL_ID
        )
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(context.getString(R.string.parking_detected_title))
            .setContentText(context.getString(R.string.parking_detected_text))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .addAction(
                R.mipmap.ic_launcher,
                context.getString(R.string.parking_action_save),
                savePendingIntent
            )
            .addAction(
                R.mipmap.ic_launcher,
                context.getString(R.string.parking_action_ignore),
                ignorePendingIntent
            )
            .build()

        NotificationManagerCompat.from(context).notify(PARKING_NOTIFICATION_ID, notification)
    }

    private fun hasLocationPermission(context: Context): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
    }

    companion object {
        const val PARKING_NOTIFICATION_ID = 3002
    }
}
