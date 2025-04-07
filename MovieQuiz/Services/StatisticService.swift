import Foundation

class StatisticService: StatisticServiceProtocol {
    var gamesCount: Int {
        get {
            UserDefaults.standard.integer(forKey: "gamesCount")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "gamesCount")
        }
    }
    
    var bestGame: GameResult
    
    var totalAccuracy: Double
    
    func store(correct count: Int, total amount: Int) {
        
    }
    
    
}
