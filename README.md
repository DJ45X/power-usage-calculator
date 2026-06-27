# Power Usage Calculator

A simple macOS app built with Swift and SwiftUI that estimates how long a battery
bank will last on a charge, and how long it takes to recharge from a solar panel.

## What It Does

The app has two modes, toggled with a segmented control:

- **Discharge** — Calculates how long (in hours and minutes) a battery bank will
  run a given load. You enter the battery capacity, choose an efficiency factor
  (AC 85% or DC 90%), and enter the load in watts.

  `runtime (h) = (capacity Wh × efficiency) / load W`

- **Recharge** — Calculates how long (in hours and minutes) it takes to recharge
  the battery from a solar panel under ideal conditions. You enter the battery
  capacity, choose a real-world solar efficiency factor (70%–80%), and enter the
  panel rating in watts.

  `charge time (h) = capacity Wh / (panel rating W × efficiency)`

Both modes accept capacity in **Wh** or **mAh**. When **mAh** is selected, a
voltage field appears and the value is converted to watt-hours first:

  `Wh = (mAh × V) / 1000`

A **Calculate** button runs the math and a **Clear** button resets the fields.

> Note: The recharge estimate assumes perfect conditions. Real-world factors like
> panel angle, temperature, and atmospheric clarity are not accounted for.

## Swift & SwiftUI Concepts Used

- **SwiftUI views** — composing the UI from `View` structs (`ContentView`,
  `DischargeView`, `RechargeView`) for clear separation of concerns.
- **State management** — `@State private var` for two-way bindings to text fields
  and pickers; `$` projected values to pass bindings into controls.
- **Enums** — `CaseIterable` / `Identifiable` enums (`CapacityUnit`,
  `CalculatorPage`, `Efficiency`, `SolarEfficiency`) with computed properties to
  pair display labels with their numeric factors.
- **Layout** — `VStack`, `HStack`, `GroupBox`, `Spacer`, and `.padding` /
  `.frame` modifiers to build a structured, resizable window.
- **Controls** — `TextField`, segmented `Picker`, and styled `Button`s, including
  `.keyboardShortcut(.defaultAction)` so Return triggers Calculate.
- **Conditional UI** — `if` / `switch` inside `body` to show the voltage field
  only for mAh and to swap between the discharge and recharge pages.
- **Optionals & safe parsing** — `guard let` with `Double(...)` to validate input
  without force unwrapping, surfacing friendly error messages.
- **Code reuse** — a shared `RuntimeFormatter` helper to format decimal hours as
  "H hours M minutes" across both pages.

## Screenshot

<img width="1024" height="1328" alt="image" src="https://github.com/user-attachments/assets/81ae099f-4f23-49ae-8c2e-af29f7cd7279" />


## Requirements

- macOS
- Xcode
- Swift / SwiftUI
