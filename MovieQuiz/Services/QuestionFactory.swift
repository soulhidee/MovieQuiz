import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    weak var delegate: QuestionFactoryDelegate?
    private var shuffledQuestions: [QuizQuestion] = []
    private var currentIndex = 0
    
    func requestNextQuestion() {
        if currentIndex == shuffledQuestions.count {
            shuffledQuestions = questions.shuffled()
            currentIndex = 0
        }
        
        let question = shuffledQuestions[currentIndex]
        currentIndex += 1
        delegate?.didReceiveNextQuestion(question: question)
    }
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
        shuffledQuestions = questions.shuffled()
    }
    
    
}
