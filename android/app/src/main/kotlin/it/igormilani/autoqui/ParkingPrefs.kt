package it.igormilani.autoqui

import android.content.Context

object ParkingPrefs {
    private const val PREFS_NAME = "FlutterSharedPreferences"
    private const val LAT_KEY = "flutter.parking_lat"
    private const val LNG_KEY = "flutter.parking_lng"
    private const val SAVED_AT_KEY = "flutter.parking_saved_at"
    private const val IGNORED_AT_KEY = "flutter.ignored_detection_at"
    private const val AUTOMATIC_DETECTION_ENABLED_KEY = "flutter.automatic_detection_enabled"
    private const val NOTIFICATIONS_ENABLED_KEY = "flutter.notifications_enabled"
    private const val CANDIDATE_LAT_KEY = "candidate_parking_lat"
    private const val CANDIDATE_LNG_KEY = "candidate_parking_lng"
    private const val CANDIDATE_AT_KEY = "candidate_parking_at"
    private const val LAST_IN_VEHICLE_AT_KEY = "last_in_vehicle_at"

    private const val MIN_VEHICLE_TIME_MILLIS = 2 * 60 * 1000L
    private const val MAX_VEHICLE_TIME_MILLIS = 6 * 60 * 60 * 1000L
    private const val CANDIDATE_COOLDOWN_MILLIS = 10 * 60 * 1000L

    fun saveCandidate(context: Context, latitude: Double, longitude: Double, timestamp: Long) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putFloat(CANDIDATE_LAT_KEY, latitude.toFloat())
            .putFloat(CANDIDATE_LNG_KEY, longitude.toFloat())
            .putLong(CANDIDATE_AT_KEY, timestamp)
            .apply()
    }

    fun markInVehicle(context: Context, timestamp: Long) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putLong(LAST_IN_VEHICLE_AT_KEY, timestamp)
            .apply()
    }

    fun saveCandidateAsParking(context: Context): Boolean {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        if (!prefs.contains(CANDIDATE_LAT_KEY) || !prefs.contains(CANDIDATE_LNG_KEY)) {
            return false
        }

        val latitude = prefs.getFloat(CANDIDATE_LAT_KEY, 0f).toDouble()
        val longitude = prefs.getFloat(CANDIDATE_LNG_KEY, 0f).toDouble()
        saveParking(context, latitude, longitude, System.currentTimeMillis())
        return true
    }

    fun saveParking(context: Context, latitude: Double, longitude: Double, timestamp: Long) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(LAT_KEY, latitude.toString())
            .putString(LNG_KEY, longitude.toString())
            .putLong(SAVED_AT_KEY, timestamp)
            .apply()
        AutoQuiParkingWidget.updateAll(context)
    }

    fun markIgnored(context: Context) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putLong(IGNORED_AT_KEY, System.currentTimeMillis())
            .apply()
    }

    fun recentlyIgnored(context: Context): Boolean {
        val ignoredAt = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getLong(IGNORED_AT_KEY, 0L)
        return System.currentTimeMillis() - ignoredAt < 15 * 60 * 1000
    }

    fun canCreateParkingCandidate(context: Context, timestamp: Long): Boolean {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val lastInVehicleAt = prefs.getLong(LAST_IN_VEHICLE_AT_KEY, 0L)
        if (lastInVehicleAt == 0L) {
            return false
        }

        val vehicleElapsed = timestamp - lastInVehicleAt
        if (vehicleElapsed < MIN_VEHICLE_TIME_MILLIS ||
            vehicleElapsed > MAX_VEHICLE_TIME_MILLIS
        ) {
            return false
        }

        val lastCandidateAt = prefs.getLong(CANDIDATE_AT_KEY, 0L)
        return timestamp - lastCandidateAt > CANDIDATE_COOLDOWN_MILLIS
    }

    fun automaticDetectionEnabled(context: Context): Boolean {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(AUTOMATIC_DETECTION_ENABLED_KEY, true)
    }

    fun notificationsEnabled(context: Context): Boolean {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(NOTIFICATIONS_ENABLED_KEY, true)
    }

    fun parking(context: Context): Pair<Double, Double>? {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        if (!prefs.contains(LAT_KEY) || !prefs.contains(LNG_KEY)) {
            return null
        }

        val latitude = readDouble(prefs.all[LAT_KEY]) ?: return null
        val longitude = readDouble(prefs.all[LNG_KEY]) ?: return null
        return Pair(latitude, longitude)
    }

    private fun readDouble(value: Any?): Double? {
        return when (value) {
            is Float -> value.toDouble()
            is Double -> value
            is String -> value.toDoubleOrNull()
            else -> null
        }
    }
}
