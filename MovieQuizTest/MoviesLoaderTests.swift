import XCTest
@testable import MovieQuiz

final class MoviesLoaderTests: XCTestCase {
    
    func testSuccessLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClientMock(emulateError: false)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        let expectation = expectation(description: "Loading expectation")
        
        // When
        loader.loadMovies { result in
            // Then
            switch result {
            case .success(let movies):
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
            case .failure:
                XCTFail("Unexpected failure")
            }
        }
        
        waitForExpectations(timeout: 2)
    }
    
    func testFailureLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClientMock(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        let expectation = expectation(description: "Loading expectation")
        
        // When
        loader.loadMovies { result in
            // Then
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            case .success:
                XCTFail("Unexpected success")
            }
        }
        
        waitForExpectations(timeout: 1)
    }
}ц
