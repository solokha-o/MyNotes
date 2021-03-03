//
//  SignInViewController.swift
//  MyNotes
//
//  Created by Oleksandr Solokha on 24.02.2021.
//  Copyright © 2021 Oleksandr Solokha. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SignInViewController: UIViewController {
    
    //configure state of controller: sign-in and sing-up
    enum State {
        case signIn, signUp
        
        var authorisationLabelTitle: String {
            switch self {
                case .signIn: return "Sign-in MyNotes"
                case .signUp: return "Sign-up MyNotes"
            }
        }
        
        var signInButtonOutletTitle: String {
            switch self {
                case .signIn: return "Sign-in"
                case .signUp: return "Sign-up"
            }
        }
        
        var signUpLabelState: Bool {
            switch self {
                case .signIn: return false
                case .signUp: return true
            }
        }
        
        var signUpButtonOutletTitle: String {
            switch self {
                case .signIn: return "Sing-up"
                case .signUp: return "Cancel"
            }
        }
        
        var signInByGoogleButtonOutletState: Bool{
            switch self {
                case .signIn: return false
                case .signUp: return true
            }
        }
    }
    
    var currentState: State = .signIn
    
    //add all components of controller to stack view
    @IBOutlet weak var signInStackView: UIStackView!
    //add all components of controller
    @IBOutlet weak var authorisationLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel! {
        didSet {
            emailLabel.text = "E-mail"
        }
    }
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.placeholder = "Enter your e-mail"
            emailTextField.leftView = UIImageView(image: UIImage(systemName: "person.circle"))
            emailTextField.leftViewMode = .always
            emailTextField.delegate = self
            emailTextField.clipsToBounds = true
            emailTextField.layer.cornerRadius = 10.0
        }
    }
    @IBOutlet weak var passwordLabel: UILabel! {
        didSet {
            passwordLabel.text = "Password"
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.placeholder = "Enter your password"
            passwordTextField.leftView = UIImageView(image: UIImage(systemName: "lock"))
            passwordTextField.leftViewMode = .always
            passwordTextField.delegate = self
            passwordTextField.clipsToBounds = true
            passwordTextField.layer.cornerRadius = 10.0
        }
    }
    @IBOutlet weak var signInButtonOutlet: UIButton!
    @IBOutlet weak var signUpLabel: UILabel! {
        didSet {
            signUpLabel.text = "If you not sign-up press ⬇️"
        }
    }
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    //add sign-in button outlet
    @IBOutlet weak var signInByGoogleButtonOutlet: UIButton! {
        didSet {
            signInByGoogleButtonOutlet.setTitle("Sign-in by Google", for: .normal)
            signInByGoogleButtonOutlet.setImage(UIImage(named: "google"), for: .normal)
            signInByGoogleButtonOutlet.clipsToBounds = true
            signInByGoogleButtonOutlet.layer.cornerRadius = 10.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //make controller like presenting controller google sign-in
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        setupController()
        hideKeyboardTappedScreen()
    }
    //configure sing-in button action
    @IBAction func signInButtonAction(_ sender: UIButton) {
        authorisationAction()
    }
    //configure sing-up button action
    @IBAction func signUpButtonAction(_ sender: UIButton) {
        switch currentState {
            case .signIn:
                currentState = .signUp
                UIView.transition(with: signInStackView, duration: 0.5, options: .transitionFlipFromTop) {
                    self.setupController()
                }
            case .signUp:
                currentState = .signIn
                UIView.transition(with: signInStackView, duration: 0.5, options: .transitionFlipFromBottom) {
                    self.setupController()
                }
        }
    }
    @IBAction func signInGoogleButtonAction(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    //configure alert that can show message with error
    func errorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //configure sing-in action and sing-up action
    func authorisationAction() {
        //get email and password from TextField
        let userEmail = emailTextField.text
        let userPassword = passwordTextField.text
        var errorMessage = ""
        if let email = userEmail, let password = userPassword {
            switch currentState {
                // if state of controller sing-up create new user and check entering information
                case .signUp:
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let error = error as NSError? {
                            switch AuthErrorCode(rawValue: error.code) {
                                case .emailAlreadyInUse:
                                    // Error: The email address is already in use by another account.
                                    errorMessage = "⛔️\nEmail is already in use by another account."
                                case .invalidEmail:
                                    // Error: The email address is badly formatted.
                                    errorMessage = "⛔️\nThe email address is badly formatted"
                                case .weakPassword:
                                    // Error: The password must be 6 characters long or more.
                                    errorMessage = "⛔️\nThe password must be 6 characters long or more"
                                default:
                                    print("Error: \(error.localizedDescription)")
                            }
                            self.errorAlert(with: errorMessage)
                        } else {
                            //if sing-up is successfully user can sing-in
                            print("User signs up successfully")
                            errorMessage = "👍\nSign-up is successfully! Now you can sing-in."
                            self.errorAlert(with: errorMessage)
                            UIView.transition(with: self.signInStackView, duration: 0.5, options: .transitionFlipFromBottom) {
                                self.currentState = .signIn
                                self.setupController()
                            }
                        }
                    }
                //if state of controller is sing-in user can to enter email and password and its check
                case .signIn:
                    Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                        if let error = error as NSError? {
                            switch AuthErrorCode(rawValue: error.code) {
                                case .userDisabled:
                                    // Error: The user account has been disabled by an administrator.
                                    errorMessage = "⛔️\nAccount has been block. Please, will write to oleksandr.solokha@gmail.com."
                                case .wrongPassword:
                                    // Error: The password is invalid or the user does not have a password.
                                    errorMessage = "⛔️\nThe email or the password is invalid."
                                case .invalidEmail:
                                    // Error: Indicates the email address is malformed.
                                    errorMessage = "⛔️\nThe email or the password is invalid."
                                default:
                                    print("Error: \(error.localizedDescription)")
                            }
                            self.errorAlert(with: errorMessage)
                        } else {
                            print("User signs in successfully")
                            //configure transition to MyNotesNavigationController when user log in
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            guard let myNotesTVC = storyboard.instantiateViewController(withIdentifier: "MyNotesNavigationController") as? UINavigationController else { return }
                            guard let window = UIApplication.shared.windows.first else {
                                return
                            }
                            UIView.transition(with: window, duration: 0.5, options: .transitionCurlUp) {
                                window.rootViewController = myNotesTVC
                            }
                            window.makeKeyAndVisible()
                        }
                    }
            }
        } else {
            errorMessage = "⛔️\nPlease, enter email and password"
            errorAlert(with: errorMessage)
        }
    }
    
    //configure controller and all his components
    func setupController() {
        switch currentState {
            case .signIn:
                authorisationLabel.text = currentState.authorisationLabelTitle
                signInButtonOutlet.setTitle(currentState.signInButtonOutletTitle, for: .normal)
                signUpLabel.isHidden = currentState.signUpLabelState
                signUpButtonOutlet.setTitle(currentState.signUpButtonOutletTitle, for: .normal)
                signInByGoogleButtonOutlet.isHidden = currentState.signInByGoogleButtonOutletState
            case .signUp:
                authorisationLabel.text = currentState.authorisationLabelTitle
                signInButtonOutlet.setTitle(currentState.signInButtonOutletTitle, for: .normal)
                signUpLabel.isHidden = currentState.signUpLabelState
                signUpButtonOutlet.setTitle(currentState.signUpButtonOutletTitle, for: .normal)
                signInByGoogleButtonOutlet.isHidden = currentState.signInByGoogleButtonOutletState
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
//hide keyboard when tap on screen
extension UIViewController {
    func hideKeyboardTappedScreen() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//change textField by return key
extension SignInViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
            authorisationAction()
        }
        return true
    }
}
