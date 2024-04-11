//
//  ContentView.swift
//  appMeteo
//
//  Created by Tech Info on 2024-04-10.
//

import SwiftUI

struct ContentView: View {
    
    @State private var response: WeatherObj?;
    @State private var loading: Bool = false;
    
    var body: some View {
        VStack(){
            Text("Saint-Georges de Beauce")
            Text(getDate(addedDays: 0))
            Image(getImageStr(type: response?.current.weather_code ?? 0))
                .resizable()
                .frame(width: 200, height: 200)
            Text(String(response?.current.temperature_2m ?? 0) + "°c").font(.system(size: 50, weight: Font.Weight.bold))
            Text("À venir")
                .padding(.top, 100)
            HStack(spacing: 20){
                    ForEach(0..<(response?.daily.weather_code.count ?? 0), id: \.self){ i in
                        VStack(){
                            Image(getImageStr(type: response?.daily.weather_code[i] ?? 0))
                                .resizable()
                                .frame(width: 80, height: 80)
                            Text(getDate(addedDays: i)).font(.system(size: 16, weight: Font.Weight.bold))
                            Text("Min: " + String(response?.daily.temperature_2m_min[i] ?? 0) + "°c")
                            Text("Max: " + String(response?.daily.temperature_2m_max[i] ?? 0) + "°c")
                        }
                    }
                }
        }.overlay(
            Group{
                if (loading){
                    ProgressView("Recueil des données météo")
                }
            }
        ).onAppear{
                Task.init{
                    loading = true;
                    response = try await getWeatherForTheNextFourDays()
                    loading = false;
                }
            }
        }
    }
    
    func getDate(addedDays:Int) -> String{
        var date = Date();
        if (addedDays > 0){
            date = Calendar.current.date(byAdding: .day, value: addedDays, to: date) ?? date
        }
        let dateFormator = DateFormatter();
        dateFormator.dateFormat = "MM-dd-yyyy";
        let result = dateFormator.string(from: date);
        return result;
    }
    
    func getImageStr(type:Int) ->String{
        if (type < 2){
            return "sunny"
        }
        if (type < 4){
            return "defaultImage"
        }
        if (type < 50){
            return "cloudy"
        }
        if ((type > 67 && type < 80) || (type > 84 && type < 89)){
            return "snowy"
        }
        return "rainy"
    }
    
    func getWeatherForTheNextFourDays() async throws -> WeatherObj {
        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=46.1264&longitude=-70.6698&current=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=America%2FNew_York&forecast_days=3")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(WeatherObj.self, from: data)
        return decoded.self
    }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct WeatherObj: Codable {
    let current: CurrentWeather
    let daily: WeatherArrays
}

struct WeatherArrays: Codable {
    let time: [String]
    let weather_code: [Int]
    let temperature_2m_max: [Double]
    let temperature_2m_min: [Double]
}

struct CurrentWeather: Codable {
    let temperature_2m: Double
    let weather_code: Int
}
