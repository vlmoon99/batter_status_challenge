import UIKit
import Flutter
import WatchConnectivity

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, WCSessionDelegate {
    private let CHANNEL = "plugin/battery"
    private let EVENT_CHANNEL = "plugin/batteryEvent"
    var session: WCSession?

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        UIDevice.current.isBatteryMonitoringEnabled = true
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }

        let methodChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
        methodChannel.setMethodCallHandler { [weak self] call, result in
            guard call.method == "getBatteryLevel" else {
                result(FlutterMethodNotImplemented)
                return
            }

            let batteryLevel = self?.getBatteryLevel() ?? -1
            if batteryLevel >= 0 {
                result(batteryLevel)
            } else {
                result(FlutterError(code: "UNAVAILABLE", message: "Battery level not available.", details: nil))
            }
        }

        let eventChannel = FlutterEventChannel(name: EVENT_CHANNEL, binaryMessenger: controller.binaryMessenger)
        eventChannel.setStreamHandler(BatteryHandler())

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }


    private func getBatteryLevel() -> Int {
        var batteryLevel = -1
        if UIDevice.current.isBatteryMonitoringEnabled {
            batteryLevel = Int(UIDevice.current.batteryLevel * 100)
            if let session = session, session.isReachable {
                // Send battery level to the watch app
                session.sendMessage(["request": "batteryLevel"], replyHandler: { reply in
                    // Handle reply from watch app if needed
                }, errorHandler: { error in
                    print("Error sending message to watch app: \(error.localizedDescription)")
                })
            }
        }
        return batteryLevel
    }

    //Apple Watch methods

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle session activation state
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session did become inactive
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Handle session did deactivate
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if message["request"] as? String == "batteryLevel" {
            let batteryLevel = getBatteryLevel()
            session.sendMessage(["batteryLevel": batteryLevel], replyHandler: nil, errorHandler: nil)
        }
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        // Handle received message data
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        // Handle received message data with reply
    }

    //Apple Watch methods
}

class BatteryHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(forName: UIDevice.batteryLevelDidChangeNotification, object: nil, queue: nil) { _ in
            self.sendBatteryLevel()
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        UIDevice.current.isBatteryMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        self.eventSink = nil
        return nil
    }
    
    private func sendBatteryLevel() {
        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        self.eventSink?(batteryLevel)
    }
}
