//
//  MainView.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Beranda", systemImage: "house.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
            }
        }
}

#Preview {
    MainView()
}
