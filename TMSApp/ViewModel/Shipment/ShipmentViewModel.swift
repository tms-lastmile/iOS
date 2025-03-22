//
//  ShipmentViewModel.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 13/03/25.
//

import Foundation

class ShipmentViewModel: ObservableObject {
    @Published var shipment: Shipment
    @Published var isUploading: Bool = false
    @Published var uploadSuccess: Bool? = nil
    @Published var uploadMessage: String = ""

    init(shipment: Shipment) {
        self.shipment = shipment
    }
    
    func getPlyFile(forDirectory directoryPath: String) -> URL? {
        let fileManager = FileManager.default
        do {
            let directoryURL = getDocumentsDirectory().appendingPathComponent(directoryPath, isDirectory: true)
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            let pclFiles = fileURLs.filter { $0.pathExtension.lowercased() == "ply" }
            return pclFiles.first
        } catch {
            print("Error reading contents of directory: \(error.localizedDescription)")
            return nil
        }
    }
    
    func uploadPlyFile(forDirectory directoryPath: String) {
        guard let plyFileURL = getPlyFile(forDirectory: directoryPath) else {
            DispatchQueue.main.async {
                self.uploadSuccess = false
                self.uploadMessage = "File PLY tidak ditemukan di \(directoryPath)"
            }
            return
        }

        isUploading = true

        NetworkService.shared.uploadPlyFile(fileURL: plyFileURL) { result in
            DispatchQueue.main.async {
                self.isUploading = false
                
                switch result {
                case .success(let response):
                    print("Upload sukses: \(response)")
                    self.uploadSuccess = true
                    self.uploadMessage = "File berhasil diunggah!"
                case .failure(let error):
                    print("Gagal upload: \(error.localizedDescription)")
                    self.uploadSuccess = false
                    self.uploadMessage = "Gagal mengunggah file: \(error.localizedDescription)"
                }
            }
        }
    }
}
