//
//  HomeView.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Memuat pengiriman...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                   Text("Error: \(errorMessage)")
                       .foregroundColor(.red)
                       .padding()
                } else if viewModel.shipments.isEmpty {
                   Text("Tidak ada pengiriman yang ditemukan")
                       .font(.headline)
                       .foregroundColor(.gray)
                       .padding()
                } else {
                   List(viewModel.shipments) { shipment in
                       NavigationLink(destination: ShipmentView(viewModel: ShipmentViewModel(shipment: shipment))) {
                           ShipmentCardView(shipment: shipment)
                       }
                   }
                   .listStyle(PlainListStyle())
               }
            }
            .navigationTitle("Pengiriman")
            .searchable(text: $viewModel.shipmentNumQuery, prompt: "Cari nomor pengiriman...")
            .onSubmit(of: .search) {
                viewModel.searchShipment()
            }
            .onAppear {
                if viewModel.shipments.isEmpty {
                    viewModel.fetchShipments()
                }
            }
        }
    }
}


#Preview {
    HomeView()
}
