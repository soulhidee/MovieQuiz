import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData()
    func generateQuestionText(for movie: Movie) -> String
}
