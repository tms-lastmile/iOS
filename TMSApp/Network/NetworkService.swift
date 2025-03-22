//
//  NetworkService.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 13/03/25.
//

import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "http://192.168.1.9:8080/api/v1"
    private let storageURL = "http://192.168.1.9:8081"
    
    func login(username: String, password: String, completion: @escaping (Result<LoginData, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/mobile/login") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let body: [String: String] = [
            "username": username,
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                completion(.failure(NSError(domain: "LoginError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Nama pengguna atau kata sandi salah"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "LoginError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Data tidak ditemukan"])))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                if let loginData = decodedResponse.data {
                    completion(.success(loginData))
                } else {
                    completion(.failure(NSError(domain: "LoginError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Respons tidak valid dari server"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func fetchShipments(skip: Int, limit: Int, completion: @escaping (Result<ShipmentData, Error>) -> Void) {
            guard let url = URL(string: "\(baseURL)/mobile/shipments?skip=\(skip)&limit=\(limit)") else {
                completion(.failure(URLError(.badURL)))
                return
            }

            guard let token = KeychainHelper.shared.get(forKey: "authToken") else {
                completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Akses ditolak"])))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                    completion(.failure(NSError(domain: "APIError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Gagal mengambil data pengiriman"])))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "APIError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Data tidak ditemukan"])))
                    return
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(ShipmentResponse.self, from: data)
                    completion(.success(decodedResponse.data))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    
    func searchShipment(shipmentNum: String, completion: @escaping (Result<[Shipment], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/mobile/shipment/search?shipment_num=\(shipmentNum)") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        guard let token = KeychainHelper.shared.get(forKey: "authToken") else {
            completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Akses ditolak"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                completion(.failure(NSError(domain: "APIError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Gagal mencari data pengiriman"])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "APIError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Data tidak ditemukan"])))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(ShipmentSearchResponse.self, from: data)
                completion(.success(decodedResponse.data))
            } catch {
                completion(.failure(error))
            }
        }

        task
            .resume()
    }
    
    func uploadPlyFile(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let uploadURL = URL(string: "\(storageURL)/upload")!
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("IbVW7XSCs6jH0skHEVwwRrvL2RHZiGnAWpZtWoWxFQiWorNBVo0wOysBgduAwhBTvcgEMBCOX68ewLrlnTFQzIu9TDGjGwzAYLEeTFsvzdjpLFmD5kmL4AjdPtdKZfZp", forHTTPHeaderField: "X-API-KEY")

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)

        do {
            let fileData = try Data(contentsOf: fileURL)
            body.append(fileData)
        } catch {
            completion(.failure(error))
            return
        }

        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        let task = URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                completion(.failure(NSError(domain: "UploadError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Gagal mengunggah file"])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "UploadError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Respons kosong dari server"])))
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                completion(.success(responseString))
            } else {
                completion(.failure(NSError(domain: "UploadError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Gagal membaca respons server"])))
            }
        }
        
        task.resume()
    }

}
