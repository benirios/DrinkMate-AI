//
//  OnboardingView.swift
//  DrinkMate AI
//
//  Created by Benício Rios on 29/12/2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var sexIndex: Int = 0
    @State private var weightKg: Double = 75
    @State private var countryIndex: Int = 0
    @State private var drinkingFrequencyIndex: Int = 1 // 0=Rarely, 1=Weekly, 2=Often
    @Binding var hasCompletedOnboarding: Bool
    @Binding var userSex: Int
    @Binding var userWeight: Double
    @Binding var userCountry: Int
    @Binding var userDrinkingFrequency: Int
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if currentPage == 0 {
                    ProblemScreen(onNext: { currentPage = 1 })
                } else if currentPage == 1 {
                    SolutionScreen(onNext: { currentPage = 2 })
                } else if currentPage == 2 {
                    UserInputScreen(
                        sexIndex: $sexIndex,
                        weightKg: $weightKg,
                        countryIndex: $countryIndex,
                        onNext: { currentPage = 3 }
                    )
                } else if currentPage == 3 {
                    DrinkingFrequencyScreen(
                        drinkingFrequencyIndex: $drinkingFrequencyIndex,
                        onComplete: {
                            userSex = sexIndex
                            userWeight = weightKg
                            userCountry = countryIndex
                            userDrinkingFrequency = drinkingFrequencyIndex
                            hasCompletedOnboarding = true
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Screen 1: Problem
struct ProblemScreen: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "car.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 20) {
                Text("The Problem")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("After drinking, it's difficult to know if you're safe to drive.")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Guessing can put you and others at risk.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .padding()
    }
}

// MARK: - Screen 2: Solution
struct SolutionScreen: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 20) {
                Text("The Solution")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("DrinkMate AI helps you make informed decisions.")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(spacing: 16) {
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Calculate BAC",
                    description: "Estimate your blood alcohol content"
                )
                
                FeatureRow(
                    icon: "gauge.with.dots.needle.67percent",
                    title: "Risk Score",
                    description: "See your risk level at a glance"
                )
                
                FeatureRow(
                    icon: "clock.fill",
                    title: "Safe Time",
                    description: "Know when it's safe to drive"
                )
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                
                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Screen 3: User Input
struct UserInputScreen: View {
    @Binding var sexIndex: Int
    @Binding var weightKg: Double
    @Binding var countryIndex: Int
    let onNext: () -> Void
    
    private let sexes = ["Male", "Female", "Other"]
    private let countries = [
        "United States", "United Kingdom", "Canada", "Australia",
        "Germany", "France", "Spain", "Italy", "Portugal", "Brazil",
        "Japan", "South Korea", "India", "Mexico", "Netherlands",
        "Belgium", "Sweden", "Norway", "Denmark", "Ireland", "Other"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.accentColor)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 12) {
                        Text("Your Profile")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        Text("Enter your details for accurate estimates.")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Sex")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Picker("Sex", selection: $sexIndex) {
                                ForEach(0..<sexes.count, id: \.self) { index in
                                    Text(sexes[index]).tag(index)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(16)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(14)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Weight")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(Int(weightKg)) kg")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            
                            Slider(value: $weightKg, in: 40...150, step: 1)
                                .accentColor(.accentColor)
                            
                            HStack {
                                Text("40 kg")
                                    .font(.system(size: 11, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("150 kg")
                                    .font(.system(size: 11, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(16)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(14)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Country")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Menu {
                                ForEach(0..<countries.count, id: \.self) { index in
                                    Button(action: {
                                        countryIndex = index
                                    }) {
                                        HStack {
                                            Text(countries[index])
                                            if countryIndex == index {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(countries[countryIndex])
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(14)
                                .background(Color(UIColor.tertiarySystemBackground))
                                .cornerRadius(10)
                            }
                        }
                        .padding(16)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            
            VStack(spacing: 0) {
                Divider()
                    .padding(.bottom, 12)
                
                Button(action: onNext) {
                    Text("Next")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}

// MARK: - Screen 4: Drinking Frequency
struct DrinkingFrequencyScreen: View {
    @Binding var drinkingFrequencyIndex: Int
    let onComplete: () -> Void
    
    private let frequencies = ["Rarely", "Weekly", "Often"]
    private let frequencyDescriptions = [
        "A few times per year or less",
        "One or more times per week",
        "Multiple times per week or daily"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "calendar")
                            .font(.system(size: 44))
                            .foregroundColor(.accentColor)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 12) {
                        Text("Drinking Habits")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        Text("How often do you typically drink alcohol?")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    
                    VStack(spacing: 16) {
                        ForEach(0..<frequencies.count, id: \.self) { index in
                            Button(action: {
                                drinkingFrequencyIndex = index
                            }) {
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(frequencies[index])
                                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Text(frequencyDescriptions[index])
                                            .font(.system(size: 14, weight: .regular, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if drinkingFrequencyIndex == index {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.accentColor)
                                    } else {
                                        Image(systemName: "circle")
                                            .font(.system(size: 24))
                                            .foregroundColor(.secondary.opacity(0.3))
                                    }
                                }
                                .padding(16)
                                .background(
                                    drinkingFrequencyIndex == index ?
                                    Color.accentColor.opacity(0.1) :
                                    Color(UIColor.secondarySystemBackground)
                                )
                                .cornerRadius(14)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Text("Privacy & Estimates")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Your information is stored locally on your device. All BAC calculations use the Widmark formula with an average metabolism rate of 0.015% per hour. Time elapsed is calculated from when you log each drink. Results are estimates and do not replace a real breathalyzer test. Never drive if you feel impaired.")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            
            VStack(spacing: 0) {
                Divider()
                    .padding(.bottom, 12)
                
                Button(action: onComplete) {
                    Text("Get Started")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(
            hasCompletedOnboarding: .constant(false),
            userSex: .constant(0),
            userWeight: .constant(75),
            userCountry: .constant(0),
            userDrinkingFrequency: .constant(1)
        )
    }
}
