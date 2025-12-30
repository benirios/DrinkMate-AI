# 🍸 DrinkMate AI

DrinkMate AI is a minimalist iOS app that helps users estimate alcohol risk and sobriety using a simplified **BAC (Blood Alcohol Concentration)** calculation based on the **Widmark formula**. The app is designed to be fast, private, and fully offline, promoting safer and more informed decisions.

## 🚀 Features

- **BAC Estimation (Widmark Formula)**
  - Uses weight, sex, drink type and quantity
  - Applies an average alcohol metabolism rate of **0.015 BAC per hour**
  - Time since last drink is calculated automatically using the timestamp of the last drink added

- **Risk Score**
  - Visual status: **Green / Yellow / Red**
  - Clear indication of current estimated risk level

- **Estimated Time Until Safe to Drive**
  - Shows how long it may take to reach a sober state
  - Displayed in simple, easy-to-read time format

- **Onboarding Personalization**
  - Collects weight, sex, and drinking frequency
  - Data stored locally on the device (UserDefaults)

- **Editable Settings**
  - Users can update onboarding information at any time via the Settings screen

- **Cal AI–Inspired UI**
  - Clean, card-based layout
  - Large typography and minimal distractions

- **100% Offline & Private**
  - No login, no backend, no data tracking

## 🛠 Tech Stack

- **Swift**
- **SwiftUI**
- **UserDefaults** for local storage
- Widmark BAC estimation logic

## ⚠️ Disclaimer

DrinkMate AI provides **estimates only**. It does **not** measure actual blood alcohol levels and should **never** be used as a legal or medical tool to determine fitness to drive. Always choose the safest option.

## 📱 Platform

- iOS (SwiftUI)
- iPhone-first MVP

## 🎯 Goal

To deliver a fast, intuitive, and responsible tool that encourages safer alcohol consumption decisions using simple, transparent logic and a modern UI.
