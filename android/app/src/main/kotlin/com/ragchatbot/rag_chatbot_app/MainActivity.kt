package com.ragchatbot.rag_chatbot_app

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ragchatbot.rag_chatbot_app/share"
    private var sharedText: String? = null
    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        android.util.Log.d("MainActivity", "handleIntent called with action: ${intent?.action}")
        if (intent?.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
            android.util.Log.d("MainActivity", "📱 Received shared text: $sharedText")
            
            // If channel is already set up, send immediately
            methodChannel?.invokeMethod("sharedText", sharedText)
        } else {
            android.util.Log.d("MainActivity", "ℹ️ Intent action: ${intent?.action}, type: ${intent?.type}")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getSharedText" -> {
                    android.util.Log.d("MainActivity", "Flutter requested shared text: $sharedText")
                    result.success(sharedText)
                    sharedText = null // Clear after reading
                }
                else -> result.notImplemented()
            }
        }
        
        // If we already have shared text, send it immediately
        if (sharedText != null) {
            android.util.Log.d("MainActivity", "Sending shared text to Flutter: $sharedText")
            methodChannel?.invokeMethod("sharedText", sharedText)
        }
    }
}
