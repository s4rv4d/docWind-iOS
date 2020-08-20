//
//  AppstoreUpdate.swift
//  docWind
//
//  Created by Sarvad shetty on 8/14/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import UIKit

enum CustomError: Error {
   case jsonReading
   case invalidIdentifires
   case invalidURL
   case invalidVersion
   case invalidAppName
}

class AppStoreUpdate: NSObject {
    
    static let shared = AppStoreUpdate()

    func showAppStoreVersionUpdateAlert(isForceUpdate: Bool) {
        
        do {
            //Get Bundle Identifire from Info.plist
            guard let bundleIdentifire = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String else {
                print("No Bundle Info found.")
                throw CustomError.invalidIdentifires
            }
            
            // Build App Store URL
            guard let url = URL(string:"http://itunes.apple.com/lookup?bundleId=" + bundleIdentifire) else {
                print("Is with generating URL.")
                throw CustomError.invalidURL
            }
            
            let serviceTask = URLSession.shared.dataTask(with: url) { (responseData, response, error) in
                
                do {
                    // Check error
                    if let error = error { throw error }
                    //Parse response
                    guard let data = responseData else { throw CustomError.jsonReading }
                    let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let itunes = ItunesAppInfoItunes.init(fromDictionary: result as! [String : Any])
                    print(itunes.results!)
                    if let itunesResult = itunes.results.first {
                        print("App Store Varsion: ",itunesResult.version!)
                        
                        //Get Bundle Version from Info.plist
                        guard let appShortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                            print("No Short Version Info found.")
                            throw CustomError.invalidVersion
                        }
                        
                        print("local phone app version SIMULATOR: \(appShortVersion)")
                        
                        if appShortVersion >= itunesResult.version {
                            //App Store & Local App Have same Version.
                            print("Same Version at both side or maybe this version is higher")
                        } else {
                            //Show Update alert
                            var message = ""
                            //Get Bundle Version from Info.plist
                            if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
                                message = "\(appName) has new version(\(itunesResult.version!)) available on App Store."
                            } else {
                                message = "This app has new version(\(itunesResult.version!)) available on App Store."
                            }
                            
                            //Show Alert on main thread
                            DispatchQueue.main.async {
                                self.showUpdateAlert(message: message, appStoreURL: itunesResult.trackViewUrl, isForceUpdate: isForceUpdate)
                            }
                        }
                    }
                } catch {
                    print(error)
                }
            }
            serviceTask.resume()
        } catch {
            print(error)
        }
    }
    
    func showUpdateAlert(message : String, appStoreURL: String, isForceUpdate: Bool) {
        
        let controller = UIAlertController(title: "New Version", message: message, preferredStyle: .alert)
        
        //Optional Button
        if !isForceUpdate {
            controller.addAction(UIAlertAction(title: "Later", style: .cancel, handler: { (_) in }))
        }
        
        controller.addAction(UIAlertAction(title: "Update", style: .default, handler: { (_) in
            guard let url = URL(string: appStoreURL) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
        }))
        
//        let applicationDelegate = UIApplication.shared.delegate as? AppDelegate
//        applicationDelegate?.window?.rootViewController?.present(controller, animated: true)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let sceneDelegate = windowScene.delegate as? SceneDelegate
            else { return }
        sceneDelegate.window?.rootViewController?.present(controller, animated: true)
        
    }
}
