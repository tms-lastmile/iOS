//
//  ShipmentModel.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import Foundation

struct ShipmentSummary: Identifiable, Decodable {
    let id: Int
    let shipmentNum: String
    let status: String
    let eta: String?

    enum CodingKeys: String, CodingKey {
        case id
        case shipmentNum = "shipment_num"
        case status
        case eta
    }
}

struct ShipmentData: Decodable {
    let currentSkip: Int
    let nextSkip: Int?
    let prevSkip: Int?
    let perPage: Int
    let total: Int
    let shipments: [ShipmentSummary]

    enum CodingKeys: String, CodingKey {
        case shipments
        case currentSkip = "current_skip"
        case nextSkip = "next_skip"
        case prevSkip = "prev_skip"
        case perPage = "per_page"
        case total
    }
}

struct Shipment: Identifiable, Decodable {
    let id: Int
    let shipmentNum: String
    let status: String
    let eta: String?
    let totalDist: Double
    let totalTime: Double
    let plateNumber: String
    let deliveryOrders: [DeliveryOrder]

    enum CodingKeys: String, CodingKey {
        case id
        case shipmentNum = "shipment_num"
        case status
        case eta
        case totalDist = "total_dist"
        case totalTime = "total_time"
        case plateNumber = "plate_number"
        case deliveryOrders
    }
}

struct ShipmentListResponse: Decodable {
    let success: Bool
    let code: Int
    let message: String
    let data: ShipmentData
}

struct ShipmentResponse: Decodable {
    let success: Bool
    let code: Int
    let message: String
    let data: Shipment
}


struct ShipmentSearchResponse: Decodable {
    let success: Bool
    let code: Int
    let message: String
    let data: [ShipmentSummary]
}
