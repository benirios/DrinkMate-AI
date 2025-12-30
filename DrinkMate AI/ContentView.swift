//
//  ContentView.swift
//  DrinkMate AI
//
//  Created by Benício Rios on 29/12/2025.
//

import SwiftUI

struct ContentView: View {
    // Initialize with onboarding values
    init(initialSex: Int = 0, initialWeight: Double = 75) {
        _sexIndex = State(initialValue: initialSex)
        _weightKg = State(initialValue: initialWeight)
    }
    
    // UI State
    @State private var selectedTab: TabSelection = .home
    @State private var showingAddDrink = false
    @State private var editingDrink: DrinkSession? = nil
    @State private var currentRisk: DrinkingSessionRisk = .safe
    
    // Inputs
    @State private var weightKg: Double
    @State private var sexIndex: Int
    @State private var drinkType: DrinkType = .beer
    @State private var drinkCount: Int = 2
    
    // Outputs
    @State private var bac: Double = 0.0
    @State private var timeUntilSafeHours: Double = 0.0
    @State private var drinkSessions: [DrinkSession] = []
    @State private var recentDrinks: [RecentDrink] = []
    
    // Constants
    private let sexes = ["Male", "Female", "Other"]
    private let eliminationRatePerHour: Double = 0.015
    private let safeThresholdBAC: Double = 0.05
    
    var body: some View {
        ZStack {
            // Light background
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            if selectedTab == .settings {
                // MARK: - Settings Screen
                SettingsView()
            } else {
                // MARK: - Home Screen
                VStack(spacing: 0) {
                    // MARK: - Header
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 20, weight: .semibold))
                            
                            Text("DrinkMate AI")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        // Notification icon
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    
                    // MARK: - Scrollable Content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // MARK: - Main Risk Card
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(formatTimeAsHoursMinutes(timeUntilSafeHours))
                                        .font(.system(size: 56, weight: .bold, design: .default))
                                        .foregroundColor(.primary)
                                    
                                    Text("Time safe")
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Circular progress ring
                                ZStack {
                                    Circle()
                                        .stroke(Color.black.opacity(0.1), lineWidth: 6)
                                        .frame(width: 70, height: 70)
                                    
                                    Circle()
                                        .trim(from: 0, to: min(timeUntilSafeHours / 8.0, 1.0))
                                        .stroke(Color(red: 0.85, green: 0.4, blue: 0.4), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                        .frame(width: 70, height: 70)
                                        .rotationEffect(.degrees(-90))
                                    
                                    Circle()
                                        .fill(Color(red: 0.85, green: 0.4, blue: 0.4))
                                        .frame(width: 14, height: 14)
                                }
                            }
                            .padding(24)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                            
                            // MARK: - Horizontal Metrics Cards
                            HStack(spacing: 12) {
                                // BAC level
                                MetricCard(
                                    value: String(format: "%.3f", bac),
                                    label: "BAC level",
                                    color: ringColor(for: bac),
                                    progress: min(bac / 0.15, 1.0)
                                )
                                
                                // Drinks count
                                MetricCard(
                                    value: "\(drinkSessions.count)",
                                    label: "Drinks",
                                    color: Color(red: 0.9, green: 0.6, blue: 0.3),
                                    progress: Double(drinkSessions.count) / 10.0
                                )
                                
                                // Risk level
                                MetricCard(
                                    value: statusText(for: bac),
                                    label: "Risk",
                                    color: Color(red: 0.5, green: 0.6, blue: 0.85),
                                    progress: min(bac / 0.15, 1.0)
                                )
                            }
                            
                            // MARK: - Recent Sessions
                            if !recentDrinks.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Recent sessions")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    ForEach(recentDrinks) { drink in
                                        RecentSessionCard(drink: drink)
                                            .contentShape(Rectangle())
                                            .contextMenu {
                                                Button {
                                                    // Find the corresponding DrinkSession
                                                    if let session = drinkSessions.first(where: { $0.id == drink.id }) {
                                                        editingDrink = session
                                                        showingAddDrink = true
                                                    }
                                                } label: {
                                                    Label("Edit Drink", systemImage: "pencil")
                                                }
                                                
                                                Button(role: .destructive) {
                                                    // Delete drink and recalculate
                                                    deleteDrink(withId: drink.id)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                                .padding(.top, 4)
                            }
                            
                            // Bottom spacing for nav bar
                            Color.clear.frame(height: 80)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
            }
            
            // MARK: - Bottom Navigation Bar
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    TabButton(
                        icon: "house.fill",
                        title: "Home",
                        isSelected: selectedTab == .home,
                        action: { selectedTab = .home }
                    )
                    
                    TabButton(
                        icon: "gearshape.fill",
                        title: "Settings",
                        isSelected: selectedTab == .settings,
                        action: { selectedTab = .settings }
                    )
                }
                .frame(height: 60)
                .background(
                    Color(UIColor.secondarySystemBackground)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -2)
                )
            }
            .ignoresSafeArea(edges: .bottom)
            
            // MARK: - Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        editingDrink = nil // Clear editing state when adding new drink
                        showingAddDrink = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.primary)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 80)
                }
            }
        }
        .sheet(isPresented: $showingAddDrink) {
            AddDrinkView(
                weightKg: $weightKg,
                sexIndex: $sexIndex,
                bac: $bac,
                timeUntilSafeHours: $timeUntilSafeHours,
                onDrinkAdded: handleDrinkAdded,
                editingSession: editingDrink
            )
        }
    }
    
    // MARK: - Calculation
    private func sexDistributionFactor(for index: Int) -> Double {
        switch index {
        case 0: return 0.68
        case 1: return 0.55
        default: return 0.62
        }
    }
    
    private func statusText(for bac: Double) -> String {
        if bac < 0.02 { return "Low" }
        if bac < 0.05 { return "Mod" }
        return "High"
    }
    
    private func ringColor(for bac: Double) -> Color {
        if bac < 0.02 { return .green }
        if bac < 0.05 { return .orange }
        return .red
    }
    
    private func formatTimeAsHoursMinutes(_ hours: Double) -> String {
        if hours <= 0 {
            return "00:00"
        }
        let totalMinutes = Int(hours * 60)
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        return String(format: "%02d:%02d", h, m)
    }
    
    private func handleDrinkAdded(_ session: DrinkSession) {
        // Check if we're editing an existing session
        if let existingIndex = drinkSessions.firstIndex(where: { $0.id == session.id }) {
            // Update existing session
            drinkSessions[existingIndex] = session
        } else {
            // Add new session
            drinkSessions.insert(session, at: 0)
            
            // Keep only last 10 drinks
            if drinkSessions.count > 10 {
                drinkSessions.removeLast()
            }
        }
        
        // Recalculate total BAC and time
        recalculateBAC()
    }
    
    private func recalculateBAC() {
        // Sum up all drink sessions
        var totalBAC: Double = 0.0
        
        for session in drinkSessions {
            totalBAC += session.bac
        }
        
        bac = totalBAC
        
        // Recalculate time until safe
        if bac <= safeThresholdBAC {
            timeUntilSafeHours = 0
        } else {
            timeUntilSafeHours = (bac - safeThresholdBAC) / eliminationRatePerHour
        }
        
        // Update all recent drinks with new calculated values
        recentDrinks.removeAll()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        
        for session in drinkSessions {
            let timeString = formatter.string(from: session.timestamp)
            let drinkDescription = session.isDouble ? "\(String(format: "%.1f", session.amount)) × \(session.name) (Double)" : "\(String(format: "%.1f", session.amount)) × \(session.name)"
            
            let newRecentDrink = RecentDrink(
                id: session.id,
                name: session.name,
                time: timeString,
                bac: session.bac,
                drinks: drinkDescription,
                riskLevel: statusText(for: bac),
                duration: String(format: "%.1fh", timeUntilSafeHours),
                thumbnail: session.emoji
            )
            
            recentDrinks.append(newRecentDrink)
        }
    }
    
    private func deleteDrink(withId id: UUID) {
        // Remove from both arrays
        drinkSessions.removeAll(where: { $0.id == id })
        recentDrinks.removeAll(where: { $0.id == id })
        
        // Recalculate BAC and time
        recalculateBAC()
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let value: String
    let label: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.secondary)
            
            // Progress circle
            ZStack {
                Circle()
                    .stroke(color.opacity(0.25), lineWidth: 4)
                    .frame(width: 36, height: 36)
                
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(-90))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

struct RecentSessionCard: View {
    let drink: RecentDrink
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(thumbnailColor(for: drink.thumbnail))
                    .frame(width: 70, height: 70)
                
                Text(drink.thumbnail)
                    .font(.system(size: 36))
            }
            
            // Details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(drink.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(drink.time)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Text("BAC \(String(format: "%.3f", drink.bac))")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.primary)
                
                HStack(spacing: 10) {
                    InfoTag(icon: "🍺", value: drink.drinks, color: Color(red: 0.85, green: 0.4, blue: 0.4))
                    InfoTag(icon: "⏱️", value: drink.duration, color: Color(red: 0.9, green: 0.6, blue: 0.3))
                    InfoTag(icon: "📊", value: drink.riskLevel, color: Color(red: 0.5, green: 0.6, blue: 0.85))
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
    
    private func thumbnailColor(for emoji: String) -> Color {
        switch emoji {
        case "🍺": return Color.orange.opacity(0.2)
        case "🍷": return Color.purple.opacity(0.2)
        case "🥃": return Color.brown.opacity(0.2)
        case "🍸": return Color.blue.opacity(0.2)
        case "🍹": return Color.pink.opacity(0.2)
        default: return Color.gray.opacity(0.2)
        }
    }
}

struct InfoTag: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 10))
            
            Text(value)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .cornerRadius(8)
    }
}

struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Supporting Types

enum DaySelection {
    case today, yesterday
}

enum TabSelection {
    case home, analytics, settings
}

struct RecentDrink: Identifiable {
    let id: UUID
    let name: String
    let time: String
    let bac: Double
    let drinks: String
    let riskLevel: String
    let duration: String
    let thumbnail: String
    
    init(id: UUID = UUID(), name: String, time: String, bac: Double, drinks: String, riskLevel: String, duration: String, thumbnail: String) {
        self.id = id
        self.name = name
        self.time = time
        self.bac = bac
        self.drinks = drinks
        self.riskLevel = riskLevel
        self.duration = duration
        self.thumbnail = thumbnail
    }
}

struct DrinkSession: Identifiable {
    let id: UUID
    let name: String
    let emoji: String
    let amount: Double
    let isDouble: Bool
    let bac: Double
    let timestamp: Date
    
    var drinkName: String { name }
    var isDoubleShot: Bool { isDouble }
    
    init(id: UUID = UUID(), name: String, emoji: String, amount: Double, isDouble: Bool, bac: Double, timestamp: Date) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.amount = amount
        self.isDouble = isDouble
        self.bac = bac
        self.timestamp = timestamp
    }
}

enum DrinkType: CaseIterable {
    case beer, wine, spirit
    
    var displayName: String {
        switch self {
        case .beer: return "Beer"
        case .wine: return "Wine"
        case .spirit: return "Spirit"
        }
    }
    
    var emoji: String {
        switch self {
        case .beer: return "🍺"
        case .wine: return "🍷"
        case .spirit: return "🥃"
        }
    }
    
    var volumeML: Double {
        switch self {
        case .beer: return 330
        case .wine: return 150
        case .spirit: return 44
        }
    }
    
    var abv: Double {
        switch self {
        case .beer: return 0.05
        case .wine: return 0.12
        case .spirit: return 0.40
        }
    }
    
    var alcoholGrams: Double {
        return volumeML * abv * 0.789
    }
    
    var detailText: String {
        String(format: "%d ml · %.0f%% ABV · %.0f g alcohol", Int(volumeML), abv * 100, alcoholGrams)
    }
}

#Preview {
    ContentView()
}
