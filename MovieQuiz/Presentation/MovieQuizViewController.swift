import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Outlets
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureServices()
        loadInitialData()
    }
    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        setAnswerButtonsState(isEnabled: false)
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        setAnswerButtonsState(isEnabled: false)
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.hideLoadingIndicator()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    func didFailToLoadData(with error: Error) {
        if let networkError = error as? NetworkError {
            showNetworkError(message: networkError.errorDescription ?? "Неизвестная ошибка")
        }
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        showLoadingIndicator()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
    }
    
    private func configureServices() {
        questionFactory = QuestionFactory(moviesLoder: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(presentingController: self)
        statisticService = StatisticService()
    }
    
    private func loadInitialData() {
        questionFactory?.loadData()
        questionFactory?.requestNextQuestion()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.setAnswerButtonsState(isEnabled: true)
                self.showNextQuestionOrResults()
                self.imageView.layer.borderWidth = 0
            }
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: result)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        guard let statisticService else { return }
        
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let bestGame = statisticService.bestGame
        let dateString = bestGame.date.dateTimeString
        let message = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.show(alert: alertModel)
    }
    
    private func setAnswerButtonsState(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз") { [weak self] in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        alertPresenter?.show(alert: model)
    }
    

}

