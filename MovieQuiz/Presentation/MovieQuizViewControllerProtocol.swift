
protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func show(quiz result: QuizResultsViewModel)
    func setAnswerButtonsState(isEnabled: Bool)
    func setLoadingState(isLoading: Bool)
    func showNetworkError(message: String)
}
