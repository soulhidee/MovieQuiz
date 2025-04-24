
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
    
    func testScreenCast() throws {
        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.staticTexts["Нет"]/*[[".buttons[\"Нет\"].staticTexts.firstMatch",".buttons.staticTexts[\"Нет\"]",".staticTexts[\"Нет\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let staticText = app/*@START_MENU_TOKEN@*/.staticTexts["Да"]/*[[".buttons[\"Да\"].staticTexts.firstMatch",".buttons.staticTexts[\"Да\"]",".staticTexts[\"Да\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        staticText.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Нет"]/*[[".buttons.containing(.staticText, identifier: \"Нет\").firstMatch",".otherElements.buttons[\"Нет\"]",".buttons[\"Нет\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        staticText.tap()
        
        let element = app.otherElements/*@START_MENU_TOKEN@*/.containing(.button, identifier: "Нет").firstMatch/*[[".element(boundBy: 5)",".containing(.staticText, identifier: \"Нет\").firstMatch",".containing(.button, identifier: \"Да\").firstMatch",".containing(.button, identifier: \"Нет\").firstMatch"],[[[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element.tap()
        staticText.tap()
        element.tap()
        staticText.tap()
        staticText.tap()
        staticText.tap()
        staticText.tap()
        staticText.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Сыграть ещё раз"]/*[[".otherElements.buttons[\"Сыграть ещё раз\"]",".buttons.firstMatch",".buttons[\"Сыграть ещё раз\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
                
    }
}
