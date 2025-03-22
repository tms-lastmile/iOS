//
//  ShipmentViewModel.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 13/03/25.
//

import Foundation

class ShipmentViewModel: ObservableObject {
    @Published var shipment: Shipment?
    @Published var deliveryOrders: [DeliveryOrder] = []
    @Published var isUploading: Bool = false
    @Published var uploadSuccess: Bool? = nil
    @Published var uploadMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var selectedBox: Box?
    
    private let shipmentId: Int

    init(shipmentId: Int) {
        self.shipmentId = shipmentId
    }

    func boxesForDO(_ deliveryOrderId: Int) -> [Box] {
        deliveryOrders.first(where: { $0.id == deliveryOrderId })?.boxes ?? []
    }

    func createBox(for deliveryOrderId: Int) {
        guard let index = deliveryOrders.firstIndex(where: { $0.id == deliveryOrderId }) else { return }

        var updatedDO = deliveryOrders[index]
        let newBox = Box(
            id: UUID().uuidString,
            height: 0,
            width: 0,
            length: 0,
            pcUrl: "",
            scannedAt: nil,
            isSaved: false
        )

        updatedDO.boxes.append(newBox)
        deliveryOrders[index] = updatedDO
    }

    func saveBoxes(for deliveryOrderId: Int) {
        guard let index = deliveryOrders.firstIndex(where: { $0.id == deliveryOrderId }) else { return }
        let boxesToSave = deliveryOrders[index].boxes.filter { !$0.isSaved }

        guard !boxesToSave.isEmpty else {
            self.uploadSuccess = false
            self.uploadMessage = "Tidak ada box baru yang bisa disimpan."
            return
        }

        let payload = boxesToSave.map { box in
            [
                "id": box.id,
                "height": box.height,
                "width": box.width,
                "length": box.length,
                "pcUrl": box.pcUrl ?? "",
                "isSaved": true
            ]
        }

        NetworkService.shared.saveBoxes(for: deliveryOrderId, payload: payload) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.uploadSuccess = true
                    self.uploadMessage = "Berhasil menyimpan box ke server."
                    for i in self.deliveryOrders[index].boxes.indices {
                        self.deliveryOrders[index].boxes[i].isSaved = true
                    }
                case .failure(let error):
                    self.uploadSuccess = false
                    self.uploadMessage = "Gagal menyimpan box: \(error.localizedDescription)"
                }
            }
        }
    }

    func uploadPlyFile(forDirectory directoryPath: String, for deliveryOrderId: Int, boxId: String) {
        guard let fileURL = getPlyFile(forDirectory: directoryPath) else {
            self.uploadSuccess = false
            self.uploadMessage = "File PLY tidak ditemukan di \(directoryPath)"
            return
        }

        isUploading = true

        NetworkService.shared.uploadPlyFile(fileURL: fileURL) { result in
            DispatchQueue.main.async {
                self.isUploading = false

                switch result {
                case .success(let uploadedUrl):
                    self.uploadSuccess = true
                    self.uploadMessage = "File berhasil diunggah!"
                    if let index = self.deliveryOrders.firstIndex(where: { $0.id == deliveryOrderId }),
                       let boxIndex = self.deliveryOrders[index].boxes.firstIndex(where: { $0.id == boxId }) {
                        self.deliveryOrders[index].boxes[boxIndex].pcUrl = uploadedUrl
                    }
                case .failure(let error):
                    self.uploadSuccess = false
                    self.uploadMessage = "Gagal upload: \(error.localizedDescription)"
                }
            }
        }
    }

    func getPlyFile(forDirectory directoryPath: String) -> URL? {
        let directoryURL = getDocumentsDirectory().appendingPathComponent(directoryPath, isDirectory: true)
        return try? FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            .first(where: { $0.pathExtension.lowercased() == "ply" })
    }

    func fetchShipmentDetail() {
        isLoading = true

        NetworkService.shared.fetchShipmentDetail(id: shipmentId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let shipment):
                    self?.shipment = shipment
                    self?.deliveryOrders = shipment.deliveryOrders
                case .failure(let error):
                    print("Gagal fetch detail shipment: \(error.localizedDescription)")
                }
            }
        }
    }
}
