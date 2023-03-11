import SwiftUI
import WatchKit
import WatchConnectivity

struct ContentView: View {
    @State var batteryLevel: Int = -1
    let sessionDelegate = WatchSessionDelegate()

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "battery.100.bolt")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            if batteryLevel < 0 {
                Text("Battery level not available")
            } else {
                Text("Battery level: \(batteryLevel)%")
            }
        }
        .padding()
        .onAppear {
            if WCSession.isSupported() {
                let session = WCSession.default
                session.delegate = sessionDelegate
                session.activate()
            }
        }
    }
}

class WatchSessionDelegate: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle session activation state
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let batteryLevel = message["batteryLevel"] as? Int {
            DispatchQueue.main.async {
                // Update UI with received battery level
                ContentView().batteryLevel = batteryLevel
            }
        }
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        // Handle message data
    }
}
