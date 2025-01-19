//
// ContentView.swift
//
// Created by Anonym on 18.01.25
//
 
import SwiftUI

struct ContentView: View {
    @State private var showWhatsNew = UserDefaults.standard.bool(forKey: "hasLaunchedBefore") == false
    
    var body: some View {
        ZStack {
            TabView {
                RealTimeWeatherView()
                    .tabItem {
                        Image(systemName: "cloud.sun.fill")
                        Text("Real-Time Weather")
                    }
                
                ForecastView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Forecast")
                    }
            }
            
            // Blur эффект для Popup
            if showWhatsNew {
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            }
        }
        .sheet(isPresented: $showWhatsNew) {
            WhatsNewView(isPresented: $showWhatsNew)
                .onDisappear {
                    UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                }
        }
    }
}

// Blur эффект для фона Popup
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}