//
//  MainView.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import SwiftUI

enum Tab {
    case home
    case box
    case profile
}

struct MainView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Beranda", systemImage: "house.fill")
                }
                .tag(Tab.home)

            BoxView(refreshTrigger: selectedTab == .box)
                .tabItem {
                    Label("Box", systemImage: "cube.box.fill")
                }
                .tag(Tab.box)

            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
                .tag(Tab.profile)
        }
    }
}

#Preview {
    MainView()
}
