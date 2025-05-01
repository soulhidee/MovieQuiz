import Foundation

final class StubQuestionFactoryMock: QuestionFactoryProtocol {
    var loadDataCalled = false
    var loadDataCompletion: (() -> Void)?
    var requestNextQuestionCalled = false
    var requestNextQuestionHandler: (() -> Void)?
    
    func requestNextQuestion() {
        requestNextQuestionCalled = true
        requestNextQuestionHandler?()
    }
    
    func loadData() {
        loadDataCalled = true
        loadDataCompletion?()
    }
    
    func generateQuestion(for movie: MovieQuiz.Movie) throws -> (questionText: String, correctAnswer: Bool) {
        return ("Question Text", true)
    }
}
