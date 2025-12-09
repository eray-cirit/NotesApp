package com.example.borc_defteri

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.app.ActivityManager
import android.graphics.BitmapFactory
import androidx.core.content.ContextCompat

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Recent apps ekranında özel görünüm
        val taskDescription = ActivityManager.TaskDescription.Builder()
            .setLabel("Tolga")
            .setPrimaryColor(ContextCompat.getColor(this, android.R.color.white))
            .build()
        
        setTaskDescription(taskDescription)
    }
}
