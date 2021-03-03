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
    
    
    //add all components of controller
    @IBOutlet weak var authorisationLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButtonOutlet: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    //add sign-in button outlet
    @IBOutlet weak var signInByGoogleButtonOutlet: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //make controller like presenting controller google sign-in
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        setupController()
    }
    
    @IBAction func signInButtonAction(_ sender: UIButton) {
    }
    //configure sing-up button action
    @IBAction func signUpButtonAction(_ sender: UIButton) {
        switch currentState {
            case .signIn:
                currentState = .signUp
                UIView.animate(withDuration: 0.5, animations: {
                    self.setupController()
                })
            case .signUp:
                currentState = .signIn
                UIView.animate(withDuration: 0.5, animations: {
                    self.setupController()
                })
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
        emailLabel.text = "E-mail"
        passwordLabel.text = "Password"
        signUpLabel.text = "If you not sign-up press ⬇️"
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
