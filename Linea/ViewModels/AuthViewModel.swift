//
//  AuthViewModel.swift
//  Linea
//

import Foundation
import GoogleSignIn
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var user: GIDGoogleUser?
    @Published var isSignedIn: Bool = false
    
    func signInWithGoogle() {
        guard let rootViewController = getRootViewController() else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Google Sign-In Error: \(error.localizedDescription)")
                return
            }
            
            guard let result = result else { return }
            
            self.user = result.user
            self.isSignedIn = true
            
            print(result.user.profile?.name ?? "No Name")
            print(result.user.profile?.email ?? "No Email")
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            return nil
        }
        return getVisibleViewController(from: rootViewController)
    }
    
    private func getVisibleViewController(from vc: UIViewController) -> UIViewController {
        if let nav = vc as? UINavigationController {
            return getVisibleViewController(from: nav.visibleViewController!)
        }
        if let tab = vc as? UITabBarController {
            return getVisibleViewController(from: tab.selectedViewController!)
        }
        if let presented = vc.presentedViewController {
            return getVisibleViewController(from: presented)
        }
        return vc
    }
}

