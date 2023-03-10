//
//  IntroLoginViewController.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/4/23.
//

import UIKit

final
class IntroLoginViewController: UIViewController {
    private let apiService: SMEAPI2 = SMEAPI2.shared
    private let settingsManager: SMESettingsManager = SMESettingsManager()!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeUI()
        self.validateToken()
    }
    
    
    // MARK: - Private Methods -
    
    private func makeUI() {
        self.navigationItem.title = "GFA"
        
        self.view.backgroundColor = .white
        
        let gfaAppImageView = UIImageView(image: UIImage(named: "gfa_app_icon", in: .gfa, with: .none))
        
        self.view.addSubview(gfaAppImageView)
        
        gfaAppImageView.translatesAutoresizingMaskIntoConstraints = false
        
        gfaAppImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        gfaAppImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        gfaAppImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.text = "GFA Login Required"
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        self.view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.topAnchor.constraint(equalTo: gfaAppImageView.bottomAnchor, constant: 30).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 24) .isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -24) .isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        let messageLabel = UILabel()
        messageLabel.text = "To use the Documents section that is a part of GFA, you need to continue with an additional login"
        messageLabel.textColor = UIColor(red: 0.542, green: 0.541, blue: 0.6, alpha: 1)
        messageLabel.numberOfLines = .zero
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        self.view.addSubview(messageLabel)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30) .isActive = true
        messageLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 24) .isActive = true
        messageLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -24) .isActive = true
        
        let loginToGFAButton = GradientButton()
        loginToGFAButton.setTitle("Login To GFA", for: .normal)
        loginToGFAButton.setTitleColor(.white, for: .normal)
        loginToGFAButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        loginToGFAButton.backgroundColor = UIColor(red: 0.129, green: 0.714, blue: 0.416, alpha: 1)
        loginToGFAButton.firstColor = UIColor.color(0x8EE500)
        loginToGFAButton.secondColor = UIColor.color(0x6FB300)
        loginToGFAButton.layer.cornerRadius = 8
        loginToGFAButton.clipsToBounds = true
        loginToGFAButton.addTarget(self, action: #selector(self.loginToGFAButtonTapped), for: .touchUpInside)
        
        self.view.addSubview(loginToGFAButton)
        
        loginToGFAButton.translatesAutoresizingMaskIntoConstraints = false
        
        loginToGFAButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 50) .isActive = true
        loginToGFAButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 24) .isActive = true
        loginToGFAButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -24) .isActive = true
        loginToGFAButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    @objc
    private func loginToGFAButtonTapped() {
        GFACoordinator.shared.setRootToLoginUSMViewController()
    }
    
    private func validateToken() {
        self.animate(true)
        
        self.apiService.validateToken((self.settingsManager.credentials?.token).as(.default)) { result in
            switch result {
            case .success(let validateTokenResponse):
                self.settingsManager.user = validateTokenResponse.data
                self.settingsManager.credentials = Credentials(token: validateTokenResponse.data.token)
                
                GFACoordinator.shared.setRootToDocumentViewerTVController()
            case .failure:
                break
            }
            
            self.animate(false)
        }
    }
}
