import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    // MARK: - Keys
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrect
        case totalQuestions
    }
    
    // MARK: - Properties
    private let storage: UserDefaults = .standard
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let correctAnswers = storage.integer(forKey: Keys.totalCorrect.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        
        guard totalQuestions != 0 else {
            return .zero
        }
        
        return (Double(correctAnswers) / Double(totalQuestions)) * 100
    }
    
    // MARK: - Methods
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
        
        let newTotalCorrect = storage.integer(forKey: Keys.totalCorrect.rawValue) + count
        let newTotalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue) + amount
        
        storage.set(newTotalCorrect, forKey: Keys.totalCorrect.rawValue)
        storage.set(newTotalQuestions, forKey: Keys.totalQuestions.rawValue)
    }
}
