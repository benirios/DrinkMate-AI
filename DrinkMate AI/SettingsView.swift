//
//  SettingsView.swift
//  DrinkMate AI
//
//  Created by Benício Rios on 30/12/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("userSex") private var userSex: Int = 0
    @AppStorage("userWeight") private var userWeight: Double = 75.0
    @AppStorage("userDrinkingFrequency") private var userDrinkingFrequency: Int = 1
    
    @State private var localSex: Int = 0
    @State private var localWeight: Double = 75.0
    @State private var localFrequency: Int = 1
    
    private let sexes = ["Male", "Female", "Other"]
    private let frequencies = ["Rarely", "Weekly", "Often"]
    private let frequencyDescriptions = [
        "A few times per year or less",
        "One or more times per week",
        "Multiple times per week or daily"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Text("Settings")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 16)
            
            // MARK: - Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // User Profile Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Profile")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            // Sex Picker
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Sex")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                Picker("Sex", selection: $localSex) {
                                    ForEach(0..<sexes.count, id: \.self) { index in
                                        Text(sexes[index]).tag(index)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .onChange(of: localSex) { newValue in
                                    userSex = newValue
                                }
                            }
                            .padding(16)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(14)
                            
                            // Weight Slider
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Weight")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(localWeight)) kg")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                }
                                
                                Slider(value: $localWeight, in: 40...150, step: 1)
                                    .accentColor(.accentColor)
                                    .onChange(of: localWeight) { newValue in
                                        userWeight = newValue
                                    }
                                
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
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Drinking Frequency Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Drinking Habits")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(0..<frequencies.count, id: \.self) { index in
                                Button(action: {
                                    localFrequency = index
                                    userDrinkingFrequency = index
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
                                        
                                        if localFrequency == index {
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
                                        localFrequency == index ?
                                        Color.accentColor.opacity(0.1) :
                                        Color(UIColor.secondarySystemBackground)
                                    )
                                    .cornerRadius(14)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Disclaimer
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Text("Important Information")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Your information is stored locally on your device and used only to estimate blood alcohol content and time until sober using the Widmark formula. These are estimates only and do not replace a real breathalyzer test. Never drive if you feel impaired.")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .padding(.top, 8)
            }
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            // Pre-fill with saved values
            localSex = userSex
            localWeight = userWeight
            localFrequency = userDrinkingFrequency
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
