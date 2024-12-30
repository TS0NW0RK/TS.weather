//
// WeatherApp.swift
//
// Created by Anonym on 30.12.24
//
 
import SwiftUI

@main
struct WeatherApp: App {
    @StateObject private var settings = SettingsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        }
    }
}