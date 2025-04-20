import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
<<<<<<< HEAD
=======
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
>>>>>>> sprint_06
}
