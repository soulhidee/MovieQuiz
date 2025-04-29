import UIKit

// MARK: - MovieQuizPresenter

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Properties
    
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol!
    private var currentQuestionIndex: Int = .zero
    private var isAnsweringNow = false
    private let questionsAmount = 10
    
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = .zero
    
    weak var viewController: MovieQuizViewController?
    
    // MARK: - Initializer
    
    init(viewController: MovieQuizViewController,
         statisticService: StatisticServiceProtocol,
         questionFactory: QuestionFactoryProtocol) {
        self.viewController = viewController
        self.statisticService = statisticService
        self.questionFactory = questionFactory
    }
    
    // MARK: - Data Loading
    
    func loadInitialData() {
        print("Start loading initial data")
        questionFactory?.loadData()
    }
    
    func didLoadDataFromServer() {
        print("Data loaded from server, requesting first question")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewController?.setLoadingState(isLoading: true)
            self.requestNextQuestion()
        }
    }
    
    func didFailToLoadData(with error: Error) {
        print("Failed to load data: \(error.localizedDescription)")
        if let networkError = error as? NetworkError {
            viewController?.setLoadingState(isLoading: false)
            viewController?.showNetworkError(message: networkError.errorDescription ?? "Неизвестная ошибка")
        }
    }
    
    // MARK: - Question Handling
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        
        guard let viewModel = convert(model: question) else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.setLoadingState(isLoading: false)
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel? {
        guard let image = UIImage(data: model.image) else {
            viewController?.showNetworkError(message: NetworkError.imageDataCorrupted.localizedDescription)
            return nil
        }
        
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Answer Handling
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard !isAnsweringNow else { return }
        isAnsweringNow = true
        viewController?.setAnswerButtonsState(isEnabled: false)
        
        guard let currentQuestion else {
            isAnsweringNow = false
            viewController?.setAnswerButtonsState(isEnabled: true)
            return
        }
        
        let givenAnswer = isYes
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            didAnswer(isCorrectAnswer: true)
        }
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.isAnsweringNow = false
            self.viewController?.setAnswerButtonsState(isEnabled: true)
            self.showNextQuestionOrResults()
        }
    }
    
    // MARK: - Next Question or Results
    
    private func showNextQuestionOrResults() {
        if isLastQuestion() {
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
                buttonText: "Сыграть ещё раз"
            )
            viewController?.show(quiz: result)
        } else {
            switchToNextQuestion()
            viewController?.setLoadingState(isLoading: true)
            requestNextQuestion()
        }
    }
    
    // MARK: - Helpers
    
    private func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func restartGame() {
        currentQuestionIndex = .zero
        correctAnswers = .zero
        requestNextQuestion()
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        let dateString = bestGame.date.dateTimeString
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        return [
            currentGameResultLine,
            totalPlaysCountLine,
            bestGameInfoLine,
            averageAccuracyLine
        ].joined(separator: "\n")
    }
}
