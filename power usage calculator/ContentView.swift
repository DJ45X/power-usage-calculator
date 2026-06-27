//
//  ContentView.swift
//  power usage calculator
//
//  Created by Brandon on 6/23/26.
//

import SwiftUI

/// Shared capacity unit used by both the discharge and recharge pages.
enum CapacityUnit: String, CaseIterable, Identifiable {
    case wattHours = "Wh"
    case milliampHours = "mAh"
    var id: Self { self }
}

enum CalculatorPage: String, CaseIterable, Identifiable {
    case discharge = "Discharge"
    case recharge = "Recharge"
    var id: Self { self }
}

struct ContentView: View {
    @State private var page: CalculatorPage = .discharge

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Power Usage Calculator")
                .font(.title2)
                .bold()

            Picker("Mode", selection: $page) {
                ForEach(CalculatorPage.allCases) { page in
                    Text(page.rawValue).tag(page)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            switch page {
            case .discharge:
                DischargeView()
            case .recharge:
                RechargeView()
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(minWidth: 400, minHeight: 520)
    }
}

struct DischargeView: View {
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
        }
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
        result = RuntimeFormatter.format(hours: runtimeHours)
    }

    private func clear() {
        capacityInput = ""
        voltageInput = "3.7"
        loadInput = ""
        result = ""
        errorMessage = nil
    }
}

struct RechargeView: View {
    enum SolarEfficiency: String, CaseIterable, Identifiable {
        case low = "70%"
        case mid = "75%"
        case high = "80%"
        var id: Self { self }

        var factor: Double {
            switch self {
            case .low: return 0.70
            case .mid: return 0.75
            case .high: return 0.80
            }
        }
    }

    @State private var capacityInput: String = ""
    @State private var capacityUnit: CapacityUnit = .wattHours
    @State private var voltageInput: String = "3.7"
    @State private var panelRatingInput: String = ""
    @State private var efficiency: SolarEfficiency = .mid
    @State private var result: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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

            GroupBox("Solar Efficiency") {
                Picker("Solar Efficiency", selection: $efficiency) {
                    ForEach(SolarEfficiency.allCases) { eff in
                        Text(eff.rawValue).tag(eff)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .padding(.vertical, 4)
            }

            GroupBox("Solar Panel Rating") {
                HStack {
                    TextField("Panel rating", text: $panelRatingInput)
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
                GroupBox("Estimated Charge Time") {
                    Text(result)
                        .font(.title3)
                        .padding(.vertical, 4)
                }
            }
        }
    }

    private func calculate() {
        errorMessage = nil
        result = ""

        guard let capacity = Double(capacityInput), capacity > 0 else {
            errorMessage = "Enter a valid capacity greater than 0."
            return
        }
        guard let panelRating = Double(panelRatingInput), panelRating > 0 else {
            errorMessage = "Enter a valid panel rating greater than 0."
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

        // Charge time is the inverse of discharge: capacity divided by the
        // effective charging power (panel rating derated by efficiency).
        let chargeHours = capacityWh / (panelRating * efficiency.factor)
        result = RuntimeFormatter.format(hours: chargeHours)
    }

    private func clear() {
        capacityInput = ""
        voltageInput = "3.7"
        panelRatingInput = ""
        result = ""
        errorMessage = nil
    }
}

/// Formats a duration in decimal hours as "H hours M minutes".
enum RuntimeFormatter {
    static func format(hours: Double) -> String {
        let totalMinutes = Int((hours * 60).rounded())
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        return "\(h) hour\(h == 1 ? "" : "s") \(m) minute\(m == 1 ? "" : "s")"
    }
}

#Preview {
    ContentView()
}
