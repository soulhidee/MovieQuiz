import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoder: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [Movie] = []
    private var shuffledMovies: [Movie] = []
    private var currentIndex = 0
    
    init(moviesLoder: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoder = moviesLoder
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoder.loadMovies { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let mostPopularMovies):
                self.movies = mostPopularMovies.items
                self.shuffledMovies = self.movies.shuffled()
                self.delegate?.didLoadDataFromServer()
            case .failure(let error):
                self.delegate?.didFailToLoadData(with: error)
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            if self.currentIndex == self.shuffledMovies.count {
                self.shuffledMovies = self.movies.shuffled()
                self.currentIndex = 0
            }
            
            let movie = self.shuffledMovies[self.currentIndex]
            self.currentIndex += 1
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async {
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}

Теперь код соответствует стилю и не содержит комментариев.

//private let questions: [QuizQuestion] = [
//    QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//    QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//    QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//    QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//    QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//    QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//    QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
//    QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
//    QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
//    QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
//]
