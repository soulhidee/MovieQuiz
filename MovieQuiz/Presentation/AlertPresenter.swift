import UIKit

final class AletPresenter {
    private weak var presentingController: UIViewController?
    
    private func show(alert model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
                  title: model.buttonText,
                  style: .default
              ) { _ in
                  model.completion()
              }
            
        
        alert.addAction(action)
        presentingController?.present(alert, animated: true)
    }
}
