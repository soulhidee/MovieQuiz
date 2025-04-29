import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        
    }
    
    func show(quiz result: MovieQuiz.QuizResultsViewModel) {
        
    }
    
    func setAnswerButtonsState(isEnabled: Bool) {
        
    }
    
    func setLoadingState(isLoading: Bool) {
        
    }
    
    func showNetworkError(message: String) {
        
    }
}


final class StubStatisticService: StatisticServiceProtocol {
    var gamesCount: Int = 0
    var bestGame = MovieQuiz.GameResult(correct: 0, total: 0, date: Date())
    var totalAccuracy: Double = 0.0
    
    func store(correct count: Int, total amount: Int) {
        
    }
}

final class StubQuestionFactory: QuestionFactoryProtocol {
    func requestNextQuestion() {
    }
    
    func loadData() {
    }
    
    func generateQuestion(for movie: MovieQuiz.Movie) throws -> (questionText: String, correctAnswer: Bool) {
        return ("Question Text", true)
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {

        let viewControllerMock = MovieQuizViewControllerMock()
        let statisticServiceStub = StubStatisticService()
        let questionFactoryStub = StubQuestionFactory()
        
        let sut = MovieQuizPresenter(
            viewController: viewControllerMock,
            statisticService: statisticServiceStub,
            questionFactory: questionFactoryStub
        )
        
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
}
