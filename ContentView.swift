//
// ContentView.swift
//
// Created by Anonym on 30.12.24
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var weatherVM = WeatherViewModel()
    @EnvironmentObject var settings: SettingsViewModel
    @State private var selectedTab = 0
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var locationManager = CLLocationManager()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            VStack {
                Text("Weather in \(weatherVM.cityName)")
                    .font(.custom("AvenirNext-DemiBold", size: 30))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                HStack {
                    TextField("Search for a city", text: $searchText, onCommit: {
                        weatherVM.cityName = searchText
                        weatherVM.fetchWeather(apiType: settings.selectedAPI)
                        isSearchFieldFocused = false // Скрыть клавиатуру после ввода
                    })
                    .font(.custom("AvenirNext-Regular", size: 17))
                    .padding(7)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(8)
                    .focused($isSearchFieldFocused)
                    
                    Button(action: {
                        searchText = ""
                        weatherVM.cityName = "Moscow" // или любой другой город по умолчанию
                        weatherVM.fetchWeather(apiType: settings.selectedAPI)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.custom("AvenirNext-Regular", size: 17))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 5)
                }
                .padding(.horizontal)

                Spacer()
                
                if weatherVM.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: weatherVM.weatherIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .blue.opacity(0.5))
                        
                        Text("\(Int(weatherVM.temperature))°C")
                            .font(.custom("AvenirNext-Bold", size: 70))
                            .foregroundColor(.white)
                        
                        Text(weatherVM.weatherDescription)
                            .font(.custom("AvenirNext-Regular", size: 20))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                weatherVM.fetchWeather(apiType: settings.selectedAPI)
                setupLocationManager()
            }
            .tabItem {
                Label("Weather", systemImage: "cloud.sun.fill")
            }
            .tag(0)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(1)
        }
        .accentColor(.white)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = weatherVM
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SettingsViewModel())
    }
}