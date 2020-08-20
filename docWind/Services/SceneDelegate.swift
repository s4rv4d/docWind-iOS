//
//  SceneDelegate.swift
//  docWind
//
//  Created by Sarvad shetty on 6/30/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import UIKit
import SwiftUI
import LocalAuthentication
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Get the managed object context from the shared persistent container.
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if AppSettings.shared.settingsURL() != nil {
            _ = AppSettings.shared.load()
            
            // to check if app is deleted or fresh start
            let fetchRequest = NSFetchRequest<DirecModel>(entityName: "DirecModel")
            fetchRequest.predicate = NSPredicate(format: "name == %@", "DocWind")
            
            do {
                let content = try context.fetch(fetchRequest)
                if let _ = content.first{
                    print("data is present no need of resetting")
                } else {
                    // reset
                    print("NO DOCWIND dorec so reset")
                    DWFMAppSettings.shared.reset()
                    AppSettings.shared.phoneSec = false
                    AppSettings.shared.firstLoginDone = false
                    _ = AppSettings.shared.update()
                }
                
            } catch {
                print("NO DOCWIND dorec so reset")
                print("❌ ERROR RETRIEVING DATA FOR DOCWIND DIRECTORY")
                // do reset
                DWFMAppSettings.shared.reset()
                AppSettings.shared.phoneSec = false
                AppSettings.shared.firstLoginDone = false
                _ = AppSettings.shared.update()
            }
            
            
            let contentView = ContentView().environment(\.managedObjectContext, context)
                

            // Use a UIHostingController as window root view controller.
            if let windowScene = scene as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = UIHostingController(rootView: contentView)
                self.window = window
                window.makeKeyAndVisible()
            }
            
        } else {
            print("NIL")
            let errorView = ErrorView()
            // Use a UIHostingController as window root view controller.
            if let windowScene = scene as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = UIHostingController(rootView: errorView)
                self.window = window
                window.makeKeyAndVisible()
            }
        }
        
//
//        AppSettings.shared.firstLoginDone = false
//        _ = AppSettings.shared.update()
//
//        DWFMAppSettings.shared.reset()

        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
        
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
        
        AppStoreUpdate.shared.showAppStoreVersionUpdateAlert(isForceUpdate: true)
        
        if AppSettings.shared.phoneSec {
            authenticateViewGlobal()
        } else{
            print("false")
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

}

func authenticateViewGlobal() {
    let context = LAContext()
    var error: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        let reason = "Unlock app"
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, authError) in
            DispatchQueue.main.async {
                if success {
//                    self.check()
                } else {
                    authenticateViewGlobal()
                }
            }
        }
    } else {
        //show error
    }
}
