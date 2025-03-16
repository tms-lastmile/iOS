//
//  NetworkService.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 13/03/25.
//

import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "http://localhost:8080/api/v1"
    
    func login(username: String, password: String, completion: @escaping (Result<LoginData, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/login") else {
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
            guard let url = URL(string: "\(baseURL)/mobile/shipment?skip=\(skip)&limit=\(limit)") else {
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

        task.resume()
    }

}
