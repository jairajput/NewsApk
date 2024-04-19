//
//  NewsApkApp.swift
//  NewsApk
//
//  Created by Jai  on 18/04/24.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct NewsApkApp: App {
    init() {
        // Firebase initialization
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView().onOpenURL { url in
                    //Handle Google Oauth URL
                    GIDSignIn.sharedInstance.handle(url)
                }
            }
        }
    }
}
    class AppDelegate:NSObject,UIApplicationDelegate{
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            FirebaseApp.configure()
            return true
            
        }
        func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
            return.noData
        }
    }

