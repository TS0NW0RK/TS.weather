//
// SettingsViewModel.swift
//
// Created by Anonym on 30.12.24
//
 
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var selectedAPI: APIType = .openWeatherMap
    @Published var isDarkMode: Bool = false {
        didSet {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }
}