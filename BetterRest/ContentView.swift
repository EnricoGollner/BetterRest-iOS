//
//  ContentView.swift
//  BetterRest
//
//  Created by Enrico Sousa Gollner on 14/11/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {  // Saying it's a static property means it belongs to the ContentView struct as a whole, not to a particular instance of that struct.
        
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    } // Contains a date value referencing 7 a.m of the current day
    
    var result: String{
        // Making an instance of our sleep calculator class:
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            let hour = (components.hour ?? 0) * 60 * 60  // Converting to seconds
            let minute = (components.minute ?? 0) * 60  // Converting to seconds
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount)) // Here we'll have a prediction of how much sleep they actually need
            
            let sleepTime = wakeUp - prediction.actualSleep  // Converting to know the bedTime
            let bedTime = sleepTime.formatted(date: .omitted, time: .shortened)
            
            return bedTime
            
        } catch{
            showingAlert = true
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        return ""
    }
    
    var body: some View {
        NavigationStack(){
            Form{
                Section(header: Text("When do you want to wake up?")){
                    DatePicker("Please, enter a number", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section(header: Text("Desired amount of sleep")){
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section(header: Text("Daily coffee intake")){
                    Picker("Select the amount of cup", selection: $coffeeAmount){
                        ForEach(1..<21){
                            Text($0 == 1 ? "\($0) cup" : "\($0) cups")
                        }
                    }
                }
                
                Section{
                    Text("Your ideal bedtime is... \(result)")
                        .font(.headline)
                    
                }
            }
            .navigationTitle("BetterRest")
            .alert("Sorry!", isPresented: $showingAlert){
                Button("OK"){}
            } message: {
                Text(alertMessage)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
