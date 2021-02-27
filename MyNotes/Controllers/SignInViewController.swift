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
    
    //add sign-in button outlet
    @IBOutlet weak var signInButtonOutlet: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //make controller like presenting controller google sign-in
        GIDSignIn.sharedInstance()?.presentingViewController = self
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
