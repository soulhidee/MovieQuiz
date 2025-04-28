import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoder: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
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
    
    func generateQuestion(for movie: Movie) throws -> (questionText: String, correctAnswer: Bool) {
        let randomComparisonValue = Float.random(in: 5.0..<10)
        let formattedValue = String(format: "%.2f", randomComparisonValue)
        
        guard let movieRating = Float(movie.rating) else {
            throw NetworkError.missingRating
        }
        
        let isGreaterComparison = Bool.random()
        let comparisonOperator = isGreaterComparison ? "больше" : "меньше"
        let questionText = "Рейтинг этого фильма \(comparisonOperator) чем \(formattedValue)?"
        
        let correctAnswer = isGreaterComparison
            ? movieRating > randomComparisonValue
            : movieRating < randomComparisonValue
        
        return (questionText, correctAnswer)
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
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: NetworkError.imageDataCorrupted)
                }
                return
            }
            
            do {
                let generatedQuestion = try generateQuestion(for: movie)
                let questionText = generatedQuestion.questionText
                let correctAnswer = generatedQuestion.correctAnswer
                
                let question = QuizQuestion(
                    image: imageData,
                    text: questionText,
                    correctAnswer: correctAnswer
                )
                
                DispatchQueue.main.async {
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
