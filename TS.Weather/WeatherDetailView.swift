//
// WeatherDetailView.swift
//
// Created by Anonym on 19.01.25
//
 
import SwiftUI

struct WeatherDetailView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            Text(value)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
    }
}