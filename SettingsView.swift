//
// SettingsView.swift
//
// Created by Anonym on 30.12.24
//
 
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsViewModel
    
    var body: some View {
        Form {
            Picker("Weather API", selection: $settings.selectedAPI) {
                Text("OpenWeatherMap").tag(APIType.openWeatherMap)
                Text("AccuWeather").tag(APIType.accuWeather)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Toggle("Dark Mode", isOn: $settings.isDarkMode)
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsViewModel())
    }
}