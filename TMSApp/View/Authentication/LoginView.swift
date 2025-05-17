//
//  LoginView.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 13/03/25.
//

import SwiftUI
import UIKit

struct LoginView: View {
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    hideKeyboard()
                }

            if authViewModel.isAuthenticated {
                MainView()
            } else {
                VStack {
                    Spacer()
                
                    Image("TMSLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.bottom, 10)
                    
                    Text("Masuk ke TMSApp")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.black.opacity(0.8))

                    VStack(spacing: 14) {
                        TextField("Nama Pengguna", text: $authViewModel.username)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        SecureField("Kata Sandi", text: $authViewModel.password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 20)

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                    }

                    Button(action: {
                        hideKeyboard()
                        authViewModel.login()
                    }) {
                        Text(authViewModel.isLoading ? "Memproses..." : "Masuk")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(authViewModel.isLoading ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 3)
                            .animation(.easeInOut(duration: 0.2), value: authViewModel.isLoading)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 20)
                    .disabled(authViewModel.isLoading)

                    Spacer()

                    Text("© 2025 TMSApp. All Rights Reserved.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
            }

            if authViewModel.isLoading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    
                    Text("Sedang masuk...")
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding(.top, 8)
                }
                .padding(20)
                .background(Color.black.opacity(0.8))
                .cornerRadius(10)
                .shadow(radius: 10)
            }
        }
        .onAppear {
            authViewModel.checkAuth()
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    LoginView().environmentObject(AuthenticationViewModel())
}
