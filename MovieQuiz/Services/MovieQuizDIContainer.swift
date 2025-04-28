import Foundation

final class MovieQuizDIContainer {
    static func makePresenter(viewController: MovieQuizViewController) -> MovieQuizPresenter {
        let statisticService = StatisticService()
        let questionFactory = QuestionFactory(moviesLoder: MoviesLoader(), delegate: viewController as? QuestionFactoryDelegate)
        return MovieQuizPresenter(viewController: viewController,
                                  statisticService: statisticService,
                                  questionFactory: questionFactory)
    }
}
