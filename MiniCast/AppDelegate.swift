//
//  AppDelegate.swift
//  MiniCast
//
//  Created by Ngoc Le on 07/06/2019.
//  Copyright © 2019 Coder Life. All rights reserved.
//

import UIKit
import XCGLogger
import GoogleCast

let log = XCGLogger.default

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let kReceiverAppID = kGCKDefaultMediaReceiverApplicationID
    let kDebugLoggingEnabled = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let criteria = GCKDiscoveryCriteria(applicationID: kReceiverAppID)
        let options = GCKCastOptions(discoveryCriteria: criteria)
        options.physicalVolumeButtonsWillControlDeviceVolume = true
        
        GCKCastContext.setSharedInstanceWith(options)
        
        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
        
        // Theme the cast button using UIAppearance.
        GCKUICastButton.appearance().tintColor = UIColor.gray
        
        // Enable logger.
        GCKLogger.sharedInstance().delegate = self
        
        GCKCastContext.sharedInstance().sessionManager.add(self)
        GCKCastContext.sharedInstance().imagePicker = self
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.gckExpandedMediaControlsTriggered,
                                                  object: nil)
    }
}

extension AppDelegate: GCKLoggerDelegate {
    
    // MARK - GCKLoggerDelegate
    func logMessage(_ message: String,
                    at level: GCKLoggerLevel,
                    fromFunction function: String,
                    location: String) {
        if (kDebugLoggingEnabled) {
            print(function + " - " + message)
        }
    }
}

// MARK: - GCKSessionManagerListener

extension AppDelegate: GCKSessionManagerListener {
    func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?) {
        if error == nil {
            if let view = window?.rootViewController?.view {
                Toast.displayMessage("Session ended", for: 3, in: view)
            }
        } else {
            let message = "Session ended unexpectedly:\n\(error?.localizedDescription ?? "")"
            showAlert(withTitle: "Session error", message: message)
        }
    }
    
    func sessionManager(_: GCKSessionManager, didFailToStart _: GCKSession, withError error: Error) {
        let message = "Failed to start session:\n\(error.localizedDescription)"
        showAlert(withTitle: "Session error", message: message)
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

// MARK: - GCKUIImagePicker

extension AppDelegate: GCKUIImagePicker {
    func getImageWith(_ imageHints: GCKUIImageHints, from metadata: GCKMediaMetadata) -> GCKImage? {
        let images = metadata.images
        guard !images().isEmpty else { print("No images available in media metadata."); return nil }
        if images().count > 1, imageHints.imageType == .background {
            return images()[1] as? GCKImage
        } else {
            return images()[0] as? GCKImage
        }
    }
}
