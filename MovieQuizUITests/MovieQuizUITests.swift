
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
    
    func testAlertAppearsAfterLastQuestion() {
        let button = app.buttons["Yes"]
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5))
        
        for i in 1...10 {
            button.tap()
            let expectedLabel: String
            
            if i == 10 {
                expectedLabel = "10/10"
            } else {
                expectedLabel = "\(i + 1)/10"
            }
            
            let predicate = NSPredicate(format: "label == %@", expectedLabel)
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: indexLabel)
            let result = XCTWaiter().wait(for: [expectation], timeout: 5)
            XCTAssertEqual(result, .completed, "Ожидали индекс: \(expectedLabel), получили \(indexLabel.label)")
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        app.buttons["Сыграть ещё раз"].tap()
        
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
