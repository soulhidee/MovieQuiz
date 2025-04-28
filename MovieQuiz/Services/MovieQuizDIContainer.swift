final class MovieQuizDIContainer {
    static func makePresenter(viewController: MovieQuizViewController) -> MovieQuizPresenter {
        let statisticService = StatisticService()
        let moviesLoader = MoviesLoader()
        let questionFactory = QuestionFactory(moviesLoder: moviesLoader, delegate: nil)
        let presenter = MovieQuizPresenter(
            viewController: viewController,
            statisticService: statisticService,
            questionFactory: questionFactory
        )
        questionFactory.delegate = presenter // Устанавливаем делегата после создания презентера
        return presenter
    }
}
