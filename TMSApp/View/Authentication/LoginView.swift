//
//  LoginView.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 13/03/25.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        ZStack {
            if authViewModel.isAuthenticated {
                MainView()
            } else {
                VStack(spacing: 20) {
                    Image("TMSLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)

                    Text("Masuk TMSApp")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 20)

                    TextField("Nama Pengguna", text: $authViewModel.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .padding(.horizontal)

                    SecureField("Kata Sandi", text: $authViewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }

                    Button(action: {
                        authViewModel.login()
                    }) {
                        Text("Masuk")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .disabled(authViewModel.isLoading)
                }
                .padding()
                .onAppear {
                    authViewModel.checkAuth()
                }
            }

            if authViewModel.isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                ProgressView()
                    .scaleEffect(2)
                    .frame(width: 100, height: 100)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
        }
    }
}

#Preview {
    LoginView().environmentObject(AuthenticationViewModel())
}
