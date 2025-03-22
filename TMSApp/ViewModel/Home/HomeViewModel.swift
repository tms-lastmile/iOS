//
//  HomeViewModel.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    
    @Published var shipments: [ShipmentSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var shipmentNumQuery: String = ""
    @Published var isSearchActive = false
    
    @Published var currentPage = 1
    @Published var perPage = 5
    @Published var totalPages = 1
    @Published var totalShipments = 0

    func fetchShipments() {
        isLoading = true
        errorMessage = nil
        shipments = []
        isSearchActive = false

        let skip = (currentPage - 1) * perPage

        NetworkService.shared.fetchShipments(skip: skip, limit: perPage) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let data):
                    self?.shipments = data.shipments
                    self?.totalShipments = data.total
                    self?.totalPages = max(1, (data.total + self!.perPage - 1) / self!.perPage)
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
        isSearchActive = true
        
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
