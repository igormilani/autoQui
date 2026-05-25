package it.igormilani.autoqui

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ParkingNotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_SAVE -> ParkingPrefs.saveCandidateAsParking(context)
            ACTION_IGNORE -> ParkingPrefs.markIgnored(context)
        }

        context.getSystemService(NotificationManager::class.java)
            .cancel(ParkingTransitionReceiver.PARKING_NOTIFICATION_ID)
    }

    companion object {
        const val ACTION_SAVE = "it.igormilani.autoqui.action.SAVE_PARKING"
        const val ACTION_IGNORE = "it.igormilani.autoqui.action.IGNORE_PARKING"
    }
}
