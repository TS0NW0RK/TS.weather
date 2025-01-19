//
// ForecastRow.swift
//
// Created by Anonym on 19.01.25
//
 
import SwiftUI

struct ForecastRow: View {
    let forecast: ForecastData

    var body: some View {
        HStack {
            Text(forecast.day)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            Image(systemName: forecast.conditionIcon)
                .font(.system(size: 24))
                .foregroundColor(.yellow)
            Text("H: \(forecast.highTemp)° L: \(forecast.lowTemp)°")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}