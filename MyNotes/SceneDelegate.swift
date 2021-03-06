//
//  SceneDelegate.swift
//  MyNotes
//
//  Created by Oleksandr Solokha on 01.06.2020.
//  Copyright © 2020 Oleksandr Solokha. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    //configure scene if user sign-in and log out
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let storyboard =  UIStoryboard(name: "Main", bundle: nil)
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            if Auth.auth().currentUser != nil {
                // redirect to the main controller
                self.window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "MyNotesNavigationController") as! UINavigationController
                self.window!.makeKeyAndVisible()
            } else {
                // redirect to the login controller
                self.window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                self.window!.makeKeyAndVisible()
            }
        }
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
    }
    
    // handle the sign in to redirect to the main controller
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let storyboard =  UIStoryboard(name: "Main", bundle: nil)
            // redirect the user to the main controller
            //add transition to MyNotesNavigationController when user sing-in
            UIView.transition(with: self.window!, duration: 0.5, options: .transitionCurlUp) {
                self.window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "MyNotesNavigationController") as! UINavigationController
            }
            self.window!.makeKeyAndVisible()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            //configure transition to SignInViewController  when user log out
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let signInVC = storyboard.instantiateViewController(identifier: "SignInViewController") as? SignInViewController else { return }
            guard let window = UIApplication.shared.windows.first else {
                return
            }
            UIView.transition(with: window, duration: 0.5, options: .transitionCurlDown) {
                window.rootViewController = signInVC
            }
            window.makeKeyAndVisible()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

