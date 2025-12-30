//
//  DrinkMate_AIApp.swift
//  DrinkMate AI
//
//  Created by Benício Rios on 29/12/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    // Keep seeder as property to prevent deallocation during async operations
    private var seeder: FirestoreSeeder?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("🚀 [APP] Application launching...")
        
        // Initialize Firebase
        FirebaseApp.configure()
        print("✅ [APP] Firebase configured")
        
        // Verify Firebase configuration
        if let app = FirebaseApp.app() {
            print("📱 [APP] Firebase app name: \(app.name)")
            print("🆔 [APP] Project ID: \(app.options.projectID ?? "unknown")")
        } else {
            print("❌ [APP] Firebase app is nil!")
        }
        
        // Force reset seeding for testing
        print("🔄 [APP] Resetting seeding status...")
        UserDefaults.standard.removeObject(forKey: "hasSeededFirestore")
        
        // Create seeder and keep it alive
        print("🌱 [APP] Creating and retaining seeder...")
        seeder = FirestoreSeeder()
        
        // Delete existing drinks FIRST, then seed new ones
        print("🗑️ [APP] Deleting old drinks before re-seeding...")
        let db = Firestore.firestore()
        
        db.collection("drinks").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("⚠️ [APP] Error fetching drinks to delete: \(error.localizedDescription)")
                print("🌱 [APP] Proceeding with seed anyway...")
                self?.seeder?.seedDrinksIfNeeded()
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("📭 [APP] No existing drinks to delete")
                print("🌱 [APP] Starting fresh seed...")
                self?.seeder?.seedDrinksIfNeeded()
                return
            }
            
            print("📊 [APP] Found \(documents.count) drinks to delete")
            
            let batch = db.batch()
            for document in documents {
                batch.deleteDocument(document.reference)
            }
            
            batch.commit { [weak self] error in
                if let error = error {
                    print("❌ [APP] Deletion failed: \(error.localizedDescription)")
                } else {
                    print("✅ [APP] Successfully deleted \(documents.count) drinks")
                }
                
                print("🌱 [APP] Now starting seed with new drinks...")
                self?.seeder?.seedDrinksIfNeeded()
            }
        }
        
        return true
    }
}

@main
struct DrinkMate_AIApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("userSex") private var userSex = 0
    @AppStorage("userWeight") private var userWeight = 75.0
    @AppStorage("userCountry") private var userCountry = 0
    @AppStorage("userDrinkingFrequency") private var userDrinkingFrequency = 1 // 0=Rarely, 1=Weekly, 2=Often
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView(initialSex: userSex, initialWeight: userWeight)
            } else {
                OnboardingView(
                    hasCompletedOnboarding: $hasCompletedOnboarding,
                    userSex: $userSex,
                    userWeight: $userWeight,
                    userCountry: $userCountry,
                    userDrinkingFrequency: $userDrinkingFrequency
                )
            }
        }
    }
}
