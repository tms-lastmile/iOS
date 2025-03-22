//
//  DeliveryOrderModel.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import Foundation

struct DeliveryOrder: Decodable, Identifiable {
    let id: Int
    let deliveryOrderNum: String
    var boxes: [Box] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case deliveryOrderNum = "delivery_order_num"
        case boxes
    }
}
