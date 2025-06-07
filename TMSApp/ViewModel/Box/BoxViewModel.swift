//
//  BoxViewModel.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 04/05/25.
//

import Foundation

class BoxViewModel: ObservableObject {
    @Published var boxes: [BoxModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var uploadSuccess: Bool? = nil
    @Published var uploadMessage: String = ""
    @Published var isCalculating: Bool = false
    @Published var isUploading: Bool = false
    @Published var selectedBox: BoxModel?

    func fetchBoxes() {
        isLoading = true
        errorMessage = nil
        boxes = []

        NetworkService.shared.fetchAllBoxes { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let boxes):
                    self?.boxes = boxes
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func addNewBox(name: String) {
        let newBox = BoxModel(
            id: UUID().uuidString,
            name: name,
            height: 0,
            width: 0,
            length: 0,
            pcUrl: nil,
            status: "created"
        )

        selectedBox = newBox
    }

    func uploadPlyFile(forDirectory directoryPath: String) {
        guard let fileURL = getPlyFile(forDirectory: directoryPath),
              var box = selectedBox else {
            self.uploadSuccess = false
            self.uploadMessage = "File atau box tidak valid"
            return
        }

        isUploading = true

        NetworkService.shared.uploadPlyFile(fileURL: fileURL) { [weak self] result in
            DispatchQueue.main.async {
                self?.isUploading = false

                switch result {
                case .success(let responseString):
                    if let data = responseString.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let urlOnly = json["url"] as? String {

                        box.pcUrl = urlOnly
                        self?.saveBoxToDatabase(box: box)
                    } else {
                        self?.uploadSuccess = false
                        self?.uploadMessage = "Gagal membaca URL dari response upload."
                    }

                case .failure(let error):
                    self?.uploadSuccess = false
                    self?.uploadMessage = "Gagal upload: \(error.localizedDescription)"
                }
            }
        }
    }

    func saveBoxToDatabase(box: BoxModel) {
        NetworkService.shared.createBox(box) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.boxes.append(box)
                    self?.uploadSuccess = true
                    self?.uploadMessage = "Box berhasil disimpan!"
                    self?.fetchBoxes() 
                case .failure(let error):
                    self?.uploadSuccess = false
                    self?.uploadMessage = "Gagal menyimpan box: \(error.localizedDescription)"
                }
            }
        }
    }

    private func getPlyFile(forDirectory directoryPath: String) -> URL? {
        let directoryURL = getDocumentsDirectory().appendingPathComponent(directoryPath, isDirectory: true)
        return try? FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            .first(where: { $0.pathExtension.lowercased() == "ply" })
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func calculateVolume(for boxId: String) {
        isCalculating = true
        uploadSuccess = nil
        uploadMessage = ""

        NetworkService.shared.calculateBoxVolume(boxId: boxId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isCalculating = false

                switch result {
                case .success:
                    self?.uploadSuccess = true
                    self?.uploadMessage = "Perhitungan dimulai"
                    self?.fetchBoxes()
                case .failure(let error):
                    self?.uploadSuccess = false
                    self?.uploadMessage = "Gagal memulai perhitungan: \(error.localizedDescription)"
                    self?.fetchBoxes()
                }
            }
        }
    }
}
