import XCTest
@testable import MovieQuiz



// MARK: - MovieQuizViewControllerMock

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    var setLoadingStateCalled = false
    var setLoadingStateArg: Bool?
    var setLoadingStateHandler: ((Bool) -> Void)?
    
    var showNetworkErrorCalled = false
    var showNetworkErrorMassage: String?
    var showNetworkErrorHandler: ((String) -> Void)?
    
    var setAnswerButtonsHandler: ((Bool) -> Void)?
    
    var showStepCalled = false
    var showStepHandler: ((QuizStepViewModel) -> Void)?
    
    var highlightImageBorderCalled = false
    var highlightImageBorderHandler: ((Bool) -> Void)?
    
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        showStepCalled = true
        showStepHandler?(step)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        highlightImageBorderCalled = true
        highlightImageBorderHandler?(isCorrectAnswer)
    }
    
    func show(quiz result: MovieQuiz.QuizResultsViewModel) {
        
    }
    
    func setAnswerButtonsState(isEnabled: Bool) {
        setAnswerButtonsHandler?(isEnabled)
    }
    
    func setLoadingState(isLoading: Bool) {
        setLoadingStateCalled = true
        setLoadingStateArg = isLoading
        setLoadingStateHandler?(isLoading)
    }
    
    func showNetworkError(message: String) {
        showNetworkErrorCalled = true
        showNetworkErrorMassage = message
        showNetworkErrorHandler?(message)
    }
}

// MARK: - StubStatisticService

final class StubStatisticService: StatisticServiceProtocol {
    var gamesCount: Int = 0
    var bestGame = MovieQuiz.GameResult(correct: 0, total: 0, date: Date())
    var totalAccuracy: Double = 0.0
    
    func store(correct count: Int, total amount: Int) {
        
    }
}

// MARK: - StubQuestionFactory

final class StubQuestionFactory: QuestionFactoryProtocol {
    var loadDataCalled = false
    var loadDataCompletion: (() -> Void)?
    var requestNextQuestionCalled = false
    var requestNextQuestionHandler: (() -> Void)?
    
    func requestNextQuestion() {
        requestNextQuestionCalled = true
        requestNextQuestionHandler?()
    }
    
    func loadData() {
        loadDataCalled = true
        loadDataCompletion?()
    }
    
    func generateQuestion(for movie: MovieQuiz.Movie) throws -> (questionText: String, correctAnswer: Bool) {
        return ("Question Text", true)
    }
}


// MARK: - MovieQuizPresenterTests

final class MovieQuizPresenterTests: XCTestCase {
    var sut: MovieQuizPresenter!
    var viewControllerMock: MovieQuizViewControllerMock!
    var statisticServiceStub: StubStatisticService!
    var questionFactoryStub: StubQuestionFactory!
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        super.setUp()
        
        viewControllerMock = MovieQuizViewControllerMock()
        statisticServiceStub = StubStatisticService()
        questionFactoryStub = StubQuestionFactory()
        
        sut = MovieQuizPresenter(
            viewController: viewControllerMock,
            statisticService: statisticServiceStub,
            questionFactory: questionFactoryStub
        )
    }
    
    override func tearDown() {
        sut = nil
        viewControllerMock = nil
        statisticServiceStub = nil
        questionFactoryStub = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testPresenterConvertModel() throws {
        guard let validImage = UIImage(named: "Deadpool"),
              let imageData = validImage.pngData() else {
            XCTFail("Не удалось создать imageData из мокового изображения")
            return
        }
        
        let question = QuizQuestion(image: imageData, text: "Question Text", correctAnswer: true)
        
        guard let viewModel = sut.convert(model: question) else {
            XCTFail("convert(model:) вернул nil")
            return
        }
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
    
    func testLoadInitialData() throws {
        let expectation = self.expectation(description: "Loading data")
        questionFactoryStub.loadDataCompletion = {
            expectation.fulfill()
        }
        
        sut.loadInitialData()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(questionFactoryStub.loadDataCalled, "Метод loadData() не был вызван")
    }
    
    func testDidLoadDataFromServer() throws {
        let setLoadingExpectation = self.expectation(description: "Должен быть вызван setLoadingState")
        let requestNextQuestionExpectation = self.expectation(description: "Должен быть вызван requestNextQuestion")
        
        viewControllerMock.setLoadingStateHandler = { isLoading in
            XCTAssertTrue(isLoading)
            setLoadingExpectation.fulfill()
        }
        
        questionFactoryStub.requestNextQuestionHandler = {
            requestNextQuestionExpectation.fulfill()
        }
        
        sut.didLoadDataFromServer()
        
        wait(for: [setLoadingExpectation, requestNextQuestionExpectation], timeout: 1.0)
        XCTAssertTrue(viewControllerMock.setLoadingStateCalled, "setLoadingState не был вызван")
        XCTAssertTrue(questionFactoryStub.requestNextQuestionCalled, "requestNextQuestion не был вызван")
    }
    
    func testdidFailToLoadData() throws {
        let setLoadingExpectation = self.expectation(description: "Должен быть вызван setLoadingState")
        let showNetworkErrorExpectation = self.expectation(description: "Должен быть вызван showNetworkError")
        
        viewControllerMock.setLoadingStateHandler = { isLoading in
            XCTAssertFalse(isLoading)
            setLoadingExpectation.fulfill()
        }
        
        viewControllerMock.showNetworkErrorHandler = { message in
            XCTAssertEqual(message, NetworkError.imageDataCorrupted.localizedDescription)
            showNetworkErrorExpectation.fulfill()
        }
        
        sut.didFailToLoadData(with: NetworkError.imageDataCorrupted)
        
        wait(for: [setLoadingExpectation, showNetworkErrorExpectation], timeout: 1.0)
        XCTAssertTrue(viewControllerMock.setLoadingStateCalled, "Должен быть вызван setLoadingState")
        XCTAssertTrue(viewControllerMock.showNetworkErrorCalled, "Должен быть вызван showNetworkError")
    }
    
    func testRequestNextQuestion() throws {
        let expectation = self.expectation(description: "Должен быть вызван requestNextQuestion")
        
        questionFactoryStub.requestNextQuestionHandler = {
            expectation.fulfill()
        }
        
        sut.requestNextQuestion()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(questionFactoryStub.requestNextQuestionCalled, "Должен быть вызван requestNextQuestion" )
        
    }
    
    func clickDisablesButtons(correctAnswer: Bool, clickAction: () -> Void) {
        let question = QuizQuestion(image: Data(), text: "Test", correctAnswer: correctAnswer)
        sut.currentQuestion = question
        
        let expectation = self.expectation(description: "Кнопки должны быть отключены")
        
        viewControllerMock.setAnswerButtonsHandler = { isEnabled in
            XCTAssertFalse(isEnabled)
            expectation.fulfill()
        }
        
        clickAction()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testYesClickDisablesButtons() throws {
        clickDisablesButtons(correctAnswer: true) {
            sut.yesButtonClicked()
        }
    }
    
    
    func testNoClickDisablesButtons() throws {
        clickDisablesButtons(correctAnswer: false) {
            sut.noButtonClicked()
        }
    }
    
    func testDidReceiveNextQuestion() throws {
        
        guard let image = UIImage(named: "Deadpool"),
              let imageData = image.pngData() else {
            XCTFail("Не удалось создать imageData из мокового изображения")
            return
        }
        
        let question = QuizQuestion(image: imageData, text: "Вопрос?", correctAnswer: true)
        
        let setLoadingStateExpectation = expectation(description: "Должен быть вызван setLoadingState")
        let showExpectation = expectation(description: "Должан быть вызван show(quiz:)")
        
        viewControllerMock.setLoadingStateHandler = { isLoading in
            XCTAssertFalse(isLoading)
            setLoadingStateExpectation.fulfill()
        }
        
        viewControllerMock.showStepHandler = { step in
            XCTAssertEqual(step.question, "Вопрос?")
            XCTAssertEqual(step.questionNumber, "1/10")
            showExpectation.fulfill()
        }
        
        sut.didReceiveNextQuestion(question: question)
        
        wait(for: [setLoadingStateExpectation, showExpectation], timeout: 1.0)
        
        XCTAssertTrue(viewControllerMock.setLoadingStateCalled)
        XCTAssertTrue(viewControllerMock.showStepCalled)
    }
    
    func testRestartGame() throws {
        sut.correctAnswers = 9
        
        let setLoadingStateExpectation = expectation(description: "Должен быть вызван setLoadingState")
        let requestNextQuestionExpectation = self.expectation(description: "Должен быть вызван requestNextQuestion")
        
        viewControllerMock.setLoadingStateHandler = { isLoading in
            XCTAssertTrue(isLoading)
            setLoadingStateExpectation.fulfill()
        }
        
        questionFactoryStub.requestNextQuestionHandler = {
            requestNextQuestionExpectation.fulfill()
        }
        
        sut.restartGame()
        
        wait(for: [setLoadingStateExpectation, requestNextQuestionExpectation], timeout: 1.0)
        
        XCTAssertEqual(sut.correctAnswers, 0, "correctAnswers должно быть сброшено до 0")
        XCTAssertEqual(sut.getCurrentQuestionIndex(), 0, "currentQuestionIndex должно быть сброшено до 0")
        XCTAssertTrue(viewControllerMock.setLoadingStateCalled, "setLoadingState не был вызван")
        XCTAssertTrue(questionFactoryStub.requestNextQuestionCalled, "requestNextQuestion не был вызван")
        
    }
    
    func testShowAnswerResult() throws {
        let question = QuizQuestion(image: Data(), text: "Test Question", correctAnswer: true)
        sut.currentQuestion = question
        
        let highlightImageBorderExpectation = expectation(description: "Должен быть вызванн highlightImageBorder с true")
        let enableButtonsExpectation = expectation(description: "Кнопки должны быть включены")
        let requestNextQuestionExpectation = self.expectation(description: "Должен быть вызван requestNextQuestion")
        
        sut.correctAnswers = 0
        
        viewControllerMock.highlightImageBorderHandler = { isCorrectAnswer in
            XCTAssertTrue(isCorrectAnswer)
            highlightImageBorderExpectation.fulfill()
        }
        
        viewControllerMock.setAnswerButtonsHandler = { isEnabled in
            XCTAssertTrue(isEnabled)
            enableButtonsExpectation.fulfill()
        }
        
        questionFactoryStub.requestNextQuestionHandler = {
            requestNextQuestionExpectation.fulfill()
        }
        
        sut.showAnswerResult(isCorrect: true)
        
        wait(for: [highlightImageBorderExpectation, enableButtonsExpectation, requestNextQuestionExpectation], timeout: 2.0)
        XCTAssertEqual(sut.correctAnswers, 1, "correctAnswers должен увеличиться до 1")
        XCTAssertTrue(viewControllerMock.highlightImageBorderCalled)
        
    }
}
