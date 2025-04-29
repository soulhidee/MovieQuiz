import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        
    }
    
    func show(quiz result: MovieQuiz.QuizResultsViewModel) {
        
    }
    
    func setAnswerButtonsState(isEnabled: Bool) {
        
    }
    
    func setLoadingState(isLoading: Bool) {
        
    }
    
    func showNetworkError(message: String) {
        
    }
}


final class StubStatisticService: StatisticServiceProtocol {
    var gamesCount: Int = 0
    var bestGame = MovieQuiz.GameResult(correct: 0, total: 0, date: Date())
    var totalAccuracy: Double = 0.0
    
    func store(correct count: Int, total amount: Int) {
        
    }
}

