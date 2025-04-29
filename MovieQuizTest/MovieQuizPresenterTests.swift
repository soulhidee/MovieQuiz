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


