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
    @State private var showToast = false
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nomor Pengiriman")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text(viewModel.shipment.shipmentNum)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.blue)
                        
                        Divider()
                        
                        DetailRow(title: "ETA", value: viewModel.shipment.eta ?? "N/A")
                        DetailRow(title: "Total Jarak Tempuh", value: "\(viewModel.shipment.totalDist) KM")
                        DetailRow(title: "Total Waktu Tempuh", value: "\(viewModel.shipment.totalTime)")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    if !viewModel.shipment.deliveryOrders.isEmpty {
                        Text("Delivery Orders")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack {
                            ForEach(viewModel.shipment.deliveryOrders) { deliveryOrder in
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
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
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
    ShipmentView(viewModel: ShipmentViewModel(shipment: Shipment(
        id: 1,
        shipmentNum: "SHIP-123456",
        status: "READY",
        eta: nil,
        totalDist: 250.5,
        totalTime: 5.3,
        plateNumber: "B 1234 XYZ",
        deliveryOrders: [
            DeliveryOrder(id: 1, deliveryOrderNum: "DO-987654", length: 30.0, width: 20.0, height: 15.0),
            DeliveryOrder(id: 2, deliveryOrderNum: "DO-567890", length: 40.0, width: 25.0, height: 20.0)
        ]
    )))
}
