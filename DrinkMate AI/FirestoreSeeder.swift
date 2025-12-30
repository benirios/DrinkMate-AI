//
//  FirestoreSeeder.swift
//  DrinkMate AI
//
//  Created by Benício Rios on 30/12/2025.
//

import Foundation
import FirebaseFirestore

// MARK: - Drink Model for JSON Decoding

struct DrinkData: Codable {
    let name: String
    let volume: Double
    let alcoholPercentage: Double?
}

struct DrinksJSON: Codable {
    let drinks: [DrinkData]
}

// MARK: - Firestore Seeder

class FirestoreSeeder {
    private let db = Firestore.firestore()
    private let userDefaults = UserDefaults.standard
    private let seedKey = "hasSeededFirestore"
    
    /// Check if Firestore has been seeded and seed if necessary
    func seedDrinksIfNeeded() {
        print("🔍 [SEEDER] Starting seeding check...")
        
        // Check if already seeded
        let hasSeeded = userDefaults.bool(forKey: seedKey)
        print("📊 [SEEDER] UserDefaults '\(seedKey)': \(hasSeeded)")
        
        if hasSeeded {
            print("✅ [SEEDER] Already seeded, skipping")
            return
        }
        
        // Check if Firestore collection is empty
        print("🔍 [SEEDER] Checking Firestore drinks collection...")
        checkAndSeedFirestore()
    }
    
    private func checkAndSeedFirestore() {
        print("📡 [SEEDER] Querying Firestore...")
        
        db.collection("drinks").limit(to: 1).getDocuments { snapshot, error in
            print("📬 [SEEDER] Firestore callback received")
            
            if let error = error {
                print("❌ [SEEDER] Firestore error: \(error.localizedDescription)")
                return
            }
            
            let isEmpty = snapshot?.documents.isEmpty ?? true
            print("📊 [SEEDER] isEmpty: \(isEmpty), count: \(snapshot?.documents.count ?? 0)")
            
            // If collection is empty, seed it
            if isEmpty {
                print("📦 [SEEDER] Starting seed...")
                self.seedDrinksFromJSON()
            } else {
                print("✅ [SEEDER] Has drinks, marking seeded")
                self.userDefaults.set(true, forKey: self.seedKey)
            }
        }
    }
    
    private func seedDrinksFromJSON() {
        print("📂 [SEEDER] Looking for drinks.json...")
        
        // Load JSON file from bundle
        guard let url = Bundle.main.url(forResource: "drinks", withExtension: "json") else {
            print("❌ [SEEDER] drinks.json NOT FOUND")
            return
        }
        
        print("✅ [SEEDER] Found at: \(url.path)")
        
        do {
            // Load and decode JSON
            let data = try Data(contentsOf: url)
            print("📄 [SEEDER] Loaded \(data.count) bytes")
            
            let decoder = JSONDecoder()
            let drinksJSON = try decoder.decode(DrinksJSON.self, from: data)
            
            print("✅ [SEEDER] Decoded \(drinksJSON.drinks.count) drinks")
            
            // Seed Firestore with drinks
            seedDrinksToFirestore(drinksJSON.drinks)
            
        } catch {
            print("❌ [SEEDER] Error: \(error)")
        }
    }
    
    private func seedDrinksToFirestore(_ drinks: [DrinkData]) {
        print("🚀 [SEEDER] Batch writing \(drinks.count) drinks...")
        
        let batch = db.batch()
        
        for drink in drinks {
            let docRef = db.collection("drinks").document()
            
            var drinkDict: [String: Any] = [
                "name": drink.name,
                "volume": drink.volume,
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            // Add alcoholPercentage only if it exists
            if let alcoholPercentage = drink.alcoholPercentage {
                drinkDict["alcoholPercentage"] = alcoholPercentage
            }
            
            batch.setData(drinkDict, forDocument: docRef)
        }
        
        print("💾 [SEEDER] Committing batch...")
        
        // Commit batch write
        batch.commit { error in
            if let error = error {
                print("❌ [SEEDER] Batch failed: \(error)")
            } else {
                print("✅ [SEEDER] SUCCESS! Seeded \(drinks.count) drinks")
                self.userDefaults.set(true, forKey: self.seedKey)
            }
        }
    }
    
    /// Force re-seed (for testing purposes)
    func forceSeed() {
        userDefaults.set(false, forKey: seedKey)
        seedDrinksFromJSON()
    }
    
    /// Reset seed status
    func resetSeedStatus() {
        userDefaults.set(false, forKey: seedKey)
        print("🔄 Reset seed status - will seed on next launch")
    }
}
