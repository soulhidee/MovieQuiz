import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol!
    private var currentQuestionIndex: Int = .zero
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = .zero
    weak var viewController: MovieQuizViewController?
    let questionsAmount = 10
    private var isAnsweringNow = false
    
    // MARK: - Initializer
    init(viewController: MovieQuizViewController,
         statisticService: StatisticServiceProtocol,
         questionFactory: QuestionFactoryProtocol) {
        self.viewController = viewController
        self.statisticService = statisticService
        self.questionFactory = questionFactory
    }
    
    
    // MARK: - Data loading
    func loadInitialData() {
        questionFactory?.loadData()
        questionFactory?.requestNextQuestion()
    }
    
    func didLoadDataFromServer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewController?.setLoadingState(isLoading: true)
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    func didFailToLoadData(with error: Error) {
        if let networkError = error as? NetworkError {
            viewController?.setLoadingState(isLoading: false)
            viewController?.showNetworkError(message: networkError.errorDescription ?? "Неизвестная ошибка")
        }
    }
    
    // MARK: - Question handling
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        
        guard let viewModel = convert(model: question) else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.setLoadingState(isLoading: false)
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel? {
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
    
    // MARK: - Answer handling
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func didAnswer(isYes: Bool) {
        guard !isAnsweringNow else { return }
        isAnsweringNow = true
        viewController?.setAnswerButtonsState(isEnabled: false)
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    // MARK: - Answer result display
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            didAnswer(isCorrectAnswer: true)
        }
        
        self.viewController?.highlightImageBorder(isCorrectAnswer: isCorrect) // СРАЗУ показать рамку!
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.isAnsweringNow = false 
            self.viewController?.setAnswerButtonsState(isEnabled: true)
            self.showNextQuestionOrResults()
        }
    }
    
    // MARK: - Next question or results
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            // Создаём результаты для отображения в конце
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
                buttonText: "Сыграть ещё раз"
            )
            // Показываем результаты
            viewController?.show(quiz: result) // Здесь передается результат, а не шаг
        } else {
            // Переходим к следующему вопросу
            switchToNextQuestion()
            viewController?.setLoadingState(isLoading: true)
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Helpers
    func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount - 1
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func restartGame() {
        currentQuestionIndex = .zero
        correctAnswers = .zero
        questionFactory?.requestNextQuestion()
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        let dateString = bestGame.date.dateTimeString
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    
}
