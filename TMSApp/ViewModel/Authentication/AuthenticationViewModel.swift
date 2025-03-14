//
//  AuthenticationViewModel.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 13/03/25.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var role: String = ""
    @Published var dc: String = ""
    @Published var isLoading: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?

    private let tokenKey = "authToken"
    private let userDefaults = UserDefaults.standard

    func login() {
        errorMessage = nil

        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Username dan password tidak boleh kosong!"
            return
        }

        isLoading = true

        NetworkService.shared.login(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let userData):
                    if userData.role == "Absolute Banten" || userData.role == "Absolute Jakarta" {
                        self.errorMessage = "Akses ditolak untuk role Absolute!"
                        self.isAuthenticated = false
                        self.username = ""
                        self.password = ""
                    } else {
                        KeychainHelper.shared.save(userData.token, forKey: self.tokenKey)

                        self.userDefaults.set(userData.username, forKey: "username")
                        self.userDefaults.set(userData.role, forKey: "role")
                        self.userDefaults.set(userData.dc, forKey: "dc")

                        self.username = ""
                        self.password = ""
                        self.isAuthenticated = true
                    }

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func checkAuth() {
        if KeychainHelper.shared.get(forKey: tokenKey) != nil{
            isAuthenticated = true
            username = userDefaults.string(forKey: "username") ?? ""
            role = userDefaults.string(forKey: "role") ?? ""
            dc = userDefaults.string(forKey: "dc") ?? ""
        }
    }

    func logout() {
        KeychainHelper.shared.delete(forKey: tokenKey)
        isAuthenticated = false
        username = ""
        role = ""
        dc = ""

        userDefaults.removeObject(forKey: "username")
        userDefaults.removeObject(forKey: "role")
        userDefaults.removeObject(forKey: "dc")
    }
}
