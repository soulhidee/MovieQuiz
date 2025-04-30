import UIKit

// MARK: - MovieQuizPresenter

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Properties
    
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol!
    private var currentQuestionIndex: Int = .zero
    private var isAnsweringNow = false
    private let questionsAmount = 10
    var correctAnswers: Int = .zero
    
    
    var currentQuestion: QuizQuestion?
    
    
    weak var viewController: MovieQuizViewControllerProtocol?
    
    // MARK: - Initializer
    
    init(viewController: MovieQuizViewControllerProtocol,
         statisticService: StatisticServiceProtocol,
         questionFactory: QuestionFactoryProtocol) {
        self.viewController = viewController
        self.statisticService = statisticService
        self.questionFactory = questionFactory
    }
    
    // MARK: - Data Loading
    //Тест написан
    func loadInitialData() {
        questionFactory?.loadData()
    }
    //Тест написан
    func didLoadDataFromServer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewController?.setLoadingState(isLoading: true)
            self.requestNextQuestion()
        }
    }
    //Текст написан
    func didFailToLoadData(with error: Error) {
        if let networkError = error as? NetworkError {
            viewController?.setLoadingState(isLoading: false)
            viewController?.showNetworkError(message: networkError.errorDescription ?? "Неизвестная ошибка")
        }
    }
    
    // MARK: - Question Handling
    //Тест написан
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        
        guard let viewModel = convert(model: question) else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.setLoadingState(isLoading: false)
            self?.viewController?.show(quiz: viewModel)
        }
    }
    //Тест написан
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
    //Тест написан
    func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Answer Handling
    //Тест написан
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    //Тест написан
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
    
    
    
    func showAnswerResult(isCorrect: Bool) {
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
    func getCurrentQuestionIndex() -> Int {
        return currentQuestionIndex
    }
    
    private func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func restartGame() {
        currentQuestionIndex = .zero
        correctAnswers = .zero
        viewController?.setLoadingState(isLoading: true)
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
    
    func setCurrentQuestionIndexForTest(_ index: Int) {
        self.currentQuestionIndex = index
    }

    func getCurrentQuestionIndexForTest() -> Int {
        return currentQuestionIndex
    }
}
