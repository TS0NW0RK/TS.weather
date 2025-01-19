//
// WhatsNewView.swift
//
// Created by Anonym on 18.01.25
//
 
import SwiftUI

struct WhatsNewView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Полупрозрачный черный фон на весь экран
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            // Основное окно Popup
            VStack(spacing: 20) {
                Text("What's New")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Text("Welcome to TS.Weather 2! Here are the latest updates...")
                    .font(.system(size: 18, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // Ссылка на GitHub
                Link(destination: URL(string: "https://github.com/yourusername/TS.Weather2")!) {
                    HStack {
                        Image(systemName: "link")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("View on GitHub")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.8))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            .padding(20)
            .transition(.scale.combined(with: .opacity))
        }
    }
}