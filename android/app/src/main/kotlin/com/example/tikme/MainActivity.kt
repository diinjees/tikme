package com.example.tikme

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.StringCodec

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.tikme/deep_links"
    private var flutterEngine: FlutterEngine? = null
    private var messageChannel: BasicMessageChannel<String>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        println("🔗 Native: onCreate called")
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        println("🔗 Native: onNewIntent called - App was already running")
        handleIntent(intent)
        
        // Immediately notify Flutter about the new deep link
        notifyFlutterAboutDeepLink(intent)
    }

    private fun handleIntent(intent: Intent) {
        println("🔗 Native: handleIntent called")
        println("🔗 Native: Intent action: ${intent.action}")
        println("🔗 Native: Intent data: ${intent.dataString}")

        extractAndStoreLink(intent)
    }

    private fun extractAndStoreLink(intent: Intent): String? {
        val action = intent.action
        val data = intent.data
        
        // Handle ACTION_VIEW (direct deep link opening)
        if (Intent.ACTION_VIEW == action && data != null) {
            val link = data.toString()
            println("🔗 Native: ✅ ACTION_VIEW deep link captured: $link")
            return link
        } 
        // Handle ACTION_SEND (shared link)
        else if (Intent.ACTION_SEND == action) {
            val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
            if (sharedText != null && sharedText.contains("tikme://")) {
                println("🔗 Native: ✅ ACTION_SEND deep link captured: $sharedText")
                return sharedText
            }
        }
        println("🔗 Native: ❌ No deep link found in intent")
        return null
    }

    private fun notifyFlutterAboutDeepLink(intent: Intent) {
        val deepLink = extractAndStoreLink(intent)
        if (deepLink != null) {
            println("🔗 Native: Notifying Flutter about new deep link: $deepLink")
            // Send message to Flutter immediately
            messageChannel?.send(deepLink)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        this.flutterEngine = flutterEngine
        println("🔗 Native: configureFlutterEngine called")
        
        // Setup MethodChannel for initial links
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialLink" -> {
                    val link = extractAndStoreLink(intent)
                    println("🔗 Native: getInitialLink called, returning: $link")
                    result.success(link)
                }
                else -> result.notImplemented()
            }
        }

        // Setup BasicMessageChannel for real-time deep link notifications
        messageChannel = BasicMessageChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.tikme/deep_links_stream",
            StringCodec.INSTANCE
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        flutterEngine = null
        messageChannel = null
    }
}