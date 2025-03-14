//
//  ProfileView.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showLogoutConfirmation = false

    private var username: String {
        UserDefaults.standard.string(forKey: "username") ?? "N/A"
    }
    
    private var role: String {
        UserDefaults.standard.string(forKey: "role") ?? "N/A"
    }
    
    private var dc: String {
        UserDefaults.standard.string(forKey: "dc") ?? "N/A"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    Text(username)
                        .font(.title2)
                        .bold()
                        .padding(.top, 5)
                }
                
                VStack(spacing: 12) {
                    ProfileInfoRow(icon: "briefcase.fill", title: "Peran", value: role)
                    ProfileInfoRow(icon: "building.2.fill", title: "Distribution Center", value: dc)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Profil")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Keluar")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .alert("Konfirmasi Keluar", isPresented: $showLogoutConfirmation) {
                Button("Batal", role: .cancel) { }
                Button("Keluar", role: .destructive) {
                    authViewModel.logout()
                }
            } message: {
                Text("Apakah Anda yakin ingin keluar?")
            }
        }
    }
}

struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.blue)
            Text(title)
                .font(.body)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.body)
                .bold()
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ProfileView().environmentObject(AuthenticationViewModel())
}
