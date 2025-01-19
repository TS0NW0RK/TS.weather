//
// WeatherModels.swift
//
// Created by Anonym on 18.01.25
//

import Foundation

// Модель для ответа от OpenWeatherMap API
struct OpenWeatherResponse: Codable {
    let main: Main
    let weather: [Weather]
    let wind: Wind
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let humidity: Int
}

struct Weather: Codable {
    let id: Int
    let description: String
}

struct Wind: Codable {
    let speed: Double
}

// Модель данных для текущей погоды
struct WeatherData {
    let temperature: Int
    let conditionIcon: String
    let description: String
    let humidity: Int
    let windSpeed: Int
    let feelsLike: Int
}

// Модель для ответа от WeatherAPI (прогноз)
struct WeatherAPIResponse: Codable {
    let forecast: Forecast
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
    let date: String
    let day: Day
}

struct Day: Codable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let condition: Condition
}

struct Condition: Codable {
    let code: Int
}

// Модель данных для прогноза
struct ForecastData {
    let day: String
    let conditionIcon: String
    let highTemp: Int
    let lowTemp: Int
}