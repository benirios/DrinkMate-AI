//
//  AIHelpers.swift
//  DrinkMate AI
//
//  Created by Benício Rios on 29/12/2025.
//

import Foundation

// MARK: - Fuzzy Search using Levenshtein Distance

struct FuzzySearchEngine {
    /// Calculate Levenshtein distance between two strings (edit distance)
    static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1 = s1.lowercased()
        let s2 = s2.lowercased()
        
        let empty = [Int](repeating: 0, count: s2.count)
        var last = [Int](0...s2.count)
        
        for (i, char1) in s1.enumerated() {
            var cur = [i + 1] + empty
            for (j, char2) in s2.enumerated() {
                cur[j + 1] = char1 == char2 ? last[j] : min(last[j], last[j + 1], cur[j]) + 1
            }
            last = cur
        }
        
        return last.last ?? 0
    }
    
    /// Calculate similarity score (0.0 to 1.0, higher is better)
    static func similarityScore(_ s1: String, _ s2: String) -> Double {
        let distance = levenshteinDistance(s1, s2)
        let maxLength = max(s1.count, s2.count)
        
        guard maxLength > 0 else { return 1.0 }
        
        return 1.0 - (Double(distance) / Double(maxLength))
    }
    
    /// Find best matches for a search query
    static func findBestMatches<T>(
        query: String,
        items: [T],
        keyPath: KeyPath<T, String>,
        threshold: Double = 0.4
    ) -> [T] {
        guard !query.isEmpty else { return items }
        
        let scoredItems = items.map { item -> (item: T, score: Double) in
            let itemName = item[keyPath: keyPath]
            
            // Check for substring match (higher priority)
            if itemName.lowercased().contains(query.lowercased()) {
                return (item, 1.0)
            }
            
            // Calculate fuzzy match score
            let score = similarityScore(query, itemName)
            return (item, score)
        }
        
        // Filter and sort by score
        return scoredItems
            .filter { $0.score >= threshold }
            .sorted { $0.score > $1.score }
            .map { $0.item }
    }
}

// MARK: - Risk Pattern Recognition

enum DrinkingSessionRisk: String {
    case safe = "Safe"
    case caution = "Caution"
    case risky = "Risky"
    
    var color: (red: Double, green: Double, blue: Double) {
        switch self {
        case .safe: return (0.3, 0.8, 0.3)      // Green
        case .caution: return (1.0, 0.7, 0.0)   // Orange
        case .risky: return (0.95, 0.3, 0.3)    // Red
        }
    }
    
    var icon: String {
        switch self {
        case .safe: return "checkmark.shield.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .risky: return "exclamationmark.octagon.fill"
        }
    }
    
    var message: String {
        switch self {
        case .safe: return "Pace looks good"
        case .caution: return "Consider slowing down"
        case .risky: return "High-risk pattern detected"
        }
    }
}

struct RiskPatternAnalyzer {
    /// Analyze drinking session and classify risk level
    static func analyzeSession(
        sessions: [DrinkSession],
        currentBAC: Double,
        timeWindow: TimeInterval = 3600 * 3 // Last 3 hours
    ) -> DrinkingSessionRisk {
        guard !sessions.isEmpty else { return .safe }
        
        let now = Date()
        let recentSessions = sessions.filter { 
            now.timeIntervalSince($0.timestamp) <= timeWindow 
        }
        
        guard !recentSessions.isEmpty else { return .safe }
        
        var riskScore: Double = 0.0
        
        // Factor 1: Current BAC level (0-40 points)
        if currentBAC >= 0.08 {
            riskScore += 40
        } else if currentBAC >= 0.05 {
            riskScore += 25
        } else if currentBAC >= 0.03 {
            riskScore += 10
        }
        
        // Factor 2: Number of drinks in time window (0-25 points)
        let drinkCount = recentSessions.count
        if drinkCount >= 5 {
            riskScore += 25
        } else if drinkCount >= 3 {
            riskScore += 15
        } else if drinkCount >= 2 {
            riskScore += 5
        }
        
        // Factor 3: Drinking pace - time between drinks (0-20 points)
        if recentSessions.count >= 2 {
            let sortedSessions = recentSessions.sorted { $0.timestamp > $1.timestamp }
            var totalInterval: TimeInterval = 0
            
            for i in 0..<(sortedSessions.count - 1) {
                let interval = sortedSessions[i].timestamp.timeIntervalSince(sortedSessions[i + 1].timestamp)
                totalInterval += interval
            }
            
            let averageInterval = totalInterval / Double(sortedSessions.count - 1)
            let minutesBetween = averageInterval / 60
            
            if minutesBetween < 15 {
                riskScore += 20 // Very fast pace
            } else if minutesBetween < 30 {
                riskScore += 10 // Fast pace
            } else if minutesBetween < 45 {
                riskScore += 5  // Moderate pace
            }
        }
        
        // Factor 4: Double shots (0-10 points)
        let doubleCount = recentSessions.filter { $0.isDouble }.count
        if doubleCount >= 2 {
            riskScore += 10
        } else if doubleCount >= 1 {
            riskScore += 5
        }
        
        // Factor 5: High-alcohol drinks (0-5 points)
        let highAlcoholDrinks = ["Martini", "Vodka Red Bull", "Whiskey", "Vodka", "Rum", "Tequila"]
        let highAlcoholCount = recentSessions.filter { session in
            highAlcoholDrinks.contains(where: { session.name.contains($0) })
        }.count
        
        if highAlcoholCount >= 2 {
            riskScore += 5
        }
        
        // Classify based on total risk score (0-100 scale)
        if riskScore >= 50 {
            return .risky
        } else if riskScore >= 25 {
            return .caution
        } else {
            return .safe
        }
    }
    
    /// Get detailed insights about the session
    static func getInsights(
        sessions: [DrinkSession],
        currentBAC: Double,
        riskLevel: DrinkingSessionRisk
    ) -> [String] {
        var insights: [String] = []
        
        let now = Date()
        let recentSessions = sessions.filter { 
            now.timeIntervalSince($0.timestamp) <= 3600 * 3 
        }
        
        // Pace insight
        if recentSessions.count >= 2 {
            let sortedSessions = recentSessions.sorted { $0.timestamp > $1.timestamp }
            var totalInterval: TimeInterval = 0
            
            for i in 0..<(sortedSessions.count - 1) {
                let interval = sortedSessions[i].timestamp.timeIntervalSince(sortedSessions[i + 1].timestamp)
                totalInterval += interval
            }
            
            let averageInterval = totalInterval / Double(sortedSessions.count - 1)
            let minutesBetween = Int(averageInterval / 60)
            
            if minutesBetween < 20 {
                insights.append("Drinking faster than recommended pace")
            }
        }
        
        // Double shots insight
        let doubleCount = recentSessions.filter { $0.isDouble }.count
        if doubleCount >= 2 {
            insights.append("Multiple double shots increase risk")
        }
        
        // BAC insight
        if currentBAC >= 0.08 {
            insights.append("BAC is above legal driving limit in most regions")
        } else if currentBAC >= 0.05 {
            insights.append("Approaching legal limit - avoid driving")
        }
        
        return insights
    }
}
