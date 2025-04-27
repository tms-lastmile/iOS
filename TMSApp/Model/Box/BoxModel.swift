//
//  BoxModel.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 22/03/25.
//

import Foundation

struct Box: Identifiable, Decodable {
    let id: String
    var name: String
    var height: Double
    var width: Double
    var length: Double
    var pcUrl: String?
    var scannedAt: String?
    var isSaved: Bool = false
    var quantity: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, height, width, length, pcUrl, scannedAt, isSaved, quantity
    }
}

struct BoxResponse: Codable {
    let success: Bool
    let code: Int
    let message: String?
    let data: BoxData?
    let error: String?
}

struct BoxData: Codable {
    let id: String
    let name: String
    let height: Double
    let width: Double
    let length: Double
    let pcUrl: String?
    let scannedAt: String?
    let isSaved: Bool
    let status: String
}
