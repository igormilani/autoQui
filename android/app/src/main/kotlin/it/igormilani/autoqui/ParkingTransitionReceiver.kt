package it.igormilani.autoqui

import android.Manifest
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.ActivityTransition
import com.google.android.gms.location.ActivityTransitionResult
import com.google.android.gms.location.CancellationTokenSource
import com.google.android.gms.location.DetectedActivity
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority

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
                    context.getSystemService(NotificationManager::class.java)
                        .cancel(PARKING_NOTIFICATION_ID)
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

        val locationClient = LocationServices.getFusedLocationProviderClient(context)
        val cancellationTokenSource = CancellationTokenSource()
        locationClient
            .getCurrentLocation(
                Priority.PRIORITY_HIGH_ACCURACY,
                cancellationTokenSource.token
            )
            .addOnSuccessListener { location ->
                val timestamp = System.currentTimeMillis()
                val parkingLocation = location ?: return@addOnSuccessListener
                if (!isUsableParkingLocation(parkingLocation, timestamp)) {
                    return@addOnSuccessListener
                }

                ParkingPrefs.saveCandidate(
                    context,
                    parkingLocation.latitude,
                    parkingLocation.longitude,
                    timestamp
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

    private fun isUsableParkingLocation(location: Location, timestamp: Long): Boolean {
        val locationAge = timestamp - location.time
        if (locationAge < 0L || locationAge > MAX_LOCATION_AGE_MILLIS) {
            return false
        }

        return !location.hasAccuracy() || location.accuracy <= MAX_LOCATION_ACCURACY_METERS
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
        private const val MAX_LOCATION_AGE_MILLIS = 90 * 1000L
        private const val MAX_LOCATION_ACCURACY_METERS = 100f
    }
}
