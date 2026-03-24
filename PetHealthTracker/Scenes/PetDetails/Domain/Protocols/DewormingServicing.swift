//
//  DewormingServicing.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 22.03.26.
//

import Foundation

protocol DewormingServicing {
    func getDeworming(petId: String) async throws -> [DewormingRecordResponse]
    func createDeworming(_ requestModel: CreateDewormingRequest) async throws -> DewormingRecordResponse
    func updateDeworming(id: String, requestModel: UpdateDewormingRequest) async throws -> DewormingRecordResponse
    func deleteDeworming(id: String) async throws
}
