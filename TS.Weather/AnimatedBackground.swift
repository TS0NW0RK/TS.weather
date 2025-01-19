//
// AnimatedBackground.swift
//
// Created by Anonym on 19.01.25
//
 
import SwiftUI

struct AnimatedBackground: View {
    @State private var gradientStart = UnitPoint(x: 0, y: 0)
    @State private var gradientEnd = UnitPoint(x: 1, y: 1)
    
    let colors: [Color] = [.mint, .blue, .mint, .blue] // Мятный и голубой
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: gradientStart, endPoint: gradientEnd)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                    self.gradientStart = UnitPoint(x: 1, y: 1)
                    self.gradientEnd = UnitPoint(x: 0, y: 0)
                }
            }
    }
}