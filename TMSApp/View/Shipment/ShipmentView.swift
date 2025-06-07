//
//  ShipmentView.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import SwiftUI

enum ShipmentAlertType: Identifiable {
    case confirmSave(deliveryOrderId: Int)
    case confirmDelete(deliveryOrderId: Int, box: Box)
    case info(title: String, message: String)

    var id: String {
        switch self {
        case .confirmSave(let id): return "confirmSave_\(id)"
        case .confirmDelete(_, let box): return "confirmDelete_\(box.id)"
        case .info(let title, _): return title
        }
    }
}

struct ShipmentView: View {
    @StateObject var viewModel: ShipmentViewModel
    @State private var expandedDOId: Int?
    @State private var activeAlert: ShipmentAlertType?
    @State private var selectedDOIdForBoxAction: Int? = nil
    @State private var isShowingBoxIdPrompt = false
    @State private var inputBoxId = ""
    @State private var showBoxNotFoundAlert = false
    @State private var selectedFoundBox: Box? = nil
    @State private var isShowingQuantityForExistingBox = false
    @State private var existingBoxQuantity: Int = 1

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Memuat detail pengiriman...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let shipment = viewModel.shipment {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ShipmentInfoView(shipment: shipment)

                        if !shipment.deliveryOrders.isEmpty {
                            Text("Delivery Orders")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(viewModel.deliveryOrders, id: \.id) { deliveryOrder in
                                DeliveryOrderSectionWrapper(
                                    deliveryOrder: deliveryOrder,
                                    isExpanded: expandedDOId == deliveryOrder.id,
                                    onToggle: {
                                        withAnimation {
                                            expandedDOId = (expandedDOId == deliveryOrder.id) ? nil : deliveryOrder.id
                                        }
                                    },
                                    onAddBoxTapped: {
                                        selectedDOIdForBoxAction = deliveryOrder.id
                                        isShowingBoxIdPrompt = true
                                    },
                                    onSaveBoxesTapped: {
                                        activeAlert = .confirmSave(deliveryOrderId: deliveryOrder.id)
                                    },
                                    onDeleteBoxTapped: { box in
                                        activeAlert = .confirmDelete(deliveryOrderId: deliveryOrder.id, box: box)
                                    }
                                )
                            }
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
            } else {
                Text("Pengiriman tidak ditemukan.")
                    .foregroundColor(.gray)
            }
        }
        .overlay {
            if viewModel.isSaving {
                ToastView(message: "Menyimpan box...")
            }
        }
        .navigationTitle("Detail Pengiriman")
        .onChange(of: viewModel.uploadSuccess) {
            if let success = viewModel.uploadSuccess {
                let title = success ? "Sukses" : "Gagal"
                activeAlert = .info(title: title, message: viewModel.uploadMessage)
                viewModel.uploadSuccess = nil
            }
        }
        .onAppear {
            viewModel.fetchShipmentDetail()
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .confirmSave(let doId):
                return Alert(
                    title: Text("Simpan Box?"),
                    message: Text("Apakah kamu yakin ingin menyimpan semua box baru untuk DO ini?"),
                    primaryButton: .default(Text("Simpan")) {
                        viewModel.saveBoxes(for: doId)
                    },
                    secondaryButton: .cancel()
                )
            case .confirmDelete(let doId, let box):
                return Alert(
                    title: Text("Hapus Box?"),
                    message: Text("Apakah kamu yakin ingin menghapus box ini?"),
                    primaryButton: .destructive(Text("Hapus")) {
                        viewModel.deleteBox(for: doId, boxId: box.id)
                    },
                    secondaryButton: .cancel()
                )
            case .info(let title, let message):
                return Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))
            }
        }
        .alert("Masukkan Nama Box", isPresented: $isShowingBoxIdPrompt, actions: {
            TextField("Nama Box", text: $inputBoxId)
            Button("Cari") {
                guard let _ = selectedDOIdForBoxAction else { return }
                viewModel.searchBoxByName(inputBoxId) { foundBox in
                    if let box = foundBox {
                        selectedFoundBox = box
                        isShowingQuantityForExistingBox = true
                    } else {
                        showBoxNotFoundAlert = true
                    }
                    inputBoxId = ""
                }
            }
            Button("Batal", role: .cancel) {
                inputBoxId = ""
            }
        })
        .alert("Jumlah Box", isPresented: $isShowingQuantityForExistingBox, actions: {
            TextField("Jumlah", value: $existingBoxQuantity, format: .number)
                .keyboardType(.numberPad)
            Button("Tambah") {
                if let box = selectedFoundBox, let doId = selectedDOIdForBoxAction {
                    viewModel.addExistingBox(box, to: doId, quantity: existingBoxQuantity)
                }
                selectedFoundBox = nil
                existingBoxQuantity = 1
            }
            Button("Batal", role: .cancel) {
                selectedFoundBox = nil
                existingBoxQuantity = 1
            }
        })
        .alert("Box tidak ditemukan", isPresented: $showBoxNotFoundAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

struct ShipmentInfoView: View {
    let shipment: Shipment

    var body: some View {
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
    }
}

private struct DeliveryOrderSectionWrapper: View {
    let deliveryOrder: DeliveryOrder
    let isExpanded: Bool
    let onToggle: () -> Void
    let onAddBoxTapped: () -> Void
    let onSaveBoxesTapped: () -> Void
    let onDeleteBoxTapped: (Box) -> Void

    var body: some View {
        DeliveryOrderSectionView(
            deliveryOrder: deliveryOrder,
            isExpanded: isExpanded,
            onToggle: onToggle,
            onAddBoxTapped: onAddBoxTapped,
            onSaveBoxesTapped: onSaveBoxesTapped,
            onDeleteBoxTapped: onDeleteBoxTapped
        )
    }
}

struct DeliveryOrderSectionView: View {
    let deliveryOrder: DeliveryOrder
    let isExpanded: Bool
    let onToggle: () -> Void
    let onAddBoxTapped: () -> Void
    let onSaveBoxesTapped: () -> Void
    let onDeleteBoxTapped: (Box) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DeliveryOrderCardView(
                deliveryOrder: deliveryOrder,
                isExpanded: isExpanded,
                onAddBoxTapped: onAddBoxTapped,
                onToggle: onToggle,
                onSaveBoxesTapped: onSaveBoxesTapped
            )

            if isExpanded {
                ForEach(deliveryOrder.boxes) { box in
                    BoxCardView(
                        box: box,
                        onDeleteTapped: {
                            onDeleteBoxTapped(box)
                        }
                    )
                }
            }
        }
        .padding(.bottom, 12)
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
