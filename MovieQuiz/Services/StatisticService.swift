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
    
    var bestGame: GameResult {
        get {
            let correct = UserDefaults.standard.integer(forKey: "bestGameCorrect")
            let total = UserDefaults.standard.integer(forKey: "bestGameTotal")
            let date = UserDefaults.standard.object(forKey: "bestGameDate") as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            UserDefaults.standard.set(newValue.correct, forKey: "bestGameCorrect")
            UserDefaults.standard.set(newValue.total, forKey: "bestGameTotal")
            UserDefaults.standard.set(newValue.date, forKey: "bestGameDate")
        }
    }
    
    var totalAccuracy: Double = 0.0
    
    func store(correct count: Int, total amount: Int) {
        
    }
    
    
}
