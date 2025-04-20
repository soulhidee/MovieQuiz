import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData()
    func generateQuestion(for movie: Movie) throws -> (questionText: String, correctAnswer: Bool)
}
