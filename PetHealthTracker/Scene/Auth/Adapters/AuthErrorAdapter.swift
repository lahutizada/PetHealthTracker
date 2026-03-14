//
//  AuthErrorAdapter.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 14.03.26.
//

import Foundation

enum AuthErrorAdapter {
    static func message(from error: Error) -> String {
        let message = (error as NSError).localizedDescription.lowercased()

        if message.contains("invalid credentials") {
            return "Wrong email or password"
        }

        if message.contains("email already in use") {
            return "This email is already in use"
        }

        if message.contains("email must be an email") {
            return "Incorrect email format"
        }

        if message.contains("email should not be empty") {
            return "Email is required"
        }

        if message.contains("password should not be empty") {
            return "Password is required"
        }

        if message.contains("password must be longer") || message.contains("password must be at least 8") {
            return "Password must be at least 8 characters"
        }

        if message.contains("could not connect to the server") {
            return "Cannot connect to server"
        }

        return "Something went wrong. Please try again."
    }
}
