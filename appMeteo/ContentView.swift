//
//  ContentView.swift
//  appMeteo
//
//  Created by Tech Info on 2024-04-10.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack(){
            Text("Saint-Georges de Beauce")
            Text(getDate(addedDays: 0))
            Image(getImageStr(type: 1))
                .resizable()
                .frame(width: 200, height: 200)
            Text("13°c").font(.system(size: 50, weight: Font.Weight.bold))
            Text("À venir")
                .padding(.top, 100)
            HStack(){
                VStack(){
                    Image(getImageStr(type: 1))
                        .resizable()
                        .frame(width: 80, height: 80)
                    Text(getDate(addedDays: 1)).font(.system(size: 16, weight: Font.Weight.bold))
                    Text("Min: " + "1" + "°c")
                    Text("Max: " + "2" + "°c")
                }
            }
        }.onAppear(perform: await getWeatherForTheNextFourDays)
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
        switch(type){
        case 1: return "cloudy"
        case 2: return "rainy"
        case 3: return "snowy"
        case 4: return "sunny"
        default: return "defaultImage"
        }
    }
    
    func getWeatherForTheNextFourDays() async throws{
        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=46.1264&longitude=- 70.6698&current=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min& timezone=America%2FNew_York&forecast_days=4")!
        let (data, _) = try await URLSession.shared.data(from: url);
        let decoded = try JSONDecoder().decode(WeatherObj.self, from: data)
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct WeatherObj: Decodable {
    let daily: WeatherArrays
}

struct WeatherArrays: Decodable {
    let time: Array<String>
    let weather_code: Array<Int>
    let temperature_2m_max: Array<Float>
    let temperature_2m_min: Array<Float>
}
