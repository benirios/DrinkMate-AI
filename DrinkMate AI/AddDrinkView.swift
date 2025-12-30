//
//  AddDrinkView.swift
//  DrinkMate AI
//
//  Created by Benício Rios on 29/12/2025.
//

import SwiftUI
import FirebaseFirestore

struct AddDrinkView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var weightKg: Double
    @Binding var sexIndex: Int
    @Binding var bac: Double
    @Binding var timeUntilSafeHours: Double
    var onDrinkAdded: (DrinkSession) -> Void
    
    var editingSession: DrinkSession? = nil
    @State private var searchText = ""
    @State private var selectedDrink: Drink?
    @State private var isDoubleShot = false
    @State private var drinkAmount: Double = 1.0
    @State private var availableDrinks: [Drink] = []
    @State private var isLoadingDrinks = true
    
    private let eliminationRatePerHour: Double = 0.015
    private let db = Firestore.firestore()
    private let safeThresholdBAC: Double = 0.05
    
    
    // Filtered drinks based on search
    private var filteredDrinks: [Drink] {
        if searchText.isEmpty {
            return availableDrinks
        }
        return FuzzySearchEngine.findBestMatches(query: searchText, items: availableDrinks, keyPath: \.name, threshold: 0.4)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search drinks...", text: $searchText)
                            .textFieldStyle(.plain)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
                    if selectedDrink == nil {
                        // Drink list
                        ScrollView {
                            VStack(spacing: 12) {
                                if isLoadingDrinks {
                                    // Loading indicator
                                    VStack(spacing: 16) {
                                        ProgressView()
                                            .scaleEffect(1.5)
                                        
                                        Text("Loading drinks from Firebase...")
                                            .font(.system(size: 15))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 100)
                                } else {
                                    ForEach(filteredDrinks) { drink in
                                        DrinkRow(drink: drink) {
                                            selectedDrink = drink
                                            searchText = ""
                                        }
                                    }
                                    
                                    if filteredDrinks.isEmpty && !searchText.isEmpty {
                                        VStack(spacing: 12) {
                                            Image(systemName: "magnifyingglass")
                                                .font(.system(size: 48))
                                                .foregroundColor(.secondary.opacity(0.5))
                                            
                                            Text("No drinks found")
                                                .font(.system(size: 17, weight: .medium))
                                                .foregroundColor(.secondary)
                                            
                                            Text("Try a different search")
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.top, 60)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    } else {
                        // Drink details and options
                        ScrollView {
                            VStack(spacing: 20) {
                                // Selected drink card
                                VStack(spacing: 16) {
                                    Text(selectedDrink!.emoji)
                                        .font(.system(size: 60))
                                    
                                    Text(selectedDrink!.name)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    Text("\(Int(selectedDrink!.volumeML))ml · \(Int(selectedDrink!.abv * 100))% ABV")
                                        .font(.system(size: 15))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(24)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(20)
                                
                                // Double shot toggle
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Double Shot")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Double the alcohol content")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $isDoubleShot)
                                        .labelsHidden()
                                }
                                .padding(20)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(16)
                                
                                // Amount control
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Amount")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 20) {
                                        Button(action: {
                                            if drinkAmount > 0.5 {
                                                drinkAmount -= 0.5
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(drinkAmount > 0.5 ? .accentColor : .gray.opacity(0.3))
                                        }
                                        .disabled(drinkAmount <= 0.5)
                                        
                                        VStack(spacing: 4) {
                                            Text(String(format: "%.1f", drinkAmount))
                                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                                .foregroundColor(.primary)
                                            
                                            Text(drinkAmount == 1 ? "drink" : "drinks")
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(minWidth: 120)
                                        
                                        Button(action: {
                                            if drinkAmount < 10 {
                                                drinkAmount += 0.5
                                            }
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(drinkAmount < 10 ? .accentColor : .gray.opacity(0.3))
                                        }
                                        .disabled(drinkAmount >= 10)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(20)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(16)
                                
                                // Add button
                                Button(action: addDrink) {
                                    Text("Add Drink")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 18)
                                        .background(Color.accentColor)
                                        .cornerRadius(16)
                                        .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 4)
                                }
                                .padding(.top, 8)
                                
                                // Change drink button
                                Button(action: {
                                    selectedDrink = nil
                                    isDoubleShot = false
                                    drinkAmount = 1.0
                                }) {
                                    Text("Choose Different Drink")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 32)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Add Drink")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let session = editingSession {
                selectedDrink = availableDrinks.first { $0.name == session.name }
                isDoubleShot = session.isDouble
                drinkAmount = session.amount
            }
            fetchDrinksFromFirebase()
        }
    }
    

    // MARK: - Firebase Fetch
    
    private func fetchDrinksFromFirebase() {
        print("🔍 [ADD_DRINK] Fetching drinks from Firebase...")
        isLoadingDrinks = true
        
        db.collection("drinks").order(by: "name").getDocuments { snapshot, error in
            if let error = error {
                print("❌ [ADD_DRINK] Error: \(error.localizedDescription)")
                self.isLoadingDrinks = false
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("⚠️ [ADD_DRINK] No drinks found")
                self.isLoadingDrinks = false
                return
            }
            
            print("✅ [ADD_DRINK] Fetched \(documents.count) drinks")
            
            var drinks: [Drink] = []
            
            for document in documents {
                let data = document.data()
                
                guard let name = data["name"] as? String,
                      let volume = data["volume"] as? Double else {
                    continue
                }
                
                let alcoholPercentage = data["alcoholPercentage"] as? Double ?? 0.0
                let abv = alcoholPercentage / 100.0
                
                let emoji = self.getEmojiForDrink(name: name)
                let category = self.getCategoryForDrink(name: name)
                
                let drink = Drink(
                    name: name,
                    emoji: emoji,
                    volumeML: volume,
                    abv: abv,
                    category: category
                )
                
                drinks.append(drink)
            }
            
            self.availableDrinks = drinks
            self.isLoadingDrinks = false
            
            print("✅ [ADD_DRINK] Loaded \(drinks.count) drinks")
        }
    }
    
    private func getEmojiForDrink(name: String) -> String {
        let lowercased = name.lowercased()
        
        if lowercased.contains("beer") || lowercased.contains("ale") || 
           lowercased.contains("lager") || lowercased.contains("stout") {
            return "🍺"
        } else if lowercased.contains("wine") || lowercased.contains("sangria") || 
                  lowercased.contains("prosecco") || lowercased.contains("champagne") {
            return "🍷"
        } else if lowercased.contains("vodka") || lowercased.contains("gin") || 
                  lowercased.contains("rum") || lowercased.contains("tequila") ||
                  lowercased.contains("whiskey") || lowercased.contains("bourbon") {
            return "🥃"
        } else if lowercased.contains("martini") || lowercased.contains("cocktail") ||
                  lowercased.contains("mojito") || lowercased.contains("margarita") {
            return "🍸"
        } else if lowercased.contains("shot") {
            return "🥃"
        } else {
            return "🍹"
        }
    }
    
    private func getCategoryForDrink(name: String) -> String {
        let lowercased = name.lowercased()
        
        if lowercased.contains("beer") || lowercased.contains("ale") || 
           lowercased.contains("lager") || lowercased.contains("stout") {
            return "Beer"
        } else if lowercased.contains("wine") || lowercased.contains("sangria") || 
                  lowercased.contains("prosecco") || lowercased.contains("champagne") {
            return "Wine"
        } else if lowercased.contains("shot") {
            return "Shot"
        } else {
            return "Cocktail"
        }
    }
    private func addDrink() {
        guard let drink = selectedDrink else { return }
        
        // Calculate alcohol content
        let multiplier = isDoubleShot ? 2.0 : 1.0
        let totalAlcoholGrams = drinkAmount * drink.volumeML * drink.abv * 0.789 * multiplier
        
        // Calculate new BAC
        let weightGrams = weightKg * 1000
        let r = sexDistributionFactor(for: sexIndex)
        let newBACPercent = (totalAlcoholGrams / (weightGrams * r)) * 100
        
        // Add to existing BAC
        bac = max(0, bac + newBACPercent)
        
        // Recalculate time until safe
        if bac <= safeThresholdBAC {
            timeUntilSafeHours = 0
        } else {
            timeUntilSafeHours = (bac - safeThresholdBAC) / eliminationRatePerHour
        }
        
        // Create or update drink session
        let session: DrinkSession
        if let editing = editingSession {
            // Update existing session, preserving ID and timestamp
            session = DrinkSession(
                id: editing.id,
                name: drink.name,
                emoji: drink.emoji,
                amount: drinkAmount,
                isDouble: isDoubleShot,
                bac: newBACPercent,
                timestamp: editing.timestamp
            )
        } else {
            // Create new session
            session = DrinkSession(
                name: drink.name,
                emoji: drink.emoji,
                amount: drinkAmount,
                isDouble: isDoubleShot,
                bac: newBACPercent,
                timestamp: Date()
            )
        }
        
        // Notify parent
        onDrinkAdded(session)
        
        // Dismiss
        dismiss()
    }
    
    private func sexDistributionFactor(for index: Int) -> Double {
        switch index {
        case 0: return 0.68
        case 1: return 0.55
        default: return 0.62
        }
    }
}

// MARK: - Supporting Views

struct DrinkRow: View {
    let drink: Drink
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Text(drink.emoji)
                    .font(.system(size: 36))
                    .frame(width: 56, height: 56)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(drink.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("\(Int(drink.volumeML))ml · \(Int(drink.abv * 100))% ABV · \(drink.category)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Data Models

struct Drink: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let volumeML: Double
    let abv: Double
    let category: String
}


#Preview {
    AddDrinkView(
        weightKg: .constant(75),
        sexIndex: .constant(0),
        bac: .constant(0.026),
        timeUntilSafeHours: .constant(2.5),
        onDrinkAdded: { _ in }
    )
}
