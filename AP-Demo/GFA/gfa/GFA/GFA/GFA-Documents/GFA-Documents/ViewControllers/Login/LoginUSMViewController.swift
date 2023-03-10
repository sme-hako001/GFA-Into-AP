//
//  LoginUSMViewController.swift
//  GTA
//
//  Created by Margarita N. Bock on 20.11.2020.
//

import UIKit
import WebKit

class LoginUSMViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    private var usmWebView: WKWebView!
    /*private var dataProvider: LoginDataProvider = LoginDataProvider()*/
    private let apiService: SMEAPI2 = SMEAPI2.shared
    private let settingsManager: SMESettingsManager = SMESettingsManager()!
    private let dialogService: DialogService = DialogService()

    private let shortRequestTimeoutInterval: Double = 24
    weak var showErrorAlertDelegate: ShowErrorAlertDelegate?
    
    var emailAddress = ""
    var token: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usmWebView = WKWebView(frame: CGRect.zero)
        usmWebView.translatesAutoresizingMaskIntoConstraints = false
        usmWebView.scrollView.showsVerticalScrollIndicator = false
        usmWebView.scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(usmWebView)
        NSLayoutConstraint.activate([
            usmWebView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            usmWebView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            usmWebView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            usmWebView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        usmWebView.navigationDelegate = self
        loadUsmLogon()
    }
    
    func removeCookies() {
        let cookieStore = usmWebView.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { cookies in
            for cookie in cookies {
                cookieStore.delete(cookie)
            }
        }
    }
    
    private func loadUsmLogon() {
        if !token.isEmptyOrWhitespace() {
            validateToken(token: token)
            return
        }
        removeCookies()
        
        let nonceStr = String(format: "%.6f", NSDate.now.timeIntervalSince1970)
        guard let redirectURIStr = USMSettings.usmRedirectURL.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else { return }
        let authURLString = "\(USMSettings.usmBasicURL)?response_type=code&scope=openid&client_id=\(USMSettings.usmClientID)&state=\(SMEUtils.stateStr(nonceStr))&nonce=\(nonceStr)&redirect_uri=\(redirectURIStr)&email=\(emailAddress)"
        if let authURL = URL(string: authURLString) {
            let authRequest = URLRequest(url: authURL, timeoutInterval: shortRequestTimeoutInterval)
            usmWebView.load(authRequest)
        }
    }
    
    private func displayErrorMessage(_ title: String, _ message: String) {
        self.dialogService.displayAlert(title: title,
                                        message: message,
                                        okButton: ("alertCloseButtonTitle".localized, .default, .none))
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToLogin", sender: nil)
    }
    
    // MARK: - REST API Methods -

    private func validateToken(token: String) {
        /*dataProvider.validateToken(token: token, userEmail: emailAddress) { [weak self] (_ errorCode: Int, _ error: Error?) in
         DispatchQueue.main.async {
         if error == nil && errorCode == 200 {
         UserDefaults.standard.set(true, forKey: "userLoggedIn")
         PushNotificationsManager().sendPushNotificationTokenIfNeeded()
         let authVC = AuthViewController()
         authVC.isSignUp = true
         if let sceneDelegate = self?.view.window?.windowScene?.delegate as? SceneDelegate {
         authVC.delegate = sceneDelegate
         }
         self?.navigationController?.pushViewController(authVC, animated: true)
         } else {
         self?.performSegue(withIdentifier: "unwindToLogin", sender: nil)
         }
         self?.usmWebView.alpha = 1
         self?.activityIndicator.stopAnimating()
         }
         }*/
        
        self.settingsManager.credentials = Credentials(token: token)
        
        self.apiService.validateToken(token) { result in
            switch result {
            case .success(let validateTokenResponse):
                self.settingsManager.user = validateTokenResponse.data
                self.settingsManager.credentials = Credentials(token: validateTokenResponse.data.token)
                
                GFACoordinator.shared.setRootToDocumentViewerTVController()
            case .failure(let error):
                self.settingsManager.credentials = Credentials()
                
                self.displayErrorMessage("alertLoginFailedTitle".localized, error.message)
            }
        }
    }
}

extension LoginUSMViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        //TODO: add error handling
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        guard let navigationRequestURL = navigationAction.request.url else { return }
        
        //TODO: implement logout functionality if necessary
        
        if navigationRequestURL.absoluteString.hasPrefix(USMSettings.usmRedirectURL) && navigationAction.request.timeoutInterval > shortRequestTimeoutInterval {
            let authRequest = URLRequest(url: navigationRequestURL, timeoutInterval: shortRequestTimeoutInterval)
            decisionHandler(.cancel)
            usmWebView.load(authRequest)
            return
        }
        if navigationRequestURL.absoluteString.contains("app_code=1160") {
            showLoginFailedAlert(message: "Your account is not setup properly. Please, contact your administrator.",
                                 title: "alertLoginFailedTitle".localized)
            decisionHandler(.cancel)
            return
        }
        if navigationRequestURL.absoluteString.contains("app_code=1267") {
            showLoginFailedAlert(message: "You don't have an account. Please, contact your administrator.",
                                 title: "alertLoginFailedTitle".localized)
            decisionHandler(.cancel)
            return
        }
        if navigationRequestURL.absoluteString.contains("app_code=1297") {
            showLoginFailedAlert(message: "An unexpected error occurred. Please try logging in again.",
                                 title: "alertLoginFailedTitle".localized)
            decisionHandler(.cancel)
            return
        }
        if navigationRequestURL.absoluteString.hasPrefix(USMSettings.usmInternalRedirectURL) {
            guard let correctParsingFormatURL = URL(string: navigationRequestURL.absoluteString.replacingOccurrences(of: USMSettings.usmInternalRedirectURL, with: "https://correctparsingformat.com")) else {
                decisionHandler(.cancel)
                return
            }
            guard let aToken = SMEUtils.valueOf(param: "access_token", forURL: correctParsingFormatURL) else {
                decisionHandler(.cancel)
                return
            }
            validateToken(token: aToken)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {

    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //TODO: implement logout functionality if necessary
    }
    
    private func showLoginFailedAlert(message: String, title: String?) {
//        self.performSegue(withIdentifier: "unwindToLogin", sender: nil)
//        showErrorAlertDelegate?.showAlert(title: title, message: message)
        
        self.displayErrorMessage(title.as("alertLoginFailedTitle".localized), message)
    }
}

protocol ShowErrorAlertDelegate: AnyObject {
    func showAlert(title: String?, message: String?)
}
