import UIKit

final class MovieQuizPresenter {
    
    private var currentQuestionIndex: Int = .zero
    let questionsAmount = 10
    var showNetworkError: ((String) -> Void)?
    
    
    func convert(model: QuizQuestion) -> QuizStepViewModel? {
        guard let image = UIImage(data: model.image) else {
            showNetworkError?(NetworkError.imageDataCorrupted.localizedDescription)
            return nil
        }
        
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = .zero
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
}
