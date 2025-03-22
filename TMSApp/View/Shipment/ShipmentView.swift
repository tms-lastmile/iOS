//
//  ShipmentView.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import SwiftUI

struct ShipmentView: View {
    @StateObject var viewModel: ShipmentViewModel
    @State private var selectedDeliveryOrder: DeliveryOrder?
    @State private var isShowingScanner = false
    @State private var showAlert = false

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Memuat detail pengiriman...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if let shipment = viewModel.shipment {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Spacer().frame(height: 4)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Nomor Pengiriman")
                                .font(.headline)

                            Text(shipment.shipmentNum)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.blue)

                            Divider()

                            DetailRow(title: "ETA", value: shipment.eta ?? "N/A")
                            DetailRow(title: "Total Jarak Tempuh", value: "\(shipment.totalDist) KM")
                            DetailRow(title: "Total Waktu Tempuh", value: "\(shipment.totalTime)")
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)

                        if !shipment.deliveryOrders.isEmpty {
                            Text("Delivery Orders")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack {
                                ForEach(shipment.deliveryOrders) { deliveryOrder in
                                    DeliveryOrderCardView(deliveryOrder: deliveryOrder) {
                                        selectedDeliveryOrder = deliveryOrder
                                        isShowingScanner = true
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            } else {
                Text("Pengiriman tidak ditemukan.")
                    .foregroundColor(.gray)
            }
        }
        .overlay {
            if viewModel.isUploading {
                ToastView(message: "Mengunggah file...")
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            viewModel.isUploading = false
                            showAlert = true
                        }
                    }
            }
        }
        .onAppear {
            viewModel.fetchShipmentDetail()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(viewModel.uploadSuccess == true ? "Sukses" : "Gagal"),
                message: Text(viewModel.uploadMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .fullScreenCover(isPresented: Binding(
            get: { isShowingScanner && selectedDeliveryOrder != nil },
            set: { if !$0 { isShowingScanner = false; selectedDeliveryOrder = nil } }
        )) {
            ScannerWrapper(onDone: { path in
                DispatchQueue.main.async {
                    isShowingScanner = false
                    viewModel.uploadPlyFile(forDirectory: path)
                    selectedDeliveryOrder = nil
                }
            })
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(value)
                    .bold()
            }
            Divider()
        }
    }
}

struct ToastView: View {
    let message: String

    var body: some View {
        VStack {
            Spacer()
            
            Text(message)
                .font(.body)
                .foregroundColor(.white)
            
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .shadow(radius: 10)
            .transition(.move(edge: .bottom))
            .animation(.easeInOut(duration: 0.3), value: message)
        }
        .padding(.bottom, 50)
    }
}

#Preview {
    ShipmentView(viewModel: ShipmentViewModel(shipmentId: 1))
}
