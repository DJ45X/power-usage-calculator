//
//  ContentView.swift
//  power usage calculator
//
//  Created by Brandon on 6/23/26.
//

import SwiftUI

struct ContentView: View {
    enum CapacityUnit: String, CaseIterable, Identifiable {
        case wattHours = "Wh"
        case milliampHours = "mAh"
        var id: Self { self }
    }

    enum Efficiency: String, CaseIterable, Identifiable {
        case ac = "AC (85%)"
        case dc = "DC (90%)"
        var id: Self { self }

        var factor: Double {
            switch self {
            case .ac: return 0.85
            case .dc: return 0.90
            }
        }
    }

    @State private var capacityInput: String = ""
    @State private var capacityUnit: CapacityUnit = .wattHours
    @State private var voltageInput: String = "3.7"
    @State private var efficiency: Efficiency = .dc
    @State private var loadInput: String = ""
    @State private var result: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Power Usage Calculator")
                .font(.title2)
                .bold()

            GroupBox("Battery Capacity") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("Capacity", text: $capacityInput)
                            .textFieldStyle(.roundedBorder)
                        Picker("Unit", selection: $capacityUnit) {
                            ForEach(CapacityUnit.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .frame(width: 140)
                    }

                    if capacityUnit == .milliampHours {
                        HStack {
                            Text("Voltage (V):")
                            TextField("e.g. 3.7", text: $voltageInput)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            GroupBox("Efficiency") {
                Picker("Efficiency", selection: $efficiency) {
                    ForEach(Efficiency.allCases) { eff in
                        Text(eff.rawValue).tag(eff)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .padding(.vertical, 4)
            }

            GroupBox("Load") {
                HStack {
                    TextField("Load wattage", text: $loadInput)
                        .textFieldStyle(.roundedBorder)
                    Text("W")
                }
                .padding(.vertical, 4)
            }

            HStack {
                Button("Calculate") { calculate() }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)

                Button("Clear") { clear() }
                    .buttonStyle(.bordered)
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            } else if !result.isEmpty {
                GroupBox("Estimated Runtime") {
                    Text(result)
                        .font(.title3)
                        .padding(.vertical, 4)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(minWidth: 400, minHeight: 500)
    }

    private func calculate() {
        errorMessage = nil
        result = ""

        guard let capacity = Double(capacityInput), capacity > 0 else {
            errorMessage = "Enter a valid capacity greater than 0."
            return
        }
        guard let load = Double(loadInput), load > 0 else {
            errorMessage = "Enter a valid load greater than 0."
            return
        }

        let capacityWh: Double
        switch capacityUnit {
        case .wattHours:
            capacityWh = capacity
        case .milliampHours:
            guard let voltage = Double(voltageInput), voltage > 0 else {
                errorMessage = "Enter a valid voltage greater than 0."
                return
            }
            capacityWh = (capacity * voltage) / 1000.0
        }

        let runtimeHours = (capacityWh * efficiency.factor) / load
        let totalMinutes = Int((runtimeHours * 60).rounded())
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        result = "\(hours) hour\(hours == 1 ? "" : "s") \(minutes) minute\(minutes == 1 ? "" : "s")"
    }

    private func clear() {
        capacityInput = ""
        voltageInput = "3.7"
        loadInput = ""
        result = ""
        errorMessage = nil
    }
}

#Preview {
    ContentView()
}
