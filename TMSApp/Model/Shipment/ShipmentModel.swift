//
//  ShipmentModel.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import Foundation

struct ShipmentResponse: Decodable {
    let success: Bool
    let code: Int
    let message: String
    let data: [Shipment]
}

struct Shipment: Decodable, Identifiable {
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
