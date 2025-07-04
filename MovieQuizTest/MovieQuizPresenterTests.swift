import XCTest
@testable import MovieQuiz

// MARK: - MovieQuizPresenterTests
final class MovieQuizPresenterTests: XCTestCase {
    var sut: MovieQuizPresenter!
    var viewControllerMock: MovieQuizViewControllerMock!
    var statisticServiceStub: StubStatisticServiceMock!
    var questionFactoryStub: StubQuestionFactoryMock!
    
    // MARK: - Setup / Teardown
    override func setUp() {
        super.setUp()
        
        viewControllerMock = MovieQuizViewControllerMock()
        statisticServiceStub = StubStatisticServiceMock()
        questionFactoryStub = StubQuestionFactoryMock()
        
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
        // Given
        guard let validImage = UIImage(named: "Deadpool"),
              let imageData = validImage.pngData() else {
            XCTFail("Не удалось создать imageData из мокового изображения")
            return
        }
        
        let question = QuizQuestion(image: imageData, text: "Question Text", correctAnswer: true)
        
        // When
        guard let viewModel = sut.convert(model: question) else {
            XCTFail("convert(model:) вернул nil")
            return
        }
        
        // Then
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
    
    func testLoadInitialData() throws {
        // Given
        let expectation = self.expectation(description: "Loading data")
        questionFactoryStub.loadDataCompletion = {
            expectation.fulfill()
        }
        
        // When
        sut.loadInitialData()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(questionFactoryStub.loadDataCalled, "Метод loadData() не был вызван")
    }
    
    func testDidLoadDataFromServer() throws {
        // Given
        let setLoadingExpectation = self.expectation(description: "Должен быть вызван setLoadingState")
        let requestNextQuestionExpectation = self.expectation(description: "Должен быть вызван requestNextQuestion")
        
        viewControllerMock.setLoadingStateHandler = { isLoading in
            XCTAssertTrue(isLoading)
            setLoadingExpectation.fulfill()
        }
        
        questionFactoryStub.requestNextQuestionHandler = {
            requestNextQuestionExpectation.fulfill()
        }
        
        // When
        sut.didLoadDataFromServer()
        
        // Then
        wait(for: [setLoadingExpectation, requestNextQuestionExpectation], timeout: 1.0)
        XCTAssertTrue(viewControllerMock.setLoadingStateCalled, "setLoadingState не был вызван")
        XCTAssertTrue(questionFactoryStub.requestNextQuestionCalled, "requestNextQuestion не был вызван")
    }
    
    func testdidFailToLoadData() throws {
        // Given
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
        
        // When
        sut.didFailToLoadData(with: NetworkError.imageDataCorrupted)
        
        // Then
        wait(for: [setLoadingExpectation, showNetworkErrorExpectation], timeout: 1.0)
        XCTAssertTrue(viewControllerMock.setLoadingStateCalled, "Должен быть вызван setLoadingState")
        XCTAssertTrue(viewControllerMock.showNetworkErrorCalled, "Должен быть вызван showNetworkError")
    }
    
    func testRequestNextQuestion() throws {
        // Given
        let expectation = self.expectation(description: "Должен быть вызван requestNextQuestion")
        
        questionFactoryStub.requestNextQuestionHandler = {
            expectation.fulfill()
        }
        
        // When
        sut.requestNextQuestion()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(questionFactoryStub.requestNextQuestionCalled, "Должен быть вызван requestNextQuestion" )
        
    }
    
    func clickDisablesButtons(correctAnswer: Bool, clickAction: () -> Void) {
        // Given
        let question = QuizQuestion(image: Data(), text: "Test", correctAnswer: correctAnswer)
        sut.currentQuestion = question
        
        let expectation = self.expectation(description: "Кнопки должны быть отключены")
        
        viewControllerMock.setAnswerButtonsHandler = { isEnabled in
            XCTAssertFalse(isEnabled)
            expectation.fulfill()
        }
        
        // When
        clickAction()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testYesClickDisablesButtons() throws {
        // Given
        let correctAnswer = true
        
        // When & Then
        clickDisablesButtons(correctAnswer: correctAnswer) {
            sut.yesButtonClicked()
        }
    }
    
    
    func testNoClickDisablesButtons() throws {
        // Given
        let correctAnswer = false
        
        // When & Then
        clickDisablesButtons(correctAnswer: correctAnswer) {
            sut.noButtonClicked()
        }
    }
    
    func testDidReceiveNextQuestion() throws {
        // Given
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
        
        // When
        sut.didReceiveNextQuestion(question: question)
        
        // Then
        wait(for: [setLoadingStateExpectation, showExpectation], timeout: 1.0)
        
        XCTAssertTrue(viewControllerMock.setLoadingStateCalled)
        XCTAssertTrue(viewControllerMock.showStepCalled)
    }
    
    func testRestartGame() throws {
        // Given
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
        
        // When
        sut.restartGame()
        
        // Then
        wait(for: [setLoadingStateExpectation, requestNextQuestionExpectation], timeout: 1.0)
        
        XCTAssertEqual(sut.correctAnswers, 0, "correctAnswers должно быть сброшено до 0")
        XCTAssertEqual(sut.getCurrentQuestionIndex(), 0, "currentQuestionIndex должно быть сброшено до 0")
        XCTAssertTrue(viewControllerMock.setLoadingStateCalled, "setLoadingState не был вызван")
        XCTAssertTrue(questionFactoryStub.requestNextQuestionCalled, "requestNextQuestion не был вызван")
        
    }
    
    func showAnswerResult(isCorrect: Bool) {
        // Given
        let question = QuizQuestion(image: Data(), text: "Test Question", correctAnswer: true)
        sut.currentQuestion = question
        
        let highlightImageBorderExpectation = expectation(description: "Должен быть вызван highlightImageBorder с \(isCorrect ? "true" : "false")")
        let enableButtonsExpectation = expectation(description: "Кнопки должны быть включены")
        let requestNextQuestionExpectation = self.expectation(description: "Должен быть вызван requestNextQuestion")
        
        sut.correctAnswers = 0
        
        viewControllerMock.highlightImageBorderHandler = { isCorrectAnswer in
            XCTAssertEqual(isCorrectAnswer, isCorrect)
            highlightImageBorderExpectation.fulfill()
        }
        
        viewControllerMock.setAnswerButtonsHandler = { isEnabled in
            XCTAssertTrue(isEnabled)
            enableButtonsExpectation.fulfill()
        }
        
        questionFactoryStub.requestNextQuestionHandler = {
            requestNextQuestionExpectation.fulfill()
        }
        
        // When
        sut.showAnswerResult(isCorrect: isCorrect)
        
        // Then
        wait(for: [highlightImageBorderExpectation, enableButtonsExpectation, requestNextQuestionExpectation], timeout: 2.0)
        
        if isCorrect {
            XCTAssertEqual(sut.correctAnswers, 1, "correctAnswers должен увеличиться до 1")
        } else {
            XCTAssertEqual(sut.correctAnswers, 0, "correctAnswers не должен увеличиться")
        }
        
        XCTAssertTrue(viewControllerMock.highlightImageBorderCalled)
    }
    
    func testShowAnswerResultTrue() throws {
        // Given
        let isCorrect = true
        
        // When & Then
        showAnswerResult(isCorrect: isCorrect)
    }
    
    func  testShowAnswerResultFalse() throws {
        // Given
        let isCorrect = false
        
        // When & Then
        showAnswerResult(isCorrect: isCorrect)
    }
    
    
    func testShowNextQuestionOrResultsLastQuestion() throws {
        // Given
        sut.correctAnswers = 7
        sut.setCurrentQuestionIndexForTest(9)
        sut.currentQuestion = QuizQuestion(image: Data(), text: "Test", correctAnswer: true)
        
        let expectation = expectation(description: "Ожидается вызов show(quiz:) с результатом")
        
        viewControllerMock.showResultHandler = { result in
            XCTAssertEqual(result.title, "Этот раунд окончен!")
            XCTAssertEqual(result.text, "Ваш результат: 7/10")
            XCTAssertEqual(result.buttonText, "Сыграть ещё раз")
            expectation.fulfill()
        }
        
        // When
        sut.showAnswerResult(isCorrect: false)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testShowNextQuestionOrResults() throws {
        // Given
        sut.correctAnswers = 7
        sut.setCurrentQuestionIndexForTest(5)
        sut.currentQuestion = QuizQuestion(image: Data(), text: "Test", correctAnswer: true)
        
        let setLoadingStateExpectation = expectation(description: "Должен быть вызван setLoadingState")
        let requestNextQuestionExpectation = self.expectation(description: "Должен быть вызван requestNextQuestion")
        
        viewControllerMock.setLoadingStateHandler = { isLoading in
            XCTAssertTrue(isLoading, "setLoadingState должен быть вызван с true")
            setLoadingStateExpectation.fulfill()
        }
        
        questionFactoryStub.requestNextQuestionHandler = {
            requestNextQuestionExpectation.fulfill()
        }
        
        // When
        sut.showAnswerResult(isCorrect: false)
        
        // Then
        wait(for: [setLoadingStateExpectation, requestNextQuestionExpectation], timeout: 2.0)
        XCTAssertEqual(sut.getCurrentQuestionIndex(), 6, "currentQuestionIndex должен увеличиться на 1")
        
    }
    
    func testMakeResultsMessage() throws {
        // Given
        sut.correctAnswers = 7
        statisticServiceStub.gamesCount = 10
        statisticServiceStub.totalAccuracy = 70.0
        statisticServiceStub.bestGame = MovieQuiz.GameResult(correct: 9, total: 10, date: Date(timeIntervalSince1970: 0))
        
        // When
        let message = sut.makeResultsMessage()
        
        // Then
        XCTAssertTrue(message.contains("Ваш результат: 7/10"), "Сообщение должно содержать текущий результат")
        XCTAssertTrue(message.contains("Количество сыгранных квизов: 10"), "Сообщение должно содержать общее число игр")
        XCTAssertTrue(message.contains("Рекорд: 9/10"), "Сообщение должно содержать лучший результат")
        XCTAssertTrue(message.contains("Средняя точность: 70.00%"), "Сообщение должно содержать среднюю точность")
    }
}
