//
//  BoxModel.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 22/03/25.
//

import Foundation

struct Box: Identifiable, Decodable {
    let id: String
    var height: Double
    var width: Double
    var length: Double
    var pcUrl: String?
    var scannedAt: String?
    var isSaved: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, height, width, length, pcUrl, scannedAt, isSaved
    }
}
