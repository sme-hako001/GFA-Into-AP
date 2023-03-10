//
//  SMEDialogService.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/8/23.
//

import UIKit

final
class DialogService {
    
    typealias DialogActionType = (title: String?, style: UIAlertAction.Style, handler: DialogActionHandler?)?
    typealias DialogActionHandler = () -> Void
    
    func displayAlert(title: String?, message: String?, okButton: DialogActionType) {
        let alertController = UIAlertController(title: title.as(.default), message: message, preferredStyle: .alert)
        
        if let okButton = okButton {
            alertController.addAction(UIAlertAction(title: okButton.title, style: okButton.style, handler: { (_) in
                okButton.handler?()
            }))
        }
        
        self.showAlertController(alertController)
    }
    
    func displayConfirmationAlert(title: String?,
                                  message: String?,
                                  cancelButton: DialogActionType,
                                  okButton: DialogActionType) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let cancelButton = cancelButton {
            alertController.addAction(UIAlertAction(title: cancelButton.title, style: cancelButton.style, handler: { (_) in
                cancelButton.handler?()
            }))
        }
        
        if let okButton = okButton {
            alertController.addAction(UIAlertAction(title: okButton.title, style: okButton.style, handler: { (_) in
                okButton.handler?()
            }))
        }
        
        self.showAlertController(alertController)
    }
    
    func displayOkAlert(title: String?, message: String?) {
        self.displayAlert(title: title,
                          message: message,
                          okButton: ("alertOKButtonTitle".localized, .default, .none))
    }

    func displayError(_ error: Error) {
        self.displayOkAlert(title: error.localizedDescription,
                            message: error.localizedDescription)
    }
    
    func displayAlert(title: String?,
                      message: String?,
                      style: UIAlertController.Style,
                      cancelButton: String?,
                      alternativeButtons: [String],
                      completion: @escaping (Int?) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        for index in 0..<alternativeButtons.count {
            alertController.addAction(UIAlertAction(title: alternativeButtons[index], style: .default, handler: { (_) in
                completion(index)
            }))
        }
        
        if let cancelButton = cancelButton {
            alertController.addAction(UIAlertAction(title: cancelButton, style: .cancel, handler: { (_) in
                completion(nil)
            }))
        }
        
        self.showAlertController(alertController)
    }
    
    
    // MARK: - Private Implementation -
    
    private func showAlertController(_ alertController: UIAlertController) {
        GFACoordinator.shared.present(alertController, animated: true, completion: .none)
    }
}
