//
//  LoginResponse.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 13/03/25.
//
import Foundation

struct LoginResponse: Codable {
    let success: Bool
    let code: Int
    let message: String
    let data: LoginData?
    let error: String?
}

struct LoginData: Codable {
    let token: String
    let username: String
    let role: String
    let dc: String?
}
