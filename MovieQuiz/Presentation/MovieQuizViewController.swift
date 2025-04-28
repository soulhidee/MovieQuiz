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
    private var correctAnswers: Int = .zero
    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureServices()
        loadInitialData()
        presenter.showNetworkError = { [weak self] message in
            self?.showNetworkError(message: message)
        }
        presenter.viewController = self
    }
    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
          presenter.didReceiveNextQuestion(question: question)
      }
    
    func didLoadDataFromServer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showLoadingIndicator()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    func didFailToLoadData(with error: Error) {
        if let networkError = error as? NetworkError {
            hideLoadingIndicator()
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
    
    
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.setAnswerButtonsState(isEnabled: true)
                self.showNextQuestionOrResults()
                self.imageView.layer.borderWidth = .zero
            }
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)",
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: result)
        } else {
            presenter.switchToNextQuestion()
            showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        guard let statisticService else { return }
        
        statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
        let bestGame = statisticService.bestGame
        let dateString = bestGame.date.dateTimeString
        let message = """
            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self else { return }
                
                self.presenter.resetQuestionIndex()
                self.correctAnswers = .zero
                self.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.show(alert: alertModel)
    }
    
    func setAnswerButtonsState(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            guard let self else { return }
            
            self.showLoadingIndicator()
            self.presenter.resetQuestionIndex()
            self.correctAnswers = .zero
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.show(alert: model)
    }
}

