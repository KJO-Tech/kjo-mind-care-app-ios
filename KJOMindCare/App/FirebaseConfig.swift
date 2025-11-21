//
//  FirebaseConfig.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//

import FirebaseCore
final class FirebaseConfig {
    static func configureIfNeeded() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
}
