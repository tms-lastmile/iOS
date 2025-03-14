//
//  TMSAppApp.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import SwiftUI

@main
struct TMSApp: App {
    
    @StateObject private var authViewModel = AuthenticationViewModel()

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(authViewModel)
        }
    }
}
