//
//  ContentView.swift
//  DrinkUp!
//
//  Created by Oliwier Kasprzak on 18/05/2023.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @AppStorage("waterConsumed") private var waterConsumed = 1800.0
    @AppStorage("waterRequired") private var waterRequired = 2000.0
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    @AppStorage("lastDrinkDate") private var lastDrinkDate = Date.now.timeIntervalSinceReferenceDate
    
    @State private var showingAdjustment = false
    @State private var showingDrinks = false
    
    
    
    var goalProgress: Double {
        waterConsumed / waterRequired
    }
    
    let mlToOz = 0.0351951
    let ozToMl = 29.5735
    
    var statusText: Text {
        if useMetricUnits {
            return Text("\(Int(waterConsumed))ml / \(Int(waterRequired))ml")
        } else {
            let adjustedConsumed = waterConsumed * mlToOz
            let adjustedRequired = waterRequired * mlToOz
            return Text("\(Int(adjustedConsumed))oz / \(Int(adjustedRequired))oz")
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                statusText
                    .font(.largeTitle)
                    .padding(.top)
                    .onTapGesture {
                        withAnimation {
                            showingAdjustment.toggle()
                        }
                    }
                
                if showingAdjustment {
                    VStack {
                        Text("Adjust goal")
                            .font(.headline)
                        
                        Slider(value: $waterRequired, in: 500...4000)
                            .tint(.white)
                    }
                    .padding()
                    .transition(.scale(scale: 0, anchor: .top))
                }
                
                Image(systemName: "drop.fill")
                    .resizable()
                    .font(.title.weight(.ultraLight))
                    .scaledToFit()
                    .foregroundStyle(
                        .linearGradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .clear, location: 1 - goalProgress),
                            .init(color: .white, location: 1 - goalProgress),
                            .init(color: .white, location: 1)
                        ], startPoint: .top, endPoint: .bottom)
                    )
                    .overlay(
                        Image(systemName: "drop")
                            .resizable()
                            .font(.title.weight(.ultraLight))
                            .scaledToFit()
                    )
                    .padding()
                    .onTapGesture {
                        showingDrinks.toggle()
                    }
                
                Toggle("Use Metric units", isOn: $useMetricUnits)
                    .padding()
                    .tint(.secondary)
            }
        }
        .foregroundColor(.white)
        .alert("Add Drink", isPresented: $showingDrinks) {
            if useMetricUnits {
                ForEach([100, 200, 300, 400, 500, 600], id: \.self) { number in
                    Button("\(number)ml") { add(Double(number)) }
                }
            } else {
                ForEach([8, 12, 20, 24, 28, 33], id: \.self) { number in
                    Button("\(number)oz") { add(Double(number) * ozToMl) }
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) {
            output in
            checkForReset()
        }
        
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) {
            output in
            checkForReset()
        }
        .onChange(of: waterConsumed) { _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onChange(of: waterRequired) { _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func add(_ amount: Double) {
        lastDrinkDate = Date.now.timeIntervalSinceReferenceDate
        waterConsumed += amount
    }
    
    func checkForReset() {
        let lastCheck = Date(timeIntervalSinceReferenceDate: lastDrinkDate)
        
        if Calendar.current.isDateInToday(lastCheck) == false {
            waterConsumed = 0
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
