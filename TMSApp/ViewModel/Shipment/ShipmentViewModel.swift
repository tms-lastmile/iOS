//
//  ShipmentViewModel.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 13/03/25.
//

import Foundation

class ShipmentViewModel: ObservableObject {
    @Published var shipment: Shipment
    
    init(shipment: Shipment) {
        self.shipment = shipment
    }
}
