//
//  PetsService.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 10.03.26.
//

import UIKit

final class PetsService: PetsServicing {
    
    static let shared = PetsService()
    
    private init() {}
    
    func getPets() async throws -> [PetResponse] {
        try await APIClient.shared.request(
            endpoint: "/pets",
            method: "GET",
            requiresAuth: true
        )
    }
    
    func getPet(id: String) async throws -> PetResponse {
        try await APIClient.shared.request(
            endpoint: "/pets/\(id)",
            method: "GET",
            requiresAuth: true
        )
    }
    
    func createPet(_ requestModel: CreatePetRequest) async throws -> PetResponse {
        let body = try JSONEncoder().encode(requestModel)
        
        return try await APIClient.shared.request(
            endpoint: "/pets",
            method: "POST",
            body: body,
            requiresAuth: true
        )
    }
    
    func updatePet(id: String, requestModel: CreatePetRequest) async throws -> PetResponse {
        let body = try JSONEncoder().encode(requestModel)
        
        return try await APIClient.shared.request(
            endpoint: "/pets/\(id)",
            method: "PATCH",
            body: body,
            requiresAuth: true
        )
    }
    
    func deletePet(id: String) async throws {
        let _: DeletePetResponse = try await APIClient.shared.request(
            endpoint: "/pets/\(id)",
            method: "DELETE",
            requiresAuth: true
        )
    }
    
    func setHighlightedPet(id: String) async throws -> PetResponse {
        try await APIClient.shared.request(
            endpoint: "/pets/\(id)/highlight",
            method: "PATCH",
            requiresAuth: true
        )
    }
    
    func uploadPetPhoto(petId: String, image: UIImage) async throws -> PetResponse {
        guard let url = APIClient.shared.makeURL(endpoint: "/pets/\(petId)/photo") else {
            throw URLError(.badURL)
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(
                domain: "UploadPetPhoto",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Failed to prepare image data"]
            )
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let accessToken = SessionManager.shared.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"pet.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        print("URL:", url.absoluteString)
        print("Method: POST")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("Status Code:", http.statusCode)
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response Body:", responseString)
        }
        
        if !(200...299).contains(http.statusCode) {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown upload error"
            throw NSError(
                domain: "UploadPetPhoto",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: errorBody]
            )
        }
        
        return try JSONDecoder().decode(PetResponse.self, from: data)
    }
    
    func deletePetPhoto(id: String) async throws -> PetResponse {
        try await APIClient.shared.request(
            endpoint: "/pets/\(id)/photo",
            method: "DELETE",
            requiresAuth: true
        )
    }
}
