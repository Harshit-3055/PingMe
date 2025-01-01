//
//  PingMeApp.swift
//  PingMe
//
//  Created by Harshit Agarwal on 04/10/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        return true
    }
}

@main
struct PingMeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false
    
    var body: some Scene {
        WindowGroup {
            ChatListView()
                .onAppear {
                    // Update login state if user exists
                    if Auth.auth().currentUser != nil {
                        isUserLoggedIn = true
                    }
                }
        }
    }
}
