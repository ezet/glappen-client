package app.garderobel.garderobelappen

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    companion object {
        const val PaymentEvents = "poc.3ds.glappen.io/events"
    }

    private var linkReceiver: BroadcastReceiver? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        EventChannel(flutterView, PaymentEvents).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(p0: Any?, p1: EventChannel.EventSink?) {
                    p1?.let {
                        linkReceiver = DeepLinkReceiver(it)
                    }
                }

                override fun onCancel(p0: Any?) {
                    linkReceiver = null
                }
            }
        )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        linkReceiver?.onReceive(this.applicationContext, intent)
    }
}

class DeepLinkReceiver(private val sink: EventChannel.EventSink) : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        intent?.dataString?.let {
            sink.success(it)
        } ?: sink.error("UNAVAILABLE", "Deeplink unavailable", null)
    }
}
