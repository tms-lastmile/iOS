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
    @Published var availableBoxes: [Box] = []
    @Published var isUploading: Bool = false
    @Published var isCalculating: Bool = false
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
    
    func createBox(for deliveryOrderId: Int, withName name: String, quantity: Int) {
        guard let index = deliveryOrders.firstIndex(where: { $0.id == deliveryOrderId }) else { return }

        NetworkService.shared.getBoxByName(name: name) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.uploadSuccess = false
                    self.uploadMessage = "Box dengan nama '\(name)' sudah ada di database. Gunakan fitur Tambah Box Lama."
                    
                case .failure:
                    var updatedDO = self.deliveryOrders[index]

                    let isDuplicateLocal = updatedDO.boxes.contains { $0.name == name }
                    if isDuplicateLocal {
                        self.uploadSuccess = false
                        self.uploadMessage = "Box dengan nama '\(name)' sudah ada di Delivery Order ini."
                        return
                    }

                    let newBox = Box(
                        id: UUID().uuidString,
                        name: name,
                        height: 0,
                        width: 0,
                        length: 0,
                        pcUrl: "",
                        scannedAt: nil,
                        isSaved: false,
                        quantity: quantity
                    )

                    updatedDO.boxes.append(newBox)
                    self.deliveryOrders[index] = updatedDO
                }
            }
        }
    }

    func saveBoxes(for deliveryOrderId: Int) {
        guard let index = deliveryOrders.firstIndex(where: { $0.id == deliveryOrderId }) else { return }
        let boxes = deliveryOrders[index].boxes

        guard !boxes.isEmpty else {
            self.uploadSuccess = false
            self.uploadMessage = "Tidak ada box yang bisa disimpan."
            return
        }
        
        let boxesWithoutScan = boxes.filter { ($0.pcUrl ?? "").isEmpty }
        guard boxesWithoutScan.isEmpty else {
            self.uploadSuccess = false
            self.uploadMessage = "Semua box harus sudah discan sebelum menyimpan."
            return
        }

        let payload = boxes.map { box in
            [
                "id": box.id,
                "name": box.name,
                "height": box.height,
                "width": box.width,
                "length": box.length,
                "pcUrl": box.pcUrl ?? "",
                "isSaved": box.isSaved,
                "quantity": box.quantity
            ]
        }

        NetworkService.shared.saveBoxes(for: deliveryOrderId, payload: payload) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    var updatedOrders = self.deliveryOrders
                    updatedOrders[index].boxes = boxes.map { oldBox in
                        var newBox = oldBox
                        newBox.isSaved = true
                        return newBox
                    }
                    self.deliveryOrders = updatedOrders

                    self.uploadSuccess = true
                    self.uploadMessage = "Berhasil menyimpan semua box."
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
                case .success(let responseString):
                    if let data = responseString.data(using: .utf8) {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            let urlOnly = json?["url"] as? String ?? ""

                            self.uploadSuccess = true
                            self.uploadMessage = "File berhasil diunggah!"

                            if let index = self.deliveryOrders.firstIndex(where: { $0.id == deliveryOrderId }),
                               let boxIndex = self.deliveryOrders[index].boxes.firstIndex(where: { $0.id == boxId }) {
                                self.deliveryOrders[index].boxes[boxIndex].pcUrl = urlOnly
                            }
                        } catch {
                            self.uploadSuccess = false
                            self.uploadMessage = "Gagal membaca URL dari response upload."
                        }
                    } else {
                        self.uploadSuccess = false
                        self.uploadMessage = "Respons tidak valid dari server."
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
    
    func deleteBox(for deliveryOrderId: Int, boxId: String) {
        guard let doIndex = deliveryOrders.firstIndex(where: { $0.id == deliveryOrderId }) else { return }
        
        var updatedBoxes = deliveryOrders[doIndex].boxes

        guard let boxIndex = updatedBoxes.firstIndex(where: { $0.id == boxId }) else { return }

        let box = updatedBoxes[boxIndex]

        updatedBoxes.remove(at: boxIndex)
        deliveryOrders[doIndex].boxes = updatedBoxes

        if box.isSaved {
            NetworkService.shared.deleteBox(boxId: boxId, doId: deliveryOrderId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        if updatedBoxes.isEmpty {
                            self.uploadSuccess = true
                            self.uploadMessage = "Semua box sudah dihapus dari Delivery Order ini."
                        } else {
                            self.uploadSuccess = true
                            self.uploadMessage = "Relasi Box dan DO berhasil dihapus."
                        }
                    case .failure(let error):
                        self.uploadSuccess = false
                        self.uploadMessage = "Gagal menghapus relasi box: \(error.localizedDescription)"
                    }
                }
            }
        } else {
            if updatedBoxes.isEmpty {
                self.uploadSuccess = true
                self.uploadMessage = "Semua box sudah dihapus dari Delivery Order ini."
            }
        }
    }
    
    func calculateVolume(for box: Box) {
        guard let doIndex = deliveryOrders.firstIndex(where: { $0.boxes.contains(where: { $0.id == box.id }) }),
              let _ = deliveryOrders[doIndex].boxes.firstIndex(where: { $0.id == box.id }) else { return }

        isCalculating = true

        NetworkService.shared.calculateBoxVolume(boxId: box.id) { result in
            DispatchQueue.main.async {
                self.isCalculating = false
                switch result {
                case .success:
                    self.uploadSuccess = true
                    self.uploadMessage = "Perhitungan volume berhasil dimulai!"
                case .failure(let error):
                    self.uploadSuccess = false
                    self.uploadMessage = "Gagal memulai perhitungan: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func searchBoxByName(_ name: String, completion: @escaping (Box?) -> Void) {
        NetworkService.shared.getBoxByName(name: name) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let box):
                    completion(box)
                case .failure:
                    completion(nil)
                }
            }
        }
    }
    
    func addExistingBox(_ box: Box, to deliveryOrderId: Int, quantity: Int) {
        guard let index = deliveryOrders.firstIndex(where: { $0.id == deliveryOrderId }) else { return }
        
        var newDOs = deliveryOrders

        let isDuplicate = newDOs[index].boxes.contains { $0.name == box.name }
        if isDuplicate {
            self.uploadSuccess = false
            self.uploadMessage = "Box dengan nama '\(box.name)' sudah ada di DO ini."
            return
        }

        var newBox = box
        newBox.isSaved = false
        newBox.quantity = quantity

        newDOs[index].boxes.append(newBox)
        deliveryOrders = newDOs
    }

}
