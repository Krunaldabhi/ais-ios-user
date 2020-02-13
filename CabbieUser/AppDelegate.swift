

//
//  AppDelegate.swift
//  Centros_Camprios
//
//  Created by imac on 12/18/17.
//  Copyright © 2017 Appoets. All rights reserved.
//

import UIKit
import UserNotifications
import GoogleMaps
import GooglePlaces
import GoogleSignIn
import IQKeyboardManagerSwift
import CoreData
import Intents
import Crashlytics
import Fabric
import Firebase
import FirebaseAuth
import FirebaseCore
import Stripe
import Reachability
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?
    private var reachability : Reachability?
    static let shared = AppDelegate()
    
    // Core Data
    lazy var persistentContainer : NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (descriptionString, error) in
            
            print("Error in Context  ",error ?? "")
        })
        return container
    }()
    
  
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.windows.forEach { window in
            if #available(iOS 13.0, *) {
                window.overrideUserInterfaceStyle = .light
            } else {
                // Fallback on earlier versions
            }
        }
        
        
     
        
        FirebaseApp.configure()
        self.appearence()
        Database.database().isPersistenceEnabled = true
        self.google()
        self.IQKeyboard()
        self.siri()
        self.registerPush(forApp: application)
        self.stripe()
       
        window?.rootViewController = Router.setWireFrame()
        window?.becomeKey()
        window?.makeKeyAndVisible()
        DispatchQueue.global(qos: .background).async {
            self.startReachabilityChecking()
        }
        self.checkUpdates()
        
        UIApplication.shared.windows.forEach { window in
            if #available(iOS 13.0, *) {
                window.overrideUserInterfaceStyle = .light
            } else {
                // Fallback on earlier versions
            }
        }
        
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to auth
        // Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.sandbox)
        // Messaging.messaging().apnsToken = deviceToken
        deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Apn Token ", deviceToken.map { String(format: "%02.2hhx", $0) }.joined())
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Notification  :  ", notification)
        
        let notificationType = notification["type"] as? String
        if notificationType == "chat" && notificationType != nil {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ChatPushRedirection"), object: nil)
            
        }else if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
    }
  

    func handleOpenUrl(_ url: URL, sourceApplication: String?) -> Bool {
      //her URL handling goes here.
        return false
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Error in Notification  \(error.localizedDescription)")
    }
    
}

//  Appearence
extension AppDelegate {
    
    private func appearence() {
        if let languageStr = UserDefaults.standard.value(forKey: Keys.list.language) as? String, let language = Language(rawValue: languageStr) {
            setLocalization(language: language)
        }
        else {
            setLocalization(language: .english)
        }
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = .darkGray
        var attributes = [NSAttributedString.Key : Any]()
        attributes.updateValue(UIColor.black, forKey: .foregroundColor)
        attributes.updateValue(UIFont.boldSystemFont(ofSize: 16), forKey : NSAttributedString.Key.font)
        UINavigationBar.appearance().titleTextAttributes = attributes
        attributes.updateValue(UIFont.boldSystemFont(ofSize: 18), forKey : NSAttributedString.Key.font)
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = attributes
        }
        UIPageControl.appearance().pageIndicatorTintColor = .lightGray
        UIPageControl.appearance().currentPageIndicatorTintColor = .primary
        UIPageControl.appearance().backgroundColor = .clear
    }
}

// Mark:- Version Update
extension AppDelegate {
    private func checkUpdates() {
        
        var request = ChatPush()
        request.version = Bundle.main.getVersion()
        request.device_type = .ios
        request.sender = .user
        Webservice().retrieve(api: .versionCheck, url: nil, data: request.toData(), imageData: nil, paramters: nil, type: .POST) { (error, data) in
            guard let responseObject = data?.getDecodedObject(from: ChatPush.self),
                let forceUpdate = responseObject.force_update,
                forceUpdate,
                let appUrl = responseObject.url,
                let urlObject = URL(string: appUrl),
                UIApplication.shared.canOpenURL(urlObject)
                else {
                    return
            }
            func showUpdateUI() {
                DispatchQueue.main.async {
                    let alert = showAlert(message: Constants.string.newVersionAvailableMessage.localize(), handler: { (_) in
                        UIApplication.shared.open(urlObject, options: [:], completionHandler: nil)
                        showUpdateUI()
                    })
                    UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
                }
            }
            showUpdateUI()
        }
    }
}

// Google & stripe
extension AppDelegate {
    
    private func google(){
        
        GMSServices.provideAPIKey(googleMapKey)
        GMSPlacesClient.provideAPIKey(googleMapKey)
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance()?.handle(url) ?? false
    }
    
    private func IQKeyboard() {
        IQKeyboardManager.shared.enable = false
    }
    
    // Stripe
    private func stripe(){
        STPPaymentConfiguration.shared().publishableKey = stripePublishableKey
    }
}

//MARK:- Siri
extension AppDelegate {
    
    private func siri() {
        
        if INPreferences.siriAuthorizationStatus() != .authorized {
            INPreferences.requestSiriAuthorization { (status) in
                
                print("Is Siri Authorized  -",status == .authorized)
            }
        }
    }
}

// MARK:- Reachability

extension AppDelegate {
    
    private func registerPush(forApp application : UIApplication){
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.alert, .sound]) { (granted, error) in
            
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    //  Offline Booking on No Internet Connection
    func startReachabilityChecking() {
        
        
        do {
            self.reachability = try Reachability()
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityAction), name: NSNotification.Name.reachabilityChanged, object: nil)
            try self.reachability?.startNotifier()
        } catch let err {
            print("Error in Reachability", err.localizedDescription)
        }
    }
    
    func stopReachability() {
        // Stop Reachability
        self.reachability?.stopNotifier()
    }
    
    // Reachability Action
    
    @objc private func reachabilityAction(notification : Notification) {
        
        print("Reachability \(self.reachability?.connection.description ?? .Empty)", #function)
        guard self.reachability != nil else { return }
        if self.reachability!.connection == .none && riderStatus == .none {
            if let rootView = UIApplication.shared.keyWindow?.rootViewController?.children.last, rootView.children.count > 0 , (rootView.children.last is HomeViewController), retrieveUserData() {
                rootView.modalPresentationStyle = .fullScreen 
                rootView.present(id: Storyboard.Ids.OfflineBookingViewController, animation: true)
            }
        } else {
            (UIApplication.topViewController() as? OfflineBookingViewController)?.dismiss(animated: true, completion: nil)
        }
    }
    
}


