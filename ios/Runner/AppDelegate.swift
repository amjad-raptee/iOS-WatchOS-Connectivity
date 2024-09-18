import UIKit
import Flutter
import WatchConnectivity

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, WCSessionDelegate, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var networkEventChannel="watchconnectivity"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        FlutterEventChannel(name: networkEventChannel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self)
        
        let watchChannel = FlutterMethodChannel(name: "watchPlatform"	, binaryMessenger: controller.binaryMessenger)
        
        if WCSession.isSupported(){
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        // This methods is for handling method channel from flutter app
        watchChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult)-> Void in
            if call.method == "sendToWatch" {
                if let args = call.arguments as? Dictionary<String, Any>, let data = args["data"] as? String{
                    let data = ["text": data]
                    self.sendMessage(data)
                }else{
                    result(FlutterError.init( code: "errorSetDebug", message:  "iphone: Data or format error", details: nil))
                }
            }else{
                result(FlutterMethodNotImplemented)
                return
            }
            
            
        })
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        Task{ @MainActor in
            if activationState == .activated
            {
                if session.isWatchAppInstalled{
                    guard let eventSink = eventSink else {
                        return
                    }
                    eventSink("iphone: watch app is installed")
                }
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
    // This method is for listing the sending the data to watch and listining the response from watch
    
    func sendMessage ( _ data: [String: Any]){
        let session = WCSession.default
        
        if session.isReachable{
            session.sendMessage(data) { response in
                Task{ @MainActor in
                    guard let eventSink = self.eventSink else{
                        return
                    }
                    
                    //update to flutter app via event channel
                    eventSink("\(response)")
                }
            }
        }
        
        
    }
    
    
    //This method is for getting receiving data from watch and reply it back
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Task { @MainActor in
            if let text = message["text"] as? String {
                guard let eventSink = eventSink else{
                    return
                }
                eventSink("\(text)")
                replyHandler(["response_iphone" : "iPhone Says: I have received data successfully"])
            }
        }
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
    
    
