//
//  UsersService.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 10.03.26.
//

import UIKit

struct AvatarUploadResponse: Codable {
    let avatarUrl: String
}

final class UsersService: UserServicing {
    
    static let shared = UsersService()
    
    private init() {}
    
    func uploadAvatar(image: UIImage) async throws -> AvatarUploadResponse {
        guard let url = APIClient.shared.makeURL(endpoint: "/users/avatar") else {
            throw URLError(.badURL)
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(
                domain: "UploadAvatar",
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
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"avatar.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("URL:", url.absoluteString)
        print("Method: POST")
        print("Status Code:", http.statusCode)
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response Body:", responseString)
        }
        
        if !(200...299).contains(http.statusCode) {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown upload error"
            throw NSError(
                domain: "UploadAvatar",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: errorBody]
            )
        }
        
        return try JSONDecoder().decode(AvatarUploadResponse.self, from: data)
    }
    
    func updateProfile(name: String) async throws -> UserResponse {
        let body = try JSONEncoder().encode(
            UpdateProfileRequest(name: name)
        )
        
        return try await APIClient.shared.request(
            endpoint: "/users/me",
            method: "PATCH",
            body: body,
            requiresAuth: true
        )
    }
}
