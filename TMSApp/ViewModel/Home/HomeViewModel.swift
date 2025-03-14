//
//  HomeViewModel.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import Foundation

class HomeViewModel : ObservableObject {
    
    @Published var shipments: [Shipment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var shipmentNumQuery: String = ""
    
    func fetchShipments() {
        isLoading = true
        errorMessage = nil
        
        NetworkService.shared.fetchShipments { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let shipments):
                    self?.shipments = shipments
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func searchShipment() {
        guard !shipmentNumQuery.isEmpty else {
            fetchShipments()
            return
        }
        
        isLoading = true
        errorMessage = nil
        shipments = []
        
        NetworkService.shared.searchShipment(shipmentNum: shipmentNumQuery) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let shipments):
                    self?.shipments = shipments
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
