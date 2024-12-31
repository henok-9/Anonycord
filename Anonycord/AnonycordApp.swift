//
//  AnonycordApp.swift
//  Anonycord
//
//  Created by Constantin Clerc on 7/8/24.
//

import SwiftUI

@main
struct AnonycordApp: App {
    @StateObject private var appSettings = AppSettings()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
        }
    }
}

class AppSettings: ObservableObject {
    @AppStorage("micSampleRate") var micSampleRate: Int = 44100
    @AppStorage("channelDef") var channelDef: Int = 1
    @AppStorage("cameraType") var cameraType: String = "Wide"
    // @AppStorage("videoQuality") var videoQuality: String = "1080p"
    @AppStorage("videoQuality") var videoQuality: String = "4K"
    @AppStorage("crashAtEnd") var crashAtEnd: Bool = false
    @AppStorage("showSettingsAtBttm") var showSettingsAtBttm: Bool = true
    @AppStorage("hideAll") var hideAll: Bool = false
    
    // Stealth recording settings
    @AppStorage("autoDimming") var autoDimming: Bool = false
    @AppStorage("dimmingIntensity") var dimmingIntensity: Double = 0.1
    @AppStorage("requireLongPressToStop") var requireLongPressToStop: Bool = true
    @AppStorage("longPressStopDuration") var longPressStopDuration: Double = 2.0
}
