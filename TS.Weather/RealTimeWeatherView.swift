//
// RealTimeWeatherView.swift
//
// Created by Anonym on 18.01.25
//
 
import SwiftUI

struct RealTimeWeatherView: View {
    @State private var weatherData: WeatherData?
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
                        fetchWeatherData()
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
                                        fetchWeatherData()
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
                
                // Отображение данных о погоде или ошибки
                Group {
                    if isLoading {
                        ProgressView("Loading weather...")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.red)
                            .padding()
                    } else if let weatherData = weatherData {
                        VStack(spacing: 20) {
                            // Иконка погоды
                            Image(systemName: weatherData.conditionIcon)
                                .font(.system(size: 100))
                                .foregroundColor(.yellow)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            // Температура
                            Text("\(weatherData.temperature)°C")
                                .font(.system(size: 70, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            // Описание погоды
                            Text(weatherData.description.capitalized)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                            
                            // Дополнительная информация
                            HStack(spacing: 30) {
                                WeatherDetailView(icon: "humidity", value: "\(weatherData.humidity)%", label: "Humidity")
                                WeatherDetailView(icon: "wind", value: "\(weatherData.windSpeed) km/h", label: "Wind")
                                WeatherDetailView(icon: "thermometer", value: "\(weatherData.feelsLike)°C", label: "Feels Like")
                            }
                            .padding(.top, 20)
                        }
                        .padding(30)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
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
    
    // Функция для получения данных о погоде
    private func fetchWeatherData() {
        guard !cityName.isEmpty else {
            errorMessage = "Please enter a city name."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(Config.openWeatherMapApiKey)&units=metric"
        
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
                    let result = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
                    weatherData = WeatherData(
                        temperature: Int(result.main.temp),
                        conditionIcon: iconForWeatherCondition(result.weather.first?.id ?? 800),
                        description: result.weather.first?.description ?? "N/A",
                        humidity: result.main.humidity,
                        windSpeed: Int(result.wind.speed),
                        feelsLike: Int(result.main.feels_like)
                    )
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
        case 200..<300: return "cloud.bolt.rain.fill" // Гроза
        case 300..<400: return "cloud.drizzle.fill" // Морось
        case 500..<600: return "cloud.rain.fill" // Дождь
        case 600..<700: return "cloud.snow.fill" // Снег
        case 700..<800: return "cloud.fog.fill" // Туман
        case 800: return "sun.max.fill" // Ясно
        case 801..<900: return "cloud.fill" // Облачно
        default: return "questionmark.circle.fill"
        }
    }
}