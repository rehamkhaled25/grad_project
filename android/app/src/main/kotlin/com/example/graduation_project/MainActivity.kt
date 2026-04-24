
package com.example.graduation_project

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode

class MainActivity: FlutterActivity() {
    // This forces the app to use a different rendering method
    override fun getBackgroundMode(): BackgroundMode {
        return BackgroundMode.transparent
    }
}