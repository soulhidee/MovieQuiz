import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    var gamesCount: Int {
        get {
            storage.integer(forKey: "gamesCount")
        }
        set {
            storage.set(newValue, forKey: "gamesCount")
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: "bestGameCorrect")
            let total = storage.integer(forKey: "bestGameTotal")
            let date = storage.object(forKey: "bestGameDate") as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: "bestGameCorrect")
            storage.set(newValue.total, forKey: "bestGameTotal")
            storage.set(newValue.date, forKey: "bestGameDate")
        }
    }
    
    var totalAccuracy: Double {
        let correctAnswers = storage.integer(forKey: "totalCorrect")
        let totalQuestions = storage.integer(forKey: "totalQuestions")
        
        guard totalQuestions != 0 else {
            return 0.0
        }
        return (Double(correctAnswers) / Double(totalQuestions)) * 100
    }
    
    
    func store(correct count: Int, total amount: Int) {
        
    }
    
    
}
