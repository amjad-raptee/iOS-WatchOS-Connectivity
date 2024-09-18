//
//  Connectivity.swift
//  MyWatchApp Watch App
//
//  Created by Sarath ARP on 18/09/24.
//

import Foundation
import WatchConnectivity

class Connectivity :NSObject, ObservableObject, WCSessionDelegate{
    @Published var receivedText = ""
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    //This method is for send data to phone and listen to response
    func sendMessage (_ data: [String: Any]){
        let session = WCSession.default
        
        if session.isReachable {
            session.sendMessage(data){ response in
                Task{ @MainActor in
                    self.receivedText = "Received response from watch after msg sent: \(response)"
                    
                }
                
            }
            
        }
    }
    
    
    // This method is for receive data and reply back to phone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Task { @MainActor in
            if let text = message["text"] as? String {
                self.receivedText = text
                replyHandler(["response_watch" : "Watch Says: Data is received by watch"])
            }
            
        }
    }
    
    
}
