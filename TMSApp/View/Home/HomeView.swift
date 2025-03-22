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
                if viewModel.shipmentNumQuery.isEmpty {
                    VStack {
                        HStack {
                            Picker("Halaman", selection: $viewModel.currentPage) {
                                ForEach(1...viewModel.totalPages, id: \.self) { page in
                                    Text("Halaman \(page)").tag(page)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: viewModel.currentPage) {
                                viewModel.fetchShipments()
                            }
                            
                            Stepper(value: $viewModel.perPage, in: 5...20, step: 5) {
                                Text("\(viewModel.perPage) / halaman")
                            }
                            .onChange(of: viewModel.perPage) {
                                viewModel.currentPage = 1
                                viewModel.fetchShipments()
                            }
                        }
                        .padding()
                    }
                }
                
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Memuat pengiriman...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        Spacer()
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                    }
                } else if viewModel.shipments.isEmpty {
                    VStack {
                        Spacer()
                        Text("Tidak ada pengiriman yang ditemukan")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                    }
                } else {
                    List(viewModel.shipments, id: \.id) { shipment in
                        NavigationLink(
                            destination: ShipmentView(viewModel: ShipmentViewModel(shipmentId: shipment.id))
                        ) {
                            ShipmentCardView(shipment: shipment)
                        }

                    }
                    .listStyle(PlainListStyle())
                }
                
                VStack {
                    if viewModel.isSearchActive {
                        Text("\(viewModel.shipments.count) hasil ditemukan")
                            .font(.footnote)
                            .padding(.top, 5)
                    } else {
                        Text("Menampilkan halaman \(viewModel.currentPage) dari \(viewModel.totalPages)")
                            .font(.footnote)
                            .padding(.top, 5)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 10)
            }
            .navigationTitle("Pengiriman")
            .searchable(text: $viewModel.shipmentNumQuery, prompt: "Cari nomor pengiriman...")
            .onChange(of: viewModel.shipmentNumQuery) {
                if viewModel.shipmentNumQuery.isEmpty {
                    viewModel.fetchShipments()
                }
            }
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
