//
// WeatherViewModel.swift
//
// Created by Anonym on 30.12.24
//
 
import SwiftUI
import Combine
import CoreLocation

class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var temperature: Double = 0
    @Published var weatherDescription: String = ""
    @Published var weatherIcon: String = "questionmark.circle.fill"
    @Published var cityName: String = "Moscow"
    @Published var isLoading: Bool = false
    
    private var openWeatherKey: String?
    private var accuWeatherKey: String?
    
    private let openWeatherBaseURL = "https://api.openweathermap.org/data/2.5/weather"
    private let accuWeatherBaseURL = "http://dataservice.accuweather.com/currentconditions/v1/"
    
    override init() {
        super.init()
        if let path = Bundle.main.path(forResource: "APIConfig", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            openWeatherKey = dict["OpenWeatherAPIKey"] as? String
            accuWeatherKey = dict["AccuWeatherAPIKey"] as? String
        }
    }
    
    func fetchWeather(apiType: APIType) {
        isLoading = true
        var url: URL?
        
        switch apiType {
        case .openWeatherMap:
            guard let apiKey = openWeatherKey else {
                isLoading = false
                return
            }
            url = URL(string: "\(openWeatherBaseURL)?q=\(cityName)&appid=\(apiKey)&units=metric")
        case .accuWeather:
            guard let apiKey = accuWeatherKey else {
                isLoading = false
                return
            }
            url = URL(string: "\(accuWeatherBaseURL)\(cityName)?apikey=\(apiKey)&details=true")
        }
        
        guard let url = url else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { DispatchQueue.main.async { self.isLoading = false } }
            guard let data = data, error == nil else {
                print("Error fetching weather data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if apiType == .openWeatherMap {
                    let weatherData = try JSONDecoder().decode(OpenWeatherData.self, from: data)
                    DispatchQueue.main.async {
                        self.temperature = weatherData.main.temp
                        self.weatherDescription = weatherData.weather.first?.description ?? ""
                        self.weatherIcon = self.mapWeatherIcon(condition: weatherData.weather.first?.main ?? "")
                    }
                } else { // AccuWeather
                    let weatherData = try JSONDecoder().decode([AccuWeatherData].self, from: data)
                    DispatchQueue.main.async {
                        self.temperature = weatherData.first?.Temperature.Metric.Value ?? 0
                        self.weatherDescription = weatherData.first?.WeatherText ?? ""
                        self.weatherIcon = self.mapAccuWeatherIcon(icon: weatherData.first?.WeatherIcon ?? 0)
                    }
                }
            } catch {
                print("Failed to decode: \(error)")
            }
        }.resume()
    }
    
    func mapWeatherIcon(condition: String) -> String {
        switch condition {
        case "Clear":
            return "sun.max.fill"
        case "Clouds":
            return "cloud.fill"
        case "Rain":
            return "cloud.rain.fill"
        case "Snow":
            return "snowflake"
        default:
            return "cloud.fill"
        }
    }
    
    func mapAccuWeatherIcon(icon: Int) -> String {
        switch icon {
        case 1, 2, 3: return "sun.max.fill"
        case 6, 7, 8: return "cloud.sun.fill"
        case 11, 12: return "cloud.rain.fill"
        case 13, 14: return "snowflake"
        default: return "cloud.fill"
        }
    }
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocode failed: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                if let city = placemark.locality {
                    self.cityName = city
                    self.fetchWeather(apiType: .openWeatherMap) // или другой API по умолчанию
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}

enum APIType {
    case openWeatherMap, accuWeather
}

struct OpenWeatherData: Codable {
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let main: String
    let description: String
}

struct AccuWeatherData: Codable {
    struct Temperature: Codable {
        struct Metric: Codable {
            let Value: Double
        }
        let Metric: Metric
    }
    let Temperature: Temperature
    let WeatherText: String
    let WeatherIcon: Int
}