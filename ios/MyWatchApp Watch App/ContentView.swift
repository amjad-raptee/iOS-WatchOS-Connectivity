//
//  ContentView.swift
//  MyWatchApp Watch App
//
//  Created by Sarath ARP on 18/09/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var connectivity = Connectivity()
    var body: some View {
        VStack {
            
            Text("iPhone: \(connectivity.receivedText)")
            Button("Message", action: sendMessage)
        }
        
    }
    
    func sendMessage (){
        let data = ["text" : "Hi iPhone, I'm you watch"]
        connectivity.sendMessage(data)
    }
}

#Preview {
    ContentView()
}
