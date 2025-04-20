import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoder: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [Movie] = []
    private var shuffledMovies: [Movie] = []
    private var currentIndex: Int = .zero
    
    init(moviesLoder: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoder = moviesLoder
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoder.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
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
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            if self.currentIndex == self.shuffledMovies.count {
                self.shuffledMovies = self.movies.shuffled()
                self.currentIndex = .zero
            }
            
            guard self.currentIndex < self.shuffledMovies.count else {
                return
            }
            
            let movie = self.shuffledMovies[self.currentIndex]
            self.currentIndex += 1
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? .zero
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(
                image: imageData,
                text: text,
                correctAnswer: correctAnswer
            )
            
            DispatchQueue.main.async {
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
