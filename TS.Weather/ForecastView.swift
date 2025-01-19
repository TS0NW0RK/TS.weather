//
// ForecastView.swift
//
// Created by Anonym on 18.01.25
//
 
import SwiftUI

struct ForecastView: View {
    @State private var forecastData: [ForecastData] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var cityName: String = ""
    @State private var searchHistory: [String] = [] {
        didSet {
            saveSearchHistory()
        }
    }
    
    var body: some View {
        ZStack {
            // Анимированный фон
            AnimatedBackground()
            
            VStack(spacing: 20) {
                // Поле поиска города
                HStack {
                    TextField("Enter city name", text: $cityName)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(25)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    Button(action: {
                        fetchForecastData()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // История поиска
                if !searchHistory.isEmpty {
                    HStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(searchHistory, id: \.self) { city in
                                    Button(action: {
                                        cityName = city
                                        fetchForecastData()
                                    }) {
                                        Text(city)
                                            .padding(10)
                                            .background(Color.white.opacity(0.2))
                                            .cornerRadius(20)
                                            .foregroundColor(.white)
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Кнопка удаления истории
                        Button(action: {
                            searchHistory.removeAll()
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.red.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                    }
                }
                
                // Отображение данных прогноза или ошибки
                Group {
                    if isLoading {
                        ProgressView("Loading forecast...")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.red)
                            .padding()
                    } else if !forecastData.isEmpty {
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(forecastData, id: \.day) { forecast in
                                    ForecastRow(forecast: forecast)
                                }
                            }
                            .padding()
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            loadSearchHistory()
        }
    }
    
    // Функция для получения данных прогноза
    private func fetchForecastData() {
        guard !cityName.isEmpty else {
            errorMessage = "Please enter a city name."
            return
        }
        
        isLoading = true
        errorMessage = nil
        forecastData = []
        
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(Config.weatherApiKey)&q=\(cityName)&days=5&aqi=no&alerts=no"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    errorMessage = "No data received"
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(WeatherAPIResponse.self, from: data)
                    forecastData = result.forecast.forecastday.map { day in
                        ForecastData(
                            day: day.date,
                            conditionIcon: iconForWeatherCondition(day.day.condition.code),
                            highTemp: Int(day.day.maxtemp_c),
                            lowTemp: Int(day.day.mintemp_c)
                        )
                    }
                    // Добавляем город в историю
                    addToSearchHistory(city: cityName)
                } catch {
                    errorMessage = "City not found. Please try again."
                }
            }
        }.resume()
    }
    
    // Функция для добавления города в историю
    private func addToSearchHistory(city: String) {
        if !searchHistory.contains(city) {
            searchHistory.append(city)
            // Ограничим историю, например, последними 5 городами
            if searchHistory.count > 5 {
                searchHistory.removeFirst()
            }
        }
    }
    
    // Функция для загрузки истории
    private func loadSearchHistory() {
        if let history = UserDefaults.standard.array(forKey: "searchHistory") as? [String] {
            searchHistory = history
        }
    }
    
    // Функция для сохранения истории
    private func saveSearchHistory() {
        UserDefaults.standard.set(searchHistory, forKey: "searchHistory")
    }
    
    // Функция для получения иконки погоды
    private func iconForWeatherCondition(_ conditionCode: Int) -> String {
        switch conditionCode {
        case 1000: return "sun.max.fill" // Ясно
        case 1003: return "cloud.sun.fill" // Переменная облачность
        case 1006, 1009: return "cloud.fill" // Облачно
        case 1030, 1135, 1147: return "cloud.fog.fill" // Туман
        case 1063, 1180, 1183, 1186, 1189, 1192, 1195, 1240, 1243, 1246: return "cloud.rain.fill" // Дождь
        case 1066, 1114, 1117, 1210, 1213, 1216, 1219, 1222, 1225, 1255, 1258: return "cloud.snow.fill" // Снег
        case 1087, 1273, 1276, 1279, 1282: return "cloud.bolt.fill" // Гроза
        default: return "questionmark.circle.fill"
        }
    }
}