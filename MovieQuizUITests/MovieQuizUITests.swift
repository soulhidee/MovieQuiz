
import XCTest

class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testButtonAction(buttonTitle: String, expectedIndex: String) {
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 5))
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons[buttonTitle].tap()
        
        let secondPoster = app.images["Poster"]
        XCTAssertTrue(secondPoster.waitForExistence(timeout: 5))
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let updatedIndexLabel = app.staticTexts["Index"]
        XCTAssertTrue(updatedIndexLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(updatedIndexLabel.label, expectedIndex)
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }

    func testYesButton() {
        testButtonAction(buttonTitle: "Yes", expectedIndex: "2/10")
    }

    func testNoButton() {
        testButtonAction(buttonTitle: "No", expectedIndex: "2/10")
    }
}
