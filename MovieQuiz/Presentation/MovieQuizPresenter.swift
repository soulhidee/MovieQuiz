import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestionIndex: Int = .zero
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = .zero
    weak var viewController: MovieQuizViewController?
    let questionsAmount = 10
    var showNetworkError: ((String) -> Void)?
   
    init(viewController: MovieQuizViewController) {
           self.viewController = viewController
           questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
           questionFactory?.loadData()
           viewController.showLoadingIndicator()
       }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        guard let viewModel = convert(model: question) else { return }
        
        DispatchQueue.main.async { [weak self] in
            viewController?.hideLoadingIndicator()
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
        func didLoadDataFromServer() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.viewController?.showLoadingIndicator()
                self.questionFactory?.requestNextQuestion()
            }
        }
    
        func didFailToLoadData(with error: Error) {
            if let networkError = error as? NetworkError {
                viewController?.hideLoadingIndicator()
                viewController?.showNetworkError(message: networkError.errorDescription ?? "Неизвестная ошибка")
            }
        }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel? {
        guard let image = UIImage(data: model.image) else {
            showNetworkError?(NetworkError.imageDataCorrupted.localizedDescription)
            return nil
        }
        
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
            if isCorrectAnswer {
                correctAnswers += 1
            }
        }
    
    func restartGame() {
        currentQuestionIndex = .zero
        correctAnswers = .zero
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func didAnswer(isYes: Bool) {
        viewController?.setAnswerButtonsState(isEnabled: false)
        guard let currentQuestion else { return }
        
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
   func noButtonClicked() {
       didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: false)
    }
    
   
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
                buttonText: "Сыграть ещё раз"
            )
            viewController?.show(quiz: result)
        } else {
            self.switchToNextQuestion()
            viewController?.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
}
