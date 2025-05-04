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
    @Published var uploadSuccess: Bool? = nil
    @Published var uploadMessage: String = ""
    @Published var isLoading: Bool = false

    private let shipmentId: Int

    init(shipmentId: Int) {
        self.shipmentId = shipmentId
    }

    func boxesForDO(_ deliveryOrderId: Int) -> [Box] {
        deliveryOrders.first(where: { $0.id == deliveryOrderId })?.boxes ?? []
    }

    func saveBoxes(for deliveryOrderId: Int) {
        guard let index = deliveryOrders.firstIndex(where: { $0.id == deliveryOrderId }) else { return }
        let boxes = deliveryOrders[index].boxes
        let newBoxes = boxes.filter { $0.isNew }

        guard !newBoxes.isEmpty else {
            uploadSuccess = false
            uploadMessage = "Tidak ada box baru untuk disimpan."
            return
        }

        let payload = newBoxes.map { box in
            [
                "id": box.id,
                "quantity": box.quantity
            ]
        }

        NetworkService.shared.saveBoxes(for: deliveryOrderId, payload: payload) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    var updatedOrders = self.deliveryOrders
                    updatedOrders[index].boxes = boxes.map { box in
                        var updatedBox = box
                        if updatedBox.isNew {
                            updatedBox.isNew = false
                        }
                        return updatedBox
                    }

                    self.deliveryOrders = updatedOrders
                    self.uploadSuccess = true
                    self.uploadMessage = "Berhasil menyimpan semua box baru."
                case .failure(let error):
                    self.uploadSuccess = false
                    self.uploadMessage = "Gagal menyimpan box: \(error.localizedDescription)"
                }
            }
        }
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

        updatedBoxes.remove(at: boxIndex)
        deliveryOrders[doIndex].boxes = updatedBoxes
        
        if deliveryOrders[doIndex].boxes[boxIndex].isNew {
            updatedBoxes.remove(at: boxIndex)
            deliveryOrders[doIndex].boxes = updatedBoxes
            uploadSuccess = true
            uploadMessage = "Box berhasil dihapus."
        } else {
            updatedBoxes.remove(at: boxIndex)
            deliveryOrders[doIndex].boxes = updatedBoxes
            NetworkService.shared.deleteBox(boxId: boxId, doId: deliveryOrderId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.uploadSuccess = true
                        self.uploadMessage = "Box berhasil dihapus."
                    case .failure(let error):
                        self.uploadSuccess = false
                        self.uploadMessage = "Gagal menghapus box: \(error.localizedDescription)"
                    }
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

        let isDuplicate = deliveryOrders[index].boxes.contains { $0.name == box.name }
        if isDuplicate {
            uploadSuccess = false
            uploadMessage = "Box '\(box.name)' sudah ada di DO ini."
            return
        }

        var newBox = box
        newBox.quantity = quantity
        newBox.isNew = true
        deliveryOrders[index].boxes.append(newBox)
    }
}
