//
//  KJOMindCareApp.swift
//  KJOMindCare
//
//  Created by Yisus on 16/11/25.
//

import SwiftUI
import FirebaseCore

@main
struct KJOMindCareApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let diContainer = DIContainer.shared
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            
        }
    }
}
