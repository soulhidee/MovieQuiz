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

    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        
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
    
    
    
    
    func testYesClickDisablesButtons() throws {
        let question = QuizQuestion(image: Data(), text: "Test", correctAnswer: true)
        sut.currentQuestion = question
        
        let expectation = self.expectation(description: "Кнопки должны быть отключены")
        
        viewControllerMock.setAnswerButtonsHandler = { isEnabled in
            XCTAssertFalse(isEnabled)
            expectation.fulfill()
        }
        
        sut.yesButtonClicked()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testNoClickDisablesButtons() throws {
        let question = QuizQuestion(image: Data(), text: "Test", correctAnswer: false)
        sut.currentQuestion = question
        
        let expectation = self.expectation(description: "Кнопки должны быть отключены")
        
        viewControllerMock.setAnswerButtonsHandler = { isEnabled in
            XCTAssertFalse(isEnabled)
            expectation.fulfill()
        }
        
        sut.noButtonClicked()
        
        wait(for: [expectation], timeout: 1.0)
    }
}
