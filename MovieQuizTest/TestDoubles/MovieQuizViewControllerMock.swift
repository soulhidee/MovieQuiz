import Foundation

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    var setLoadingStateCalled = false
    var setLoadingStateArg: Bool?
    var setLoadingStateHandler: ((Bool) -> Void)?
    
    var showNetworkErrorCalled = false
    var showNetworkErrorMassage: String?
    var showNetworkErrorHandler: ((String) -> Void)?
    
    var setAnswerButtonsHandler: ((Bool) -> Void)?
    
    var showStepCalled = false
    var showStepHandler: ((QuizStepViewModel) -> Void)?
    
    var highlightImageBorderCalled = false
    var highlightImageBorderHandler: ((Bool) -> Void)?
    
    var showResultCalled = false
    var showResultHandler: ((QuizResultsViewModel) -> Void)?
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        showStepCalled = true
        showStepHandler?(step)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        highlightImageBorderCalled = true
        highlightImageBorderHandler?(isCorrectAnswer)
    }
    
    func show(quiz result: MovieQuiz.QuizResultsViewModel) {
        showResultCalled = true
        showResultHandler?(result)
    }
    
    func setAnswerButtonsState(isEnabled: Bool) {
        setAnswerButtonsHandler?(isEnabled)
    }
    
    func setLoadingState(isLoading: Bool) {
        setLoadingStateCalled = true
        setLoadingStateArg = isLoading
        setLoadingStateHandler?(isLoading)
    }
    
    func showNetworkError(message: String) {
        showNetworkErrorCalled = true
        showNetworkErrorMassage = message
        showNetworkErrorHandler?(message)
    }
}
