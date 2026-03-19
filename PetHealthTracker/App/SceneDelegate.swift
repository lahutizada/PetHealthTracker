//
//  SceneDelegate.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 28.02.26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
                self.window = window
                
                let coordinator = AppCoordinator(window: window)
                self.appCoordinator = coordinator
                coordinator.start()
                
                if let url = connectionOptions.urlContexts.first?.url {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.handleIncomingURL(url)
                    }
                }
            }
            
            func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
                guard let url = URLContexts.first?.url else { return }
                handleIncomingURL(url)
            }
            
    private func handleIncomingURL(_ url: URL) {
        print("Incoming URL:", url.absoluteString)
        
        guard url.scheme == "pethealthtracker" else { return }
        guard url.host == "reset-password" else { return }
        
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let token = components.queryItems?.first(where: { $0.name == "token" })?.value
        else { return }
        
        appCoordinator?.showResetPassword(token: token)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
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
    }
    
    
}
